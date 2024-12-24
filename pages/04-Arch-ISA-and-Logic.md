---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: https://cover.sli.dev
highlighter: shiki
# some information about your slides (markdown enabled)
title: 04-Arch-ISA-and-Logic
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
coverBackgroundUrl: /04-Arch-ISA-and-Logic/cover.jpg
---

# 程序的机器表示 III & ISA {.font-bold}

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

# C 语言中的复合类型

composite types in C Language

<div grid="~ cols-3 gap-12">
<div>

### 数组（Arrays）

- 连续的内存分配
- 按照每个元素的对齐要求进行对齐
- 指向第一个元素的指针
- 不进行边界检查{.text-sky-5}
  ```c
  int arr[3] = {1, 2, 3};
  int var = arr[3];
  ```

</div>

<div>

### 结构体（Structures）

- 按声明的顺序分配字节
- 中间和末尾填充以满足对齐要求

</div>

<div>

### 联合体（Unions）

- 重叠声明
- 是绕过类型系统的方式

</div>
</div>

---

# 字节顺序对于类型转换的影响

the impact of byte order on type conversion

<div grid="~ cols-2 gap-12">
<div>

```c  {*}{maxHeight:'380px'}
union {
    unsigned char c[8];
    unsigned short s[4];
    unsigned int i[2];
    unsigned long l[1];
} dw;

int main() {
    // 初始化字符数组
    for (int j = 0; j < 8; j++)
        dw.c[j] = 0xf0 + j;
    // 打印字符数组
    printf("Characters 0-7 == [0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x]\n",
        dw.c[0], dw.c[1], dw.c[2], dw.c[3],
        dw.c[4], dw.c[5], dw.c[6], dw.c[7]);
    // 打印短整型数组
    printf("Shorts 0-3 == [0x%x, 0x%x, 0x%x, 0x%x]\n",
        dw.s[0], dw.s[1], dw.s[2], dw.s[3]);
    // 打印整型数组
    printf("Ints 0-1 == [0x%x, 0x%x]\n",
        dw.i[0], dw.i[1]);
    // 打印长整型数组
    printf("Long 0 == [0x%lx]\n",
        dw.l[0]);
}
```

</div>

<div>

运行结果：

```
Characters 0-7 == [0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7]
Shorts 0-3 == [0xf1f0, 0xf3f2, 0xf5f4, 0xf7f6]
Ints 0-1 == [0xf3f2f1f0, 0xf7f6f5f4]
Long 0 == [0xf7f6f5f4f3f2f1f0]
```

</div>
</div>

---

<div grid="~ cols-2 gap-12">
<div text-sm>

# x86-64 Linux 内存布局

memory layout

- **栈（Stack）**
  - 运行时栈（8MB 限制）
  - 例如：局部变量
- **堆（Heap）**
  - 按需动态分配
  - 当调用 `malloc()` `calloc()` `new()`
- **数据（Data）**
  - 静态分配数据
  - 例如：全局变量、静态变量、字符串常量
- **文本 / 共享库（Text / Shared Libraries）**
  - 可执行的机器指令
  - 只读，尝试写会导致段错误
  <br>（Segmentation Fault）{.text-gray-5}

注意始末地址：自 $0\text{x}400000$ 到 $2^{48} -1$ 是用户态空间，再往上是内核态（操作系统）

</div>

<div>

![memory-layout](/04-Arch-ISA-and-Logic/memory-layout.png)

</div>
</div>


---

# 内存分配示例

example of memory allocation

<div grid="~ cols-2 gap-12">
<div>


```c
char big_array[1L<<24]; // 16 MB
char huge_array[1L<<31]; // 2 GB

int global = 0;

int useless() { return 0; }

int main () {
    void *phuge1, *psmall12, *phuge3, *psmall14;
    int local = 0;
    phuge1 = malloc(1L << 28); // 256 MB
    psmall12 = malloc(1L << 8); // 256 B
    phuge3 = malloc(1L << 32); // 4 GB
    psmall14 = malloc(1L << 8); // 256 B
    /* Some print statements ... */
}
```

</div>

<div>

![memory-layout-2](/04-Arch-ISA-and-Logic/memory-layout-2.png)

