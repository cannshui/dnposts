## JS 编码字符串（Encode query string sent to server）

javascript 中有 3 种编码查询字符串的方式：`escape`，`encodeURI`，`encodeURIComonent`。那么如何选择呢？今天特地做了下简单总结。

### `escape`

`escape` 已经被废弃（[escape() - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/escape)），不再推荐使用这个 API。下面为取自 mozilla 的描述：

 > **废弃**
 >
 > `escape` 已经从 web 标准中移除。虽然有些浏览器仍然支持这个特性，但它已经被移除了。不要再在老或新项目中使用它。使用它的页面或 web 应用可能会在任何时候失效。

这里暂不对它进行更进一步的学习。

### `encodeURI`

mozilla [encodeURI() - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURI) 的概述翻译：

 > `encodeURI(URI)` 方法，通过替换指定字符的每个实例成 1，2，3 或 4 个十六进制的转义序列，表示这个字符的 **UTF-8 编码**（对于两个“代理”组合成的字符只会转成 4 个序列 ??），来编码一个 URI。

这个方法的参数是 URI，表示它的本意接收*一个完整的 URI*，而不单单是 URI 中的某个*查询参数*。这意味着它不会编码 URI 中有特殊意义的字符，如下：

<table>
	<tr><th>类型</th><th>字符</th></tr>
	<tr><td>保留字符</td><td>; , / ? : @ & = + $</td></tr>
	<tr><td>无转义字符</td><td>字母（A-Z, a-z） 数字（0-9） - _ . ! ~ ' ( )</td></tr>
	<tr><td>评分</td><td>#</td></tr>
</table>

注意，调用 `encodeURI(URI)` 并*不一定能*构造出正确的 URI。因为它不转义“&”，“+”，和“=”。当这 3 个字符出现在查询参数时，就会出现问题：

	var s = '1&2=3+4;'
	var uri = 'http://guge.io/#q=' + s;
	console.log(encodeURI(uri)); // http://guge.io/#q=1&2=3+4

转义后，由于没有转义“&”，“+”，和“=”，*&2=3+4* 没有被识别成 s 查询参数的一部分。也可能引起非法的注入，比如：

	var s = 'root&deleteFlag=1';
	var uri = 'http://xxx.com/name=' + s;
	console.log(encodeURI(uri)); // http://xxx.com/name=root&deleteFlag=1

### `encodeURIComponent`

[`encodeURIComponent()`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent) 与 `encodeURI()` 基本作用相同，表示对字符串转义。

但与 `encodeURI(URI)` 不同， `encodeURIComponent(str)` 的方法参数为 `str`，意味着它并不是设计用于编码整个 URI，而是只对某一个部分（component）进行编码。它可以转义更多的字符，包括 URI 保留字符。它也有不能转义的字符，为：字母，数字，“-”，“_”，“.”，“!”，“~”，“'”，“（”，“）”。

有些时候，可能希望对这些无法转义的字符也进行转义，以获得服务器端一致的解析效果，或彻底防止注入发生（比如，“-”，“'”，可能被用作构造 SQL 注入）。 mozilla 上有个简单函数，可能用来做这种替换：

	// 替换 ! ' ( ) 成 escape 字符串，替换 * 为 %2A
	function fixedEncodeURIComponent (str) {
		return encodeURIComponent(str).replace(/[!'()]/g, escape).replace(/\*/g, "%2A");
	}

### 总结

个人认为，比较好的编程实践：

 1. 没有必要使用 `escape` 和 `encodeURI` 来做转义，使用 `encodeURIComponent` 是最佳选择。
 2. GET 方式查询字符串，出现非 ASCII 字符时，通过 `encodeURIComponent` 进行转码，然后提交，而不要直接提交原始的样子，服务器端调用相应的 `decode` API 进行解码，例如 Java 为 [`URLDecode`](http://docs.oracle.com/javase/7/docs/api/java/net/URLDecoder.html) 的 `decode` 方法。
	
	> **不要直接提交原始的样子**
	> 
	> 比如，查询字符串为“中文”，GET 方式直接提交时，实际的编码方式和编码后结果是操作系统（页面无 `<meta>`）和页面编码（`<meta>` 中设置）相关的。比如，`<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >`，直接提交“中文”实际编码为“%E4%B8%AD%E6%96%87”；`<meta http-equiv="Content-Type" content="text/html; charset=GBK" >`，直接提交“中文”实际编码为“%D6%D0%CE%C4”（Chrome/Firefox 控制台查看 GET 方式提交时的 HEADER）。而直接在 javascript 中调用 `encodeURI` 或 `encodeURIComponent` 则不会跟页面或操作系统编码绑定，而是直接转成 **UTF-8** 的序列。服务器端在一致性处理上，会比较方便（不必担心客户端编码可能造成干扰）。
	> 
	> 当然，最佳的编程实践，还是同时设置 `<meta>` 标签 *charset* 值与服务器上期望一致。
	> 
	> > 其实，POST 方式在提交查询参数时，编码规则和 GET 方式是一样的。
	> 
	> **PS. Java 转码方式**
	> 
	> GET 方式，直接提交：
	
		String q = request.getParameter("q");
		q = new String(q.getBytes("ISO-8859-1"), "<meta charset>" or "OS default");
	
	> GET 方式，调用 encode：
	
		String q = request.getParameter("q");
		q = URLDecoder.decode(q, "<meta charset>" or "OS default");

 3. 既然有 *encode*，那么自然会有对应的 *decode*，JS 中为 [`decodeURI()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/decodeURI) 和 [`decodeURIComponent`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/decodeURIComponent)，看了上述之后，理解 `decode` 将会是很简单的事情。只不过，实践中不太会用到他们，因为我们一般是会直接输出原始结果交由浏览器渲染，同样包括 ajax 请求的 reponse。