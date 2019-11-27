---
layout: post
title: "Hello Lightning Network -2"
date: 2019-11-26 17:14:16 +0800
comments: true
categories: blockchain lightning
---

在上一篇文章中我们评论道：闪电网络是一个丰富的生态，将来里面会有各种各样的角色参与其中；目前来看，如何注入足够Inbound Capacity，保持闪电网络有充裕的流动性似乎是个棘手问题；而且不少人攻击这最终会导致比特币运营中心化；


我们这篇文章就来探讨为了解决Inbound Capacity问题，目前lightningLab的一个实验项目：

[loop](https://github.com/lightninglabs/loop)

<!-- more -->

在介绍loop之前，我们还需要复习并深化闪电网络的一些基础知识；即RSMC 和HTLC；这些基础我们曾在[之前的文章中](https://happy123.me/blog/2019/01/06/bi-te-bi-de-jiao-yi-7/)简要介绍过，但只是对网上的资料做了一番整理，人云亦云而已，实在是辜负了闪电网络；

如果把闪电网络比作一支跌宕起伏的乐章，那RSMC和HTLC就是其中最华彩的两个小节，围绕这两个基础技术所衍生的种种细节Tooltips就是其中的伴奏，整个乐章美不胜收。那么，让我们沉下心来仔细体味吧；


## RSMC (Recoverable Sequence Maturity Contract) -- 序列到期可撤销合约RSMC

#### Funding Tx 

让我们再回忆一下链下(off-chain)交易的双方要解决的信任问题：Alice和Bob想要实现公正的，双方都无法作弊的多次交易，他们需要做什么；

首先他们需要向对方展示一下自己有支付的能力，放到现实世界里面做个类比，我们买房摇号时要冻结一笔保证金，这样双方能够放心；

买房者的保证金放到银行账户上，银行来确保开发商不会挪用，但在去中心化的世界里面，如何向对方证明自己的资金实力呢？毕竟，比特币世界里面，可没有中心化的银行；

这需要双方各自将一笔保证金打到一个2-2 多重签名地址当中，这样只要这笔资金不被挪用，就会在这段时间内表明双方的资金实力；

这笔交易被称之为Funding Tx，一般翻译为保证金交易；Funding Tx交易输出的资金需要Alice和Bob两个人的签名同意才能动用；

![img](https://raw.githubusercontent.com/brain-zhang/memoryboxes.github.io/source/images/20191126/bg0-1.jpg)

Funding Tx构造之后，最终资金如何花费需要取得双方的同意，当双方产生分歧时，这笔钱就有可能冻结在这个地址永远无法花费，所以此时还不能广播上链；所以支付通道建立初期， 状况是这样的：

1. Alice和Bob 通过协商，构造了Funding Tx交易；双方都需要将自己的资金打入一个2-2多重签名地址；
2. Funding Tx交易的UTXO需要两人签名才能花费，而此时Alice没有Bob的签名，Bob也没有Alice的签名，只算个口头协议而已
3. 由于担心之后存在的分歧，Funding Tx交易还不能广播到链上

#### Commitment Tx

Funding Tx需要解决三个问题，才能让人放心大胆的广播出去：

1. 需要防止某一方 `损人不利己` -- 永远不同意释放这笔资金，然后这笔钱就一直冻结在这里了；
2. 相互签名之后，需要防止某一方全部提款走人，每一方只能花费自己应得资金；在上图中，要保证当前状态下，Alice和Bob各自只能花费0.5BTC

于是我们产生了一个初步的方案：

![img](https://raw.githubusercontent.com/brain-zhang/memoryboxes.github.io/source/images/20191126/bg0-2.jpg)

Alice构造了C1a交易，这笔交易的Input是Funing Tx的output，但是输出上做了限制，它将资金分配到了两个output:

* 需要Alice2和Bob的签名才能花费 (0.5BTC)
* 直接还给Bob 0.5BTC

这样的交易输出保证Bob不会吃亏，在任何情况下，Alice解约，Bob会立即收到自己的0.5BTC；

但是Alice呢？Alice的0.5BTC怎么办呢？ Alice会对Bob说：我够意思吧，任何情况下，你都能拿回自己的0.5BTC，那么，你如果能对 Alice2&Bob的Output提供签名，那就太好了，这样我们就能达成交易了，这样任何时候都不会让你吃亏；

同样的，Bob也会构造C1b交易，他会说：好吧，Alice，你确实是个诚信的人；你的做法启发了我，为了能随时解约，我也同样构造了一笔交易，无论何时，你都能拿回自己应得的0.5个BTC，而这笔交易也需要你签署一下；

双方的这两笔交易我们称之为 Commitment Tx(承诺交易)；

我们可以想象，Alice和Bob两个人高高兴兴的互相为对方的交易签名，并为合作双方不用依靠别人就达成了如此巧妙而公平的交易而洋洋自得；

此时，无论是Funding TX，还是双方的Commitment Tx，都还没有广播出去; 但是似乎在达成了Commitment Tx之后，可以广播Funding Tx了；

但是且慢!！ 我们建立资金通道的目的是什么？

当然是为了解决资金的链下双向流通问题，目前双方在不依靠第三方公证人的前提下，成功冻结了一笔保证金，可是怎么让这笔保证金流动起来呢？

#### RSMC

聪明的Alice和Bob再次对他们的通道交易做了升级，现在通道里面的交易变成了这样：

![img](https://raw.githubusercontent.com/brain-zhang/memoryboxes.github.io/source/images/20190106/bg1.jpg)


在Alice一方， 又增加了一笔交易， 即RD1a；

RD1a消费了C1a的第一个输出，即 `Alice2 & Bob 0.5btc`， 而RD1a直接输出给Alice，但是这笔交易有一个限制条件，即seq=1000，即如果广播C1a的话，要等1000个block之后，RD1a才会生效；

C1a, C1b两笔交易花费的是同一个输出，故他们两个交易只有一个能进块。若Alice广播C1a，则Bob立即拿到0.5BTC（C1a的第二个输出），而Alice需要等C1a得到1000个确认，才能通过RD1a的输出拿到0.5BTC。另一方，若Bob广播C1b，则Alice立即拿到0.5BTC，Bob等待C1b得到1000个确认，才能通过RD1b拿到0.5BTC。也就是说，单方广播交易终止合约的那一方会延迟拿到币，而另一放则立即拿币。

上述过程以及结构图的描述，就是创建RSMC的全部过程。

#### 交易更新

Alice和Bob各自0.5BTC的余额，此时Alice从Bob处购买了一件商品，价格为0.1BTC，那么余额应该变为Alice 0.4BTC，Bob 0.6BTC。

于是创建新的Commitment Tx，对于Alice来说是C2a 和RD2a，对于Bob来说是C2b和RD2b，过程与上面类似。


![img](https://raw.githubusercontent.com/brain-zhang/memoryboxes.github.io/source/images/20190106/bg2.jpg)

交易更新时的交易结构此时两个状态均是有效的，那么最核心的问题来了，如何才能彻底废弃掉C1a和C1b呢？

RSMC采用了一个非常巧妙的方法，在C1a的第一个输出中，采用了Alice2和Bob的多重签名，Alice将Alice2 的私钥交给Bob，即表示Alice放弃C1a，承认C2a。

![img](https://raw.githubusercontent.com/brain-zhang/memoryboxes.github.io/source/images/20190106/bg3.jpg)

Alice交出Alice2的私钥给Bob，那么Bob就可以修改RD1a的输出给他自己，形成新的交易BR1a。

若Alice破坏合约存在C2a的情况下依然广播出C1a，那么Alice的惩罚就是失去她全部的币。

Alice交出Alice2的私钥，或者对交易BR1a进行签名，两者是等同的，都是对C1a的放弃。反之亦然，Bob交出Bob2的私钥给Alice即意味放弃C1b，而仅能认可C2b。

引入sequence的目的是，阻止后续交易进块（RD1a），给出一个实施惩罚窗口期，当发现对方破坏合约时，可以有1000个块确认的时间去实施惩罚交易，即广播BR1a代替RD1a。若错过1000个块时间窗口，则无法再实施惩罚了（RD1a进块了）。

#### 小结

Alice和Bob两人通过不断的协商和推敲，最终建立了这样一个通道：

1. 两人各自拿出一笔资金来放入这个通道中
2. 每个人都可以随时随地自由解约，同时任何情况下两人的资金都不会有损失
3. 通道的资金可以在两方协商同意的情况下任意分配，而不需要交易广播上链

在达成了Funding Tx、C1a, C2a, RD1a, RD2a 这些交易之后，Alice和Bob两人就可以广播Funding Tx了，这是唯一需要广播的交易，建立通道后，双方所有的交易就是更新Commitment Tx的过程了，这些更新都可以通过链下完成，交易速度理论上只取决于Alice及Bob两方的网络和机器性能，可以很轻易的提升至数千TPS；

## HTLC (Hashed Timelock Contract) --哈希时间锁定合约HTLC

#### 交易中转

RSMC要求交易的双方一定要都缴纳一笔保证金，我每天都跟不同的商家打交道，不能跟每个人都去建立RSMC，存入一笔资金吧。而且通道的建立和关闭都是需要链上广播的，如果要建立多个支付通道，交易费用也不容小觑，这有点本末倒置了吧。

为了解决这个问题，闪电网络又引入了HTLC ( Hashed Timelock Contract )，中文意思是“哈希的带时钟的合约”。这个其实就是限时转账。理解起来也很简单，通过智能合约，双方约定转账方先冻结一笔钱，并提供一个哈希值，如果在一定时间内有人能提出一个字符串，使得它哈希后的值跟已知值匹配（实际上意味着转账方授权了接收方来提现），则这笔钱转给接收方。

推广一步，甲想转账给丙，丙先发给甲一个哈希值。甲可以先跟乙签订一个合同，如果你在一定时间内能告诉我一个暗语，我就给你多少钱。乙于是跑去跟丙签订一个合同，如果你告诉我那个暗语，我就给你多少钱。丙于是告诉乙暗语，拿到乙的钱，乙又从甲拿到钱。最终达到结果是甲转账给丙。这样甲和丙之间似乎构成了一条完整的虚拟的“支付通道”。而乙就做了中转节点。

Alice想要支付0.5BTC给Bob，但她并没有一个渠道来和他进行交易。幸运的是，她和Charlie有一个交易渠道，而Charlie正好和Bob有一个交易渠道。这样Alice就能借助Charlie的交易渠道，通过哈希时间锁定合约（HTLC）来和Bob进行交易了。

![img](https://raw.githubusercontent.com/brain-zhang/memoryboxes.github.io/source/images/20190106/bg4.png)

为了完成这次交易，Alice就会给Bob发短信说：“嘿！我要给你付笔款。”这时Bob自己将收到一个随机数字（R），接着Bob便会回一个被哈希的数字（H）（你可以认为被哈希的数字R是随机数字的一种加密形式）给Alice。

然后Alice的钱包紧接着就会联系Charlie说：“嘿，Charlie。如果你给我生成（H）的未加密值（R），那么我就同意更新我们渠道的支付分配，这样你就可以得到的就会比0.5BTC多一点，我得的比0.5少一点。”

尽管Charlie并不知道R，但他也会同意。之后Charlie便会去找Bob说：“嘿，Bob。如果你给我那个能生成H的未加密的值R，我将同意更新我们渠道的支付分配，这样你就可以得到的会比0.5BTC多一点，我得到的比0.5少一点。”因为R就是从Bob这里生成的，所以他肯定知道。接着他马上将R告诉Charlie，并更新了其渠道的支付分配。然后Charlie将R告诉给了Alice之后也更新他们的渠道，最后交易完成，Alice以脱链的形式付给Bob0.5BTC。

交易中转说起来很简单，但它也要解决一些工程细节问题：

1. 如何构造一笔交易，保证Charlie 只有收到R值的时候才能花费
2. 如果交易由于超时或者网络原因中断，如何回退交易
3. 这笔交易其实是Alice和Bob之间的事情，形成一条交易路径时却要通知所有参与转发交易的节点，如何保护隐私？


让我们用一个更复杂的例子来好好理清这个交易过程吧！

![img](https://raw.githubusercontent.com/brain-zhang/memoryboxes.github.io/source/images/20191126/bg1-0.jpg)

#### HTLC



![img](https://raw.githubusercontent.com/brain-zhang/memoryboxes.github.io/source/images/20191126/bg1-1.png)

#### 最后，让我们再次自我鞭策：饥渴求知，虚怀若愚(Stay Hungry, Stay Foolish)


#### 引用

https://blog.lightning.engineering/posts/2018/05/30/routing.html

https://blog.lightning.engineering/technical/posts/2019/04/15/loop-out-in-depth.html
