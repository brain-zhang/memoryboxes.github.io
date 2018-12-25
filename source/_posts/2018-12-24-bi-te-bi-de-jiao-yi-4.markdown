---
layout: post
title: "比特币的交易-4"
date: 2018-12-24 18:41:36 +0800
comments: true
categories: blockchain
styles: data-table
---
前面的文章中我们分析了一笔标准的Pay to Public Key HASH(P2PKH)交易。看起来其实结构挺简单的，这篇文章我们乘胜追击，看一下矿工们领取系统奖励时，构造的coinbase交易。

<!-- more -->

Coinbase交易规范的叫法是Generation TX，每一个block有且只有一笔Genration TX，该类交易的币是矿工挖矿凭空产生的，所以没有vin。比特币系统所有的币都产自于这里。

我们就以最常见创世块的交易作为示例来分析吧。

[000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f](https://www.blockchain.com/btc/block/000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f)这个创始块中只有一笔交易，就是中本聪手工构造发给自己的币：

[4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b](https://www.blockchain.com/btc/tx/4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b)

#### 区块原始数据

```
00000000   01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
00000010   00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
00000020   00 00 00 00 3B A3 ED FD  7A 7B 12 B2 7A C7 2C 3E   ....;£íýz{.²zÇ,>
00000030   67 76 8F 61 7F C8 1B C3  88 8A 51 32 3A 9F B8 AA   gv.a.È.ÃˆŠQ2:Ÿ¸ª
00000040   4B 1E 5E 4A 29 AB 5F 49  FF FF 00 1D 1D AC 2B 7C   K.^J)«_Iÿÿ...¬+|
00000050   01 01 00 00 00 01 00 00  00 00 00 00 00 00 00 00   ................
00000060   00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
00000070   00 00 00 00 00 00 FF FF  FF FF 4D 04 FF FF 00 1D   ......ÿÿÿÿM.ÿÿ..
00000080   01 04 45 54 68 65 20 54  69 6D 65 73 20 30 33 2F   ..EThe Times 03/
00000090   4A 61 6E 2F 32 30 30 39  20 43 68 61 6E 63 65 6C   Jan/2009 Chancel
000000A0   6C 6F 72 20 6F 6E 20 62  72 69 6E 6B 20 6F 66 20   lor on brink of 
000000B0   73 65 63 6F 6E 64 20 62  61 69 6C 6F 75 74 20 66   second bailout f
000000C0   6F 72 20 62 61 6E 6B 73  FF FF FF FF 01 00 F2 05   or banksÿÿÿÿ..ò.
000000D0   2A 01 00 00 00 43 41 04  67 8A FD B0 FE 55 48 27   *....CA.gŠý°þUH'
000000E0   19 67 F1 A6 71 30 B7 10  5C D6 A8 28 E0 39 09 A6   .gñ¦q0·.\Ö¨(à9.¦
000000F0   79 62 E0 EA 1F 61 DE B6  49 F6 BC 3F 4C EF 38 C4   ybàê.aÞ¶Iö¼?Lï8Ä
00000100   F3 55 04 E5 1E C1 12 DE  5C 38 4D F7 BA 0B 8D 57   óU.å.Á.Þ\8M÷º..W
00000110   8A 4C 70 2B 6B F1 1D 5F  AC 00 00 00 00            ŠLp+kñ._¬....
```

然后我们解析拿我们以前文章的方法来解析一下这笔交易(因为这个区块中只包含了唯一一笔交易，我们顺便解析一下区块构造):

#### block header 部分

1. 首先是version字段:`01000000`
2. 然后是32字节代表上一个block的hash id(因为这笔交易所属block是第一个block，所以人为设置为0): `0000000000000000000000000000000000000000000000000000000000000000`
3. 接着是32字节的merkle root(关于merkle root，我们会在后面的文章中详解): `3BA3EDFD7A7B12B27AC72C3E67768F617FC81BC3888A51323A9FB8AA4B1E5E4A`
4. 4字节的时间戳: `29AB5F49`
5. 接着是目标难度(bits): `FFFF001D` 代表着挖矿难度，具体含义可参考我们之前的[比特币POW难度调节分析](https://happy123.me/blog/2018/02/12/bi-te-bi-pownan-du-diao-jie-fen-xi/)。 
6. nonce: `1DAC2B7C`，同样的挖矿调节参数，我们老是说比特币系统就是在算一个 "毫无意义的随机数字"，没错，这就是毫无意义君。
7. 这个区块包含的总交易数目：`01`


最好来个结构明细表格：


Field |	Size |	Data
------|------|-------
Version	|4 bytes | Little-endian
Previous Block Hash	| 32 bytes |	Big-endian
Merkle Root	| 32 bytes	| Big-endian
Time |	4 bytes |	Little-endian
Bits |	4 bytes |	Little-endian
Nonce|	4 bytes	|   Little-endian

#### 交易部分

1. version: `01000000`
2. input数目 01
3. prev output: `0000000000000000000000000000000000000000000000000000000000000000FFFFFFFF`
4. script length: `4d`
5. coinbase (2-100字节): ```04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73```
6. sequence: FFFFFFFF
7. outputs数目: 01 
8. btc数目: 00F2052A01000000 - 50 BTC
9. pk_script length: 43
10. pk_script:```41 04678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5F  AC ```
    - 0x41代表着后面65个字节入栈
    - ```04678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5F```
    - 0xAC代表着OP_CHECKSIG
    - 整个合起来就是输出脚本为: <Pubkey> <OP_CHECKSIG>
11. lock time: 00000000 

这笔交易跟我们上一篇文章中的TransB构造是一样的，想要花费的话提供签名就OK了。不过这笔交易没有vin，取代的字段是coinbase。这个字段是可以随意调整的，中本聪在这里留存了一句非常有名的话：

```
04678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5F
```

ASCII解码为:  The Times 03/Jan/2009 Chancellor on brink of second bailout for banks

这是2009年1月3日泰晤士报当天的头版文章标题，这是一个时间证明，证明比特币于2009-01-03开始运行，也顺便对传统的金融体系小小嘲讽一下。


## 挖矿

Generation TX交易需要Coinbase字段有两个原因:

1. 但是4字节的nonce字段随机性是不够的，需要引入更长的extra nonce，所以有了长度可以灵活调节(2-100字节)的coinbase字段
2. 作为一个附言留给矿工来发表意见


其实我对于coinbase字段没有啥意见，但是最初的nonce字段只有4个字节，意味着每秒钟只有4G的碰撞空间，很快全网就超出了这个限制，所以Coinbase字段立即就派上用场了。后来slushpool矿池发明了stratum挖矿架构，彻底进入了大算力组团挖矿的时代；这些技术的演化也非常有意思，可以参考这篇文章，讲的非常清晰：

[区块链核心技术演进之路 - 挖矿演进](https://www.8btc.com/article/108894)

其实我觉得nonce字段最初最好设置为32字节，就没这么多事情了。


## 有钱任性的矿工们

矿工们早期是一批劳苦大众死宅，后来优胜劣汰只剩下了寡头；在挖矿故事里，还是有几个有意思的故事说道说道的：

* TXID 相同的交易

一笔交易的id值是SHA(TX HEX)算出来的，因为每一笔交易的vin, vout不同，很难得到相同的txid值。但是在Generation TX里面，输出的数目和地址很有可能都是一样的。所以需要矿工自己构造一个随机的coinbase内容，防止产生相同的TXID值。

早期一位矿工挖出Block后，打包Block时忘记修改Generation Tx coinbase字段的值，币量相同且输出至相同的地址，那么就构造了两个完全一模一样的交易，分别位于两个Block的第一个位置。这个对系统不会产生什么问题，但只要花费其中一笔，另一个也被花费了。相同的Generation Tx相当于覆盖了另一个，白白损失了挖出的币。该交易ID为[e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468](https://blockchain.info/tx/e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468)，第一次出现在[#91722](https://blockchain.info/block/00000000000271a2dc26e7667f8419f2e15416dc6955e5a6c6cdf3f2574dd08e)，第二次出现在[#91880](https://blockchain.info/block/00000000000743f190a18c5577a3c2d2a1f610ae9601ac046a38084ccb7cd721)。


* 忘了接收奖励的矿工

2017-12-30 20:55:00，有个矿工挖到了一个区块之后，竟然丢弃了12.5BTC的奖励！

[区块0000000000000000004b27f9ee7ba33d6f048f684aaeb0eea4befd80f1701126](https://btc.com/0000000000000000004b27f9ee7ba33d6f048f684aaeb0eea4befd80f1701126)


我们不知道这位矿工是用的哪个版本的挖矿软件，但是他们挖到一个区块之后，竟然没有构造地址来领取这笔奖励(价值20W USD)。难道他们真刀真枪上阵之前从来不测试一下吗？或者他们就是有钱任性的真土豪，我只能说:

土豪我们做朋友吧~~~


## coinbase

因为coinbase是矿工们发挥自己灵感的地方，所以最初作为`区块永留存`的手段之一，大家纷纷刻字留念。

有刻字到此一游的，有山盟海誓秀恩爱的，有炫耀生孩子的，有申诉政治诉求的，有吟诗作对，弘扬中国传统文化的；总之这100个字节表示鸭梨很大。

## 刻字服务

当然，coinbase区块链刻字，必须挖矿出块才行；后来有了还有更方便的手段；里面的内容更是洋洋洒洒，可以参考这篇文章：

http://www.righto.com/2014/02/ascii-bernanke-wikileaks-photographs.html

有个网站专门parse了所有区块的文本数据供大家瞻仰：

http://bitcoinstrings.com/

里面记录了许多尘封的历史，篇幅最大的就是扩容大战；完整的将当时社区争论刻进了区块链中，这是人类历史上第一次区块链圆桌访谈录，值得仔细瞻仰。


## 小结

好了，到了这里，我们对于比特币的开采交易，普通交易都理解了；

下一步我们将一步步手工代码构造十六进制数据，然后形成一笔完整的交易去广播；完全吃透一笔交易的来龙去脉；

那么，下次再见。
