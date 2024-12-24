---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: https://cover.sli.dev
highlighter: shiki
# some information about your slides (markdown enabled)
title: 10-System-IO
info: |
  ICS 2024 Fall Slides
  Presented by Arthals
titleTemplate: '%s'
# apply unocss classes to the current slide
class: text-center
# https://sli.dev/features/drawing
drawings:
  persist: false
# slide transition: https://sli.dev/guide/animations.html#slide-transitions
transition: fade-out
# enable MDC Syntax: https://sli.dev/features/mdc
mdc: true
layout: cover
coverBackgroundUrl: /10-System-IO/cover.jpg
---

# 系统级 I/O {.font-bold}

2110306206 预防医学&信双 卓致用{.!text-gray-200}

<div class="pt-12  text-gray-1">
  <span @click="$slidev.nav.next" class="px-2 py-1 rounded cursor-pointer" hover="bg-white bg-opacity-10">
    Here we go! <carbon:arrow-right class="inline"/>
  </span>
</div>

<style>
  div{
   @apply text-gray-2;
  }
</style>

---

# Unix I/O

Unix I/O

- 所有的 I/O 设备都被模型化为 **文件**{.text-sky-5}
- 输入输出 **等价于文件的读写**{.text-sky-5}

---

# 文件的读写

File Read/Write

- 每次打开文件，都会有唯一非负整数 **文件描述符**{.text-sky-5} 与之对应
- Shell 创建时的默认三个文件描述符：
  - `0` 标准输入 `STDIN_FILENO`
  - `1` 标准输出 `STDOUT_FILENO`
  - `2` 标准错误 `STDERR_FILENO`
- 文件的读：复制文件的内容到内存，可能会遇到 EOF（End of File）
- 文件的写：复制内存的内容到文件

![open](/10-System-IO/open.svg){.h-50.mx-auto}

---

# 文件类型

File Type

- 普通文件 `-`：文本文件和二进制文件
- 目录文件 `d`：文件夹 / 目录文件，一个目录至少含有两个条目，一个指向自己本身（`.`），一个指向其父亲（`..`）
- 套接字文件 `s`：和另外一个进程进行跨网络通信的 **文件**{.text-sky-5}

```bash
cd /var/run
eza -l --grid # eza 是一个 ls 的替代品，功能更强大
cd ~
mkdir test && cd test
eza -laa # -l 列出文件的详细信息，-a 列出所有文件，包括隐藏文件，两个 -a 启用对 . / .. 的显示
```

**不要认为套接字这个拗口的词汇和文件有什么本质的不同，它就是一层抽象，使得网络通信和文件一样**

会略有差异，但是概念是相通的。在学未来的网络编程时，尤其需要明确这一点。

---

# 文件路径

File Path

- 绝对路径：从根目录 `/` 开始的路径
- 相对路径：从当前目录 `.` 开始的路径

尝试运行：

```bash
ls / # 列出根目录下的所有文件
ls . # 列出当前目录下的所有文件
```

其他路径：

- `..` 父目录
- `~` 当前用户的主目录，在 macOS / Linux 中是 `/Users/username`

---

# 目录层次结构

Directory Hierarchy

![tree](/10-System-IO/tree.png){.h-60.mx-auto}

你可以使用 `tree` 命令来查看当前目录的层次结构：

```bash
tree
# 如果太多，可以使用 -L 2 来限制层级
tree -L 2
```

---

# 打开文件

Open File

```c
int open(const char *pathname, int flags, mode_t mode);
```

参数：

- `pathname` 文件路径，绝对路径或当前路径下文件名（可以使用相对路径）
- `flags` 打开文件的方式
- `mode` 新文件的权限

返回值：`int`

- 成功：返回文件描述符
- 失败：返回 `-1`，并设置 `errno`


---

# 打开文件 - Flags

Open File - Flags

<div text-sm>

| 常量 | 含义 |
| --- | --- |
| `O_RDONLY` | 只读打开，Read Only |
| `O_WRONLY` | 只写打开，Write Only |
| `O_RDWR` | 读写打开，Read Write |
| `O_CREAT` | 如果文件不存在，则创建它，需要 `mode`，Create |
| `O_TRUNC` | 如果文件存在，且以写模式（`O_WRONLY` 或 `O_RDWR`）打开，则将其长度截断为 0，Truncate |
| `O_APPEND` | 在每次写操作前，设置文件位置到文件结尾处（是写操作前而不是就在打开文件时），Append |


