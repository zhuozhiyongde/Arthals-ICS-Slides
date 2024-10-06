---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: https://cover.sli.dev
highlighter: shiki
# some information about your slides (markdown enabled)
title: 02-Machine-Programming-I
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
coverBackgroundUrl: /02-Machine-Programming-I/cover.jpg
colorSchema: dark
---

# 程序的机器表示 I {.font-bold}

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

# 基本概念

basic concepts

- Architecture（架构）{.font-bold.text-sky-5}：也称为 ISA（指令集架构，Instruction Set Architecture）。
  
  指处理器设计的一部分，程序员需要了解，以便编写正确的汇编代码（asm Code）或机器码（Machine Code）。

  包括指令集规范（Instruction Set Specification）和寄存器（Registers）等。

- Assembly Code（汇编代码）{.font-bold.text-sky-5}

  是机器码的文本表示形式，通常使用助记符和符号来代替二进制代码，以便程序员更容易理解和编写。

- Machine Code（机器码）{.font-bold.text-sky-5}
  
  是处理器可以直接执行的字节级别程序。通常以二进制形式表示，是计算机硬件可以理解和执行的最低级别的指令。

---

# 从 C 源代码到汇编代码

from C source code to assembly code

```bash
gcc -Og -S hello.c
gcc -Og -c hello.c
gcc -O1 -o hello hello.c
gcc -O1 -o hello hello.o
```

- 使用 `-S` 指令可以生成 `.s` 汇编代码文本
- 使用 `-c` 指令可以生成 `.o` 二进制汇编代码文件（只编译，不链接，在第七章-链接会讲）
- 使用 `-Og/-O1/-O2/-O3` 指令可以指定编译器优化等级

<br>

```bash
objdump -d hello > hello.asm
```

- 使用 `objdump` 可以将二进制文件通过反汇编得到它的汇编代码文本（Bomblab 中会用到！必学！）

---

# 基本概念

basic concepts

程序的底层执行通过 **汇编**{.text-sky-5} 代码进行。汇编代码由指令构成，这些指令被编码成二进制文件，CPU 可以读取并运行这些指令。

指令的内容包括内存读写操作、算术操作、控制操作等。

使用 Objdump 反编译一个二进制文件（在 Bomblab 你一定会用到）：

<div grid="~ cols-2 gap-12">
<div>



```bash
objdump -d bomb > bomb.asm
```

- `-d` 代表 disassemble，反汇编。
- `bomb` 是你要反汇编的二进制文件名。
- `> bomb.asm` 是将反汇编结果输出到 `bomb.asm` 文件中。

</div>

<div>

```asm
0000000000001000 <_init>:
    1000: f3 0f 1e fa                  	endbr64
    1004: 48 83 ec 08                  	subq	$8, %rsp
    1008: 48 8b 05 d9 5f 00 00         	movq	24537(%rip), %rax       # 0x6fe8 <_GLOBAL_OFFSET_TABLE_+0x118>
    100f: 48 85 c0                     	testq	%rax, %rax
    1012: 74 02                        	je	0x1016 <_init+0x16>
    1014: ff d0                        	callq	*%rax
    1016: 48 83 c4 08                  	addq	$8, %rsp
    101a: c3                           	retq
```


</div>
</div>

---

# 数据格式

data format

<div text="sm">

| C 声明     | Intel 数据类型 | 汇编代码后缀 (记忆) | 大小（字节） |
|------------|----------------|---------------|---------------|
| `char`       | 字节           | b (byte)             | 1             |
| `short`      | 字             | w (word)             | 2             |
| `int`        | 双字           | l (double word)             | 4             |
| `long`       | 四字           | q (quad word)             | 8             |
| `char*`      | 四字           | q (quad word)            | 8             |
| `float`      | 单精度         | s (single word)            | 4             |
| `double`     | 双精度         | l (double word)            | 8             |

</div>


<div class="text-sm text-gray-5">

我的记忆方法：`l` 是 linguist 语言学家，双语→双字；`q` → `square` 正方形，四条边→四字（或直接记 `quad` 词根）

</div>

---

# 程序计数器

Program Counter (PC)

- 程序计数器（PC）是一个寄存器，用于存储当前正在执行的指令的地址。
- 在 x86-64 中，程序计数器通常是 `%rip` 寄存器。
- 每当执行一条指令时，程序计数器会根据指令的长度自动更新，指向下一条指令的地址。

---
layout: image-right
image: /02-Machine-Programming-I/registers.png
backgroundSize: 80%
---

