## Log4j XML 配置入门

### 基本示例

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

### XML 配置格式

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

### `appender` 配置

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
 - 0 或多个 **filter** 元素 - 见**[过滤器配置](#Filter-Conf)**小节。 
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

### Logger 配置

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

 一个典型的 `logger` 元素配置类似与如下：

	<logger name="com.mycompany.apackage.MyClass">
		<level value="info" />
	</logger>

#### Logger 继承机制

稍后描述。

#### 日志叠加

`logger` C 的 log 操作将会输出到所有 C 中定义的 `appender` 和 C 的祖先 `logger` 中。这就是 *appender additivity* 的含义。

然而，如果 C 的一个祖先，比如 P，P 的 *additivity* 属性设置为 `false`，那么 C 的信息将会直接输出到 C 中定义的 `appender` 和它直到祖先 P（包括 P） 的但不包括 P 的祖先的 `appender` 中。

`logger` 的 *additivity* 标记默认为 *true*。配置示例：

	<logger name="com.eatmutton.muttonsite.torque" additivity="false">
		<level value="info" />
		<appender-ref ref="local-torque" />
	</logger>

`additivity` 小节取自 [http://logging.apache.org/log4j/docs/manual.html](http://logging.apache.org/log4j/docs/manual.html)。

 > 译注：`additivity` 没有看懂，疑问，这里所说的祖先是类中的继承关系吗？怎么构造出这样的例子呢？这也许得参考上面的链接中的内容。

 ### properties 配置方式转 XML 格式

 我将 log4j 使用文档中的配置例子转成了 xml 格式。希望能帮助有需要的人转化自己的配置文件。

 #### 例子 1

 	# Set root logger level to DEBUG and its only appender to A1.
	# 设置 `root logger` 的日志输出最小等级为 *DEBUG*，设置 `appender` 为 *A1*。
	log4j.rootLogger=DEBUG, A1

	# A1 is set to be a `ConsoleAppender`。
	log4j.appender.A1=org.apache.log4j.ConsoleAppender

	# A1 uses PatternLayout.
	log4j.appender.A1.layout=org.apache.log4j.PatternLayout
	log4j.appender.A1.layout.ConversionPattern=%-4r [%t] %-5p %c %x - %m%n

转化成 XML 格式如下：

	<?xml version="1.0" encoding="UTF-8" ?>
	<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
	
	<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
	
		<!-- A1 is set to be a ConsoleAppender -->
		<appender name="A1" class="org.apache.log4j.ConsoleAppender">
			<!-- A1 uses PatternLayout -->
			<layout class="org.apache.log4j.PatternLayout">
				<param name="ConversionPattern" value="%-4r [%t] %-5p %c %x - %m%n" />
			</layout>
		</appender>
	
		<root>
			<!-- Set root logger level to DEBUG and its only appender to A1 -->
			<priority value="debug" />
			<appender-ref ref="A1" />
		</root>
	
	</log4j:configuration>

 #### 例子 2

	log4j.rootLogger=DEBUG, A1
	log4j.appender.A1=org.apache.log4j.ConsoleAppender
	log4j.appender.A1.layout=org.apache.log4j.PatternLayout

	# Print the date in ISO 8601 format
	log4j.appender.A1.layout.ConversionPattern=%d [%t] %-5p %c - %m%n

	# Print only messages of level WARN or above in the package com.foo.
	# 只打印 `com.foo` 包下等级 *WARN* 及以上的日志信息。
	log4j.logger.com.foo=WARN

转化成 XML 格式如下：

	<?xml version="1.0" encoding="UTF-8" ?>
	<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
	
	<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
	
		<appender name="A1" class="org.apache.log4j.ConsoleAppender">
			<layout class="org.apache.log4j.PatternLayout">
				<!-- Print the date in ISO 8601 format -->
				<param name="ConversionPattern" value="%d [%t] %-5p %c - %m%n" />
			</layout>
		</appender>
	
		<logger name="com.foo">
			<!-- Print only messages of level warn or above in the package com.foo -->
			<level value="warn" />
		</logger>
	
		<root>
			<priority value="debug" />
			<appender-ref ref="A1" />
		</root>
	
	</log4j:configuration>

 #### 例子 3

 	log4j.rootLogger=debug, stdout, R

	log4j.appender.stdout=org.apache.log4j.ConsoleAppender
	log4j.appender.stdout.layout=org.apache.log4j.PatternLayout

	# Pattern to output the caller's file name and line number.
	# 输出调用者（类）文件的名称和调用方法所在行号。
	log4j.appender.stdout.layout.ConversionPattern=%5p [%t] (%F:%L) - %m%n

	log4j.appender.R=org.apache.log4j.RollingFileAppender
	log4j.appender.R.File=example.log

	log4j.appender.R.MaxFileSize=100KB
	# Keep one backup file
	log4j.appender.R.MaxBackupIndex=1

	log4j.appender.R.layout=org.apache.log4j.PatternLayout
	log4j.appender.R.layout.ConversionPattern=%p %t %c - %m%n

 > 译注：layout 实例无法重用吗？layout 必须使用全小写，否则出现 *找不到* 报错。而简单属性首字母（只限于首字母）大小写皆可。
 
转化成 XML 格式如下：

	<?xml version="1.0" encoding="UTF-8" ?>
	<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
	
	<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
	
		<appender name="stdout" class="org.apache.log4j.ConsoleAppender">
			<layout class="org.apache.log4j.PatternLayout">
				<!-- Pattern to output the caller's file name and line number -->
				<param name="ConversionPattern" value="%5p [%t] (%F:%L) - %m%n" />
			</layout>
		</appender>
	
		<appender name="R" class="org.apache.log4j.RollingFileAppender">
			<!-- 译注：最好用 File. -->
			<param name="file" value="example.log" />
			<param name="MaxFileSize" value="100KB" />
			<!-- Keep one backup file -->
			<param name="MaxBackupIndex" value="1" />
			<layout class="org.apache.log4j.PatternLayout">
				<param name="ConversionPattern" value="%p %t %c - %m%n" />
			</layout>
		</appender>
	
		<root>
			<priority value="debug" />
			<appender-ref ref="stdout" />
			<appender-ref ref="R" />
		</root>

	</log4j:configuration>

### <a name="Filter-Conf"></a>过滤器配置

`filter` 可以定义在 `appender` 中。比如只过滤特定等级的日志信息，可以按照如下方式使用 [LevelRangeFilter](http://wiki.apache.org/logging-log4j/LevelRangeFilter)：

	<appender name="TRACE" class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.PatternLayout">
			<param name="ConversionPattern" value="[%t] %-5p %c - %m%n" />
		</layout>
		<filter class="org.apache.log4j.varia.LevelRangeFilter">
			<param name="levelMin" value="DEBUG" />
			<param name="levelMax" value="DEBUG" />
		</filter>
	</appender>

### 高级主题

稍后描述。

### 更多示例

（请在这里随意添加你的配置示例。）

注意，[TimeBasedRollingPolicy](/logging-log4j/TimeBasedRollingPolicy) 只能在 XML 中配置使用，而无法在 log4j.properties 中。

	<?xml version="1.0" encoding="UTF-8" ?>
	<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
	
	<!-- Note that this file is refreshed by the server every 60seconds,
		as specified in web.xml -->
	
	<log4j:configuration debug="true">
	
		<appender name="ROLL" class="org.apache.log4j.rolling.RollingFileAppender">
			<!-- The active file to log to -->
			<param name="file" value="/applogs/myportal/portal.log" />
			<param name="append" value="true" />
			<param name="encoding" value="UTF-8" />
	
			<rollingPolicy class="org.apache.log4j.rolling.TimeBasedRollingPolicy">
				<!-- The file to roll to, this is a fairly intelligent parameter, if the 
					file ends in .gz, it gzips it, based on the date stamp it rolls at that time, 
					default is yyyy-MM-dd, (rolls at midnight).
					See: http://logging.apache.org/log4j/companions/extras/apidocs/org/apache/log4j/rolling/TimeBasedRollingPolicy.html -->
				<param name="FileNamePattern" value="/applogs/myportal/portal.%d.log.gz" />
			</rollingPolicy>
	
			<layout class="org.apache.log4j.PatternLayout">
				<!-- The log message pattern -->
				<param name="ConversionPattern" value="%5p %d{ISO8601} [%t][%x] %c - %m%n" />
			</layout>
		</appender>
	
		<!-- Loggers to filter out various class paths -->
		<logger name="org.hibernate.engine.loading.LoadContexts" additivity="false">
			<level value="error" />
			<appender-ref ref="ROLL" />
		</logger>
	
		<!-- Debugging loggers -->
	
		<!-- Uncomment to enable debug on calpoly code only -->
		<!--
		<logger name="edu.calpoly">
			<level value="debug" />
			<appender-ref ref="ROLL" />
		</logger>
		-->
	
		<root>
			<priority value="info" />
			<appender-ref ref="ROLL" />
		</root>
	
	</log4j:configuration>

Log4jXmlFormat (最后编辑时间 2013-04-15 10:15:25，[WikiCleaner](/logging-log4j/WikiCleaner)。

 > **原文：** [Log4jXmlFormat](http://wiki.apache.org/logging-log4j/Log4jXmlFormat)。
