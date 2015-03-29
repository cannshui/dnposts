## Java NIO

 1. [Java NIO 教程](#Java-NIO-Tutorial)
 1. [Java NIO 概述](#Java-NIO-Overview)
	- [Channels 和 Buffers](#channels-and-buffers)
	- [Selectors](#selectors)
 1. [Java NIO Channel](#Java-NIO-Channel)
	- [Channel 实现](#channel-implementations)
	- [基本 Channel 示例](#basic-channel-example)
 1. [Java NIO Buffer](#Java-NIO-Buffer)
	- [基本 Buffer 使用](#basicusage)
	- [Buffer 容量，位置和限制](#capacity-position-limit)
		- [容量](#capacity)
		- [位置](#position)
		- [限制](#limit)
	- [Buffer 类型](#buffertypes)
	- [分配 Buffer](#allocating)
	- [写数据到 Buffer 中](#writing)
	- [flip()](#flip)
	- [从 Buffer 读数据](#reading)
	- [rewind()](#rewind)
	- [clear() 和 compact()](#clear)
	- [mark() 和 reset()](#mark)
	- [equals() 和 compareTo()](#equals-and-compareto)
		- [equals()](#equals)
		- [compareTo()](#compareTo)
 1. [Java NIO Scatter / Gather](#Java-NIO-Scatter-Gather)
	- [Scattering Reads](#scattering-reads)
	- [Gathering Writes](#gathering-writes)
 1. [Java NIO 通道之间数据传送](#Java-NIO-Channel-to-Channel-Transfers)
	- [transferFrom()](#transferfrom)
	- [transferTo()](#transferto)
 1. [Java NIO Selector](#Java-NIO-Selector)
	[为什么使用 Selector](#why-use-a-selector)
	[创建 Selector](#creating-a-selector)
	[向 Selector 注册 Channel](#registering-channels-with-the-selector)
	[SelectionKey 的](#selectionkey)
		[兴趣位（Interest Set）](#selector-interest-sets)
		[状态位（Ready Set）](#selector-ready-set)
		[Channel + Selector](#channel-selector)
		[关联对象](#attaching-objects)
	[通过 Selector 选择 Channel](#selecting-channels-via-a-selector)
		[selectedKeys()](#selectedkeys)
	[wakeUp()](#wakeup)
	[close()](#close)
	[完整 Selector 示例](#full-selector-example)
 1. [Java NIO FileChannel](#Java-NIO-FileChannel)
	- [打开 FileChannel](#opening-a-filechannel)
	- [从 FileChannel 读数据](#reading-data-from-a-filechannel)
	- [写数据到 FileChannel](#writing-data-to-a-filechannel)
	- [关闭 FileChannel](#closing-a-filechannel)
	- [FileChannel 位置](#filechannel-position)
	- [FileChannel 大小](#filechannel-size)
	- [FileChannel 截断](#filechannel-truncate)
	- [FileChannel 强制刷新](#filechannel-force)
 1. [Java NIO SocketChannel](#Java-NIO-SocketChannel)
	- [打开 SocketChannel](#opening-a-socketchannel)
	- [关闭 SocketChannel](#closing-a-socketchannel)
	- [从 SocketChannel 读](#reading-from-a-socketchannel)
	- [写向 SocketChannel](#writing-to-a-socketchannel)
	- [非阻塞模式](#non-blocking-mode)
		- [connect()](#connect)
		- [write()](#write)
		- [read()](#read)
		- [非阻塞模式和 Selector](#non-blocking-mode-with-selectors)
 1. [Java NIO ServerSocketChannel](#Java-NIO-ServerSocketChannel)
	- [打开 ServerSocketChannel](#opening-a-serversocketchannel)
	- [关闭 ServerSocketChannel](#closing-a-serversocketchannel)
	- [监听连入连接](#listening-for-incoming-connections)
	- [非阻塞模式](#non-blocking-mode)

### <a name="Java-NIO-Tutorial"></a> 1. Java NIO 教程

Java NIO（New IO）是 Java IO API 的替代方案（Java 1.4 之后），是指传统 [Java IO]() 和 [Java Networking]() API 的一种替代。Java NIO 提供了一种使用 IO 的不同方式，相比于传统的 IO API。

#### 1.1 Java NIO：Channels 和 Buffers

使用传统 IO API，你实际是使用的是字节流和字符流。而 NIO 中，你需要使用 channels 和 buffers。数据总是从一个 channel 读入到一个 buffer，或从一个 buffer 写向一个 channel。

#### 1.2 Java NIO：非阻塞（Non-blocking）IO

Java NIO 可以使你实现非阻塞的 IO。比如，一个线程可以像一个 channel 请求读入数据到一个 buffer。当 channel 在读数据到 buffer 的时候，那个县城可以执行其他操作。一旦当数据读入到 buffer 中时，线程就可以接着处理它。这同样适用于写数据到 channel 中。

#### 1.3 Java NIO：Selectors

Java NIO 包含“selector”的概念。一个 selector 是一个对象，它可以为多个 channel 监测特定事件（像：连接开启，数据到达等） 。因而，一个简单线程就可以为数据监测多个 channel。

### <a name="Java-NIO-Overview"></a> 2. Java NIO 概述

Java NIO 包含如下核心组件：

 - Channels
 - Buffers
 - Selectors

Java NIO 当然有很多类和组件，而不止上面的 3 个，但是在我看来， `Channel`，`Buffer` 和 `Selector` 是最核心的 API。剩下的组件，像 `Pipe` 和 `FileLock` 仅仅是为了与这 3 个核心组件协作的工具类。因而，本小节，我将会重点关注于这三个组件。其他的组件会在本教程的其他小节解释到。参见本页顶的索引列表。

#### <a name="channels-and-buffers"></a> 2.1 Channels 和 Buffers

一般，所有 NIO 中的 IO 都由一个 `Channel` 作为开始。一个 `Channel` 有点类似于一个流。从 `Channel` 中数据可以被读入到一个 `Buffer`。数据也可以从 `Buffer` 被写入到一个 `Channel` 中。这里是关于上述的一个图例：

<center>![overview-channels-buffers](overview-channels-buffers.png)</center>
<center>**Java NIO：Channel 读数据到 Buffer，Buffer 写数据到 Channel。**</center>

有多种 `Channel` 和 `Buffer` 类型。下面是 Java NO 中一组主要的 `Channel` 实现类：

 - FileChannel
 - DatagramChannel
 - SocketChannel
 - ServerSocketChannel

如你所见，这些 channel 覆盖了 UDP + TCP 网络 IO 和文件 IO。

有一些有趣的接口跟这些类一起工作，但是为简单起见，我不会在本节中讲述。它们将会本教程其他章节涉及到的地方解释。

下面是 Java NIO 中一组核心 `Buffer` 实现类：

 - ByteBuffer
 - CharBuffer
 - DoubleBuffer
 - FloatBuffer
 - IntBuffer
 - LongBuffer
 - ShortBuffer

这些 `Buffer` 涵盖了你可以通过 IO 发送的基本数据类型：byte，short，int，long，float，double，和 characters。

Java NIO 同样有一个 `MappedByteBuffer`，用于跟内存映射文件相协作。我也不会在本章节讨论这个 `Buffer`。

#### <a name="selectors"></a> 2.2 Selectors

一个 `Selector` 允许一个简单线程处理多个 `Channel`。这将会很方便，如果你的应用有多个连接（Channel）处于打开状态，但每个连接只有较低的流量。

比如，一个聊天服务器。

下面是一个线程使用 `Selector` 处理 3 个 `Channel` 的示意图：

<center>![overview-selectors](overview-selectors.png)</center>
<center>**一个线程使用一个 Selector 处理 3 个 Channel。**</center>

为了使用一个 `Selector`，你需要注册 `Channel` 到它。然后你调用它的 `select()` 方法。这个方法将会一直阻塞直到一个已注册的 channel 的事件到来。一旦这个方法返回，线程就可以处理这些事件了。事件类型比如连接到达，接收到数据等。

### <a name="Java-NIO-Channel"></a> 3. Java NIO Channel

Java NIO Channel 跟流很相似，但也有一些不同：

 - 你可以同时读和写一个 Channel。流一般是单一的（只读或只写）。
 - Channel 可以被异步读写。
 - Channel 总是从 Buffer 读，写向 Buffer。

像上面提到的，你可以从 Channel 读数据到 Buffer，及从 Buffer 写数据到 Channel。这里是一个示意图：

<center>![overview-channels-buffers](overview-channels-buffers.png)</center>
<center>**Java NIO：Channel 读数据到 Buffer，Buffer 写数据到 Channel。**</center>

#### <a name="channel-implementations"></a> 3.1 Channel 实现

下面是 Java NIO 中一些最重要的 Channel 实现类：

 - FileChannel
 - DatagramChannel
 - SocketChannel
 - ServerSocketChannel

`FileChannel` 从文件读或写数据。

`DatagramChannel` 可以通过 UDP 协议从网络读和写数据。

`SocketChannel` 可以通过 TCP 协议从网络读或写数据。

`ServerSocketChannel` 允许你监听到达的 TCP 连接，像 web 服务器那样。每一个到达的链接，就会创建一个 `SocketChannel`。

#### <a name="basic-channel-example"></a> 3.2 基本 Channel 示例

下面是一个基本示例，使用 `FileChannel` 读取一些数据到 Buffer：

	RandomAccessFile aFile = new RandomAccessFile("data/nio-data.txt", "rw");
	FileChannel inChannel = aFile.getChannel();

	ByteBuffer buf = ByteBuffer.allocate(48);

	int bytesRead = inChannel.read(buf);
	while (bytesRead != -1) {

		System.out.println("Read " + bytesRead);
		buf.flip();

		while (buf.hasRemaining()) {
			System.out.print((char) buf.get());
		}

		buf.clear();
		bytesRead = inChannel.read(buf);
	}
	aFile.close();

注意 `buf.flip()` 调用。首先你读到一个 Buffer 中。然后，你切换读写模式。然后，读出它。我将会在下一小节讲解更多关于 `Buffer` 的细节。

### <a name="Java-NIO-Buffer"></a> 4. Java NIO Buffer

Java NIO Buffer 用于跟 NIO Channel 交互。如你所知，数据从 Channel 读入 Buffer，从 Buffer 写向 Channel。

一个 Buffer，本质是一块内存区域，你可以写入数据到其中，并之后进行重读。这块内存区域被包装成 NIO Buffer 对象，这些对象提供了一系列方法使的更易于跟内存块一起工作。

#### <a name="basicusage"></a> 4.1 基本 Buffer 使用

使用一个 Buffer 来读和写数据，一般有 4 步：

 1. 写数据到 Buffer 中
 2. 调用 buffer.flip()
 3. 从 Buffer 读取读数
 4. 调用 buffer.clear() 或 buffer.compact()

当你写数据到 Buffer 中，这个 Buffer 会记录你已经写了多少数据。一旦，你需要读数据，就需要通过 `flip()` 来切换 Buffer 从写模式到读模式。读模式下，Buffer 可以使你读到所有已写入 Buffer 的数据。

一旦你读完了所有数据，你需要清空 Buffer，使它可以做好准备再次写入。你可以通过两种方式实现：调用 `clear()` 或调用 `compant()`。`clear()` 方法清空整个 Buffer。`compact()` 方法仅仅清空你已经读过的数据。所有未读数据将会被移动到 Buffer 的开始位置，然后数据将会被写入到 Buffer 中未读数据的后面。

	RandomAccessFile aFile = new RandomAccessFile("data/nio-data.txt", "rw");
	FileChannel inChannel = aFile.getChannel();

	ByteBuffer buf = ByteBuffer.allocate(48);

	int bytesRead = inChannel.read(buf);
	while (bytesRead != -1) {

		System.out.println("Read " + bytesRead);
		buf.flip();

		while (buf.hasRemaining()) {
			System.out.print((char) buf.get());
		}

		buf.clear();
		bytesRead = inChannel.read(buf);
	}
	aFile.close();

#### <a name="capacity-position-limit"></a> 4.2 Buffer 容量，位置和限制

下面是一个简单实用 `Buffer` 的示例，包括写，切换，读和清空操作：

一个 Buffer 本质上是一块内存区域，你可以写入数据到其中，并之后再次阅读。这块内存区域被包装成 NIO Buffer 对象，这些对象提供了一系列方法使的更易于跟内存块一起工作。

一个 Buffer 有 3 个你需要熟悉的属性，才能理解一个 `Buffer` 是如何工作的。它们是：

 - 容量（capacity）
 - 位置（position）
 - 限制（limit）

`position` 和 `limit` 的实际含义依赖于 `Buffer` 是处于读还是写模式。容量总是同一个含义，跟 Buffer 模式无关。

下面是容量、位置和限制在写和读模式下的示意图。示意图的解释在下一小节。

<center>![buffers-modes](buffers-modes.png)</center>
<center>**写和读模式下 Buffer 容量，位置和限制。**</center>

##### <a name="capacity"></a> 4.2.1 容量（capacity）

一个内存块，即一个 `Buffer` 有一个确定的尺寸，也叫做它的“capacity”。你只能写 `catacity` 长度的 byte，long 和 char 等到 Buffer 中。一旦 Buffer 满了，你需要先清空它（读数据，或清空它），在你可以再次写入更多数据之前。

##### <a name="position"></a> 4.2.2 位置（position）

当你写入数据到 `Buffer` 中，你会设置一个指定 position。初始化时 position 是 0。当一个 byte，long 等已经被写入到 `Buffer` 中，position 就会前进到下一个 Buffer 中的格子来插入下个数据。position 最大可以变成 `capacity - 1`。

当你从 `Buffer` 中读入数据时，你也同样需要根据当前 position 来设置新 position。当你切换一个 `Buffer` 从写模式到读模式时，position 将被重设成 0。当你从 `Buffer` 读入数据时，也将会变动 `position` 值，即前进 `position` 到下个被读的位置。

##### <a name="limit"></a> 4.2.3 限制（limit）

写模式下，一个 `Buffer` 的 limit 是你可以写入多少数据到 Buffer 中。写模式下，limit 是等于 `Buffer` capacity 的。

当切换 `Buffer` 到读模式，limit 表示你可以从 Buffer 中读多少数据（译注：原文是 from the data，应该是错误的，data 应该是 buffer）。因而，当切换一个 `Buffer` 到读模式，limit 值被设置成写模式下写入数据时的最后 position。换句话说，你写了多少数据就可以读入多少数据（limit 被设置成已写字节（译注：应该是指定类型的数据）的数量，即 position 值）。

#### <a name="buffertypes"></a> 4.3 Buffer 类型

Java NIO 中有以下 **Buffer** 类型：

 - ByteBuffer
 - MappedByteBuffer
 - CharBuffer
 - DoubleBuffer
 - FloatBuffer
 - IntBuffer
 - LongBuffer
 - ShortBuffer

如你所见，这些 `Buffer` 类型用于表示不同的数据类型。换句话说，它们使你可以对待 Buffer 中的字节成 char，short，int，long，float 或 double 类型。

`MappedByteBuffer` 有点特殊，将会在自己小节中讲解。

#### <a name="allocating"></a> 4.4 分配 Buffer

为了获得一个 `Buffer` 对象，你必须先分配它。每个 `Buffer` 类都有一个 `allocate()` 方法，来实现分配操作。下面是一个例子展示了对 `ByteBuffer` 的分配，容量 48 字节：

	ByteBuffer buf = ByteBuffer.allocate(48);

下面的例子分配一个 `CharBuffer`，容量为 1024 个 char：

	CharBuffer buf = CharBuffer.allocate(1024);

#### <a name="writing"></a> 4.5 写数据到 Buffer 中

你可以写数据到 `Buffer` 中，有两种方式：

 1. 从 `Channel` 写数据到 `Buffer` 中。
 2. 直接通过 `Buffer` 写入数据，通过 Buffer 的 `put()` 方法。

下面的例子展示一个 `Channel` 如何写入数据到 `Buffer` 中：

	int bytesRead = inChannel.read(buf); //read into buffer.

下面的例子是写入数据到 `Buffer` 中，通过 `put()` 方法：

	buf.put(127);

有很多其他版本的 `put()` 方法，允许你通过多种方式写数据到 `Buffer` 中。比如，在特定的位置写入数据，或写一个字节数组到 Buffer 中。具体 Buffer 实现类的细节，参见 JavaDoc。

#### <a name="flip"></a> 4.6 flip()

`flip()` 方法切换 `Buffer` 从写模式到读模式。调用 `flip()` 会设置 `position` 成 0，并设置 `limit` 为 position 值。

换句话说，`position` 现在标记读的位置，`limit` 标记多少字节，字符等被入到 Buffer 中，即多少字节，字符等可以被读出。

#### <a name="reading"></a> 4.7 从 Buffer 读数据

有两种方式，你可以从 `Buffer` 读入数据。

 1. 从 Buffer 读数据到一个 Channel。
 2. 从 Buffer 本身读取数据，通过 `get()` 方法。

下面的例子展示你如何从 Buffer 读数据到一个 Channel 中：

	//read from buffer into channel.
	int bytesWritten = inChannel.write(buf);

下面的例子展示了通过 `get()` 方法从 `Buffer` 读入数据：

	byte aByte = buf.get();

还有很多其他版本的 `get()` 方法，允许你从 `Buffer` 以多种方式读数据。比如，读取特定位置的数据，从 Buffer 读取一个字节数组。具体 Buffer 实现类的细节，参见 JavaDoc。

#### <a name="rewind"></a> 4.7 rewind()

`Buffer.rewind()` 重新设置 `position` 成 0，这样你可以重新读取 Buffer 中的所有数据。`limit` 值不会变化，即仍标记可以从 `Buffer` 读取多少元素（字节，字符等）。

#### <a name="clear"></a> 4.8 clear() 和 compact()

一旦你完成了从 `Buffer` 读取数据，你必须使 `Buffer` 做好准备再次被写入。你可以通过调用 `clear()` 或 `compact()` 来做到这个。

如果你调用 `clear()` 方法，将会设置 `position` 成 0，`limit` 成 `capacity` 值。换句话说，`Buffer` 被清空了。`Buffer` 中的实际数据并没有被清空。这些标记变量仅仅告诉你可以从哪里写入数据到 `Buffer` 中。

如果 `Buffer` 中还有未被读取的数据，当你调用 `clear()` 的时候，这些数据将会被“遗忘”，即你不再有任何标记变量告诉你什么数据已经读过了，什么数据还没有被读过。

如果 `Buffer` 中仍有未被读取的数据，而且你还想在之后读取，但你需要首先做一些写入操作，则需要调用 `compact()` 方法而非 `clear()`。

`compact()` 复制这些未读数据到 `Buffer` 中起始位置。然后，设置 `position` 为最右边的未读元素的索引。`limit` 值设置成 `capacity` 值，就像 `clear()` 方法所做的那样。现在，`Buffer` 已经是可以再次写入的状态了，但你并没有复写未读数据。

#### <a name="mark"></a> 4.9 mark() 和 reset()

你可以在 `Buffer` 中标记一个给定的 position，通过调用 `Buffer.mark()` 方法。然后，你可以重设 position 到这个已标记的 position，通过调用 `Buffer.reset()` 方法。下面是一个例子：

	buffer.mark();
	//call buffer.get() a couple of times, e.g. during parsing.
	buffer.reset();  //set position back to mark.

#### <a name="equals-and-compareto"></a> 4.10 equals() 和 compareTo()

可以比较两个 Buffer， 通过 `equals()` 和 `compareTo()`。

##### <a name="equals"></a> 4.10.1 equals()

两个 Buffer 是相等的，如果（译注：同时满足 3 个条件）：

 1. 它们具有相同的类型（字节，字符，整形等）。
 2. 它们的 Buffer 中有同等数量的未读（译注：此处为 remaining，翻译成“未读”？）字节，字符等。
 3. 所有的字节，字符等是相等的。

如你所见，equals 方法仅仅比较 `Buffer` 的一部分，而非其中的每一个元素。其实，它仅比较 `Buffer` 中的未读元素。

##### <a name="compareTo"></a> 4.10.2 compareTo()

`compareTo()` 方法比较两个 Buffer 的剩余元素（字节，字符等），比如，排序例程。一个 Buffer “小于”另一个 Buffer 如果：

 1.  Buffer 中第一个元素小于另一个 Buffer 中的相应元素。
 2. 所有的元素是相等的，但是第一个 Buffer 先于第二个 Buffer 读（耗）尽了所有元素（即，第一个 Buffer 有较少的元素）。

### <a name="Java-NIO-Scatter-Gather"></a> 5. Java NIO 散和收（Sactter/Gather）

Java NIO 有内建的 scatter / gather 支持。scatter / gather 的概念用于读 / 写 channel。

一个 scattering 用于从 channel 执行读操作，读数据到一个或多个 buffer 中。因而，channel 用于从多个通道“分散”数据到多个缓冲区中。

一个 gathering 写向 channel 是一个写操作来写数据到 channel 中，可以从一或多个缓冲区中写数据到一个单一的 channel。

scatter / gather 会是很有用的解决方案，当你需要用分开使用多种类的数据时。比如，如果一个消息由一个头（header）和正文（body）组成，你可能想将头和正文放在分开的缓冲区中。这样做，可以使你更易于以分离的方式使用头和正文。

#### <a name="scattering-reads"></a> 5.1 分散读（Scattering Reads）

一个“散开读”从一个单一通道中读数据到多个缓冲区中。下面是这个原理的实例图：

<center>![scatter](scatter.png)</center>
<center>**Java NIO：分散读**</center>

这面这个例子展示如何实现一个分散读：

	ByteBuffer header = ByteBuffer.allocate(128);
	ByteBuffer body   = ByteBuffer.allocate(1024);

	ByteBuffer[] bufferArray = { header, body };

	channel.read(buffers);

注意，实例化后的缓冲区先被插入到数组中的，然后数组作为参数传递到 `channel.read()` 方法。然后，`read()` 方法按照数组中缓冲区的顺序，从通道中写数据到数组中的缓冲区实例。一旦一个缓冲区写满了，通道转向下一个，并填满它。

分散读填满一个缓冲区之后才会转向下一个，这意味着动态大小的消息部分并不适合使用分散读。换句话说，如果你有一个头和正文，而且头有固定尺寸（如，128 字节），那么分散度将会相当有效。

#### <a name="gathering-reads"></a> 5.2 收集写（Gathering Writes）

一个“收集写”从多个缓冲区中写数据到一个单一通道中。下面是这个原理的示意图：

<center>![gather](gather.png)</center>
<center>**Java NIO：收集写**</center>

下面的代码示例展示如何实现一个收集写：

	ByteBuffer header = ByteBuffer.allocate(128);
	ByteBuffer body   = ByteBuffer.allocate(1024);

	//write data into buffers

	ByteBuffer[] bufferArray = { header, body };

	channel.write(buffers);

缓冲区数组传递到 `write()` 方法，该方法按照数组中缓冲区的顺序将内容写到通道中。仅仅在 position 和 limit 之间的缓冲区内容才会被写出。因而，如果一个缓冲区的容量为 128 字节，但仅包含 58 字节的实际数据，那么只会有这 58 字节从缓冲区写向通道中。因此，一个收集写在消息大小是动态变化时将会工作的很好，跟分散读相反。

### <a name="Java-NIO-Channel-to-Channel-Transfers"></a> 6. Java NIO 通道之间数据传送

Java NIO 中，你可以直接将数据从一个通道转到另一个通道中，如果通道中的一个是 `FileChannel` 的话。`FileChannel` 类有一个 `transferTo()` 和一个 `transferFrom()` 方法，来完成数据转送操作。

#### <a name="transferfrom"></a> 6.1 transferFrom()

`FileChannel.transferFrom()` 方法从一个源通道转送数据到另一个 `FileChannel`。


	RandomAccessFile fromFile = new RandomAccessFile("fromFile.txt", "rw");
	FileChannel      fromChannel = fromFile.getChannel();
	
	RandomAccessFile toFile = new RandomAccessFile("toFile.txt", "rw");
	FileChannel      toChannel = toFile.getChannel();
	
	long position = 0;
	long count    = fromChannel.size();
	
	toChannel.transferFrom(fromChannel, position, count);

position 和 count 参数，告诉目标（被写入）文件从哪里开始写数据（`position`），及应该转送最大多大（`count`）字节的数据。如果源通道数据量少于 `count` 字节，那么将只转送能够转送的数据量。

另外，一些 `SocketChannel` 实现可能也可以转送数据，这些数据只是 `SocketChannel` 中当前已经在内部缓冲区中的了，即使 `SocketChannel` 中可能后续有很多的数据进来。因而，它可能无法从 `SocketChannel` 转送全部的所要求的（`count`）数据到 `FileChannel` 中。

#### <a name="transferfrom"></a> 6.2 transferto()

`transferTo()` 方法用于从 `FileChannel` 转数据到其它通道。下面是一个简单示例：

	RandomAccessFile fromFile = new RandomAccessFile("fromFile.txt", "rw");
	FileChannel      fromChannel = fromFile.getChannel();
	
	RandomAccessFile toFile = new RandomAccessFile("toFile.txt", "rw");
	FileChannel      toChannel = toFile.getChannel();
	
	long position = 0;
	long count    = fromChannel.size();
	
	fromChannel.transferTo(position, count, toChannel);

注意，这个例子跟前例非常相似。唯一真正的不同是，这个方法是在哪个 `FileChannel` 对象调用的。其它都是相同的。

问题是，`SocketChannel` 也提供了一个 `transferTo()` 方法。`SocketChannel` 实现可能只会从 `FileChannel` 中转送字节直到发送缓冲区满了（send buffer），然后停止（译注：挂起？）。

### <a name="Java-NIO-Selector"></a> 7. Java NIO Selector

一个 `Selector` 是 Java NIO 的一个组件，用于检查一或多个 NIO Channel，并决定 Channel 状态，如读或写。这样，一个单线程就可以管理多个通道，及多个网络连接。

#### <a name="why-use-a-selector"></a> 7.1 为什么使用 Selector

只使用一个线程来处理多个通道的优点是你只需较少的线程来处理通道。其实，你可以只用一个线程来处理你所有的通道。操作系统中，线程间的切换是很重的操作，而且每个线程都需要一些资源（内存）。因而，越少的线程使用，越好。

但是记住，现在操作系统和 CPU 在多任务的处理上变的越来越好，所以多线程的切换代价变的越来越小。其实，如果一个 CPU 由多核，你可能在浪费 CPU 的能力，如果不使用多任务的话。不过，那种设计讨论是另外的主题。这里，只讨论通过单个线程利用 `Selector` 处理多个通道。

下面是一个线程利用 `Selector` 处理 3 个 `Channel` 的例子：

<center>![overview-selectors](overview-selectors.png)</center>
<center>**一个线程使用一个 Selector 处理 3 个 Channel。**</center>

#### <a name="creating-a-selector"></a> 7.2 创建 Selector

你通过调用 `Selector.open()` 方法创建一个 `Selector`，像这样：

	Selector selector = Selector.open();

#### <a name="registering-channels-with-the-selector"></a> 7.3 向 Selector 注册 Channel

为了搭配 `Selector` 使用 `Channel`，你必须注册 `Channel` 到 `Selector`。这通过 `SelectableChannel.register()` 方法实现，如下：

	channel.configureBlocking(false);

	SelectionKey key = channel.register(selector, SelectionKey.OP_READ);

`Channel` 必须处于非阻塞模式，才能搭配使用 `Selector`。这意味着，你不能为 `FileChannel` 使用 `Selector`，因为 `FileChannel` 无法切换到非阻塞模式。Socket channel 将会工作的很好。

注意 `register()` 方法的第二个参数。这是一个“兴趣位（interest set）”，表示你为 `Channel` 设置对哪种事件感兴趣，通过 `Selector`。你可以监听 4 种事件：

 1. 连入（Connect）
 2. 允许（Accept）
 3. 读（Read）
 4. 写（Write）

一个 `Channel` “激活一个事件（fire an event）”，也叫做“准备好（ready）”处理这个事件。所以，一个已经成功连接上另一个服务器的通道处于“可接受连接状态（connect ready）”状态。一个 server socket 通道，允许接受连接，处于“允许（accept）”状态。一个通道有数据可以被读取处于“读”状态。一个通道准备好向其写数据处于“写”状态。

这 4 个状态被定义成 `SelectionKey` 的 4 个常量：

 1. SelectionKey.OP_CONNECT
 2. SelecitonKey.OP_ACCEPT
 3. SelectionKey.OP_READ
 4. SelectionKey.OP_WRITE

如果，你对不止一个事件感兴趣，用“或”操作符连起它们，如：

	int interestSet = SelectionKey.OP_READ | SelectionKey.OP_WRITE;

我将会在本文下面更多的讲解“兴趣位”。

#### <a name="selectionkey"></a> 7.4 SelectionKey 的

如你在前面小节中所见，当你通过 `register()` 方法注册 `Channel` 到 `Selector` 时，返回一个 `SelectionKey` 对象。这个 `SelectionKey` 对象包括一组兴趣属性：

 - 兴趣位（interest set）
 - 准备状态位（ready set）
 - 通道
 - Selection
 - 关联对象（可选）

我将在下面描述这些属性。

##### <a name="selector-interest-sets"></a> 7.4.1 兴趣位（Interest Set）

兴趣位是一组你感兴趣的事件，如在“向 Selection 注册 Channel”所描述。你可以通过 `SelectionKey` 读和写兴趣位，像这样：

	int interestSet = selectionKey.interestOps();

	boolean isInterestedInAccept  = interestSet & SelectionKey.OP_ACCEPT;
	boolean isInterestedInConnect = interestSet & SelectionKey.OP_CONNECT;
	boolean isInterestedInRead    = interestSet & SelectionKey.OP_READ;
	boolean isInterestedInWrite   = interestSet & SelectionKey.OP_WRITE;   

如你所见，你可以通过“&”操作符连接 `SelectionKey` 常量变量来设置设置兴趣位，以此确定一个事件是否在兴趣位中。

##### <a name="selector-ready-set"></a> 7.4.2 状态位（Ready Set）

准备状态位描述一组通道预备好的可以执行的操作。你将在得到 selection 后获取状态位。Selection 在下面小节中解释。你通过如下操作获取状态位：

	int readySet = selectionKey.readyOps();

你可以按这种方式来获取其他兴趣位，什么事件 / 操作这个通道处于准备完成状态。但是，你也可以使用下面 4 个方法，都是返回 boolean 值：

	selectionKey.isAcceptable();
	selectionKey.isConnectable();
	selectionKey.isReadable();
	selectionKey.isWritable();

##### <a name="channel-selector"></a> 7.4.3 Channel + Selector

从 `SelectionKey` 获取 channel 和 selector 很简单。按照下面操作：

	Channel  channel  = selectionKey.channel();

	Selector selector = selectionKey.selector(); 

##### <a name="attaching-objects"></a> 7.4.4 关联对象

你可以关联对象到一个 `SelectionKey`，这可以通过手动方式由通道得到关联对象，或关联更多信息到通道。比如，你可以关联你的通道正使用的 `Buffer`，或一个包括聚合数据的对象。下面是如何关联到对象的操作：

	selectionKey.attach(theObject);

	Object attachedObj = selectionKey.attachment();

你也可以关联对象，在向 `Selector` 注册 `Channel` 的时候，在 `register()` 方法中。下面是示例：

	SelectionKey key = channel.register(selector, SelectionKey.OP_READ, theObject);

#### <a name="selecting-channels-via-a-selector"></a> 7.5 通过 Selector 选择 Channel

一旦你已经注册一或多个通道到 `Selector`，你可以通过 `select()` 方法选择其中一个。这些方法返回准备好某种状态（你所感兴趣的，connect，accept，read 或 write）的通道。换句话说，如果你对准备好读的通道“感兴趣”，通过 `select()` 方法你将获得这个准备好读的通道。

下面是一些 `select()` 方法：

 - int select()
 - int select(long timeout)
 - int selectNow()

`select()` 方法阻塞，直到至少一个通道准备好了注册的事件。

`select(long timeout)` 跟 `select()` 一样除了它最多阻塞 `timeout` 毫秒（参数）。

`selectNow()` 完全不阻塞。它返回现在处于准备完成状态的任何通道。

`select()` 方法的返回值是 `int` 类型，告诉你多少通道处于准备状态。即，多少通道处于准备状态，自从你上次调用过 `select()`。如果你调用 `select()` 并返回 1，因为一个通道处于准备状态，多次调用 `select()`， 并且多个通道处于准备状态，它将会再次返回 1。如果你没有用第一个准备状态的通道，你现在将会有 2 个处于准备状态的通道，但是在每次调用 `select()` 之间，只有 1 个通道已经变成准备状态。

##### <a name="selectedkeys"></a> 7.5.1 selectedKeys()

一旦你调用了某一个 `select()` 方法，它的返回值表示一或多个通道处于准备状态，你可以通过调用 selector 的 `selectedKeys()` 方法来获得所有处于准备状态的通道。

Set<SelectionKey> selectedKeys = selector.selectedKeys();

当你注册一个通道到 `Selector`，`Channel.register()` 方法返回一个 `SelectionKey` 对象。这个 key 表示通道注册到的 selector。你可以通过 `selectedKeySet()` 方法得到这些 key。从 `SelectionKey`。

你可以遍历这些 selected key set 来获得这些处于准备状态的通道。下面是这个的示例：

	Set<SelectionKey> selectedKeys = selector.selectedKeys();
	
	Iterator<SelectionKey> keyIterator = selectedKeys.iterator();
	
	while(keyIterator.hasNext()) {
	    
	    SelectionKey key = keyIterator.next();
	
	    if(key.isAcceptable()) {
	        // a connection was accepted by a ServerSocketChannel.
	
	    } else if (key.isConnectable()) {
	        // a connection was established with a remote server.
	
	    } else if (key.isReadable()) {
	        // a channel is ready for reading
	
	    } else if (key.isWritable()) {
	        // a channel is ready for writing
	    }
	
	    keyIterator.remove();
	}

这个循环遍历 selected key 集中的 key。对每一个 key，它测试这个 key 来决定这个 key 指向的通道所处的状态。

注意每次遍历最后的 `keyIterator.remove()` 方法。`Selector` 不会自己从 selected key 集中移除 `SelectionKey` 实例。当你完成对通道的处理，你需要自己做这个。下次通道变成准备状态时，`Selecotr` 将会再次将它添加到 selected key 集中。

`SelectionKey.channel()` 方法返回的通道需要被转型成你真正要用的通道，比如一个 `ServerSockterChannel` 或 `SocketChannel` 等。

#### <a name="wakeup"></a> 7.6 wakeUp()

一个已经调用了 `select()` 方法而阻塞的线程，可以从 `select()` 方法返回，即使没有通道处于准备状态。这是由一个不同的线程调用 `Selector` 上的 `Selector.wakeup()` 方法，在第一个已经调用 `select()` 的线程上。这个线程在内部等待 `select()`，然后立即返回。

如果一个不同线程调用 `wakeup()`，而且没有任何线程当前内部处于 `select()` 阻塞状态，下一个调用 `select()` 的线程将会立即“唤醒”。

#### <a name="close"></a> 7.7 close()

当你完成了 `Selector`，你需要调用它的 `close()` 方法。这将会关闭 `Selector` 并且移除所有注册到 `Selector` 的 `SelectionKey` 的实例。通道并没有关闭。

#### <a name="full-selector-example"></a> 7.8 完整 Selector 示例

下面是一个完整示例，打开一个 `Selector`，注册通道（通道实例化没有包括在本例中），并且检测 `Selector` 的 4 种状态（accept，connect，read，write）。

	Selector selector = Selector.open();
	
	channel.configureBlocking(false);
	
	SelectionKey key = channel.register(selector, SelectionKey.OP_READ);
	
	
	while(true) {
	
	  int readyChannels = selector.select();
	
	  if(readyChannels == 0) continue;
	
	
	  Set<SelectionKey> selectedKeys = selector.selectedKeys();
	
	  Iterator<SelectionKey> keyIterator = selectedKeys.iterator();
	
	  while(keyIterator.hasNext()) {
	
	    SelectionKey key = keyIterator.next();
	
	    if(key.isAcceptable()) {
	        // a connection was accepted by a ServerSocketChannel.
	
	    } else if (key.isConnectable()) {
	        // a connection was established with a remote server.
	
	    } else if (key.isReadable()) {
	        // a channel is ready for reading
	
	    } else if (key.isWritable()) {
	        // a channel is ready for writing
	    }
	
	    keyIterator.remove();
	  }
	}

### <a name="Java-NIO-FileChannel"></a> 8. Java NIO FileChannel

Java NIO FileChannel 是一个通道用于连接到文件。使用文件通道，你可以从文件读取数据，并向文件写数据。Java NIO FileChannel 类是 NIO 的对 [利用标准 Java IO API 读文件](#http://tutorials.jenkov.com/java-io/file.html)的一个替代。

`FileChannel` 无法设置成非阻塞模式。它总是运行在阻塞模式中。

#### <a name="opening-a-filechannel"></a> 8.1 打开 FileChannel

在你使用 `FileChannel` 之前，你必须打开它。你不能直接打开一个 `FileChannel`。你需要从输入流（InputStream），输出流（OutputStream），或 RandomAccessFile 中获取 FileChannel。下面是如何通过 RndomAccessFile 打开 FileChannel。

	RandomAccessFile aFile     = new RandomAccessFile("data/nio-data.txt", "rw");
	FileChannel      inChannel = aFile.getChannel();

#### <a name="reading-data-from-a-filechannel"></a> 8.2 从 FileChannel 读数据

你可以调用 `read()` 从 `FileChannel` 读数据。下面是一个示例：

	ByteBuffer buf = ByteBuffer.allocate(48);

	int bytesRead = inChannel.read(buf);

首先，分配一个 `Buffer`。从 `FileChannel` 读数据到 `Buffer` 中。

然后，`FileChannel.read()` 方法被调用。这个方法从 `FileChannel` 读数据到 `Buffer` 中。`read()` 方法返回 `int` 值，告诉你写到 `Buffer` 中了多少字节。如果返回的是 -1，那么表示到达了文件结尾。

#### <a name="writing-data-to-a-filechannel"></a> 8.3 写数据到 FileChannel

通过 `FileChannel.write()` 方法，可以写数据到 `FileChannel` 中，它需要 `Buffer` 作为参数。下面是一个示例：

	String newData = "New String to write to file..." + System.currentTimeMillis();

	ByteBuffer buf = ByteBuffer.allocate(48);
	buf.clear();
	buf.put(newData.getBytes());

	buf.flip();

	while(buf.hasRemaining()) {
    		channel.write(buf);
	}

注意如何在 while 循环中调用 `FileChannel.write()` 方法。并不保证 `write()` 方法写多少字节到 `FileChannel` 中。因而，我们重复调用 `write()` 方法直到 `Buffer` 中没有能写出的字符。

#### <a name="closing-a-filechannel"></a> 8.4 关闭 FileChannel

当你用过 `FileChannel` 之后，你必须关闭它。如下操作：

	channel.close(); 

#### <a name="filechannel-position"></a> 8.5 FileChannel 位置

当读或写一个 `FileChannel` 时，你是在一个指定位置操作的。通过调用 `position()` 方法，你可以获得 `FileChannel` 对象的当前位置。

你也可以通过调用 `position(long pos)` 方法设置 `FileChannel` 的位置信息。

下面是两个例子：

	long pos channel.position();

	channel.position(pos +123);

如果你设置位置在文件末尾，并尝试从通道中读取数据，你将会得到 -1，标记文件结尾。

如果你设置位置在文件末尾，并向通道中写数据，文件将会先扩容到这个位置然后写入数据。这可能导致“文件空洞（file hole）”，即写入数据到磁盘上的物理文件有空隙。

#### <a name="filechannel-size"></a> 8.6 FileChannel 大小

`FileChannel` 对象的 `size()` 方法返回文件通道连接的文件的大小。

	long fileSize = channel.size();

#### <a name="filechannel-truncate"></a> 8.7 FileChannel 截断

你可以截断一个文件通过 `FileChannel.truncate()` 方法。当你截断一个文件时，你切断文件成给定的长度。下面是一个示例：

	channel.truncate(1024);

这个例子截断文件成 1024 字节。

#### <a name="filechannel-force"></a> 8.8 FileChannel 强制刷新

`FileChannel.force()` 方法刷新所有通道中的未写数据到磁盘上。操作系统出于性能原因可能会在内存中缓存数据，所以无法保证数据写到通道中就是实际就写到磁盘中了，直到你调用 `force()` 方法。

`force()` 方法需要一个 boolean 参数，表示是否将文件元数据（权限等）也同样刷新到文件中。

下面是一个例子，同时刷新文件数据和文件元数据。

	channel.force(true);

### <a name="Java-NIO-SocketChannel"></a> 9. Java NIO SocketChannel

Java NIO SocketChannel 是一个连接 TCP 网络端口的通道。它是 Java NIO 中的对 [Java 网络编程](http://tutorials.jenkov.com/java-networking/sockets.html)的替代。有两种创建 `SocketChannel` 的方式：

 1. 你打开一个 `SocketChannel` 并连到一个网络上的服务器。
 2. 一个 `SocketChannel` 将会被创建，当一个连接到达 [ServerSocketChannel](#Java-NIO-ServerSocketChannel) 时。

#### <a name="opening-a-socketchannel"></a> 9.1 打开 SocketChannel

下面是如何打开一个 `SocketChannel`：

	SocketChannel socketChannel = SocketChannel.open();
	socketChannel.connect(new InetSocketAddress("http://jenkov.com", 80));

#### <a name="closing-a-socketchannel"></a> 9.2 关闭 SocketChannel

你通过调用 `SocketChannel.close()` 方法来关闭一个 `SocketChannel`。下面是一个示例：

	socketChannel.close();

#### <a name="reading-from-a-socketchannel"></a> 9.3 从 SocketChannel 读

通过 `read()` 方法从 `SocketChannel` 读数据。下面是一个例子：

	ByteBuffer buf = ByteBuffer.allocate(48);

	int bytesRead = socketChannel.read(buf);

首先，一个 `Buffer` 被分配创建。从 `SocketChannel` 读数据到 `Buffer` 中。

然后，调用 `SocketChannel.read()` 方法。这个方法从 `SocketChannel` 读数据到 `Buffer` 中。`read()` 方法返回一个 `int` 值，告诉多少字节被写到 `Buffer` 中。如果返回的是 -1，表示到达了流的结尾（连接关闭）。

#### <a name="writing-to-a-socketchannel"></a> 9.4 写向 SocketChannel

使用 `SocketChannel.write()` 方法写数据到 `SocketChannel`，需要一个 `Buffer` 作为参数。下面是一个示例：

	String newData = "New String to write to file..." + System.currentTimeMillis();

	ByteBuffer buf = ByteBuffer.allocate(48);
	buf.clear();
	buf.put(newData.getBytes());

	buf.flip();

	while(buf.hasRemaining()) {
    		channel.write(buf);
	}

注意，`SocketChannel.write()` 方法是如何在 while 循环中调用的。并不保证 `write()` 方法写多少字节到 `SocketChannel` 中。因而，我们重复调用 `write()` 方法，直到 `Buffer` 中没有任何字符需要写出。

#### <a name="non-blocking-mode"></a> 9.5 非阻塞模式

你可以设置 `SocketChannel` 成非阻塞模式。当你这样做时，你可以以异步模式调用 `connect()`，`read()` 和 `write()` 方法。

##### <a name="connect"></a> 9.5.1 connect()

如果 `SocketChannel` 是非阻塞模式，而且你调用了 `connect()` 方法，这个方法可以在连接建立前就返回。决定连接是否建立了，你可以调用 `finishConnect()` 方法，像这样：

	socketChannel.configureBlocking(false);
	socketChannel.connect(new InetSocketAddress("http://jenkov.com", 80));

	while(! socketChannel.finishConnect() ){
		//wait, or do something else...
	}

##### <a name="write"></a> 9.5.2 write()

非阻塞模式下，`write()` 方法可能直接返回，并且没有写出任何数据。因而，你需要在循环中调用 `wriet()` 方法。但是，上面的例子已经演示了这个做法，这里没有什么不同。

##### <a name="read"></a> 9.5.3 read()

非阻塞模式下，`read()` 方法可能直接返回，而且没有读到任何数据。因而，你需要注意返回的 `int` 值，告诉你读入了多少字节。

##### <a name="non-blocking-mode-with-selectors"></a> 9.5.4 非阻塞模式和 Selector

`SocketChannel` 的非阻塞方式搭配使用 `Selector` 将会工作的很好。通过注册一或多个 `SocketChannel` 到一个 `Selecotor`，你可以询问 `Selector` 找到处于准备状态（读，写等）的通道。如何使用 `Selector` 和 `SocketChannel` 将会在下文中详细解释。

### <a name="Java-NIO-ServerSocketChannel"></a> 10. Java NIO ServerSocketChannel

Java NIO ServerSocketChannel 是一个通道，可以监听到达的 TCP 连接，就像标准 Java 网络编程中 [ServerSocket](http://tutorials.jenkov.com/java-networking/server-sockets.html)。`ServerSocketChannel` 类在 `java.nio.channels` 包下。

下面是一个例子：

	ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();

	serverSocketChannel.socket().bind(new InetSocketAddress(9999));

	while(true){
		SocketChannel socketChannel = serverSocketChannel.accept();

		//do something with socketChannel...
	}

#### <a name="opening-a-serversocketchannel"></a> 10.1 打开 ServerSocketChannel

你打开一个 `ServerSocketChannel` 通过调用 `ServerSocketChannel.open()` 方法。按照下面这样做：

	ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();

#### <a name="closing-a-serversocketchannel"></a> 10.2 关闭 ServerSocketChannel

关闭一个 `ServerSocketChannel` 通过 `ServerSocketChannel.close()` 方法。按照下面这样做：

	serverSocketChannel.close();

#### <a name="listening-for-incoming-connections"></a> 10.3 监听连入连接

监听连入连接通过 `ServerSocketChannel.accept()` 方法。当 `accept()` 方法返回时，它返回一个 `SocketChannel` 代表一个连入连接。因而，`accept()` 方法阻塞直到有连接到达。

因为你一般不会只对一个单一连接感兴趣，因而你将需要在一个 while 循环中调用 `accept()` 方法。向下面这样：

	while(true){
		SocketChannel socketChannel =
			serverSocketChannel.accept();

		//do something with socketChannel...
	}

当然你可以在循环中使用一些停止条件而不是 `true`。

#### <a name="non-blocking-mode"></a> 10.4 非阻塞模式

一个 `ServerSocketChannel` 将可以设置成非阻塞模式。非阻塞模式下，`accept()` 方法立即返回，并可能返回 null 值，如果没有任何连接连入。因而，你需要检查返回的 `SocketChannel` 是否为 null 值。下面是一个例子：

	ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();

	serverSocketChannel.socket().bind(new InetSocketAddress(9999));
	serverSocketChannel.configureBlocking(false);

	while(true){
		SocketChannel socketChannel =
			serverSocketChannel.accept();

		if(socketChannel != null){
		//do something with socketChannel...
		}
	}

