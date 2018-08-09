## <center>My Git FAQ.</center>

### 安装 Git（On CentOS）

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
	echo 'export PATH=$PATH:/usr/local/git/bin' >> /etc/bashrc
	source /etc/bashrc

安装后进行自更新（Hadn't tried.）：

	git clone git://git.kernel.org/pub/scm/git/git.git

Windows 下可到 [https://git-scm.com/](https://git-scm.com/) 下载。

### 源代码换行设定

安装完毕 git 之后，最好统一设置源码的**换行**规则。

	git config [--global] core.autocrlf [true|input|false]

带有 `--global` 选项表示这项设置对全局工程生效，不带则只是对当前工程生效。`core.autocrlf` 有三种值可选：

 - `true`，提交时采用 Unix 换行风格（LF `\n`），检出采用 Win 换行风格（CRLF `\r\n`）。对于跨平台的项目，Win 上推荐这种设置。
 - `input`，提交时采用 Unix 换行风格（LF `\n`），检出时不做转化。对于跨平台的项目，Unix/Linux 上推荐这种设置。
 - `false`，提交时不做转化，检出时也不做转化。跨平台的项目不推荐这种设置。

 > eclipse 中 EGit 插件做代码比较时，如果未做 `git config --global core.autocrlf` 的设置操作，将可能出现由于**换行规则不统一**而达不到预期效果。

### 创建远端仓库及检出

创建远端仓库：

	cd /path/to/git/repo
	git init --bare my-project.git

可以根据不同的协议检出远端服务器器上的 repo，例如 ssh 方式（注意路径的起始为 `user` 家目录）：

	git clone ssh://user@server-host/path/to/git/repo/my-project.git

以简短的 scp 风格：

	git clone user@server-host:path/to/git/repo/my-project.git

如果在 `~/.ssh/config` 中设置了 ssh 连接别名的话，可以直接使用别名：

	git clone ssh-alias:path/to/git/repo/my-project.git

### 推送本地分支到库（push local branch to remote repo）

通用方式，将本地分支推送至某远端分支：

	git checkout -b <target-branch>
	git push <remote-repo> <local-target-branch>:<remote-target-branch>

如果 `<remote-repo>` 后只声明了一个 `<target-branch>`，那么这表示 `<local-target-branch>` 和 `<remote-target-branch>` 是一样的，同为 `<target-branch>`。

 > **注意**
 > 
 > 1. 加上 `-f` 或 `--force` 选项将会强制推送本地分支到远程分支，**覆盖**冲突。
 > 2. 如果省略掉 `<local-target-branch>` 而直接是 `git push <remote-repo> :<remote-target-branch>`，这将会**删除**远端分支 `<remote-target-branch>`。

### 检出远程分支（checkout a remote branch）

如果 Git version 在 1.6.6 以上。可以按照如下方式操作：

	git fetch <remote-name>
	git checkout <target-branch>

如果省略 `<remote-name>` 则默认为 `origin`，当有多个 `remote` 的时候最好也声明 `<remote-name>`，因为你应该检出的是特定 `remote` 上的 `branch`。

用下面的命令查看所有本地分支和 `remote` 分支：

	git branch -v -a

### ignore 已提交文件

	git rm --cached [-r] /path/to/file

执行后，被移除文件处于 `deleted` 状态，再进行一次 commit 和 push 操作，可将文件从 repo 中移除。

### 修改最后一次提交的 commit 信息

	git commit --amend

如果已 push 到远程，则需再次强制 push

	git push -f <remote-repo> <target-branch>