前三个必选其一，后三个可选。类似上节课讲的，我们可以用 `|` 来组合多个标志。

如 `O_RDWRO | O_CREAT | O_TRUNC` 表示以读写模式打开文件，如果文件不存在则创建它，若存在则截断文件长度为 0。

</div>

---

# 打开文件 - Mode

Open File - Mode

新文件的访问权限位，每个进程还额外有 `umask` 掩码，用于限制新文件的权限。

当进程创建新文件时，新文件的权限位是 `mode & ~umask`。

```bash
eza -l ~
```

假设得到结果 `drwxrwxr-x`，其代表：

```
d | rwx | rwx | r-x
```

- 文件类型：目录
- 文件所有者权限：读、写、执行
- 文件所有者所在组权限：读、写、执行
- 其他用户权限：读、执行

---

# 打开文件 - Mode

Open File - Mode


`umask` 值是一个三位八进制数，每一位分别对应文件权限中的用户（owner）、组（group）和其他人（others）。它表示要从默认权限中屏蔽的位。

```c
#include <sys/types.h>
#include <sys/stat.h>

mode_t umask(mode_t mask);
```

---

# 打开文件 - Mode

Open File - Mode

`mode` 值是一个四位八进制数，一般使用常量来指定，在创建新文件时生效，其组成包括：


- 特殊权限位
- 文件所有者权限
- 文件所有者所在组权限
- 其他用户权限


常量：

- `S_IRUSR`、`S_IWUSR`、`S_IXUSR`：用户（`USR`，user）对文件的读/写/执行权限。
- `S_IRGRP`、`S_IWGRP`、`S_IXGRP`：用户组（`GRP`，group）对文件的读/写/执行权限。
- `S_IROTH`、`S_IWOTH`、`S_IXOTH`：其他人（`OTH`，other）对文件的读/写/执行权限。

---

# 关闭文件

Close File

```c
int close(int fd);
```

返回值：`int`

- 成功：返回 `0`
- 失败：返回 `-1`，并设置 `errno`

关闭一个已经关闭的描述符会出错。

无论进程因为什么而终止，内核都会关闭所有打开的文件并释放内存资源。

---

# 读和写

Read and Write

<div grid="~ cols-2 gap-12">
<div>

### 读 `read`

```c
ssize_t read(int fd, void *buf, size_t n);
```

- `fd` 文件描述符
- `buf` 缓冲区，用于存储读取到的数据
- `n` 读取的字节数



返回值：`ssize_t`（有符号整数，signed size_t）

- 成功：**返回读取的字节数**{.text-sky-5}
- 读到 EOF：返回 `0` <span class="text-sm text-gray-5">也不算失败，但也不算完全正常？</span>
- 失败：返回 `-1`，并设置 `errno`

</div>

<div>

### 写 `write`

```c
ssize_t write(int fd, const void *buf, size_t n);
```

- `fd` 文件描述符
- `buf` 缓冲区，用于存储写入的数据
- `n` 写入的字节数

返回值：`ssize_t`（有符号整数，signed size_t）

- 成功：**返回写入的字节数**{.text-sky-5}
- 失败：返回 `-1`，并设置 `errno`

</div>
</div>

**当返回非负，但是小于预期的 $n$ 时，表示写入操作只成功了一部分，我们称之为** **不足值**{.text-sky-5}

---

# 不足值

Short Count

不足值：$-1 < \text{ret} < n$

不足值的出现原因：

- 读到 EOF：（假设 $n = 50$）此次返回到 EOF 时已读取的数量 $< 50$，比如 $20$，下次再读取时返回 $0$
- 从终端传输文本行：一般设置读取的字节数较大，但是每次读取的文本行可能较短，所以返回的字节数会小于请求的字节数
- 读和写网络套接字（Socket）：如果打开的文件对应于网络套接字，那么内部缓冲约束和较长的网络延迟会引起 `read` 和 `write` 返回不足值（回忆一下信号中断）

由于不足值的存在，为了能够保证输入输出能够正常的、按照预期的完成（主要是情况 3），我们可能需要反复、多次调用 `read` 和 `write`。


