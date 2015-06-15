## <center>My Git FAQ.</center>

#### 安装 Git

CentOS 下，如果已经安装了 Git，并且版本比较低，可以首先进行移除：

	yum remove git

获取最新 Git 源码并解压：

	wget https://www.kernel.org/pub/software/scm/git/git-2.4.3.tar.gz
	tar -xvf git-2.4.3.tar.gz

安装 Git：

	cd git-2.4.3
	make configure
	./configure --prefix=/usr/local/git
	make all
	make install
	echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc
	source /etc/bashrc

安装后进行自更新：

	git clone git://git.kernel.org/pub/scm/git/git.git

#### 创建远端分支及检出

创建远端分支：

	cd /path/to/git/repo
	git init --bare my-project.git

可以根据不同的协议检出远端服务器器上的 repo，例如 ssh 方式（注意路径的起始为 `user` 家目录）：

	git clone ssh://user@server-host/path/to/git/repo/my-project.git

以简短的 scp 风格：

	git clone user@server-host:path/to/git/repo/my-project.git

如果在 `~/.ssh/config` 中设置了 ssh 连接别名的话，可以直接使用别名：

	git clone ssh-alias:path/to/git/repo/my-project.git

#### 推送本地分支到库（push local branch to remote repo）

通用方式，将本地分支推送至某远端分支：

	git checkout -b <target-branch>
	git push <remote-repo> <local-target-branch>:<remote-target-branch>

如果 `<remote-repo>` 后只声明了一个 `<target-branch>`，那么这表示 `<local-target-branch>` 和 `<remote-target-branch>` 是一样的，同为 `<target-branch>`。

 > **注意**
 > 
 > 1. 加上 `-f` 或 `--force` 选项将会强制推送本地分支到远程分支，**覆盖**冲突。
 > 2. 如果省略掉 `<local-target-branch>` 而直接是 `git push <remote-repo> :<remote-target-branch>`，这将会**删除**远端分支 `<remote-target-branch>`。

#### 检出远程分支（checkout a remote branch）

如果 Git version 在 1.6.6 以上。可以按照如下方式操作：

	git fetch <remote-name>
	git checkout <target-branch>

如果省略 `<remote-name>` 则默认为 `origin`，当有多个 `remote` 的时候最好也声明 `<remote-name>`，因为你应该检出的是特定 `remote` 上的 `branch`。

用下面的命令查看所有本地分支和 `remote` 分支：

	git branch -v -a


