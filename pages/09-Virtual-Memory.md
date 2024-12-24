---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: https://cover.sli.dev
highlighter: shiki
# some information about your slides (markdown enabled)
title: 09-Virtual-Memory
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
coverBackgroundUrl: /09-Virtual-Memory/cover.jpg
---

# 虚拟内存 {.font-bold}

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

# 虚拟内存

Virtual Memory

为什么要使用虚拟内存？

<div v-click>

虚拟内存是一层很关键的抽象：

</div>

<v-clicks>

- 它隐藏了物理内存的细节，为程序提供了一个抽象的、一致的内存视图
- 它保证了每个进程地址空间的独立性，使得进程之间不会相互干扰
- 可以分配超过物理内存的地址空间，充分利用物理内存（物理地址是唯一的，不能多次分配）

</v-clicks>

---

# 物理寻址和虚拟寻址

<div grid="~ cols-2 gap-8" text-sm>
<div>

###### 物理寻址

![physical_addressing](/09-Virtual-Memory/physical_addressing.png){.h-55.mx-auto}

1. 获得物理地址（PA，Physical Address）
2. 通过地址总线访问物理内存

物理地址不要求总量 $M$ 是 2 的幂次，寻址范围 $0 \sim M-1$

</div>

<div>

###### 虚拟寻址

![virtual_addressing](/09-Virtual-Memory/virtual_addressing.png){.h-55.mx-auto}

1. 获得虚拟地址（VA，Virtual Address）
2. 通过 CPU 中的内存管理单元（MMU）的转换，将虚拟地址转换为物理地址
3. 通过地址总线访问物理内存

虚拟地址要求总量 $N$ 是 2 的幂次，即满足 $N = 2^n$，寻址范围 $0 \sim N-1 / 0 \sim 2^n - 1$

</div>
</div>

---

# 虚拟内存做为缓存的工具

Virtual Memory as a tool for caching

<div grid="~ cols-2 gap-8">
<div>

回想我们在第六章学习过的内容：

访问更低级存储设备前，我们会先访问更高一级存储设备，试图命中缓存。

由于使用虚拟内存寻址时，我们会先访问虚拟内存，再访问物理内存，所以我们可以将先前是否缓存的检查放到虚拟内存这一层。

</div>

<div>

![memory_hierarchy](/09-Virtual-Memory/memory_hierarchy.png){.mx-auto}

</div>
</div>

---

# 虚拟内存做为缓存的工具

Virtual Memory as a tool for caching

<div grid="~ cols-2 gap-8">
<div>


任何时刻，虚拟内存的集合分为三个不相交的子集：

- **未分配的**{.text-sky-500}：完全没在虚拟内存中分配（用不到、省下来）
- 已分配的
  - **已缓存的**{.text-lime-500}：已经在物理内存中缓存，不需要到到硬盘中取
  - **未缓存的**{.text-amber-500}：不在物理内存中缓存，需要到硬盘中取

和之前在缓存中最小交换的单位是 **块** 一样，虚拟内存中最小交换的单位是 **页**{.text-sky-5}。


</div>

<div>


![vm_as_cache](/09-Virtual-Memory/vm_as_cache.png){.mx-auto}

</div>
</div>

---


# 页表

Page Table

<div grid="~ cols-2 gap-8">
<div text-sm>

由于现在虚拟内存参与到了缓存机制中，所以和之前的缓存一样，虚拟内存也需要一个方式来判断一个页是否完成了缓存，而这，就是页表。

页表是一个页表条目（Page Table Entry, PTE）的数组。

每个页表条目由一个有效位（valid bit）和一个 n 位地址字段组成：

有效位：判断一个页是否在物理内存中

- 0：不在物理内存中，对应的页表项为：
  - 空（**未分配**，`NULL`）
  - **虚拟页**{.text-sky-5} 起始地址（**未缓存**，对应更低级缓存（磁盘）中的起始地址）
- 1：**已缓存**，缓存在了物理内存中，对应项为 **物理页**{.text-sky-5} 的起始地址


</div>

<div text-xs>

![page_table](/09-Virtual-Memory/page_table.png){.h-60.mx-auto}

Key Points:

- **页表是常驻在物理内存中的（总是需要用页表来索引）。**
- **DRAM 缓存是全相联的，所以任意物理页都可以包含任意虚拟页。**


</div>
</div>

---

# 比较：页表 vs 全相联缓存

<div grid="~ cols-2 gap-8">
<div>

###### 页表

