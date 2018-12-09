---
layout: post
title: "比特币的交易-3"
date: 2018-12-09 15:46:05 +0800
comments: true
categories: blockchain
styles: data-table
---


## scriptSig与scriptPubKey

继续解析我们上篇文章的交易(`b0a0afb65ac08f453b26fa03a40215be653b6d173510d366321019ab8248ea3b`)

目前为止，我们还没有解析vin中的scriptSig，以及vout中的scriptPubKey；这两个东东才是交易的核心，他们有什么作用呢？

<!-- more -->

scriptSig是一笔UTXO的开锁脚本，scriptPubKey是输出UTXO的加锁脚本，一笔交易就是打开上家的保险箱，将资金转移到下家的保险箱并重新加锁的过程:

* 上家-TransA: id(b0a0afb65ac08f453b26fa03a40215be653b6d173510d366321019ab8248ea3b) -> vout scriptPubkey (转移到保险箱A，并给A上锁)
```
			{
				"value": 0.00010000,
				"n": 0,
				"scriptPubKey": {
					"asm": "OP_DUP OP_HASH160 650d0497e014e60d4680fce6997d405de264f042 OP_EQUALVERIFY OP_CHECKSIG",
					"hex": "76a914650d0497e014e60d4680fce6997d405de264f04288ac",
					"reqSigs": 1,
					"type": "pubkeyhash",
					"addresses": [
						"1ADJqstUMBB5zFquWg19UqZ7Zc6ePCpzLE"
					]
				}
```

* 转移-TransB: id(3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517) -> vin scriptSig (解锁保险箱A，拿出资金)

```
			{
				"txid": "b0a0afb65ac08f453b26fa03a40215be653b6d173510d366321019ab8248ea3b",
				"vout": 0,
				"scriptSig": {
					"asm": "304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0[ALL] 04c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5",
					"hex": "47304402204f1eeeb46dbd896a4d421a14b156ad541afb4062a9076d601e8661c952b32fbf022018f01408dc85d503776946e71d942578ab551029b6bee7d3c30a8ce39f2f7ac0014104c4f00a8aa87f595b60b1e390f17fc64d12c1a1f505354a7eea5f2ee353e427b7fc0ac3f520dfd4946ab28ac5fa3173050f90c6b2d186333e998d7777fdaa52d5"
				},
				"sequence": 4294967295
			}
```

* 下家-TransB: id(3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517) ->vout scriptPubkey (转移到保险箱B，并给B上锁)
```
			{
				"value": 0.00007000,
				"n": 0,
				"scriptPubKey": {
					"asm": "03db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603 OP_CHECKSIG",
					"hex": "2103db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603ac",
					"reqSigs": 1,
					"type": "pubkey",
					"addresses": [
						"1aau2Kgn7xBRWS6gPkYXWiw4cnzyKi7rR"
					]
				}
			}
```

具体怎么理解这两个东东呢？我们还需要一点前置知识。

## 比特币脚本语言系统 scripting language

scriptPubkey以及scriptSig是一种脚本语言。比特币的脚本语言被设计为一种类 Forth 栈语言。拥有成无状态和非图灵完备的性质。无状态性保证了一旦一个交易被区块打包，这个交易就是可用的。图灵非完备性（具体来说，缺少循环和goto 语句）使得比特币的脚本语言更加不灵活和更可预测，从而大大简化了安全模型。

如果大家之前做过汇编开发的话，就会发现这跟汇编的指令码是非常相似的东东。

先来一个在线解析工具:

https://bitcoin-script-debugger.visvirial.com/

再来一个视频讲解：

https://www.youtube.com/watch?v=4qz7XehSBCc

比较简单的教程:

https://davidederosa.com/basic-blockchain-programming/bitcoin-script-language-part-one/

* 额，我知道大部分人跟我一样懒得去翻阅上面这些资料，所以我们简单传送一下：


### 一个最小脚本集

现在想象我们有一台非常简单的计算器，它的CPU只有一个16位的寄存器，以及非常小的内存(1KB)；我们需要设计一种语言，实现一些最简单的计算，比如：

```
x = 0x23
x += 0x4b
x *= 0x1e
```

然后转换为类似汇编语言的比较简单的操作码形式, 我们需要以下指令集：


opcode | encoding | 操作码| 操作数(V值) | explained
---|---|---|---|---
SET(V) | `ab` V | `0xab` | 16bits(0x23) | 将V(0x23)载入到寄存器中
ADD(V) | `ac` V | `0xac` | 16bits(0x4b) | 寄存器值+0x4b; `0x23 + 0x4b = 0x6e`
MUL(V) | `ad` V | `0xad` | 16bits(0x1e) | 寄存器值*0x1e; `0x6e * 0x1e = 0x0ce4`


