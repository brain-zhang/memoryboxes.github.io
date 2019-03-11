---
layout: post
title: "比特币的blockchain-2"
date: 2019-01-23 19:05:29 +0800
comments: true
categories: blockchain
---


比特币的发展史上，非常非常早期就出现了一种名为侧链(sideChains)的技术；

这个技术早在2008年比特币代码尚未发布时，就在论坛上有所讨论，后来比特币网络开始运行，各种Geek点子层出不穷，从最初的namecoin(域名币)，到后来的（Counterparty）、万事达币（Mastercoin）和彩色币（ColoredCoin）等附生链；再到后来百链齐开，大家试图在完全不同的链上转移交换资产；以及最近到blockstream的[Liquid](https://blockstream.com/liquid/)，以及基于闪电网络的原子交换(Atomic Swap)，这个技术的发展一直不温不火，但毫无疑问，侧链技术绝对是blockchain技术的重要组成部分。

<!-- more -->

顺便说一句，技术的演化是一个渐进的过程，中间甚至还会有倒退；比特币社区早期提出了非常多的天马行空的点子，但大多过于超前和激进，所以你说投机者也好，先烈也罢，大部分都湮没在历史风尘之中了；但是这些技术的一个重要应用，就是后来人再用几个高大上的名词包装一下，原样推出来继续割韭菜；

比如对比现在的一干稳定币；bitshares表示不服；

比如现在的各种DPOS算法，死去的先烈们纷纷表示生不逢时；

而且一个新技术出来，伴随着大量术语(有时候一个名词用不同语言说出来就感觉是两个技术)，比如各种Smart Contract，智能合约，双向锚定，智能资产，Oracles，预言机，图灵完备，零知识证明，分布式自治组织DAO，Dcententralize Autonomous Oganization，DAPP，hyperledger，DistributedLedger，DistributedNetwork，ERC20，~~~把人忽悠的一愣一愣的；

而且最让人想不通的，你要说某某技术是在比特币基础上搭建的，我们的第一反应就是:`庞氏骗局`；如果他说他的项目是踏着五色云彩，手持先知卷轴，以联盟链为基础，建立在全球的去中心化内容协议之上，采用了区块链与分布式存储技术，要构建一个世界范围内的自由金融体系，已经有XXX,YYY,ZZZ等各大机构支持投资，以及UUU,ZZZ等诺贝尔奖级别的专家背书，我们便会对其顶礼膜拜~~~~

好了，不八卦了；为了避免受骗，只有一个办法，就是这个世界谁都靠不住，只能自己搞明白，让我们看看这个侧链技术究竟是大忽悠还是真本事。

我初次接触到这个技术时，不禁感叹社区的强大，连这么匪夷所思的东东都能想出来，总之可以总结为:

`还有这种操作?`

那么，接下来就从2010年，比特币的早期说起，这个侧链的技术究竟是如果诞生、演化的。

#### BitDNS (第一个侧链概念的诞生)

2010/11/15，有人在bitcointalk.org发贴提出了建立一个类似于比特币的分布式DNS的系统，称之为bitDNS:

https://bitcointalk.org/index.php?topic=1790.0

这个帖子值得一再研究，里面整个一群英荟萃，讨论的内容在数年之后启发扩展出来了无数种山寨币。

讨论的起点是很简单的，就是有人受比特币启发，说要建立一条新的公链bitX，并在其上面发行多种资产，域名、比特币都仅仅是其中的一种资产而已。

一石激起千重浪，大家就一个分布式的DNS系统的实现展开热烈讨论。

讨论的结果是，既然比特币公链已经为我们提供了三种能力：

1. 时间戳——证明事件的时间顺序
2. 加密完整性——证明数据没有被篡改
3. 身份验证——证明数据满足一些基本标准

那么为什么不以比特币的公链为基础锚定物，在其之上扩展出任意的资产呢？

这个想法非同小可，若干年后，除了namecoin，还衍生出来了（Counterparty）、万事达币（Mastercoin）和彩色币（ColoredCoin）等附生链，以及bitshares 这种基础设施，乃至大名鼎鼎的ethereum 的部分思想也可以追溯于此。

BitDNS的想法最终作为namecoin项目实现，让我们看看如果以比特币公链为锚，构造一个分布式域名系统。

#### namecoin

让我们遵循老习惯，先提出问题： 假如我们要建立一个去中心化的DNS系统，应该怎么做呢？

##### 初版方案

众所周知，现下的DNS系统是由ICNAA来把持的，我们日常访问的所有域名记录来源于几个根服务器；乃至于https的证书颁发机构都是中心权威化的；密码极客们讨论建立一个去中心化的DNS系统已经好多年，比特币的出现无疑是一束光。

我们参照比特币的实现，将最小化的DNS信息记录上链，方案很明显，一个人持有私钥，对指定的域名签名，然后存到一条链上，那么就完成了对这个域名的所有权声明。将来如果这个域名需要转让，参照比特币的转账方式，构造scriptSig即可。

至于这条链是如何运行的，完全可以参考比特币，folk一份代码，构造一条完全独立的POW链即可。

DNS的解析、登记、TXT、A记录、CNAME等等所有其他功能，完全可以移交给三方开发商来提供服务，当域名所有者提供签名后，开发商请求namecoin 链进行验证即可。

##### 二版方案

初版方案的设想非常简洁美好，已经完成了这个系统的大部分，但是还有一点小问题要解决一下：

* 传统的域名注册、续签等等都需要付费，初版系统没有经济激励，很容易造成域名抢注和滥用

解决办法也很简单，就是引入一种代币(namecoin)，注册和续签、以及转移，都需要花费namecoin作为手续费；而获取namecoin的手段，则是挖矿。


##### 三版方案

设计至此，已经非常完美了。但是社区成员进一步思考，既然比特币的主链已经提供了足够的算力来保障其安全，我们为什么为了发行另外一项资产，就要另起炉灶开启新的POW竞争呢？

POW算力链，只有一份保障就够了，没有必要开启其他的同样的POW链。

* 那么问题来了，如何用比特币的主链来保障namecoin链的唯一和不可篡改呢？

答案就是将namecoin链的每一个block hash值嵌入到比特币的主链上，这样namecoin就作为一条侧链依附于比特币主链，在比特币全网POW算力的庇护下茁壮成长。

* namecoin的block hash 怎样嵌入比特币主链上呢？

答案是嵌入在比特币挖矿交易的coinbase中；这样比特币矿工可以同时加入到bitcoin和namecoin的网络中，每挖到一个块，可以顺便嵌入namecoin的block header到coinbase里面，顺便获得一些namecoin，这样也保障了namcoin主网的安全。

##### 四版方案

我们把bitcoin blockchain称之为主链，namecoin block chain称之为辅链；

想象当中，两条链的结构是这样的:

![img](https://raw.githubusercontent.com/memoryboxes/memoryboxes.github.io/source/images/20190311/bg1.png)

那么，挖矿的难度应该怎么设计呢？我们要求该父链区块的难度必须符合辅链的难度要求：

> 将辅链区块的hash值内置于父链的Coinbase，其实是利用父链作存在证明。这样就可以实现间接依靠父链的算力来维护辅链安全。一般来说，父链的算力比辅链大，因而满足父链难度要求的区块一定同时满足辅链难度要求，反之则不成立。这样一来，很多本来在父链达不到难度要求的区块，却达到辅链难度要求，矿工广播到辅链网络，在辅链获得收益，何乐而不为。

到这里看起来已经非常好了，但是且慢，还有一个问题，就是这样就限制了辅链block的生成速度，每挖一个主链block，只能顺带挖一个辅链block，是不是有点太死板了呢？要知道，可能将来有些资产应用，会要求更灵活的区块生成间隔时间，这个问题怎么解决呢？


##### 五版方案

辅链除了用prev block 指针组成一条chain，还又引入了另外一个指针： parent block； 这样每几个block可以归附于一个parent block，挂接在主链的同一个block下面；这样就实现了挖一个主链block，附带挖多个辅链block；结构如下:

![img](https://raw.githubusercontent.com/memoryboxes/memoryboxes.github.io/source/images/20190311/bg2.png)

在这张图中，主链的block100只挂接了辅链的blockB100，但是blockB101，blockB102都指向同样的parent block，就是blockB100，这样就实现了只用主链的blockB100，同时挂接辅链的三个区块(blockB100、blockB101、block102)；

一个parent block可以后续有多个block，辅链验证的一个block是否合法的时候，需要三步验证：

1. 首先按照辅链的规则验证此block是否合法
2. 查看它是否属于一个parent block，若有，验证此parent block是否合法
3. 验证此block或者其parent block所挂接的主链block是否合法

嗯哼，完美！


###### 六版方案

世界上不存在完美的方案，很快，我们又迎来了新的挑战： 以主链为锚定，我们想要有多条辅链的时候该怎么办？

答案是merkle结构，就像bitcoin的block用merkle聚合了多笔交易一样，我们再次用merkle聚合多条辅链的parent block header。

最终的设计细节如下:

![img](https://raw.githubusercontent.com/memoryboxes/memoryboxes.github.io/source/images/20190311/bg3.png)


AuxPOW协议对两条链都有一些数据结构方面的规定，对于父链，要求必须在区块的coinbase的scriptSig字段中插入如下格式的44字节数据：

![img](https://cdn.8btc.com/wp-content/uploads/2016/11/Snip20161108_2.png)

对于辅链，对原区块结构改动比较大，在nNonce字段和txn_count之间插入了5个字段，这种区块取名AuxPOW区块。

![img](https://cdn.8btc.com/wp-content/uploads/2016/11/Snip20161108_3.png)


> 混合挖矿要求父链和辅链的算法一致，是否支持混合挖矿是矿池的决定，矿工不知道是否在混合挖矿。矿池如果支持混合挖矿，需要对接所有辅链的节点。

> 将辅链区块hash值内置在父链的Coinbase，意味着矿工在构造父链Coinbase之前，必先构造辅链的AuxPOW 区块并计算hash值。如果只挖一条辅链，情况较为简单，如果同时挖多条辅链，则先对所有辅链在挖区块构造Merkleroot。矿池可以将特定的44字节信息内置于上文Stratum协议中提到的Coinb1中，交给矿工挖矿。对矿工返回的shares重构父链区块和所有辅链区块，并检测难度，如果符合辅链难度要求，则将整个AuxPOW区块广播到辅链。

辅链节点验证AuxPOW区块逻辑过程如下：

1. 依靠父链区块头（parent_block）和区块Hash值（block_hash，本字段其实没必要，因为节点可以自行计算），验证父链区块头是否符合辅链难度要求。
2. 依靠Coinbase交易（coinbase_txn）、其所在的分支（coinbase_branch）以及父链区块头（parent_block），验证Coinbase交易是否真的被包含在父链区块中。
3. 依靠辅链分支（blockchain_branch），以及Coinbase中放Hash值的地方（aux_block_hash），验证辅链区块Hash是否内置于父链区块的Coinbase交易中。

通过以上3点验证，则视为合格的辅链区块。

需要注意的一个字段是主链上的merkle_nonce； 因为一个矿工可能同时挖多条辅链，而每开采主链上一个合法的block，可能会带有数目不定的多条辅链，为了区分每条辅链的`链接位置`，即通过辅链的id确定这条辅链链接的索引号(也称为slot num)，引入了一个nonce，算法如下：

```
unsigned int rand = merkle_nonce;
rand = rand * 1103515245 + 12345;
rand += chain_id;
rand = rand * 1103515245 + 12345;
slot_num = rand % merkle_size
```

##### 以上就是初代侧链的实现技术!


~~~ 填坑中

## 参考资料:

http://www.blockstream.com/sidechains.pdf

https://en.bitcoin.it/wiki/Atomic_swap

https://en.bitcoin.it/wiki/Merged_mining_specification
