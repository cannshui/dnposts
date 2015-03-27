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

	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xsi:schemaLocation="http://www.springframework.org/schema/beans
	        http://www.springframework.org/schema/beans/spring-beans.xsd">
	
	    <bean id="..." class="...">
	        <!-- collaborators and configuration for this bean go here -->
	    </bean>
	
	    <bean id="..." class="...">
	        <!-- collaborators and configuration for this bean go here -->
	    </bean>
	
	    <!-- more bean definitions go here -->
	
	</beans>

`id` 属性是用于唯一标识 bean 定义的一个字符串。`class` 属性定义 bean 的类型，需要使用全类名。通过 id 值可以引用其他的协作对象。XML 中配置引用协作对象的方式没有在这个例子中展示；参见[依赖]()查看更多信息。

#### 5.2.2 实例化一个容器

实例化一个 Spring IoC 容器很方便。通过将配置资源的路径（可以同时有多个）提供给 `ApplicationContext` 构造器，容器即可装载配置数据，配置资源的路径有多种选择，如本地文件系统，Java `CLASSPATH`，等等。

	ApplicationContext context =
   		new ClassPathXmlApplicationContext(new String[] {"services.xml", "daos.xml"});

 > **Note**
 >
 > 在你了解 Spring 的 IoC 容器后，你可能想知道更多关于 Spring `Resource` 抽象的信息，参见[第 6 章，资源]()，`Resource` 提供了一种方便的机制来从不同 URI 语法表示的位置读入InputStream。特别地，`Resource` 路径被用于构造应用上下文，参见[6.7 小节，“应用上下文和资源路径”]。

下面的例子展示了 service 层对象`（services.xml）`配置文件：

	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xsi:schemaLocation="http://www.springframework.org/schema/beans
	        http://www.springframework.org/schema/beans/spring-beans.xsd">
	
	    <!-- services -->
	
	    <bean id="petStore" class="org.springframework.samples.jpetstore.services.PetStoreServiceImpl">
	        <property name="accountDao" ref="accountDao"/>
	        <property name="itemDao" ref="itemDao"/>
	        <!-- additional collaborators and configuration for this bean go here -->
	    </bean>
	
	    <!-- more bean definitions for services go here -->
	
	</beans>

下面的例子展示了数据存取对象 `daos.xml` 文件：

	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xsi:schemaLocation="http://www.springframework.org/schema/beans
	        http://www.springframework.org/schema/beans/spring-beans.xsd">
	
	    <bean id="accountDao"
	        class="org.springframework.samples.jpetstore.dao.jpa.JpaAccountDao">
	        <!-- additional collaborators and configuration for this bean go here -->
	    </bean>
	
	    <bean id="itemDao" class="org.springframework.samples.jpetstore.dao.jpa.JpaItemDao">
	        <!-- additional collaborators and configuration for this bean go here -->
	    </bean>
	
	    <!-- more bean definitions for data access objects go here -->
	
	</beans>

