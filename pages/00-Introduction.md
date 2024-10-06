---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: https://cover.sli.dev
highlighter: shiki
# some information about your slides (markdown enabled)
title: 00-Introduction
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
coverBackgroundUrl: /00-Introduction/cover.jpg
colorSchema: dark
---

# 欢迎来到 ICS 课程 {.font-bold}

2110306206 预防医学&信双 卓致用

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

<!--
The last comment block of each slide will be treated as slide notes. It will be visible and editable in Presenter Mode along with the slide. [Read more in the docs](https://sli.dev/guide/syntax.html#notes)
-->

---

# 关于我

Developer / Designer / Medical student

一边被 ~~病理病生理药理~~ 内外妇儿折磨，一边在 ~~ICS 的 Lab 作业~~ PyTorch 中 debug 到头秃的医学生


<div class="my-10 grid grid-cols-[40px_1fr] w-min gap-y-4 items-center">
  <ri-github-line class="opacity-50"/>
  <div><a href="https://github.com/zhuozhiyongde" target="_blank">Arthals</a></div>
  <ri:blogger-line class="opacity-50"/>
  <div><a href="https://arthals.ink" target="_blank">arthals.ink</a></div>
  <ri:mail-line class="opacity-50"/>
  <div><a href="mailto:zhuozhiyongde@126.com">zhuozhiyongde@126.com</a></div>
  <ri:wechat-2-line class="opacity-50"/>
  <div>zhuozhiyongde</div>
</div>

<!--
You can have `style` tag in markdown to override the style for the current page.
Learn more: https://sli.dev/features/slide-scope-style
-->

<!--
Here is another comment.
-->

---

# 关于课程

或许你会更想了解一些可能对你们有用的链接...

|     |     |
| --- | --- |
| [ICS-2023Fall-PKU](https://github.com/zhuozhiyongde/Introduction-To-Computer-System-2023Fall-PKU) | 北京大学 2023 年秋计算机系统导论课程（ICS）作业、笔记、经验 |
| [ICS 2023 课程资料](https://disk.pku.edu.cn/anyshare/link/AACEA547E95DB14D289605A60FBC2ECD34) | 往年题、Slides |
| [ICS Labs](https://arthals.ink/tags/ics) | 更适合北大宝宝的 ICS Lab 踩坑记 by [Arthals](https://github.com/zhuozhiyongde) |
| [CSAPP 笔记版 / GoodNotes](https://disk.pku.edu.cn/link/AA46F302BBA11A4E73AAAA4FA1AED1FD98) | By [Arthals](https://github.com/zhuozhiyongde) & [EmptyBlueBox](https://github.com/EmptyBlueBox)，提取码 `csapp` |
| [CSAPP 笔记版 / PDF](https://disk.pku.edu.cn/link/AA834F941EFC62489DA7DBEEA2659CDCD5) | By [Arthals](https://github.com/zhuozhiyongde) & [EmptyBlueBox](https://github.com/EmptyBlueBox)，提取码 `csapp` |
| [深入理解计算机系统视频版讲解](https://space.bilibili.com/354767108/channel/collectiondetail?sid=373847) | By [九曲阑干](https://space.bilibili.com/354767108) |
| [CSAPP Errata](https://csapp.cs.cmu.edu/3e/errata.html) | CSAPP 勘误表（英文） |


---

# 关于课程

或许你会更想了解一些可能对你们有用的链接...

**以下链接均限校内可用**

|     |     |
| --- | --- |
| [Clab](https://clab.pku.edu.cn/) | 写 Lab 用的云计算实验平台 |
| [Autolab](https://autolab.pku.edu.cn/) | Lab 用的自动评测平台 ~~卷王排行榜~~ |
| [Memos](https://ics.huh.moe/) | 答疑平台 |



---
layout: image-right
image: /00-Introduction/pku-art.jpeg
backgroundSize: 80%
---

# 小广告！

受够了丑丑的教学网...？

[PKU Art](https://github.com/zhuozhiyongde/PKU-Art)：一个由我开发的教学网美化样式



---

# 课程概述

|     |     |
| --- | --- |
| 程序与数据 | Data Lab  |
| 处理器体系结构 | Bomb Lab / Attack Lab |
| 程序性能 | Arch Lab |
| 分级存储器体系 | Cache Lab |
| 虚拟内存 | Malloc Lab |
| 异常控制流 | Shell Lab |
| 网络、并发 | Proxy Lab |



<!-- 主要依据 CSAPP 讲解，第一章不用看，后面有的地方可能也不在考试范围 -->

---

# 课程概述

给分方案

- 30% Lab
- 15% 小班表现
- 15% 期中考试
- 40% 期末考试

注：可能会调整，大班也可能会有作业

<!-- <div v-click>

###### Pros

- More explicit, with type checking
- Less caveats

###### Cons

- `.value`

</div> -->



---

# 如何学好 ICS

实话说，我也不清楚

ICS 是 5 学分大课，不仅占分高，还是后续很多礼包课程的基础课，大伙肯定都想学好它、拿高分，然而...

- 内容多，难度大，时间紧
- 催命的 Labs
- 考试命题懂的都懂

尽管如此，我也有一些（不成熟的）建议：

- 好好读书，至少读两遍
- 拟合往年题，~~尽管可能没什么用~~
- 多和助教沟通，我也曾是萌新

---
layout: image-right
image: /00-Introduction/terminal.png
backgroundSize: contain
---

# 终端

吃饭的家伙事儿

推荐的命令行应用程序：

- macOS：[Warp](https://warp.dev/)
- Windows：[Windows Terminal](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701)

[从零开始配置 Linux](https://arthals.ink/blog/initialize-linux)




---
layout: two-cols-header
---
# 一些你必须掌握的 Linux 命令

我知道，不是所有人都有基础...

[常用 Linux 命令](https://dl.ypw.io/linux-command/)

推荐：

- 使用 [tldr](https://github.com/tldr-pages/tldr) 来学习这些命令
- 使用 [VS Code Remote - SSH](https://code.visualstudio.com/docs/remote/ssh) 来进行远程连接，可视化管理文件

最常用的一些：

::left::

- `ls`： 列出文件和目录
- `cd`： 切换目录
- `pwd`： 显示当前目录
- `mv`： 移动文件或目录
- `mkdir`： 创建目录

::right::
- `rm`： 删除文件或目录（需要添加 `-r` 参数）
- `ssh`： 远程登录
- `scp`： 远程文件拷贝
- `curl`： 发送 HTTP 请求
- `grep`： 搜索文件内容




---

# 一些你必须掌握的 Linux 命令

我知道，不是所有人都有基础...

一个现代化的命令提示：[tldr](https://github.com/tldr-pages/tldr)

一些其他我常用的指令亦可参见之前提到的： [从零开始配置 Linux](https://arthals.ink/blog/initialize-linux)

> `pm2`、`zoxide`...

你可能还需要了解一下 Git 和 [GitHub](https://github.com/)，SSH 和 Markdown / $\LaTeX$ 语法，这些东西在你未来的学习中会经常用到。

**强烈推荐找些博客或者 B 站 / YouTube 视频学习一下它们！**

> 如果你想要求助 GPT 但不知道怎么做，也可以参考我发的树洞 #5924935




---
layout: center
class:
---


<div flex="~ gap-16"  mt-2 justify-center items-center>


<div  w-fit h-fit mb-2>

# THANKS

Made by Arthals with ❤️ ~~and hair~~ {.mb-4}

[Blog](https://arthals.ink/) · [GitHub](https://github.com/zhuozhiyongde) · [Bilibili](https://space.bilibili.com/203396427)

</div>

![wechat](/wechat.jpg){.w-40.rounded-md}

</div>

