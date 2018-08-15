## R 语言 Rserve 包实践

### 1. 操作系统准备

常规 Linux 发行版都可用，如 Ubuntu，CentOS。下面将以 CentOS-6.5-x86_64-minimal 为例。

 > 如果分配了已安装 Linux 的服务器，可跳过操作系统的准备。

如果没有独立的服务器，可在某台已有服务器上安装虚拟机。虚拟机软件选择 [VirtualBox](https://www.virtualbox.org/wiki/Downloads)。VirtualBox 中逐步安装 CentOS-6.5-x86_64-minimal 的过程不在本文描述。

 > 1. 虚拟机最好保证 4G 内存，20G 磁盘空间以上。
 > 
 > 2. 网络设置为桥接，以将其作为独立服务器看待。

### 2. R 环境准备

检查系统中是否已有 R 环境：

	R --version

如果正常输出版本号，则说明已有环境，可跳过 R 环境准备。如果显示 `command not found` 则说明需要安装，已确认 R 3.2.5 或 3.4.3 都可以正常使用 Rserve，最新的版本也应该满足向后兼容。当前 epel 源中最新的 R 版本为 3.5.0，通过 `yum install R` 进行安装。

 > 注：minimal 下通过 yum 安装时会提示 `No package R available` 则需要先安装 epel 源。
 > 
 > CentOS 6：
 >
	rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm

 > CentOS 7：
 >
	rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

### 3. Rserve 插件

#### 3.1 Rserve 简介

[Rserve](https://www.rforge.net/Rserve/) 是 R 语言中一个包，将其安装启动后可作为通过 TCP/IP 连接的服务端使用。其典型应用场景为部署成分布式的 R 语言环境，用作多种语言如 C/C++/PHP/Java 等执行 R 脚本进行统计建模、数据分析、绘图等的一种解决方案。

Rserve 特性：

 - **快：服务器启动时已初始化 R 环境的操作，后续调用时就不需要初始化的操作。**
 - 二进制传输：直接将 R 对象作为二进制传输，而非仅仅 R 的文本输出。
 - 自动类型转换：多数 R 数据类型可直接转换成本地的数据类型。
 - **持久连接：每个连接都有自己独立的命名空间和工作目录。每个你创建的对象将会持续到连接结束。**客户端不需要获取和存储中间结果。
 - 客户端独立：客户端不需要有 R 环境。
 - 安全：Rserve 通过加密用户名/密码为服务端提供一些基本的安全支持。Rserve 也可配置为只允许本地（local）连接。
 - **文件传输：Rserve 协议允许在客户端和服务端之间传输文件，因而可将 Rserve 用与回传 R 生成的图片文件。**
 - 配置友好：配置文件（默认 `/etc/Rserv.conf`）用于配置是否启用如认证、远程访问、文件传输等特性。

Rserve 警告：

 - Rserve 不提供回调功能。但用户可通过 TCP/IP 和 R socket 自己实现。
 - Rserve 不是 R 的 telnet 客户端。Rserve 的输出不会回传给客户端（除非通过 capture.output（not tried））。Rserve 为了性能采用二进制协议传输。
 - **不同的 Rserve 连接之间是线程安全的，但是同一个连接的 `eval` 方法是非线程安全的，这意味着如果多个线程同时使用一个连接的 `eval` 方法，应该由用户保证线程安全。**
 - 不推荐在 Windows 下使用，简而言之：Windows 下无法充分发挥 Rserve 的功能，且可能有潜在问题。
 - 出于安全考虑，最好不要以 root 用户启动 Rserve 服务。
 - 出于安全考虑，开启 `remote enable` 时最好同时配置 `auth required` 和 `plaintext disable`。（not tried）

#### 3.2 Rserve 安装

在 R 内部，从 CRAN 安装是最简单的方式：

	install.packages("Rserve")

当前安装版本为 1.7-3，虽然官网最新版本已是 1.8-6(2018-05-18 11:29)。

#### 3.3 Rserve 启动

虽然可以作为普通的 R 包从 R 内部进行启动，不过推荐直接在命令行中启动：

	R CMD Rserve

Rserve 的默认选项：不接受远端连接；无需用户名/密码；开启文件文件传输支持。

#### 3.4 Rserve 配置

Rserve 默认的配置文件为 `/etc/Rserv.conf`，如想修改默认文件，需在编译安装时设置 `-DCONFIG_FILE=...` 指定。或者在命令行参数中提供 `--RS-conf` 指定。配置参数在配置文件中设置，格式为逐行 `parameter value`，部分参数可直接在命令行中提供，与配置文件是等效的，所有的配置参数如下表所示：

<table>
  <tr><th>选项</th><th>参数</th><th>默认值</th><th style="width: 130px;">命令行参数</th><th>说明</th></tr>
  <tr><td>workdir</td><td>path</td><td>/tmp/Rserv</td><td>--RS-workdir</td><td>Rserve 连接的工作目录</td></tr>
  <tr><td>pwdfile</td><td>file</td><td>none|disabled</td><td></td></tr>
  <tr><td>remote</td><td>enable|disable</td><td>disable</td><td>--RS-enable-remote</td><td>命令行参数将直接启动用远程连接</td></tr>
  <tr><td>auth</td><td>required|disable</td><td>disable</td><td></td></tr>
  <tr><td>plaintext</td><td>enable|disable</td><td>disable</td><td></td></tr>
  <tr><td>fileio</td><td>enable|disable</td><td>enable</td><td></td></tr>
  <tr><td>interactive</td><td>yes|no</td><td>yes</td><td></td></tr>
  <tr><td>socket</td><td>socket</td><td>none=disabled</td><td>--RS-socket</td><td>使用 local socet 而非 TCP/IP 传输</td></tr>
  <tr><td>port</td><td>port</td><td>6311</td><td>--RS-port</td><td>Rserve 监听的端口</td></tr>
  <tr><td>maxinbuf</td><td>size in kb</td><td>262144</td><td></td><td>客户端发向服务端的最大数据量</td></tr>
  <tr><td>maxsendbuf</td><td>size in kb</td><td>0=unlimited</td><td></td><td>服务端发向客户端的最大数据量</td></tr>
  <tr><td>uid</td><td>uid</td><td>none</td><td></td><td rowspan="2"></td></tr>
  <tr><td>gid</td><td>gid</td><td>none</td><td></td></tr>
  <tr><td>su</td><td>now|server|client</td><td>none</td><td></td></tr>
  <tr><td>source</td><td>file</td><td></td><td>--RS-source</td><td>启动后执行指定 R 脚本</td></tr>
  <tr><td>eval</td><td>expressions</td><td></td><td></td><td>启动后执行指定表达式</td></tr>
  <tr><td>chroot</td><td>directory</td><td>none</td><td></td></tr>
  <tr><td>sockmod</td><td>mode</td><td>0=default</td><td></td></tr>
  <tr><td>umask</td><td>mask</td><td>0</td><td></td></tr>
  <tr><td>encoding</td><td>native|utf8|latin1</td><td>native</td><td>--RS-encoding</td><td>服务端编码数据的方式，如果客户端为 Java，建议设置值为 UTF8。</td></tr>
</table>

配置文件中选项 `port`，`uid`，`gid`，`umask` 和 `sockmode` 支持十六进制（`0x..`），八进制（`0..`）和十进制设置。其他的配置项和命令行选项只支持十进制。

`uid`，`gid`，`umask` 和 `chroot` 只在 Linux 和 Unix 受支持。如果配置了其中的选项，当 Rserve 以 `root` 用户启动时，在真正启动 Rserve 之前，将首先切换 `user/gorup` 为声明的 `uid/gid`。且，这些选项生效的顺序跟在配置文件中配置的顺序一致。如，假设同时配置了 `uid` 和 `gid`，则**必须**先声明 `gid`，否则如果先声明 `uid`，用户可能没有权限修改 `gid`。而且 `chroot` 必须在 `uid` 之前，因为只有 `root` 可以使用它。除非必要，不比设置这些选项。

命令行中的其他关键参数；

 - `--help` 列出所有支持的参数。
 - `--RS-conf <file>` 加载指定的配置文件，如有重合将会覆盖默认配置中的选项。
 - `--RS-settings` 输出 Rserve 的当前设置。
 - `--verison` 输出 Rserve 的版本。

#### 3.5 Rserve 实践

##### 3.5.1 Rserve 启动总结

一般会在内网环境下使用 Rserve，除了 `remote`，Rserve 的默认配置足以满足应用场景，本人关于 Rserve 的调优实践不多。

启用 Rserve 远程连接支持的方法 1，编辑 `/etc/Rserv.conf`，加入 `remote enable`，如：

	# /etc/Rserv.conf
	remote enable
	port 6311
	
启用 Rserve 远程连接支持的方法 2，命令行参数中指定，如：

	R CMD Rserve --RS-enable-remote

启动后还涉及到一些简单的进程管理，Rserve 以进程方式提供服务，主进程一般为 500M，而后每个新的连接都会对应生成一个新的进程，每个连接进程约为 250M。注意，当客户端意外关闭时，可能导致 Rserve 连接进程无法正常关闭，因此需要手动重启 Rserve 以释放内存空间。 

	# 查看当前所有 Rserve 进程
	ps aux | grep Rserve	

	# 正常关闭 Rserve 进程
	killall -15 Rserve

至此，Rserve 的基本使用介绍完毕。为了便于操作，将配置、启动、查看、关闭和重启总结为如下 bash 文件 `Rserve.sh`，并放入 `/etc/profile.d` 下：

	#!/bin/bash
	# setting for R Rserve package
	# mainly used for managing Rserve process more conveniently
	#
	alias R_Rserve='R CMD Rserve --RS-enable-remote'
	alias greprserve='ps aux | grep Rserve'
	alias k15rserve='killall -15 Rserve'
	alias R_Rserve_restart='killall -15 Rserve && R_Rserve'

使之生效后，便可以 `alias` 出的命令进行便捷操作。

 > 注：系统防火墙应放行此端口，通过 `iptables`，`firewall-cmd` 或关闭防火墙。

##### 3.5.2 Rserve 服务端临时目录清理

Rserve 的临时工作目录，默认为 `/tmp/Rserv`，当客户端创建连接时，会伴随在其下生成临时 `connXXXX` 目录，已验证可直接删除，不会影响连接的正常使用。除 `connXXXX` 之外，R 脚本执行的过程中，可能还会有临时文件生成在 `/tmp/Rserv` 下，因而定期清理是有必要的。配置 `crontab` 每天执行清理操作：

	13 4 * * * rm -rf /tmp/Rserv/*

 > 建议客户端编码时，如用到服务端临时工作目录，也将工作目录设置与 Rserve 的临时目录一致，可以一起清理。
 >
 > 根据 Rserve 的调用情况，如果 Rserve 调用很频繁，可以配置 `crontab` 执行更频繁的清理。
 >
 > **注意：清理可能会触发临界点 bug，比如 Rserve 生成临时文件后，还未等 client 读取该文件就被删除。**

### 4. Rserve Java client

Rserve Java client 实现已被发布到 maven repo 中，可用版本参见 [Maven Repository: org.rosuda.REngine » Rserve](https://mvnrepository.com/artifact/org.rosuda.REngine/Rserve)，也可从[官网](https://www.rforge.net/Rserve/files/)下载较新的二进制版本。

具体使用 Rserve Java client 进行开发的方式不在本文描述，可参见[example](https://www.rforge.net/Rserve/example.html)。

**参考：**

 - [https://fedoraproject.org/wiki/EPEL/FAQ#How_can_I_install_the_packages_from_the_EPEL_software_repository.3F](https://fedoraproject.org/wiki/EPEL/FAQ#How_can_I_install_the_packages_from_the_EPEL_software_repository.3F)
 - [https://mirrors.tuna.tsinghua.edu.cn/help/epel/](https://mirrors.tuna.tsinghua.edu.cn/help/epel/)
 - [https://www.rforge.net/Rserve/doc.html](https://www.rforge.net/Rserve/doc.html)
