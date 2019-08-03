---
layout: post
title: "Libssl segfaults on python3.6 with threading"
date: 2019-08-03 20:23:47 +0800
comments: true
categories: develop
---

openssl1.0.0 和 openssl1.0.1 使用Python3.6的绑定:

<!-- more -->

```
import ctypes
import logging

try:
    ssl_library = ctypes.cdll.LoadLibrary('libeay32.dll')
except Exception:
    ssl_library = ctypes.cdll.LoadLibrary('libssl.so')

def check_result(val, func, args):
    if val == 0:
        raise ValueError
    else:
        return ctypes.c_void_p(val)


# ssl_library.EC_KEY_new.restype = ctypes.c_void_p
ssl_library.EC_KEY_new_by_curve_name.restype = ctypes.c_void_p
ssl_library.EC_KEY_new_by_curve_name.errcheck = check_result

k = ssl_library.EC_KEY_new_by_curve_name(NID_secp256k1)

if ssl_library.EC_KEY_generate_key(k) != 1:
    raise Exception("internal error")
ssl_library.EC_KEY_free(k)
```

这段代码在多线程的时候会出现segmentation fault error； 是openssl1.0.0的实现问题，参考:

https://bugs.python.org/issue29340

需要升级至openssl1.1.0；

这个是今天我在实现一个简单的比特币钱包的时候发现的，用函数名google了一通没发现问题；挂上gdb才追踪到了lib库里面；

我当时通读了electrum的代码，还纳闷他为啥自己实现了一遍ECDSA，这回明白了；

原来解决这种问题还蛮有兴致的，现在是越来越懒，有时候觉得这样效率真低啊，难道已经到了智力衰退期了，话说程序员有个35岁限制，我原来是不信的，现在有点体会了~~~