# 寄存器

Registers

这个表要完整的记忆下来。{.text-sky-5}

---

# 寄存器

Registers


- `%r[a-d]x` - `%e[a-d]x` - `%[a-d]x` - `%[a-d]l`

  Register / Extended / Lower-part

  - accumulator 累加寄存器 / **返回值**{.text-sky-5}
  - base 基址寄存器
  - count 计数寄存器
  - data 数据寄存器

  记忆：只有 `[a-d]x` 的 Low-part 除了尾加 `l` 以外，还删掉了原有的 `x` 后缀

---

# 寄存器

Registers

- `%r[s/d]i` - `%e[s/d]i` - `%[s/d]i` - `%[s/d]il`

  Register / Extended / Lower-part

  - source index 源索引寄存器
  - destination index 目的索引寄存器

  记忆：此处恢复正常，在 `[s/d]i` 后面直接加代表 low 的 `l` 后缀

---

# 寄存器

Registers

- `%r[b/s]p` - `%e[b/s]p` - `[b/s]p` - `[b/s]pl`

  Register / Extended / Lower-part

  - base pointer 栈基址寄存器
  - stack pointer 栈指针寄存器

  记忆：此处恢复正常，在 `[b/s]p` 后面直接加代表 low 的 `l` 后缀

---

# 寄存器

Registers

- `%r[8~15]` - `%r[8~15]d` - `%r[8~15]w` - `%r[8~15]b`

  Register / Double-word / Word / Byte

  - 命名非常规则

---

# 寄存器

Registers

<div grid="~ cols-2 gap-12">
<div>

### 被调用者保存寄存器

- `%rbx`
- `%rbp`
- `%r12` - `%r15`

记忆：`b` 开头代表 `backup`，`12` 代表 `要二（b）` 也是 `backup`

↑胡扯的，方便记忆就好{.text-sm.text-gray-5}

### 调用者保存寄存器{.mt-10}

除了上述寄存器外，其余寄存器均为调用者保存寄存器。

</div>

<div>

什么是被调用者保存寄存器？

- 当一个函数 `B` 被另一个函数 `A` 调用时，被调用者 `B` 在处理过程中，有可能覆盖一些寄存器，然而这些寄存器对于恢复 `A` 的执行状态非常重要。
- 因此，在 `B` 的开始处，将这些寄存器中的值 **保存**{.text-sky-5} 到栈中，在 `B` 的结束处，再将这些寄存器中的值从栈中 **恢复**{.text-sky-5}。
- 所以，我们称这些寄存器为被调用者（`B`）保存寄存器。

</div>
</div>

<!-- 比如，你计算斐波那契数列，然后外层要打印，那么就需要存储原始值（但这个例子中，实际上是调用者保存寄存器） -->

---

# 寄存器

Registers

<div grid="~ cols-2 gap-12">
<div>

### 参数寄存器{.mb-4}

- `%rdi`：第一个参数
- `%rsi`：第二个参数
- `%rdx`：第三个参数
- `%rcx`：第四个参数
- `%r8`：第五个参数
- `%r9`：第六个参数

硬记吧，反正就 6 个。{.text-sm.text-gray-5}

</div>

<div>

### 其他参数

超过 6 个参数的函数调用，**使用栈传递**{.text-sky-5}。

</div>
</div>

---

# 存储

storage

程序在运行时的存储主要有 **寄存器（条件码）**{.text-sky-5} 和 **内存**{.text-sky-5}。

- 内存可以抽象为一个下标范围为 $2^{32}$ 或 $2^{64}$ 的字节数组（由操作系统是 32 位还是 64 位决定）。
- 寄存器可以看作运行过程中可以快速访问的变量，所有寄存器都有特定的功能。

---

# 操作数指示符

operand indicator

操作数主要各式如下图。注意：
- 基址和变址寄存器必须是 64 位寄存器 <span class="text-sm text-gray-5">（记忆：64 位系统）</span> → `(%eax)` 不合法
- 比例因子必须是 1、2、4、8 <span class="text-sm text-gray-5">（记忆：二进制）</span> → `(,%rax,3)` 不合法


![operand](/02-Machine-Programming-I/operand.png){.h-70.mx-auto}


<!-- 

为什么必须是 1，2，4，8？因为这是二进制！

 -->

---

# Mov 类指令

`mov` instruction

<div text="sm">