![page_table](/09-Virtual-Memory/page_table.png){.h-70.mx-auto}

</div>

<div>

###### 全相联缓存

![review_fully_associative](/09-Virtual-Memory/review_fully_associative.png){.mx-auto}

</div>
</div>

用于检索的 **有效位** 和 **标记位** 被抽离出来，成为了页表；**标记位不复存在**，因为页表包括了整个虚拟地址空间。

实际存储信息的 **高速缓存块** 拼在一起，组成了 **物理内存**。

---

# 页表索引

Page Table Indexing

<div grid="~ cols-2 gap-8">
<div>

#### 成功

如果已缓存（有效位为 `1`），称为 **页命中（Page Hit）**：

直接从页表中对应的物理内存地址中读取数据即可


</div>

<div>

#### 失败

如果未缓存（有效位为 `0`），称为 **缺页（Page Fault）**：

此时会触发一个 **缺页异常**（Page Fault）

> 回顾：缺页异常是？类型（同步 / 异步）、恢复到的地点是？
> 
> <span v-click text-sky-5>故障、同步、当前指令 $I_{cur}$</span>

</div>
</div>

<div v-click>

缺页异常调用内核中的缺页异常处理程序，选择一个 **牺牲页**（如果牺牲页被修改了，就写回磁盘）

然后用所需虚拟页替换之，并修改牺牲页和新虚拟页对应的页表条目。

**分配页面**：如果要分配一个新的虚拟内存页（如调用 `malloc`），则在磁盘上创建空间并更新对应的页表条目（PTE），使其指向新创建的页面。

</div>

<!-- (Tips：类比 Cache Hit 和 Cache Miss！) -->

---

# 局部性

Locality

从内存到磁盘的交换时间很长会导致高昂的不命中处罚。

但是，由于页表很大，所以会具有比较好的空间局部性。

抖动（thrashing）：如果工作集的的大小超出了物理内存的大小，那么这时页面还是会不断地换进换出。

---

# 虚拟内存用作内存管理

Virtual Memory as a Memory Management Tool

<div grid="~ cols-2 gap-8">
<div>

全局单页表 → 每个进程拥有一个独立的页表。

提供了一个 **假象**：每个进程独占所有物理内存。

<v-clicks text-sm>

- **简化链接**：每个进程使用了类似的内存格式，使得链接器的设计和实现被大大简化（不用考虑物理地址 PA，只用考虑虚拟地址 VA）
- **简化加载**：将 `.text` 和 `.data` 节加载到新创建的进程中时，只需要分配虚拟页并将页表条目指向目标文件中适当的位置
- **简化共享**：不同进程中适当的虚拟页面可以映射到相同的物理页面
- **简化内存分配**：物理页面可以随机地分散在物理内存中（这项单页表就有）

</v-clicks>
</div>

<div relative>
<div :class="$clicks<=1 ? 'opacity-100' : 'opacity-0'" transition duration-400 absolute>

![private_address_space](/09-Virtual-Memory/private_address_space.png){mx-auto}

</div>
<div :class="$clicks==2 ? 'opacity-100' : 'opacity-0'" transition duration-400 absolute>

![page_table](/09-Virtual-Memory/page_table.png){mx-auto}

</div>
<div :class="$clicks>=3 ? 'opacity-100' : 'opacity-0'" transition duration-400 absolute>

![vm_share_page](/09-Virtual-Memory/vm_share_page.png){mx-auto}

</div>
</div>
</div>

---

# 虚拟内存作为内存保护的工具

Virtual Memory as a Memory Protection Tool

除了标明是否缓存的有效位，页表条目中还可以包含数个 **权限位（protection bit）**{.text-sky-5}，用于标明一个页的权限。

如果指令违反许可条件，CPU 会触发一个一般保护 **故障**，将控制传递给内核中的异常处理程序。

Linux Shell 一般将其报告为 **段错误（Segmentation Fault）**{.text-red-5}。


![mem_protection](/09-Virtual-Memory/mem_protection.png){.h-70.mx-auto}

<!-- 

| 类别   | 原因                     | 异步 / 同步 | 返回行为               |
|--------|--------------------------|-----------|------------------------|
| 中断（Interrupt）   | 来自 I/O 设备的信号      | 异步  | 总是返回到下一条指令 $I_{next}$   |
| 陷阱（Trap）   | 有意的异常               | 同步      | 总是返回到下一条指令 $I_{next}$   |
| 故障（Fault）   | 潜在可恢复的错误         | 同步      | 可能返回到当前指令 $I_{cur}$     |
| 终止（Abort）   | 不可恢复的错误           | 同步      | 不会返回               |


 -->

