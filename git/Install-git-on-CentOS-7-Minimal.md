CentOS 7 Minimal 上的 git 安装
=============================

在个人桌面虚拟机软件（如 VirtualBox）或是云平台上的虚拟机，我通常使用 CentOS 7 Minimal 系统。系统自带有一个版本比较老的 git-1.8，使用体验上与新版本相差甚远。所以这里会记录下如何替换/安装比较新的版本。

### 1. 从源码编译安装

当前最新版本总是可以从源码编译安装。下面的 bash 脚本，可以实现移除旧版本的 git，并安装最新的版本，截至文章当前日期（2021-05-08）版本为 `2.31.1`。在不提供给脚本一个版本参数时，会默认安装 `2.31.1`。

```bash
#!/bin/bash
#
# Install git from source.
#
# Arguments:
#     $1: git version number, eg: 2.31.1


set -o pipefail
set -o errtrace

# check if git already exists
if [ -x "$(command -v git)" ]; then
    git_version_tmp=$(git --version)
    if [[ ${git_version_tmp} == *" 1."* ]]; then
        echo Remove legacy ${git_version_tmp} firstly
        yum remove -y git
    elif [[ ${git_version_tmp} == *" 2."* ]]; then
        echo ${git_version_tmp} already installed
        exit 0
    else
        echo Unknow, nothing to do
        exit 0
    fi
fi

GIT_VERSION=2.31.1

if [ "$1" != "" ]; then
    GIT_VERSION=$1
fi

set -o nounset

echo Work in dir /opt/git
mkdir -p /opt/git
cd /opt/git

yum install -y gcc autoconf curl-devel openssl-devel zlib-devel bash-completion

if [ ! -f git-${GIT_VERSION}.tar.xz ]; then
    curl -LO https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.xz
    echo git-${GIT_VERSION}.tar.xz was downloaded in /opt/git
fi

tar -xf git-${GIT_VERSION}.tar.xz
pushd git-${GIT_VERSION} > /dev/null
make configure
./configure --prefix=/usr
make all
make install

tee /etc/profile.d/git.sh <<-'EOF'
# git aliases
alias gs='git status'
alias gd='git diff'
alias gc='git checkout'
alias gb='git branch -va'
alias gps='git push'
alias gpl='git pull'
alias gl='git log'
alias glp='git log --pretty=format:"%h %s" --graph'
alias grprune='git remote prune origin'
alias gcmail='git config user.email'
alias gcname='git config user.name'
EOF

cp contrib/completion/git-completion.bash /etc/bash_completion.d/

popd > /dev/null
# clean temp work dir
rm -rf git-${GIT_VERSION}

echo $(git --version) installed
```

这个脚本也可从 [dnposts git-install.sh](https://github.com/cannshui/dnposts/blob/master/git/git-install.sh) 获取到。使用时，可以不提供参数直接执行，会安装默认的 `2.31.1` 版本：

    ./git-install.sh

或者显式指定一个版本号，如：

    ./git-install.sh 2.31.1

> 注：
> 这里没有安装 doc、html、info，如需安装，需要先安装其他一些依赖，参见[官方文档](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)：
> `make install install-doc install-html install-info`

### 2. 从第三方 yum 源安装

从源码编译安装需要预先安装一些依赖，这通常不是问题，不过“强迫症”可能更希望不安装这些编译期的工具。下面记录从两个可用的第三方 yum 源安装 git。

#### 2.1 IUS Community Project

[IUS Community Project](https://ius.io/) 是[官方推荐](https://git-scm.com/download/linux)的一个源，安装方式：

    yum install https://repo.ius.io/ius-release-el7.rpm

可以从 [https://repo.ius.io/7/x86_64/packages/g/](https://repo.ius.io/7/x86_64/packages/g/) 查看当前比较新的 git 版本。如当前比较新为 git224，通过 yum 直接安装：

    yum install git224

#### 2.2 End Point Software Package Repositories

[End Point Software Package Repositories](https://packages.endpoint.com/) 也是一个不错的三方源，安装方式：

    yum install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.9-1.x86_64.rpm

相比 IUS，这个源中的 git 没有特殊命名。通过 yum 直接安装：

    yum install git

### 3. 总结

 - 从源码编译比较自由，总是可以使用最新版本的 git，而第三方源中通常会稍微落后一些。
 - 第三方源中的包便于管理，在可维护性上比如卸载、升级会更加方便。
 - 第三方源的 repo rpm 会升级，在使用时最好从官网获取。

**你倾向于哪一种？**

--------

**参考：**

 - [1.5 Getting Started - Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
 - [Download for Linux and Unix](https://git-scm.com/download/linux)
 - [IUS - Setup](https://ius.io/setup)
 - [End Point Software Package Repositories](https://packages.endpoint.com/)
