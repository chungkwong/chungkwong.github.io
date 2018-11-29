---
title:  "Linux下常用命令概览"
redirect_from: /2016/12/04/linux-commands.html
layout: post
last_modified_at: 2018-02-15
tags: gnu linux 操作系统
ads:
    - <a rel="nofollow" target="_blank" href="https://amazon.cn/gp/product/B008Z1IEQ8/ref=as_li_tl?ie=UTF8&tag=chungkwong-23&camp=536&creative=3200&linkCode=as2&creativeASIN=B008Z1IEQ8&linkId=270aa78907737f2b7700c97ee1f3ecc2">UNIX编程艺术</a>
---

命令是类Unix系统的一个重要接口（C函数是更低层次的一个，但命令通常是第一选择，Unix传统认为一行shell胜万行C），使用Unix应当了解一些命令，以便把它们组合起来用。Unix有很多命令，不用一一记住，但应该知道什么样的任务有命令可用。Unix命令的用法大都是规则的（有点经验一般能大致猜到），同时Unix有方便的帮助系统，需要时查阅即可。

## 命令的格式约定

命令由一些用空白分隔的字组成，其中首个字为命令名，其余为参数。命令名决定哪个程序被调用，而各参数被传递给该程序，程序结束时返回一个整数（0表示成功完成）。

大多数命令（特别是GNU的）遵守本节约定。参数分为选项和操作数，其中选项由`-`开首。由`--`开首的是长选项，否则是短选项。短选项本来`-`只后接一个字符，后接多个会自动拆开，如`ls -lR`相当于`ls -l -R`。

选项通常可以任何顺序出现， 如`sort -r passwd -t :`等效于`sort -r -t : passwd`。但环境变量POSIXLY_CORRECT被设置的话，选项应当先于操作数。

大多数程序也接受长选项的前缀缩写，只要无歧义。如`rmdir --ignore-fail-on-non-empty`可简作`rmdir --ignore-fail`或`rmdir --i`。

|标准选项|用途|
|:---|:---|
|--help|打印用法（包括可用参数）后成功地退出|
|--version|打印版本号后成功地退出|
|--|后面的参数即使以`-`开首也不视为选项。如`sort -- -r`中`-r`是文件名而非选项。|

单独的`-`用在预期文件的地方时通常视为标准输入或标准输出。

在预期块大小的场合，可用后缀表示单位，如kB（10^3 = 1000）、k、K、KiB（2^{10}）、MB（10^6）、M、MiB（2^{20}）、GB（10^9）、G、GiB（2^{30}）、TB（10^{12}）、T、TiB（2^{40}）、PB（10^{15}）、P、PiB（2^{50}）、EB（10^{18}）、E、EiB（2^{60}）、ZB（10^{21}）、Z、ZiB（2^{70}）、YB（10^{24}）、Y、YiB（2^{80}）。

在预期信号的地方，可用`SIG`后接信号名，包括：

|信号|原因|
|:---|:---|
|HUP|挂起（如用户按下ctrl-Z）|
|INT|终端发起中断（如用户按下ctrl-C）|
|QUIT|终端发起离开（如用户按下ctrl-\）|
|ABRT|进程中止|
|KILL|杀死（不能捕获或忽略）|
|ALRM|时钟|
|TERM|结束|

在预期随机源的地方，伪随机数发生器`/dev/urandom`足以满足多数需要，真随机数发生器`/dev/random`很慢。

##  部分命令列表

本节列出一些通常GNU/Linux系统上都有的命令。

###  帮助

当不知道一个命令的用法时，首先应当查一下文档（远比搜索引擎靠谱），绝大多数命令都有man文档（部分有中文化），一些命令（特别是GNU的）还有更详细的info文档。

|命令|用途|常用选项|
|:---|:---|:---|
|man|在线参考手册的接口|-a列出来自所有类别的|
|info|阅读info文档||
|apropos|搜索手册页名称和描述||

顺带一提，在info阅读器中，回车可进入链接，P、N、U可分别前往前一、后一、上一层节点，D回到目录，S搜索，R退出。


### 文件管理

#### 文件系统