上面的例子中，service 层由 `PetStoreServiceImpl` 对象，及两个 DAO 对象 `JpaAccountDao` 和 JpaItemDao`（基于 JPA 对象/关系映射标准）构成。`property name` 元素指向 JavaBean 的某个属性名，`ref` 元素引用另外一个 bean 的定义。`id` 和 `ref` 元素的关联描述了协作对象间的依赖关系。更多关于配置对象间依赖关系的细节，参见[依赖]()。

##### Composing 组合基于 XML 的配置数据

将 bean 的定义分散到多个 XML 文件中是相当有用的。一般，每个独立的 XML 配置文件代表你应用架构中的一个逻辑层次。

你可以使用应用上下文构造器（application context）从配置文件 XML 片段中装载 bean 定义。这个构造器可以有多个 `Resource` 位置，像前面小节中显示的那样。可选地，通过使用一或多个 `<import/>` 元素从其他单个或多个文件装载 bean 定义。比如：

	<beans>
		<import resource="services.xml"/>
		<import resource="resources/messageSource.xml"/>
		<import resource="/resources/themeSource.xml"/>

		<bean id="bean1" class="..."/>
		<bean id="bean2" class="..."/>
	</beans>

上面的例子中，外部的 bean 定义从 3 个文件中装载：`services.xml`，`messageSource.xml` 和 `themeSource.xml`。所有的被导入文件路径是相对于这个导入文件的，所以，`services.xml` 必须和导入文件在同一个目录中或是 classpath 中，`messageSource.xml` 和 `themeSource.xml` 必须在 `resources` 目录下。如你所见，前置“/”是会被忽略的，但是考虑到所给路径都是作为相对路径处理的，所以最好不去使用“/”。被导入的文件，包括顶级的 `<beans/>` 元素，必须是经过 Spring Schema 验证的 XML bean 定义。

 > **Note**
 >
 > 虽然可以，但是不推荐通过相对路径 “../” 引用父级目录中的文件。这样做的话，将会依赖于当前应用之外的配置文件。（译注：ERROR?）特别地，这种引用也不推荐在“classpath:”路径中使用（如，“classpath:../services.xml”），因为，运行时查找配置文件的方式是先在选择“最近的” classpath 下查找，然后才去它的父级目录中查找。classpath 改变的话可能导致选择了不同的，错误的目录。
 >
 > 你可以总是使用完整的资源路径替代相对路径：比如，“file:C:/config/services.xml”或“classpath:/config/services.xml”。然而，注意，此时你会将你的应用配置耦合到特定的绝对路径。通常，推荐为绝对路径维护一个非直接（indirection）字面值，如，通过设置“${...}”占位符，让 JVM 在运行时解析系统属性。

#### 5.2.3 使用容器

`ApplicationContext` 是增强的工厂接口，用于管理不同 bean 和它们的依赖的注册行为。通过方法 `T getBean(String name, Class<T> requiredType)`，你可以取到你的 bean 实例。

`ApplicationContext` 可以使你读入 bean 定义及取到它们，如：

	// create and configure beans
	// 创建和配置所有 bean
	ApplicationContext context =
		new ClassPathXmlApplicationContext(new String[] {"services.xml", "daos.xml"});

	// retrieve configured instance
	// 取到已配置的实例
	PetStoreService service = context.getBean("petStore", PetStoreService.class);

	// use configured instance
	// 使用实例
	List<String> userList = service.getUsernameList();

你使用 `getBean()` 来取到你 bean 的实例。`ApplicationContext` 还有一些其他方法用于获取 bean，但理想情况下，你的应用程序代码应该从不使用它们。事实上，你的应用程序代码应该不去调用 `getBean()` 方法，甚至不应该依赖于任何 Spring API。 比如，Spring 跟 web 框架的整合为多种 web 框架类提供了依赖注入，像控制器层和 JSF 管理的 bean。

### 5.3 bean 概述

一个 Spring IoC 容器管理着一个或多个 *beans*。这些 bean 通过提供给容器的配置数据创建，比如，以 XML `<bean/>` 形式定义。

在容器内部，这些 bean 定义被表示成 `BeanDefinition` 对象，它包括（除了其他信息之外）如下元数据：

 - *包含全包名的类名：*一般是定义的 bean 的真正实现类。
 - bean 表现配置元素，描述 bean 在容器内是如何表现的（领域（scope），lifecycle callback（生命周期内回调），等等）。
 - 引用的其他 bean，需要被引用的 bean 用于执行自己的工作；这些引用也被叫做*协作对象*或*依赖对象*。
 - 其他配置选项用于创建对象时使用，比如，管理一个连接池的连接数量，或池的大小限制。

这些元数据转换成一组属性设置，用于组成每个 bean 定义。

**表 5.1. bean 定义**

<table>
  <tr><th>属性</th><th>解释参见</th></tr>
  <tr><th>类</th><th>5.3.2，“实例化 bean”</th></tr>
  <tr><th>名称</th><th>5.3.1，“命名 bean”</th></tr>
  <tr><th>作用域</th><th>5.5，“bean 作用域”</th></tr>
  <tr><th>构造器参数</th><th>5.4.1，“依赖注入”</th></tr>
  <tr><th>属性</th><th>5.4.1，“依赖注入”</th></tr>
  <tr><th>注入模式</th><th>5.4.5，“注入协作对象”</th></tr>
  <tr><th>延迟-实例化模式</th><th>5.4.4，“延迟-实例化组件”</th></tr>
  <tr><th>初始化方法</th><th>“初始化操作回调方法”</th></tr>
  <tr><th>销毁方法</th><th>“销毁操作回调方法”</th></tr>
</table>

除了通过 bean 定义包含如何创建一个特定 bean 之外，`ApplicationContext` 实现也允许注册容器外用户自己创建的对象。这是通过 ApplicationContext 的 BeanFactory `getBeanFactory()` 方法实现的，`getBeanFactory()` 方法将会返回 BeanFactory 实现 `DefaultListableBeanFactory`。`DefaultListableBeanFactory` 通过 `registerSingleton(..)` 和 `registerBeanDefinition(..)` 方法支持这种注册行为。然而，典型的 application 工作模式是仅使用 bean 元数据定义。

#### 5.3.1 命名 bean

每个 bean 有一或多个定义。这些定义必须是唯一的，用于容器持有这些 bean。一个 bean 通常只有一个定义，但如果它需要一个以上，那么额外的定义可以考虑通过别名实现。

基于 XML 的配置元数据，你可以使用 `id` 及（或）`name` 属性指定 bean 定义。`id` 属性允许你指定一个唯一存在的 bean id。一般，这些名称是字母或数字（*myBean*，*fooService*，等。），但也可以包含特殊字符。如果你想为这个 bean 引入其他别名，那么你也可以通过 `name` 属性指定它们（译注：一组别名），由逗号（`,`），分号（`;`），或空白符间隔。作为一个历史注意点，Spring 3.1 以前的版本，`id` 属性被定义成 `xsd:ID` 类型，约束了所允许的字符。3.1 后，它定义成了 `xsd:string` 类型。注意，bean `id` 的唯一性仍由容器强制约束，不再由 XML 解析器约束。

你并不必须为 bean 提供一个 name 或 id。如果没有显式提供 name 或 id，容器将为 bean 生成一个唯一 name。然而，如果你想通过 name 引用其他 bean，比如 `ref` 元素或 [Service Locator]() 样式的查找，你就必须提供一个 name。如果不想提供 name，参见[内部 bean]()和[自动注入协作对象]()。

 > **bean 名称约定**
 >
 > 当命名 bean 的时候，约定使用标准的 Java 实例字段名称约定。即，bean 名称以小写字母开始，然后是驼峰表示法。这种名称的示例比如（不包含引号）`accountManager`，`accountService`，`userDao`，`loginController`，等等。
 >
 > 一致的 bean 名称约定可以使你的配置更易阅读和理解，而且，如果你使用 Spring AOP 的话，将会很方便的应用 advice 到一组由名称相关联的 bean 上。

##### 在 bean 定义之外为其设置别名

在 bean 定义本身内，你就可以为其提供不止一个名称，通过使用唯一的 name（由 `id` 属性），及任何 `name` 属性中的 name 值。这些 name 等同于别名对应同一个 bean，而且某些场景下很有用，比如，允许应用中的每个组件通过自己的名称指向一个通用依赖。（译注：ERROR!）

然而，只在一处声明所有的别名并不是总是适当的。有时，为 bean 在某处引入一个别名还是很需要的。这通常是这样的场景，一个大系统，配置被分散到子系统中，每个子系统又有自己的对象定义。基于 XML 的配置方式中，你可以使用 `<alias/>` 元素设置别名。

	<alias name="fromName" alias="toName"/>

这个例子中，容器中的一个名称为 `fromName` 的 bean，通过这样设置别名之后，可以通过 `toName` 指向它。

比如，子系统 A 的配置数据可能通过 `subsystemA-dataSource` 指向一个 DataSource。子系统 B 可能通过 `systemB-dataSource` 指向一个 DataSource`。当组装成同时使用这些子系统的主应用的时候，通过 `myApp-dataSource` 指向 DataSource。为了使这 3 个名称指向同一个对象，添加如下别名定义到 MyApp 配置数据：

	<alias name="subsystemA-dataSource" alias="subsystemB-dataSource"/>
	<alias name="subsystemA-dataSource" alias="myApp-dataSource" />