---

# RIO 包

Robust I/O

让你的 I/O 健壮一点~

---

# RIO - 不带缓冲的读

`rio_readn`

<div grid="~ cols-2 gap-8">
<div relative>

<div :class="$clicks==0 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

`rio_readn` 函数用于从文件描述符 `fd` 中读取 `n` 个字节到缓冲区 `usrbuf` 中。

它是 **无缓冲** 的，与 `read` 相比，多了对不足值的处理。

注意鉴别这里的 **无缓冲** 和参数之一的 **缓冲区**。

后者的定义是，内存中即将存储读入数据的区域。

前者的定义是，有没有对 `read` 这个函数本身实现缓冲机制（我会在后面将带缓冲的版本让大家对比理解）。

</div>

<div :class="$clicks==1 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

首先，设置变量：

- `nleft` 为请求的字节数
- `bufp` 为缓冲区指针
- `nread` 变量用于存储每次读取的字节数

</div>

<div :class="$clicks==2 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

循环读入（多次尝试），正常情况下唯一的退出条件是 `nleft <= 0`。

</div>

<div :class="$clicks==3 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

每次调用 `read` 来尝试读入 `nleft` 个字节。

`nread` 中会存储实际读入的字节数。

</div>

<div :class="$clicks==4 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

当 `nread` 小于 0 时，说明返回值是 `-1`，代表出错。

如果 `errno` 被设置为 `EINTR`，表示被信号处理程序中断（`interrupt`）返回，此时需要将 `nread` 设置为 `0`。

这是因为，`errno == EINTR` 表示这次调用确实没有读取任何数据（如缺页异常），文件指针没有发生变化，我们即将重试此次操作。

如果 `errno` 不是 `EINTR`，则说明读取失败是由于 `read()` 本身导致的，此时我们放弃继续读取，返回代表出错的 `-1`，并保留 `errno` 不变。一些可能情况：

1. `EBADF`：`fd` 不是有效的文件描述符，或者文件描述符没有以读取模式打开。
2. `EFAULT`：`bufp` 指向的内存区域不可访问。
3. `EINVAL`：无效参数，例如 `fd` 不是有效的文件描述符。

</div>

<div :class="$clicks==5 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

回忆我们刚才说的，当遇到 `EOF` 时，`read` 会先返回此次读取到的字节数，再次调用 `read` 则会返回 `0`。

这两句判断就对应再次调用 `read` 的情况。

</div>

<div :class="$clicks==6 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

望文生义，我们还需要读取的字数是 `nleft - nread`，文件指针也要移动 `nread` 个字节。

还是举 EOF 那个情况：当遇到 `EOF` 时，`read` 会先返回此次读取到的字节数，再次调用 `read` 则会返回 `0`。

这对应先前那次调用 `read` 的情况。

（但其实这个例子不是唯一的，涉及套接字的话，可能多次返回，每次返回的 `nread` 都只是 `nleft` 的一部分）

</div>

<div :class="$clicks==7 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

运行到这的唯二两种可能：

- `nleft == 0`，完全读入成功，返回 `n`
- EOF 导致退出，返回 `n - nleft`，即实际读入的字节数。

</div>

</div>

<div>

```c{all|3-5|7-18|8|8-13|14-15|16-17|7,14,15,19}{at:1}
ssize_t rio_readn(int fd, void *usrbuf, size_t n)
{
    size_t nleft = n;
    ssize_t nread;
    char *bufp = usrbuf;

    while (nleft > 0) {
        if ((nread = read(fd, bufp, nleft)) < 0) {
            if (errno == EINTR) /* 被信号处理程序中断返回 */
                nread = 0;      /* 再次调用 read() */
            else
                return -1;      /* read() 设置了 errno */
        }
        else if (nread == 0)
            break;              /* EOF */
        nleft -= nread;
        bufp += nread;
    }
    return (n - nleft);         /* 返回值 >= 0 */
}
```

</div>
</div>

---

# RIO - 不带缓冲的写

`rio_writen`

<div grid="~ cols-2 gap-8">
<div text-sm>

`rio_writen` 函数用于从文件描述符 `fd` 中写入 `n` 个字节到缓冲区 `usrbuf` 中。

它是 **无缓冲** 的，与 `write` 相比，多了对不足值的处理。