|命令|用途|常用选项|
|:---|:---|:---|
|fsck|检查并修复Linux文件系统||
|mkfs|创建一个 Linux 文件系统|-t 文件系统类型|
|tune2fs|调整ext2/ext3/ext4文件系统参数||
|df|报告文件系统磁盘空间的使用情况||
|du|报告文件的磁盘空间使用情况||
|stat|打印信息节点(inode)内容||
|switch_root|改变根||
|pivot_root|改变根||
|sync | 清空文件系统缓冲区||
|findmnt|列出已挂载文件系统||
|mount |挂载文件系统（包括虚拟光驱）||
|mountpoint |检查一个文件是否挂载点||
|umount | 卸载文件系统||
|fusermount | 卸载用户空间文件系统||
|ulockmgr_server |用户空间文件系统管理器||
|fuser | 找出正在用文件的进程和套接字||
|lsblk |列出块设备||
|mkswap|建立一个linux交换区||
|swapon, swapoff|使用/关闭用于分页和交换的文件和设备||
|fstrim|放弃未用的块||
|fdisk|分区表操作工具||
|mt |控制磁带设备||
|locate|定位文件（快但数据可能过时）|--existing、--ignore-case、--regex、-n LIMIT|
|updatedb|更新locate用的数据库||
|find|寻找文件|选项众多|
|which |定位命令||

## 文件管理

|命令|用途|常用选项|
|:---|:---|:---|
|basename|从文件名中剥离目录和后缀||
|csplit|按模式分割文件||
|cat | 连接文件并在标准输出上输出||
|chacl | 改变获取文件的访问控制列表||
|chgrp | 改变文件的组所有权||
|chmod | 改变文件的访问权限||
|chcon|设置安全上下文||
|chown | 修改文件所有者和组别||
|cp | 复制文件和目录||
|dd | 转换和拷贝文件|if=file、of=file、bs=bytes、cbs=bytes、skip=blocks、seek=blocks、count=blocks|
|dircolors|设置 ls 的颜色||
|file|确定文件类型||
|getfacl |获取文件的访问控制列表||
|gpg|加密与数字签名||
|install|复制文件并设置属性||
|link|硬链接||
|ln |在文件之间建立连接|-s用符号连接而非硬连接|
|ls| 列目录内容|-C多列输出、-R递归、-a也列出以`.`开头的隐含文件、-l详细、-1单列输出|
|mkdir |建立目录|-p建立缺失的父目录|
|mknod | 建立块专用或字符专用文件||
|mkfifo|创建命名管道||
|mktemp | 产生唯一的临时文件名||
|mv | 移动 (改名) 文件||
|pathchk|检查路径是否有效或可移植|--portability|
|pwd | 显示出当前/活动目录的名称||
|realpath|显示绝对路径||
|readlink |解析符号链接||
|shred|覆写文件以使内容更难恢复|--iterations=N、--size=N、--remove|
|rm | 移除文件或者目录|-f不作确认提示、-i进行确认提示、-r或者-R递归地移除目录树。|
|rmdir|删除空目录||
|sum|计算文件的校验和,以及文件占用的块数||
|cksum|CRC校验以及字节数||
|md5sum|计算或检验MD5校验码|
|sha1sum|计算检验SHA1校验码|-b二进制模式|
|sha224sum|计算检验SHA224校验码|-b二进制模式|
|sha256sum|计算检验SHA256校验码|-b二进制模式|
|sha384sum|计算检验SHA384校验码|-b二进制模式|
|sha512sum|计算检验SHA512校验码|-b二进制模式|
|split|分割文件|--bytes=SIZE、--line-bytes=SIZE、--lines=NUMBER|
|setfacl | 改变获取文件的访问控制列表||
|tempfile |创建临时文件||
|touch | 修改文件的时间戳记.||
|truncate|把文件大小设为给定值|--no-create、--io-blocks、--reference=RFILE、--size=SIZE|
|unlink|移除文件||

#### 归档文件处理

|命令|用途|常用选项|
|:---|:---|:---|
|cpio | 存取归档包中的文件||
|tar | tar 归档文件管理程序。|-A合并归档、-c建立新的归档、-d比较存档与当前文件、--delete从存档中删除、-r附加到存档结尾、-t列出存档中文件的目录、-u仅将较新的文件附加到存档中、-x展开|
|ar|建立, 修改归档或从归档中抽取成员（常用于库）||