---

# 虚拟地址翻译

Virtual Address Translation

<div grid="~ cols-2 gap-8">
<div>

回顾：缓存寻址

<div class="text-sm">

| 缓存  | 虚拟内存 |
| ----- | ---- |
| 有效位 | 页表有效位 |
| 标记位 | /，用于页表是全量的 |
| 块偏移 | 物理页偏移，利用了交换块大小一致 |

</div>

</div>

<div>

![vm_translation](/09-Virtual-Memory/vm_translation.png){.mx-auto}

</div>
</div>

<div class="text-sm">

- VA = **VPN**（Virtual Page Number，虚拟页号）: **VPO**（Virtual Page Offset，虚拟页偏移），`:` 代表拼接
- VPN 直接作为索引去查找，替代了标记位的对比判断，经页表查询后得到物理页号 PPN <br>（不是之前说的物理地址偏移了，但是是等价的，因为 PPN $\times$ 页大小 = 物理地址偏移）
- VPO 等价于块偏移，用于索引页内地址
- PA = PPN : PPO

</div>


<!-- 

要点，对理解多级页表很重要

 -->

---

# 虚拟地址翻译

Virtual Address Translation

<div grid="~ cols-2 gap-8">
<div>


### 命中

1. 处理器生成一个虚拟地址，并把它传送给 MMU
2. MMU 生成 PTE 地址，并从高速缓存 / 主存请求得到它
3. 高速缓存 / 主存向 MMU 返回 PTE
4. MMU 构造物理地址，并把它传送给高速缓存 / 主存
5. 高速缓存 / 主存返回所请求的数据字给处理器

**回忆：页表是常驻在物理内存中的，所以请求页表一定会触发一次访存，且（此时）必然命中。**{.text-sky-5}

</div>

<div>

![vm_translation_detail_hit](/09-Virtual-Memory/vm_translation_detail_hit.png){.mx-auto}

</div>
</div>

---

# 虚拟地址翻译

Virtual Address Translation

<div grid="~ cols-2 gap-8">

<div>

### 缺页

1. 处理器生成一个虚拟地址，并把它传送给 MMU
2. MMU 生成 PTE 地址，并从高速缓存 / 主存请求得到它
3. 高速缓存 / 主存向 MMU 返回 PTE
4. MMU 触发异常，传递 CPU 中的控制到操作系统内核中的缺页异常处理程序
5. 缺页异常处理程序确定并处理牺牲块
6. 缺页处理程序调入新的页面，并更新内存中的 PTE

**回忆：页表是常驻在物理内存中的，所以请求页表一定会触发一次访存，且（此时）必然命中。但是，页表在不代表页在。**{.text-sky-5}

</div>

<div>

![vm_translation_detail_miss](/09-Virtual-Memory/vm_translation_detail_miss.png){.mx-auto}

</div>
</div>

---

# 万物皆可缓存

Everything is Cacheable

- 页表常驻在物理内存中，还很大（总量：$N_{pages} \times {bit}_{PTE}$）
- CPU 到 内存 还是存在较大的延迟（回忆：在此之前我们会试图使用 L1 ~ L3 缓存来缓解）
- 页表本身也是数据，页表条目可以缓存，就像其他的数据字一样，也可以通过 L1 ~ L3 缓存来提高访问速度

![page_table_cache](/09-Virtual-Memory/page_table_cache.png){.mx-auto.h-70}

---

# 传统缓存是有极限的！

~~wobudangrenle!~~

- 每条指令都要访存，每次访存都要获取一个 PTE
- 即使 PTE 就在 L1 缓存中，每次访问也还是需要 1~2 个时钟周期，积沙成塔，性能损失很大，但这已经是把 PTE 当做传统数据字的极限了
- 继续优化，**添加新硬件**，再叠一层缓存来加速 PTE 的获取！


---

# 翻译后备缓冲器 TLB

Translation Lookaside Buffer, TLB

<div grid="~ cols-2 gap-8">
<div text-sm>

#### L1 ~ L3 缓存{.mb-4}

- 把页表当做普通数据字来看待
- 它们的索引，操作的是这个数据字所在的内存物理地址
- 利用的是内存物理地址的局部性
- Cache 缓存物理地址，对应以物理地址开头的物理块，目的是加快数据字的访问

#### TLB 缓存{.my-4}