| MOV S, D   | D←S    | 传送           |
|------------|--------|----------------|
| `movb`     |        | 传送字节       |
| `movw`     |        | 传送字         |
| `movl`     |        | 传送双字 <span class="text-sky-5">*</span>       |
| `movq`     |        | 传送四字       |
| `movabsq I, R` | R←I  | 传送绝对的四字|

</div>

- `mov` 指令的两个操作不能都是内存类型，<span class="text-gray-5 text-sm">D 表示 destination / 目的地，S 表示 source / 源。</span>
- 寄存器大小必须和指令后缀匹配。
- \*{.text-sky-5} `movl` 指令以寄存器为目的时，会将高位 4 字节清零。

<!-- 不要搞反表达式 -->

---

# Mov 类指令

`mov` instruction

<div text="sm" grid="~ cols-2 gap-12">

<div>

| S, R         | `movz`         |`movs`|
|--------------|--------------|-----------|
| 1→2          | `movzbw`       |`movsbw`|           
| 1→4          | `movzbl`       |`movsbl`|       
| 1→8          | `movzbq`       |`movsbq`|          
| 2→4          | `movzwl`       |`movswl`|       
| 2→8          | `movzwq`       |`movswq`|      
| 4→8          | `movl`{.text-sky-5}       |`movslq`|
| 4→8          | /       |`cltq`| 

</div>

<div text="base">

`cltq`：convert long to quad，将 `%eax` 符号扩展到 `%rax`，等价于 `movslq %eax, %rax`。

`s`：代表符号扩展，`z`：代表零扩展。

没有 `movzlq`，因为其等价于 `movl`

</div>

</div>
---

# Mov 类指令

`mov` instruction

在 x86-64 下，以下哪个选项的说法是错误的？

- A. `movl` 指令以寄存器为目的时，会将该寄存器的高位 4 字节设置为 0
- B. `cltq` 指令的作用是将 `%eax` 符号扩展到 `%rax`
- C. `movabsq` 指令只能以寄存器为目的地
- D. `movswq` 指令的作用是将零扩展的字传送到四字节目的地

<!-- 很显然，选 D -->

---
layout: image-right
image: /02-Machine-Programming-I/runtime-memory.png
backgroundSize: 80%
---

# 栈

stack

栈在程序运行时具有很重要的作用，包括：

- **函数调用管理**：每次函数调用时，都会在栈上创建一个新的栈帧（Stack Frame），用于存储函数的局部变量、返回地址等信息。
- **局部变量存储**：函数的局部变量会存储在栈帧中，函数结束时这些变量会自动释放（通过调整栈顶指针 `%rsp` 标记）。
- **控制流管理**：通过保存返回地址，确保函数调用结束后能正确返回调用点。

<!-- 

一个理解：为什么向下增长？往上是内核态，容易爆炸，这在 Attack lab 中会类似地用到

这里还可以提一下书 P114 页中上部分为什么用户内存虚拟地址高 16 位必须要求是 0，因为再往上就是内核态了，用户程序无法访问。
 -->

---
layout: image-right
image: /02-Machine-Programming-I/runtime-memory.png
backgroundSize: 80%
---

# 栈

stack

- 栈从高地址向低地址增长 <span class="text-sky-5">（向下增长）</span>
- `%rsp` 表示栈中最低地址元素所在的位置（栈顶）
- `%rbp` 表示栈中最高地址元素所在的位置（栈底）
- 超过 6 个参数的函数调用，使用栈传递参数

回忆一下，第 1~6 个参数分别使用那些寄存器传递？

<div v-click>

`%rdi`，`%rsi`，`%rdx`，`%rcx`，`%r8`，`%r9`

</div>

---

# 栈的数据操作

stack data operation

| 指令        | 影响                                      | 描述               |
|-------------|-----------------------------------------|--------------------|
| `pushq S`     | `R[%rsp] ← R[%rsp] - 8; M[R[%rsp]] ← S`   | 压入四字（quad）数据 |
| `popq D`      | `D ← M[R[%rsp]]; R[%rsp] ← R[%rsp] + 8`   | 弹出四字（quad）数据 |

注意顺序！会考！尤其是一些奇怪的题目甚至会考 `popq %rsp` 这种不知所云的东西。

---

# 栈的数据操作

stack data operation

![push-pop](/02-Machine-Programming-I/push-pop.png){.h-90.mx-auto}

---
layout: image-right
image: /02-Machine-Programming-I/stack.png
backgroundSize: contain
---

# 栈的结构

structure of the stack

注意参数的压栈顺序、被调用者保存的寄存器。


---