现在每个组件和主应用都可以通过名称指向 dataSource，name 必须是唯一的，并保证不与其他 bean 定义冲突（比较有效地方式是创建一个命名空间），它们（译注：bean 所有的名称和别名）现在指向同一个 bean。

 >**Java 配置方式**
 >
 > 如果你正使用基于 Java 代码的配置，`@Bean` 注解可以用于提供别名（可多个），细节参见 5.12.3 小节，“使用 @Bean 注解”。

#### 5.3.2 实例化 bean

一个 bean 定义是创建一个或多个对象的菜谱。当有请求时，容器从菜谱中查找到指定名称的 bean，并通过 bean 定义封装的配置数据创建（或获取）一个实际的对象。

如果你使用基于 XML 的配置数据，你需要在 `<bean/>` 的 `class` 属性中声明要被实例化的对象类型（或类）。`class` 属性，对应的是 `BeanDefinition` 实例的 `Class` 属性，通常是强制必设的。（对于异常，参见[“通过实例工厂方法实例化”小节]()及[5.7 小节，“Bean 定义继承”]()。）你通过两种方式中的一种使用 `Class` 属性：

 - 典型的，指明要被构造的 bean 类型，容器直接直接通过反射调用类构造器来创建 bean，某种程度上等同于 Java 代码中的 `new` 操作符。
 - 指明某个类的 `static` 工厂方法被调用创建对象，容器调用一个类的静态工厂方法来创建对象，一般不是常见的情况。调用 `static` 工厂方法的返回对象类型可能是同一种类型或完全不同的类型。

 >**内部类名称。**如果你想为一个内部 `static` 类配置 bean 定义，你必须使用内部类的*二进制*名称。
 >
 >比如，你有一个类 `Foo` 在 `com.example` 包下，`Foo` 类有一个 `static` 内部类叫做 `Bar`，那么一个 bean 定义的 `class` 属性设置是：
 >
 >`com.example.Foo$Bar`
 >
 >注意使用字符 `$` 分开内部类名和外部类名。