- 缓存的是物理地址
- 它的索引，操作的是虚拟地址 VP 中的 VPN
- 利用的是虚拟地址的局部性
- TLB 缓存虚拟地址，对应 PTE，目的是加速 VP 到 PP 的翻译

TLB 通常是 **高度相联的**，这带来了更高的灵活性。

</div>

<div>


![tlb](/09-Virtual-Memory/tlb.png){.mx-auto}
![vp_tlb](/09-Virtual-Memory/vp_tlb.png){.mx-auto}


</div>
</div>

---

# 翻译后备缓冲器 TLB

Translation Lookaside Buffer, TLB

<div grid="~ cols-2 gap-8">
<div>

TLB 将 VPN 映射到 PPN，为了利用 VPN 的局部性，它将 VPN 分为了两部分：

- TLBT（TLB Tag）：用于比较缓存中是否为想要的
- TLBI（TLB Index）：用于索引缓存

TLB 的索引过程：

1. 处理器生成一个虚拟地址，并把它传送给 MMU
2. MMU 将虚拟地址分解为 VPN 和 VPO
3. 使用 VPN 的低阶位（TLBI）作为索引，访问 TLB
4. 如果 TLB 命中（TLBT 匹配），则 TLB 条目中的物理地址（PPN）和 VPO 拼接成物理地址，否则执行常规的页表查询，访问 L1 缓存

</div>

<div>


![vp_tlb](/09-Virtual-Memory/vp_tlb.png){.mx-auto}
![cache_address](/09-Virtual-Memory/cache_address.png){.mx-auto}


</div>
</div>

---

# 多级页表

Multi-level Page Table

页表常驻在物理内存中，还很大（总量：$N_{pages} \times {bit}_{PTE}$）

TLB 给我们带来了一些启发：我们可以利用 VP 的空间局部性（VPN 的时间局部性）。
<br><span class="text-sm text-gray-5">连续的 VP，变动的是低阶位 VPO，VPN 基本不变。</span>

那么，能不能进一步的利用 VPN 的空间局部性呢？

---
clicks: 1
---

# 多级页表

Multi-level Page Table

<div grid="~ cols-2 gap-8">
<div text-sm>

多级页表：将 VPN 的前缀再拆分成数段 $\text{VPN}_i, i \in [1, k]$，假设每段有 $n$ 位：

- 一级页表：$\text{VPN}_1$，对它而言，$\text{VPN}_{2\sim k}:\text{VPO}$ 是它的 “VPO”，它的每一项，存储的是一个 **2 级页表的基址**{.text-sky-5}，可以认为它的每一项缓存了 $\dfrac{1}{2^n}$ 的虚拟内存 **（加起来寻址了全部）**{.text-sky-5}
- 二级页表：$\text{VPN}_2$，对它而言，$\text{VPN}_{3\sim k}:\text{VPO}$ 是它的 “VPO”，它的每一项，存储的是一个 **3 级页表的基址**{.text-sky-5}，可以认为它的每一项缓存了 $\dfrac{1}{2^{2n}}$ 的虚拟内存
- ...
- 第 k 级页表：$\text{VPN}_k$，对它而言，$\text{VPO}$ 就是它的 “VPO”，**也只有它的每一项，存储了实际的 PPN**{.text-sky-5}，可以认为它的每一项，缓存了 $\dfrac{1}{2^{kn}}$ 的虚拟内存，这恰好等于 $2^m$，其中 $m$ 是 PPO 的位数

</div>

<div relative>
<div :class="$clicks==0 ? 'opacity-100' : 'opacity-0'" transition duration-400 absolute>

![multi_level_page_table](/09-Virtual-Memory/multi_level_page_table.png){.mx-auto}


</div>
<div :class="$clicks==1 ? 'opacity-100' : 'opacity-0'" transition duration-400 absolute>

![multi_level_page_table_2](/09-Virtual-Memory/multi_level_page_table_2.png){.mx-auto}

</div>

<div mt-80>

此时：**只有 1 级页表常驻在物理内存中**{.text-sky-5}，2 级页表和 3 级页表，可以不在物理内存中。

</div>

</div>
</div>

<!-- 

一般 `bitof(VPN1) = bitof(VPN2) = ... = bitof(VPNk)`

 -->

---

# 一些延伸概念

Some Boring Things

1. **PTE（Page Table Entry）**：
   - PTE 是页表中的一个条目，每个条目包含一个虚拟页到物理页的映射
   - PTE 包含物理页框地址以及一些控制位（如有效位、读/写权限位、访问位等）
   - 当 CPU 需要访问某个虚拟地址时，会通过页表找到对应的 PTE，从而得到物理地址

