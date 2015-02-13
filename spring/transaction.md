###### <center>10. 事务管理</center>
###### <center>Part IV. 数据存取</center>
----------------------------------------

### 10. 事务管理
### 10.1 Spring 事务管理简介

强大、全面的事务支持是使用 Spring 框架的一个很重要因素。Spring 为事务管理提供了一致的抽象，具有以下优势：

- 为不同规范的事务 API 比如 Java Tranaction API(JTA), JDBC, Hibernate, Java Persistence API(JPA) 及 Java Data Objects(JDO) 提供一致的编程模型。
- 支持声明式事务管理。
- 简单 API 支持编程式事务管理相比于复杂的事务 API 比如 JTA。
- 与 Spring 数据存取抽象层完美整合。

以下小节讲述了 Spring 框架的事务使用和技术（译者： ERROR?）。（本章同样包括最佳编程实践、与应用服务器整合、常见问题解决方案方面的讨论。）

- Spring 事务支持模型的优势：描述了，*为什么* 你应该使用 Spring 事务抽象而非 EJB 容器-管理级事务(EJB Container-Managed Transactions,CMT) 或是通过其他所有者的事务 API 驱动本地事务比如 Hibernate 的事务 API。
- 理解 Spring 事务抽象：概述核心类及描述如何从不同数据源配置和获取`DataSource`实例。
- 利用事务同步资源：描述应用代码如何正确的保证资源的创建、重用及清理。
- 声明式事务管理：描述对声明式事务管理的支持。
- 编程式事务管理：覆盖了对编程式（即，显示代码）事务支持。

### 10.2 Spring 事务支持模型的优势

传统而言，Java EE 开发人员有两种方式进行事务管理：*全局(global)* 或 *本地(local)* 事务，这两种都有很大的限制（译者：体现在那？）。全局和本地的事务管理将在以下两小节回顾，然后是讨论 Spring 事务管理支持是如何解决全局和本地事务模型的限制。

#### 10.2.1 全局事务

全局事务使你能跟多种事务源打交道，典型如关系型数据库和消息队列。应用服务器通过 JTA 管理全局事务，而 JTA 是相当笨重的 API(部分原因是它的异常(exception)模型)。而且，一个 JTA `UserTransaction` 通常需要从 JNDI 获取，这意味着你 *必须同时使用* JNDI。显然，全局事务的使用将会限制任何潜在的代码重用，因为 JTA 通常只在应用服务器中能得到。（译者：WHAT?）

早先，使用全局事务的首先方式是通过 EJB *CMT(Container Managed Transaction)* ：CMT 是一种 **声明式事务管理** (区分自 **编程式事务管理** )。EJB CMT 移除了与事务相关联的 JNDI 查找，尽管它本身仍需要从 JNDI 中查找。它移除了大部分但并非全部通过编写 Java 代码控制事务的必要性。CMT 的显著缺点是它绑定到 JTA 及应用服务器环境。而且，只有当实现 EJB 形式的业务逻辑时 CMT 才可用，至少也得是 EJB 事务的门面（译者：Better?）。EJB 的负面效果太严重了，因为它不是一个很有吸引力的方案，特别是在面对引人注目的声明式事务管理时。

#### 10.2.2 本地事务

本地事务是跟资源相关的，比如与 JDBC 连接相关联的事务。本地事务可能使用很简便，但也有显著的缺陷：它们无法跨多种事务资源。比如，通过 JDBC 连接管理事务的代码无法再一个全局 JTA 事务中运行。因为事务管理中没有涉及到应用服务器，因而它无法帮你保证正确的跨多种资源。(这没有任何价值，因为大部分的应用程序只使用单一的事务源。)另外一个不利面是本地事务是侵入到编程模型中的。

#### 10.2.3 Spring 一致性编程模型

Spring 解决了全局和本地事务的缺陷。它使开发人员能够使用 *一致的* 编程模型 *在任何环境下* (译注：环境代指 Global, Local, JTA, CMT)。你一次编写你的代码，就能够利用不同环境事务管理策略的优势。Spring 提供了声明式和编程式事务管理。大多数用户选择声明式事务管理，它也是大部分场景较为推荐的方式。