和 `readn` 行为类似，但是没有了对于 EOF 的处理，所以永远不会返回不足值（要么返回错误 `-1`，要么返回 `n`）。

</div>

<div>

```c
ssize_t rio_writen(int fd, void *usrbuf, size_t n)
{
    size_t nleft = n;
    ssize_t nwritten;
    char *bufp = usrbuf;

    while (nleft > 0) {
        if ((nwritten = write(fd, bufp, nleft)) <= 0) {
            if (errno == EINTR) /* 被信号处理程序中断返回 */
                nwritten = 0;   /* 再次调用 write() */
            else
                return -1;      /* write() 设置了 errno */
        }
        nleft -= nwritten;
        bufp += nwritten;
    }
    return n;                   /* 返回原始请求的字节数 */
}
```


</div>
</div>

---

# RIO - 带缓冲的读

`rio_read` / `rio_readnb` / `rio_readlineb`

<div grid="~ cols-3 gap-8">
<div relative>

<div :class="$clicks==0 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

函数组合定义：

- n 是读 n 个字节
- b 是 buffer 的意思，代表使用缓冲区

</div>

<div :class="$clicks==1 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

#### 带缓冲什么意思呢？

假设我们已经知道，要以连续进行很多次 `read` 操作，每次读 $n$ 个字节。

那么，考虑如下两种方式：

1. 调用多次 `read` 函数，每次读取 $n$ 个字节。
2. 一次读取很多字节到内存，然后每次读的时候到内存中取 $n$ 个字节。

这两种方式，后者由于可以直接在内存中取数据，**减少实际系统调用的次数**{.text-sky-5}（回想一下，系统调用函数总是需要陷入内核，远比用户调用函数慢），从而提高了效率。

</div>

<div :class="$clicks==2 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

#### `rio_t`


为了能够实现这个涉及，我们需要声明一个结构体 `rio_t`，用于存储缓冲区信息：

- `rio_fd` 文件描述符
- `rio_cnt` 缓冲区中未读字节数
- `rio_bufptr` 指向缓冲区内下一个未读字节的指针
- `rio_buf` 缓冲区本体

缓冲区的意义：**减少对于 `read` 的系统调用次数。**{.text-sky-5}

</div>

<div :class="$clicks==3 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

#### `rio_read`

这个函数和先前讲过的 `rio_readn` 函数有一些类似，支持不足值的处理。

且在此之上，它支持了缓冲区的设计，通过移动 `rp->rio_bufptr` 而不是使用 `nleft` 来指明当前读取到的位置。

</div>

<div :class="$clicks==4 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

#### `rio_read`

重点关注在 13 行，它真实调用 `read` 函数的时候，并不是读了 `n` 个字节，而是读了 `sizeof(rp->rio_buf)` 个字节。

这代表它会尝试将缓冲区填满，而不是仅仅读取 `n` 个字节。

26 行，`memcpy` 函数将 `rio_t` 内缓冲区的数据复制到实际想要存到的 `usrbuf` 中。

</div>

<div :class="$clicks==5 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

#### `rio_readnb`

这个函数和先前讲过的 `rio_readn` 函数完全类似，只不过迁移到了缓冲区的实现。

注意第 38 行，这里用的是刚才讲的 `rio_read` 函数，而不是 `read` 函数。

这代表，它读取的目标是缓冲区，而不是文件。

</div>

<div :class="$clicks==6 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

#### `rio_readlineb`

`rio_readlineb` 函数从文件 `rp` 读出下一个文本行（包括结尾的换行符），将它复制到内存位置 `usrbuf`，并且用 `NULL`（零）字符来结束这个文本行。

`rio_readlineb` 函数最多读 `maxlen-1` 个字节，余下的一个字符留给结尾的 `NULL` 字符。

超过 `maxlen-1` 字节的文本行会被截断。

**由于核心的 57 行实现是基于 `rio_read` 函数的，所以我们可以肆无忌惮地使用它，每次只读 1 个字节，而不用顾虑系统调用次数。**{.text-sky-5}

</div>

</div>

<div col-span-2>