# 算数和逻辑操作

arithmetic and logical operations

<div grid="~ cols-2 gap-12">
<div text="sm">

| 指令   | 效果                    | 描述                     |
|--------|-------------------------|--------------------------|
| LEAQ   | D ← &S                  | 加载有效地址             |
| INC    | D ← D + 1               | 递增                     |
| DEC    | D ← D - 1               | 递减                     |
| NEG    | D ← -D                  | 取反                     |
| NOT    | D ← ~D                  | 反补码                   |
| ADD    | D ← D + S               | 加法                     |
| SUB    | D ← D - S               | 减法                     |
| IMUL   | D ← D * S               | 乘法                     |

</div>

<div text="sm">

| 指令   | 效果                    | 描述                     |
|--------|-------------------------|--------------------------|
| XOR    | D ← D ^ S               | 异或                     |
| OR     | D ← D | S              | 或                       |
| AND    | D ← D & S               | 与                       |
| SAL    | D ← D << k              | 左移                     |
| SHL    | D ← D << k              | 左移（与 SAL 相同）      |
| SAR    | D ← D >> <span text="8px">A</span> k            | 算术右移                 |
| SHR    | D ← D >> <span text="8px">L</span> k            | 逻辑右移                 |

</div>
</div>

---

# leaq 指令

leaq instruction

`leaq` 指令：load effective address，意为“加载有效地址”。**但实际上主要用于计算**{.text-sky-5}

- “加载”是取内存的意思，地址代表取值，相当于 C 中先 `*` 再 `&`，等于没与内存交互。

  所以 `leaq` 指令主要用于计算，比如 `leaq 7(%rdx,%rdx,4), %rax` 意为 `%rax = 7 + 5 * %rdx`

- `leaq` 支持多种寻址方法，但是要求 `D` 必须是寄存器
- `leaq` 不改变条件码（常考）


<div class="text-sm">


暗坑之省略也要加逗号：

```asm
leaq (%rdx, 1), %rdx
```

应当改为：

```asm
leaq (,%rdx,1), %rdx
```

</div>

---

# 移位操作

shift operation

移位量可以是一个立即数，或者放在单字节寄存器 `%cl`中。

注意：只有这个寄存器可以存移位量！<span class="text-sky-5">（记忆：`cl` → count lower）</span>

左移（`SAL` / `SHL`）是等价的，但是右移会区分算术右移（`SAR`，前补符号位）和逻辑右移（`SHR`，前补 0）。

---

# 特殊算数操作

special arithmetic operations

<div text="sm">

| 指令     | 效果                                            | 描述                  |
|----------|-------------------------------------------------|-----------------------|
| `imulq S`| `R[%rdx]:R[%rax] ← S × R[%rax]`               | 有符号全乘法          |
| `mulq S` | `R[%rdx]:R[%rax] ← S × R[%rax]`                | 无符号全乘法          |
| `cqto`   | `R[%rdx]:R[%rax] ← SignExtend(R[%rax])`       | 转换为八字节          |
| `idivq S`| `R[%rdx] ← R[%rax] mod S; R[%rax] ← R[%rdx] ÷ S` | 有符号除法            |
| `divq S` | `R[%rdx] ← R[%rax] mod S; R[%rax] ← R[%rdx] ÷ S` | 无符号除法            |

</div>

勘误：书上这里写成 `clto` 了。

一般这里只考搭配的是 `%rax` 和 `%rdx` 两个寄存器，且后者在乘法里是高位。`%rax` 在除法里用于存商（因为 `%rax` 一般用于返回结果，可以这么记）
---

# 标志位

condition code / flags

每次执行完算数指令之后，会有 4 个条件码被隐式的修改：

- ZF（Zero Flag）：当该次运算结果为 0 时被置为 1，否则置为 0
- SF（Sign Flag）：当运算结果的符号位（最高位）为 1 时被置为 1，否则置为 0
- CF（Carry Flag）：当两个 unsigned 类型的数作运算因 **进位/借位**{.text-sky-5} 而发生溢出时置为 1，否则置为 0
- OF（Overflow Flag）：当两个 signed 类型的数做运算而发生符号位溢出时置为 1，否则置为 0

### 注意区分 “进位” 和 “溢出”{.mt-10.mb-6}

-   有 “溢出” 时，不一定有 “进位”，对应 **有符号数** 的相同符号大整数因为表示范围上限限制加超了 / 下限限制减超了，在阿贝尔群下 “轮回” 了，相差一个 $2^N$
-   有 “进位” 时，不一定有 “溢出”，对应 **无符号数** 的大整数因为表示范围上限限制加超了，相差一个 $2^N$

