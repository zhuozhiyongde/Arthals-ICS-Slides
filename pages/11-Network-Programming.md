---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: https://cover.sli.dev
highlighter: shiki
# some information about your slides (markdown enabled)
title: 11-Network-Programming
info: |
  ICS 2024 Fall Slides
  Presented by Arthals
presenter: false
download: true
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
coverBackgroundUrl: /11-Network-Programming/cover.jpg
---

# 网络编程 {.font-bold}

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

# 客户端 - 服务端模型

Client - Server Model

![client-server](/11-Network-Programming/client_server.png){.mx-auto}

客户端和服务端是 **进程**{.text-sky-5}，而不是 **主机**，它们可以在同一台主机上，也可以在不同的主机上。

<span class="text-sm text-gray-5">

但是一般而言，你可以这么理解网络：到另一台计算机上获取文件（资源）

</span>

---

# 网络

Network

<div grid="~ cols-2 gap-8">
<div>

网络是一种 **I/O**{.text-sky-5} 设备，通常使用 DMA 传输。

网络是按照地理远近组成的层次系统。

</div>

<div>

![network_io](/11-Network-Programming/network_io.png){.mx-auto}

</div>
</div>

---

<div grid="~ cols-2 gap-8">
<div text-sm>


# 网络

Network

#### **局域网**（Local Area Network，LAN）

以太网（Ethernet）是一种 LAN 技术

- 主机
- 集线器（Hub）：不加分辨地转发到所有端口
- 桥（Bridge）：存在分配算法，有选择性地转发

LAN 帧 = LAN 帧头 + 互联网络包（有效载荷）

<div mt-4/>

#### **广域网**（Wide Area Network，WAN）

WAN 由路由器连接若干 LAN 组成。

- 路由器（Router）：每台路由器对它所连接到的每个网络都有一个适配器（端口）

互联网络包 = 互联网络包头 + 用户数据（有效载荷）


</div>

<div flex flex-col justify-center items-center h-full>

![lan](/11-Network-Programming/lan.png){.mx-auto}

<div class="text-sm text-gray-5 mx-auto">
桥接 LAN
</div>

![wan](/11-Network-Programming/wan.png){.mx-auto}

<div class="text-sm text-gray-5 mx-auto">
WAN
</div>

</div>
</div>


---

# 互联网

Internet

互联网（<span class="text-sky-5">i</span>nternet）：路由器连接若干 LAN 和 WAN

全球 IP 因特网（<span class="text-sky-5">I</span>nternet）：是互联网（internet）的具体实现

### 协议软件{.mb-2.mt-8}

协议软件：让主机能够跨过不兼容的网络发送数据

- 命名机制
- 传送机制：运行在主机和路由器上，控制主机和路由器协同工作。<br>一个包是由 **包头** 和 **有效载荷** 组成的，包头包括了传输所需信息，如源主机地址、目的主机地址

---

# 互联网络传输

internet transfer

<div flex gap-4>

<div>

你可能会疑惑：“网络”在哪里？

注意这是一个 internet 而不是 Internet，它只有两个 LAN。

- 帧的有效载荷是互联网络包
- 互联网络包的有效载荷是数据


</div>

<img src="/11-Network-Programming/internet_transfer.png" class="h-80 shrink-0"/>

</div>


---

# 全球 IP 因特网

Internet

<div grid="~ cols-2 gap-8">
<div>


### TCP / IP 协议

- 内核模式运行
- 是协议族，提供不同的功能

Key points：

- 主机集合被映射为一组 32 位的 **IP 地址**{.text-sky-5}
- 这组 IP 地址被映射为一组称为因特网 **域名**{.text-sky-5}（Internet domain name）的标识符
- 因特网主机上的进程能够通过连接（connection）和任何其他因特网主机上的进程通信。

</div>

<div>


![internet](/11-Network-Programming/internet.png){.mx-auto}


</div>
</div>

---

# 全球 IP 因特网

Internet


**IP协议**（Internet Protocol，互联网协议）：

- 它提供了一种基本的命名方法和传递机制（给每台电脑分配一个唯一的 32 位 IP 地址，并负责把数据包（或者叫数据宝，Datagram）送到正确的地址）
- 它是不可靠的（不保证数据包一定会到达目的地，也不负责重传丢失的数据包）