|操作|bz2|gz|lz|xz|lzop|
|:---|:---|:---|:---|:---|:---|
|解压|bunzip2|gunzip|unlzma|unxz|unlzop|
|压缩|bzip2|gzip|lzma|xz|lzop|
|修复损坏的压缩包|bzip2recover||||
|原地压缩可执行文件使之可像原来那样用|bzexe|gzexe|||
|压缩包信息||||lzmainfo|
|cat|bzcat|zcat|lzcat|xzcat|lzopcat|
|cmp|bzcmp|zcmp|lzcmp|xzcmp|
|diff|bzdiff|zdiff|lzdiff|xzdiff|
|egrep|bzegrep|zegrep|lzegrep|xzegrep|
|fgrep|bzfgrep|zfgrep|lzfgrep|xzfgrep|
|grep|bzgrep|zgrep|lzgrep|xzgrep|
|less|bzless|zless|lzless|xzless|
|more|bzmore|zmore|lzmore|xzmore|

#### 二进制文件处理

|命令|用途|常用选项|
|:---|:---|:---|
|cmp|比较文件||
|hexdump|显示文件||
|od|显示文件||
|base32|Base32编码和解码|-d解码、-w指定行长|
|base64|Base64编码和解码|-d解码、-w指定行长|
|uuencode|对二进制文件编码||
|uudecode|对二进制文件解码||
|strings|显示文件中的可打印字符||
|objdump|显示对象文件||

#### 文本处理

|命令|用途|常用选项|
|:---|:---|:---|
|aspell|拼写检查||
|diff|找出两个文件的不同点|-c使用上下文输出格式、--recursive、--side-by-side|
|diff3|找出三个文件的不同点||
|comm|逐行比较两个已排序的文件||
|sdiff|边对边地合并文件||
|patch|对原文件应用diff文件||
|sed |用于过滤或转换文本的流编辑器，参考[sed](/2016/12/03/sed.html)||
|gawk|一种模式匹配与处理工具，参考[GAWK](/2016/12/23/gawk.html)||
|grep, egrep, fgrep | 打印匹配给定模式的行|||
|less |在显示器上分屏阅读文件的过滤器（建议）||
|more |在显示器上分屏阅读文件的过滤器||
|nano |一个简单易用的文本编辑器（Nano's ANOther）||
|rnano |安全模式的Nano||
|vi|一个程序员的文本编辑器||
|head|输出文件的开始部分||
|tail|输出文件的末尾部分||
|wc|输出文件中的行数、单词数、字节数||
|tac|反转显示文件||
|tr|转换或删除字符|--complement、--delete、--squeeze-repeats、--truncate-set1|
|shuf|随机重排文本行|--echo、--input-range=LO-HI、--head-count=COUNT、--repeat|
|tsort|拓扑排序，输入中每行给出偏序||
|sort|行排序|-r颠倒比较的结果、-n数值比较|
|uniq|删除排序文件中的重复行|--count、--repeated、--skip-fields=N、--ignore-case、--skip-chars=N、--unique、--check-chars=N|
|dos2unix|从DOS格式原地转换为Unix格式||
|unix2dos|从Unix格式原地转换为DOS格式||
|expand|把制表符换成空格|--all、--first-only、--tabs=N、--tabs=LIST|
|unexpand|把空格换成制表符|--initial、--tabs=N、--tabs=LIST|
|seq|打印等差数列||
|ptx|打印文件的排序索引||
|pr|分页的分栏为适合打印的形式||
|printf|格式化并显示数据||
|numfmt|把数字转换为给人读的形式（或相反）||
|cut|在文件的每一行中提取片断|--bytes=LIST、--characters=LIST、--delimiter=DELIM、--fields=LIST|
|paste|合并文件各行|--delimiters=LIST、--serial|
|nl|加行号||
|join|合并公共域||
|fold|折叠输入行, 使其适合指定的宽度|--bytes、--spaces、--width=WIDTH|
|fmt|简易的文本格式优化工具|--prefix=STRING、--split-only、--tagged-paragraph、--uniform-spacing、--width=NUMBER|

### 系统管理

#### 进程

|命令|用途|常用选项|
|:---|:---|:---|
|top|实时显示进程信息||
|ps |显示当前进程|-a列出所有|
|pstree|显示进程树||
|kill | 终止进程||
|killall|以名字方式来杀死进程||
|pidof |由名字查PID||
|nohup|使程序运行时不挂起, 不向 tty 输出信息||
|nice|改变执行程序的优先级|--adjustment=ADJUST|
|renice|改变执行程序的优先级|--priority priority、--pgrp、--pid、--user|
|ionice|读写I/O调度类型和优先级||
|start-stop-daemon|启动或停止守护进程|

#### 时间