---

# 标志位

condition code / flags

设置条件码的细节：
- 如果无符号数减法发生了借位，也会设置 `CF` 为 1
- `leaq` 指令不改变任何条件码
- 逻辑操作（`AND`、`OR`、`XOR`、`NOT`）会把 `CF` 和 `OF` 设置成 0
- 移位操作会把 `CF` 设置为最后一个被移出的位，`OF` 设置为 0
- `INC` 和 `DEC` 指令会设置 `OF` 和 `ZF`，但是不会改变 `CF`

---

# 条件码指令

`cmpq` and `testq`

<div grid="~ cols-2 gap-12">
<div>

### `cmpq s1, s2`

包括 `cmpb` / `cmpw` / `cmpl` / `cmpq`

计算 `s2 - s1`，但不同于 `subq` 会修改 `s2` 的值，`cmpq` 只会影响条件码的值{.text-sky-5}。

注意顺序！记忆：大多数指令都是源操作数在前，目的操作数在后

</div>

<div>

### `testq s1, s2`

包括 `testb` / `testw` / `testl` / `testq`

计算 `s1 & s2`，<span text="sky-5">同样只会影响条件码的值</span>。

</div>
</div>

---

# 条件码指令

`setX`

我们并不能直接访问 Condition Codes，但我们可以用指令 `setX` 来间接的获取它们的值。

| setX        | 操作          | 描述               |
| ----------- | ------------------ | -------------- |
| `sete D`      | `D ← ZF`              | 等于 0 时设置|
| `setne D`     | `D ← ~ZF`             | 不等于 0 时设置|
| `sets D`      | `D ← SF`              | 负数时设置|
| `setns D`     | `D ← ~SF`             | 非负数时设置|

需要注意的是，`setX` 只会将最低的 1 个 Byte 置为相应的值，其他 Byte 保持不变！

Q：如果想要设置全部 8 Byte，该使用什么指令？ <span v-click>A：`movzbl` / `movzbq`</span>

---

# 条件码指令

`setX`

| setX        | 操作          | 描述               |
| ----------- | ------------------ | -------- |
| `setg D`  | `D ← ~(SF^OF)&~ZF` | 大于（有符号）          |
| `setge D` | `D ← ~(SF^OF)`     | 大于或等于（有符号） |
| `setl D`  | `D ← (SF^OF)`      | 小于（有符号）             |
| `setle D` | `D ← (SF^OF)\|ZF`  | 小于或等于（有符号）    |
| `seta D`  | `D ← ~CF&~ZF`      | 大于（无符号）          |
| `setb D`  | `D ← CF`           | 小于（无符号）          |

---

# 小于条件的证明

proof of `setl`

当 $a < b$ 时，有两种情况：

<div grid="~ cols-2 gap-12">
<div>

1. **有溢出的情况**：
   - 条件： $a < b$ 且 $(a - b)_{\text{补码}} > 0$
   - 结果：会发生负溢出
   - 标志位： $OF = 1, SF = 0$

</div>

<div>

2. **无溢出的情况**：
   - 条件： $a < b$ 且 $(a - b)_{\text{补码}} < 0$
   - 结果：不会发生溢出
   - 标志位： $OF = 0, SF = 1$（负数）

</div>
</div>

由此，判断是否小于，可以用异或表达式 `OF ^ SF` 来表示。

而且，我们无法直接获得 `OF` 的值。

---

# 跳转指令

jumping instruction

<div grid="~ cols-2 gap-12">
<div>

### 直接跳转

```asm
Label:
  ...
  jmp Label
```

跳转目标作为指令的一部分编码，要定义 `Label`

</div>

<div>

### 间接跳转

```asm
jmp *Operand    e.g. jmp *%rax ; jmp *(%rax)
```

跳转目标是从寄存器或内存位置中读出的，有一个类似先前 `mov` 指令中介绍的取值表达式

在后面介绍的 `switch` 跳转表中会用到！

</div>
</div>

---

# 跳转指令的编码

encoding of jumping instruction


<div grid="~ cols-2 gap-12 gap-y-4">
<div>

### PC 相对的（PC-relative）

将目标指令的地址与紧跟在跳转指令后面那条指令的地址之间的差作为编码

- 当执行 `PC` 相对寻址时，**程序计数器的值是跳转指令后面的那条指令的地址**{.text-sky-5}
- 地址偏移量可以编码为 **1、2、4**{.text-sky-5} 个字节，有符号

