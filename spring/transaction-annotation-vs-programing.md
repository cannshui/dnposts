## @Transactional vs. TransactionTemplate

使用 Spring 的事务框架可以极大方便事务操作。 Spring 事务管理方式基本有两种，声明式事务管理和编程式事务管理。这篇文章，并不深究原理，而只是记录使用中容易出错的点。比如，为何加了注解事务却不生效；声明式事务管理和编程式事务管理应该如何选择。

测试环境：JDK 1.8，Spring 5.x，数据库 MySQL 5.7。

测试表和类简列如下，起始处于不加事务的状态：

    // 插入
    create table `mock_tx` (
      `id` int not null auto_increment,
      `name` varchar(5) not null, -- 最多 5 个字符
      constraint `pk_mock_tx` primary key (`id`)
    ) engine=InnoDB charset=utf8;

    // Service 接口
    public interface MockTxService {

        void mockBatchUpdate();

    }

    // Service 实现，注册为 Spring Bean
    @Service
    public class MockTxServiceImpl implements MockTxService {
    
        @Autowired
        private JdbcTemplate jdbcTemplate;
    
        @Override
        public void mockBatchUpdate() {
            this.batchInsertOperation1();
        }
    
        // 插入 5 条记录
        public void batchInsertOperation1() {
            String sql = "insert into mock_tx (name) values (?)";
            Random rand = new Random();
            List<Object[]> names = IntStream.range(1, 6).mapToObj(i -> new Object[] { rand.nextInt(100000) + "" }).collect(Collectors.toList());
            // 模拟第三个位置引入了一个错误
            names.get(3)[0] = "greater than 5 chars";
            this.jdbcTemplate.batchUpdate(sql, names);
        }
    
        // 更新 5 条记录
        public void batchUpdateOperation2() {
            String sql = "update mock_tx set name = ? where id = ?";
            Random rand = new Random();
            List<Object[]> names = IntStream.range(6, 11).mapToObj(i -> new Object[] { rand.nextInt(100000) + "", i }).collect(Collectors.toList());
            // 模拟第三个位置引入了一个错误
            names.get(3)[0] = "greater than 5 chars";
            this.jdbcTemplate.batchUpdate(sql, names);
        }
    
    }

### 备忘：rewriteBatchedStatements=true 对 JdbcTemplate batchUpdate 的改变

默认 `rewriteBatchedStatements` 为 false，batchUpdate 中执行的语句，合法的语句将执行成功，比如，上述 `batchInsertOperation1` 将会插入 4 条记录，`batchUpdateOperation2` 将会更新 4 条记录。非法的语句将会执行失败，当全部执行 Spring 才抛出相应异常。设置 `rewriteBatchedStatements=true` 后，表现则不同了：

 - 插入操作，有一个失败就会全部失败，因为多条 `insert into mock_tx (name) values (?)` 语句将被改写成单条 `insert into mock_tx (name) values (x1), (x2), (x3), ...`
 - 更新操作，失败记录前面的会成功，后面的将会全部失败，因为多条 `update mock_tx set name = ? where id = ?` 语句将被改写成但条 `update mock_tx set name = x1 where id = id1;update mock_tx set name = x2 where id = id2; update mock_tx set name = x3 where id = id3; ...`，但因为有 `;` 间隔，所以前面执行成功的部分仍可入库。
 - 删除操作同更新操作，用 `;` 连接成单体。

### 为 mockBatchUpdate 添加事务支持

通常目标是 `mockBatchUpdate` 执行的批量更改数据库操作是安全的，也就是要么全部成功，要么全部失败。

#### @Transactional

