## 编写 Bash 脚本的最佳实践

 > 独立项目参见 [bash3boilerplate.sh](http://bash3boilerplate.sh/)

我最近在 twitter 上发布了一些过去多年所总结的最佳 bash 编程实践，收到了一些不错的反馈。我决定把他们都总结在这篇博客中。如下：

 1. 使用长选项（`logger --priority` VS `logger -p`）。如果你在 CLI 中使用，缩写对与提高效率很有意义。但是当编写可重用的脚本时，多输入一些字符将显著提高可读性。并且可以避免将来的协作者再去查阅 `man` 手册。
 2. 脚本起始设置 `set -o errexit`（简写 `set -e`），当脚本中某个命令执行失败时立刻退出脚本。
 3. 命令后添加 `|| true` 如果允许其执行失败。
 4. 脚本起始设置 `set -o nounset`（简写 `set -u`），当脚本中使用未经定义的变量时，执行失败立刻退出脚本。
 5. 脚本起始设置 `set -o xtrace`（简写 `set -x`），追踪执行了什么。调试时十分有用。
 6. 脚本起始设置 `set -o pipefail`，可以捕获 `mysqldump` 的失败，如 `mysqldump | gzip`。脚本的退出值为最后一个执行失败的命令的 exit-value。
 7. `#!/usr/bin/env bash` 比 `#!/bin/bash` 更具移植性。
 8. 不要使用 `#!/usr/bin/env bash -e`（VS `set -e`），因为如果通过 `bash ./script.sh` 执行脚本时，将会忽略“预设的命令失败时退出”行为。
 9. 用 `{}` 将变量包括起来。否则 bash 将会访问 `/srv/$ENVIRONMENT_app` 中的 `$ENVIRONMENT_app`，而你的本意是 `/srv/${ENVIRONMENT}_app`。
 10. 不需要使用两个等于号来检查相等性，如 `if [ "${NAME}" = "Kevin" ]`。
 11. 将变量包括在 `"` 中，如 `if [ "${NAME}" = "Kevin" ]`，因为当 `$NAME` 没有声明时，它将是空值，bash 将会抛出语法错误（同样参见 `nounset`）。
 12. 使如果变量可以是未定义的，用 `:-` 来进行变量检查。如：`if [ "${NAME:-}" = "Kevin" ]`，当未定义 `NAME` 时，将会设置 `$NAME` 为空。也可以设置它为 `noname`，如 `if [ "${NAME:-noname}" = "Kevin" ]`。
 13. 在当前脚本头部设置魔法变量、`basename`、目录等，可以方便后续使用。

总结，为什么不像下面这样开始你的脚本文件呢：

    #!/usr/bin/env bash
    # Bash3 Boilerplate. Copyright (c) 2014, kvz.io

    set -o errexit
    set -o pipefail
    set -o nounset
    # set -o xtrace

    # Set magic variables for current file & dir
    __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
    __base="$(basename ${__file} .sh)"
    __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

    arg1="${1:-}"

如果你有其他好的编程实践，分享吧，然后我会加入到这篇博客中。

**原文：**[Best Practices for Writing Bash Scripts](http://kvz.io/blog/2013/11/21/bash-best-practices/)
