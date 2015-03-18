##### <center>5. IoC 容器</center>
##### <center>Part III. 核心技术</center>

----------------------------------------

### 5. IoC 容器

### 5.1 Spring IoC 容器和组件（beans）介绍

本章介绍 Spring 框架对于控制反转（IoC）的实现。IoC 也被称作*依赖注入*。它是定义对象间依赖关系的一个过程，即，对象需要协同其他对象（被注入）完成逻辑处理，对象的注入，只通过构造器参数，工厂方法参数，或调用实例（构造方法构造或工厂方法返回）的 set 方法设置属性。容器会在创建 bean 的时候*注入*依赖关系。这就是反转的基本原理，也就是*控制反转（IoC）*，通过直接使用依赖类的构造器或其他某种机制如 *Service Locator* 模式， 由 bean 自己控制它的依赖类的实例化和位置。

`org.springframework.beans` 和 `org.springframework.context` 包是 Spring 框架 的 IoC 容器的基础。 `BeanFactory` 接口提供了一种高级配置机制可以管理任何类型的对象。 `ApplicationContext` 是 `BeanFactory` 的子接口。它添加了，跟 Spring AOP 特性的简易整合；消息资源处理（国际化时使用），事件发布；应用层特定的 context 实现，如 web 应用中使用 `WebApplicationContext`。

简而言之，`BeanFactory` 提供了配置框架和基本功能，`ApplicationContext` 添加了更多企业级的功能。`ApplicationContext` 是 `BeanFactory` 的一个完整超集，将仅仅在本章使用，用于描述 Spring IoC 容器。更多关于使用 `BeanFactory` 替代 `ApplicationContext` 的信息，参见 [5.16 小节 “BeanFactory”]()。

Spring 中，由 Spring IoC *容器* 管理你应用中的骨架对象，这些对象就称做*组件（bean）*。一个组件就是一个由 Spring IoC 容器实例化，组装，及管理的对象，只是你应用中许多对象里的一个。组件，及它们之间的*依赖关系*，将在*配置元信息*中反应，并由容器使用。

### 5.2 容器概述

`org.springframework.context.ApplicationContext` 接口就代表 Spring IoC 容器，并负责实例化，配置和装配前面提到的 beans。容器通过读取配置信息，决定实例化，配置，和装配何种对象。配置元数据有 XML 格式，Java 注解格式，或直接 Java 代码。它允许你表述对象构成你的应用及这些对象间复杂的依赖关系。
