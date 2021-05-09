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