```c{all|1-7|1-7|9-30|9-30|32-49|51-71}{lines:true, maxHeight:'400px'}
// rio_t - 自定义的带缓冲区的读入结构体
typedef struct {
    int rio_fd;                /* 描述符 */
    ssize_t rio_cnt;           /* 缓冲区中未读字节数 */
    char *rio_bufptr;          /* 下一个未读字节 */
    char rio_buf[RIO_BUFSIZE]; /* 缓冲区 */
} rio_t;

// rio_read - 健壮地读入 n 个字节，不带缓冲区
static ssize_t rio_read(rio_t *rp, char *usrbuf, size_t n) {
    int cnt;
    while (rp->rio_cnt <= 0) { /* 重新填充缓冲区 */
        rp->rio_cnt = read(rp->rio_fd, rp->rio_buf, sizeof(rp->rio_buf));
        if (rp->rio_cnt < 0) {
            if (errno != EINTR) /* 由于信号处理程序返回而中断 */
                return -1;
        } else if (rp->rio_cnt == 0) /* EOF */
            return 0;
        else
            rp->rio_bufptr = rp->rio_buf; /* 重新初始化缓冲区指针 */
    }
    /* 复制 min(n, rp->rio_cnt) 个字节到用户缓冲区 */
    cnt = n;
    if (rp->rio_cnt < n)
        cnt = rp->rio_cnt;
    memcpy(usrbuf, rp->rio_bufptr, cnt);
    rp->rio_bufptr += cnt;
    rp->rio_cnt -= cnt;
    return cnt;
}

// rio_readnb - 健壮地读入 n 个字节，带缓冲区
ssize_t rio_readnb(rio_t *rp, void *usrbuf, size_t n) {
    size_t nleft = n;
    ssize_t nread;
    char *bufp = usrbuf;
    while (nleft > 0) {
        if ((nread = rio_read(rp, bufp, nleft)) < 0) {
            if (errno == EINTR) /* 由于信号处理程序返回而中断 */
                nread = 0;     /* 再次调用rio_read()函数 */
            else
                return -1; /* 由rio_read()设置的errno */
        } else if (nread == 0)
            break; /* EOF */
        nleft -= nread;
        bufp += nread;
    }
    return (n - nleft); /* 返回值 >= 0 */
}

// rio_readlineb - 健壮地读入一行，带缓冲区
ssize_t rio_readlineb(rio_t *rp, void *usrbuf, size_t maxlen) {
    int n, rc;
    char c, *bufp = usrbuf;

    for (n = 1; n < maxlen; n++) {
        if ((rc = rio_read(rp, &c, 1)) == 1) {
            *bufp++ = c;
            if (c == '\n')
                break;
        } else if (rc == 0) {
            if (n == 1)
                return 0; /* EOF，没有读入任何数据 */
            else
                break; /* EOF，读入了部分数据 */
        } else
            return -1; /* 错误 */
    }
    *bufp = 0;
    return n;
}
```


</div>
</div>

---

# RIO 总结

Robust I/O Summary

缓冲区的实现：基于 `rio_t` 结构体，在此基础上封装出了 `rio_read` / `rio_readinitb` / `rio_readnb` / `rio_readlineb` 函数。

缓冲区的思想：通过一次读入很多字节，实现一个缓存机制，后续再读直接从缓存中取，从而减少系统调用次数。

不带缓冲区的实现：实现了对不足值的处理，包括 EOF / 系统调用中断等，在此基础上封装出了 `rio_readn` / `rio_writen` 函数。

带缓冲的版本和不带缓冲的版本，在实现上有很多类似的地方，**但一定不能混用。**{.text-sky-5}

例：`rio_readlineb` 和 `rio_readnb` 可以混用，但不能和 `rio_readn` 混用。

---

# 共享文件

Shared Files

<div text-sm>

| 数据结构       | 描述                             | 共享性                    | 关键内容                                  |
| -------------- | -------------------------------- | ------------------------- | ----------------------------------------- |
| 描述符表       | 每个进程都有独立的描述符表       | 不共享                    | 描述符表项由文件描述符索引，指向文件表项  |
| 文件表         | 表示打开文件的集合               | 所有进程共享              | 文件位置、引用计数、v-node 指针            |
| v-node 表      | 包含文件的 `stat` 结构信息       | 所有进程共享              | `st_mode` 和 `st_size`                    |

这么类比着记：