</div>
</div>

---

# 内存分配示例

example of memory allocation

<div grid="~ cols-2 gap-12">
<div>

1. **全局变量和数组**：
   ```c
   char big_array[1L<<24];  /* 16 MB */
   char huge_array[1L<<31]; /* 2 GB */
   int global = 0;
   ```
   - **位置**：Data 段
   - **原因**：全局变量和静态变量在程序启动时分配内存，存在于 Data 段中，直到程序结束。

</div>

<div>

![memory-layout-2](/04-Arch-ISA-and-Logic/memory-layout-2.png)

</div>
</div>

---

# 内存分配示例

example of memory allocation

<div grid="~ cols-2 gap-12">
<div>

2. **局部变量**：
   ```c
   int main () {
      //...
      int local = 0;
      //...
   }
   ```
   - **位置**：Stack 段
   - **原因**：局部变量在函数调用时分配内存，存在于栈中，函数返回后内存释放。
   - **注意**：栈帧的大小是有限的，递归函数会导致栈帧的深层嵌套，当栈帧满时，会发生栈溢出（Stack Overflow）。递归判断出口条件出错使得无限调用函数时会出现这种错误。

</div>

<div>

![memory-layout-2](/04-Arch-ISA-and-Logic/memory-layout-2.png)

</div>
</div>

---

# 内存分配示例

example of memory allocation

<div grid="~ cols-2 gap-12">
<div>

3. **动态内存分配**：
   ```c
   void *phuge1, *psmall2, *phuge3, *psmall4;
   phuge1 = malloc(1L << 28);  /* 256 MB */
   psmall2 = malloc(1L << 8);  /* 256 B */
   phuge3 = malloc(1L << 32);  /* 4 GB */
   psmall4 = malloc(1L << 8);  /* 256 B */
   ```
   - **位置**：Heap 段
   - **原因**：`malloc` 函数动态分配内存，内存块从堆中分配，手动管理分配和释放。对于大的块，可能会分配到共享库附近。

</div>

<div>

![memory-layout-2](/04-Arch-ISA-and-Logic/memory-layout-2.png)

</div>
</div>

---

# 内存分配示例

example of memory allocation

<div grid="~ cols-2 gap-12">
<div>

4. **函数代码**：
   ```c
   int useless() { return 0; }
   int main () { ... }
   ```
   - **位置**：Text 段
   - **原因**：程序的代码部分存储在 Text 段中，包含所有的函数代码。

</div>

<div>

![memory-layout-2](/04-Arch-ISA-and-Logic/memory-layout-2.png)

</div>
</div>

---

# 内存分配总结

summary of memory allocation

- **全局变量和静态变量**（如`big_array`、`huge_array`、`global`）在 Data 段，程序启动时分配内存。
- **局部变量**（如`local`）在 Stack 段，函数调用时分配内存，函数返回后释放。
- **动态分配的内存**（如`phuge1`、`psmall2`等）在 Heap 段，通过`malloc`分配，需要手动释放，对于大的块，可能会分配到共享库附近。
- **代码段**（如`useless`函数和`main`函数）在 Text 段，包含程序的指令。

---

# 缓冲区溢出

buffer overflow

**缓冲区溢出**：指当程序试图将数据写入超出其分配的内存区域时发生的一种错误。

前置条件：

- 未正确检查输入数据的边界或者长度，导致数据溢出到相邻的内存区域。
- 局部变量和状态信息（如备份的被调用者保存寄存器）都存放在栈中，可能与缓冲区（数组）相邻。


此时，越界写操作会破坏存储在栈中的状态信息。

当程序使用这个被破坏的状态，试图重新加载寄存器或执行 `ret` 指令时，就会出现很严重的错误。

尤其是一些字符串输入的函数容易出现溢出，如 `strcpy` `sprintf` `scanf` `gets` 等。

---

# ROP 攻击

return-oriented programming attack

ROP 攻击是一种利用程序中已有的指令片段（gadget）来构造出特定指令序列的技术。

通过精心构造的指令序列，可以实现对程序的控制，绕过安全机制，执行任意代码。

