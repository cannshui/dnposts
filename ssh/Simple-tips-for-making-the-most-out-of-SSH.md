## 常用 SSH tip

跟很多其他开发人员一样，我发现自己几乎每天使用 ssh。这篇博客不会涉及到用 ssh 实现的高端操作，而只描述一些简单技巧。你可能希望自己上手 ssh 的时候，就知道这些简单技巧。

### 1. 在 ssh config 文件中为连接设置别名

你是否在意，每次建立一个连接时都需输入完整 ssh 配置？

	$ ssh dev@dev.hostname.com
	$ ssh -i ~/Documents/keys/myKey.pem ec2-user@64.92.157.36

利用 ssh config 文件为你的各种 ssh 连接创建别名。配置上面的连接，你可以添加如下片段到 `~/.ssh/config` 文件中（译注：config 文件可能还不存在，直接创建它即可）：

	Host dev 
		HostName dev.hostname.com
		User dev
	
	Host aws
		HostName 64.92.157.36
		User ec2-user
		IdentityFile ~/Documents/keys/myKey.pem

现在，你能以更加简洁的方式连接到服务器：

	$ ssh dev
	$ ssh aws

[ssh config 进阶用法，参见这里。](http://www.cyberciti.biz/faq/create-ssh-config-file-on-linux-unix/)

### 2. 设置无需密码的 ssh

你是否在意，每次建立一个 ssh 连接时都输入密码？你可以让远端服务器通过 ssh key 识别到你，而无需每次输入密码。为了实现这个效果，你必须追加你的本地 public key（取自本地 `~/.ssh`）到你期望连入的服务器上的 `~/.ssh/authorized_keys` 文件中。你可以通过如下命令实现追加：

	$ cat ~/.ssh/id_rsa.pub | ssh myUser@remoteHost.com '>> .ssh/authorized_keys'

译注：上述命令执行后，好像并不能拷贝 ssh key 到服务器上，查看博客一楼和三楼评论，并尝试后，发现上面少了 `cat` 命令，完整应该如下：

	cat ~/.ssh/id_rsa.pub | ssh myUser@remoteHost.com 'cat >> .ssh/authorized_keys'

	# 还有以下两种等效方式
	ssh myUser@remoteHost.com 'cat >> .ssh/authorized_keys' < cat ~/.ssh/id_rsa.pub

	# ssh 内建工具，有些场景下没有提供
	ssh-copy-id myUser@remoteHost.com

现在你再也不需要在登录远端服务器时输入密码了。[如果你遇到了麻烦，参看这里。](http://www.tecmint.com/ssh-passwordless-login-using-ssh-keygen-in-5-easy-steps/)

### 3. 使用 screen 保持 SSH 会话

你是否在意，ssh 会话甚至你的当前工作由于网络问题而中断？一种简单解决方案是在 screen 中运行你的 ssh 会话，由它独立开 ssh 连接来保持 shell 会话，并允许你在连接突然断开时重连到 shell 会话。

使用下面的 screen 命令在远端服务器上创建命名 shell 会话：

	screen -S 'mySession'

使用下面的 screen 命令在远端服务器上重连到你的 shell 会话，如果连接断掉的话：

	screen -r 'mySession'

或使用下面的命令重连到你的 shell 会话，并断连其他的客户端（有时很有用，如，你正通过的 work 电脑连入，而现在你想从 home 电脑连入）：

	screen -rd 'mySession'

如你所猜想的那样，通过 screen 你可以从一台机器启动一个远端 shell 会话，然后通过另一台机器重连。或者，你可以有一个存在多天的 shell 会话，而你只在需要时才重连到它。

使用 screen 也可以在远端服务器上保持持续运行的进程，然后你可以随时连入。比如，我自己通过这种方式运行 node.js 应用；这样，我可以很易于在发生问题时重连到 screen 会话，并可以在 console 上看到发生的错误，同样也很易于从 git pull 更新或重启 node 进程。

译注：扩展阅读，[linux 技巧：使用 screen 管理你的远程会话](http://www.ibm.com/developerworks/cn/linux/l-cn-screen/)。

### 4. 连入并执行一条命令

假如你需要在远端服务器上运行一条命令，而不关心是否有全功能 shell，你可以简单追加打算执行的命令到 ssh 连接后面。比如，如果我只打算重启远端服务器上的 nginx，我只需要下面的命令（注意你可以在 config 别名后使用任何其他的 ssh 选项）： 

	ssh dev sudo service nginx restart

然而，如果你需要执行的命令是交互式的（如文本编辑器 vim，nano，或 shell 解释器如 bash，mongo，等），你可以使用 `-t` 选项告诉 ssh 模拟一个 tty 终端。这将带给你超乎想象的方便；比如你打算直接连入你服务器的 mongo shell，你可以使用如下命令：

	ssh dev -t mongo myDatabase

再比如你打算连到服务器，并快速编辑一个配置文件：

	ssh dev -t screen -rd mySession

### 5. 从 ssh 会话强制断连

有时网络问题引起 ssh 断连，但是客户端没有意识到管道已经断开，导致现在 shell 无响应。或者有时你只是想强制断连 ssh 连接。实现这个效果，依次点击 `[enter] ~.`。这将会发送转义序列给 ssh 客户端，让它立即结束连接。

译注：依次点击 `[enter] ~.`，指 `Enter`（回车），`~`（``Shift + ` ``），`.`（英文点号）。

### 6. 使用 SSH 隧道在本地访问远端服务器内部服务

假如你想使用测试工具如 [Postman](https://chrome.google.com/webstore/detail/postman-rest-client/fdmmgilgnpjigdojojpjoooidkmcomcm?hl=en) 来测试或调试运行在远端服务器上的内部服务，但出于安全考虑你不想将它暴露为公共服务。你可以使用 ssh 隧道转发服务到一个本地端口；假如服务运行在 `myhostname:8080` 上，下面是你如何转发它到 localhost 上的 3000 端口（感谢 Chris Sims 指出实现这种效果的最好方式，阅读[这里](https://jcsi.ms/posts/ssh-port-forwarding/)的博客）：

	ssh myuser@myhostname.com -NL 3000:myhostname.com:8080

现在你可以使用 Postman 发送请求给 `localhost:3000`，然后将会通过加密的 ssh 连接转发到 `myhostname:8080`。

隧道是 ssh 中最酷特性之一，它甚至是许多应用使用 ssh 的一个原因，你可以参见[这里](http://www.cyberciti.biz/faq/set-up-ssh-tunneling-on-a-linux-unix-bsd-server-to-bypass-nat/)或[这里](http://blog.trackets.com/2014/05/17/ssh-tunnel-local-and-remote-port-forwarding-explained-with-examples.html)，了解更多内容。

 > **原文：**[Simple tips for making the most out of SSH](http://felixmilea.com/2015/06/simple-tips-for-making-the-most-out-of-ssh/)