2. **PDE（Page Directory Entry）**：类似 PTE，但是层级在 PTE 之上
   - PDE 是页目录中的一个条目，每个条目指向一个页表
   - 页目录用于组织和管理多个页表
   - PDE 也包含一些控制信息，如有效位、访问权限等

---

<div grid="~ cols-2 gap-8">
<div>

# 一些延伸概念

Some Boring Things

3. **大页模式（Huge Pages or Large Pages）**{.text-sky-5}：

    <p class="text-sm text-gray-5 mt-0">往年题最喜欢的一集</p>

    <v-clicks text-sm>

    - 大页模式是一种内存分页机制，其中每个页的大小比普通页更大
    - 考虑右图，现在的寻址方式是，先用 VPN1 找到一级页表中的 PDE，再解码得到二级页表的基址，再用 VPN2 找到二级页表中的 PDE...
    - 如果我们能保证连续的 VPN2 指向的三级页表基址是连续的，那么我们就可以减少页表的层级，用一个一级页表的 PDE 来表示一整个大页，这个大页融合了二级页表和三级页表{.text-sky-5}
    - 联想比较：`int a[b][c]` 和 `int a[b*t + c]`，利用二进制的特性
    - 大页模式可以提高 TLB 的命中率，减少页表的查找次数

    </v-clicks>

</div>

<div>

![multi_level_page_table](/09-Virtual-Memory/multi_level_page_table.png){.mx-auto.h-50}


![multi_level_page_table_2](/09-Virtual-Memory/multi_level_page_table_2.png){.mx-auto.h-50}

</div>
</div>

---

# 要点总结

Recap

基础概念：

- 虚拟内存三个便利：作为缓存工具、作为内存管理（简化链接，简化加载，简化共享，简化内存分配）、作为内存保护
- MMU 完成 地址翻译 + 权限保护
- 页表数据结构：用来管理 page 的状态、信息（利用对齐特性，低位放权限位 / 大页等信息）
- TLB 缓存虚拟地址，对应 PTE，目的是加速 VP 到 PP 的翻译
- Cache 缓存物理地址，对应以物理地址开头的物理块，目的是加快数据字的访问

TLB 的刷新：**每个进程都有自己的虚拟地址空间，进程间切换需要 TLB 刷新，切换到对应 VP 的解析**{.text-sky-5}

- 在切换上下文后 TLB 的内容完全不对怎么办？
  - 选项 1： 清空全部的 TLB
  - 选项 2： 将进程 ID 与每个 TLB 相关联

---

# 要点总结

Recap

地址翻译由硬件和软件协同完成：
- 硬件负责：地址翻译 + 权限保护
- 软件负责：创建页表，维护页表

多级页表：

- 多级页表前 $k-1$ 级的地址字段是 **下一级页表**{.text-sky-5} 的物理页基质，第 $k$ 级的地址字段是虚拟页对应的 **物理页**{.text-sky-5} 的基址
- 当多级页表具有较好连续性时，可以使用大页模式

---

# 要点总结

Recap

![address_translation_all](/09-Virtual-Memory/address_translation_all.png){.mx-auto}

---

# 酷睿 i7 的地址翻译要点

Key Points of Intel Core i7 Address Translation

页表 4KB 对齐，使得我们可以在低 12 位中设置权限位、大页位等字段，其中重要字段包括：

- **有效位**（P，Present），表示该页是否存在于物理内存中
- **大页位**（PS，Page Size），表示该页是否是大页，**只对第三层 PTE 有效**{.text-sky-5}<br><span class="text-sm text-gray-5">四级页表，第三层第四层组成了大页，连续的 1024 个 4KB 的页组成了 4MB 的大页</span>
- **引用位**（A，Accessed），表示该页是否被访问过，**由 MMU 在读时设置，由软件清除，为了实现替换策略**{.text-sky-5}
- **脏位**（D，Dirty），表示该页是否被修改过，**只对最低的第四层 PTE 有效，由 MMU 在读和写时设置，由软件清除，为了确定是否要写回**{.text-sky-5}

---
clicks: 1
---

# 酷睿 i7 的地址翻译要点

Key Points of Intel Core i7 Address Translation

<div relative>
<div :class="$clicks==0 ? 'opacity-100' : 'opacity-0'" transition duration-400 absolute w-full>