1. 找到许多以 `ret`（`0xc3`）结尾的小代码段（gadget）
2. 把他们的地址逐一放以某个栈上返回地址结尾的一段内存中
3. 这些小代码段被正常的过程返回机制逐一执行

在 Attacklab 中，你会亲手实现 ROP 攻击！

---

# ROP 攻击

return-oriented programming attack

<div grid="~ cols-3 gap-12">
<div>

```c
/* Echo Line */
void echo() {
    char buf[4]; /* Way too small! */
    gets(buf);
}
```

这段代码分配了一个大小为 4 字节的缓冲区，然后调用 `gets` 函数从标准输入读取一行数据并存储在缓冲区中。

</div>

<div>

```asm
echo:
    subq $24, %rsp
    movq %rsp, %rdi
    call gets
    ...
```

- `subq $24, %rsp`
  <br>将栈指针向下移动 24 字节
- `movq %rsp, %rdi`
  <br>将栈指针的值存储到 `%rdi` 寄存器中，从而准备好 `gets` 函数的第一个参数。

</div>

<div>

![rop-1](/04-Arch-ISA-and-Logic/rop-1.png){.mx-auto}

</div>
</div>

---

# ROP 攻击

return-oriented programming attack

<div grid="~ cols-2 gap-12">
<div>

输入：

```c
01234567890123456789012\0 // 24 个字符
```

此时，发生了缓冲区溢出，但是没造成严重后果。

尤其注意，`gets` 函数会在缓冲区末尾自动添加一个空字符 `\0`{.text-sky-5}。

绿色框圈出的预期的安全输入缓冲区范围。

</div>

<div>

![rop-2](/04-Arch-ISA-and-Logic/rop-2.png){.h-80.mx-auto}

</div>
</div>

---

# ROP 攻击

return-oriented programming attack

<div grid="~ cols-2 gap-12">
<div>

输入：

```c
012345678901234567890123\0 // 25 个字符
```

此时，不仅发生了缓冲区溢出，还造成了严重后果：

<div text-sky-5>

因为溢出到了存放返回后下一条指令的（调用者的栈帧内）区域，导致程序 `ret` 后，会跳转到错误的位置执行。

</div>

按照这个思路，继续溢出直至恰好将整个返回地址覆盖，就可以跳转到我们想要执行的代码位置。

</div>

<div>

![rop-3](/04-Arch-ISA-and-Logic/rop-3.png){.h-80.mx-auto}

</div>
</div>

---

# ROP 攻击

return-oriented programming attack

![rop-detail](/04-Arch-ISA-and-Logic/rop-detail.png)

---

# 避免缓冲区溢出攻击

avoid buffer overflow attack

- **使用安全的函数编写程序**：`fgets` `strncpy` `snprintf`，指定每次读取的字节数
- **地址随机化（Address Space Layout Randomization，ASLR）**：随机化程序的内存布局，使得攻击者无法事先确定数据地址
- **限制可执行代码区域**：将可执行代码区域限制在特定的内存区域，使用页表进行限制
- **设置金丝雀值（canary）进行栈破坏检测**：在栈帧中复制一处不可修改的地方的值过来，当程序试图覆盖返回地址时，必然会破坏金丝雀值，从而在返回时可以检测到栈溢出

---

# 地址随机化

address space layout randomization

<div grid="~ cols-2 gap-12">
<div>

1. **随机化栈偏移**：在程序启动时，系统会在栈上分配一个随机大小的空间。从而每次程序执行时，栈的布局都会有所不同。
2. **栈地址的偏移**：由于栈的随机分配，整个程序的栈地址都会发生变化。这种变化使得攻击者难以预测插入代码的起始位置。从而即使插入了恶意代码，也无法准确执行。

</div>

<div>

![aslr](/04-Arch-ISA-and-Logic/aslr.png){.h-90.mx-auto}

</div>
</div>

<!-- main 函数也是函数，会有对应的帧栈 -->

---

# 限制可执行代码区域

restrict the executable code region

给予内存区域一个 **标记**，来标志其内的字节是否可以作为代码执行。

后续章节中会学到，这会通过页表的权限位来实现。

类似的，还会有 **只读** 权限位。

---

# 金丝雀值

canary value


<div grid="~ cols-2 gap-12">
<div>

