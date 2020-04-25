---
layout: post
title: "十行代码挑战世界金融体系"
date: 2020-04-23 15:47:39 +0800
comments: true
categories: blockchain
---
这个有点标题党了，但实话说许多"高科技"项目也是这种浮夸的宣传手段，且听我慢慢道来；

最近央行将推出数字货币（DCEP）的消息沸沸扬扬，在没有实际用过之前，我无意对其做过多揣测；

不过这个消息激起了我另一方面的兴趣，就是写一写那些在以太坊上面发行的各种山寨Token；

众所周知，自从Ethereum的ERC20、ERC223、ERC777等Token合约标准诞生以来，在Ethereum上面发行一种货币的成本低的令人发指，我测算，按照现在的ETH汇率，大概10块人民币就能让你发行一个具有发行、转账、增发、销毁等基本功能的电子货币，如果导入OpenZeppelin程序库，在部署合约的时候多出100块钱左右，就可以拥有一个具有融资上限、拍卖、行权计划和其他更复杂的功能的货币。

伟大的先知Andreas M. Antonopoulos 曾经在2014年加拿大关于比特币的听证会上表示，未来的货币发行市场可能会超出所有人的想象，一个十几岁的屁大小子，用10行代码足以创造最灵活最有信用的货币；借助区块链的技术，一个幼儿园的童星创造的货币，可能比历史上最有权力的君王创造的货币用户更多；

虽然比特币发明以来，把它的代码Folk一份，修改两个参数就出来"颠覆世界"的山寨币已经数不胜数，但真正把"造币"这件事情变成无门槛，像吃棒棒糖一样容易的，还是得说以太坊的ERC20的横空出世；

那么，就先让我们体验一下，如何10行代码创造我们自己的棒棒糖币吧~~~

<!-- more -->

### 前置技能

虽然夸张的宣传是只需要十行代码，但是我们得懂一些前置技能:

1. 会翻墙
2. 了解[Ethereum](https://ethereum.org/)的基本原理，最好能把白皮书读明白
3. 学会[solidity语言](https://github.com/ethereum/solidity/)
4. 搞明白[Truffle开发环境的使用](trufflesuite.com/)
5. 会用Nodejs
6. 会用Npm安装包，因为相关代码迭代速度很快，有时候需要你自己解决一些依赖问题
7. 会一些基本的Linux命令

好啦，相信老码农对于以上小门槛根本不屑一顾；

我们假设你满足了上面的前置条件，在一台能翻墙的Linux机器上部署了Nodejs, Geth, Truffle，让我们开干吧；

### 初版

1. 首先我们要完成Truffle的搭建，与我们本地运行的Geth联动，保证你的地址里面有一点ETH能支付Gas费用，这部分操作可以参考官方文档

2. 然后我们用Truffle命令建立一个简单的模板项目

```
$ mkdir BangToken
$ cd BangToken
$ truffle init 
```

3.  开始编辑我们的棒棒糖Token合约

```
$ vim contracts/BangToken.sol

pragma solidity ^0.5.0;
contract BangToken {
    mapping (address => uint256) public balanceOf;
    constructor(uint256 initialSupply) public {
        balanceOf[msg.sender] = initialSupply;              
    }
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);           
        require(balanceOf[_to] + _value >= balanceOf[_to]); 
        balanceOf[msg.sender] -= _value;                    
        balanceOf[_to] += _value;                  
    }
}
```

4. 编写一个部署脚本

```
$ vim migrations/2_deploy_contact.js

var BangToken = artifacts.require("BangToken");
module.exports = function(deployer) {
  deployer.deploy(BangToken);
};
```

5. 编译部署上链

```
$ truffle migrate
```

大功告成，在付出大概0.001ETH的Gas费用之后，你的私人货币就发行成功了，此时你有两项权力：

* 可以在部署的时候指定货币的总体供应量
* 可以执行央行的角色，把货币分发给其他人；至于分发的方式，就看你的心情了
    - 可以像以太坊众筹一样，为某个时间点的所有比特币持有者做个快照，然后按照比特币的持有量给所有持有人发币
    - 可以搞宣传诈骗，引那些不明真相的群众花钱来买你成本只有0.001ETH的棒棒糖币
    - 纯粹为了玩，发行1000万亿货币随机分发给所有以太坊玩家


这个合虽然简单，但是已经完成了货币的基本功能：贮存和转移，而且是一个全球通用的，不需要任何组织背书，完全依赖于以太坊的数学体系运转的电子货币；

不要小看这10行代码哦，在所谓的“区块链技术”纷纷攘攘的日子里，很多所谓的金融创新就是靠着这样的代码，大肆圈钱；甚至有个国家，咱就不指明了，发行个啥石油币，本质上一样的套路；


### 第二版

上面的货币虽然简单好用，但是有一些缺陷：

* 初始发行量定了就不能改了，以后不能在增发货币
* 发行出去的货币无法注销
* 初始发行者的权利不能转让
* 无法开展融资等活动
* .....

为了解决这些问题，我们想要一个更高级一点的棒棒糖货币；毕竟，金融就是一件把事情越做越复杂的活儿，这样才好浑水摸鱼嘛^_^；

这么搞下来10行代码肯定不止了，但是程序员最大的特称就是造轮子，早就有人把这些东西封装成现成的库合约了，我们引入一下，代码量反而更少了；

~~~ 填坑中
