## nginx 指令

- [location](#control)
- [rewrite](#rewrite)
- [upstream](#upstream)
- [server](#server)
- [proxy_pass](#proxy_pass)

### <a name="control"></a> [location](http://nginx.org/en/docs/http/ngx_http_core_module.html#location)

    语法：    location [ = | ~ | ~* | ^~ ] uri { ... }
             location @name { ... }
    默认值：  -
    作用域：  server, location

根据请求的 URI 作用对应的配置。

匹配规则基于规范化处理后的 URI，规范化操作涉及解码“%XX”（译注如空格、？、&），解析相对路径引用如“.”和“..”，及可能[压缩](#http://nginx.org/en/docs/http/ngx_http_core_module.html#merge_slashes)两个或两个以上的相邻“/”成一个“/”。

`location` 可以定义为前缀字符串或正则表达式。正则表达式需要前置“~*”（大小写不敏感匹配）或“~*”（大小写敏感匹配）修饰符。为请求查找 `location`，nginx 首先检查前缀字符串定义的 `location`。在其中确定最长匹配并记住。然后（前缀字符串无法找到匹配时）检查正则表达式，检查顺序按照在配置文件中的定义顺序。找到第一个匹配的正则表达式时就停止，并应用它相关的配置。如果没有匹配的正则表达式，那么将会应用之前记住的前缀字符串的配置。

`location` 快可嵌套，但下面描述中会提到一些例外。

对于不区分大小写的操作系统（如 macOS 和 Cygwin），前缀字符串匹配无视大小写（0.7.7）。但比较仅限于一字节的语言环境。

正则表达式可以包含捕获（0.7.40），并应用到后续指令中。

如果最长匹配有“~^”修饰符那么不会检查后续正则表达式。

“=”修饰符用于定义精确匹配，匹配到此类，则停止查找。比如，如果“/”请求经常出现，定义“location = /”将会加速请求处理的过程，因为在第一次查找后就结束了。这种匹配不能包含嵌套的 `location`。

演示上面的匹配规则：

    location = / {
        [ configuration A ]
    }

    location  / {
        [ configuration B ]
    }

    location /documents/ {
        [ configuration C ]
    }

    location ^~ /images/ {
        [ configuration D ]
    }

    location ~* \.(gif|jpg|jpeg)$ {
        [ configuration E ]
    }

“/”将会匹配 configuration A，“/index.html”将会匹配 configuration B，“/documents/document.html”将会匹配 configuration C，“/images/1.gif”将会匹配 configuration D，“/documents/1.jpg”将会匹配 configuration E。

“@”前缀定义一个命名的 `location`。这种 `location` 不用于通常的请求处理，而是用于请求重定向。这种 `location` 无法嵌套。

如果 `location` 由以“/”字符结尾的前缀字符串定义，并且请求由 [proxy_pass](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass)，[factcgi_pass](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_pass)，[uwcgi_pass](http://nginx.org/en/docs/http/ngx_http_uwsgi_module.html#uwsgi_pass)，[scgi_pass](http://nginx.org/en/docs/http/ngx_http_scgi_module.html#scgi_pass)，[memcached_pass](http://nginx.org/en/docs/http/ngx_http_memcached_module.html#memcached_pass)，或 [grpc_pass](http://nginx.org/en/docs/http/ngx_http_grpccgi_module.html#grpc_pass) 之一处理，那么将会执行特定的处理过程。如果没有尾部“/”，那么将会发起 301 永久重定向，在请求 URI 后附加“/”（译注：what?）。如果不期望这种默认行为，可以像这样定义 URI 和 `location` 的精确匹配：

    location /user/ {
        proxy_pass http://user.example.com;
    }

    location = /user {
        proxy_pass http://login.example.com;
    }

### <a name="rewrite"></a> [rewrite](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html#rewrite)

    语法：    rewrite regex replacement [flag];
    默认值：  -
    作用域：  server, location, if

如果请求 URI 匹配到正则表达式，URI 将会变为 `replacement`。`rewrite` 指令按照在配制文件中定义的顺序执行。可以通过 `flag` 终止后续处理。如果 `replacement` 以 `http`，`https://`，或 `$scheme`，将停止处理返回重定向给客户端。

可选的 `flag` 参数如下：

 - last
    > 停止处理 `ngx_http_rewrite_module` 指令，并为替换后的 URI 查找新的 `location`；
 - break
    > 停止处理 `ngx_http_rewrite_module` 指令，并像[break](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html#break)指令作用一样；
 - redirect
    > 返回临时重定向 302 码，当 `replacement` 不以 `http`，`https://`，或 `$scheme` 起始时可用；
 - permanent
    > 返回永久重定向 301 码。

完整的重定向 URL 由请求类型（`$scheme`）、[server_name_in_redirect](http://nginx.org/en/docs/http/ngx_http_core_module.html#server_name_in_redirect) 和 [port_in_redirect](http://nginx.org/en/docs/http/ngx_http_core_module.html#port_in_redirect) 指令共同组成。

如：

    server {
        ...
        rewrite ^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 last;
        rewrite ^(/download/.*)/audio/(.*)\..*$ $1/mp3/$2.ra  last;
        return  403;
        ...
    }

如果这些指令放在“/download/” `location`，那么 `last` 应该被替换为 `break`，否则 nginx 会执行 10 次循环匹配然后返回 500 错误：

    location /download/ {
        rewrite ^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 break;
        rewrite ^(/download/.*)/audio/(.*)\..*$ $1/mp3/$2.ra  break;
        return  403;
    }

如果 `replacement` 中包含新的请求参数，那么旧的请求参数将会被追加在后面。如果不期望这种默认行为，在 `replacement` 后添加 `?` 作为结尾来避免，比如：

    rewrite ^/users/(.*)$ /show?user=$1? last;

如果正则表达式包含“}”或“;”字符，需要用英文单引号或双引号括起来。

### <a name="upstream"></a> [upstream](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#upstream)

    语法：    upstream name { ... }
    默认值：  -
    作用域：  http

定义一个服务器组。服务器可以监听不同的端口。另外，可以混合监听 TCP 和 UNIX-domain socket。

示例：

    upstream backend {
        server backend1.example.com weight=5;
        server 127.0.0.1:8080       max_fails=3 fail_timeout=30s;
        server unix:/tmp/backend3;
    
        server backup1.example.com  backup;
    }

默认，nginx 通过加权轮询负载均衡算法将请求分发到不同的服务器。上面的例子中，每 7 个请求的分发规则：5 个发送到 `backend1.example.com`，第二和第三个各一个。如果与服务器通讯发生错误，那么请求将会被传递到下一个服务器，直到尝试完所有正常运行的服务器。如果无法获得任何服务器的成功响应，将会返回与最后一个服务器的通讯结果给客户端。

### <a name="server"></a> [server](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server)

    语法：    server address [parameters];
    默认值：  -
    作用域：  upstream

为 `upstream` 定义一台服务器的 `address` 和其他 `parameters`。地址可以声明为可选端口的域名或 IP，或者以 `unix:` 前缀声明的 UNIX-domain socket。如果没有声明端口，则使用 80。如果域名被解析为多个 IP，则表示一次性定义了多个 `server`（WTF?）。

可选参数定义如下：

 - weight=*number*
    > 设置服务器权重，默认为 1。
 - max_conns=*number*
    > 限制与代理服务器处于最大活动状态的连接数（1.11.5）。默认为 0，表示没有限制。如果服务器组没有设置[共享内存](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#zone)，则此设置对每个工作进程独立有效。
    > > 如果启用了 [idle keepalive](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive)，多[workers](http://nginx.org/en/docs/ngx_core_module.html#worker_processes) 和 [shared memory](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#zone)，总的连接到代理服务器的活动和空闲连接数可能超过 `max_conns` 值。
 - max_fails=*number*
    > 在 fail_timeout 时间内设置与服务器通信不成功的尝试次数，全部失败表示服务器不可用。默认设置为 1。设置为 0 表示不做尝试计数。不成功的尝试由 [proxy\\_next\\_upstream](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_next_upstream)，[fastcgi\\_next\\_upstream](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_next_upstream)，[uwsgi\\_next\\_upstream](http://nginx.org/en/docs/http/ngx_http_uwsgi_module.html#uwsgi_next_upstream)，[scgi\\_next\\_upstream](http://nginx.org/en/docs/http/ngx_http_scgi_module.html#scgi_next_upstream)，[memcached\\_next\\_upstream](http://nginx.org/en/docs/http/ngx_http_memcached_module.html#memcached_next_upstream) 和 [grpc\\_next\\_upstream](http://nginx.org/en/docs/http/ngx_http_grpc_module.html#grpc_next_upstream) 指令定义。
 - fail_timeout=*number*
    > - 不成功的尝试达到次数后，发起下次检查的间隔时间；
    > - 以及认为服务器不可用的时间。
    >
    > 默认此参数设置为 10 秒。
    > > 在 max\_fails 定义的失败次数后，距离下次检查的间隔时间，默认是 10s；如果 max\_fails 是 5，它就检测 5 次，如果 5 次都是 502，那么，它就会根据 fail\_timeout 的值，等待 10s 再去检查，还是只检查一次，如果持续 502，在不重新加载 Nginx 配置的情况下，每隔 10s 都只检测一次。参考《跟老男孩学 Linux 运维》。
 - backup
    > 标记服务器为备用服务器。当主服务器不可用时传递请求给它。
 - down
    > 标记服务器永久不可用。

**其他商业版支持参数略，包括 resolve，route=string，service=name，slow_start=time，drain。**

### <a name="proxy_pass"></a> [proxy_pass](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass)

    语法：    proxy_pass URL;
    默认值：  -
    作用域：  location, if in location, limit_except

为 `location` 设置映射的代理服务器的协议和地址及一个可选的 URI。协议可以声明为“http”或“https”。地址可以声明为域名或 IP 加一个可选的端口：

    proxy_pass http://localhost:8000/uri/;

或 “unix:” 前缀声明的 UNIX-domain socket 路径“：

    proxy_pass http://unix:/tmp/backend.socket:/uri/;

如果域名可以被解析为多个 IP，则这些地址将以轮询形式使用。也就是说地址可以声明为[服务器组](http://nginx.org/en/docs/http/ngx_http_upstream_module.html)。

参数值（译注：即 URL）可以包含变量。此时，如果地址声明为域名，首先在服务器组中查找，如果未找到，会在[resolver](http://nginx.org/en/docs/http/ngx_http_core_module.html#resolver)中确定。

请求 URI 按照如下规则发送给代理服务器：

 - 如果 `proxy_pass` 指令声明中包含了 URI，则当请求发送给服务器时，请求 URI 中与 `location` 匹配的部分将被指令中声明的 URI 替换。
    >
        location /name/ {
            proxy_pass http://127.0.0.1/remote/;
        }
 - 如果 `proxy_pass` 指令声明中不包含 URI，则请求 URI 将会以其原始的形发送给代理服务器，或者将改变后 URI 规范化后发送给发代理服务器。
    >
        location /some/path/ {
            proxy_pass http://127.0.0.1;
        }

某些情况下，无法确定要被替换的请求 URI 的部分：

 - `location` 通过正则表达式声明，且在 `@name location` 内部。
    > 此时，`proxy_pass` 声明中不能包含 URI。
 - URI 在代理型的 `location` 内部通过 [rewrite](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html#rewrite) 指令改变，并且这个配置用于处理一个请求（`break`）：
    >
        location /name/ {
            rewrite    /name/([^/]+) /users?name=$1 break;
            proxy_pass http://127.0.0.1;
        }
    > 此时，将忽略指令中声明的 URI，并将改变后的请求 URI 发送给代理服务器。
 - 在 `proxy_pass` 中使用变量：
    >
        location /name/ {
            proxy_pass http://127.0.0.1$request_uri;
        }
    > 此时，如果在指令内声明了 URI，将替换原始的请求 URI 后发送给代理服务器。

[WebSocket](http://nginx.org/en/docs/http/websocket.html) 代理在 1.3.13 后支持且需要特殊的代理配置。