##### 通过构造器实例化

当你通过构造器形式创建 bean 的时候，所有的普通类都是 Spring 可用和兼容的。即，开发的类不需要实现特定接口或按照指定形式编码。简单声明 bean 的类型就足够了。然而，依赖于特定管理 bean 的 IoC 容器类型，你可能需要提供一个默认（空）构造器。

Spring IoC 容器可以管理你想被管理的实际上的*任何类*；并不限制到只管理实际的 JavaBean。大多数 Spring 用户倾向选择实际的 JavaBean，提供一个默认（无参数）的构造器和适当的属性 setter 和 getter 方法。你的容器中也可以有一些奇特的非传统 bean 规范的类。如果，比如，你需要使用传统的链接池，它肯定不遵循 JavaBean 规范，Spring 同样可以管理它。

基于 XML 的配置方式，你可以这样声明你的 bean 类型，如下：

	<bean id="exampleBean" class="examples.ExampleBean"/>

	<bean name="anotherExample" class="examples.ExampleBeanTwo"/>

关于提供参数给构造器（如果需要）和对象构造之后设置对象实例属性，参见[注入依赖]()。

##### 通过静态工厂方法实例化

当定义一个从静态工厂方法创建的 bean 时，你使用 `class` 属性声明包含 `static` 工厂方法的类，`factory-method` 属性声明工厂方法的名称。你应该可以调用这个方法（可选参数后续描述）并返回一个实际对象，这个对象就像是从构造器创建一样。这样的 bean 定义的一个用途就是实现传统代码调用 `static` 工厂方法。

下面的 bean 定义声明这个 bean 将会通过调用工厂方法（factory-method）创建。定义没有声明返回对象的类型（类），只有包含工厂方法的类。这个例子中，`createInstane()` 方法必须是*静态*方法。

	<bean id="clientService"
		class="examples.ClientService"
		factory-method="createInstance"/>

	public class ClientService {
		private static ClientService clientService = new ClientService();
	
		private ClientService() {
		}
	
		public static ClientService createInstance() {
			return clientService;
		}
	}

