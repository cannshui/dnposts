## 69 个 Spring 面试问题和答案

本文是关于 Spring 框架在面试过程中可能被问到的最重要的问题总结。

你可能被问到的主要问题总结在下面列表中。所有核心模块，从基本 Spring 功能如 Spring Bean，到 [Spring MVC](http://examples.javacodegeeks.com/enterprise-java/spring/mvc/spring-mvc-hello-world-example/) 框架将被呈现和简要描述。在看了这些面试问题之后，如果需要的话，你应该学习我们的 [Spring Tutorial](http://www.javacodegeeks.com/tutorials/java-tutorials/enterprise-java-tutorials/spring-tutorials/)。

那么，开始！

### Spring 概述

#### 1. Spring 是什么？

Spring 是用于 [Java 企业](http://www.javacodegeeks.com/tutorials/java-tutorials/enterprise-java-tutorials/)应用的开源开发框架。Spring 框架的核心特性可以用于开发任何 Java 应用，但是也有其它的扩展来构建 Java EE 平台之上的 web 应用。Spring 框架的目标是使 Java EE 开发变得更加容易，并通过[基于 POJO 编程模型](http://www.javacodegeeks.com/2012/09/how-to-write-better-pojo-services.html)来保证良好的编程实践。

#### 2. Spring 框架带来什么益处？

 - **轻量级（Lightweight）：**Spring 是轻量级的，这个说法来自于它的框架大小和透明度。Spring 框架的基本版本约 2MB。
 - **控制反转（Inversion of Control（IoC））：**Spring 通过[控制反转技术](http://www.javacodegeeks.com/2011/08/what-is-dependency-inversion-is-it-ioc.html)实现松耦合。对象只给出它们的依赖关系而不创建和查找依赖对象。
 - **面向切面（Aspect Oriented（AOP））：**[Spring 支持面向切面编程](http://www.javacodegeeks.com/2011/01/aspect-oriented-programming-spring-aop.html)，使应用的业务逻辑和系统服务相分离。
 - **容器（Container）：**Spring 包含和管理应用对象的配置和生命周期。
 - **MVC 框架（MVC Framework）：**Spring 的 web 框架是一种良好设计的 [web MVC 框架](http://www.javacodegeeks.com/2011/02/spring-mvc-development-tutorial.html)，提供了 web 框架的绝佳替代方案。
 - **事务管理（Transaction Management）：**Spring 提供了一致的事务管理接口，向下可以缩小到使用本地事务，向上可以扩大到使用全局事务（JTA）。
 - **异常处理（Exception Handling）：**Spring 提供了方便的 API 来转化特定技术的异常（JDBC，Hibernate，或 JDO 抛出）成一致的、不受检异常。

#### 3. Spring 框架有哪些模块？

Spring 框架的基础模块：

 - 核心模块
 - Bean 模块
 - 上下文模块
 - 表达式语言模块
 - [JDBC 模块](http://examples.javacodegeeks.com/enterprise-java/spring/jdbc/spring-jdbctemplate-example/)
 - [ORM 模块](http://examples.javacodegeeks.com/enterprise-java/spring/jpaorm/spring-hibernate-mysql-and-maven-showcase/)
 - OXM 模块
 - JMS 模块
 - 事务模块
 - Web 模块
 - Web-Servlet 模块
 - Web-Struts 模块
 - Web-Porlet 模块

#### 4. 解释核心容器（应用上下文）模块

这是一个基础 Spring 模块，提供 Spring 框架的基本功能。`BeanFactory` 是任何基于 Spring 的应用的心脏。Spring 框架是建立在这个模块之上的，组成了 Spring 容器。

#### 5. BeanFactory - BeanFactory 实现例子

`BeanFactory` 是工厂模式实现，应用控制反转从实际应用代码中分离配置和依赖。

最常用的 `BeanFactory` 实现是 `XmlBeanFactory` 类。

#### 6. XMLBeanFactory

最有用的是 `org.springframework.beans.factory.xml.XmlBeanFactory`，它基于 XML 文件中的配置信息装载 bean。这个容器从 XML 文件中读取配置数据，并创建一个完全配置好的系统或应用。

#### 7. 解释 AOP 模块

AOP 模块用于为 Spring 应用开发切面。很多支持已经由 AOP 联盟提供了，为了确保 [Spring 和其他 AOP 框架](http://www.javacodegeeks.com/2014/02/applying-aspect-oriented-programming.html)之间的互通性。这个模块也为 Spring 引入了元数据编程。

#### 8. 解释 JDBC 抽象和 DAO 模块

[JDBC 抽象和 DAO 模块](https://examples.javacodegeeks.com/enterprise-java/spring/jdbc/spring-jdbctemplate-example/)使得数据库操作更加简洁，并且可以在异常时关闭数据库资源，从而避免出现问题。并在各种品牌数据库的异常之上抽象出了一层更有意义的异常。同时，利用了 Spring AOP 模块为 Spring 应用提供事务支持。

#### 9. 解释 Spring ORM 整合模块

除了直接使用 JDBC 外，Spring 通过 ORM 模块支持 [ORM 工具](https://www.javacodegeeks.com/2011/12/persistence-layer-with-spring-31-and_14.html)。Spring 提供的支持可以整合常见流行的 ORM 框架，包括 [Hibernate](https://www.javacodegeeks.com/2010/05/jboss-42x-spring-3-jpa-hibernate.html)，JDO，和 [iBatis SQL Maps](https://www.javacodegeeks.com/2012/02/mybatis-3-spring-integration-tutorial.html)。Spring 的事务管理支持所有这些 ORM 框架，同样也支持 JDBC。

#### 10. 解释 web 模块

[Spring web 模块](https://examples.javacodegeeks.com/enterprise-java/spring/mvc/spring-mvc-hello-world-example/)构建在 application context 模块之上，提供用于支持 web 应用的 context。这个模块还支持许多面向 web 的特性，如文件上传，请求参数绑定到业务对象。还支持整合 Jakarta Struts 框架。

#### 11. 解释 Spring MVC 模块

MVC 框架用于通过 Spring 构建 web 应用。Spring 可以通过很简单的方式来整合其他 MVC 框架，但是 [Spring MVC 框架](https://www.javacodegeeks.com/2012/09/spring-adding-spring-mvc-part-1.html)是最好的选择，因为通过 IoC 可以非常清晰的将分离控制层的业务逻辑和业务对象进行分离。通过 Spring MVC 还可以声明式的绑定请求参数到业务对象。

#### 12. Spring 配置文件

Spring 配置文件是 XML 文件。文件配置了 class 信息和各 class 之间的相互关系。

#### 13. Spring IoC 容器是什么？

Spring IoC 负责创建对象，管理对象（通过依赖注入），组合对象，配置对象，并管理对象的完整生命周期。

#### 14. IoC 有何益处？

IoC 或 DI 可以极大的减少应用的代码量。同时也更益于测试应用，因为不需要实例化或 JDNI 查找机制。通过最小的要求和最少的侵入性实现松耦合。IoC 容器支持尽早的实例化和服务懒加载。

#### 15. ApplicationContext 有哪些常用实现？

`FileSystemXmlApplicationContext` 容器从 XML 文件加载 bean 配置。需要提供 XML 文件的真实磁盘路径。

`ClassPathXmlApplicationContext` 容器也从 XML 文件加载 bean 配置。你需要正确设置 `CLASSPATH` 属性，然后容器会从 `CLASSPATH` 的 XML 配置中查找和加载 bean。

`ClassPathXmlApplicationContext` 容器从 web 应用下的 XML 文件中查找和加载 bean。

#### 16. BeanFactory 和 ApplicationContext 的区别？

ApplicationContext 提供了一种方式来解析文本信息，一种通用的方式来加载文件资源（如图片），也可以发布事件到注册成监听器的 bean。另外，BeanFactory 容器或 bean 的操作需要以编程方式实现，而 ApplicationContext 中可以声明式实现。ApplicationContext 实现了 `MessageSource` 接口，通过具体的实现，可以获取本地（国际）化信息。

#### 17. Spring 应用的一般表现？

 - 接口定义功能函数/方法。
 - 实现类包含属性，setter/getter 方法，方法等。
 - [Spring AOP](https://examples.javacodegeeks.com/enterprise-java/spring/aop/spring-aop-example/)
 - Spring 配置文件。
 - 客户代码使用接口方法。

### 依赖注入

#### 18. Spring 的依赖注入是什么？

[依赖注入](https://www.javacodegeeks.com/2014/02/dependency-injection-options-for-java.html)，控制反转（IoC）的一个方面（实现），是一个泛化概念，有多种不同的实现方式。你不需要创建你的对象，只需要描述它们应该如何被创建。你不需要通过代码将组件和服务类等组合在一起，只需要在配置文件中进行描述。IoC 容器负责处理这些。

#### 19. IoC 的不同类型？

 - **构造器依赖注入：**容器调用构造器，每个构造器参数代表对一个其他类的依赖。
 - **setter 依赖注入：**容器实例化 bean 后，调用 bean 的无参 setter 方法，或无参工厂方法初始化 bean。

#### 20. 建议哪种依赖注入方式？

构造器依赖注入和 setter 依赖注入都是较为常用的。如果是强制依赖，最好用构造器注入，可选依赖用 setter 注入。

### Spring Beans

#### 21. Spring beans 是什么？

[Spring beans](https://examples.javacodegeeks.com/enterprise-java/spring/beans-spring/spring-3-bean-reference-example/) 是 Java 对象，构成 Spring 应用的骨架。由 Spring IoC 容器实例化，组装，和管理。这些 bean 通过提供配置元数据给容器后，由容器创建，配置如，定义 `<bean/>`。

Spring 框架中的 bean 默认是单例的。通过 bean 标签中的 `singleton` 属性设置，如果设置为 false，将会是 prototype bean。

#### 22. Spring bean 定义包含什么？

Spring bean 定义中包含所有的配置元数据，由此，容器可以知道如何创建 bean，管理 bean 的生命周期细节和它的依赖。

#### 23. 如何提供配置元数据给 Spring 容器？

有三种重要的方式：

 - XML 配置文件。
 - 注解配置。
 - [Java 程序式配置](https://examples.javacodegeeks.com/enterprise-java/spring/beans-spring/spring-3-java-config-example/)。

#### 24. 如何定义 bean 的 scope？

通过 `<bean>` 标记，可以定义 bean 的 scope。可以通过 `scope` 属性定义。如，应用每次都需要 Spring 提供一个新的实例，可以将 bean 的`scope` 属性设置为 `prototype` 实现。另一方面，如果每次都需要的是同一实例，`scope` 属性必须设置为 `singleton`。


#### 25. Spring 中的 bean scope 有哪些？

Spring 框架支持 5 种 scope：

 - **singleton**，每个 Spring IoC 容器中只有一个单实例。
 - **prototype**，一个 bean 定义有许多对象实例。
 - **request**，bean 在 HTTP request 定义。这个 scope 只在 Spring web 应用中有用。
 - **session**，bean 在 HTTP session 定义。这个 scope 只在 Spring web 应用中有用。
 - **global-session**，bean 在 global HTTP session 定义。这个 scope 只在 Spring web 应用中有用。

默认 scope 为 `singleton`。

#### 26. Spring 中的单例 bean 是线程安全的吗？

不是。

#### 27. 解释 Spring 框架中 bean 的生命周期

 - Spring 容器查找 bean 定义并实例化 bean。
 - Spring 填充所有声明的属性。
 - 如果 bean 实现了 `BeanNameAware` 接口，Spring 传递 bean 的 id 给 `setBeanName()` 方法。 
 - 如果 bean 实现了 `BeanFactoryAware` 接口，Spring 传递 `beanFactory` 给 `setBeanFactory()` 方法。
 - 如果 `BeanPostProcessors` 关联到了这个 bean，Spring 回调 `postProcesserBeforeInitialization()` 方法。
 - 如果 bean 实现了 `IntializingBean`，将会调用 `afterPropertySet()` 方法。如果声明了 `init-method` 属性，特定的初始化方法将会被调用。
 - 如果 `BeanPostProcessors` 关联到了这个 bean，Spring 回调 `postProcessAfterInitialization()` 方法。
 - 如果 bean 实现了 `DisposableBean`，销毁时将会调用 `destroy()` 方法。

#### 28. bean 重要的生命周期方法有哪些？可以覆盖吗？

有两个重要的 bean 生命周期方法。第一个是 `setup`，当 bean 加载进容器的时候调用。第二个是 `teardown`，当 bean 卸载的时候调用。

`bean` 标签有两个重要属性 `init-method` 和 `destory-method`，可以定义初始化和销毁方法。相关的注解是 `@PostConstruct` 和 `@PreDestory`。

#### 29. Spring inner bean 是什么？

当一个 bean 只用作为另一个 bean 的属性，它可以被生命为内部 bean。Spring XML 配置中可以在 `<property/>` 或 `<constructor-arg/>` 内使用 `<bean/>` 元素。内部 bean 通常是匿名的，scope 是 prototype（？）。

#### 30. Spring 中如何注入 Java 集合？

Spring 提供如下集合[配置元素](https://examples.javacodegeeks.com/enterprise-java/spring/beans-spring/spring-collections-list-set-map-and-properties-example/)：

 - `<list>` 用于注入一组值，允许重复。
 - `<set>` 用于注入一组非重复值。
 - `<map>` 注入键值对集合，键和值可以是任何类型。
 - `<props>` 注入键值对集合，键和值都必须是 String 类型。

#### 31. 什么是 bean 装配？

装配，或 bean 装配是 Spring 容器组合 bean 的行为。当装配 bean 时，Spring 容器需要知道装配何种 bean，及如何用依赖注入来组合他们。

#### 32. 什么是 bean 自动装配？

Spring 容器支持在协作的 bean 之间[自动装配](http://examples.javacodegeeks.com/enterprise-java/spring/beans-spring/spring-autowire-example/)。这意味着，Spring 可以从 `BeanFactory` 为 bean 查找和关联协作的 bean，不需要在 `<constructor-arg>` 和 `<property>` 元素中指定

#### 33. 自动装配模式间的区别？

自动注入功能有 5 种模式，可以用于指示 Spring 容器自动注入：

 - **no：**默认设置。通过显式的声明引用进行装配。
 - **byName：**Spring 以 bean 属性名去查找相应的 bean，进行装配。
 - **byType：**Spring 以 bean 属性的类型去查找相应的 bean，进行装配。如果存在多个候选 bean，将会抛出异常。
 - **constructor：**类似于 `byType`，但以构造器参数的类型为查找依据。如果存在多个候选 bean，将会抛出异常。
 - **autodectect：**Spring 首先尝试 `constructor` 模式，如果失败，再尝试 `byType`。

#### 34. 自动装配的限制？

限制如下：

 - **覆盖：**，声明了自动装配后，仍可以通过 `<constructor-arg>` 和 `<property>` 元素设置覆盖掉自动装配的设置。
 - **简单类型：**无法自动注入简单类型、String 和 Class。
 - **模糊性：**自动装配对比显式的生命太不直接，如果可能，尽量选择显式的装配。

#### 35. 可以注入 null 和空字符串吗？

可以。

### Spring 注解

#### 36. Spring Java-Based 配置是什么？列举一些注解示例。

[Java-Based 配置](http://www.javacodegeeks.com/2013/04/spring-java-configuration.html) 可以通过一系列的 Java 注解脱离 Spring XML 配置文件。

`@Configuration` 注解说明类被 Spring 容器用作 bean 定义源（类似于一个 XML 文件）。`@Bean` 注解在方法上，说明方法的返回将被注册为 Spring 应用中的 bean。

#### 37. 什么是基于注解的容器配置？

替代 XML 设置中的元素声明，通过字节码级别的配置来装配组件。替代用 XML 描述 bean 装配，开发者将配置信息通过注解声明在相关的类、方法、或字段放在组件类中。

#### 38. 如何启用注解装配？

Spring 容器默认不启用注解装配。为了使用注解装配，必须在配置文件中那个配置 `<context:annotation-config/>` 元素。

#### 39. @Required 注解

这个注解表示相关的 bean 属性必须在配置时设置，通过显式的属性值或自动装配。如果没有设置，将抛出 `BeanInitializationException` 异常。

#### 40. @Autowired 注解

`@Autowired` 注解为 bean 在何时、何地进行自动装配提供了更细粒度的控制。它可以跟 `@Required` 一样应用于 setter 方法、构造器、属性或任意名称和参数的 PN 方法（？）来自动装配 bean。

#### 41. @Qualifier 注解

当某类型有不止一个 bean 的实例时，并且只能有一个实例装配到属性时应用。`@Qualifier` 注解同 `@Autowired` 一起通过显式声明来消除装配时的歧义。

### Spring 数据存取

#### 42. Spring 框架中更高效的 JDBC 使用方式？

使用 Spring JDBC 框架资源管理和错误处理的负担将大大减少。开发者只需要编写具体的语句从数据库存取数据。JDBC 可以通过 Spring 提供的模板类 [`JdbcTemplate`](http://examples.javacodegeeks.com/enterprise-java/spring/jdbc/spring-jdbctemplate-example/) 来更加高效的使用。

#### 43. JdbcTemplate

`JdbcTemplate` 提供许多方便的方法来完成业务功能，如转化数据库数据到基础类型或对象，执行预处理 SQL 语句，及提供定制的数据库错误处理。

#### 44. Spring DAO 支持

[Spring DAO 支持](http://www.javacodegeeks.com/2012/09/spring-dao-and-service-layer.html)旨在更加简便的以一致的方式使用数据存取技术如 JDBC，Hibernate，或 JDO。这允许我们可以在持久化技术之间进行切换，而不必担心捕获每种技术特定的异常。

#### 45. Spring 应用中如何访问 Hibernate？

两种方式：

 - 控制反转，交给 Hibernate 模板和回调。
 - 继承 `HibernateDAOSupport`，应用 AOP 拦截器模式。

#### 46. ORM 框架的 Spring 支持

Spring 支持整合如下 ORM：

 - Hibernate
 - iBatis
 - JPA（Java Persistence API）
 - TopLink
 - JDO（Java Data Objects）
 - OJB

#### 47. 如何通过 HibernateDaoSupport 整合 Spring 和 Hibernate？

使用 Spring 的 `SessionFactory`，具体为 `LocalSessionFactory`。整合过程有三步：

 - 配置 Hibernate SessionFactory。
 - 继承 `HibernateDaoSupport` 实现 DAO。
 - 装配 AOP 事务支持。

#### 48. Spring 支持的事务管理

Spring 支持两种事务管理方式：

 - **程序式事务管理：**直接通过编程管理相关的事务。非常灵活，但是难以管理。
 - **声明式事务管理：**[分离事务管理和你的业务代码](https://www.javacodegeeks.com/2011/09/spring-declarative-transactions-example.html)。可以通过注解或 XML 配置管理事务。

#### 49. Spring 的事务管理有何益处？

 - 提供一致的编程模型，可以跨不同的事务 API 如 JTA，JDBC，Hibernate，JPA，和 JDO。
 - 为程序式事务管理提供更加简单易于使用的 API，相比于复杂的事务 API 如 JTA。
 - 支持声明式事务管理。
 - 与 Spring 各种数据存取抽象完美整合。

#### 50. 更倾向于何种事务管理方式？

绝大多数的 Spring 用户选择声明式事务管理，因为可以最小限度的侵入应用代码，因此最符合非侵入性轻型容器的思想。声明式事务管理优于程序式事务管理，尽管它缺少灵活性。

### Spring AOP 编程

#### 51. 解释 AOP？

[面向切面编程](https://www.javacodegeeks.com/2014/02/applying-aspect-oriented-programming.html)是一种变成技术允许程序模块化横向的关注点，或典型的责任分离，如日志和事务管理。

#### 52. Aspect

AOP 的核心就是切面，包括应用于大多数类的可重用模块。它是一个有一组 API 的模块描述跨领域的需求。如，日志模块可以称为日志 AOP 切面。一个应用可以有多个切面需求。Spring AOP 中，切面由普通的 Java 类实现，只需要 `@Aspect` 注解即可（`@AspectJ` 风格）。 

#### 53. Spring AOP 中关注点和横切关注点的区别？

关注点是我们的应用希望具有的功能模块，可能定义成我们需要实现的功能方法。

横切关注点是适用于整个应用级别的功能点，它会影响整个应用程序。如，日志，[安全](https://www.javacodegeeks.com/2013/04/spring-aop-in-security-controlling-creation-of-ui-components-via-aspects.html)和数据传输是几乎每个应用都需要关注的店，因此它们是横切关关注点。

#### 54. Join point

连接点表示应用中可以插入 AOP 切面的地方。它是 Spring AOP 实际发生作用的地方。

#### 55. Advice

advice 是在目标方法执行前后实际执行的行为。实际上是 Spring AOP 框架在程序执行前后调用的一段代码。

Spring 切面支持 5 中 adivce：

 - **before：**在目标方法执行前运行 adivce。
 - **after：**无论目标方法执行结果如何，在方法执行后运行 advice。
 - **after-returning：**只在目标方法成功执行后，才运行 advice。
 - **after-throwing：**只在目标方法执行过程中抛出异常后，才运行 advice。
 - **around：**在目标方法执行前后都运行 advice。

#### 56. Pointcut

切点是一组连接点的集合，表示 advice 应该作用的地方。可以通过表达式或正则式来声明切入点。

#### 57. 引入点（Introduction）是什么？

给已存在的类添加新方法或属性的一种方式。

#### 58. 目标对象是什么意思？

目标对象指代可以被一或多个切面作用的对象。它会成为代理对象。也指 adivsed 对象。


#### 59. 代理是什么意思？

代理指应用了 adivce 到目标对象后创建的对象。作为客户端代码使用时，可以单纯的认为目标对象和代理对象是一个意思。

#### 60. 自动代理有哪些不同的类型？

 - BeanNameAutoProxyCreator
 - DefaultAdvisorAutoProxyCreator
 - Metadata autoproxying

#### 61. 织入是什么意思？织入可以作用在哪些点？

织入是链接切面到其他类型或对象后创建 advised 对象的过程。

织入可以在编译时、装载时和运行时完成。

#### 62. 解释基于 XML 的切面实现

这种实现场景中，切面通过普通类实现，并在 XML 文件中配置。

#### 63. 解释基于注解的（@AspectJ）切面实现

基于注解的（@AspectJ）切面实现在普通 Java 类的基础上加入特性切面注解类。

### Spring MVC

#### 64. Spring MVC 框架是什么？

Spring 中有一个[全功能的 MVC 框架用于构建 web 应用](http://examples.javacodegeeks.com/enterprise-java/spring/mvc/spring-mvc-hello-world-example/)。尽管 Spring 可以很方便的整合其他 MVC 框架，如 Struts，Spring 的 MVC 框架通过 IoC 提供更加清晰的控制逻辑和业务对象的分离。它也允许声明式的绑定请求参数到业务对象。

#### 65. DispatcherServlet

Spring MVC 框架围绕 `DispatcherServlet` 进行设计，处理所有的 HTTP 请求。

#### 66. WebApplicationContext

`WebApplicationContext` 是 `ApplicationContext` 的一个扩展，它有一些 web 应用所特定的特性。跟普通的 `ApplicationContext` 不同，它可以解析主题，并知道自己是关联到哪个 servlet 上。

#### 67. Spring MVC 框架中的 Controller 是什么？

控制器使得应用可以访问在 service 中实现的功能。解释用户输入并转化成模型对象，并将视图呈现给用户。Spring 以非常抽象的方式实现了控制器，从而你可以创建各式具体的控制器。

#### 68. @Controller 注解

@Controller 注解指示一个特定的类作为控制器的角色。Spring 并不要求你继承具体的控制器基类或引用 servlet API。

#### 69. @RequestMapping  注解

@RequestMapping 注解用于映射 URL 到整个类或一个特定处理器方法。

 - [全部 Spring 教程](https://www.javacodegeeks.com/tutorials/java-tutorials/enterprise-java-tutorials/spring-tutorials)。
 - [示例专用小节](https://examples.javacodegeeks.com/category/enterprise-java/spring/)。

 > **原文：**[69 Spring Interview Questions and Answers](https://www.javacodegeeks.com/2014/05/spring-interview-questions-and-answers.html)