好处：

- 指令编码更简洁（很多情况下只需要 1、2 个字节指代地址）
- 代码可以不做任何改变就移到内存中不同的位置


</div>

<div>

### 绝对地址

用 4 个字节直接指定目标

</div>
</div>

---

# PC 相对的跳转指令的编码

encoding of PC-relative jumping instruction

注意，其中一个加数的是 **下一条指令**{.text-sky-5} 的地址！

![jmp-offset](/02-Machine-Programming-I/jmp-offset.png){.h-90.mx-auto}

---

# PC 相对的跳转指令的编码

encoding of PC-relative jumping instruction

在如下代码段的跳转指令中，目的地址是？

```asm
400020: 74 FO     je ____
400022: 5d        pop %rbp
```
<div v-click>


- `je` 指令：1 字节操作码 + 1 字节偏移量
- 偏移量范围：-128 到 +127（共256个字节）

`0xF0` 是一个负数，我们使用 `-x = ~x + 1` 来快速准确转换

`~0xF0 = 0x0F, 0x0F + 1 = 0x10`

`400022 - 0x10 = 400012`

</div>

---

# 条件跳转指令

conditional branches & jumping

以 `.Expr:` 的格式定义跳代码块后，可以利用 `jX` 指令跳转到指定的代码位置。

利用不同的 jumping 指令（定义类似之前的 `setX` 指令），我们可以实现条件分支。

<div grid="~ cols-2 gap-6" text="sm">
<div>

| jX        | 条件          |
| --------- | --------------|
| `jmp`     | `1`           |
| `je`      | `ZF`          |
| `jne`     | `~ZF`         |
| `js`      | `SF`          |
| `jns`     | `~SF`         |

</div>

<div>

| jX        | Condition      |
| --------- | ---------------|
| `jg`      | `~(SF^OF)&~ZF` |
| `jge`     | `~(SF^OF)`     |
| `jl`      | `(SF^OF)`      |
| `jle`     | `(SF^OF)\|ZF`  |
| `ja`      | `~CF&~ZF`      |
| `jb`      | `CF`           |

</div>
</div>

---

# 条件跳转指令示例

conditional branches example

<div grid="~ cols-2 gap-12">
<div>


```c
long absdiff(long x, long y){
    long result;
    if(x > y) result = x-y;
    else result = y-x;
    return result;
}
```

<br>

```asm
absdiff:
    cmpq %rsi, %rdi  # x:y
    jle .L4
    movq %rdi, %rax
    subq %rsi, %rax
    ret
.L4:       # x <= y
    movq %rsi, %rax
    subq %rdi, %rax
    ret
```

</div>

<div>

等价的 `goto` 版本：

```c
long absdiff_goto(long x, long y){
    long result;
    if(x > y) goto x_gt_y;
    result = y-x;
    return result;
x_gt_y:
    result = x-y;
    return result;
}
```

注意这里对 `if else` 的转写，在 Archlab 中会用到！


</div>
</div>


---

# 条件传送指令

`cmov` (conditional move) instruction

`cmovX S, R`：当条件码 `X` 满足时，将源操作数（寄存器或内存地址） `S` 传送到目的寄存器 `R`

- **不支持单字节的条件传送**{.text-sky-5}
- 汇编器可以从目标寄存器的名字推断出条件传送指令的操作数长度，而无需显式写出（Diff：`movw`、`movl`、`movq`）
- 与流水线预测有关（第四章会学），并不总会提升效率

---

# 条件传送的适用条件

conditional move applicable conditions

只有当两个表达式（then-expr 和 else-expr）都很容易计算时，GCC才会使用条件传送

一些不会使用条件传送的情况：

<div text="sm">

1. 表达式的求值需要大量的运算
2. 表达式的求值可能导致错误

    ```c
    val = p ? *p : 0;
    ```

    在这个式子中，涉及指针的解引用操作，有可能会导致错误，如 `p` 为空指针

3. 表达式的求值可能导致副作用

    ```c
    val = x > 0 ? x *= 7 : x += 3;
    ```

    这两个操作都会修改`x`的值，称为副作用。条件传送要求在硬件层面一次性完成选择操作，而不能处理带有副作用的表达式。
    
    如果使用条件传送，无法保证 `x` 的修改只发生在条件满足的情况下。

</div>

---

# 条件传送的适用条件

conditional move applicable conditions

