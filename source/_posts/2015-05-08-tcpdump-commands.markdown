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
* 抓 192.168.1.123的包
```
tcpdump -i eth1 host 192.168.1.123 -w /tmp/xxx.cap
```

* 抓192.168.1.123的80端口的包 
```
tcpdump -i eth1 host 192.168.1.123 and port 80 -w /tmp/xxx.cap 
```

* 抓192.168.1.123的icmp的包 
```
tcpdump -i eth1 host 192.168.1.123 and icmp -w /tmp/xxx.cap 
```

* 抓192.168.1.123的80端口和110和25以外的其他端口的包 
```
tcpdump -i eth1 host 192.168.1.123 and ! port 80 and ! port 25 and ! port 110 -w /tmp/xxx.cap 
```

* 抓vlan 1的包 
```
tcpdump -i eth1 port 80 and vlan 1 -w /tmp/xxx.cap 
```

* 抓pppoe的密码 
```
tcpdump -i eth1 pppoes -w /tmp/xxx.cap 
```

* 以100m大小分割保存文件， 超过100m另开一个文件
```
tcpdump -i eth1 -w /tmp/xxx.cap  -C 100m
```
