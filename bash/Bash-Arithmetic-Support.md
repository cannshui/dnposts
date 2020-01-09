## Bash 算术运算支持

一定要亲自总结下 Bash 中的算术运算支持了，每次编写脚本时候都要重新去查一遍，太不方便。

因为 Shell 我用最多的是 Bash，所以，将只记录 Bash 中的支持，其他 Shell 未做测试。

涉及算术运算时，我们经常直接用到的有 `((...))`，`$((...))`，`$[...]`，`let`，`expr`，下面分别说明。

#### 1. `((...))` [算术逻辑](https://wiki-dev.bash-hackers.org/syntax/ccmd/arithmetic_eval)

双括号将计算表达式结果，并根据结果设置 `exit code` 值，表达式本身的结果将被忽略，仅仅是忽略表达式的结果，如果对表达式中的变量进行了修改，则变量的变化仍旧是保留的（见下例循环）。可直接用在需要逻辑判断的地方，如 `if` 语句和 `while` 循环等。

表达式结果与 `exit code` 的对应规则：

 - 如果表达式结果为 0，则 `exit code` 为 1，逻辑结果为 `FALSE`；
 - 如果表达式结果不为 0，则 `exit code` 为 0，逻辑结果为 `TRUE`。

比如：

    # 1 - 1 = 0，exit code 1，FALSE，将会输出 1
    $ ((1 - 1)) ; echo $?

    # 1 + 1 = 2 不等于 0，exit code 0，TRUE，将会输出 0
    $ ((1 + 1)) ; echo $?

    # 1 - 9 = -8 不等于 0，exit code 0，TRUE，将会输出 0
    $ ((1 - 9)) ; echo $?

并不难理解。实际使用时可能会是下面的样子：

    MY_TEST_FLAG=0

    if ((MY_TEST_FLAG)); then
        echo "MY_TEST_FLAG is ON"
    else
        echo "MY_TEST_FLAG is OFF"
    fi

    MY_TEST_FLAG=10
    while ((--MY_TEST_FLAG)); do
        echo "MY_TEST_FLAG ${MY_TEST_FLAG} is ON"
    done

#### 2. `$((...))` [算术扩展](http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_03_04.html)

算术扩展在计算算术表达式的基础上，会保留计算结果，而不会仅保留 TRUE 和 FALSE 结果。表达式作为一个被双引号包括的整体看待，表达式中已有的双引号不做特殊处理。表达式中的所有标记（token）都将首先进行参数扩展、命令替换、引用删除。算术扩展只支持有符号整形运算，且不支持浮点数结果。整形数只支持 ANSI C 中的十进制常量，八进制常量和十六进制常量表示。

列举几个直观示例：

    # 直接对操作数做除法，结果为 6 余 1，且仅保留整数 6，输出 6
    $ i=$((19 / 3)) && echo $i

    $ x=3
    # 参数扩展后，做除法，19 / 3，结果为 6 余 1，且仅保留整数 6，输出 6
    $ i=$((19 / $x)) && echo $i

    # 命令替换后，做除法，19 / 3，结果为 6 余 1，且仅保留整数 6，输出 6
    $ i=$((19 % $(echo -n "abc" | wc -m))) && echo $i

相比 `((...))` 算术逻辑，主要区别是是否保留计算结果。

##### 2.1 `$[...]` [算术扩展（已废弃）](https://stackoverflow.com/a/2415777/3701431)

`$[]` 是老的的算术扩展语法，已废弃，没有细究的必要了。注意不要和 `[ ]` test 运算弄混即可。 

#### 3. `let` [Bash 内建命令](https://wiki-dev.bash-hackers.org/commands/builtin/let?s[]=let)

语法：

    let expr1 [expr2 ...]

从左到右顺序执行算术表达式，并设置 `exit code`，规则同 `((...))`。任何使用 `let` 的地方都可以被替换成 `(())`，且更加直观符合“算术表达式”的形式。所以，没有理由去使用 `let` 了。

#### 4. `expr` 算术运算命令

语法：

    expr operand1 operator1 operand2[ operator2 operand3 ...]

`expr` 是一个古老的 POSIX 命令，执行算术运算。每个操作符（`operator`）两边必须要留空白，否则不会识别为可计算的表达式。有 `$((...))` 的存在，`expr` 也没有使用的必要了。

总结：以后的 Bash 编程中，分不同场景，应使用算术逻辑 `((...))` 和算术扩展 `$((...))`。

不足之处，持续改进。

**参考：**

 - [bash - Difference between let, expr and $\[\] - Ask Ubuntu](https://askubuntu.com/questions/939294/difference-between-let-expr-and)（这个问题直接激发我做这个总结。）
 - [Shell expansion](http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_03_04.html)
 - [The Bash Hackers Wiki \[Bash Hackers Wiki\]](https://wiki-dev.bash-hackers.org/)