![i7_p1_to_p3](/09-Virtual-Memory/i7_p1_to_p3.png){.mx-auto.h-100}

</div>
<div :class="$clicks==1 ? 'opacity-100' : 'opacity-0'" transition duration-400 absolute w-full>

![i7_p4](/09-Virtual-Memory/i7_p4.png){.mx-auto.h-100}

</div>
</div>

---

# 酷睿 i7 的地址翻译要点

Key Points of Intel Core i7 Address Translation

**高速缓存 CI + CO = 12位 = VPO**

这样的话：

1. 翻译地址：只使用 VPN
2. 确立缓存：先使用 VPO（PPO）提取出 CI 和 CO，再使用 PPN 作为 Tag 去对比

2 的前半段和 1 可以 **并行**，加快访存过程。

<!-- 

由于 VPO = PPO，而在地址翻译的过程中只使用了 VPN，因此在一开始输入虚拟地址后，可以分别分割出 VPN 和 VPO，发送给 TLB 和 cache/memory。由于 PPO 确定了对应的高速缓存组和块偏移量，cache 就能够完成组索引找到对应的组，等到 MMU 找到了 PPN后，只需要和这一组中的每一行标志位进行比较，极大加快访存过程。

 -->

---

<div grid="~ cols-2 gap-8" h-full>
<div>

# Linux 虚拟内存系统

Linux Virtual Memory System

Linux 为每个进程维护了一个单独的虚拟地址空间。

- 进程虚拟内存：实际只可以使用 $0 \sim 2^{48}-1$ 这一段空间
- 内核虚拟内存：
  - 内核代码和数据，对每个进程一样
  - 完整物理内存的连续映射，对每个进程一样
  - 与进程相关的数据结构，如页表、内核栈等，对每个进程不一样

</div>

<div flex h-full w-full justify-center items-center >

![linux_vm_process](/09-Virtual-Memory/linux_vm_process.png){.mx-auto.h-100}

</div>
</div>

---

# 内核虚拟内存

Kernel Virtual Memory

<div grid="~ cols-3 gap-2">
<div text-sm>

`task_struct`：是 Linux 内核中用于描述一个进程的主要数据结构。

<span class="text-xs text-gray-5">

包含或者指向内核运行该进程所需要的所有信息（例如，PID、指向用户栈的指针、可执行目标文件的名字，以及程序计数器）

</span>

`mm_struct`：描述了虚拟内存的当前状态。

- `pgd`：page global directory，指向第一级页表（页全局目录）的基址，`pgd` 存放在 CR3 寄存器中
- `mmap`：memory map，指向一个 `vm_area_struct` 链表，每个 `vm_area_struct` 描述了当前虚拟地址空间中的一个区域

</div>

<div col-span-2>

![linux_vm_organization](/09-Virtual-Memory/linux_vm_organization.png){.mx-auto.h-90}

</div>
</div>

---

# 内核虚拟内存

Kernel Virtual Memory

<div grid="~ cols-3 gap-2">
<div text-sm>

`vm_area_struct` 描述了虚拟地址空间中的一个区域。

<span class="text-xs text-gray-5">

区域：通常指虚拟地址空间中的一段连续的内存范围。

</span>

- `vm_start`：指向这个区域的起始地址
- `vm_end`：指向这个区域的结束地址
- `vm_prot`：描述这个区域内含有的所有页的读写许可权限
- `vm_flags`：描述这个区域的属性（例如是否共享等）
- `vm_next`：指向链表中的下一个区域结构

</div>

<div col-span-2>

![linux_vm_organization](/09-Virtual-Memory/linux_vm_organization.png){.mx-auto.h-90}

</div>
</div>

---

# 缺页异常处理程序

Page Fault Exception Handler

1. 检查虚拟地址 VA 是否合法：看它是否在某个段中。遍历比较 `vm_area_struct` 链表的子节点中从 `vm_start` 到 `vm_end` 的值，看 VA 是否在某个 `vm_start` 和 `vm_end` 之间。
    - 不合法：触发 **段错误**{.text-red-5}（页不存在于段中，就说明他不是合法的虚拟地址，不能被索引），终止进程。
2. 检查对虚拟地址 VA 的访问是否合法：确定所在段后，根据 `vm_prot` 字段检查访问权限，判断是否和操作类型匹配。
    - 不合法：触发 **段错误**{.text-red-5}，进入缺页异常处理程序，可能会修复（COW），亦可能直接终止进程