通过编程式事务管理，开发人员直接利用运行在底层事务之上的 Spring 事务抽象。通过首选的声明式模型，开发人员只需编写很少或是不需要编写代码即可关联到事务管理，因此不依赖于 Spring 事务 API 或任何其他事务 API。

> > ###### 你需要应用服务器支持事务管理吗？
> > Have not translated.

### 10.3 理解 Spring 事务抽象

理解 Spring 事务抽象的关键是事务 *策略概念* 。事务策略定义在 `org.springframework.transaction.PlatformTransactionManager` 接口：

	public interface PlatformTransactionManager {

		TransactionStatus getTransaction(TransactionDefinition definition) throws ransactionException;

		void commit(TransactionStatus status) throws TransactionException;

		void rollback(TransactionStatus status) throws TransactionException;

	}

`PlatformTransactionManager` 是一个服务提供接口(SPI)，尽管你可以通过[编程方式](#transaction-programmatic-ptm)在应用代码中使用它。因为 `PlatformTransactionManager` 是一个 *接口* ，所以它可以很容易的被模拟或是存根(译注：WHAT?)需要的话。它没有被绑定到任何诸如 JNDI 的查找策略。`PlatformTransactionManager` 实现被定义成 Spring IoC 容器中的一个普通对象(或组件)。但这个优点就使 Spring 事务是很有价值的抽象即使你使用 JTA (译注：BETTER?)。事务代码将很容易被测试相比于直接使用 JTA。

按照 Spring 的哲学，被 `PlatformTransactionManager` 接口的任何方法抛出的`TransactionException` 可以是 *未检的* (即，继承自 `java.lang.RuntimeException` 类)。底层的事务失败几乎是致命的。非常少的场景下应用代码才能从一次事务失败中真正恢复，此时开发人员仍能选择捕获并处理 `TransactionException` 。关键是开发人员并不会 *强制* 你这么做。

`getTransaction(..)` 方法返回一个 `TransactionStatus` 对象，依赖于一个 `TransactionDefinition` 参数。返回值 `Transaction` 可以表示一个全新事务，也可以表示一个已存在于当前调用栈中匹配的事务。后一种场景的含义是，JavaEE 中事务上下文是关联到一个 **线程** 执行环境中的。

`TransactionDefinition` 接口定义了：

- **Isolaion:** 隔离性定义当前事务同其他事务的隔离级别。如，本事务可以看到其他事务还未提交的更改吗？
- **Propagation:** 一般，一个事务域中的代码只会在事务中执行。但是，你可以选择一个事务方法在一个已存在事务上下文中执行。如，代码可以继续在一个已存在事务中执行(常见情形)；或者挂起已存在事务后创建一个新的。*Spring 提供了类似于 EJB CMT 的所有的事务传播选项。* 参阅 10.5.7, “事务传播”，查看 Spring 事务传播的语义。
- **Timeout:** 超时之前事务执行的时间，超时之后将会由事务底层实现自动回滚。
- **Read-only status:** 只读事务中代码只进行数据读取而无修改。只读事务会是一些场景中非常有用的一种优化，比如当你在使用 Hibernate.

这些选项设置都映射到标准概念。如果需要的话，参阅(refer to)其他详细描述事务隔离界别等其他核心事物概念的文档。理解这些概念是使用 Spring 及任何其他事务管理方案不可或缺的。

`TransactionStatus` 接口提供了事务代码控制事务执行和查询事务状态的简便方法。这些概念应该很熟悉了，因为它们都是通用、标准的事务 API:

	public interface TransactionStatus extends SavepointManager {
	
	    boolean isNewTransaction();
	
	    boolean hasSavepoint();
	
	    void setRollbackOnly();
	
	    boolean isRollbackOnly();
	
	    void flush();
	
	    boolean isCompleted();
	
	}

无论你使用 Spring 声明式还是编程式事务管理，都必须正确定义 `PlatformTransactionManager`。一般你通过依赖注入来定义这个实现。

`PlatformTransactionManager` 的不同实现一般都需要知道它们所执行的环境：JDNC、JTA、Hibernate 等等。下面的例子展示了你应该如何定义一个本地 `PlatformTransactionManager` 实现。(这个例子基于纯 JDBC。)

定义一个 JDBC `DataSource`

	<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
		<property name="driverClassName" value="${jdbc.driverClassName}" />
		<property name="url" value="${jdbc.url}" />
		<property name="username" value="${jdbc.username}" />
		<property name="password" value="${jdbc.password}" />
	</bean>

相关联的 `PlatformTransactionManager` bean 需要一个对 `DataSource` 的引用。如下所示：

	<bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
		<property name="dataSource" ref="dataSource" />
	</bean>

如果你使用 Java EE 容器的 JTA 那么你需要一个取自 JNDI 的容器 `DataSource` ，配合 Spring 的 `JtaTransactionManager` 。如下所示是 JTA 和 JNDI 查找配置：

	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:jee="http://www.springframework.org/schema/jee"
		xsi:schemaLocation="
		http://www.springframework.org/schema/beans 
		http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
		http://www.springframework.org/schema/jee 
		http://www.springframework.org/schema/jee/spring-jee-3.0.xsd">

		<jee:jndi-lookup id="dataSource" jndi-name="jdbc/jpetstore"/> 

		<bean id="txManager" class="org.springframework.transaction.jta.JtaTransactionManager" />
  
		<!-- other <bean/> definitions here -->

	</beans>

`JtaTransactionManager` 并不需要知道 `DataSource` 或是任何其他特定的数据源，因为它使用容器底层的全局事务管理(译注：BETTER?)。

> > **Note**
> > 上面 `DataSource` 的定义使用 `jee` 命名空间的 `<jndi-lookup/>` 标记。更多信息参看基于 schema 的配置(schema-based configuration)。更多 `<jee/>` 标记信息参看 C.2.3 "The jee schma" 小节。

你同样可以方便的使用 Hibernate 的本地事务，如下例所示。你需要定义一个 Hibernate `LocalSessionFactoryBean` ，这样你的应用代码就可以从中取到 Hibernate `Session` 实例。

`DataSource` 组件的定义与之前的 JDBC 例子中相似。下面例子中没有列出 `DataSource` 组件的定义。

> > **Note**
> > 如果 `DataSouce` 被非 JTA 事务管理使用，并且它是从 JNDI 中查找到及被 JavaEE 容器管理。那么，它是非事务的因为 Spring 而非 JavaEE 容器将会去进行事务管理(译注：ERROR?)。

此时 `txManager` 组件是 `HibernateTransactionManager` 类型。同样跟 `DataSourceTransactionManager` 一样它需要 `DataSource` 的引用，`HibernateTransactionManager` 同时还需要 `SessionFactory` 引用。

	<bean id="sessionFactory"
		class="org.springframework.orm.hibernate3.LocalSessionFactoryBean">
		<property name="dataSource" ref="dataSource" />
		<property name="mappingResources">
			<list>
				<value>org/springframework/samples/petclinic/hibernate/petclinic.hbm.xml</value>
			</list>
		</property>
		<property name="hibernateProperties">
			<value>
				hibernate.dialect=${hibernate.dialect}
			</value>
		</property>
	</bean>

	<bean id="txManager"
		class="org.springframework.orm.hibernate3.HibernateTransactionManager">
		<property name="sessionFactory" ref="sessionFactory" />
	</bean>

如果你打算使用 Hibernate 或是 Java EE 容器管理的 JTA 事务，那么你可以同样简单应用 `JtaTransactionManager`，像之前为 JDBC 应用 JTA 一样。

	<bean id="txManager" class="org.springframework.transaction.jta.JtaTransactionManager"/>

> > **Note**
> > 如果你使用 JTA，那么你的事务管理定义看起来是一样的，不管你使用各种数据存取技术，比如 JDBC，Hibernate JPA 或是任何其他的支持技术。这是因为 JTA 是全局事务，它能够支持任何事务源。

所有这些场景，应用代码都无需改变。你只需要通过更改配置就能改变事务管理方式，哪怕是改变本地事务到全局事务，或相反。

### 10.4 通过事务同步资源

现在你应该清楚如何创建不同的事务管理器了，以及它们是如何绑定到需要被事务同步保护的资源(比如，`DataSourceTransactionManager` 绑定 JDBC `DataSource`，`HibernateTransactionManager` 绑定 Hibernate `SessionFactory` 等等)。本节描述应用代码如何直接或间接使用持久化 API 比如 JDBC，Hibernate 或是 JDO，确保这些资源的正确创建、重用及清理。本节同样讨论了事务同步是如何被相关的 `PlatformTransactionManager` 触发的(可选)(译注：BETTER?)。

#### 10.4.1 高层次的同步方式

首选方式就是使用 Spring 基于持久化 API 的高层次模板或是使用本地 ORM 框架的事务工厂对象 API 或是管理本地资源的代理工厂。这些事务感知方案在内部处理资源的创建、重用、清理，资源的事务同步及异常处理。从而用户数据存取代码并不再需要处理这些工作，就可以将工作重点聚焦在样板化的持久逻辑之外。一般情况下，你使用本地 ORM API 或是通过使用 `JdbcTemplate` 以 *模板* 方式访问 JDBC。这些解决方案在本参考文档的随后章节讲述。

#### 10.4.2 低层次的同步方式

许多类如 `DataSourceUtils` (方便 JDBC 使用)，`EntityManagerFactoryUtils` (方便 JPA 使用)，`SessionFactoryUtils` (方便 Hibernate 使用)，`PersistenceManagerFactoryUtils` (方便 JDO 使用)，等都存在于很低的层次。当你想让应用代码直接使用本地持久 API 进行处理时，通过使用这些类可以保证你正确得到合适的 Spring 框架所管理的实例。事务是(可选)同步的，处理过程中发生的异常将被映射到一致的 API 上。

比如，使用 JDBC 的场景，与传统使用 JDBC 的方式调用 `DataSource` 的 `getConnection()` 方法不同，你应该使用 Spring 的 `org.springframework.jdbc.datasource.DataSourceUtils` ，如下所示：

	Connection conn = DataSourceUtils.getConnection(dataSource);

如果一个现有的事务已经有一个连接对象同步(关联)到它，那个连接对象将被返回(译注：BETTER?)。否则这个方法调用触发器创建一个新的连接对象，然后同步到(可选地)任何现有事务，并在同一事务中可后续再利用。如前所述，任何 `SQLException` 都被包装成 Spring 的 `CannotGetJdbcConnectionException` ，它是 Spring 不受检异常(unchecked DataAccessExceptions)中的一个。这种方式会提供更多的信息相比于从 `SQLException` 中所得到的，并且保证了跨数据库甚至是夸不同持久技术的可移植性。

当你不使用 Spring 的事务管理(事务同步是可选的)时，这种方式同样有效。所以无论你是否使用 Spring 事务管理机制，你都可以使用它。

当然，一旦你使用了 Spring 的 JDBC 支持，JPA 支持或是 Hibernate 支持，你一般也倾向于不使用 `DataSourceUtils` 或是其他的辅助类，因为你更愿意使用 Spring 的直接、抽象 API。比如，如果你使用 Spring `JdbcTemplate` 或是 `jdbc.object` 包来简化 JDBC 应用，正确获取连接的行为发生在幕后，你不需要编写任何特殊、额外的代码。

#### 10.4.3 TransactionAwareDataSourceProxy

最基础层次有一个 `TransactionAwareDataSourceProxy` 类。它是一个对特定 `DataSource` 对象的代理类，包装 `DataSource` 对象，为其添加 Spring 事务管理。从这个方面讲，它十分类似于 JavaEE 容器提供的事务性 JDNI `DataSource` 。

几乎没必要来描述对这个类的使用，除非代码的调用必须通过传递一个标准 JDBC `DataSource` 接口的实现。这种场景下，`TransactionAwareDataSourceProxy` 类才能用，但是耦合了 Spring 的事务管理。因而，建议你最好是使用更高层次的抽象来编写代码。

### 10.5 声明式事务编程

 > > **Note**
 > >
 > > 大部分 Spring 用户选择使用声明式事务管理。因为，这种方式跟应用代码耦合很小，并跟轻量级容器的 *非侵入性* 目标一致。

Spring 的声明式事务管理基于 Spring 面向切面编程(AOP)，尽管，Spring 自带事务代码会以样板化的方式使用，但并不需要理解 AOP 概念就可以有效使用这些代码(译注：WHAT?)。

Spring 的声明式事务管理类似于 EJB CMT，其中可以在单独的方法级别定义事务行为(或不定义)。如果需要，可以使 `setRollbackOnly()` 调用在一个事务上下文中完成(译注：WAHT?)。两中事务管理的区别是：

 - 与 EJB CMT 绑定到 JTA 不同，Spring 声明式事务管理可以在任何环境中使用。只需要通过调整配置文件，它就可以利用 JTA 事务或是本地 JDBC，JPA，Hibernate，JDO。
 - 你可以将 Spring 声明式事务管理应用到任何类，而非仅仅特殊的类，如 EJB 那样。
 - Spring 提供了声明式的[*回滚规则*](#transaction-declarative-rolling-back) ，而 EJB 则没有这种特性。Spring 同时提供了编程式和声明式回滚规则。
 - Spring 允许你通过使用 AOP 定制事务行为。比如，你可以在事务回滚后执行定制的行为。你也可以随意添加 advice，跟事务 advice 一样。而使用 EJB CMT，你无法参与容器的事务管理，只能调用 `setRollbackOnly()`。
 - Spring 不像高端应用服务器那样支持远程调用的事务传播。如果你需要这个特性，那么我们推荐你使用 EJB。但是，请在使用这个特性之前考虑清楚，因为一般，不会想让一个事务传播到（译注：to span, 怎么译呢？）远程调用。

 > **TransactionProxyFactoryBean 在哪？** 
 >
 > Spring 2.0 及以上版本声明式事务编程配置与之前版本不同。主要区别是不在需要配置 `TransactionProxyFactoryBean `。
 > Spring 2.0 之前的配置方式仍 100% 是正确的。以后，考虑使用 `<tx:tags/>` 作为更简洁定义 `TransactionProxyFactoryBean ` 的方式。

回滚的概念很重要：你可以声明哪些可抛异常应该自动触发回滚。你可以在配置文件中进行声明，而非 Java 代码中。所以，尽管你仍可以调用 `TransactionStatus ` 对象的 `setRollbackOnly()` 方法来使当前事务回滚，但大多数情况下你可以声明一个规则，`MyApplicationException` 异常必须触发回滚。这个选项的显著优势是业务逻辑对象不必依赖事务基本架构。比如，业务逻辑对象不必导入 Spring 事务 API 或其他 Spring  API（译注：就可以通过编译，但运行仍需要依赖）。

尽管 EJB 容器在*系统异常（system exception）*（通常是运行时异常（runtime exception））的默认行为是自动回滚，但 EJB CMT 并不自动回滚发生*应用程序异常*（更确切的说，受检异常，除了（译注：原词 other than ）`java.rmi.RemoteException`）的事务。Spring 声明式事务管理的默认行为遵循 EJB 约定（不受检异常才能自动触发回滚），通常这种方式很有用。

#### 12.5.1 理解 Spring 声明式事务管理的实现

简单告诉你用 `@Transactional` 注解你的类，添加 `@EnableTransactionManagement` 到配置中，然后就希望你理解它是如何工作的，是毫无意义的。本节从事务相关的问题出发，解释 Spring 声明式事务管理的内部工作机制。

关于 Spring 声明式事务管理最重要的概念是它是通过[AOP 代理](aop.html#aop-understanding-aop-proxies)实现的。事务 advice 是由 *metadata*（当前 XML 或 注解进行声明）驱动。AOP 和事务元数据的组合产生 AOP 代理，协作使用 `TransactionInterceptor `  与恰当的 `latformTransactionManager` 实现，驱动*方法调用前后*的事务行为。

 > > Spring AOP 在[第 9 章](aop.html)涉及。

概念上，调用一个事务代理的方法，如下：

**图 12.1**

![tx](tx.png)

#### 12.5.2 声明式事务编程实现示例

考虑下面的接口和它的实现。这个例子使用 `Foo` 和 `Bar` 类，这样你可以将重点关注在事务的使用上而非特殊的域模型（domain model）。为了达到这个例子的目的，`DefaultFooService` 类在每个实现方法中都抛出 `UnsupportedOperationException` 异常是很必要的。你可以看到由于 `UnsupportedOperationException` 实例的创建，事务会进行创建和回滚。

	// the service interface that we want to make transactional
	// 希望进行事务管理的服务接口
	
	package x.y.service;
	
	public interface FooService {
	
		Foo getFoo(String fooName);
	
		Foo getFoo(String fooName, String barName);
	
		void insertFoo(Foo foo);
	
		void updateFoo(Foo foo);
	
	}

上述接口的一个实现：

	//an implementation of the above interface
	
	package x.y.service;
	
	public class DefaultFooService implements FooService {
	
		public Foo getFoo(String fooName) {
			throw new UnsupportedOperationException();
		}
	
		public Foo getFoo(String fooName, String barName) {
			throw new UnsupportedOperationException();
		}
	
		public void insertFoo(Foo foo) {
			throw new UnsupportedOperationException();
		}
	
		public void updateFoo(Foo foo) {
			throw new UnsupportedOperationException();
		}
	
	}

注意 `FooService` 接口的头两个方法， `getFoo(String)` 和 `getFoo(String, String)`，必须在只读语义的事务中执行，另外的两个方法 `insertFoo(Foo)` 和 `updateFoo(Foo)` 必须在读写事务中执行。下面的配置会在接下来段落中进行解释。

	<!-- from the file 'context.xml' -->
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:aop="http://www.springframework.org/schema/aop"
		xmlns:tx="http://www.springframework.org/schema/tx"
		xsi:schemaLocation="
	        http://www.springframework.org/schema/beans
	        http://www.springframework.org/schema/beans/spring-beans.xsd
	        http://www.springframework.org/schema/tx
	        http://www.springframework.org/schema/tx/spring-tx.xsd
	        http://www.springframework.org/schema/aop
	        http://www.springframework.org/schema/aop/spring-aop.xsd">
	
		<!-- this is the service object that we want to make transactional -->
		<bean id="fooService" class="x.y.service.DefaultFooService" />
	
		<!-- the transactional advice (what 'happens'; see the <aop:advisor/> bean below) -->
		<tx:advice id="txAdvice" transaction-manager="txManager">
			<!-- the transactional semantics... -->
			<tx:attributes>
				<!-- all methods starting with 'get' are read-only -->
				<tx:method name="get*" read-only="true" />
				<!-- other methods use the default transaction settings (see below) -->
				<tx:method name="*" />
			</tx:attributes>
		</tx:advice>
	
		<!-- ensure that the above transactional advice runs for any execution of 
			an operation defined by the FooService interface -->
		<aop:config>
			<aop:pointcut id="fooServiceOperation"
				expression="execution(* x.y.service.FooService.*(..))" />
			<aop:advisor advice-ref="txAdvice" pointcut-ref="fooServiceOperation" />
		</aop:config>
	
		<!-- don't forget the DataSource -->
		<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource"
			destroy-method="close">
			<property name="driverClassName" value="oracle.jdbc.driver.OracleDriver" />
			<property name="url" value="jdbc:oracle:thin:@rj-t42:1521:elvis" />
			<property name="username" value="scott" />
			<property name="password" value="tiger" />
		</bean>
	
		<!-- similarly, don't forget the PlatformTransactionManager -->
		<bean id="txManager"
			class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
			<property name="dataSource" ref="dataSource" />
		</bean>
	
		<!-- other <bean/> definitions here -->
	
	</beans>

查看上面的配置，你想要为一个 service 对象实例 `fooService` 添加事务支持。事务语义的添加通过定义 `<tx:advice/>` 来封装。上面配置中 `<tx:advice/>` 的定义表示 “*所有以 `get` 作为前缀的方法将在只读事务中执行，其他所有方法将在默认的事务语义中执行*”。`<tx:advice/>` 的 `transaction-manager` 属性设置为一个 `PlatformTransactionManager` 组件的引用（id 或 name），这里是 `txManager` 组件，用以*驱动*事务。

 > > > **注意**：如果你想注入的 `PlatformTransactionManager` 组件的引用名为 `transactionManager`，那么可以省略事务 advice（`<tx:advice/>`） 的 `transaction-manager` 属性。而如果是  `transactionManager` 以外的其他引用名（译注：比如这里是 `txManager`），你都必须要显示声明 `transaction-manager` 属性，像前面例子中所做的那样。
 
定义 `<aop:config/>` 使 `<tx:advice/>` 定义的事务 advice 在程序里正确的切点（points）执行。首先你定义匹配 `FooService` 接口中方法执行的切点（pointcut）（`fooServiceOperation`），然后通过 advisor 关联切点和 `<tx:advice/>`。这意味着，`fooServiceOperation` 执行时，由 `<tx:advice/>` 定义的 advice 也将会执行。

`<aop:pointcut/>` 元素定义的表达式为 AspectJ 切点表达式；参见[第 9 章 Spring 面向切面编程](aop.html)，查看更多 Spring 切点表达式的细节。

一项常规需求是，是将事务支持加入整个 service 层。最好、最简单的方式是改写切点表达式来匹配所有 service 层的操作。比如：

	<aop:config>
		<aop:pointcut id="fooServiceMethods" expression="execution(* x.y.service.*.*(..))" />
		<aop:advisor advice-ref="txAdvice" pointcut-ref="fooServiceMethods" />
	</aop:config>

 > > > 这个例子中，假设你所有的 service 接口都定义在 `x.y.service` 包下，参见[第 9 章 Spring 面向切面编程](aop.html)，查看更多 Spring 细节。

现在，我们已经分析过了上面的配置，但你可能会问你自己，“额，写好了，但是这些配置到底干了什么啊？”。

上面的配置用于从 `fooService` 组件创建的对象前后创建事务代理。事务代理由事务 advice 配置，当调用代理对象的方法时，就将会开始、挂起，标记为只读事务等等，这些行为取决于关联到方法上的事务配置。下面的程序利用上面的配置运行：

	public final class Boot {
	
		public static void main(final String[] args) throws Exception {
			ApplicationContext ctx = new ClassPathXmlApplicationContext("context.xml", Boot.class);
			FooService fooService = (FooService) ctx.getBean("fooService");
			fooService.insertFoo(new Foo());
		}
	}

运行上面的程序将会产生类似于下面的输出。（为了清晰，截取部分 Log4J 输出及 DefaultFooService 的 insertFoo(..) 方法抛出的 UnsupportedOperationException 异常堆栈）

	<!-- the Spring container is starting up... -->
	[AspectJInvocationContextExposingAdvisorAutoProxyCreator] - Creating implicit proxy for bean fooService with 0 common interceptors and 1 specific interceptors
	
	<!-- the DefaultFooService is actually proxied -->
	[JdkDynamicAopProxy] - Creating JDK dynamic proxy for [x.y.service.DefaultFooService]
	
	<!-- ... the insertFoo(..) method is now being invoked on the proxy -->
	[TransactionInterceptor] - Getting transaction for x.y.service.FooService.insertFoo
	
	<!-- the transactional advice kicks in here... -->
	[DataSourceTransactionManager] - Creating new transaction with name [x.y.service.FooService.insertFoo]
	[DataSourceTransactionManager] - Acquired Connection [org.apache.commons.dbcp.PoolableConnection@a53de4] for JDBC transaction
	
	<!-- the insertFoo(..) method from DefaultFooService throws an exception... -->
	[RuleBasedTransactionAttribute] - Applying rules to determine whether transaction should rollback on java.lang.UnsupportedOperationException
	[TransactionInterceptor] - Invoking rollback for transaction on x.y.service.FooService.insertFoo due to throwable [java.lang.UnsupportedOperationException]
	
	<!-- and the transaction is rolled back (by default, RuntimeException instances cause rollback) -->
	[DataSourceTransactionManager] - Rolling back JDBC transaction on Connection [org.apache.commons.dbcp.PoolableConnection@a53de4]
	[DataSourceTransactionManager] - Releasing JDBC Connection after transaction
	[DataSourceUtils] - Returning JDBC Connection to DataSource
	
	Exception in thread "main" java.lang.UnsupportedOperationException at x.y.service.DefaultFooService.insertFoo(DefaultFooService.java:14)
	<!-- AOP infrastructure stack trace elements removed for clarity -->
	at $Proxy0.insertFoo(Unknown Source)
	at Boot.main(Boot.java:11)

#### 12.5.3 回滚声明式事务

上一小节介绍了如何在你的应用程序，以声明式的形式为类声明事务配置，特别是 service 层的类。这一小节描述你如何以声明式的形式控制事务回滚。

指示 Spring 事务框架工作的推荐方式是通过在当前事务上下文中正在执行的代码中抛出异常（`Exception`） 来回滚事务。由于异常会在调用栈中向上冒泡，Spring 事务框架将会捕获任何未处理（译注：unhandled，没有经过 try {...} catch(...) {...}）的异常（`Exception`），然后决定是否标记事务进行回滚。

默认配置下，Spring 事务框架代码*仅仅*在运行时（runtime）抛出不受检异常时，也就是说，抛出的异常是 `RuntimeException` 的子类实例时，才标记事务回滚。（`Error`s，默认，同样会导致回滚）。而受检异常则默认*不会*导致回滚。

你可以配置指定类型的异常（`Exception`）才会导致回滚，包括受检异常。下面的 XML 片段演示如何为受检的，特定应用的异常（`Exception`）配置回滚。

	<tx:advice id="txAdvice" transaction-manager="txManager">
		<tx:attributes>
			<tx:method name="get*" read-only="true" rollback-for="NoProductInStockException" />
			<tx:method name="*" />
		</tx:attributes>
	</tx:advice>

如果你*不想*事务在异常抛出的时候回滚，可以声明*不会触发回滚的规则*。下面的例子告诉 Spring 事务框架提交相关的事务即使发生了未处理异常 `InstrumentNotFoundException`。

	<tx:advice id="txAdvice">
		<tx:attributes>
			<tx:method name="updateStock" no-rollback-for="InstrumentNotFoundException" />
			<tx:method name="*" />
		</tx:attributes>
	</tx:advice>

当 Spring 事务框架捕获到异常后，查询配置的回滚规则以决定是否触发回滚，*权重最高（strongest）*匹配规则将会获胜（译注：决定是否回滚）。所以在下面的配置示例中，除了 `InstrumentNotFoundException` 之外的所有异常将会回滚方法相关的事务。

	<tx:advice id="txAdvice">
		<tx:attributes>
			<tx:method name="*" rollback-for="Throwable" no-rollback-for="InstrumentNotFoundException" />
		</tx:attributes>
	</tx:advice>

你也可以通过*编程方式*实现一个必要的回滚。尽管很简单，但这种处理是侵入性的，并使你的代码跟 Spring 事务框架紧密耦合：

	public void resolvePosition() {
		try {
			// some business logic...
		} catch (NoProductInStockException ex) {
			// trigger rollback programmatically
			TransactionAspectSupport.currentTransactionStatus()
					.setRollbackOnly();
		}
	}

在所有可能的情况下，强烈建议你使用声明式的编程方式。编程式的回滚只用在你必须使用的时候，但它的使用将破坏程序基于简洁 POJO-架构的实现。