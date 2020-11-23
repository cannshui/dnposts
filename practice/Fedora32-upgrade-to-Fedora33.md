## Fedora 32 升级到 Fedora 33

2020-11-16 把 Fedora 32 升级到了 Fedora 33（2020-10-27 发布）。升级后，遇到了两个主要问题，记录如下。

### 1. Fedora 32 上安装的 VirtualBox 不见了

只好重新安装。官网上暂时没有提供 Fedora 33 版本的 rpm 包下载，只好下载 Fedora 32 的 VirtualBox-6.1-6.1.16_140961_fedora32-1.x86_64.rpm。

通过 `sudo rpm -ivh VirtualBox-6.1-6.1.16_140961_fedora32-1.x86_64.rpm` 安装时，遇到报错：

    warning: VirtualBox-6.1-6.1.16_140961_fedora32-1.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 98ab5139: NOKEY
    error: Failed dependencies:
    	python(abi) = 3.8 is needed by VirtualBox-6.1-6.1.16_140961_fedora32-1.x86_64

这个比较好查到，在这个问题 [https://www.virtualbox.org/ticket/19989](https://www.virtualbox.org/ticket/19989) 中重现和解决。

原因是 Fedora 33 上的 Python3 版本升级到了 3.9，不满足安装的前提条件。

**解决方案 1：**

用 run 脚本来安装（当初在 Fedora 32 上以这种形式安装），可从 [https://download.virtualbox.org/virtualbox/6.1.16/](https://download.virtualbox.org/virtualbox/6.1.16/) 下载 VirtualBox-6.1.16-140961-Linux_amd64.run 文件。

**解决方案 2：**

安装 rpmrebuild 软件，修改 rpm 包的 spec 文件中的 Python 版本。

`sudo dnf install rpmrebuild`

`rpmrebuild --edit-spec --package VirtualBox-6.1-6.1.16_140961_fedora32-1.x86_64.rpm`

修改 `Requires:      python(abi) = 3.8` 为 `Requires:      python(abi) >= 3.8` 保存后，会在用户的家目录下生成修改后的 rpm 文件，此处为 `~/rpmbuild/RPMS/x86_64/VirtualBox-6.1-6.1.16_140961_fedora32-1.x86_64.rpm`，安装这个新包即可。

### 2. git 无法通过 ssh 访问 gitlab 和 gerrit 系统

在项目目录执行与远程系统交互的命令时出错，比如 `git pull`，出错信息： 

    Unable to negotiate with 172.16.30.17 port 29418: no matching key exchange method found. Their offer: diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
    fatal: Could not read from remote repository.
    
    Please make sure you have the correct access rights
    and the repository exists.

参考问题 [https://bugzilla.redhat.com/show_bug.cgi?id=1881301](https://bugzilla.redhat.com/show_bug.cgi?id=1881301) 和 [http://www.poweradded.net/2020/11/after-upgrade-to-fedora33-ssh-no-longer.html](http://www.poweradded.net/2020/11/after-upgrade-to-fedora33-ssh-no-longer.html) 得以解决。

原因是 Fedora 33 中 OpenSSH 升级到了 8.4p1-2，默认不支持旧版本不安全的算法，在无法升级服务端 OpenSSH 的情况下需要在客户端配置支持。

**解决方案：**

在用户的 `~/.ssh/config` 中，添加如下信息：

    Host *
        KexAlgorithms +diffie-hellman-group1-sha1
        Ciphers +aes256-cbc
        PubkeyAcceptedKeyTypes +ssh-rsa

`*` 表示应用这个规则到所有的 `host`。如果只想应用到某一个 `host`，可以修改 `*` 为实际 `host` 的 IP 或者 `hostname`，如

    Host gerrit.dunnen.top
        KexAlgorithms +diffie-hellman-group1-sha1
        Ciphers +aes256-cbc
        PubkeyAcceptedKeyTypes +ssh-rsa

**思考：**

1. 你遇到的所谓问题，已有别人遇到过并且有了解决方案，善用搜索是个技术活。
2. 水平不足的情况下，“尝鲜”是个危险的操作。
