---
layout: post
title: "Javascript设计模式 - 笔记2"
date: 2015-01-05 09:05:16 +0800
comments: true
categories: javascript_pattern
---
# 如何封装一个对象

## 门户大开型

最简单的办法就是按传统方法创建一个类，用一个函数来做其构造器。

```
var Book = function(isbn, title, author) {
    if (isbn === undefined) {
        throw new Error('Book constructor requires an isbn.');
    }
    this.isbn = isbn;
    this.title = title || 'No title specified';
    this.author= author || 'No title specified';
}

//define by attr
Book.prototype.display = function() {...};

//define by object literals
Book.prototype = {
    display: function(){...},
    checkisdn: function(){...}
};
```

* 优点：简单
* 缺点：没有保护，需要加各种校验。但内部的成员还是有很大可能被修改的。

## 语法修饰增强型

用setattr,getattr等赋值取值方法及命名规范区别私有成员


## 闭包实现私有成员

## 实现静态方法和属性

## 实现常量
