## <center>新手指南</center>

- [启动，停止，重载配置](#control)
- [配置文件的结构](#conf_structure)
- [处理静态内容](#static)
- [设置一个简单代理服务器](#proxy)
- [设置 FastCGI 代理](#fastcgi)

本指南介绍了 nginx 的基本概念，以及利用它所能做到的事。首先 nginx 应该已经安装在你（读者）的机器上了。如果还没有，那么参阅[安装 nginx](http://nginx.org/en/docs/install.html) 进行安装。（译注：解压包之后，运行 nginx，浏览器中输入[http://localhost](http://localhost)，将显示欢迎页。）本指南描述了，如何启动、停止、重载 nginx 配置，配置文件的结构，如何设置 nginx 处理静态内容，配置 nginx 作为代理服务器，及如何将它连接到 FastCGI 应用服务。

nginx 有一个主进程及很多工作者进程(worker processes)。主进程主要完成读取和执行配置，管理工作者进程。工作者进程处理实际的请求。nignx 采用了基于事件的模型及操作系统耦合的机制来高效地在工作者进程之间分发请求。工作者进程的数量在配置文件中定义，它可以被修改为指定的配置或是自动调整成 CPU 核数（参阅[工作者进程](http://nginx.org/en/docs/ngx_core_module.html#worker_processes)）。

nginx 及其各模块的工作方式在配置文件中进行定义。默认，配置文件为 nginx.conf， 位于 /usr/local/nginx/conf， /etc/nginx 或是 /usr/local/etc/nginx 其中之一的目录下。（译注：windows 在解压包/conf 下。）

#### <a name="control"></a><center>启动，停止和重载</center>

运行 nginx 可执行文件，启动 nginx. 一旦 nginx 启动后，可以通过带上 -s 选项，对它进行管理。使用以下语法：

	nginx -s signal

*signal* 可选如下：

- stop — 快速停止（fast shutdown）
- quit — 优雅停止（graceful shutdown）
- reload — 重载配置（reloading the configuration file）
- reopen — 重新打开日志文件（reopening the log files）

比如，停止 nginx 进程直到工作者进程完成处理当前请求，应执行以下命令：

	nginx -s quit

> 这个命令应当由启动 nginx 的用户执行。

配置文件中的更改将不会生效，直到通过命令使 nginx 重新装载配置了文件或进行重启。重载配置文件，执行：

	nginx -s reload

当主进程接受到了重载配置信号，它将检查配置文件的语法，然后尝试应用配置。如果成功，主进程将会启动新的工作者进程并发送信息给旧的（译注：修改配置文件之间的）工作者进程使它们停止。否则（译注：若果失败），主进程回滚变化，并继续利用旧的配置方式进行工作。旧的工作者进程，收到一个关闭命令后，将停止就收新请求，继续处理当前正在处理的请求直到结束。然后，老的工作者进程才会退出。

也可以通过 Unix kill 命令来发送信号给 nginx. 这时，信号是直接发送给一个指定 PID 号的进程。nginx 主进程的 PID 默认为 nginx.pid， 位于 /usr/local/nginx/logs 或是 /var/run. 比如，如果主进程 PID 是 1628， 发送 QUIT 信号时 nginx 优雅的关闭，可以执行：

	kill -s QUIT 1628

列出所有运行中的 nginx 进程，可以使用 ps 命令（译注：windows 用 tasklist），比如，执行：

	#unix
	ps -ax | grep nginx

	@rem windows
	tasklist | find "nginx"

更多关于发送信号给 nginx ，参考 [Controlling nginx](http://nginx.org/en/docs/control.html)

#### <a name="conf_structure"></a><center>配置文件的结构</center>

nginx 由一些列的模块组成，这些模块在配置文件中以指令方式声明。指令分为简单指令和块集指令。一条简单指令由名字和参数组成，名称和参数之间以空白符隔开，并以分号（;）结束。块集指令跟简单指令结构一样，但不能以分号表示结束，它由一些列由大括号（{}）包裹的额外指令组成。如果一个块指令的大括号中还有其他的指令（译注：简单指令或块集指令），那么它称之为一个上下文（context）（例如：[events](http://nginx.org/en/docs/ngx_core_module.html#events)， [http](http://nginx.org/en/docs/http/ngx_http_core_module.html#http)， [server](http://nginx.org/en/docs/http/ngx_http_core_module.html#server) 及 [location](http://nginx.org/en/docs/http/ngx_http_core_module.html#location)）。

配置文件中，在其他指令上下文之外的所有指令，处于 [main](http://nginx.org/en/docs/ngx_core_module.html) 上下文。`events` 和 `http` 指令处于 `main` 上下文中，`server` 在 `http` 中， `location` 在 `server` 中。

以 `#` 开头的行被解释为注释。

#### <a name="static"></a><center>处理静态内容</center>

web 服务器一个重要的任务就是发送文件（比如图片或静态网页）。你将学习一个例子，根据请求，从不同的本地目录拿取文件：/data/www（包含 HTML 文件）和 /data/images（包含图片）。实现上述，需要编辑配置文件设置一个 [server](http://nginx.org/en/docs/http/ngx_http_core_module.html#server) 块位于 [http](http://nginx.org/en/docs/http/ngx_http_core_module.html#http) 块中，`server` 包含两个 [location](http://nginx.org/en/docs/http/ngx_http_core_module.html#location) 块指定 HTML 和图片文件目录。

首先，创建 /data/www 目录，并编写一个随意 index.html 放在它下面，创建 /data/images 目录，放一些图片进去。

然后，打开配置文件。默认配置文件中已经包括很多 `server` 块的示例，大多处于注释状态。现在，全部注释掉，重新编写一个新的 `server` 块：

	http {
		server {
		}
	}

一般，配置文件中会包含很多的 `server` 块，由 [监听](http://nginx.org/en/docs/http/ngx_http_core_module.html#listen) 的端口和 [server name](http://nginx.org/en/docs/http/server_names.html)加以 [区分](http://nginx.org/en/docs/http/request_processing.html)。一旦，nginx 决定由哪个 `server` 处理一个请求，它将比较请求头中的 URI 和 `location` 指令中定义的参数。

添加如下 `location` 块到 `server` 块：

	location / {
		root /data/www;
	}

这个 `location` 块声明了 "/" 前缀同请求中的 URL 进行比较。对于匹配的请求，URI 将被添加到 [root](http://nginx.org/en/docs/http/ngx_http_core_module.html#root) 声明的指令中，这里是 `/data/www` ，形成到本地磁盘系统的实际文件路径。如果有很多匹配的 `location` 块，nginx 会选择那个最长匹配前缀的 `location` ，上面的 `location` 提供了最短匹配，长度为 1，所以直到其他所有 `location` 块匹配失败，这个块才会被用到。

接下来，添加第二个 `location` 块：

	location /images/ {
		# root /data; #译注：按照之前描述，应为如下：
		root /data/images;
	}

它会匹配以 `/images/` 作为前缀开头的请求（`location` `/` 同样可以匹配这些请求，但是是最短的前缀）。

所以，`server` 的配置应该类似于如下所示：

	server {
		location / {
			root /data/www;
		}

		location /images/ {
			# root /data; #译注：按照之前描述，应为如下：
			root /data/images;
		}
	}

这已经是一个服务器可以工作的配置了，监听端口为标准默认的 80，可以通过 [http://localhost/](http://localhost/) 进行访问。响应以 `/images/` 作为 URI 前缀的请求，服务器会将 `/data/images/` 目录中的文件返回。比如，为了响应 `http://localhost/images/example.png` 的请求，nginx 将会发送 /data/images/example.png 文件到客户端。如果这个文件不存在，nginx 将会发送一个代表 404 错误的响应到客户端。不是以 `/images/` 作为 URI 前缀的请求，将会被映射到 `/data/www` 目录。比如，响应 `http://localhost/some/example.html` 请求，nginx 会发送 `/data/www/some/example.html` 文件到客户端。

应用改动后新的配置，启动 nginx 如果还没启动它。或者发送重载信号给主进程，执行：

	nginx -s reload

> 如果没有达到按照预期效果，查阅 `access.log` 和 `error.log` 找出原因。这两个文件位于，`/usr/local/nginx/logs`（译注：nginx 目录） 或 `/var/log/nginx` 下。

#### <a name="proxy"></a><center>设置简单代理服务器</center>

nginx 最常用的方式之一就是设置成一个代理服务器，表示一个服务器接受请求，然后发送请求到被代理的服务器，从被代理的服务器接收响应，然后发送到客户端。

我们将配置一个基本的代理服务器，处理图片请求，发送其他的请求到被代理的服务器。这个例子中，两种服务器将会在一个 nginx 实例中定义。

首先，通过添加一或多个 `server` 块到 nginx 配置文件来定义一个被代理的服务器，内容如下：

	server {
		listen 8080;
		root /data/up1;

		location / {
		}
	}

这将定义一个监听在 8080 端口的简单服务器（之前，`listen` 指令没有被声明，因为默认将使用 80 端口），映射所有的请求到本地 `/data/up1` 目录。创建这个目录，放一个 `index.html` 文件。注意，`root` 指令在 `server` 上下文中（译注：比较与 `location` 中的 `root` 指令）。这里的 `root` 指令用于当一个选中的 `loation` 块不包含自己的 `root` 指令时。

然后，使用之前小节的 `server` 配置，修改成一个代理服务器的配置。第一个 `location` 块中，编写 [proxy_pass](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass) 指令，参数包括：协议，名称，被代理服务器监听端口（这里是，`http://localhost:8080`）：

	server {
		location / {
			proxy_pass http://localhost:8080;
		}

		location /images/ {
			root /data/images;
		}
	}

我们将修改第二个 `location` 块，当前是映射以 `/images/` 作为前缀的请求到 `/data/images` 目录，修改成只匹配指定后缀的图片请求。修改后的 `location` 块如下：

	location ~\.(gif|jpg|png)$ {
		root /data/images;
	}

`location` 的参数是一个正则表达式匹配所有以 `.gif`，`jpg`，`png` 结尾的 URI 请求。正则表达式应该以 `~` 作为起始。匹配的请求将被映射到 `/data/images` 目录下。

nginx 首先检查 [location](http://nginx.org/en/docs/http/ngx_http_core_module.html#location) 指令的指定前缀，记录下含有最长前缀的 `location`，然后检查正则表达式，最终选择一个 `location` 块来处理一个请求。如果 `location` 有一个正则表达式的匹配，nginx 将会它，否则，选择之前记忆的。

代理服务器的配置示例如下：

	server {
		location / {
			proxy_pass http://localhost:8080/;
		}

		location ~\.(gif|jpg|png)$ {
			root /data/images;
		}
	}

这个服务器将会过滤以 `.gif`，`.jpg` 或 `.png` 结尾的请求，将它们映射到 `/data/images` 目录（通过添加 URI 到 `root` 指令的参数），然后发送其他请求到上面被代理的服务器。

应用新的配置，发送重载信号到 nginx，如之前小节所述。

有很多[其他](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)指令用于更详尽的代理连接配置。

#### <a name="fastcgi"></a><center>设置 FastCGI 代理</center>

nginx 可以用于路由请求到 FastCGI 服务器。FastCGI 服务用于运行不同框架或编程语言所构建的程序，如 PHP。

nginx 配置成与 FastCGI 共同工作最基本的是使用 [fastcgi_pass](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_pass) 指令而非 `proxy_pass`，[fastcgi_param](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_param) 指令设置发送到 FastCGI 服务器的参数。假设，FastCGI 服务器配置在 `localhost:9000`。复制之前小节的代理配置，替换 `proxy_pass` 成 `fastcgi_pass` 指令，修改指令参数为 `localhost:9000`。 PHP 中，`SCRIPT_FILENAME` 用于指定脚本名称，`QUERY_STRING` 用于传递请求参数。现在配置文件应该如下所示：

	server {
		location / {
			fastcgi_pass localhost:9000;
			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
			fastcgi_param QUERY_STRING $query_string
		}

		location ~\.(gif|jpg|png)$ {
			root /data/images;
		}
	}

以上，将会设置一个服务器，通过 FastCGI 协议路由除了静态图片文件之外的所有请求到被代理的服务器（`localhost:9000`）。