3. 如果上述检查均通过，则确定了这个缺页是由于对合法的虚拟地址进行合法的操作造成的
    <br> → 执行正常的缺页处理
    1. 处理程序会选择一个物理牺牲页，如果牺牲页被修改了，则进行写回；
    2. 将虚拟地址 VA 对应的虚拟页写入对应的物理页中，修改对应的页表；
    3. 从处理程序返回

---

# 缺页异常处理程序

Page Fault Exception Handler

![page_fault](/09-Virtual-Memory/page_fault.png){.mx-auto.h-90}

---

# 内存映射

Memory Mapping

**内存映射**：是把一个虚拟内存区域和 **磁盘上的一个对象**{.text-sky-5}（例如文件）关联起来，以 **初始化这个虚拟内存区域**{.text-sky-5} 的过程。

<div grid="~ cols-2 gap-8">
<div>

###### 内存映射

<v-clicks at="1">

**延迟加载**：在程序访问某个内存页时，才会从磁盘读取相应的数据到物理内存中。未访问的页不会占用物理内存。

**内存共享**：多个进程可以共享同一个虚拟内存区域，从而节省物理内存。

**文件与内存同步**：当内存中的数据被修改时，会立即同步到磁盘上的文件中，以保证数据的一致性。

**减少 I/O 操作**：通过内存映射，可以减少对磁盘的访问次数，提高程序的执行效率。

</v-clicks>

</div>

<div>

###### 加载

<v-clicks at="1">

**立即加载**：加载的定义就是将磁盘上的数据复制到物理内存中。

**私有内存**：每个进程都有自己独立的内存空间，即使访问相同的文件，内存也不会共享。

**文件与内存不同步**：内容加载到内存后，所有修改都是在内存中进行的，除非需要显式地写入文件，才能将修改同步到磁盘上。

**恒定 I/O**：每次访问文件都需要磁盘 I/O 操作，速度相对较慢。

</v-clicks>

</div>
</div>

---

# 内存映射

Memory Mapping

虚拟内存区域可以映射到两种类型的对象中的一种：

<div grid="~ cols-2 gap-8">
<div>

#### 普通文件{.mb-4}

- 一个区域可以映射到一个普通磁盘文件的连续部分
- 比如一个可执行文件，分成页大小的数据块
- 如果区域比文件区要大，那么就用零来填充这个区域的余下部分

</div>

<div>

#### 匿名文件{.mb-4}

- 由内核创建，全是二进制 `0` 构成
- 匿名文件并不真实存在，只是一个 trick，允许我们创建一个全是 `0` 的页
- **创建时，磁盘和内存之间没有任何实际的数据传送**{.text-sky-5}
- 换出时肯定有磁盘和内存之间的数据传送

</div>
</div>

---

# 交换空间

Swap space

交换空间：是 **磁盘**{.text-sky-5} 上的一个区域，用于存储那些被换出的页。

交换区可以被看作是物理内存的扩展，它提供了一个“缓存”以便在物理内存不足时存储更多的页。

**虚拟内存系统允许进程使用比实际物理内存更多的内存。**{.text-sky-5}

<v-clicks>

1. 对于一个正在运行的进程，他修改过后的页被存放在物理内存中，但是物理内存总有放满的一天。
2. 当它被选中为牺牲页牺牲的时候，肯定不能放回原来磁盘中的文件了（因为你此时没有显式地使用 `write` 等系统调用写回文件，要保证磁盘上的原始文件没变，要不然再来一个程序加载这个文件就坏事了）。
3. 于是只好将这些被修改过后的内容放到磁盘中一个统一的地方（Page-out），这个地方称为交换区（swap space）。

</v-clicks>

<div v-click>

交换区不一定是连续的，保存了进程被修改后的数据。可以把交换空间理解成 RAM 在磁盘上的坚实后盾。

书上提到交换区大小限制了当前运行的进程能够分配的虚拟页总数，事实上应该说 **物理内存 + 交换区**{.text-sky-5} 的大小限制了当前运行的进程能够分配的虚拟页总数。

</div>

---

# 共享对象

Shared Objects

虚拟内存系统承诺要给每个进程一个抽象：他们有自己的私有虚拟内存地址，不会被其他进程所修改。

但是有时候需要共享一些段，譬如说共享库（shared library）或者匿名页。

虚拟内存区域中通过 `vm_flags` 确定该虚拟内存区域中的虚拟页是否在进程之间共享。