关于提供（可选）参数给工厂方法和为返回对象设置对象实例属性，参见[依赖和配置细节]()。

##### 通过实例工厂方法实例化

跟通过[静态工厂方法]()实例化类型，实例工厂方法实例化是调用容器中一个已存在 bean 的非静态方法创建对象。使用这种机制，`class` 属性设置为空，`factory-bean` 属性声明当前（或父/祖先）容器内 bean 的名称，这个 bean 即包含创建对象的实例方法。仍在 `factory-method` 中设置工厂方法的名称。

	<!-- the factory bean, which contains a method called createInstance() -->
	<bean id="serviceLocator" class="examples.DefaultServiceLocator">
		<!-- inject any dependencies required by this locator bean -->
	</bean>

	<!-- the bean to be created via the factory bean -->
	<bean id="clientService" factory-bean="serviceLocator"
		factory-method="createClientServiceInstance" />

DefaultServiceLocator 类（译注：译者添加。）：

	public class DefaultServiceLocator {
	
		private static ClientService clientService = new ClientServiceImpl();
	
		private DefaultServiceLocator() {
		}
	
		public ClientService createClientServiceInstance() {
			return clientService;
		}
	}

一个工厂类可以包含不止一个工厂方法，如下所示：

	<bean id="serviceLocator" class="examples.DefaultServiceLocator">
		<!-- inject any dependencies required by this locator bean -->
	</bean>

	<bean id="clientService"
		factory-bean="serviceLocator"
		factory-method="createClientServiceInstance" />

	<bean id="accountService"
		factory-bean="serviceLocator"
		factory-method="createAccountServiceInstance" />

新 DefaultServiceLocator 类（译注：译者添加。）：

	public class DefaultServiceLocator {
	
		private static ClientService clientService = new ClientServiceImpl();
		private static AccountService accountService = new AccountServiceImpl();
	
		private DefaultServiceLocator() {
		}
	
		public ClientService createClientServiceInstance() {
			return clientService;
		}
	
		public AccountService createAccountServiceInstance() {
			return accountService;
		}
	
	}

上面的形式显示了工厂 bean 本身可以通过依赖注入（DI）管理和配置。参见[依赖和配置细节]()。

 > **Note**
 >
 > Spring 文档中，工厂 bean 指这样的 bean，Spring 容器中配置 创建对象 通过一个[实例]()或[静态]()工厂方法。相反，`FactoryBean`（注意大写）指 Spring 特定的 `FactoryBean`。

### 5.4 依赖

一个典型的企业级应用不会只包含一个简单对象（或 bean，按照 Spirng 的说法）。即使是最简单的应用也有一组相互协作的对象，最终用户看到的是一个连贯的应用。这一节解释了如何定义一组 bean，这组 bean 实现一个全功能的应用程序，应用程序中对象协作在一起达成一个目标。

#### 5.4.1 依赖注入

*依赖注入*（DI）是定义对象间依赖关系的一个过程，即，对象需要协同其他对象（被注入）完成逻辑处理，对象的注入，只通过构造器参数，工厂方法参数，或调用实例（构造方法构造或工厂方法返回）的 set 方法设置属性。然而，容器会在创建 bean 的时候*注入*依赖关系。这就是反转的基本原理，也就是*控制反转（IoC）*，通过直接使用依赖类的构造器或其他某种机制如 *Service Locator* 模式，由 bean 自己控制它的依赖类的实例化和位置。

基于 DI 原则的代码很干净，而且当通过依赖提供对象时更利于解耦。对象并不查找它自己的依赖，也不知道依赖的位置或类型。这样，你的类将会更易于测试，特别是当你依赖的是借口或抽象基类时，因为这将允许在单元测试中使用模拟实现。

DI 存在两个主要变种，[基于构造器的依赖注入]() 和 [基于 setter 方法的依赖注入]()。

