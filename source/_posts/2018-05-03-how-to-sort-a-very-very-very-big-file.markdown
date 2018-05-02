---
layout: post
title: "how to sort a very very very big file"
date: 2018-05-03 07:21:50 +0800
comments: true
categories: tools
---

sort -uo 一个1T的文件，让最高配的google cloud崩溃了~~~，可惜了我的$30，白白跑了那么长时间~~~

网上搜索都是how to sort a big file，那我这个属于very very very big big big file了~~

不管是并行也好，管道也好，用了各种奇技淫巧就是敌不过人家 very very big~

我也不想自己去写代码，最后只有分割搞定~~

### 把大象装进冰箱分为几步？

### 三步:

1. split -l 1000000000 huge-file small-chunk

2. for X in small-chunk*; do sort -u < $X > sorted-$X; done

3. sort -u -m sorted-small-chunk* > sorted-huge-file && rm -rf huge-file
