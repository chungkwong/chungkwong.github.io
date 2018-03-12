---
title:  "Debian和openJDK下Netbeans 8随机崩溃的应对"
redirect_from: /2018/01/01/netbeans-crash.html
layout: post
tags: netbeans 应急
---

前段时间在两台机器都出现了Netbeans 8在毫无征兆下崩溃的现象，似乎与崩溃前做的事没有什么关联，甚至没有留下JVM崩溃的日志文件，两台机器都在用Debian 9, openJDK 8版本较新。

按照Debian和Netbeans跟踪器中讨论，得知这是一个底层的Bug，与残疾人辅助功能有关。于是一个临时方案是在`/etc/java-8-openjdk/accessibility.properties`中注释掉启用GNOME辅助功能的配置。

```
# assistive_technologies=org.GNOME.Accessibility.AtkWrapper
```

实测表明，此后Netbeans没有再崩溃。