- 描述表，每个进程单独一个，符合直觉
- v-node 是类的声明，一个真实文件只有一个，所有进程共享
- 打开文件表是类的实例，所有进程共享，每个实例必然有与之对应的声明（v-node），但是多个实例可以指向同一个声明（v-node）
- 多个进程可以共用同一个文件表，类比他们共用相同的实例。

</div>

---
clicks: 2
---

# 共享文件

Shared Files

<div grid="~ cols-3 gap-8">
<div text-sm>

打开文件表和 v-node 表的最核心差异：

- 打开文件表的每一项 **对应一次打开**{.text-sky-5}
- v-node 表的每一项 **对应一个文件**{.text-sky-5}

<div v-click>

由于一个文件可以打开多次，所以可以有多个打开文件表项指向同一个 v-node 表项。

</div>

<div v-click>

由于多个进程可以共享一次打开，所以有了打开文件表中的 `refcnt`，多个进程的描述表中的描述符可以对应同一个打开文件表项（如父子进程）。

</div>

</div>

<div col-span-2 relative>

<div :class="$clicks==0 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

![shared_files_1](/10-System-IO/shared_files_1.png)

</div>

<div :class="$clicks==1 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

![shared_files_2](/10-System-IO/shared_files_2.png)

</div>

<div :class="$clicks==2 ? 'opacity-100' : 'opacity-0'" transition duration-200 absolute text-sm>

![shared_files_3](/10-System-IO/shared_files_3.png)

</div>

</div>
</div>



---

# 共享文件 - 总结

Shared Files - Summary

<div grid="~ cols-3 gap-6" text-sm>
<div>


#### 描述符表{.my-4}

- 每个进程都有独立的描述符表
- 描述符表的表项由进程打开的文件描述符来索引
- 每个打开的描述符表项指向文件表中的一个表项
- **对应一个进程所需要的描述符信息**{.text-sky-5}


</div>

<div>


#### 文件表{.my-4}

- 打开的文件集合由文件表表示，所有进程共享该表。
- 文件表的表项包括：
  - 文件位置：当前文件位置
  - 引用计数 `refcnt`：当前指向该表项的描述符表项数量
  - v-node 指针：指向 v-node 表中对应表项的指针
- 关闭一个描述符会减少相应文件表表项的引用计数
- 内核不会删除文件表表项，直到引用计数为零
- **对应一次打开**{.text-sky-5}



</div>

<div>


#### v-node 表{.my-4}

- v-node 表同样由所有进程共享
- 每个表项包含 `stat` 结构中的大多数信息，包括 `st_mode` 和 `st_size` 成员
- **对应一个文件**{.text-sky-5}

</div>
</div>

---

# I / O 重定向

I / O Redirection

<div grid="~ cols-2 gap-6">
<div>

#### `dup`

```c
int dup(int oldfd);
```

`dup` 用于复制一个文件描述符 `oldfd`，并返回一个新的文件描述符。

新的文件描述符与原来的文件描述符共享同一个文件表项。


</div>

<div>

#### `dup2`

```c
int dup2(int oldfd, int newfd);
```

`dup2` 复制文件描述符 `oldfd` 到 `newfd`。

**注意顺序：是用前面的覆盖后面的，也就是把后面的指向前面**{.text-sky-5}

如果 `newfd` 已经打开，它会首先被关闭。


</div>


<div>

#### 返回值{.my-4}

- 成功时，返回新的文件描述符。
- 失败时，返回 `-1`，并设置 `errno` 以指示错误。

</div>


<div>

#### 返回值{.my-4}

- 成功时，返回 `newfd`。
- 失败时，返回 `-1`，并设置 `errno` 以指示错误。

</div>
</div>

---

# I / O 重定向

I / O Redirection

<div>

![shared_files_4](/10-System-IO/shared_files_4.png)

</div>

---

# I / O 重定向 - 习题

I / O Redirection - Exercise

假设缓冲区足够大，且 `stdout` 只有在关闭文件、执行与 `fflush` 的情况下才会刷新缓冲区。程序运行过程中所有的系统调用均成功。

<div grid="~ cols-3 gap-6">
<div>

```c
// (1)
int main() {
  printf("a");
  fork();
  printf("b");
  fork();
  printf("c");
  return 0;
}
```

</div>

<div>

```c
// (2)
int main() {
  write(1, "a", 1);
  fork();
  write(1, "b", 1);
  fork();
  write(1, "c", 1);
  return 0;
}
```

