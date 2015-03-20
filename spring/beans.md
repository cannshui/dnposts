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

`org.springframework.context.ApplicationContext` 接口就代表 Spring IoC 容器，并负责实例化，配置和装配前面提到的 beans。容器通过读取配置信息，决定实例化，配置，和装配何种对象。配置元数据有 XML 格式，Java 注解格式，或直接 Java 代码。它允许你组合对象构成你的应用，及组织这些对象间复杂的依赖关系。

`ApplicationContext` 接口的一些实现由 Spring 提供，开箱即用（out-of-the-box）。在独立应用中，通常创建 [`ClassPathXmlApplicationContext`]() 或 [`FileSystemXmlApplicationContext`]() 实例。虽然 XML 是定义配置元数据的传统格式，现在你也可以让配置使容器基于声明式的 Java 注解或代码配置的元数据格式，从而可以减少 XML 配置量。

大多数应用程序场景中，并不需要显式的用户代码去实例化 Spring IoC 容器的一或多个实例。比如，一个 web 应用场景，`web.xml` 文件中 8 行（左右）简单 的 web 模板描述符基本就够了（参见 [5.15.4 小节，“web 应用 ApplicationContext 实例化配置”]()）。如果你正使用 [Spring Tool Suite]() Eclipse 开发环境，这个模板配置可以非常简单的被创建，只需要点击几下鼠标或快捷键。

下图是 Spring 的高层次抽象。你的应用程序类由配置信息组合在一起，当 `ApplicationContext` 创建和初始化后，就可以得到配置完成的可执行的系统或应用。

**5.1 Spring IoC 容器**

![container-magic](container-magic.png)

#### 5.2.1 配置元数据

如上图展示的那样，Spring IoC 容器包含一组*配置数据*；这些配置元数据用于表达你作为应用开发者告诉 Spring 容器如何实例化，配置，及组装你应用中的对象。

配置数据的传统方式是通过简单直观的 XML 格式呈现，这也是本章使用的方式用于讲述 Spring IoC 容器的核心概念和特性。

 > **Note**
 >
 > 基于 XML 的元数据并*不是*唯一允许的配置方式。Spring IoC 容器本身是*完全*跟书写配置数据的方式解耦的。现在，很多开发人员选择 [Java-based 配置方式]() 开发 Spring 应用。

Spring 容器其他方式的配置方法，参见：

 - [基于注解（annotation-based）的配置方式]()：Spring 2.5 引入基于注解的配置方式。
 - [基于 Java 代码（Java-based）的配置方式]()：Spring 3.0 以后，很多 Spring JavaConfig 项目支持的特性变成了 Spring 核心框架的一部分。因此，你可以通过 Java 代码而非 XML 文件定义应用中的 bean。使用这些新特性，参见 `@Configuration`，`@Bean`，`@Import` 和 `@DependsOn` 注解。

Spring configuration consists of at least one and typically more than one bean definition that the container must manage. XML-based 配置数据通过 `<bean/>`（顶级 `<beans/>` 元素里） 元素配置 bean。Java 配置方式一般使用 `@Configuration` 类内的 `@Bean` 注解的方法。

Spring configuration consists of at least one and typically more than one bean definition that the container must manage. XML-based 配置数据通过 `<bean/>`（顶级 `<beans/>` 元素里） 元素配置 bean。Java 配置方式一般使用 `@Configuration` 类内的 `@Bean` 注解的方法。

这些 bean 定义关联到组成你应用的实际的对象。一般，你可以定义 service 层对象，数据存取层对象（DAOs），表现层对象如 Struts `Action` 实例，底层对象如 Hibernate `SessionFactories`，JMS `Queues`，等等。一般，不配置容器中细粒度（fine-grained）的领域对象，因为通常是 DAO 对象和业务逻辑负责创建和加载领域对象。但是，你可以使用 Spring 整合 AspectJ 配置在 IoC 容器外创建的对象。参见[通过 Spring AspectJ 实现依赖注入领域对象]()。

下面的例子展示了基于 XML 配置方式的基本结构：