在上面这个表格中，我们定义了三种最简单的操作码：`0xab, 0xac, 0xad`，跟在这三个操作码后面的2个字节就是操作数；将上面的计算步骤用代码表示如下(小端排序):

```
ab 23 00 ac 4b 00 ad 1e 00
```

我们可以实现一个最简单的脚本逻辑，顺序parse这段代码，并转换为相应的操作码，然后进行运算；

我们实现了一个非常迷你的脚本集。


### 栈设计

上面的操作只涉及到了寄存器，但是现实情况中，我们通常要做多个计算步骤，并将临时变量存到内存中，另外会把复杂的程序组织为一个个函数；这种时候，最常见的内存组织方法是什么呢？

没错，就是我们最常用的数据结构：栈(STACK)。

比如下面这个函数:

```
int foo() {

    /* 1 */

    /* 2 */
    uint8_t a = 0x12;
    uint16_t b = 0xa4;
    uint32_t c = 0x2a5e7;

    /* 3 */
    uint32_t d = a + b + c;

    return d;

    /* 4 */
}
```
1. 第一步函数刚刚跳转执行，栈初始化为空。[]
2. 第二步，三个变量`a,b,c`压入栈中(PUSH STACK)
```
[12]
[12, a4 00]
[12, a4 00, e7 a5 02 00]
```
3. 结合我们上面的操作码，计算`a,b,c`的和，并将结果压栈
```
[12, a4 00, e7 a5 02 00, 9d a6 02 00]
```
4. 返回结果，并将栈元素弹出(POP STACK)，恢复到初始状态。
```
[12, a4 00, e7 a5 02 00]
[12, a4 00]
[12]
[]
```

### Script Language

机器码设计了指令的表示方法，栈设计规定了数据的存储方法；将机器码与栈设计结合起来，就是Bitcoin Script Language。它有两个明显的特点：

* 脚本没有循环:这意味着脚本不能无限运行
* 脚本的内存访问是基于栈的:这意味着脚本中不存在命名变量这种东西，所有的操作码和操作数都表示为栈上的运算；通常，推入的栈项将成为后续操作码的操作数。在脚本的末尾，最上面的堆栈项是返回值。

举个最简单的例子，bitcoin script language支持下面两个操作码：

#### 压栈操作码

opcode | encoding | explained
---|---|---|---
OP_0 | 0x00 | 将0x00压入栈中
OP_1 -- OP_16 | 0x51 -- 0x60 | 将0x01 -- 0x10 压入栈中

> PS: OP_0, OP_1还代表着布尔值False,True


然后下面一段示例脚本代码：

```
0x54 0x57 0x00 0x60
```
或者直接翻译为:

```
OP_4 OP_7 OP_0 OP_16
```

作用就是将四个值依次压栈，栈状态可以表示为:

```
[]
[0x04]
[0x04, 0x07]
[0x04, 0x07, 0x00]
[0x04, 0x07, 0x00, 0x10]
```

此时栈顶元素值为0x10，前面我们说了，栈顶元素即返回值，所以这个脚本的返回值为0x10。当然，这个脚本现在就是将四个值压栈，并没有什么实际作用。


#### PUSHDATA操作码

简单的压栈操作码只能压入1个字节的数据，如果我们想以此压入多个字节的数据，需要用到 `PUSH DATA`操作码。


opcode | encoding | L (length) | D (data)
---|---|---|---
OP_PUSHDATA1 | `0x4c` L D | 8bits | L bytes
OP_PUSHDATA2 | `0x4d` L D | 16bits| L bytes
OP_PUSHDATA3 | `0x4e` L D | 32bits| L bytes


* L 代表需要压入的字节长度，它可以有8bits, 16bits，或者32bits，这三个操作码可以最大压入2^8-1=255字节、2^16-1=65535字节、2^32字节
* D 代表实际的数据

举个例子:

```
4c 14 11 06 03 55 04 8a
0c 70 3e 63 2e 31 26 30
24 06 6c 95 20 30
```

前面的`0x4c`代表是`OP_PUSHDATA1`操作符，后面的`0x14`代表压入20个字节，然后后面跟着20字节的数据

此时栈状态可以表示为:

```
[11 06 03 55 04 8a 0c 70
 3e 63 2e 31 26 30 24 06
 6c 95 20 30]
```

~~ 待续