|命令|用途|常用选项|
|:---|:---|:---|
|cal|显示日历|
|crontab|管理定期运行||
|hwclock|硬件时间||
|date|打印或设置系统日期和时间|
|sleep | 延迟指定数量的时间||
|timeout|限时运行命令||
|time|运行命令并总结资源使用||
|at|在指定的时间执行命令||
|uptime|告知系统运行了多久时间||

#### 用户管理

|命令|用途|常用选项|
|:---|:---|:---|
|login | 在系统上启动回话||
|sulogin|单用户登录（用于维护）||
|w|显示已经登录的用户以及他们在做什么||
|who|显示已经登录的用户||
|whoami|显示有效用户ID||
|last, lastb|显示最近登录的用户列表||
|logname|显示用户登录名||
|users|显示已经登录的用户名||
|groups|显示用户所在的组||
|id|显示真实和有效的 UID 和 GID||
|passwd|更改用户密码||
|chpasswd|批量更新密码||
|su| 更改用户 ID 或成为超级用户||
|sudo|以另一用户身份执行命令，配置在/etc/sudoers|--user=user|
|useradd|增加用户|
|userdel|删除用户|
|usermod|修改用户|
|groupadd|增加用户组|
|groupdel|删除用户组|
|groupmod|修改用户组|


### 系统信息

|命令|用途|常用选项|
|:---|:---|:---|
|arch|显示机器的体系结构||
|uname | 显示输出系统信息|-a所有|
|dmesg |打印或控制内核日志||
|free|显示系统中已用和未用的内存空间总和||
|logger|加入日志||
|printenv|显示环境||
|nproc|显示可用处理器数|--all|
|modprobe|装卸内核模块|-i加载、-r卸载|
|modinfo|显示当前内核模块信息||
|lsmod|列出当前内核模块信息||
|sysctl|设置内核参数||
|efibootmgr |EFI引导管理器||
|lspci|列出pci设备||
|acpid|ACPI设置||
|wdctl|显示硬件看门狗状态||
|losetup|设定与控制环回设备||
|blockdev|从命令行调用区块设备控制程序||
|halt, reboot, poweroff|中止系统运行|-f强行|
|shutdown|关闭系统|-r重启、-h停机|

#### 终端

|命令|用途|常用选项|
|:---|:---|:---|
|openvt |在新的虚拟终端启动程序||
|deallocvt|释放未使用的虚拟终端||
|chvt | 修改虚拟终端的前台环境||
|fgconsole | 显示活动的虚拟终端数||
|unicode_start | 将控制台设为Unicode模式.||
|fc-list|列出字体||
|setfont | 加载EGA/VGA控制台屏幕字体||
|stty | 改变并打印终端行设置||
|setupcon | 设置控制台的字体和键盘||
|dumpkeys | 转储显示键盘翻译表||
|setkeycodes|设置键盘映射||
|vmmouse_detect | 检测是否在VMware运行||
|whiptail | 根据shell脚本显示对话框||
|loadkeys | 调入键盘翻译表||
|reset|初始化终端||
|tty|显示连接标准输入的终端的文件名||
|clear|清除终端屏幕||


#### 网络

|命令|用途|常用选项|
|:---|:---|:---|
|hostid|显示当前主机的数字化标识|
|hostname|显示或设置系统的主机名|
|domainname|显示或设置系统的NIS/YP域名|
|dnsdomainname|显示系统的DNS域名|
|nisdomainname|显示或设置系统的NIS/YP域名|
|ypdomainname|显示或设置系统的NIS/YP域名|
|nodename|显示或设置系统的DECnet节点名|
|nameif|设置网络接口的MAC地址|
|hciconfig |配置蓝牙设备||
|ifconfig|配置网络接口||
|iwconfig|配置无线网络接口||
|ifup|启用网络接口||
|ifdown|停用网络接口||
|ifquery|解析网络接口配置||
|arping|发送arp请求|
|arp|管理ARP缓存|
|ip |显示或设置路由||
|route|显示/操作IP路由表||
|ping|向网络主机发送ICMP回显请求(ECHO_REQUEST)分组||
|ping6|向网络主机发送ICMP回显请求(ECHO_REQUEST)分组||
|traceroute|探测路径|
|traceroute6|探测路径|
|tcpdump|转储网络上的数据流||
|nc|发起或监听TCP/UDP连接||
|netcat|发起或监听TCP/UDP连接||
|netstat |显示网络连接，路由表，接口状态，伪装连接，网络链路信息和组播成员组。||
|networkctl|查询网络连接状态||
|ss |显示套接字统计||
|nslookup|DNS查询||
|host|DNS查询和反向查询||
|wget|FTP/HTTP/HTTPS下载器|--recursive、--level=depth、--accept-regex urlregex、--reject-regex urlregex|
|ssh|远程登录程序||
|telnet|||
|ftp|FTP客户端||
|rcp,scp|远程复制||
|w3m|网页浏览器||

