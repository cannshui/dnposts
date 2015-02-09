### Log4j XML 配置入门

原文 [Log4jXmlFormat](http://wiki.apache.org/logging-log4j/Log4jXmlFormat)。

#### 基本示例

下面是一个很基本的 log4j xml 配置文件，可以让你快速上手：

	<?xml version="1.0" encoding="UTF-8" ?>
	<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">

	<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">

		<appender name="console" class="org.apache.log4j.ConsoleAppender">
			<param name="Target" value="System.out"/>
			<layout class="org.apache.log4j.PatternLayout">
				<param name="ConversionPattern" value="%-5p %c{1} - %m%n"/>
			</layout>
		</appender>

		<root>
			<priority value ="debug" />
			<appender-ref ref="console" />
		</root>

	</log4j:configuration>

按照上面配置，将会输出所有 `debug` 或之上级别的所有信息到屏幕控制台。注意点：

 - 首先应定义出 `appender`，必须声明 `name` 属性（这里是 *console*）。`appender` 包含一个 `layout`（这里是一个 `PatternLayout`），`layout` 包含一个 `pattern`。`layout` 的定义需满足 `layout` 规范，所以参照 javadoc 描述来准确定义你选用的 `layout` 类（`PatternLayout` 是最常用的）。
 - `loggers` 在这例子中没有出现，只定义了 `root logger` 的配置（译注：`root` 本质是一个 `logger`。）。`root logger` 配置成 `debug` 级别，并把 *console* `appender` 关联到它。所有的 `loggers` 都继承至 `root`，所以这个例子中，所有 `loggers` 的 `deubg` 级别以上的信息都将输出到 *console* `appender`。


#### XML 配置格式

为了更好的理解更细节的例子，熟悉 XML 配置文件的格式还是很有必要的。XML 语法格式定义在 log4j.dtd 中，它的位置在 log4j 二进制包下的 `org.apache.log4j.xml` 下。log4j.dtd 文件的内容不会被整个在这里列出，你可以直接打开/打印它。如果你不熟悉 xml dtd 文件格式，你最好先找本相关书籍进行查看。

文件开始位置附近是如下描述：

	<!ELEMENT log4j:configuration (renderer*, throwableRenderer?,
                               appender*,plugin*, (category|logger)*,root?,
                               (categoryFactory|loggerFactory)?)>

这个元素定义了 xml 文件期望的内容结构：包含 0 或多个 `renderer` 元素，0 或多个 `appender`，0 或多个 `logger` 元素，0 或一个 `root` 元素，0 或一个 `categoryFactory` 元素。元素之间出现的顺序必须按照定义中出现的顺序，否则 xml parser 在读入文件解析的时候将会打印出错误信息。小注，`category` 元素跟 `logger` 元素语义和作用相同。log4j 1.2 之前的版本，`loggers` 用 `category` 表示，所以很多的文档现在仍是沿用 `category`，记得它们是同一样东西就行了。

接下来， log4j.dtd 中是如下描述，定义了所允许的属性：

	<!ATTLIST log4j:configuration
	  xmlns:log4j              CDATA #FIXED "http://jakarta.apache.org/log4j/" 
	  threshold                (all|trace|debug|info|warn|error|fatal|off|null) "null"
	  debug                    (true|false|null)  "null"
	  reset                    (true|false) "false"
	>

 - **debug** - 可能是 `log4j:configuration` 最重要的的属性了，设置成 *true* 将会打印读取配置文件，根据配置文件配置 `log4j` 环境这个过程的信息。在配置文件没有按照预期工作的时候，这个选项设置成 *true* 会有助于指出问题所在。
 - **threshold** - 稍后介绍。

了解 XML 配置文件的预期结构，有助于更加专注于所需要进行配置的元素。


#### `appender` 配置

可以构造你的代码打印重要的调试信息，但 log4j 如果没有配置至少一个 `appender`，那么一切将是徒劳。调试信息将无从显示。

回顾 log4j.dtd，`appender` 元素声明如下：

	<!ELEMENT appender (errorHandler?, param*,
	      rollingPolicy?, triggeringPolicy?, connectionSource?,
	      layout?, filter*, appender-ref*)>
	<!ATTLIST appender
	  name 		CDATA 	#REQUIRED
	  class 	CDATA	#REQUIRED
	>

`appender` 元素必须设置 *name* 和 *class* 属性。*name* 用于后续配置文件中引用这个 `appender`（译注：类似于 id）。*class* 属性值需要是 `appender` 类的全类名（比如 `org.apache.log4j.ConsoleAppender`）。

`appender` 元素可以包含子元素：

 - 0 或 1 个 **errorHandler** 元素 - 稍后介绍。
 - 0 或多个 **param** 元素 - 每个 `appender` 可以设置成不同的功能。这是通过 `appender` 类中的 `getter` 和 `setter` 方法实现的。 `param` 元素用于 `setter` 方法。`param` 元素的格式很简单，它是原子元素，只有一个 *name* 属性和一个 *value* 属性。*name* 属性值是 `setter` 方法去掉 *set* 后的部分（如，方法名 `setTarget` 配置时是 *Target*）。*value* 属性是调用 `setter` 方法进行设置的值。
 - 0 或 1 个 **layout** 元素 - 并非所有 `appender` 都需要配置一个 `layout`。对于需要配置的，`layout` 元素定义了用到的 `layout` 类。`layout` 元素只有一个属性 *class*，声明用到的 `layout` 类的全类名。与 `appender` 元素类似，`layout` 元素也可以拥有 0 或多个 `param` 子元素。同样，`param` 元素用于设置 `layout` 类的属性值，根据不同 `layout` 类会有所不同。
 - 0 或多个 **filter** 元素 - 见 **[Filter Configuration](#Filter-Conf)** 小节。 
 - 0 或多个 **appender-ref** 元素 - 稍后介绍。

通过上述，简单示例中的 *console* `appender` 应该较易理解了：

	<appender name="console" class="org.apache.log4j.ConsoleAppender">
		<param name="Target" value="System.out" />
		<layout class="org.apache.log4j.PatternLayout">
			<param name="ConversionPattern" value="%-5p %c{1} - %m%n" />
		</layout>
	</appender>

这是一个 *console* `appender`。*console* 用于后续配置文件中对这个 `appender` 的引用。定义这个 `appender` 是基于 `org.apache.log4j.ConsoleAppender`。

*console* `appender` 有一个 `param` 元素。参照 `ConsoleAppender` javadoc 可知，`setTarget` 方法用于选择日志信息输出到哪个流，`System.out` 或是 `System.err`（标准输出或标准错误流）。这个例子中配置成使用 `System.out`。

*console* `appender` 也有一个 `layout` 元素，定义了使用 `org.apache.log4j.PatternLayout` 作为其格式化信息方式。参照 `PatternLayout` javadoc 可知，`setConversionPattern` 方法需要一个 `String` 类型参数描述日志信息输出的格式。日志信息格式化的细节参考 javadoc。

`appender` 类的配置细节根据选择的 `appender` 类会有所不同。最好的方法是在使用时参考 `appender` 类的 javadoc 进行配置。特别注意属性的 `setter` 方法和它所需的值。每个 `setter` 方法都可以在 XML 配置文件中通过 **param** 元素进行配置。

当前，有以下可选 `appender` 类：

 - org.apache.log4j.ConsoleAppender [ConsoleAppender](http://wiki.apache.org/logging-log4j/ConsoleAppender)
 - org.apache.log4j.FileAppender [FileAppender](http://wiki.apache.org/logging-log4j/FileAppender)
 - org.apache.log4j.JDBCAppender JDBCAppender
 - org.apache.log4j.AsyncAppender AsyncAppender
 - org.apache.log4j.net.JMSAppender [JMSAppender](http://wiki.apache.org/logging-log4j/JMSAppender)
 - org.apache.log4j.lf5.LF5Appender LF5Appender
 - org.apache.log4j.nt.NTEventLogAppender [NTEventLogAppender](http://wiki.apache.org/logging-log4j/NTEventLogAppender)
 - org.apache.log4j.varia.NullAppender NullAppender
 - org.apache.log4j.net.SMTPAppender [SMTPAppender](http://wiki.apache.org/logging-log4j/SMTPAppender)
 - org.apache.log4j.net.SocketAppender SocketAppender
 - org.apache.log4j.net.SocketHubAppender [SocketHubAppender](http://wiki.apache.org/logging-log4j/SocketHubAppender)
 - org.apache.log4j.net.SyslogAppender SyslogAppender
 - org.apache.log4j.net.TelnetAppender TelnetAppender
 - org.apache.log4j.WriterAppender WriterAppender


#### Logger 配置

现在 `appenders` 已经配置了。但是如何配置 `loggers` 输出一个特定等级的日志信息？如何配置 `loggers` 输出日志信息到指定的 `appender`？欢迎到 `logger` 的配置。

你需要配置的最重要的一个 `logger` 是 `root logger`。简单示例中，是如下配置：

	<root>
		<priority value="debug" />
		<appender-ref ref="console" />
	</root>

上面 `root logger` 配置成输出 *debug* 及以上等级的日志信息到 *console* `appender` 中。所有的 `loggers` 都继承至 `root logger` 的设置。所以，如果没有其他的配置项，所有的 `loogers` 都将自动输出它们的日志信息到 *console* `appender`。对于简单调试这没有问题，但最终总有可能需要更加详细的配置。

回顾 log4j.dtd，`logger` 元素声明如下：

	<!ELEMENT logger (param*,level?,appender-ref*)>
	<!ATTLIST logger
	  class         CDATA   #IMPLIED
	  name		CDATA	#REQUIRED
	  additivity	(true|false) "true"  
	>

 > 译注：我取至 log4j-1.2.16.jar 与原文有出入。

`logger` 元素必须有一个 *name* 属性，用于创建 `Logger` 实例时的名称（通常用全类名）。可以有一个可选的 *additivity* 属性，更多细节稍后介绍。

`logger` 元素可以包含子元素：

 - 0 或 1 个 **level** 元素 - 定义这个 `logger` 允许进行记录的日志信息的等级。常用有 `debug`，`info`，`warn`，`error`，或 `fatal`。只有当前等级或比当前等级更高的日志信息才会报告给日志记录。

 - 0 或多个 **appender-ref** 元素 - 用于引用一个已定义的 `appender`，当前 `logger` 将会输出日志信息到这个引用的 `appender` 中。`appender-ref` 是只有一个 *ref* 属性的简单元素，*ref* 属性值即是 `appender` 的 *name* 属性值。