##### 基于构造器的依赖注入

*基于构造器的*的 DI 实现是通过容器调用构造器，并传入一组参数，每个参数表示一个依赖。调用一个 `static` 工厂方法，并传入指定的参数来构建 bean 基本上是类似的，这里的讨论对待构造器的参数和 `static` 工厂方法的参数也是类似的。下面的例子展示了一个只能通过构造器注入实现依赖注入的类。注意，这个类并没有*特殊*之处，它是一个 POJO，不包含对任何容器特定的接口、基本类或注解的依赖。

	public class SimpleMovieLister {

		// the SimpleMovieLister has a dependency on a MovieFinder
		// SimpleMovieLister 依赖于一个 MovieFinder
		private MovieFinder movieFinder;

		// a constructor so that the Spring container can inject a MovieFinder
		// 一个构造器用于 Spring 容器注入一个 MovieFinder
		public SimpleMovieLister(MovieFinder movieFinder) {
			this.movieFinder = movieFinder;
		}

		// business logic that actually uses the injected MovieFinder is omitted...
		// 忽略实际使用注入的 MovieFinder 进行逻辑处理

	}

##### 构造器参数匹配

构造器参数匹配基于参数的类型。如果没有潜在的歧义存在于一个 bean 定义的构造器参数，那么在 bean 创建的时候，bean 定义中的构造器参数顺序就是那些参数提供给适当构造器的顺序。考虑下面的类：

	package x.y;

	public class Foo {

		public Foo(Bar bar, Baz baz) {
			// ...
		}

	}

上例没有任何的歧义存在，此处假设 `Bar` 和 `Baz` 类没相关的继承关系。因而，下面的配置将会很好的工作，而且你不需要在 `<constructor-arg/>` 元素中显式的声明构造器参数索引顺序及（或）类型。

	<beans>
		<bean id="foo" class="x.y.Foo">
			<constructor-arg ref="bar"/>
			<constructor-arg ref="baz"/>
		</bean>

		<bean id="bar" class="x.y.Bar"/>

		<bean id="baz" class="x.y.Baz"/>
	</beans>

当另外的 bean 被引用时，类型是可知的，然后可以进行匹配（就像前面的例子）。当使用了一个简单类型，比如 `<value>true</value>`，Spring 无法推断值的类型，所以无法只通过类型匹配。考虑下面的类：

	package examples;

	public class ExampleBean {

		// Number of years to calculate the Ultimate Answer
		private int years;

		// The Answer to Life, the Universe, and Everything
		private String ultimateAnswer;

		public ExampleBean(int years, String ultimateAnswer) {
			this.years = years;
			this.ultimateAnswer = ultimateAnswer;
		}

	}

上面的场景中，容器*可以*使用类型匹配，如果你通过使用 `type` 属性显式地声明了构造器参数的类型。比如：

	<bean id="exampleBean" class="examples.ExampleBean">
		<constructor-arg type="int" value="7500000"/>
		<constructor-arg type="java.lang.String" value="42"/>
	</bean>

使用 `index` 属性显式的声明构造器参数的索引顺序。比如：

	<bean id="exampleBean" class="examples.ExampleBean">
		<constructor-arg index="0" value="7500000"/>
		<constructor-arg index="1" value="42"/>
	</bean>

为了解决多个简单值的歧义，当一个构造器有两个同类型的参数则就需要声明一个索引顺序解决歧义。注意，*索引顺序从 0 计数*。

你也可以使用构造器参数名称为参数值消除歧义：

	<bean id="exampleBean" class="examples.ExampleBean">
		<constructor-arg name="years" value="7500000"/>
		<constructor-arg name="ultimateAnswer" value="42"/>
	</bean>

注意，要使上述 `name` 属性的设置有效，编译时必须带上 debug 标记，这样 Spring 才可以从构造器中查找参数名称。如果，你无法在编译你的代码时带上 debug 标记（或不想），你可以使用 [@ConstructorProperties]() JDK 注解来显式地为构造器参数设置名称。样例类看起来如下：

	package examples;

	public class ExampleBean {

		// Fields omitted

		@ConstructorProperties({"years", "ultimateAnswer"})
		public ExampleBean(int years, String ultimateAnswer) {
			this.years = years;
			this.ultimateAnswer = ultimateAnswer;
		}

	}

