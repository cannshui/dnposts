## 部署 tomcat 7 ROOT 应用

通常在 tomcat 中，应用默认部署在 `$CATALINA_HOME/webapps` 下，部署后通过 `http://ip:port/context-path` 进行访问。

不过还应注意到，tomcat 中有一个特别的*默认 web 应用* `ROOT`，部署后可以通过 `http://ip:port` 访问，即没有 URL 中的 `context-path`，它表示处理所有未关联到某个具体 context 的请求（http[s] request）。如 `webapps` 下的 tomcat 一览页应用就部署成了 `ROOT`，直接通过 `http://localhost:8080` 访问。

通常当服务器有独立的域名，或就是希望忽略应用名称时，会希望直接将应用部署成 `ROOT` 应用，访问时会更加方便。下面记录部署成 `ROOT` 应用的 3 种方法。

 > 注：
 > 
 > 1. ROOT 为 tomcat 默认 web 应用。
 > 2. ip 和 port 以 tomcat 默认的 localhost 和 8080 作为示例。
 > 3. 下文中，以 myroot 应用为示例，应用下仅有 index.jsp 文件。

### 1. 替换当前 ROOT 应用

webapps 下已有 `ROOT` 应用，可以将其删除，然后将自己的 ROOT.war 直接或解压后部署在 webapps 下。

一般不建议着么做，因为限定了应用的名称必须是 ROOT，无法通过名称直接反应应用的信息，不利于将来的维护。

### 2. server.xml 中声明

`server.xml` 位于 `$CATALINA_HOME/conf` 下。找到其中的 `<Host/>` 标签，在其下插入 `<Context/>` 标签，最简单的形式如下：

	<Context path="" docBase="myroot" />

`path` 属性**必须为空**，才表示 ROOT 应用，否则就是具体的 `context-path`。myroot 应用位于部署目录（默认为 webapps）下，此时会导致两个问题：

 1. 原已有的 ROOT（如果存在）无法被访问。如果通过 `http://localhost:8080/ROOT` 访问，将会发现返回 404。
 2. **双重部署问题。**

双重部署，指同一个应用在 tomcat 容器中表现为两个独立的应用，也就是两个独立的 context。以此处的 myroot 为例，无论通过 `http://localhost:8080` 或是 `http://localhost:8080/myroot` 都可访问 myroot，但它们是两个独立的 context。如何验证呢，编辑 index.jsp 文件，内容只包含如下一行：

	<% System.out.println(application); %>

当以 `http://localhost:8080` 和 `http://localhost:8080/myroot` 访问时会发现 tomcat terminal 中输出不同的 `application` 实例。

双重部署显然不是期望的副作用。可通过两种方式克服：

 1. 不部署在默认部署目录（默认为 webapps）下，如：

		<Context path="" docBase="/path/not/appBase/myroot" />

 2. 父级 `<Host/>` 标签的 `deployOnStartup` 和 `autoDeploy` 属性**同时**设置为 `false`。

修改 `server.xml` 中配置的方式，侵入性太强，且必须要重启 tomcat 后才可生效。一般也不再建议使用。

### 3. 自建应用级的 Context XML 文件中声明

根据[文档](https://tomcat.apache.org/tomcat-7.0-doc/config/context.html#Defining_a_context)中描述，xml 可位于 `/META-INF/context.xml` 或 `$CATALINA_BASE/conf/[enginename]/[hostname]/` 下。此时 `<Context/>` 的 `path` 属性将被忽略，`context-path` 被自动推断。为了部署 `ROOT` 应用，依据推断规则，只可在`$CATALINA_BASE/conf/[enginename]/[hostname]/` 创建 `ROOT.xml` 文件。此处具体为 `$CATALINA_HOME/conf/Catalina/localhost/ROOT.xml`，内容如下：

	<Context docBase="/path/not/appBase/myroot" />

注意，此时 `myroot` 不能部署在默认部署目录（默认为 webapps）下，否则将会被忽略。

### 4. 总结

第三种方法一般是建议的方式，它即不“简单粗暴”，又不具有强侵入性，也不要求配置变动时，必须重启 tomcat 才能生效。


**参考：**

 - [Apache Tomcat 7 Configuration Reference - The Context Container](https://tomcat.apache.org/tomcat-7.0-doc/config/context.html)
 - [Apache Tomcat 7 Configuration Reference - The Host Container](https://tomcat.apache.org/tomcat-7.0-doc/config/host.html)
 - [Deploy Application at Tomcat Root | Baeldung](https://www.baeldung.com/tomcat-root-application)
