## CentOS 6 基于 R Markdown 渲染 PDF 的环境安装

[R Markdown](http://rmarkdown.rstudio.com/index.html) 为 [RStudio](https://www.rstudio.com/) 旗下的产品。项目中基于 R Markdown 渲染 PDF 报告。这种 PDF 渲染方案除了必须的 R 语言之外，还需额外的软件支持，主要为 texlive 和 pandoc。以下为环境安装的过程记录。

 > 注1：安装时为了方便，切换到 root 用户，避免一直输入 sudo。
 > 
 > 注2：文中“当前”指此文编写时的日期，为 2018-01-15。

### 1. 安装 texlive 2017

CentOS 6 中自带的或是 yum repo 中已有的 texlive 为 2007 版本，太过陈旧，R Markdown 在渲染 PDF 时不可用。需要先移除：

	注：移除旧版本 texlive
	# yum remove texlive

最新版的 texlive 安装方式多样，见 [TeX Live - TeX Users Group](http://www.tug.org/texlive/)。为了简单，选择通过 iso 安装。

	注：从清华镜像站获取 texlive 2017 镜像，如失败可使用 wget -c 选项断点续传下载
	# wget https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/Images/texlive2017.iso

以 loop 模式挂载 iso 文件后即可进行访问：

	# mkdir /mnt/tl
	# mount -o loop /path/to/texlive2017.iso /mnt/tl
	注：进入挂载后的目录
	# cd /mnt/tl
	注：ls 后将会看到 install-tl 脚本
	# ls -l

值得一提之处，texlive 默认将安装于 `/usr/local/texlive`。不同版本可并存，如 2017 版本，默认会安装于 `/usr/local/texlive/2017`。一般主要基于磁盘空间的考虑，需要更改安装路径，**否则建议采用默认安装路径**。更换默认安装路径见 [The TeX Live Guide - 2017 #3.2.3 Directories](http://www.tug.org/texlive/doc/texlive-en/texlive-en.html#x1-260003.2.3)，此处采用预设 `TEXLIVE_INSTALL_PREFIX` 环境变量的方式。

	注：别忘记 export，且 /disk2/zkgd/texlive 需已存在
	# export TEXLIVE_INSTALL_PREFIX=/disk2/zkgd/texlive
	# ./install-tl

看到如下的输入表示设置默认安装目录成功。如发现非预期结果，可能是因为未带 export 或目录不存在或权限不足等，请对照解决。

	<D> set directories:
	   TEXDIR (the main TeX directory):
	     /disk2/zkgd/texlive/2017
	   TEXMFLOCAL (directory for site-wide local files):
	     /disk2/zkgd/texlive/texmf-local
	   TEXMFSYSVAR (directory for variable and automatically generated data):
	     /disk2/zkgd/texlive/2017/texmf-var
	   TEXMFSYSCONFIG (directory for local config):
	     /disk2/zkgd/texlive/2017/texmf-config
	   TEXMFVAR (personal directory for variable and automatically generated data):
	     ~/.texlive2017/texmf-var
	   TEXMFCONFIG (personal directory for local config):
	     ~/.texlive2017/texmf-config
	   TEXMFHOME (directory for user-specific files):
	     ~/texmf

默认即为全安装模式，**建议如此**，`Enter command:` 后输入 `I` 启动安装。等待安装完成。安装完成后将会看到如下输出（只展示部分）：

	 ----------------------------------------------------------------------
		...
	    TEXLIVE_INSTALL_PREFIX=/disk2/zkgd/texlive
	 ----------------------------------------------------------------------
	
	Welcome to TeX Live!
	
	Documentation links: /disk2/zkgd/texlive/2017/index.html
	...
	
	Add /disk2/zkgd/texlive/2017/texmf-dist/doc/man to MANPATH.
	Add /disk2/zkgd/texlive/2017/texmf-dist/doc/info to INFOPATH.
	Most importantly, add /disk2/zkgd/texlive/2017/bin/x86_64-linux
	to your PATH for current and future sessions.
	
	Logfile: /disk2/zkgd/texlive/2017/install-tl.log

安装完成后，需要设置环境变量见 [The TeX Live Guide - 2017 #3.4.1 Environment variables for Unix](http://www.tug.org/texlive/doc/texlive-en/texlive-en.html#x1-310003.4.1)，包括 PATH，man 和 info 相关。环境变量的设置方式很多，为了便于管理，建议在 `/etc/profile.d` 下新建 `texlive.sh`，文件内容如下：

	#!/bin/bash
	# setting env vars, see: http://www.tug.org/texlive/doc/texlive-en/texlive-en.html#x1-310003.4.1
	export PATH=/disk2/zkgd/texlive/2017/bin/x86_64-linux:$PATH
	export MANPATH=/disk2/zkgd/texlive/2017/texmf-dist/doc/man:$MANPATH
	export INFOPATH=/disk2/zkgd/texlive/2017/texmf-dist/doc/info:$INFOPATH

使 `texlive.sh` 中设置立即生效，执行：

	# . /etc/profile.d/texlive.sh

也可注销用户，重新登录。生效后，`tex --version` 将会输出 texlive 版本信息，而非 `bash: tex: command not found`。

现在完成了 texlive 2017 的安装。可用一些简单脚本测试 `tex`，`xelatex` 命令是否可正常使用。不在赘述。

### 2. 安装 pandoc

pandoc 是 R Markdown 包渲染 PDF 时必须的支持软件。yum repo 中虽有，但 yum 安装后，无法被 R Markdown 正确使用，报错很**离奇**，尝试搜索原因和解决方案，结果失败。

 > 注：Ubuntu 15 中无此问题，apt-get 安装后可正常使用。

#### 2.1 正常安装

**不采用 yum 安装，直接下载官方编译好的 pandoc，经测试可正常使用。**见 [Pandoc - Installing pandoc](http://www.pandoc.org/installing.html)。如，当前前最新版本为 pandoc-2.1.1-linux.tar.gz，将其解压到 `/disk2/zkgd`，此时可见 `/disk2/zkgd/pandoc-2.1.1/bin` 下存在 `pandoc` 和 `pandoc-citeproc` 两个可执行文件。为了使得 pandoc 对于 R 可见，有两种方式：

 1. 将 `pandoc` 命令加入全局 PATH 变量。
 2. 设置全局 `RSTUDIO_PANDOC` 变量指向 pandoc bin 目录。

无论哪种方式，皆建议设置到 `/etc/profile.d/pandoc.sh` 文件中，生效方式同上述 `texlive.sh`。`pandoc.sh` 内容如下：

	#!/bin/bash
	# setting env var for pandoc
	#
	# if you just want pandoc used by R. **here, I prefer this**
	export RSTUDIO_PANDOC=/disk2/zkgd/pandoc-2.1.1/bin
	# if you or other users or other softs also need `pandoc`, **uncomment follow**
	# export PATH=$PATH:/disk2/zkgd/pandoc-2.1.1/bin

输入 `/disk2/zkgd/pandoc-2.1.1/bin/pandoc -v`，将会输出 pandoc 版本信息，而非 `bash: pandoc: command not found`。

#### 2.2 意外

#### 2.2.1 pandoc 2.x

虽然 pandoc 已经发展到 2.0 以上，但当前 R Markdown 稳定兼容的还是 2.0 以下。2.0 以上会出现问题，比如在使用 `htmlwidgets` 包的 `saveWidget(sapmle, "xxxxx.html", selfcontained = TRUE)` 将 `sample` 对象导出成自包含的 html 文件时，头部会多有文本 `&lt;!DOCTYPE html&gt;`，此 bug 可参见以下两个描述 [https://github.com/rstudio/rmarkdown/issues/1200](https://github.com/rstudio/rmarkdown/issues/1200)，[https://github.com/ramnathv/htmlwidgets/issues/289](https://github.com/ramnathv/htmlwidgets/issues/289)。而 2.0 以下会正确解释成 `<!DOCTYPE html>` 这个声明标签，也就不会做为普通文本显示了。

#### 2.2.2 自编译失败

2.0 以下的 Linux 可执行 pandoc 版本无法从 releases 页面下载到，需要自己编译。参见 [Pandoc - Installing pandoc](http://www.pandoc.org/installing.html) **Compiling from source** 小节。两种方式我皆失败，也许是受到**科学上网**的限制。

#### 2.3 从 RStudio 获取

作为对 R Markdown 的支持，RStudio 下已带有编译后的 pandoc。RStudio 下载安装见 [https://www.rstudio.com/products/rstudio/download-server/](https://www.rstudio.com/products/rstudio/download-server/)，当前版本为 1.1.419。CentOS 6 下安装后，会存在 `/usr/lib/rstudio-server/bin/pandoc` 目录，其下的 `pandoc` 版本为 1.19.2.1。**已验证可正常使用。可将 pandoc 目录单独取出、备份，用于以后的环境安装，而不必总是安装 RStudio。**

### 3. 安装 R 3.4.3

当前 CentOS 6.5 yum repo 中已有的 R 版本为 3.4.3，是可用的新版本。通过 yum 安装时，会发现依赖一些 2007 版本的 texlive 相关软件包，安装即可，已验证不会跟已安装的 texlive 2017 冲突。

	# yum install R

安装完成后，输入 `R` 将会进入 R 的命令交互模式，说明安装成功。在其中安装 R Markdown 包，输入：

	> install.packages('rmarkdown')

等待 `rmarkdown` 插件安装完成。至此，基于 R Markdown 渲染 PDF 的环境已安装完成。

### 4. 思考

从上可以看出 R Markdown 生成 PDF 的方案，依赖的环境还是非常笨重的。项目为 Java Web 应用，这种方案在生产环境中不算合适，以下为我的思考：

优点：

 1. R Markdown 本身的语法非常简单，易上手。
 2. R Markdown 为 Markdown 加入 R 语言的支持，扩大了 Markdown 的边界。
 3. 语法简单意味着可以快速生成和修改简单的脚本，用于快速交付效果。
 4. 支持直接内嵌 latex 指令。因为本质上 R Markdown 将首先被解释成 latex 脚本。

缺点：

 1. 依赖环境非常笨重，为了生成 PDF 竟然需要如此庞大的软件的支持。
 2. 学习曲线初平后陡，简单的 markdown 语法几乎不可能满足生产环境中的报告需求。需要依赖 R 语言，或是直接内嵌 latex 指令，因而对 R 语言和 latex 的学习是必须的。
 3. 默认模板虽然效果不错，但是生产环境中的报告需求很复杂，对默认模板的修改无可避免。修改默认模板需要比较深的 latex 知识，难度较高。
 4. 性能考虑，R Markdown 脚本到目标 PDF 之间存在着文件转化，如从 rmd 先到 tex，再从 tex 到 PDF，且伴随生成还有其他中间文件，这都会带来性能和空间资源的浪费。（BUT: premature optimization is the root of all evil.）

对于 Java Web 应用，生产环境还是优先考虑采用 Java 中渲染 PDF 的解决方案，虽然上手较难，但是总体来看绝对比 R Markdown 学习成本低（毕竟，Java 中 PDF 渲染只是一个组件，而 R Markdown 背靠着 R 和 latex），而且组件掌握后将可灵活应对繁杂的报告需求（存疑？）。

**AGAIN： R Markdown 很“理想”，想随心所欲的使用，必须深入学习 R 语言和 latex。**