1. 共享区域：各个进程在该区域中的操作是 **互相可见** 的，**且变化也会反映在磁盘上**
2. 私有区域：各个进程在该区域中的操作是 **互相不可见** 的，**也不会反映到磁盘上**


---

# 共享对象

Shared Objects

<div grid="~ cols-3 gap-6">
<div text-sm>

1. 在左边的进程中，磁盘上的一个对象通过内存映射与该进程的一个共享段关联起来，使得进程共享段的 PTE 指向磁盘上的文件，当引用该对象时，就会将对应的虚拟页加载到物理页中。
2. 右边的进程也想要把该对象与自己的一个共享段关联起来。当进程 2 对对象引用时，内核会发现左边的进程已经将对象的物理页加载进内存，因此只需要将进程 2 的 PTE 指向相同的物理页即可。

</div>

<div col-span-2>


![shared_object](/09-Virtual-Memory/shared_object.png){.mx-auto}


</div>
</div>

---

# 私有对象的写时复制

Copy On Write, COW

<div grid="~ cols-3 gap-6">
<div text-sm>

对于私有对象，使用一种叫做写时复制的巧妙技术。

1. 前面与共享对象一样，未发生修改时，物理内存只保存同一个对象副本。同时每个进程的 PTE 都是 **只读** 的
2. 当右边进程想修改时会触发 **保护故障（protect fault）**{.text-red-5}
3. 处理程序就会在物理内存中创建一个该物理页的副本
4. 然后让右边进程对该对象的 PTE 指向新的副本，并设置该虚拟页具有写权限，然后处理程序返回，从写指令重新运行。

注意这时左边进程的 PTE 还是指向最初的地方。

</div>

<div col-span-2>


![cow](/09-Virtual-Memory/cow.png){.mx-auto}


</div>
</div>

---

# Fork 和 Execve

`fork` & `execve`

<div grid="~ cols-2 gap-8" text-sm>
<div>

#### `fork`

```c
pid_t fork(void);
```

1. 创建一个具有相似但独立虚拟地址空间的子进程，并分配一个唯一的 PID
2. 内核会复制父进程的 `mm_struct`、`vm_area_struct` 与页表
3. 两个进程的页都设置为 **只读**{.text-sky-5} 的，**且所有区域都标记为私有的写时复制**{.text-sky-5}
4. 当父子进程都没有对页进行修改时，父子进程是共享相同的物理内存的
5. 当其中一个进程对页进行修改时，就会对该页进行写回复制，并为该页赋予写权限，并更新进程对应的页表

</div>

<div>

#### `execve`

```c
int execve(const char *filename, const char *argv[], const char *envp[]);
```

1. **删除已存在的用户区域**：当前运行的程序就会变为 `filename` 了，需要删除原先的 `vm_area_struct` 和页表
2. **映射私有区域**：为新的程序创建新的区域结构，建立内存映射，`bss`、`stack`、`heap` 都会映射到匿名文件
3. **映射共享区域**：如共享库动态链接
4. **设置程序计数器**：最后设置程序计数器指向代码段的入口点

类似于一个全新的加载程序的过程

</div>
</div>

---

# 加载器如何映射用户地址空间区域

How Loader Maps User Address Space Regions

![loader](/09-Virtual-Memory/loader.png){.mx-auto.h-100}

---

# Mmap

`mmap` Function

```c
void *mmap(void *start, size_t length, int port, int flags, int fd, off_t offset);
```

<div grid="~ cols-2 gap-8">
<div text-sm>

功能：使用文件描述符 `fd` 指定一个磁盘文件，该函数会将该磁盘文件中偏移 `offset` 处开始的 `length` 个字节的对象映射到虚拟内存中的 `start` 处（推荐，但不是必须）。

- `prot`：指定映射区域的访问权限，对应区域结构中的 `vm_prot`
  - `PROT_EXEC`：可执行
  - `PROT_READ`：可读
  - `PROT_WRITE`：可写
  - `PROT_NONE`：不可访问
- `flags`：指定映射区域的各种属性，对应区域结构中的 `vm_flags`

返回：若成功时则为指向映射区域的指针，若出错则为 `MAP_FAILED(-1)`

</div>

<div>

![mmap](/09-Virtual-Memory/mmap.png){.mx-auto}

</div>
</div>


----

# 动态内存分配

Dynamic Memory Allocation

基本上就是堆的相关内容，大家做 malloclab 一定会狠狠体验到的。

部分难点基本都在我的博客有所讲解：[malloclab](https://arthals.ink/blog/malloc-lab/)。


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