为了使 `mockBatchUpdate` 方法成为安全的，首选方案就是应用声明式注解，使用 `@Transactional`：

    ...
    @Override
    @Transactional(rollbackFor = RuntimeException.class)
    public void mockBatchUpdate() {
    ...

首先，这是非常正确的行为。也许你注意到 `mockBatchUpdate` 只是调用了**类内部**的方法来完成工作，那是否可以直接将 `@Transactional(rollbackFor = RuntimeException.class)` 应用于 `batchUpdateOperation` 上面呢？比如像这样：

    ...
    // 插入 5 条记录
    @Transactional(rollbackFor = RuntimeException.class)
    public void batchInsertOperation1() {
    ...

答案是**不行**，测试你将会发现 `Transactional` 没有生效，还是插入了 4 条脏记录。这跟 Spring 基于 AOP 来实现事务框架的有关，同一个类内部的方法间相互调用，不会应用 AOP proxy，也就是此时 `Transactional` 不会被识别并特殊对待。你可能会想将 `batchInsertOperation1` 暴露于 `MockTxService` 接口中，这同样不行，因为也没有改变**同一个类内部的方法间相互调用**这一本质。所以，必须做跨类调用，甚至是内部类也可以：

    public class MockTxServiceImpl implements MockTxService {

        ...

        @Autowired
        private OtherClass otherClass;
    
        @Override
        public void mockBatchUpdate() {
            System.out.println(jdbcTemplate);
            // 调用内部类的事务方法
            this.otherClass.batchInsertOperation1();
        }
    
        // 哪怕在内部类中直接使用，也算跨类调用
        @Component
        class OtherClass {
    
            // 必须重新注入，不可以使用顶级类中的 jdbcTemplate，会抛出空指针异常
            @Autowired
            private JdbcTemplate jdbcTemplate;
    
            @Transactional(rollbackFor = RuntimeException.class)
            public void batchInsertOperation1() {
                System.out.println("asdfasfasdfasfsaf");
                System.out.println(jdbcTemplate);
                String sql = "insert into mock_tx (name) values (?)";
                Random rand = new Random();
                List<Object[]> names = IntStream.range(1, 6).mapToObj(i -> new Object[] { rand.nextInt(100000) + "" }).collect(Collectors.toList());
                // 模拟第三个位置引入了一个错误
                names.get(3)[0] = "greater than 5 chars";
                this.jdbcTemplate.batchUpdate(sql, names);
            }
        }

    }

#### TransactionTemplate 编程式事务

Spring 开发组一般推荐使用 `TransactionTemplate` 进行编程式事务管理。所以就只以它为例子讨论。接上面的例子，显然不可能为所有的场景都应用上述那种粗犷的类间调用，此时就可以引入 `TransactionTemplate` 的使用，他不受方法间调用的限制，比如可以：

    ...
    @Autowired
    private TransactionTemplate transactionTemplate;

    @Override
    public void mockBatchUpdate() {
        this.transactionTemplate.execute(new TransactionCallbackWithoutResult() {
            @Override
            protected void doInTransactionWithoutResult(@NonNull TransactionStatus status) {
                batchInsertOperation1();
            }
        });
    }
    ...

或者直接应用在 `batchInsertOperation1` 内部：

    ...
    @Autowired
    private TransactionTemplate transactionTemplate;

    @Override
    public void mockBatchUpdate() {
        this.batchInsertOperation1();
    }

    // 插入 5 条记录
    public void batchInsertOperation1() {
        this.transactionTemplate.execute(new TransactionCallbackWithoutResult() {
            @Override
            protected void doInTransactionWithoutResult(@NonNull TransactionStatus status) {
                String sql = "insert into mock_tx (name) values (?)";
                Random rand = new Random();
                List<Object[]> names = IntStream.range(1, 6).mapToObj(i -> new Object[] { rand.nextInt(100000) + "" }).collect(Collectors.toList());
                // 模拟第三个位置引入了一个错误
                names.get(3)[0] = "greater than 5 chars";
                jdbcTemplate.batchUpdate(sql, names);
            }
        });
    }
    ...

只需要将想保护的数据库操作放在 `TransactionCallbackWithoutResult` 的实现类中。

有时候我们的场景就是需要在小局部内事务安全，而在全局内可以容忍失败。典型的应用场景就是对海量数据的持续处理，即选择一个合适的大小来批量处理数据，循环这个过程直到处理完毕。比如有 1 千万条 `mock_tx` 的 `name` 记录，我们需要检查表中每一个 `name` 是否有误，并将有误的更改为正确。显然，不可能将 1 千万条数据一次性查询出来，当然也不会选择查询 1 千万次。而是会选择一个合理的批次，假设以 100 来取，那么程序会检查每 100 个 `name` 中的错误，并在更正后同样批量更新回 `mock_tx`。假如发生任何失败，那么就回退对这 100 个的任何操作，后续可以再次触发继续这个循环任务。

### 总结

`TransactionTemplate` 的边界显然比 `@Transactional` 更广，但是使用上也远没有 `@Transactional` 方便，这是很直观就能认识到的。除此之外，还有**更关键**的一点，即 `@Transactional` 的应用边界，并不是随便加了 `@Transactional` 就可以让操作变成事务安全的。


**参考：**

 - [https://stackoverflow.com/questions/14651276/java-multipile-update-statements-in-mysql](https://stackoverflow.com/questions/14651276/java-multipile-update-statements-in-mysql)
 - [https://stackoverflow.com/questions/2993251/jdbc-batch-insert-performance](https://stackoverflow.com/questions/2993251/jdbc-batch-insert-performance)