对于下列四个函数，假设 gcc 开了编译优化，判断 gcc 是否会将其编译为条件传送

<div grid="~ cols-2 gap-4">
<div>

```c
long f1(long a, long b) {
    return (++a > --b) ? a : b;
}
```

</div>

<div>

```c
long f2(long *a, long *b) {
    return (*a > *b) ? --(*a) : (*b)--;
}
```

</div>
<div>

```c
long f3(long *a, long *b) {
    return a ? *a : (b ? *b : 0);
}
```

</div>

<div>

```c
long f4(long a, long b) {
    return (a > b) ? a++ : ++b;
}
```

</div>
</div>

你可以使用 [在线编译器](https://godbolt.org/) 来验证！（注意别在你的 ARM 设备上试，会不一样）

<div v-click text="sm">

- `f1` 由于比较前计算出的 `a` 与 `b` 就是条件传送的目标，因此会被编译成条件传送；
- `f2` 由于比较结果会导致 `a` 与 `b` 指向的元素发生不同的改变，因此会被编译成条件跳转，或者直接因为使用了指针排除掉；
- `f3` 由于指针 `a` 可能无效，因此会被编译为条件跳转；
- `f4` 会被编译成条件传送，注意到 `a` 和 `b` 都是局部变量，return 的时候对 `a` 和 `b` 的操作都是没有用的。

</div>

---

# do-while 循环

do-while loop

<div grid="~ cols-2 gap-12">
<div>


```c
do
    body-statement
while (test-expr);
```

此语法结构决定了循环体至少执行一次。

</div>

<div>

```c
loop:
    body-statement
    t = test-expr;
    if (t)
        goto loop;
```

</div>
</div>

<div grid="~ cols-2 gap-12">
<div>

```c
long fact_do(long n) {
    long result = 1;
    do {
        result *= n;
        n = n - 1;
    } while (n > 1);
    return result;
}
```

</div>

<div>


```asm
; long fact_do(long n)
; n 存储在 %rdi
fact_do:
    movl $1, %eax       ; 初始化 result = 1
.L2:
    imulq %rdi, %rax    ; 计算 result *= n
    subq $1, %rdi       ; 计算 n = n - 1
    cmpq $1, %rdi       ; 比较 n : 1
    jg .L2              ; 如果 n > 1，跳转到 .L2
    rep; ret            ; 返回
```

</div>
</div>

---

# while 循环

while loop

<div grid="~ cols-2 gap-12">
<div>


```c
while (test-expr)
    body-statement
```

</div>

<div>


```c
goto test;
loop:
    body-statement
test:
    t = test-expr;
    if (t)
        goto loop;
```

</div>
</div>

<div grid="~ cols-2 gap-12">
<div>

```c
long fact_while(long n) {
    long result = 1;
    while (n > 1) {
        result *= n;
        n = n - 1;
    }
    return result;
}
```

</div>

<div>

```asm
; long fact_while(long n)
; n 存储在 %rdi
fact_while:
    movl $1, %eax       ; 初始化 result = 1
    jmp .L5             ; Goto test
.L6:
    imulq %rdi, %rax    ; 计算 result *= n
    subq $1, %rdi       ; 计算 n = n - 1
.L5:
    cmpq $1, %rdi       ; 比较 n : 1
    jg .L6              ; 如果 n > 1，跳转到 .L6
    rep; ret            ; 返回
```

</div>
</div>

---

# while 循环 - guarded do

while loop - guarded do

<div grid="~ cols-2 gap-12">
<div>

```c
t = test-expr;
if (!t)
    goto done;
loop:
    body-statement
    t = test-expr;
    if (t)
        goto loop;
done:
```

```c
long fact_while(long n) {
    long result = 1;
    while (n > 1) {
        result *= n;
        n = n - 1;
    }
    return result;
}
```

</div>

<div>

```asm
; long fact_while(long n)
; n 存储在 %rdi
fact_while:
    cmpq $1, %rdi       ; 比较 n : 1
    jle .L7             ; 如果 <=, 跳转到 done
    movl $1, %eax

.L6:
    imulq %rdi, %rax    ; 计算 result *= n
    subq $1, %rdi       ; 计算 n = n - 1
    cmpq $1, %rdi       ; 比较 n : 1
    jne .L6             ; 如果 n != 1，跳转到 .L6
    rep; ret            ; 返回
.L7:
    movl $1, %eax       ; 计算 result = 1
    ret                 ; 返回
```

</div>
</div>

---

# for 循环

for loop

```c
for (init-expr; test-expr; update-expr)
    body-statement
```

只需转换为 while 循环：

```c
init-expr;
while (test-expr) {
    body-statement
    update-expr;
}
```

---

# Switch 语句

switch statement

使用跳转表的场景：

- 当开关情况数量比较多（例如 4 个以上）
- 值的范围跨度比较小时（数据的极差不能过大）

优点：执行开关语句的时间与开关情况的数量无关。可以看做一种用空间换时间的策略

具体实现：

- 在 `.rodata`（只读数据）段中，用连续的地址存放一张跳转表，跳转表中的每一个表项对应了 switch 的一个分支代码段的所在地址
- 在 `switch` 对应的汇编代码段中，用 `jmp *JumpTab[x]` 间接跳转的方式跳转到对应的分支

简便理解：在一段特定的内存空间（跳转表）中，连续存放了多个跳转指令起始入口的地址，然后通过间接跳转的方法，根据当前的 `case` 值，跳转到对应的 `case` 代码段中。

---

# 小测试

quiz

下面关于布尔代数的叙述，错误的是：

- A. 设 `x, y, z` 是整型，则 `x^y^z == y^z^x`
- B. 任何逻辑运算都可以由与运算 (`&`) 和异或运算 (`^`) 组合得到
- C. 设 `m, n` 是 `char*` 类型的指针，则下面三条语句 `*n = *m^*n; *m = *m^*n; *n = *m^*n;` 可以交换 `*m` 和 `*n` 的值
- D. 已知 `a, b` 是整型，且 `a+b+1==0` 为真，则 `a^b+1==0` 为真

<div v-click>

A. 正确，考虑每个 bit 的最终结果只和 `x, y, z` 的对应 bit 有多少个 0、多少个 1 有关，而和异或顺序无关

B. 正确，非 `~ A = A ^ 1`；或 `A | B = (A ^ 1) & (B ^ 1) ^ 1`，即 `A | B = ~ (~ A & ~ B)`

C. 错误，因为 `m` 和 `n` 可能指向同一个地址，所以第一句话直接置零了。但对于其他情况，是对的。

D. 正确，这个非常离谱，下一页 PPT 单独讲。

</div>

---

# 小测试

quiz

- D. 已知 `a, b` 是整型，且 `a+b+1==0` 为真，则 `a^b+1==0` 为真

第一层理解：前面等价于 `a+b == -1`，后面等价于 `a^b == -1`，利用 `a = -b - 1 = ~b + 1 -1 = ~b` 可推知（对于 `b` 是 $T_{min}$ 的情况要特判，此时 `a` 是 $T_{max}$，也满足）

第二层理解：注意到右式中没加括号，存在运算优先级问题，查 [优先级表](https://c-cpp.com/c/language/operator_precedence) 发现，计算优先级 `+` > `==` > `^`，直接推得右式是错的。

第三层理解：在第二层理解上再次思考，考虑了优先级后，何时 `a^((b+1)==0)` 为假？

此时，我们有 `a = 1 | a = 0`，且 `a + b = -1`

<div grid="~ cols-2 gap-12">
<div>

`a = 1`，则 `b = -2`，那么 `a^((b+1)==0) = a^(-1==0) = a^0 = 1`，为真。

</div>

<div>

`a = 0`，则 `b = -1`，那么 `a^((b+1)==0) = a^(0==0) = a^1 = 1`，为真。

</div>
</div>

所以，此选项仍然正确。

---

# 思考题

thinking questions of *Machine Prog: Basics*

1. 一份 C 语言写成的代码，在 x86-64 架构的处理器上的 Ubuntu 系统中编译成可执行文件，需要经过哪些步骤？（超纲了，在第七章讲）
2. 为什么在寄存器上读、写数据时不需要再考虑大端法和小端法的区别？
3. 为什么 `movg` 指令的 `S (scale)` 参数总是 1，2，4 或者 8？
4. <span text="gray-5">*</span> 为什么 1 中编译的可执行文件无法在同一处理器上的 Windows 系统上执行？分歧主要发生在哪一步骤中？

---

# 思考题

thinking questions of *Machine Prog: Control*

1. 如何对一个寄存器较高的字节赋值，同时不改变较低的字节？
2. 为什么不建议使用条件赋值？
3. C 语言中三种循环形式(`for`，`while`，`do-while`)，理论上哪种效率更高？
4. 为什么 C 语言中的 `switch` 语句需要在每个分支后 `break` 才能退出？



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