### 杂项

|命令|用途|常用选项|
|:---|:---|:---|
|echo | 显示一行文本||
|stdbuf|以特定缓冲方式运行命令|--input=MODE、--output=MODE、--error=MODE（0表示不缓冲、L表示行缓冲、否则为缓冲大小）|
|tee|从标准输入写往文件和标准输出|--append、--ignore-interrupts|
|test|求值关于文件的布尔表达式||
|expr|求值表达式，0返回1、null返回2、其它返回0||
|bc|表达式计算器||
|dc|逆向波兰表达式计算器||
|factor|素因子分解||
|true|(成功的)什么都不做||
|false | (失败的)什么都不做||
|yes|不断输出一个字符串,直到杀死其为止|
|watch|重复执行命令|--interval seconds|
|run-parts |在指定目录运行程序||
|chroot|以特定根目录运行命令或者交互式 shell||
|runcon|在指定安全上下文运行命令|--type=TYPE、--user=USER、--role=ROLE、--range=RANGE|
|xargs|从标准输入重建并执行命令行||
|getopt|解析命令行参数||

另外，GNU Gettext中有一些国际化工具： autopoint、envsubst、gettextize、gettext、msgattrib、msgcat、msgcmp、msgcomm、msgconv、msgen、msgexec、msgfilter、msgfmt、msggrep、msginit、msgmerge、msgunfmt、msguniq、ngettext、xgettext


值得一提的是，如果发现命令不可用又不方便安装，可以尝试用号称瑞士军刀的busybox，它虽然只有1MB左右，但包含了众多Unix工具的精简版本：

[, [[, acpid, adjtimex, ar, arp, arping, ash, awk, basename,
               blockdev, brctl, bunzip2, bzcat, bzip2, cal, cat, chgrp, chmod,
               chown, chpasswd, chroot, chvt, clear, cmp, cp, cpio, crond, crontab,
               cttyhack, cut, date, dc, dd, deallocvt, depmod, devmem, df, diff,
               dirname, dmesg, dnsdomainname, dos2unix, dpkg, dpkg-deb, du,
               dumpkmap, dumpleases, echo, ed, egrep, env, expand, expr, false,
               fdisk, fgrep, find, fold, free, freeramdisk, fstrim, ftpget, ftpput,
               getopt, getty, grep, groups, gunzip, gzip, halt, head, hexdump,
               hostid, hostname, httpd, hwclock, id, ifconfig, ifdown, ifup, init,
               insmod, ionice, ip, ipcalc, kill, killall, klogd, last, less, ln,
               loadfont, loadkmap, logger, login, logname, logread, losetup, ls,
               lsmod, lzcat, lzma, lzop, lzopcat, md5sum, mdev, microcom, mkdir,
               mkfifo, mknod, mkswap, mktemp, modinfo, modprobe, more, mount, mt,
               mv, nameif, nc, netstat, nslookup, od, openvt, passwd, patch, pidof,
               ping, ping6, pivot_root, poweroff, printf, ps, pwd, rdate, readlink,
               realpath, reboot, renice, reset, rev, rm, rmdir, rmmod, route, rpm,
               rpm2cpio, run-parts, sed, seq, setkeycodes, setsid, sh, sha1sum,
               sha256sum, sha512sum, sleep, sort, start-stop-daemon, stat,
               static-sh, strings, stty, su, sulogin, swapoff, swapon, switch_root,
               sync, sysctl, syslogd, tac, tail, tar, taskset, tee, telnet,
               telnetd, test, tftp, time, timeout, top, touch, tr, traceroute,
               traceroute6, true, tty, tunctl, udhcpc, udhcpd, umount, uname,
               uncompress, unexpand, uniq, unix2dos, unlzma, unlzop, unxz, unzip,
               uptime, usleep, uudecode, uuencode, vconfig, vi, watch, watchdog,
               wc, wget, which, who, whoami, xargs, xz, xzcat, yes, zcat

