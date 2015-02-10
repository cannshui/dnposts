## <center>Git FAQ.</center>


##### 推送本地分支到库（push local branch to remote repo）

通用方式：

	git checkout -b <target-branch>
	git push <remote-repo> <target-branch>:<target-branch>



##### 检出远程分支（checkout a remote branch）

如果 Git version 在 1.6.6 以上。可以按照如下方式操作：

	git fetch
	git checkout target_branch



