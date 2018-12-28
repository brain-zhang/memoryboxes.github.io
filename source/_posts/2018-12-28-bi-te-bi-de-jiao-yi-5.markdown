---
layout: post
title: "比特币的交易-5"
date: 2018-12-28 21:08:25 +0800
comments: true
categories: blockchain
---

我们还是拿[3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517](http://chainquery.com/bitcoin-api/getrawtransaction/3a295e4d385f4074f6a7bb28f6103b7235cf48f8177b7153b0609161458ac517/1)做例子。


<!-- more -->

## 准备工作


#### 私钥-公钥

在[前面的文章](https://happy123.me/blog/2018/11/02/bi-te-bi-de-hdqian-bao-yan-hua-2/)中，我们已经算出来私钥的WIF表示:

```
5KUN8s42BCTkQVMTy3oFfqeXE8awVskbDi6XbDMpRnFvHJW9fgk
```

以及公钥:

```
0489077434373547985693783396961781741114890330080946587550950125758215996319671114001858762817543140175961139571810325965930451644331549950109688554928624341
```

#### 交易body

这笔交易有1个vin，1个vout；然后再把我们之前的结构分析图拿来，看看具体需要哪些参数传入:

![img](https://raw.githubusercontent.com/memoryboxes/memoryboxes.github.io/source/images/20181203/bg3.jpg)


#### 需要手工构造input

1. 指定上一笔vout的txid，是已知参数(outputTransactionHash):`b0a0afb65ac08f453b26fa03a40215be653b6d173510d366321019ab8248ea3b`
2. 指定上一笔vout的index，是已知参数(sourceIndex):`00000000`
3. 构造scriptSig，即对这个UTXO签名。我们需要用私钥签名，这个是难点，我们后面来计算

#### 需要手工构造output

1. 设置矿工费用，从而计算输出值
2. 构造scriptPubKey

#### 最后组合成为一笔交易

1. 增加version字段：`01000000`
2. 增加inputCount字段: `01`
3. 增加outputCount字段: `01`
4. 增加block lock time字段: `00000000`


#### 然后我们实现一个函数，将这些变量组合，最后得到原始交易值(对应bitcoin-cli的createrawTransa)

```
# Makes a transaction from the inputs
# outputs is a list of [redeemptionSatoshis, outputScript]
def makeRawTransaction(outputTransactionHash, sourceIndex, scriptSig, outputs):
    def makeOutput(data):
        redemptionSatoshis, outputScript = data
        return (struct.pack("<Q", redemptionSatoshis).encode('hex') +
        '%02x'.format(len(outputScript.decode('hex'))) + outputScript)
    formattedOutputs = ''.join(map(makeOutput, outputs))
    return (
        "01000000" + # 4 bytes version
        "01" + # varint for number of inputs
        outputTransactionHash.decode('hex')[::-1].encode('hex') + # reverse outputTransactionHash
        struct.pack('<L', sourceIndex).encode('hex') +
        '%02x'.format(len(scriptSig.decode('hex'))) + scriptSig +
        "ffffffff" + # sequence
        "%02x".format(len(outputs)) + # number of outputs
        formattedOutputs +
        "00000000" # lockTime
        )
```

#### outputs构造

上面这个函数中，我们发现需要我们计算的参数只有一个，就是outputs。outputs是包含多个output的数组。在这个例子中，我们打算只构造一个output。结合我们之前的文章，就是构造一个bitcoin scriptPubKey，设置一把新锁。

这个scriptPubkey是这样子的:

```
<pubkey>  OP_CHECKSIG
```

PubKeyHash其实就是收币的地址，其它操作符都是现成的。


#### 小结

在构造一笔完整的交易之前，我们需要手工做两件事情：

1. 构造一个output输出
2. 对vin中的UTXO签名，构造scriptSig

## 如何构造一笔output

一笔output的构造是简单的，所有东西都是现成的，而且这笔交易是个P2PK交易，输出非常简化，我们仅仅需要构造`<pubkey>  OP_CHECKSIG`即可:

```
def makeOutput(value,  index, pubkey):
    OP_CHECKSIG =  'ac'
    value = "{:0<16x}".format(int(struct.pack('<I', int(value)).hex(), 16))
    index = "{:02x}".format(int(index))
    pubkey = pubkey
    pubkey_length = "{:02x}".format(len(pubkey)/2)
    return value + index = pubkey_length + pubkey + OP_CHECKSIG
    

> print(makeOutput(7000, 0, '2103db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603ac'))
> 581b000000000000232103db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603ac
> outputs = ['581b000000000000232103db3c3977c5165058bf38c46f72d32f4e872112dbafc13083a948676165cd1603ac']
    
```

## 如何对一笔交易签名(scriptSig)


在构造一笔交易的过程中，签署交易是一个非常麻烦的过程。其基本思想是使用ECDSA椭圆曲线算法和私钥生成交易的数字签名，但细节比较复杂。签名过程通过10个步骤描述。下面的缩略图说明了详细的流程。

![img](https://en.bitcoin.it/w/images/en/7/70/Bitcoin_OpCheckSig_InDetail.png)

这张图出自于[这里](http://www.righto.com/2014/02/bitcoins-hard-way-using-raw-bitcoin.html)，里面的TX ID是不同的，但基本步骤一样。



准备工作: 首先要验证上一笔交易，即`b0a0afb65ac08f453b26fa03a40215be653b6d173510d366321019ab8248ea3b`的有效性。即对我们上一篇文章的bitcoin script系统验证交易的vin, vout 有效性。



```

def makeSignedTransaction(privateKey, outputTransactionHash, sourceIndex, scriptPubKey, outputs):
    myTxn_forSig = (makeRawTransaction(outputTransactionHash, sourceIndex, scriptPubKey, outputs)
         + "01000000") # hash code

    s256 = hashlib.sha256(hashlib.sha256(myTxn_forSig.decode('hex')).digest()).digest()
    sk = ecdsa.SigningKey.from_string(privateKey.decode('hex'), curve=ecdsa.SECP256k1)
    sig = sk.sign_digest(s256, sigencode=ecdsa.util.sigencode_der) + '\01' # 01 is hashtype
    pubKey = keyUtils.privateKeyToPublicKey(privateKey)
    scriptSig = utils.varstr(sig).encode('hex') + utils.varstr(pubKey.decode('hex')).encode('hex')
    signed_txn = makeRawTransaction(outputTransactionHash, sourceIndex, scriptSig, outputs)
    verifyTxnSignature(signed_txn)
    return signed_txn
```
