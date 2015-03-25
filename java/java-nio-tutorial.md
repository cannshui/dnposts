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

### <a name="Java-NIO-Channel"></a> 3 Java NIO Channel

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

### <a name="Java-NIO-Buffer"></a> 4 Java NIO Buffer

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

