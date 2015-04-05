## 69 个 Spring 面试问题和答案

本文是关于 Spring 框架在面试过程中可能被问到的最重要的问题总结。不用担心你的下一次面试，因为 Java Code Geeks 全力为你服务。

你可能被问到的主要问题总结在下面列表中。所有核心模块，从基本 Spring 功能如 Spring Bean，到 [Spring MVC](http://examples.javacodegeeks.com/enterprise-java/spring/mvc/spring-mvc-hello-world-example/) 框架将被呈现和简要描述。在看了这些面试问题之后，如果需要的话，你应该学习我们的 [Spring Tutorial](http://www.javacodegeeks.com/tutorials/java-tutorials/enterprise-java-tutorials/spring-tutorials/)。

那么，开始！

### Spring 概述

#### 1. Spring 是什么？

Spring 是用于 [Java 企业](http://www.javacodegeeks.com/tutorials/java-tutorials/enterprise-java-tutorials/)应用的开源开发框架。Spring 框架的核心特性可以用于开发任何 Java 应用，但是也有其它的扩展来构建 Java EE 平台之上的 web 应用。Spring 框架的目标是使 Java EE 开发变得更加容易，并通过[基于 POJO 编程模型](http://www.javacodegeeks.com/2012/09/how-to-write-better-pojo-services.html)来保证良好的编程实践。

#### 2. Spring 框架带来什么益处？

 - **轻量级（Lightweight）：**Spring 是轻量级的，这个说法来自于它的框架大小和透明度。Spring 框架的基本版本大有是 2MB。
 - **控制反转（Inversion of Control（IoC））：**Spring 通过[控制反转技术](http://www.javacodegeeks.com/2011/08/what-is-dependency-inversion-is-it-ioc.html)实现松耦合。对象只给出它们的依赖关系而不创建和查找依赖对象。
 - **面向切面（Aspect Oriented（AOP））：**[Spring 支持面向切面编程](http://www.javacodegeeks.com/2011/01/aspect-oriented-programming-spring-aop.html)，使应用业务逻辑服务和系统服务相分离。
 - **容器（Container）：**Spring 包含和管理配置的应用对象的声明周期。
 - **MVC 框架（MVC Framework）：**Spring 的 web 框架是一种良好设计的 [web MVC 框架](http://www.javacodegeeks.com/2011/02/spring-mvc-development-tutorial.html)，提供了一种对 web 框架的非常好的替换。
 - **事务管理（Transaction Management）：**Spring 提供了一种一致的事务管理接口，可以 scale down 使用本地事务及 scale up 使用全局事务。
 - **异常处理（Exception Handling）：**Spring 提供一种方便的 API 来翻译特定技术的异常（由 JDBC，Hibernate，或 JDO 抛出）成一致的不受检异常。

#### Spring 框架有哪些模块？

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

这是一个基本 Spring 模块，提供 Spring 框架的基本功能。`BeanFactory` 是任何基于 Spring 的应用的心脏。Spring 框架是建立在这个模块之上的，组成了 Spring 容器。

#### 5. BeanFactory - BeanFactory 实现例子

`BeanFactory` 是工厂模式实现，应用控制反转从实际应用代码中分离配置和依赖。

最常用的 `BeanFactory` 实现是 `XmlBeanFactory` 类。

#### 6. XMLBeanFactory

最有用的是 `org.springframework.beans.factory.xml.XmlBeanFactory`，从 XML 文件中的配置定义装载 bean。这个容器从 XML 文件中读取配置数据，并使用它创建一个完全配置的系统或应用。

#### 7. 解释 AOP 模块

AOP 模块用于为基于 Spring 的应用开发切面。很多支持已经由 AOP 联盟提供了，为了确保 [Spring 和其他 AOP 框架](http://www.javacodegeeks.com/2014/02/applying-aspect-oriented-programming.html)之间的互通性。这个模块也为 Spring 引入了元数据编程。

