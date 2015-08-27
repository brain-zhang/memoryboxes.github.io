---
layout: post
title: "Netcat Command"
date: 2015-08-26 01:07:48 +0000
comments: true
categories: netcat
---

Netcat能做到的事情太多了，但和tcpdump一个流派，参数多的令人发指，拣常用的几个命令记录一下

## 场景

SERVER A: 192.168.100.100

Server B: 192.168.100.101


### 端口扫描

```
nc -z -v -n 192.168.100.100 21-25
```

- 可以运行在TCP或者UDP模式，默认是TCP，-u参数调整为udp.
- z 参数告诉Netcat使用Zero IO,指的是一旦连接关闭，不进行数据交换
- v 参数指使用冗余选项
- n 参数告诉Netcat 不要使用DNS反向查询IP地址的域名

一旦你发现开放的端口，你可以容易的使用Netcat 连接服务抓取他们的banner。

```
nc -v 192.168.100.100 21
```

#### 消息传送

两台机器间消息传输

SERVER A:

```
nc -l 1234
```

Netcat 命令在1567端口启动了一个tcp 服务器，所有的标准输出和输入会输出到该端口。输出和输入都在此shell中展示。


SERVER B:

```
nc 192.168.100.100 1234
```

不管你在机器B上键入什么都会出现在机器A上


#### 文件传输

大部分时间中，我们都在试图通过网络或者其他工具传输文件。有很多种方法，比如FTP,SCP,SMB等等，但是当你只是需要临时或者一次传输文件，真的值得浪费时间来安装配置一个软件到你的机器上嘛。假设，你想要传一个文件file.txt 从A 到B。A或者B都可以作为服务器或者客户端，以下，让A作为服务器，B为客户端。

SERVER A:

```
nc -l 1234 < file.txt
```

SERVER B:

```
nc -n 192.168.100.100 1234 > file.txt
```

这里我们创建了一个服务器在A上并且重定向Netcat的输入为文件file.txt，那么当任何成功连接到该端口，Netcat会发送file的文件内容。

在客户端我们重定向输出到file.txt，当B连接到A，A发送文件内容，B保存文件内容到file.txt.

没有必要创建文件源作为Server，我们也可以相反的方法使用。像下面的我们发送文件从B到A，但是服务器创建在A上，这次我们仅需要重定向Netcat的输出并且重定向B的输入文件。

B作为Server

SERVER B:

```
nc -l 1234 > file.txt
```

SERVER A:

```
nc 192.168.100.101 1234 < file.txt
```

#### 目录传输

发送一个文件很简单，但是如果我们想要发送多个文件，或者整个目录，一样很简单，只需要使用压缩工具tar，压缩后发送压缩包。

如果你想要通过网络传输一个目录从A到B。

SERVER A:

```
tar -cvf – dir_name | nc -l 1234
```

SERVER B:

```
nc -n 192.168.159.100 1234 | tar -xvf -
```

这里在A服务器上，我们创建一个tar归档包并且通过-在控制台重定向它，然后使用管道，重定向给Netcat，Netcat可以通过网络发送它。

在客户端我们下载该压缩包通过Netcat 管道然后打开文件。

如果想要节省带宽传输压缩包，我们可以使用bzip2或者其他工具压缩。

SERVER A:

```
tar -cvf – dir_name| bzip2 -z | nc -l 1234
```
通过bzip2压缩

SERVER B:

```
nc -n 192.168.100.100 1234 | bzip2 -d |tar -xvf -
```
使用bzip2解压


#### 加密你通过网络发送的数据

如果你担心你在网络上发送数据的安全，你可以在发送你的数据之前用如mcrypt的工具加密。

SERVER A:

```
nc 192.168.100.101 1234 | mcrypt –flush –bare -F -q -d -m ecb > file.txt
```
使用mcrypt工具加密数据。

SERVER B:

```
mcrypt –flush –bare -F -q -m ecb < file.txt | nc -l 1234
```
使用mcrypt工具解密数据。

以上两个命令会提示需要密码，确保两端使用相同的密码。

这里我们是使用mcrypt用来加密，使用其它任意加密工具都可以。