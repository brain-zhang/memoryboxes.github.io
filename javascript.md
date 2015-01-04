Javascript设计模式 (笔记1)

# 富有表现力的javascript

## 弱类型语言

javascript中有三种原始类型:布尔型、数值型(不区分浮点数和整数)和字符串型。
此外，还有对象类型和包含可执行代码的函数类型。前者是一种复合类型(数组是一种特殊的对象)。
最后，还有空类型(null)和未定义类型(undefined)。

原始数据类型按值传送，其他数据类型则按引用传送。

## 函数是一等对象
 
  * 匿名函数

        (function(){
            var foo = 10;
            var bar = 2;
            alert(foo * bar);
        })();

  * 闭包

        var bar;
        (function(){
            var foo = 10;
            var bar = 2;
        })();