##### 基于 setter 方法的依赖注入

*基于 setter* 的依赖注入由容器调用你的 bean 的 setter 方法完成，这发生在容器调用一个无参数的构造器或无参数的 `static` 工厂方法实例化了你的 bean 之后。

下面的例子展示了一个只能通过 setter 注入实现依赖注入的类。这个类只包含普通 Java 代码（译注：ERROR!）。它是一个 POJO，不依赖于任何的容器特定的接口、基类或注解。

	public class SimpleMovieLister {

		// the SimpleMovieLister has a dependency on the MovieFinder
		private MovieFinder movieFinder;

		// a setter method so that the Spring container can inject a MovieFinder
		public void setMovieFinder(MovieFinder movieFinder) {
			this.movieFinder = movieFinder;
		}

		// business logic that actually uses the injected MovieFinder is omitted...

	}

`ApplicationContext` 支持基于构造器和基于 setter 方法的依赖注入方式来管理 bean。它也支持在一些依赖已经通过构造器的方式注入之后再基于 setter 方法注入依赖。你通过 `BeanDefinition` 配置依赖关系，搭配使用 `PropertyEditor` 实例，可以将属性从一种格式转换成另一种。然而，大多数 Spring 用户并不直接使用这些类（如，通过编程方式），而是通过 XML `bean` 定义，注解组件（如，注解类 `@Component`，`@Controller`，等），或 `@Configuration` 注解类的 `@Bean` 注解方法。这些源码会在内部被转化成 `BeanDefinition` 实例，并用于装载成一个全功能的 Spring IoC 容器实例。

 > **基于构造器还是 setter 方法的依赖注入？**
 >
 > 因为你会弄混基于构造器和基于 setter 方法的依赖注入，这是一条好的规则，为*强制依赖*使用构造器方式，*可选依赖*选用 setter 方法或配置方法。注意可以在 setter 方法上通过使用 `@Required` 注解来使属性成为必须依赖。
 >
 > Spring 开发组一般推荐构造器注入方式，因为它使你将应用组件实现为*不可变对象*，并保证必须依赖的引用不会为 `null`。而且，构造器注入方式肯定会返回一个完全初始化的对象给客户（调用）代码。作为一个小提醒（As a side note），大量的构造器参数是一种*臭代码（bad code smell）*，意味着这个类可能有太多的责任，应当被重构成一个更好的关注点分离。（译注：WHAT?）
 >
 > setter 注入应该主要用于可选依赖，这种依赖可以在类中已分配了默认值。此外，任何使用这些依赖的地方都应该现有非空检查。setter 注入的一个优点是 setter 方法可使依赖类的对象在之后重新配置或注入。然而，通过 [JMX MBeans]() 的管理操作强制使用 setter 依赖。
 >
 > 使用那种方式的依赖注入有时取决于特定类。有时，当使用没有源码的第三方类时，使用那种方式取决于你。比如，一个第三方类没有暴漏任何的 setter 方法，那么构造器注入可能是唯一的依赖注入方式。

##### 依赖解析过程

容器解析 bean 依赖关系，按照如下规则：

 - `ApplicationContext` 通过描述所有 bean 的配置数据来被创建和初始化。配置数据可以通过 XML，Java 代码或注解声明。
 - 对每一个 bean，它的依赖表述为一组属性，构造器参数或静态工厂方法的参数（如果你使用静态工厂方法替代一个普通构造器）。这些依赖被提供给这个 bean，*在 bean 被实际实际创建完成的时候*。
 - 每个属性或构造器参数是一个实际定义的值，或引用容器中的另一个 bean。
 - 每个属性或构造器参数是一个值，这个值是从它的特定格式转换成实际属性或构造器参数的类型对应的值。 默认，Spring 可以转换提供的字符串值到所有的内置类型，如 `int`，`long`，`String`，`boolean`，等。

