---
layout: post
title: "Cisco 3560X config cheat"
date: 2016-07-28 10:02:06 +0800
comments: true
categories: cisco
---
工作需要，学习了Cisco的路由器配置，记一下:

* 查看所有信息

```
    show run
```

* 查看span

```
    show span
```

* 为某个vlan id建立spanning-tree

```
    spanning-tree vlan 15
```

* 取消某个vlan id的spanning-tree

```
    no spanning-tree vlan 15
```

* 将某个端口加入vlan中

```
    sh run init gi 0/39
    config t
    switchport access vlan 14
```

* 保存配置

```
    do wr
    copy running-config startup-config
```

