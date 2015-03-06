## Subversive 安装教程

这是一篇教程，关于如何通过不同的方式安装 Subversive 的 Subversive 软件包。

### 说明

Subversive 的安装由 Subversive 插件（Subversive plug-in）和 Subversive SVN 连接器（Subversive SVN Connectors）的安装两部分组成。Subversive 插件作为 Eclipse 官方项目开发（EPL 版权），并通过 Eclipse web 站点分发。Subversive SVN 连接器是 SVN 库，用作 Subversive 与 SVN 库交互。这些库都是作为开源项目开发的，但由于它们所用的版权不是 EPL-兼容的，所以它们必须在外部网站分发。

为了使用 Subversive，你需要安装 Subversive 插件和至少一个跟你的系统和所用 SVN 版本兼容的 Subversive SVN 连接器。Subversive 插件包含对可用 Subversive SVN 连接器的引用，所以在安装完 Subversive 插件之后，会自动提示你安装一或多个连接器。

### 第一步 安装 Subversive 插件

下面，你将看到如何通过不同类型的 Subversive 发行版安装 Subversive 插件。

##### 第一种 通过 Eclipse 即时版本更新点安装

这种方法很值得推荐，如果你希望安装一个稳定版本的 Subversive，并将它作为 Eclipse 即时版本整体中的一部分。它允许你通过 Eclipse 更新点为一个即时版本的 Eclipse 安装 Subversive 插件。

 - 运行 Eclipse，从主菜单选择 **Help > Install New Software...**。
 - 在出现的对话框中，从 **Work With** 组合框里选择一个预配置的即时更新点。比如，Juno 发行版，选择 "Juno - http://download.eclipse.org/releases/juno" 更新点。
 - 稍等一会儿，直到更新点的内容显示在组合框中。
 - 展开 **Collaboration** 组，选择 Subversive 功能，进行安装。特定的 Subversive 功能（译注：指依赖）将被添加如果你想使用 SVN，其他可选功能用于提供额外的功能。你可以跳过可选功能，如果你希望的话。
 - 点击“下一步”通过标准插件安装过程安装选中的 Subversive 功能。安装完成后重启 Eclipse。
 - [接着安装 Subversive 连接器。](#phase2)

##### 第二种 通过 Subversive 更新点安装

你可以通过它自己的在线更新点安装 Subversive。无法在 Eclipse 即时更新点通过这个方法安装预览版本（Early Access Build）。

 - 运行 Eclipse，从主菜单选择 **Help > Install New Software...**。
 - 在出现的 **Install** 对话框上，点击 **Add...** 按钮，然后指定一个在线更新点的网络路径。你可以在 [Downloads](http://eclipse.org/subversive/downloads.php) 页上查看关于可用 Subversive 的信息。
 - 选择你需要的 Subversive 功能，并按照标准插件安装过程安装。安装完成后重启 Eclipse。
 - [接着安装 Subversive 连接器。](#phase2)

##### 第三种 通过 Eclipse Marketplace 客户端

如果你安装了 Eclipse Marketplace 客户端，你可以通过它安装最新稳定版的 Subversive。

 - 打开 Eclipse Marketplace 客户端，搜索 Subversive 项目。
 - 点击挨着 Subversive 介绍清单的安装（Install）按钮。
 - 选择你需要的 Subversive 功能，并按照标准插件安装过程安装。安装完成后重启 Eclipse。
 - [接着安装 Subversive 连接器。](#phase2)

### <a name="phase2"></a>第二步 安装 Subversive SVN 连接器

一旦 Subversive 插件安装后，并重启了 Eclipse，Subversive 会自动显示提示你安装与当前版本兼容的 Subversive SVN 连接器的对话框。此时，你可以在线安装 Subversive SVN 连接器并进行后续更新。访问 [Polarion.com](http://www.polarion.com/products/svn/subversive/download.php?utm_source=eclipse.org&utm_medium=link&utm_campaign=subversive)，查看更多关于可用更新点的信息。

你必须安装至少一个与你的系统和 SVN 服务器兼容的连接器。选择正确的连接器，可以按照下述推荐操作进行：

 - 检查你的系统。如果你运行的是 win32 Eclipse（x86 Eclipse，Windows 上已安装 Java），你可以安装 JavaHL 连接器和它的二进制包（它们只与这个平台兼容），或 SVNKit 连接器。其他平台（MacOS，Linux 等），你需要安装一个平台无关的基于纯 Java 的 SVNKit 连接器，或额外为目标系统安装一个包含 JavaHL 二进制包。 
 - 检查你的 SVN server 版本。Subversive SVN 连接器包含特定版本的 SVN 客户端模块。通常，每一种 Subversive SVN 连接器（JavaHL 或 SVNKit）都包含不同的可选版本。注意要与标准 SVN client-server 兼容，去选择合适的连接器。

如果，你已经在非 win32 系统上安装了 JavaHL 连接器或者你想使用一个不同的 JavaHL 实现，你应该按如下操作：

 - 为目标系统安装一个包含 JavaHL 的二进制包。
 - 确保这个包所有的二进制文件都在 PATH 或 LD_LIBRARY_PATH 变量所指的目录下（Windows 或 类 Unix 系统都有效）。
 - 在启动 Eclipse IDE 之前，定义 **subversion.native.library** 属性。比如， -Dsubversion.native.library=C:/SlikSVN_JavaHL/libsvnjavahl-1.dll。

如果你希望的话，你可以按照安装过程选择步骤安装多个连接器。安装之后，你可以切换使用不同的连接器，通过主菜单 **Window > Preferences > Team (节点) > SVN (节点) > SVN Connector (面板)** 进行切换。

 > **原文**：[http://eclipse.org/subversive/installation-instructions.php](http://eclipse.org/subversive/installation-instructions.php)

**翻译完。**

-----------------------------------------------------

### 备忘

我在线安装完 SVN 插件并重启 eclipse 后，在弹出框中，取消掉了连接器的安装，以为并非必须安装（当时还没有连接器的概念）。在导入项目的时候，会有如下出错信息：

	SVN: '0x00400006: Validate Repository Location' operation finished with error: Selected SVN connector library is not available or cannot be loaded.
	If you selected native JavaHL connector, please check if binaries are available or install and select pure Java Subversion connector from the plug-in connectors update site.
	If connectors already installed then you can change the selected one at: Window->Preferences->Team->SVN->SVN Connector.
	Selected SVN connector library is not available or cannot be loaded.
	If you selected native JavaHL connector, please check if binaries are available or install and select pure Java Subversion connector from the plug-in connectors update site.
	If connectors already installed then you can change the selected one at: Window->Preferences->Team->SVN->SVN Connector.

原因就是连接器没有安装，于是简单翻译了这篇教程。

安装还是比较简单的，就是选择一个更新点而已。打开 [Polarion.com](http://www.polarion.com/products/svn/subversive/download.php?utm_source=eclipse.org&utm_medium=link&utm_campaign=subversive) 后，这里包含所有关于 Subversive 插件安装源的信息。
我的 Eclipse IDE 是 **eclipse-jee-luna-SR1-win32**，选择的 SVN 连接器更新点为： [http://community.polarion.com/projects/subversive/download/eclipse/4.0/luna-site/](http://community.polarion.com/projects/subversive/download/eclipse/4.0/luna-site/)。
