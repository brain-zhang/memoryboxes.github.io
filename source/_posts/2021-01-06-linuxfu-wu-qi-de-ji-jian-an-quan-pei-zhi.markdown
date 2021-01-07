---
layout: post
title: "linux服务器极简安全配置"
date: 2021-01-06 17:33:38 +0800
comments: true
categories: tools
---

网络知识了解的越多，就越胆小；也许，这就是江湖吧；

当配置一台新的Linux服务器并上线时，其实就是将Server暴露到了炮火横飞的战场上，任何的大意都会让其万劫不复；但由于永恒的人性的弱点，我们总是在安全和便利之间摇摆；

本文希望能提供一种最简单的办法，帮助我们抵抗大多数的炮火；

<!-- more -->


#### 用户管理

最重要的就是不要用root用户操作，当一台服务器部署初期，为不同用途划分不同用户组以及用户能避免绝大多数悲剧；

1. 增加一个用户组 `develop`

```
groupadd develop
```
2. 增加一个用户`brain`，设置密码，并把他加入到组 `develop`

```
useradd -d /home/brain -s /bin/bash -m brain
passwd brain
usermod -a -G develop brain
```
3. 允许用户登录
```
vim /etc/sudoers
```
找到类似下面的一行，并在后面增加一行

```
root     ALL=(ALL:ALL) ALL
brain    ALL=(ALL) NOPASSWD: ALL
```

上面的NOPASSWD表示，切换sudo的时候，不需要输入密码，这样比较省事。如果出于安全考虑，也可以强制要求输入密码。

```
root    ALL=(ALL:ALL) ALL
brain    ALL=(ALL:ALL) ALL
```

然后，切换到新用户的身份，检查到这一步为止，是否一切正常。

```
su brain
```


#### 防火墙

防火墙为我们抵抗绝大多数的脚本小子的攻击，是最省力，性价比最高的投资，切勿偷懒;

几乎所有的公有云都提供了非常傻瓜化的web 操作界面，来设置防火墙规则，一般情况下这些设置足够了；

设置第一原则是：只开放必要的端口

如果是自己设置防火墙，iptable的使用比较复杂，我们采用最简单的规则链:

......

#### sshd配置

几条最简单的配置，即能避免90%以上的恶意嗅探；

1. 端口

```
vim /etc/ssh/sshd_config

Port 22
->
Port 12222
```
2. DNS


3. Key

首先，确定有SSH公钥（一般是文件~/.ssh/id_rsa.pub），如果没有的话，使用ssh-keygen命令生成一个




#### Fail2Ban

警惕那些不怀好意的撞库者

jail.local

nail.rc

