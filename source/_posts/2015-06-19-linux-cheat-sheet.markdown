---
layout: post
title: "linux cheat sheet"
date: 2015-06-19 01:43:07 +0000
comments: true
categories: linux
---

收集linux下需要多次google的命令

## 编码问题

* utf16 > utf8

```
iconv -f UTF-16 -t UTF-8 file_name
```

## web开发命令

* curl post 一个json文件

```
curl -H "Content-Type: application/json"--data @body.json http://localhost:8080/ui/webapp/conf
```

* curl post 一个json字符串

```
curl -H "Content-Type: application/json"-d '{"username":"xyz","password":"xyz"}' http://localhost:3000/api/login
```

## 系统时间

* centos6系列修改时区

```
```
