##### <center>10. 测试</center>
##### <center>Part III. 核心技术</center>

----------------------------------------

### 11. 测试

### 11.1 Spring 测试模块简介

测试，是企业应用软件开发必须的一部分。本章专注于重在在于通过 IoC 原理实现[单元测试（unit testing）]()，及通过 Spring 框架支持[集成测试（integration testing）]()的好处。(关于企业级应用的一个完整的测试流程规范讲解超出本文档的范围。)

### 11.2 单元测试

依赖注入，将会使你的代码减少对于容器的依赖相比于使用传统的 Java EE 容器。你的应用由各种 POJO 对象组成，它们应该是可测试的无论是用 JUnit 或 TestNG，只需要简单通过 `new` 操作符实例化它们，*而不必依赖于 Spring 或任何其他容器*。你可以使用 [Mock 对象（mock objects）]()（结合其他良好的测试技术）来隔离测试你的代码。如果，你按照 Spring 建议的架构，代码拥有清晰的层次和组件，那么将大大方便单元测试。比如，当运行单元测试时，你可以通过模拟 DAO 或 Repository 接口测试 service 层对象，不用真的去存取持久层数据。

真正的单元测试一般运行的非常快，因为一般不需要创建完整的运行时环境。强调单元测试作为你开发方法的一部分将会促进你的工作效率。你可能并不需要阅读本章来使你写出更加容易测试的基于 Ioc 的应用。然而，对于某些特定的单元测试场景，Spring 框架提供了如下 Mock 对象和测试支持类。

#### 11.2.1 Mock 对象

##### 环境（Environment）

`org.springframework.mock.env` 包含 `Environment` 和 `PropertySource` 抽象的 Mock 实现（参加 5.13.1 小节，“组件定义”和 5.13.3 小节“PropertySource抽象”）。`MockEnvironment` 和 `MockPropertySource` 对于开发依赖环境（译注：OS，JDK 等）的*容器外（out-of-container）*测试很有用。

##### JNDI

`org.springframework.mock.jndi` 包含 JNDI SPI 的 Mock 实现，可以用于设置一个简单的 JNDI 环境用于测试或独立应用。如果，比如说在某种 Java EE 容器中测试代码有 JDBC `DataSource`s 绑定到同样的 JNDI 名称，你可以在测试场景重用应用代码和配置而不用做任何修改。