**UDP协议**（User Datagram Protocol，用户数据报协议）是对 IP 协议的扩展：

- 它允许数据包在不同的进程之间传送（就像允许不同的程序之间直接发送数据）
- 它也不保证数据的可靠传输

**TCP协议**（Transmission Control Protocol，传输控制协议）是构建在 IP 协议之上的更复杂的工具：

- 它提供了可靠的 **全双工连接**（就像在两个程序之间建立一条可靠的双向通道，确保数据准确无误地传输）

---

# TCP vs UDP


![tcp_vs_udp](/11-Network-Programming/tcp_vs_udp.png){.mx-auto}

---

# 全球 IP 因特网

Internet

网络字节顺序：**大端法**{.text-sky-5}（可能需要相关函数进行转换）

IP 地址：点分十进制表示法（如 `128.2.194.242`）/ 十六进制 IP 地址（`0x8002c2f2`）

Linux 命令 `hostname -i` 可以查看主机的点分十进制地址

注意：**点分十进制表示法是以字符串形式存储的**

---

# 因特网域名

Internet domain name

<div grid="~ cols-2 gap-8">
<div>

域名是多层次的：`ics.huh.moe` `huh.moe` `moe`

DNS（Domain Name System，域名系统）维护域名集合和 IP 地址的映射

</div>

<div>

![domain](/11-Network-Programming/domain.png){.mx-auto}

</div>
</div>

---

# 因特网域名

Internet domain name

<div grid="~ cols-2 gap-8">
<div>

### 域名{.mb-4}

- 一个域名可以解析到多个 IP 地址
- 一个 IP 地址可以对应多个域名
- 某些合法的域名没有映射到任何 IP 地址
- `localhost` 回送地址 `127.0.0.1`

### 端口{.my-4}

表示服务类型，由 `/etc/services` 文件维护

- 22：SSH 远程登录
- 80：HTTP Web 端口
- 443：HTTPS Web 端口

</div>

<div>

![domain](/11-Network-Programming/domain.png){.mx-auto}

</div>
</div>

---

# 套接字

Socket

套接字（Socket）：提供了一层抽象，让网络 I/O 对于进程而言就像文件 I/O 一样，可以类比文件描述符。

<span class="text-sm text-gray-5">

然而，套接字还是与传统的文件 I/O 有所差异，在使用前需要调用一些特殊函数

</span>

套接字是连接的一个 **端点**{.text-sky-5}，一对套接字组成一个连接。

套接字地址形如 `(IP 地址:端口号)`

套接字对形如 `(客户端 IP:客户端端口, 服务端 IP:服务端端口)`，其唯一确定了一个连接。

![socket_pair](/11-Network-Programming/socket_pair.png){.mx-auto.h-30}

<!-- 

展示 Surge

 -->

---

# 套接字接口

Socket interface

<div grid="~ cols-3 gap-6">
<div>

### 类型定义


套接字接口是一组函数，和 Unix I/O 函数结合创建网络应用。

`sin` 前缀：Socket Internet

IP 地址结构中存放的地址总是以（大端法）网络字节顺序存放的

</div>

<div col-span-2>

```c
/* IP 地址结构，2B */
struct in_addr {
    uint32_t  s_addr; /* 网络字节顺序的地址 (大端序) */
}; 

/* 套接字地址结构，16B */
typedef struct sockaddr SA;
struct sockaddr {
    uint16_t sa_family; /* 协议族，2B，如 AF_INET（IPv4）、AF_INET6（IPv6） */
    char sa_data[14];   /* 存储具体的地址数据，14B，与协议族相关 */
}; // 整体 16B

/* 套接字地址结构，16B */
struct sockaddr_in {
    uint16_t sin_family;   /* 协议族 (总是 AF_INET) */
    uint16_t sin_port;     /* 端口号（网络字节序） */
    struct in_addr sin_addr; /* IP 地址（网络字节序） */
    unsigned char sin_zero[8]; /* 填充到 sizeof(struct sockaddr) = 16B */
}; // 兼容 sockaddr，整体 16B

```