</div>

<div>

```c
// (3)
int main() {
  printf("a");
  fork();
  write(1, "b", 1);
  fork();
  write(1, "c", 1);
  return 0;
}
```

</div>
</div>

1. 对于（1）号程序，写出它的一个可能的输出？这个可能的输出是唯一的吗？
2. 对于（2）号程序，它的输出中包含\_\_\_个a，\_\_\_个b，\_\_\_个c。输出的第一个字符一定是\_\_\_。
3. 对于（3）号程序，它的输出中包含\_\_\_个a，\_\_\_个b，\_\_\_个c。输出的第一个字符一定是\_\_\_。

---

# I / O 重定向 - 答案

I / O Redirection - Answer

假设缓冲区足够大，且 `stdout` 只有在关闭文件、执行与 `fflush` 的情况下才会刷新缓冲区。程序运行过程中所有的系统调用均成功。

<div grid="~ cols-3 gap-6">
<div>

```c
// (1)
int main() {
  printf("a");
  fork();
  printf("b");
  fork();
  printf("c");
  return 0;
}
```

</div>

<div>

```c
// (2)
int main() {
  write(1, "a", 1);
  fork();
  write(1, "b", 1);
  fork();
  write(1, "c", 1);
  return 0;
}
```

</div>

<div>

```c
// (3)
int main() {
  printf("a");
  fork();
  write(1, "b", 1);
  fork();
  write(1, "c", 1);
  return 0;
}
```

</div>
</div>

1. 对于（1）号程序，写出它的一个可能的输出：`abcabcabcabc`。这个可能的输出是唯一的吗？
否。
2. 对于（2）号程序，它的输出中包含 `1` 个 `a`，`2` 个 `b`，`4` 个 `c`。输出的第一个字符一定是 `a`。
3. 对于（3）号程序，它的输出中包含 `4` 个 `a`，`2` 个 `b`，`4` 个 `c`。输出的第一个字符一定是 `b`。

<div v-click>

Keypoint：**`printf` 有缓冲区，父子进程共享；`write` 由于直接向文件输出，所以没有缓冲区。**{.text-sky-5}

</div>

<!-- 

1. 对于(1)号程序：
    - `printf` 使用的是标准输出缓冲区，在 `fork` 之前，缓冲区中的内容不会被刷新。因此，每次 `fork` 会复制父进程中未刷新缓冲区的内容，导致输出的结果包含多次重复。
    - `fork` 调用会产生新的进程，每个新的进程都会从 `fork` 处继续执行，因此每次 `fork` 后会产生新的输出。
    - 这个程序的输出并不是唯一的，因为 `printf` 的输出顺序可能会因为进程调度的不同而不同。
    - 但题目中给出的 `abcabcabcabc` 是一个可能的输出。

2. 对于(2)号程序：
    - `write` 是直接输出到文件描述符，不经过缓冲区，因此每次 `fork` 后，新的进程不会重复之前的输出。
    - 第一个 `fork` 后有两个进程，第二个 `fork` 后有四个进程，因此最终会有 1 个 `a`，2 个 `b`，4 个 `c`。
    - 由于 `write` 是直接输出，因此第一个字符一定是 `a`。

3. 对于(3)号程序：
    - `printf("a")` 会将 `a` 写入缓冲区，但不会立即输出。
    - 第一个 `fork` 之后，缓冲区中的 `a` 会被复制到子进程中，因此会有两个进程，每个进程的缓冲区中都有一个 `a`。
    - `write(1, "b", 1)` 会直接输出 `b`，因此会有两个 `b`。
    - 第二个 `fork` 后会有四个进程，每个进程都会输出 `c`，因此会有四个 `c`。
    - 由于 `write` 直接输出，因此第一个字符一定是 `b`。

 -->

---
layout: center
---


<div flex="~ gap-16"  mt-2 justify-center items-center>


<div  w-fit h-fit mb-2>

# THANKS

Made by Arthals with ❤️ ~~and hair~~ {.mb-4}

[Blog](https://arthals.ink/) · [GitHub](https://github.com/zhuozhiyongde) · [Bilibili](https://space.bilibili.com/203396427)

</div>

![wechat](/wechat.jpg){.w-40.rounded-md}

</div>
