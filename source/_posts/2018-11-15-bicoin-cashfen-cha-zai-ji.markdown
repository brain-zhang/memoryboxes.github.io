---
layout: post
title: "Bicoin Cash分叉在即"
date: 2018-11-15 15:08:32 +0800
comments: true
categories: blockchain
---

Bitcoin Cash 将于UNIX时间1542300000 (即香港时间2018年11月16日00：40)发生硬分叉;

分叉两派是比特大陆为首支持的[Bitcoin ABC](https://github.com/Bitcoin-ABC/bitcoin-abc)实现，以及Craig Steven Wright为首的[BItcoin SV](https://github.com/bitcoin-sv/bitcoin-sv)实现。

两派的恩恩怨怨政治斗争无心吐槽，咱也没有明确的倾向；但是作为码农咱要黑一黑；

<--! more -->

[这里](https://github.com/bitcoin-sv/bitcoin-sv/commit/2ab7775797a5a37ab311ab9a067771e5c1bfe22a)是bitcoin SV 从Bitcoin ABC项目里面开始folk出来的修改；截至他们发布Bitcoin SV Beta1.0；最后提交的代码是[1dcf61c6fd2898e506a9b9f1fe954d0ec46b2d12](https://github.com/bitcoin-sv/bitcoin-sv/commit/1dcf61c6fd2898e506a9b9f1fe954d0ec46b2d12)；


执行 `git diff 802629f 1dcf61c --stat` 瞄一眼:

```
 .arcconfig                                               |    9 -
 .arclint                                                 |   18 -
 .teamcity/.gitignore                                     |    3 -
 .teamcity/BitcoinABC/Project.kt                          |   18 -
 .teamcity/BitcoinABC/buildTypes/BitcoinABCMasterLinux.kt |   49 --
 .teamcity/BitcoinABC/settings.kts                        |   41 --
 .teamcity/BitcoinABC/vcsRoots/BitcoinABCGit.kt           |   18 -
 .teamcity/pom.xml                                        |  114 -----
 .travis.yml                                              |   89 ----
 CMakeLists.txt                                           |    2 +-
 CONTRIBUTING.md                                          |  193 +-------
 COPYING                                                  |    1 +
 INSTALL.md                                               |    2 +-
 README.md                                                |   33 +-
 arcanist/.phutil_module_cache                            |    1 -
 arcanist/__phutil_library_init__.php                     |    3 -
 arcanist/__phutil_library_map__.php                      |   20 -
 arcanist/linter/AutoPEP8Linter.php                       |   79 ----
 arcanist/linter/ClangFormatLinter.php                    |   79 ----
 src/Makefile.am                                          |    2 +
 src/Makefile.test.include                                |    2 +-
 src/clientversion.cpp                                    |    4 +-
 src/config.cpp                                           |    8 +
 src/config/CMakeLists.txt                                |    2 +-
 src/consensus/consensus.h                                |    4 +-
 src/init.cpp                                             |   22 +-
 src/miner.cpp                                            |    4 +-
 src/policy/policy.h                                      |    2 +-
 src/rpc/misc.cpp                                         |   11 +-
 src/script/interpreter.cpp                               |  133 +++++-
 src/script/interpreter.h                                 |   95 +---
 src/script/script.h                                      |    8 +
 src/script/script_flags.h                                |  108 +++++
 src/test/CMakeLists.txt                                  |    2 +-
 src/test/data/script_tests.json                          |  118 ++++-
 src/test/excessiveblock_tests.cpp                        |   23 +-
 src/test/miner_tests.cpp                                 |    8 +-
 src/test/monolith_opcodes.cpp                            |  789 --------------------------------
 src/test/net_tests.cpp                                   |    4 +-
 src/test/opcode_tests.cpp                                | 1171 ++++++++++++++++++++++++++++++++++++++++++++++++
 src/test/rpc_tests.cpp                                   |   13 +
 src/test/scriptflags.cpp                                 |    2 +
 src/validation.cpp                                       |   45 +-
 src/validation.h                                         |    6 +
 test/functional/abc-cmdline.py                           |   10 +-
 test/functional/abc-p2p-compactblocks.py                 |    3 +-
 test/functional/abc-rpc.py                               |    8 +-
 test/functional/bsv-128Mb-blocks.py                      |  237 ++++++++++
 test/functional/bsv-blocksize-params.py                  |   40 ++
 test/functional/magnetic-activation.py                   |  182 ++++++++
 test/functional/prioritise_transaction.py                |    3 +-
 51 files changed, 2152 insertions(+), 1689 deletions(-)

```

从头review一遍，他们从2018-08-22搞到现在，啥改动都没有，就开了几个操作码，改了几个测试；原本MAXBLOCKSIZE就变成可配置的了，他们不过是稍稍改了一下判断条件而已，改动最大的反而是README文件，最值得吐槽的就是这个提交：

https://github.com/bitcoin-sv/bitcoin-sv/commit/db8190ab5fb5262a6d3701017d733f106308fd0d

凭良心说，Bitcoin ABC的开发比不上Bitcoin Core的活跃，但起码Bitcoin Core有什么更新，人家能及时Merge过来啊！

曾经，像Bitcoin Gold之流，改个POW算法就出来割韭菜了，大家还愤愤不平；

Litcoin和Dogcoin还是改了改币数上限和出块时间的，这是在早期，咱们也忍了~~

如今Bitcoin SV的代码库让我见识了什么叫任性！我觉得这种代码出来分叉真的是对开发人员赤裸裸的打脸。

如果不赞成升级，原版代码运行就是；现在哥们，你们倒是增加了操作码！但是操作码执行实现的部分在哪里，对应的测试在哪里？就两天时间开放出来不怕出BUG吗？

我觉得数字货币这个场子没啥正义公理可言，就是中本聪重现人间，相信说话也没多大分量了；但是代码质量是没办法靠嘴炮提升的；Bitcoin SV这个代码质量得不到码农的信赖。