在栈帧中，除了返回地址外，还会在栈帧的末尾添加一个金丝雀值。

当程序试图覆盖返回地址时，必然会破坏金丝雀值，从而在返回时可以检测到栈溢出。

</div>

<div>

![canary](/04-Arch-ISA-and-Logic/canary.png){.h-80.mx-auto}

</div>
</div>

---

# 金丝雀值

canary value

<div grid="~ cols-2 gap-12">
<div>

```asm{3-5,11}
echo:
    sub $0x18,%rsp
    mov %fs:0x28,%rax
    mov %rax,0x8(%rsp)
    xor %eax,%eax
    mov %rsp,%rdi
    callq 4006e0 <gets>
    mov %rsp,%rdi
    callq 400570 <puts@plt>
    mov 0x8(%rsp),%rax
    xor %fs:0x28,%rax
    je 400768 <echo+0x39>
    callq 400580 <__stack_chk_fail@plt>
    add $0x18,%rsp
    retq
```

</div>

<div>

- 从特定的段寄存器 `%fs` 的偏移地址 `0x28` 加载金丝雀，并将金丝雀值存储到栈中分配的空间中，然后清除中间用过的寄存器。
- 在函数返回前，检查金丝雀值是否被破坏，如果被破坏，则调用 `__stack_chk_fail` 函数终止程序。

</div>
</div>

---
layout: image-right
image: /04-Arch-ISA-and-Logic/isa.png
---

# 什么是 ISA？

Instruction Set Architecture

直译：指令集体系结构

如果非要强行解释... [^1]

- “汇编语言”转换到“机器码”（相当于一个翻译过程）
- CPU 执行机器码的晶体管和逻辑电路的集合

Y86-64：一种精简的 ISA