</div>
</div>


---

# 套接字接口

Socket interface

<div grid="~ cols-3 gap-8">
<div text-sm>

### 客户端{.mb-4}

- `getaddrinfo`：获取地址信息
- `socket`：创建套接字
- `connect`：连接到服务器
- `rio_writen`：发送 $n$ 字节数据
- `rio_readlineb`：读取一行数据
- `close`：关闭套接字

</div>

<div col-span-2>

![socket_interface](/11-Network-Programming/socket_interface.png){.mx-auto}

</div>
</div>

---

# 套接字接口

Socket interface

<div grid="~ cols-3 gap-8">
<div text-sm>

### 服务器{.mb-4}

- `getaddrinfo`：获取地址信息
- `socket`：创建套接字
- `bind`：绑定套接字到地址
- `listen`：监听套接字
- `accept`：接受连接
- `rio_readlineb`：读取一行数据
- `rio_writen`：发送 $n$ 字节数据
- `close`：关闭套接字

</div>

<div col-span-2>

![socket_interface](/11-Network-Programming/socket_interface.png){.mx-auto}

</div>
</div>

---

# 套接字接口

Socket interface

为什么要搞得这么复杂？

<v-clicks>

网络编程不像文件 I/O 那么 “确定”{.text-sky-5.font-bold}

对于客户端：

</v-clicks>

<v-clicks text-sm>

1. 为了得到连接对方的信息，我们需要先用 `getaddrinfo` 获取对方的网络连接信息。
2. 然后我们需要用 `socket` 创建一个套接字，但是这只是填入了对方的基础信息，我们不确定对方的状态，所以此时套接字是 **不可用**{.text-sky-5} 的。
3. 我们需要调用 `connect` 来尝试建立连接，若能正常建立，则得知此时套接字是 **可用**{.text-sky-5} 的。
4. 然后我们就可以调用 `rio_writen` 和 `rio_readlineb` 来发送和接收数据了。
5. 最后我们调用 `close` 关闭套接字，终止连接，释放描述符使之可以被重用。

</v-clicks>


---

# 套接字接口

Socket interface

对于服务端：

<v-clicks text-sm>

1. 为了能够参与到网络连接，我们需要先用 `getaddrinfo` 获取自己的网络连接信息。
2. 然后我们需要用 `socket` 创建一个套接字，用于监听客户端的连接请求，此时，这个套接字依旧是 **不可用**{.text-sky-5} 的。
3. 调用 `bind` 将套接字绑定到获取到的地址信息上，声明对某个端口（如 HTTP 对 80 端口）的占用，这样套接字就可以使用了。
4. 调用 `listen` 来将之转为监听套接字，这样套接字就可以监听客户端的连接请求了。
5. 接下来，我们调用 `accept` 来从监听序列中取出一个套接字，这代表我们接受了客户端的连接请求，这样，我们就可以使用这个套接字和客户端进行通信了。
6. 调用 `rio_readlineb` 和 `rio_writen` 来发送和接收数据。
7. 当读到客户端调用 `close` 关闭连接的信息后，我们也调用 `close` 关闭套接字，从而允许这个套接字被重用。

</v-clicks>

<div class="text-sm text-gray-5">

<v-clicks>

你可能会疑惑，为什么不能合并 `bind` 和 `listen`？它们似乎都只在服务端使用。

- `bind` 代表绑定，它使得侦听端口固定了下来。在客户端不需要这个过程，每次连接随便分配一个可用端口即可。
- `listen` 代表监听，它让套接字从主动套接字变为被动套接字。

接下来，让大家看看我的 Surge。{.text-sky-5}

</v-clicks>

</div>

---

# 套接字接口

Socket interface


`getaddrinfo` 函数用于获取地址信息


```c
int getaddrinfo(const char *host, const char *service, const struct addrinfo *hints, struct addrinfo **res);
void freeaddrinfo(struct addrinfo *res);
```

<div grid="~ cols-2 gap-8">
<div text-sm>