Spring 容器在创建时会验证每个 bean 的配置。然而，bean 属性本身不会被设置直到依赖 bean 被*实际创建*。在容器创建的时候，如果 bean 是单例域的并设置成预初始化（默认设置），bean 将会被创建。域的定义在 [5.5 小节，“Bean 域”]()。否则，bean 只在需要时才被创建。bean 的创建会潜在引入 bean 创建图，描述 bean 的依赖和它的依赖的依赖（等等）会被创建和分配。注意，那些依赖中不匹配的解析将会在之后解决，如，相关 bean 首次创建的时候。

 > **循环依赖**
 > 
 > 如果你主要使用构造器注入，那就可能创建无法解析的循环依赖场景。
 >
 > 比如：A 类需要通过构造器注入 B 类的实例，B 类需要通过构造器注入 A 类的实例。如果，你配置 A 和 B 类相互注入彼此，Spring IoC 容器会在运行时检测循环应用，并抛出 `BeanCurrentlyInCreationException`。
 >
 > 一个可选解决方案是编辑某些类代码，通过 setter 方法注入而非构造器。即，避免构造器注入并只使用 setter 注入。换句话说，尽管并不推荐，你可以通过 setter 注入方式配置循环依赖。
 >
 > 不像*典型*应用（不存在循环依赖），一个 A bean 和 B bean 之间的循环依赖，会强制其中的一个 bean 先被注入到另一个来实现自己的完全初始化（典型的“先有鸡还是先有蛋”的场景）。

你一般可以相信 Spring 会做正确的事情。它会在容器的装载过程检测配置错误，如引用了不存在的 bean 和循环依赖。Spring 尽可能迟的设置属性和解决依赖，直到 bean 被实际创建了。这意味着，在你实际请求一个对象的时候，如果创建这个对象或它的依赖的过程中出现了错误，已经正确装载的 Spring 容器就可以生成一个异常。比如，bean 抛出一个异常表示缺失属性或属性配置错误。这可能会导致延迟显示一些配置问题，这也是为什么 `ApplicationContext` 实现默认会预先实例化 bean 单例。在实际需要 bean 之前，花费一些前期启动的时间和内存来创建所有 bean，这样你会在 `ApplicationContext` 创建的时候就发现配置问题，而非之后。你仍可以覆盖这种默认行为，这样单例 bean 将会延迟初始化，而非预先实例化。

如果没有循环引用存在，当一或多个协作 bean 被注入到需要依赖的 bean，每个协作 bean 被*完全地*配置到需要依赖的 bean（译注：ERROR!）。这意味着如果 bean A 依赖于 bean B，Spring IoC 容器会先完全地配置 bean B，然后调用 bean A 的 setter 方法设置对 bean B 的依赖。换句话说，bean 被实例化（如果不是预先实例化的单例），它的依赖被设置，相关声明周期方法被调用（如，[配置初始化方法]()或[InitializingBean 回调方法]()）。

##### 依赖注入示例

下面的例子为基于 setter 方法的依赖注入使用基于 XML 的配置数据。Spring XML 配置文件中的一部分 bean 定义：

	<bean id="exampleBean" class="examples.ExampleBean">
		<!-- setter injection using the nested ref element -->
		<property name="beanOne">
			<ref bean="anotherExampleBean"/>
		</property>

		<!-- setter injection using the neater ref attribute -->
		<property name="beanTwo" ref="yetAnotherBean"/>
		<property name="integerProperty" value="1"/>
	</bean>

	<bean id="anotherExampleBean" class="examples.AnotherBean"/>
	<bean id="yetAnotherBean" class="examples.YetAnotherBean"/>

ExampleBean 类：（译注：作者添加）

	public class ExampleBean {
	
		private AnotherBean beanOne;
		private YetAnotherBean beanTwo;
		private int i;
	
		public void setBeanOne(AnotherBean beanOne) {
			this.beanOne = beanOne;
		}
	
		public void setBeanTwo(YetAnotherBean beanTwo) {
			this.beanTwo = beanTwo;
		}
	
		public void setIntegerProperty(int i) {
			this.i = i;
		}
	
	}