[^1]: [CPU 指令集（Instruction Set Architecture, ISA） / Zhihu](https://zhuanlan.zhihu.com/p/599864602)

---

# 程序员可见状态

programmer visible state


| 缩写 | 全称 | 描述 | 包括 |
|------|-------|------|------|
| RF   | Register File | 程序寄存器 | `%rax` ~ `%r14` |
| CC   | Condition Code | 条件码 | ZF<span follow>zero</span>, OF<span follow>overflow</span>, SF<span follow>symbol</span> |
| Stat | Status | 程序状态 | - |
| PC   | Program Counter | 程序计数器 | - |
| DMEM | Data Memory | 内存 | - |



<style>
span[follow] {
  @apply text-[0.6rem];
}
</style>

---
layout: image-right
image: /04-Arch-ISA-and-Logic/Y86-Instruction.png
---

# Y86-64 ISA

一个 X86-64 的子集

```md {all|1|2|3|4|5|6|7|8|9|10|11|12|13|all}
* halt # 停机
* nop # 空操作，可以用于对齐字节
* cmovXX rA, rB # 如果条件码满足，则将寄存器 A 的值移动到寄存器 B
* rrmovq rA, rB # 将寄存器 A 的值移动到寄存器 B
* irmovq V, rB # 将立即数 V 移动到寄存器 B
* rmmovq rA, D(rB) # 将寄存器 A 的值移动到内存地址 rB + D
* mrmovq D(rB), rA # 将内存地址 rB + D 的值移动到寄存器 A
* OPq rA, rB # 将寄存器 A 和寄存器 B 的值进行运算，结果存入寄存器 B
* jXX Dest # 如果条件码满足，跳转到 Dest
* call Dest # 跳转到 Dest，同时将下一条指令的地址压入栈
* ret # 从栈中弹出地址，跳转到该地址
* pushq rA # 将寄存器A的值压入栈
* popq rA # 从栈中弹出值，存入寄存器A
```

<div text-sm>

* 第一个字节为 **代码** ，其高 4 位为操作类型，低 4 位为操作类型（fn）的具体操作（或 0）
* F：0xF，为 Y86-64 中“不存在的寄存器”
* 所有数值（立即数、内存地址）均以 hex 表示，为 8 字节

</div>

---
layout: image-right
image: /04-Arch-ISA-and-Logic/Y86-Instruction.png
---

# Y86-64 ISA

一个 X86-64 的子集

```md
* halt # 停机
* nop # 空操作，可以用于对齐字节
* cmovXX rA, rB # 如果条件码满足，则将寄存器 A 的值移动到寄存器 B
* rrmovq rA, rB # 将寄存器 A 的值移动到寄存器 B
* irmovq V, rB # 将立即数 V 移动到寄存器 B
* rmmovq rA, D(rB) # 将寄存器 A 的值移动到内存地址 rB + D
* mrmovq D(rB), rA # 将内存地址 rB + D 的值移动到寄存器 A
* OPq rA, rB # 将寄存器 A 和寄存器 B 的值进行运算，结果存入寄存器 B
* jXX Dest # 如果条件码满足，跳转到 Dest
* call Dest # 跳转到 Dest，同时将下一条指令的地址压入栈
* ret # 从栈中弹出地址，跳转到该地址
* pushq rA # 将寄存器A的值压入栈
* popq rA # 从栈中弹出值，存入寄存器A
```

<div class="text-[0.8rem]" grid="~ cols-2 gap-4">

<div>
  
* i(immediate)：立即数
* r(register)：寄存器
* m(memory)：内存地址{.text-sky-4}
  
</div>
<div>
  
* d(displacement)：偏移量
* dest(destination)：目标地址
* v(value)：数值
  
</div>
</div>


---

# Fn

<div grid="~ cols-3 gap-12">
<div>

### Jmp Fn
![Jmp Fn](/04-Arch-ISA-and-Logic/fn_jmp.png){.h-90}

</div>

<div>

### Mov Fn
![Mov Fn](/04-Arch-ISA-and-Logic/fn_mov.png){.h-90}

</div>
<div>

### OP Fn
![OP Fn](/04-Arch-ISA-and-Logic/fn_op.png){.h-90}

</div>
</div>


---
layout: image-right
image: /04-Arch-ISA-and-Logic/register.png
---

# 寄存器

Register

```markdown{all|1-4|5-6|7-8|9-15|16|all|8,7,3,2|all|4,6,13-16}
* 0x0 %rax 
* 0x1 %rcx
* 0x2 %rdx
* 0x3 %rbx
* 0x4 %rsp
* 0x5 %rbp
* 0x6 %rsi
* 0x7 %rdi
* 0x8 %r8
* 0x9 %r9
* 0xA %r10
* 0xB %r11
* 0xC %r12
* 0xD %r13
* 0xE %r14
* 0xF F / No Register
```

<div class="text-[0.7rem]" flex="~ gap-4">
<div shrink-0>

* a,c,d,b + x <span text-gray-400># AcFun 倒（D）了，然后 Bilibili 兴起了</span>
* 栈指针（包括栈顶%rsp和栈底%rbp）
* 前两个参数指针
* 按序的 %r8 ~ %r14

</div>

![acdb](/04-Arch-ISA-and-Logic/acdb.jpg)

</div>


---

# 汇编代码翻译

translate assembly code to machine code

以下习题节选自书 P248，练习题 4.1 / 4.2

<div v-click-hide>

### Quiz

|     |     |
| --- | --- |
| 0x200 | a0 6f 80 0c 02 00 00 00 00 00 00 00 30 f3 0a 00 00 00 00 00 00 00 90 |
| loop | rmmovq %rcx, -3(%rbx) |

对于第一条翻译为汇编代码，第二条翻译为机器码

<br/>

</div>

<div v-after>

### Step 1
|     |     |
| --- | --- |
| 0x200 | <kbd>a0</kbd> <kbd>6f</kbd> \| <kbd>80</kbd> <kbd>0c 02 00 00 00 00 00 00</kbd> \| <kbd>00</kbd> \| <kbd>30</kbd> <kbd>f</kbd><kbd>3</kbd> <kbd>0a 00 00 00 00 00 00 00</kbd> \| <kbd>90</kbd>|
| loop | rmmovq, rcx, rbx, -3 |


</div>

<br>

<div v-click>

### Step 2

<div  grid="~ cols-2 gap-4">
<div>

```bash
0x200:
  pushq %rbp
  call 0x20c
  halt
0x20c:
  irmovq $10 %rbx
  ret
```

</div>
<div>

<kbd>40</kbd> <kbd>1</kbd><kbd>3</kbd> <kbd>ff ff ff fd</kbd>

</div>
</div>
</div>

<style>
.slidev-vclick-hidden {
  @apply hidden;
}
</style>



<!--
地址、立即数都是小端法
-->

---

# Y86-64 vs x86-64, CISC vs RISC

Complex Instruction Set Computer & Reduced Instruction Set Computer


<div grid="~ cols-2 gap-4">
  <div>

* Y86-64 是 X86-64 的子集
* X86-64 更复杂，但是更强大
* Y86-64 更简单，复杂指令由简单指令组合而成
  
如 Y86-64 的算数指令（`OPq`）只能操作寄存器，而 X86-64 可以操作内存

> 所以 Y86-64 需要额外的指令（`mrmovq`、`rmmovq`）来先加载内存中的值到寄存器，再进行运算

  </div>
<div>

* CISC：复杂指令集计算机
* RISC：精简指令集计算机
* 设计趋势是融合的
  
![CISC v.s. RISC](/04-Arch-ISA-and-Logic/cisc_vs_risc.jpg){.w-70}

</div>
</div>

---

# Y86-64 状态

status

| 值 | 名字 | 含义 | 全称 |
|----|------|------|------|
| 1  | `AOK`  | 正常操作 | All OK |
| 2  | `HLT`  | 遇到器执行`halt`指令遇到非法地址 | Halt |
| 3  | `ADR`  | 遇到非法地址，如向非法地址读/写 | Address Error |
| 4  | `INS`  | 遇到非法指令，如遇到一个 `ff` | Invalid Instruction |

除非状态值是 `AOK`，否则程序会停止执行。



---
layout: image-right
image: /04-Arch-ISA-and-Logic/Y86_stack.png
---

# Y86-64 栈

stack

`Pushq rA F / 0xA0 rA F`

压栈指令
- 将 `%rsp` 减去8
- 将字从 `rA` 存储到 `%rsp` 的内存中

<br>

***

`Popq rA F / 0xB0 rA F`

弹栈指令
- 将字从 `%rsp` 的内存中取出
- 将 `%rsp` 加上8
- 将字存储到 `rA` 中

<!-- 


<div text-sm>

根据书 P334 4.7、4.8，如果压栈 / 弹栈的时候的寄存器恰为 `%rsp`，则不会改变 `%rsp` 的值。

</div>

 -->


---

# Y86-64 程序调用

`call` & `ret`

`Call Dest / 0x80 Dest`

调用指令
- 将下一条指令的地址 `pushq` 到栈上（`%rsp` 减 8、地址存入栈中）
- 从目标处开始执行指令

<br/>

***

`Ret / 0x90`

返回指令
- 从栈上 `popq` 出地址，用作下一条指令的地址（`%rsp` 加 8、地址从栈中取出，存入 `%rip`）



---

# Y86-64 终止与对齐

`Halt / 0x00`

终止指令
- 停止执行
- 停止模拟器
- 在遇到初始化为 0 的内存地址时，也会终止
- 记忆：没有事情做了 ➡️ 停止

<br/>

`Nop / 0x10`

空操作
- 什么都不做（但是 PC <span text-sm> Program Counter </span> + 1），可以用于对齐字节
- 记忆：扣 1 真的没有用

---

# 逻辑设计和硬件控制语言 HCL

hardware control language

* 计算机底层是 0（低电压） 和 1（高电压）的世界
* HCL（硬件 **控制** 语言）是一种硬件 **描述** 语言（HDL），用于描述硬件的逻辑电路
* HCL 是 HDL 的子集

<br>

<div grid="~ cols-3 gap-4"  mt-2>

<div>

#### 与门 And

![And](/04-Arch-ISA-and-Logic/and.png){.h-30}

```c
out = a&&b
```

</div>

<div>

#### 或门 Or

![Or](/04-Arch-ISA-and-Logic/or.png){.h-30}

```c
out = a||b
```

</div>

<div>

#### 非门 Not

![Not](/04-Arch-ISA-and-Logic/not.png){.h-30}

```c
out = !a
```

</div>

</div>

记忆：方形的更严格→与；圆形的更宽松→或



---

# 组合电路 / 高级逻辑设计

中杯：bit level / bool

<div grid="~ cols-2 gap-12"  mt-2>

<div>

```c
bool eq = (a && b) || (!a && !b);
```

![bit_eq](/04-Arch-ISA-and-Logic/bit_eq.png){.h-50.mx-auto}

- 组合电路是 `响应式` 的：在输入改变时，输出经过一个很短的时间会立即改变
- 没有短路求值特性：`a && b` 不会在 `a` 为 `false` 时就不计算 `b`

</div>

<div>

```c
bool out = (s && a) || (!s && b);
```

![bit_mux](/04-Arch-ISA-and-Logic/bit_mux.png){.h-50.mx-auto}

- Mux：Multiplexer / 多路复用器，用一个 `s` 信号来选择 `a` 或 `b`

</div>

</div>




---

# 组合电路 / 高级逻辑设计

大杯：word level / word

<div grid="~ cols-2 gap-12">
<div>




```c
bool Eq = (A == B)

```

![word_eq](/04-Arch-ISA-and-Logic/word_eq.png){.h-60}

</div>

<div>

```c
int Out = [
  s : A; # select: expr
  1 : B;
];

```

![word_mux](/04-Arch-ISA-and-Logic/word_mux.png){.h-60}

</div>
</div>


---

# 组合电路 / 高级逻辑设计

超大杯：相信你已经学会了基本的 ~~红石~~ 逻辑门电路，那就试试 ~~纯红石~~ 神经网络 [^1] 吧！

![组合电路](/04-Arch-ISA-and-Logic/redstone.png){.h-80}

[^1]: [【Minecraft】世界首个纯红石神经网络！真正的红石人工智能(中文/English)(4K)/ Bilibili](https://www.bilibili.com/video/BV1yv4y1u7ZX/)



---

# 组合电路 / 集合关系

是的，我们居然还能在这里温习《离散数学基础》

```c
int Out4 = [
  bool s1 = code in {2, 3}; # 10, 11
  bool s2 = code in {1, 3}; # 01, 11
];

```

![sets](/04-Arch-ISA-and-Logic/sets.png){.h-40}

<!-- 我们可以用集合关系来表示电路的逻辑 -->


---

# 组合电路 / 算数逻辑单元 ALU
Arithmetic Logic Unit

![ALU](/04-Arch-ISA-and-Logic/alu.png)

<div grid="~ cols-2 gap-4"  mt-2>

<div>

- 组合逻辑
- 持续响应输入
- 控制信号选择计算的功能
</div>
<div>

- 对应于 Y86-64 中的 4 个算术 / 逻辑操作
- 计算条件码的值
- 注意 `Sub` 是被减的数在后面，即输入 B 减去输入 A，等于 `subq A, B`
</div>
</div>




---

# 存储器和时钟

响了十二秒的电话我没有接，只想要在烟花下闭着眼~

组合电路：不存储任何信息，只是一个 `输入` 到 `输出` 的映射（有一定的延迟）

时序电路：有 **状态** ，并基于此进行计算


---

# 时钟寄存器 / 寄存器 / 硬件寄存器

register

存储单个位或者字

- 以时钟信号控制寄存器加载输入值
- 直接将它的输入和输出线连接到电路的其他部分


<div grid="~ cols-2 gap-12" mt-8>
<div>

![clock-1](/04-Arch-ISA-and-Logic/clock-1.png){.h-45.mx-auto}

</div>

<div>

![clock-2](/04-Arch-ISA-and-Logic/clock-2.png){.h-45.mx-auto}

</div>
</div>

在 Clock 信号的上升沿，寄存器将输入的值采样并加载到输出端，其他时间输出端保持不变

---

# 随机访问存储器 / 内存

memory

<div grid="~ cols-2 gap-12">
<div>

以 **地址** 选择读写

包括：

- 虚拟内存系统，寻址范围很大
- 寄存器文件 / 程序寄存器，个数有限，在 Y86-64 中为 15 个程序寄存器（`%rax` ~ `%r14`）

可以在一个周期内读取和 / 或写入多个字词

</div>

<div>

![memory](/04-Arch-ISA-and-Logic/memory.png){.h-50.mx-auto}

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
