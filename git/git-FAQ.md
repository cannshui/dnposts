## <center>My Git FAQ.</center>


##### 推送本地分支到库（push local branch to remote repo）

通用方式，将本地分支推送至某远端分支：

	git checkout -b <target-branch>
	git push <remote-repo> <local-target-branch>:<remote-target-branch>

如果 `<remote-repo>` 后只声明了一个 `<target-branch>`，那么这表示 `<local-target-branch>` 和 `<remote-target-branch>` 是一样的，同为 `<target-branch>`。

**注意**：如果省略掉 `<local-target-branch>` 而直接是 `git push <remote-repo> :<remote-target-branch>`，这将会**删除**远端分支 `<remote-target-branch>`。

##### 检出远程分支（checkout a remote branch）

如果 Git version 在 1.6.6 以上。可以按照如下方式操作：

	git fetch <remote-name>
	git checkout <target-branch>

如果省略 `<remote-name>` 则默认为 `origin`，当有多个 `remote` 的时候最好也声明 `<remote-name>`，因为你应该检出的是特定 `remote` 上的 `branch`。

用下面的命令查看所有本地分支和 `remote` 分支：

	git branch -v -a


