---
layout: post
title: "tcpdump commands"
date: 2015-05-08 12:06:22 +0000
comments: true
categories: tcpdump
---

tcpdump 的抓包保存到文件的命令参数是-w xxx.cap

* 抓eth1的包
```
tcpdump -i eth1 -w /tmp/xxx.pcap
```