- `host`：主机名，可以是 `127.0.0.1` 或 `localhost`，域名或点分制都可以，甚至可以是 `NULL`，代表监听本机通配地址 `0.0.0.0`（监听所有网络接口）
- `service`：服务名，可以是 `80`（十进制端口号）或 `http`，端口号或服务名都可以
- `hints`：提示信息，控制行为
- `res`：地址信息链表，存放结果

`ai` 是 `addrinfo` 的缩写

`canonname` 全称 canonical name，即规范、权威名

</div>

<div>

![getaddrinfo_res](/11-Network-Programming/getaddrinfo_res.png){.mx-auto.h-70}

</div>
</div>

---

# 套接字接口

Socket interface

`socket` 函数用于创建可供读写的套接字。

```c
int socket(int domain, int type, int protocol);
```

- `domain`：协议族，如 `AF_INET` / `AF_INET6`
- `type`：套接字类型，如 `SOCK_STREAM` / `SOCK_DGRAM`
- `protocol`：协议，如 `0`

使用 `getaddrinfo` 获取地址信息后，可以自动生成这些所需参数。

---

# 套接字接口

Socket interface

`connect` 函数用于建立和服务器的连接。

```c
int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

- `sockfd`：套接字描述符
- `addr`：套接字地址
- `addrlen`：套接字地址长度

<div text-sky-5>

注意，`connect` 函数会阻塞，直到连接建立成功或失败。

而且还要注意，`connect` 是否返回，与服务器是否 `accept` 无关。

前者返回 `0` 表明建立了连接，后者代表开始服务器处理这个连接。

</div>

---

# 套接字接口

Socket interface

`bind` 函数用于在服务器将套接字绑定到地址。它声明对某个端口（如 HTTP 对 80 端口）的占用。

```c
int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

- `sockfd`：套接字描述符
- `addr`：套接字地址
- `addrlen`：套接字地址长度

依旧是最好使用 `getaddrinfo` 获取地址信息后，可以自动生成这些所需参数。

---

# 套接字接口

Socket interface

`listen` 函数用于在服务器将套接字转为监听套接字。该端口必须首先被声明占用（`bind`）。

```c
int listen(int sockfd, int backlog);
```

- `sockfd`：套接字描述符
- `backlog`：连接队列长度，**表示服务器最多可以同时处理多少个连接。**{.text-sky-5}

调用完 `listen` 后，对于连接请求，会放入队列。

回忆：这是一个队列，建立连接后，我们先放进去，但不代表我们立即调用 `accept` 来处理。

监听描述符只被创建一次，存在于整个生命周期。{.text-sky-5}

---

# 套接字接口

Socket interface

`accept` 函数用于在服务器接受连接。

```c
int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
```

- `sockfd`：监听套接字描述符
- `addr`：客户端套接字地址会被填写在这里
- `addrlen`：客户端套接字地址长度

从队列取出连接请求，如果决定接受，则为该连接分配新的描述符 `fd`

<div text-sm>

- 多个连接存在时，每个连接有各自的 `fd`，但共用一个端口号，即监听时的端口号。
- 系统内部用 `(源 IP 地址，源端口号，目的 IP 地址，目的端口号)` 区分连接
- 因此，即使多个连接共用服务器端口号，也能区分
- 即使原先监听描述符被提前关闭，也不影响已经建立的连接。

</div>

已连接描述符只存在于为一个客户端服务的过程中。{.text-sky-5}

---

# 监听描述符 vs 已连接描述符

listen fd vs connected fd

![listen_fd_vs_connected_fd](/11-Network-Programming/listen_fd_vs_connected_fd.png){.mx-auto}

<!-- 

看 Surge

-->

---

# 套接字接口辅助函数

Socket interface helper functions

<div grid="~ cols-2 gap-8">
<div>

### `open_clientfd`

```c
int open_clientfd(char *hostname, char *port);
```

客户端调用 `open_clientfd` 函数建立与服务器的连接，该服务器运行在主机 `hostname` 上，在端口号 `port` 上监听连接请求。

等价于 `socket` + `connect`

</div>

<div>

### `open_listenfd`

```c
int open_listenfd(char *port);
```

服务端调用 `open_listenfd` 函数，服务器创建一个监听描述符，准备好接收连接请求。

等价于 `socket` + `bind` + `listen`


</div>
</div>

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
