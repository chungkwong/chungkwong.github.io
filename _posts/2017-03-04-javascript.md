---
title:  "Javascript概览"
redirect_from: /2017/03/04/javascript.html
layout: post
tags: javascript web 程序设计语言
---

Javascript([ECMAScript](http://www.ecma-international.org/ecma-262))是，除了作为客户端网页脚本的事实标准外，也逐渐在服务器端取得一些应用（如Node），还在个别其它地方用作脚本语言（如PDF）。JS是一种基于对象的动态类型语言，但并不基于类而基于原型。JS的对象可看作其它语言中的散列表，键值对即属性（键称为属性的名字，值称为属性的值）不区分方法和域，其中每个对象有一个`prototype`属性的值称为对象的原型。

## 类型系统

### 分类

#### 基本类型

##### 未定义类型

只有一个值`undefined`，未被赋值的变量都有这个值。

##### 空类型

只有一个值`null`。

##### 布尔类型

只有两个值`true`和`false`分别表示真、假。

##### 符号类型

符号用作对象的属性的键，符号都是惟一和不可变的，并与`undefined`或字符串关联。

##### 字符串类型

字符串是由零个或多个16位无符号整数组成的序列，用从0开始的指标引用各整数。其中的整数通常用于表示UTF-16代码点。

##### 数值类型

数值即IEEE754双精度浮点数。

#### 对象类型

对象就是属性的集合，属性即键值对，由键（是字符串的话叫名字）。属性可分为：
- 数据属性关联一个值和一些布尔配置：
    - `[[Value]]`值为取访问属性时得到的值（默认为`undefined`）
    - `[[Writable]]`决定能否改变属性的值（默认为`false`）
    - `[[Enumerable]]`决定能否用for‐in遍历（默认为`false`）
    - `[[Configurable]]`决定能否删除属性、改变配置（除把`[[Writable]]`改为`false`）、改为访问器属性（默认为`false`）
- 访问器属性关联一个或两个访问器函数和一些布尔配置：
    - `[[Get]]`值为取访问时被以空参数列表调用以返回值的函数对象（默认为`undefined`）
    - `[[Set]]`值为设访问时被以被设值为单一参数调用的函数对象（默认为`undefined`）
    - `[[Enumerable]]`决定能否用for‐in遍历（默认为`false`）
    - `[[Configurable]]`决定能否删除属性、改变配置、改为数据属性（默认为`false`）

### 类型转换

#### 到基本类型

1. 如对象有`toPrimitive`方法，调用它并返回结果
4. 
    - 若提示为字符串，依次尝试调用对象的`toString`或`valueOf`方法，得到非对象就返回它
    - 依次尝试调用对象的`valueOf`或`toString`方法，得到非对象就返回它
5. 抛出`TypeError`异常

#### 到布尔类型

`undefined`、`null`、`false`、`+0`、`-0`、`NaN`、`""`被转换为`false`，否则为`true`。

#### 到数值类型

值|结果
:---|:---
`undefined`|NaN
`null`|`+0`
`false`|`+0`
`true`|`1`
数值|自身
字符串|类似于解析数值（另支持`Infinity`、`+Infinity`、`-Infinity`），容许前后有空白，全空白则返回0，无法解析则返回NaN
符号|抛出`TypeError`异常
对象|先转换为基本类型（提示数值），再按上述规则

#### 到字符串类型

值|结果
:---|:---
`undefined`|`"undefined"`
`null`|`"null"`
`false`|`"false"`
`true`|`"true"`
数值|其字符串表示
字符串|自身
符号|抛出`TypeError`异常
对象|先转换为基本类型（提示字符串），再按上述规则

#### 到对象类型

值|结果
:---|:---
`undefined`|抛出`TypeError`异常
`null`|抛出`TypeError`异常
布尔值|对应Boolean对象
数值|对应Number对象
字符串|对应String对象
符号|对应Symbol对象
对象|自身

## 语法

JS代码分为：
- 全局代码不解析为FunctionDeclaration、FunctionExpression、GeneratorDeclaration、GeneratorExpression、MethodDefinition、ArrowFunction、ClassDeclaration或ClassExpression的部分
- Eval代码是给内置函数eval的代码文本的全局部分
- 函数代码为解析为FunctionDeclaration、FunctionExpression、GeneratorDeclaration、GeneratorExpression、MethodDefinition、ArrowFunction、ClassDeclaration或ClassExpression的部分，但不包括嵌套的
- 模块代码为作为模块体的代码文本，在模块初始化时运行，不包括解析为FunctionDeclaration、FunctionExpression、GeneratorDeclaration、GeneratorExpression、MethodDefinition、ArrowFunction、ClassDeclaration或ClassExpression的部分

在以下情况会启用严格模式：
- 由含的导言开始的全局代码
- 模块代码
- 类定义和类表达式中
- 由含的导言开始的全局代码或由严格模式代码直接调用的eval代码
- 由Use Strict导言开始或关联的FunctionDeclaration、FunctionExpression、GeneratorDeclaration、GeneratorExpression、MethodDefinition、ArrowFunction、ClassDeclaration或ClassExpression包含于严格模式代码的函数代码
- 开始于含Use Strict导言的作为内置函数和生成器构造器的参数的函数代码

### 词法

#### 注释

JS的注释与Java等等类似，有两种形式：
- 从`//`到行结束符前（不包括行结束符以免影响自动分号插入）
- 从`/*`开始到最近的`*/`

#### 标号

以下之一：

```
{ ( ) [ ] . ... ; , < > <= >= == != === !== + ‐ * % ++ ‐‐ << >> >>> & | ^ ! ~ && || ? : = +=
‐= *= %= <<= >>= >>>= &= |= ^= => ** **=
/ /=
}
```

##### 自动分号插入

假设从左到右解析脚本或模块，
- 若遇到没有生成规则接受一个标记，并且
    - 该标记前有行结束符
    - 该标记为`}`
    - 前一标记为`)`且插入的分号会被解析为do-while语句的结束
  则在标记前插入分号
- 若遇到输入结束而未能完成解析，则插入分号到输入结束处
- 若遇到只有受限的生成规则容许的标记且会成为标注“[no LineTerminator here]”（如`=>`、`++`或`--`前；return、continue、break、throw、yield后；）后的首个符号，但与上一标记相隔至少一个行结束符，则在标记前插入分号

然而，如插入的分号会被解析为空语句或for语句头的两个分号之一，则不进行插入。

#### 标识符

标识符由`$`、`_`或有ID_START属性的Unicode字符开始，然后是零个可多个`$`、`_`、U+200C、U+200D、或有ID_Continue属性的Unicode字符，其中的字符也可用转义序列如`\u{十六进制整数}`或`\uhhhh`（但仍要满足前述规则）。但以下是保留字：
- `null`
- `true`和`false`
- 关键字`break`、`do`、`in`、`typeof`、`case`、`else`、`instanceof`、`var`、`catch`、`export`、`new`、`void`、`class`、`extends`、`return`、`while`、`const`、`finally`、`super`、`with`、`continue`、`for`、`switch`、`yield`、`debugger`、`function`、`this`、`default`、`if`、`throw`、`delete`、`import`、`try`
- `enum`和`await`
两个标识符视为相等当且仅当它们对应相同的代码点序列

#### 空常量

`null`

#### 布尔常量

`true`和`false`

#### 字符串常量

字符串由`"`包围的以下序列组成：
- `"`、`\`和行结束符外的其它字符，表示它自身
- `\`后接一个或以上行结束符，不表示什么
- `\u`后接四个十六进制数字表示有指定代码点的字符
- `\u{一个或以上十六进制数字}`表示有指定代码点的字符
- `\x`后接两个十六进制数字表示有指定代码点的字符
- `\0`、`\b`、`\t`、`\n`、`\v`、`\f`、`\r`、`\"`、`\'`、`\\`含义如Java
- `\`后接无关字符则表示该字符

上述的`"`可以同时改为`'`。

#### 正则表达式常量

正则表达式表示为`/表达式/选项`，其中表达式中首字符不能为`*`，也不能有换行或`/`，选项为可用于标识符中非开始处的字符组成的序列。

#### 模板常量

模板由`` ` ``包围，其中除由`${`与`}`包围处外，由以下组成：
- `` ` ``、`\`、`$`外的其它字符
- `\`后接一个或以上行结束符
- `\u`后接四个十六进制数字
- `\u{一个或以上十六进制数字}`
- `\x`后接两个十六进制数字
- `\0`、`\b`、`\t`、`\n`、`\v`、`\f`、`\r`、`\"`、`\'`、`\\`
- `\`后接无关字符则表示该字符


#### 数值常量

- 二进制的`0b`或`0B`后接由`0和`1`组成的非空序列
- 八进制的`0o`或`0O`后接由`0`到`7`组成的非空序列
- 十进制的依次由以下部分组成：
    - 可选的整数部分为由`0`到`9`组成的序列
    - 可选的小数部分为`.`和由`0`到`9`组成的序列（与上一条加起来至少要有一个数字）
    - 可选的指数部分由`e`或`E`、可选的`+`或`-`、由`0`到`9`组成的非空序列组成
- 十六进制的`0x`或`0X`后接由`0`到`9`、`a`到`f`、`A`到`F`组成的非空序列

### 表达式

初等表达式|效果
:---|:---
标识符|值为对应绑定的值
`yield`|值为对应绑定的值
`this`|
常量|值为相应的空常量、布尔常量、字符串常量、数值常量
数组常量|值为对应的数组
对象常量|值为对应的对象
`function 标识符 ( 形参列表 ) { 函数体 }`|值为对应函数
`function ( 形参列表 ) { 函数体 }`|值为对应函数
类表达式|语法同类声明，值为对应类
生成器表达式|语法同生成器声明，值为对应函数
正则表达式常量|值为相应的正则表达式对象
模板常量|值为替换结果
`( 表达式 )`|值为表达式的值

其中，
- 数组常量由`[`开始、由`]`结束，中间为由`,`分隔的零个或多个赋值表达式或空，赋值表达式前可以有`...`以表示展开
- 对象常量由`{`开始、由`}`结束，中间为由`,`分隔的零个或多个属性定义：
    - 标识符
    - `标识符=赋值表达式`
    - `属性名:赋值表达式`，其中属性名为标识符、字符串、数值或`[赋值表达式]`
    - 方法声明

成员表达式（辅助）|效果
:---|:---
初等表达式|值为表达式的值
`成员表达式 [ 表达式 ]`|值为成员表达式的值的名为表达式的值的属性
`成员表达式 . 标识符`|值为成员表达式的值的指定属性
`成员表达式 模板常量`|值为以模板常量给出的参数值列表调用成员表达式的值的返回值
`super [ 表达式 ]`|值为名为表达式的值的超属性
`super . 标识符`|值为指定的超属性
`new . target`|值为新的目标
`new 成员表达式 参数`|值为用创建表达式的值为构造器、以指定参数值列表创建的对象

创建表达式（辅助）|效果
:---|:---
成员表达式|表达式的值
`new 创建表达式`|值为用创建表达式的值为构造器创建的对象

调用表达式（辅助）|效果
:---|:---
`成员表达式 参数`|值为以给定参数值列表调用成员表达式的值的返回值
`super 参数`|值为用父构造器、以给定参数值列表创建的对象
`调用表达式 参数`|参考前表
`调用表达式 [ 表达式 ]`|参考前表
`调用表达式 . 标识符`|参考前表
`调用表达式 模板常量`|参考前表

其中，参数由`(`开始、由`)`结束，中间为由`,`分隔的零个或多个赋值表达式，赋值表达式前可以有`...`以表示展开

左值表达式|效果
:---|:---
创建表达式|表达式的值
调用表达式|表达式的值

自增减表达式（辅助）|效果
:---|:---
a++|自增a，值为增加前的值
a--|自减a，值为减少前的值
++a|自增a（a为一元表达式），值为增加后的值
--a|自减a（a为一元表达式），值为减少后的值

一元表达式|效果
:---|:---
`delete 一元表达式|删除属性或绑定，值表示是否成功
`void 一元表达式`|求值一元表达式，值为`undefined`
`typeof 一元表达式`|值为一元表达式的类型，如"undefined"、"boolean"、"function"、"number"、"symbol"或"string"等等
`+ 一元表达式`|值为一元表达式的值（转换为数值）
`‐ 一元表达式`|值为一元表达式的负值（转换为数值）
`~ 一元表达式`|值为一元表达式的值转换为32位整数后的按位补
`! 一元表达式`|值为一元表达式的值转换为布尔后的反

指数表达式|说明
:---|:---
`自增减表达式 ** 指数表达式`|值为幂

积性表达式|说明
:---|:---
`积性表达式 * 指数表达式`|值为积
`积性表达式 / 指数表达式`|值为商
`积性表达式 % 指数表达式`|值为余

加性表达式|说明
:---|:---
`加性表达式 + 积性表达式`|值为和或字符串串接
`加性表达式 - 积性表达式`|值为差

移位表达式|说明
:---|:---
`移位表达式 << 和性表达式`|值为左移位结果（位数只有低5位有效）
`移位表达式 >> 和性表达式`|值为右算术移位结果（位数只有低5位有效）
`移位表达式 >>> 和性表达式`|值为右逻辑移位结果（位数只有低5位有效）

关系表达式|说明
:---|:---
`关系表达式 < 移位表达式`|是否小于
`关系表达式 > 移位表达式`|是否大于
`关系表达式 <= 移位表达式`|是否小于等于
`关系表达式 >= 移位表达式`|是否大于等于
`关系表达式 in 移位表达式`|是否有属性
`关系表达式 instanceof 移位表达式`|是否派生自

相等表达式|说明
:---|:---
`相等表达式 == 关系表达式`|是否相等
`相等表达式 != 关系表达式`|是否不相等
`相等表达式 === 关系表达式`|是否严格相等
`相等表达式 !== 关系表达式`|是否不严格相等

位与表达式|说明
:---|:---
`位与表达式 & 相等表达式`|与

位异或表达式|说明
:---|:---
`位异或表达式 ^ 位与表达式`|异或

位或表达式|说明
:---|:---
`位或表达式 | 位异或表达式`|或

逻辑与表达式|说明
:---|:---
`逻辑与表达式 && 位或表达式`|短路与

逻辑或表达式|说明
:---|:---
`逻辑或表达式 || 逻辑与表达式`|短路或

条件表达式|说明
:---|:---
`逻辑或表达式 ? 赋值表达式 : 赋值表达式`|首表达式转换为布尔值真时值为次表达式的值，否则为末表达式的值

赋值表达式|说明
:---|:---
条件表达式|
yield表达式|
箭头表达式|对应匿名函数
`左值表达式 赋值运算符 赋值表达式`|若左值表达式为对象常量或数组常量，再求值赋值表达式，用于更新解构后的左值表达式；否则，先后求值左值表达式和赋值表达式，用后者的值更新前者（后者为匿名函数时也设置其name属性）

其中赋值运算符为以下之一：

```
= *= /= %= += ‐= <<= >>= >>>= &= ^= |= **=
```

箭头表达式则形如`箭头形参  => {函数体}`或`箭头形参  => 不始于花括号的赋值表达式`，其中箭头形参为以下之一：
- `标识符`
- `( 表达式 )`
- `( )`
- `( ... 标识符 )`
- `( ... 绑定模式 )`
- `( 表达式 , ... 标识符 )`
- `( 表达式 , ... 绑定模式 )`

yield表达式形如以下之一：
- `yield`表示生成`undefined`
- `yield 赋值表达式`表示生成赋值表达式的值
- `yield  * 赋值表达式`表示生成赋值表达式的值（作为迭代器）的最后一个元素

逗号表达式|效果
:---|:---
a,b|先后求值a、b，值为后者的值

### 语句和声明

#### 语句

语句|语法|效果
:---|:---|:---
块|由`{`开始、由`}`结束，中间为由`;`分隔的零个或多个语句或声明|在新环境中按块中声明初始化，然后在块中依次运行块中语句，最后得到的非空值（如有）作为块语句的值，退出块前恢复原来环境
变量|由`var`开始，然后是由`,`分隔的一个或多个变量声明，最后以`;`结束|引入变量
空|`;`|
表达式|`表达式 ;`，但开始时向前看符号非`{` `、`function`、`class`、`let [`|值为表达式的值
分支|if ( 表达式 ) 语句 else 语句|若表达式求值转换为布尔值`true`，值为首语句的值，否则为次语句的值
分支|if ( 表达式 ) 语句|若表达式求值转换为布尔值`true`，值为首语句的值，否则为`undefined`
继续|`continue 表达式;`或`continue;`|结束指定或最内层循环的当前迭代
离开|`break 表达式;`或`break;`|离开指定或最内层循环或switch语句
返回|`return 表达式;`|返回表达式的值
环境|`with ( 表达式 ) 语句`|先把表达式求值为一个对象，然后以它和原环境构造新环境运行语句，以语句的值为值
循环|`do 语句  while ( 表达式 ) ;`|运行语句，再求值表达式，若其值转换为`true`则重复，值为最后运行的非空值语句的值（如有）
循环|`while ( 表达式 ) 语句`|求值表达式，若其值转换为`true`则求值语句并重复，值为最后运行的非空值语句的值（如有）
循环|`for ( [lookahead ∉ { let [ }] 表达式 opt ; 表达式  opt ; 表达式 opt ) 语句 `|先求值首个表达式，然后在每次迭代前求值次表达式，若其值转换为`true`则运行语句再求值末表达式，再准备下次迭代，其值为语句的最后一个非空值
循环|`for ( var 变量声明列表 ; 表达式 opt ; 表达式 opt ) 语句`|先声明变量，然后在每次迭代前求值首表达式，若其值转换为`true`则运行语句再求值末表达式，再准备下次迭代，其值为语句的最后一个非空值
循环|`for ( 词法作用域变量声明 表达式 opt ; 表达式 opt ) 语句`|在新环境中声明变量，然后在每次迭代前求值首表达式，若其值转换为`true`则运行语句再求值末表达式，再准备下次迭代，其值为语句的最后一个非空值
循环|`for ( [lookahead ∉ { let [ }] 左值表达式 in 表达式 ) 语句`|先求值表达式得到一对象，从而枚举其属性键字符串的迭代器，每次迭代中把当前元素（解构）赋值给左值表达式的值，再运行语句
循环|`for ( var for绑定 in 表达式 ) 语句`|先求值表达式得到一对象，从而枚举其属性键字符串的迭代器，每次迭代中把当前元素（解构）赋值给for绑定，再运行语句
循环|`for ( for声明 in 表达式 ) 语句`|先求值表达式得到一对象，从而枚举其属性键字符串的迭代器，每次迭代中把当前元素（解构）赋值给for声明中的for绑定，再运行语句
循环|`for ( [lookahead ≠ let] 左值表达式 of 赋值表达式 ) 语句`|先求值赋值表达式得到一迭代器，每次迭代中把当前元素（解构）赋值给左值表达式的值，再运行语句
循环|`for ( var for绑定 of 赋值表达式 ) 语句`|先求值赋值表达式得到一迭代器，每次迭代中把当前元素（解构）赋值给for绑定，再运行语句
循环|`for ( for声明 of 赋值表达式 ) 语句`|先求值赋值表达式得到一迭代器，每次迭代中把当前元素（解构）赋值给for声明中的for绑定，再运行语句
选择|`switch ( 表达式 ) {零个或多个case子句和至多一个default子句 } `，其中case子句如`case 表达式 : 零个或多个语句或声明`、default子句如`default : 零个或多个语句或声明`|先求值表达式，然后按块中初始化，找首个case表达式与它===的case子句（没有则default子句），从该处开始运行并返回最后的非空值（如有）
标号|`标识符 : 语句或函数声明`|与内部的语句或函数声明类似，只是其中的break和continue可用这标识符
抛出|`throw 表达式  ;`|抛出表达式的值
尝试|`try 块 catch ( 捕获参数 ) 块`|若首个块正常返回则以其返回值为值，否则在新环境中用抛出的值初始化捕获参数后运行次块，以其返回状态为本语句的返回状态
尝试|`try 块 finally 块`|依次运行两块，若次块正常结束，值为首块的值
尝试|`try 块 catch ( 捕获参数 ) 块 finally 块`|若首个块正常返回则以其返回值为A；否则在新环境中用抛出的值初始化捕获参数后运行次块，以其返回状态为A。然后运行末块，若正常结束，返回状态如A
调试|`debugger`|进行与实现有关的调试工作并返回结果

其中for声明形如`let for绑定`或`const for绑定`，而for绑定为标识符或绑定模式；捕获参数为标识符或绑定模式

变量声明为以下之一：
- `标识符`
- `标识符 = 赋值表达式`
- `绑定模式 = 赋值表达式`
其中绑定模式为以下之一：
- 对象模式由`{`和`}`包围，中间是由`,`分隔的零个或多个`标识符`或`标识符 = 赋值表达式`
- 数组模式由`[`开始、由`]`结束，中间为由`,`分隔的零个或多个`标识符`或`标识符 = 赋值表达式`或`绑定模式`或`绑定模式 = 赋值表达式`或空，最后也可以是`...`后接标识符或绑定模式

#### 声明

##### 类声明

由`class`开始，然后是可选的标识符（类名），然后是可选的`extends 左值表达式`，最后是由`{`与`}`包围的零个或多个类元素：
- `方法声明`
- `static 方法声明`
- `;`

其中方法声明如以下之一：
- `属性名 ( 形参列表 ) { 函数体 }`
- `* 属性名 ( 形参列表 ) { 函数体 }`
- `get 属性名 ( ) { 函数体 }`
- `set 属性名 ( 绑定元素 ) { 函数体 }`


##### 词法作用域变量声明

由`let`或`const`开始，然后是由`,`分隔的一个或多个以下形式的绑定：
- `标识符`
- `标识符 = 赋值表达式`
- `绑定模式 = 赋值表达式`

##### 函数声明

形如`function 标识符 ( 形参列表 ) { 函数体 }`或`function ( 形参列表 ) { 函数体 }`，其中
- 形参列表为由零个或多个由`,`分隔形参组成：
    - 绑定元素
    - 最后一个也可以是`...`后接标识符或绑定模式
- 函数体为可选的语句列表

值得一提的是，在严格模式下函数体可进行尾调用优化。

##### 生成器声明

形如`function * 标识符 ( 形参列表 ) { 函数体 }`或`function * ( 形参列表 ) { 函数体 }`

#### 脚本和模块

脚本就是零个或多个语句或声明的列表。

模块则是零个或多个导入声明、导出声明、语句或声明的列表。

导入声明形如以下之一：
- `import 标识符 from 字符串字面值 ;
- `import * as 标识符 from 字符串字面值 ;
- `import { 标识符 , ...} from 字符串字面值 ;
- `import 标识符 , * as 标识符 from 字符串字面值 ;
- `import 标识符 , { 标识符 , ...} from 字符串字面值 ;
- `import 字符串字面值 ;`

导出声明形如以下之一：
- `export * from 字符串字面值 ;`
- `export {标识符 , ...} from 字符串字面值 ;`
- `export {标识符 , ...} ;`
- `export 变量语句`
- `export 声明`
- `export default 函数声明或生成器声明`
- `export default 类声明`
- `export default [lookahead ∉ { function , class }] 赋值表达式 ;`

## 内置对象

如无特殊说明，约定：

- 如果调用时参数不足，没给定的视为`undefined`；如果参数过多，多余的会被忽略或用于实现有关的用途。
- 内置函数和构造器的原型为`Function.prototype`，其它内置对象的原型为`Object.prototype`。
- 内置函数的`length`属性值为接受的最多命名参数个数，不可写、不可枚举、可设置。
- 非匿名内置函数的`name`属性值为函数名，不可写、不可枚举、可设置。
- 其它数据属性可写、不可枚举、可设置。
- 其它访问器属性不可枚举、可设置。

### 全局对象

惟一的全局对象在进入任何执行正文前创建，原型与实现有关，不能作为函数或构造器。

值属性|说明
:---|:---
Infinity|$`+\infty`$，不可写、不可设置
NaN|NaN，不可写、不可设置
undefined|`undefined`，不可写、不可设置

函数属性|说明
:---|:---
eval(x)|在当前上下文执行代码并返回结果
isFinite(number)|返回number是否可转换为非NaN或正负无穷的数值
isNaN(number)|返回number是否可转换为NaN的数值
parseFloat(string)|返回string解析得的十进制数值
parseInt(string,radix)|返回string解析得的radix进制数值，radix默认为10（除非string由`0x`或`0X`开始）
decodeURI(encodedURI)|解码URI
decodeURIComponent(encodedURIComponent)|解码URI的一部分
encodeURI(URI)|编码URI
encodeURIComponent(URIComponent)|编码URI的一部分

构造器属性|说明
:---|:---
Array ( . . . )
ArrayBuffer ( . . . )
Boolean ( . . . )
DataView ( . . . )
Date ( . . . )18.3.6 Error ( . . . )
EvalError ( . . . )
Float32Array ( . . . )
Float64Array ( . . . )
Function ( . . . )
Int8Array ( . . . )
Int16Array ( . . . )
Int32Array ( . . . )
Map ( . . . )
Number ( . . . )
Object ( . . . )
Proxy ( . . . )
Promise ( . . . )
RangeError ( . . . )
ReferenceError ( . . . )
Set ( . . . )
String ( . . . )
Symbol ( . . . )
SyntaxError ( . . . )
TypeError ( . . . )
Uint8Array ( . . . )
Uint8ClampedArray ( . . . )
Uint16Array ( . . . )
Uint32Array ( . . . )
URIError ( . . . )
WeakMap ( . . . )
WeakSet ( . . . )

其它属性|说明
JSON|处理JSON用的工具对象
Math|数学用的工具对象
Reflect|反射用的工具对象

### 基本的对象

#### Object

构造器|说明
:---|:---
Object ( [ value ] )|创建或转换对象

Object原型为函数原型。

属性|说明
:---|:---
Object.assign ( target, ...sources )|把各source的各自身可枚举属性都复制到target
Object.create ( O, Properties )|创建以O为原型的对象并加入指定属性
Object.defineProperties ( O, Properties )|给O加入指定属性
Object.defineProperty ( O, P, Attributes )|给O加入指定属性
Object.freeze ( O )|冻结对象
Object.getOwnPropertyDescriptor ( O, P )|返回自身属性描述
Object.getOwnPropertyNames ( O )|返回自身属性名数组
Object.getOwnPropertySymbols ( O )|返回自身属性名符号数组
Object.getPrototypeOf ( O )|返回原型
Object.is ( value1, value2 )|返回两者是否等值
Object.isExtensible ( O )返回是否可扩展
Object.isFrozen ( O )|返回O是否被冻结
Object.isSealed ( O )|返回O是否没有被冻结
Object.keys ( O )|返回键数组
Object.preventExtensions ( O )|禁止扩展
Object.prototype|原型，不可写、不可配置
Object.seal ( O )|解冻O
Object.setPrototypeOf ( O, proto )|设置原型

Object.prototype原型为null。

属性|说明
:---|:---
Object.prototype.constructor|即Object
Object.prototype.hasOwnProperty ( V )|返回是否有自身属性
Object.prototype.isPrototypeOf ( V )|返回是否为V的原型
Object.prototype.propertyIsEnumerable ( V )|返回指定自身属性是否可枚举
Object.prototype.toLocaleString ( [ reserved1 [ , reserved2 ] ] )|返回本地化的字符串
Object.prototype.toString ( )|返回类型的字符串表示
Object.prototype.valueOf ( )|返回对象

#### Function

构造器|说明
:---|:---
Function ( p1, p2, ... , pn, body )|创建函数

属性|说明
:---|:---
Function.length|值为1、不可写
Function.prototype|不可写、不可配置

属性|说明
:---|:---
Function.prototype.apply ( thisArg, argArray )|应用函数
Function.prototype.bind ( thisArg, ...args)|Curry化
Function.prototype.call (thisArg, ...args)|调用函数
Function.prototype.constructor|初始为Function
Function.prototype.toString ( )|返回函数代码的字符串表示

属性|说明
:---|:---
length|典型参数个数，不可写
name|字符串描述，不可写
prototype|作为构造器时用的原型，不可配置

#### Boolean

构造器|说明
:---|:---
Boolean ( value )|按值创建布尔

属性|说明
:---|:---
Boolean.prototype|不可写、不可配置

属性|说明
:---|:---
thisBooleanValue ( value )|返回值
Boolean.prototype.constructor|初始为Boolean
Boolean.prototype.toString ( )|返回值的字符串表示

#### Symbol

构造器|说明
:---|:---
Symbol ( [ description ] )|创建符号

属性|说明
:---|:---
Symbol.for ( key )|返回指定键对应的符号
Symbol.hasInstance|一个常用符号，不可写、不可设置
Symbol.isConcatSpreadable|一个常用符号，不可写、不可设置
Symbol.iterator|一个常用符号，不可写、不可设置
Symbol.keyFor ( sym )|返回对应于指定符号的键
Symbol.match|一个常用符号，不可写、不可设置
Symbol.prototype|一个常用符号，不可写、不可设置
Symbol.replace|一个常用符号，不可写、不可设置
Symbol.search|一个常用符号，不可写、不可设置
Symbol.species|一个常用符号，不可写、不可设置
Symbol.split|一个常用符号，不可写、不可设置
Symbol.toPrimitive|一个常用符号，不可写、不可设置
Symbol.toStringTag|一个常用符号，不可写、不可设置
Symbol.unscopables|一个常用符号，不可写、不可设置

属性|说明
:---|:---
Symbol.prototype.constructor|初始为Symbol
Symbol.prototype.toString ( )|返回符号值或描述
Symbol.prototype.valueOf ( )|返回符号或其值

#### Error


构造器|说明
:---|:---
Error ( message )|构造错误

属性|说明
:---|:---
Error.prototype|原型

属性|说明
:---|:---
Error.prototype.constructor|初始为Error
Error.prototype.message|初始为""
Error.prototype.name|初始为"Error".
Error.prototype.toString ( )|返回字符串表示

原生的运行期错误EvalError、RangeError、ReferenceError、SyntaxError、TypeError、URIError有类似结构，但不是Error，以下用NativeError指代它们：

构造器|说明
:---|:---
NativeError ( message )|创建有指定信息的NativeError

属性|说明
:---|:---
NativeError.prototype|一个原生对象，不可写、不可设置

属性|说明
:---|:---
NativeError.prototype.constructor|初始为对应的NativeError子类
NativeError.prototype.message|初始为""
NativeError.prototype.name|对应的NativeError字符串

### 数值和日期

#### Number

构造器|说明
:---|:---
Number ( value )|创建以为value对应数值为值的Number对象

Number属性|说明
Number.EPSILON|1与比1大的最小数值的距离，约为$`2.2204460492503130808472633361816x10^{‐16}`$，不可写、不可配置
This property has the attributes { [[Writable]]: false, [[Enumerable]]: false, [[Con伀氂igurable]]: false }.
Number.isFinite ( number )|返回number是否有限的数值
Number.isInteger ( number )|返回number是否视为整数数值
Number.isNaN ( number )|返回number是否NaN数值
Number.isSafeInteger ( number )|返回number是否绝对值不超过$`2^{53}-1`$的整数数值
Number.MAX_SAFE_INTEGERNOTE|最大的整数使它和它的后继可精确表示为数值，即$`2^{53}‐1`$，不可写、不可配置
Number.MAX_VALUE|最大的数值，约$`1.7976931348623157 × 10^{308}`$，不可写、不可配置
Number.MIN_SAFE_INTEGER|最小的整数使它和它的前驱可精确表示为数值，即$`-2^{53}+1`$，不可写、不可配置
Number.MIN_VALUE|最小的正数值，约$`5×10^{‐324}`$，不可写、不可配置
Number.NaN|NaN数值，不可写、不可配置
Number.NEGATIVE_INFINITY|负无穷数值，不可写、不可配置
Number.parseFloat ( string )|同parseFloat
Number.parseInt ( string, radix )|同parseInt
Number.POSITIVE_INFINITY|正无穷数值，不可写、不可配置

Number.prototype属性|说明
:---|:---
Number.prototype.constructor|同Number
Number.prototype.toExponential ( fractionDigits )|返回本数值的指数式字符串表示，其中fractionDigits为小数位个数
Number.prototype.toFixed ( fractionDigits )|返回本数值的定点式字符串表示，其中fractionDigits为小数位个数
Number.prototype.toLocaleString ( [ reserved1 [ , reserved2 ] ])||返回本数值的本地字符串表示
Number.prototype.toPrecision ( precision )|返回本数值的字符串表示，其中precision为精度
Number.prototype.toString ( [ radix ] )|返回本数值的字符串表示，其中radix为进制（默认10）
Number.prototype.valueOf ( )|返回本数值

#### Math

值属性|说明
:---|:---
Math.E|自然对数的底，约2.7182818284590452354，不可写、不可配置
Math.LN10|10的自然对数，约2.302585092994046，不可写、不可配置
Math.LN2|2的自然对数，约0.6931471805599453，不可写、不可配置
Math.LOG10E|e的常用对数，约0.4342944819032518，不可写、不可配置
Math.LOG2E|e以2为底的对数，约1.4426950408889634，不可写、不可配置
Math.PI|圆周率，约3.1415926535897932，不可写、不可配置
Math.SQRT1_2|0.5的平方根，约0.7071067811865476，不可写、不可配置
Math.SQRT2|2的底平方根，约1.4142135623730951，不可写、不可配置

以下函数会把参数先转换为数值：

函数属性|说明
:---|:---
Math.abs ( x )|返回x的绝对值
Math.acos ( x )|返回x的反余弦近似值
Math.acosh ( x )|返回x的反双曲余弦近似值
Math.asin ( x )|返回x的正余弦近似值
Math.asinh ( x )|返回x的反双曲正弦近似值
Math.atan ( x )|返回x的反正切近似值
Math.atanh ( x )|返回x的反双曲正切近似值
Math.atan2 ( y, x )|返回y/x的反正切近似值，符号标示方向
Math.cbrt ( x )|返回x的立方近似值
Math.ceil ( x )|返回x的上取整
Math.clz32 ( x )|返回32位整数x前导零个数
Math.cos ( x )|返回x的余弦近似值
Math.cosh ( x )|返回x的双曲余弦近似值
Math.exp ( x )|返回$`e^{x}`$近似值
Math.expm1 ( x )|返回$`e^{x}-1`$近似值
Math.floor ( x )|返回x的下取整
Math.fround ( x )|返回x舍入为32位的数值
Math.hypot ( value1, value2, ...values )|返回各参数平方和的平方根的近似值
Math.imul ( x, y )|返回32位整数的模$`2^32`$积
Math.log ( x )|返回x的自然对数近似值
Math.log1p ( x )|返回$`\ln (1+x)`$近似值
Math.log10 ( x )|返回x的常用对数近似值
Math.log2 ( x )|返回x的以2为底的对数的近似值
Math.max ( value1, value2, ...values )|返回各参数中最大者
Math.min ( value1, value2, ...values )|返回各参数中最小者
Math.pow ( base, exponent )|返回base的exponen幂
Math.random ( )|返回0与1间的均匀分布伪随机数
Math.round ( x )|返回与x最近（等距则取大）的整数
Math.sign (x)|返回x的符号
Math.sin ( x )|返回x的正弦近似值
Math.sinh ( x )|返回x的双曲正弦近似值
Math.sqrt ( x )|返回x的平方根近似值
Math.tan ( x )|返回x的正切近似值
Math.tanh ( x )|返回x的双曲正切近似值
Math.trunc ( x )|返回x的整数部分

#### Date

Date对象有时间值，即从1970年起的毫秒数。

构造器|说明
:---|:---
Date ( year, month [ , date [ , hours [ , minutes [ , seconds [ , ms ] ] ] ] ] )|创建Date对象
Date ( value )|按时间值创建Date对象
Date ( )|按当前时间值创建Date对象

Date属性|说明
:---|:---
Date.now ( )|返回当前的UTC时间值
Date.parse ( string )|解析时间的字符串表示
Date.UTC ( year, month [ , date [ , hours [ , minutes [ , seconds [ , ms ] ] ] ] ] )|计算时间值.

Date.prototype属性|说明
:---|:---
Date.prototype.constructor|同Date
Date.prototype.getDate ( )|返回日期
Date.prototype.getDay ( )|返回周中的天
Date.prototype.getFullYear ( )|返回年份
Date.prototype.getHours ( )|返回小时
Date.prototype.getMilliseconds ( )|返回毫秒
Date.prototype.getMinutes ( )|返回分钟
Date.prototype.getMonth ( )|返回月
Date.prototype.getSeconds ( )|返回秒
Date.prototype.getTime ( )|返回时间值
Date.prototype.getTimezoneOffset ( )|返回时区差（分钟）
Date.prototype.getUTCDate ( )|返回UTC日期
Date.prototype.getUTCDay ( )|返回UTC日
Date.prototype.getUTCFullYear ( )|返回UTC年
Date.prototype.getUTCHours ( )|返回UTC小时
Date.prototype.getUTCMilliseconds ( )|返回UTC毫秒
Date.prototype.getUTCMinutes ( )|返回UTC分钟
Date.prototype.getUTCMonth ( )|返回UTC月
Date.prototype.getUTCSeconds ( )|返回UTC秒
Date.prototype.setDate ( date )|设置日子
Date.prototype.setFullYear ( year [ , month [ , date ] ] )|设置日子
Date.prototype.setHours ( hour [ , min [ , sec [ , ms ] ] ] )|设置时间
Date.prototype.setMilliseconds ( ms )|设置毫秒
Date.prototype.setMinutes ( min [ , sec [ , ms ] ] )|设置分钟
Date.prototype.setMonth ( month [ , date ] )|设置月份
Date.prototype.setSeconds ( sec [ , ms ] )|设置秒
Date.prototype.setTime ( time )|设置时间值
Date.prototype.setUTCDate ( date )|设置UTC日子
Date.prototype.setUTCFullYear ( year [ , month [ , date ] ] )|设置UTC年
Date.prototype.setUTCHours ( hour [ , min [ , sec [ , ms ] ] ] )|设置UTC小时
Date.prototype.setUTCMilliseconds ( ms )|设置UTC毫秒
Date.prototype.setUTCMinutes ( min [ , sec [ , ms ] ] )|设置UTC分钟
Date.prototype.setUTCMonth ( month [ , date ] )|设置UTC月份
Date.prototype.setUTCSeconds ( sec [ , ms ] )|设置UTC秒
Date.prototype.toDateString ( )|返回人类友好的日期的字符串表示
Date.prototype.toISOString ( )|返回包括各域的字符串表示
Date.prototype.toJSON ( key )|返回时间值的字符串表示
Date.prototype.toLocaleDateString ( [ reserved1 [ , reserved2 ] ] )|返回本地的日子的字符串表示
Date.prototype.toLocaleString ( [ reserved1 [ , reserved2 ] ] )|返回本地的字符串表示
Date.prototype.toLocaleTimeString ( [ reserved1 [ , reserved2 ] ] )|返回本地的时间的字符串表示
Date.prototype.toString ( )|返回日子的字符串表示
Date.prototype.toTimeString ( )|返回时间的字符串表示
Date.prototype.toUTCString ( )|返回人类友好的UTC字符串表示
Date.prototype.valueOf ( )|返回时间值

另外，转换Date对象为基本类型对象时，"default"视为"string"

### 文本

#### String

构造器|说明
String ( value )|构造String对象

属性|说明
:---|:---
String.fromCharCode ( ...codeUnits )|从代码单元生成字符串
String.fromCodePoint ( ...codePoints )|从代码点生成字符串
String.prototype|不可写，不可配置
String.raw ( template, ...substitutions )|根据模板代入各substitutions生成字符串

属性|说明
:---|:---
String.prototype.charAt ( pos )|返回指定位置的代码单元
String.prototype.charCodeAt ( pos )|返回指定位置的代码单元数值
String.prototype.codePointAt ( pos )|返回第pos个代码点
String.prototype.concat ( ...args )|串接
String.prototype.constructor|初始为String
String.prototype.endsWith ( searchString [ , endPosition ] )|返回是否结束于searchString
String.prototype.includes ( searchString [ , position ] )|返回是否包含searchString
String.prototype.indexOf ( searchString [ , position ] )|返回searchString首次出现位置
String.prototype.lastIndexOf ( searchString [ , position ] )|返回searchString最后出现位置
String.prototype.localeCompare ( that [ , reserved1 [ , reserved2 ] ] )|返回本地的字符串比较结果
String.prototype.match ( regexp )|返回是否匹配regexp
String.prototype.normalize ( [ form ] )|返回正规化其中form为"NFC"、"NFD"、"NFKC"、"NFKD"之一
String.prototype.repeat ( count )|返回重复count次得的字符串
String.prototype.replace (searchValue, replaceValue )|返回替换结果
String.prototype.search ( regexp )|返回regexp首次匹配位置
String.prototype.slice ( start, end )|返回子字符串并转换为String
String.prototype.split ( separator, limit )|拆解被separator分隔的子字符串数组，最多limit个
String.prototype.startsWith ( searchString [ , position ] )|返回是否从位置position起以searchString开始
String.prototype.substring ( start, end )|返回子字符串值
String.prototype.toLocaleLowerCase ( [ reserved1 [ , reserved2 ] ] )|返回本地的小写化
String.prototype.toLocaleUpperCase ([ reserved1 [ , reserved2 ] ] )|返回本地的大写化
String.prototype.toLowerCase ( )|返回小写化
String.prototype.toString ( )|返回字符串值
String.prototype.toUpperCase ( )|返回大写化
String.prototype.trim ( )|返回去掉两端空白的字符串
String.prototype.valueOf ( )|返回本字符串的值

另外String有不可写、不可配置的length属性表示代码单元数，还可以对代码点迭代。

#### RegExp

RegExp对象封闭正则表达式和一些标志。

属性|说明
:---|:---
RegExp.prototype|不可写、不可配置

属性|说明
:---|:---
RegExp.prototype.constructor|初始为RegExp
RegExp.prototype.exec ( string )|开始匹配并返回捕获组数组
RegExp.prototype.flags|返回标志字符串
RegExp.prototype.global|返回全局标志
RegExp.prototype.ignoreCase|返回大小写不敏感标志
RegExp.prototype.multiline|返回多行模式标志
RegExp.prototype.sticky|返回粘性标志
RegExp.prototype.test ( S )|返回S是否满足这正则表达式
RegExp.prototype.toString ( )|返回字符串表示
RegExp.prototype.unicode|返回unicode标志

RegExp对象还有不可配置的lastIndex属性表示下次运行的开始位置

### 数组

#### 数组

构造器|说明
:---|:---
Array ( )|创建长度为0的数组
Array (len)|创建指定长度的数组
Array (...items )|创建由指定元素组成的数组

属性|说明
:---|:---
Array.from ( items [ , mapfn [ , thisArg ] ] )|由类数组对象和转换构造数组
Array.isArray ( arg )|返回arg是否数组
Array.of ( ...items )|返回由指定元素组成的数组
Array.prototype|不可写、不可配置

属性|说明
:---|:---
Array.prototype.concat ( ...arguments )|返回串接各数组得的数组
Array.prototype.constructor|初始为%Array%.
Array.prototype.copyWithin (target, start [ , end ] )|复制指标从start到end的元素复制到指标target开始的位置
Array.prototype.entries ( )|返回键值对迭代器
Array.prototype.every ( callbackfn [ , thisArg ] )|返回thisArg.callbackfn是否对所有元素返回true（另用指标和数组对象作参数）
Array.prototype.fill (value [ , start [ , end ] ] )|用value填充
Array.prototype.filter ( callbackfn [ , thisArg ] )|返回对thisArg.callbackfn返回true的元素组成的子数组（另用指标和数组对象作参数）
Array.prototype.find ( predicate [ , thisArg ] )|返回对thisArg.callbackfn返回true的首个元素（另用指标和数组对象作参数）
Array.prototype.findIndex ( predicate [ , thisArg ] )|返回对thisArg.callbackfn返回true的首个元素（另用指标和数组对象作参数）对应指标（没有则-1）
Array.prototype.forEach ( callbackfn [ , thisArg ] )|对每个元素、指标和当前对象调用thisArg.callbackfn
Array.prototype.includes ( searchElement [ , fromIndex ] )|返回用值比较的searchElement是否出现
Array.prototype.indexOf ( searchElement [ , fromIndex ] )|返回用===比较的searchElement首次出现位置（不存在则-1）
Array.prototype.join (separator)|返回用指定分隔符（默认逗号）的字符串表示
Array.prototype.keys ( )|返回键迭代器
Array.prototype.lastIndexOf ( searchElement [ , fromIndex ] )|返回用===比较的searchElement最后出现位置（不存在则-1）
Array.prototype.map ( callbackfn [ , thisArg ] )|返回由各元素的像组成的数组，其中thisarg.callbackfn用元素、指标和数组对象作参数
Array.prototype.pop ( )|返回弹出元素
Array.prototype.push ( ...items )|依次推入各参数
Array.prototype.reduce ( callbackfn [ , initialValue ] )|左折叠，对每个元素先前值、当前元素、指标和数组对象作参数调用callbackfn
Array.prototype.reduceRight ( callbackfn [ , initialValue ] )|右折叠
Array.prototype.reverse ( )|反转元素顺序
Array.prototype.shift ( )|移除并返回首个元素
Array.prototype.slice (start, end)|返回切片
Array.prototype.some ( callbackfn [ , thisArg ] )|返回thisArg.callbackfn是否对某个元素返回true（另用指标和数组对象作参数）
Array.prototype.sort (comparefn)|排序
Array.prototype.splice (start, deleteCount, ...items )|把从指标start起deleteCount个元素换成items，返回被换的元素数组
Array.prototype.toLocaleString ( [ reserved1 [ , reserved2 ] ] )|返回本地的字符串表示
Array.prototype.toString ( )|返回本地的字符串表示
Array.prototype.unshift ( ...items )|把各items加入到前面
Array.prototype.values ( )|返回值迭代器

数组对象还有属性length，并且可迭代。

#### 类型化数组

构造器|元素类型|元素大小|描述|对应的C类型
:---|:---|:---|:---|:---
Int8Array|Int8| 1 | 8位的2的补码|signed char
Uint8Array|Uint8| 1|8位无符号整数（转换为取模）| unsigned char
Uint8ClampedArray | Uint8C| 1 | 8位无符号整数（转换为截断） |unsigned char
Int16Array |Int16| 2| 16位的2的补码| short
Uint16Array | Uint16| 2|8位无符号整数| unsigned short
Int32Array |Int32|4|32位的2的补码|int
Uint32Array | Uint32| 4|32位无符号整数|unsigned int
Float32Array|Float32|4|IEEE单精度浮点数|float
Float64Array|Float64|8|IEEE双精度浮点数|double

以下用TypedArray指代上述的构造器。

%TypedArray%是各TypedArray构造器都继承的内部对象，它的构造器总抛出异常。

属性|说明
:---|:---
%TypedArray%.from ( source [ , mapfn [ , thisArg ] ] )|用源和转换构造类型化数组
%TypedArray%.of ( ...items )|构造类型化数组
%TypedArray%.prototype|不可写、不可配置

属性|说明
:---|:---
get %TypedArray%.prototype.buffer|返回已读缓冲
get %TypedArray%.prototype.byteLength|返回字节长度
get %TypedArray%.prototype.byteOffset|返回字节偏移
%TypedArray%.prototype.constructor|初始为%TypedArray%
%TypedArray%.prototype.copyWithin (target, start [ , end ] )|类似Array.prototype.copyWithin
%TypedArray%.prototype.entries ( )|返回键值对迭代器
%TypedArray%.prototype.every ( callbackfn [ , thisArg ] )类似Array.prototype.every
%TypedArray%.prototype.fill (value [ , start [ , end ] ] )|类似Array.prototype.fill
%TypedArray%.prototype.filter ( callbackfn [ , thisArg ] )|类似Array.prototype.filter
 %TypedArray%.prototype.find (predicate [ , thisArg ] )|类似Array.prototype.find
 %TypedArray%.prototype.findIndex ( predicate [ , thisArg ] )|类似Array.prototype.findIndex
 %TypedArray%.prototype.forEach ( callbackfn [ , thisArg ] )|类似Array.prototype.forEach
 %TypedArray%.prototype.indexOf (searchElement [ , fromIndex ] )|类似Array.prototype.indexOf
 %TypedArray%.prototype.includes ( searchElement [ , fromIndex ] )|类似Array.prototype.includes
 %TypedArray%.prototype.join ( separator )|串接为字符串
 %TypedArray%.prototype.keys ( )|返回数组键迭代器
 %TypedArray%.prototype.lastIndexOf ( searchElement [ , fromIndex ] )|返回指定元素的最后出现位置
 get %TypedArray%.prototype.length|长度
 %TypedArray%.prototype.map ( callbackfn [ , thisArg ] )|映射
 %TypedArray%.prototype.reduce ( callbackfn [ , initialValue ] )|左折叠
 %TypedArray%.prototype.reduceRight ( callbackfn [ , initialValue ] )|右折叠
 %TypedArray%.prototype.reverse ( )|反转
 %TypedArray%.prototype.set ( overloaded [ , offset ])|设置
 %TypedArray%.prototype.slice ( start, end )|取子数组的复制品
 %TypedArray%.prototype.some ( callbackfn [ , thisArg ] )|类似于Array.prototype.some
 %TypedArray%.prototype.sort ( comparefn )|排序
 %TypedArray%.prototype.subarray( begin, end )|取子数组
 %TypedArray%.prototype.toLocaleString ([ reserved1 [ , reserved2 ] ])|类似Array.prototype.toLocaleString
 %TypedArray%.prototype.toString ( )|同%TypedArray%.prototype.toString
 %TypedArray%.prototype.values ( )|返回数组值迭代器

另外，TypedArray可迭代

构造器|说明
:---|:---
TypedArray ( )|构造长度0的类型化数组
TypedArray ( length )|构造指定长度的类型化数组
TypedArray ( typedArray )|由现有类型化数组构造类型化数组
TypedArray ( object )|由迭代器构造类型化数组
TypedArray ( buffer [ , byteOffset [ , length ] ] )|由数组似的对象的一部分构造类型化数组

属性|说明
:---|:---
TypedArray.BYTES_PER_ELEMENT|每个元素占的字节数，不可写、不可配置
TypedArray.prototype|不可写、不可配置

属性|说明
:---|:---
TypedArray.prototype.BYTES_PER_ELEMENT|每个元素占的字节数，不可写、不可配置
TypedArray.prototype.constructor|对应内部对象 %TypedArray%

### 映射表

键用SameValueZero区分

#### Map

构造器|说明
:---|:---
Map ( [ iterable ] )|构造Map

属性|说明
:---|:---
Map.prototype|不可写、不可配置

属性|说明
:---|:---
Map.prototype.clear ( )|清除所有条目
Map.prototype.constructor|
Map.prototype.delete ( key )|删除key对应条目
Map.prototype.entries ( )|返回条目迭代器
Map.prototype.forEach ( callbackfn [ , thisArg ] )|对每个条目，用值、键、此对象调用thisArg.callbackfn
Map.prototype.get ( key )|返回key对应的值
Map.prototype.has ( key )|返回是否有条目以key为键
Map.prototype.keys ( )|返回键迭代器
Map.prototype.set ( key, value )|设置键值对
Map.prototype.size|返回条目数
Map.prototype.values ( )|返回键值对迭代器

Map对象可以迭代。

#### Set

构造器|说明
:---|:---
Set ( [ iterable ] )|构造Set

属性|说明
:---|:---
Set.prototype|不可写、不可配置

属性|说明
:---|:---
Set.prototype.add ( value )|加入元素
Set.prototype.clear ( )|清除所有元素
Set.prototype.constructor|
Set.prototype.delete ( value )|删除元素
Set.prototype.entries ( )|返回条目迭代器
Set.prototype.forEach ( callbackfn [ , thisArg ] )|对每个条目，用元素、元素、此对象调用thisArg.callbackfn
Set.prototype.has ( key )|返回是否有条目以key为键
Set.prototype.keys ( )|返回键迭代器
Set.prototype.size|返回条目数
Set.prototype.values ( )|返回键值对迭代器

Set对象可以迭代。

#### WeakMap

构造器|说明
:---|:---
WeakMap ( [ iterable ] )|构造Map

属性|说明
:---|:---
WeakMap.prototype|不可写、不可配置

属性|说明
:---|:---
WeakMap.prototype.constructor|
WeakMap.prototype.delete ( key )|删除key对应条目
WeakMap.prototype.get ( key )|返回key对应的值
WeakMap.prototype.has ( key )|返回是否有条目以key为键
WeakMap.prototype.set ( key, value )|设置键值对

#### WeakSet

构造器|说明
:---|:---
WeakSet ( [ iterable ] )|构造Set

属性|说明
:---|:---
WeakSet.prototype|不可写、不可配置

属性|说明
:---|:---
Set.prototype.add ( value )|加入元素
Set.prototype.constructor|
Set.prototype.delete ( value )|删除元素
Set.prototype.has ( key )|返回是否有条目以key为键

### 结构化数据

#### ArrayBuffer

构造器|说明
:---|:---
ArrayBuffer ( length )|返回有length字节的ArrayBuffer

属性|说明
:---|:---
ArrayBuffer.isView ( arg )|返回有否被查看
ArrayBuffer.prototype|不可写、不可配置

属性|说明
:---|:---
ArrayBuffer.prototype.byteLength|返回字节数
ArrayBuffer.prototype.constructor|
ArrayBuffer.prototype.slice ( start, end )|返回由指定范围中字节组成的新ArrayBuffer

#### DataView

构造器|说明
:---|:---
DataView (buffer, byteOffset, byteLength )|构造基于buffer中从byteOffset开始byteLength个字节的DataView

属性|说明
:---|:---
DataView.prototype.buffer|返回底层的ArrayBuffer
DataView.prototype.byteLength|返回字节数
DataView.prototype.byteOffset|返回依稀量
DataView.prototype.constructor|
DataView.prototype.getFloat32 ( byteOffset [ , littleEndian ] )|返回指定位置处的Float32值
DataView.prototype.getFloat64 ( byteOffset [ , littleEndian ] )|返回指定位置处的Float32值
DataView.prototype.getInt8 ( byteOffset )|返回指定位置处的Int8值
DataView.prototype.getInt16 ( byteOffset [ , littleEndian ] )|返回指定位置处的Int16值
DataView.prototype.getInt32 ( byteOffset [ , littleEndian ] )|返回指定位置处的Int32值
DataView.prototype.getUint8 ( byteOffset )|返回指定位置处的Uint8值
DataView.prototype.getUint16 ( byteOffset [ , littleEndian ] )|返回指定位置处的Uint16值
DataView.prototype.getUint32 ( byteOffset [ , littleEndian ] )|返回指定位置处的Uint32值
DataView.prototype.setFloat32 ( byteOffset, value [ , littleEndian ] )|在指定位置开始处放置指定Float32值
DataView.prototype.setFloat64 ( byteOffset, value [ , littleEndian ] )|在指定位置开始处放置指定Float64值
DataView.prototype.setInt8 ( byteOffset, value )|在指定位置开始处放置指定Int8值
DataView.prototype.setInt16 ( byteOffset, value [ , littleEndian ] )|在指定位置开始处放置指定Int16值
DataView.prototype.setInt32 ( byteOffset, value [ , littleEndian ] )|在指定位置开始处放置指定Int32值
DataView.prototype.setUint8 ( byteOffset, value )|在指定位置开始处放置指定Uint8值
DataView.prototype.setUint16 ( byteOffset, value [ , littleEndian ] )|在指定位置开始处放置指定Uint16值
DataView.prototype.setUint32 ( byteOffset, value [ , littleEndian ] )|在指定位置开始处放置指定Uint32值

#### JSON

属性|说明
:---|:---
JSON.parse ( text [ , reviver ] )|解析JSON文本text，reviver为接受键和值两个参数的函数返回修改后的值（undefined表示删除条目）
JSON.stringify ( value [ , replacer [ , space ] ] )|返回value的JSON表示

### 控制抽象

#### 迭代

约定迭代器:
- 属性next值为一个返回迭代结果的函数，并且一旦返回过done属性为true的迭代结果，以后也要返回done属性为true的迭代结果
- 可选属性return值为一个返回迭代结果的函数，在不会再调用next时被调用，通常返回done属性为true的迭代结果，其值则为参数
- 可选属性throw值为一个返回迭代结果的函数，用于通知错误条件被发现，通常抛出参数或通常返回done属性为true的迭代结果

约定迭代结果:
- done属性表示是否没有可用值（未定义这属性表示false）
- value属性表示当前迭代元素值（若非done）或返回值（没有则undefined）

#### GeneratorFunction

构造器|说明
:---|:---
GeneratorFunction (p1, p2, ... , pn, body)|返回以各p为形参、body为体的生成器函数

属性|说明
:---|:---
GeneratorFunction.length|1，不可写
GeneratorFunction.prototype|不可写、不可配置

属性|说明
:---|:---
GeneratorFunction.prototype.constructor|不可写
GeneratorFunction.prototype.prototype|不可写

另外，GeneratorFunction的实例有属性length、name、prototype

#### Generator

属性|说明
:---|:---
25.3.1.1 Generator.prototype.constructor|不可写
25.3.1.2 Generator.prototype.next ( value )|返回下一个值

#### Promise

构造器|说明
:---|:---
Promise ( executor )|构造以executor为延迟操作的Promise，executor被调用时分别以两个单参函数为实参，分别用于报告顺利完成和失败

属性|说明
:---|:---
Promise.all ( iterable )|返回一个Promise要么由各参数的满足值组成的数组满足，要么拒绝
Promise.prototype|不可写、不可配置
Promise.race ( iterable )|返回一个Promise，求值所有Promise但结果与首个Promise同
Promise.reject ( r )|返回一个会以r拒绝的Promise
Promise.resolve ( x )|返回一个会以x接受的Promise

属性|说明
:---|:---
Promise.prototype.catch ( onRejected )|进行延迟操作并在失败时执行对应函数
Promise.prototype.constructor|
Promise.prototype.then ( onFulfilled, onRejected )|进行延迟操作并在成功或失败时执行对应函数

### 反射

#### Reflect

属性|说明
:---|:---
Reflect.apply ( target, thisArgument, argumentsList )|调用target
Reflect.construct ( target, argumentsList [ , newTarget ] )|构造对象
Reflect.defineProperty ( target, propertyKey, attributes )|定义属性
Reflect.deleteProperty ( target, propertyKey )|删除属性
Reflect.get ( target, propertyKey [ , receiver ])|返回属性
Reflect.getOwnPropertyDescriptor ( target, propertyKey )|返回属性描述
Reflect.getPrototypeOf ( target )|返回原型
Reflect.has ( target, propertyKey )|返回是否有具指定键的属性
Reflect.isExtensible (target)|返回target是否可扩展
Reflect.ownKeys ( target )|返回自身属性的键数组
Reflect.preventExtensions ( target )|防止扩展
Reflect.set ( target, propertyKey, V [ , receiver ] )|设置属性
Reflect.setPrototypeOf ( target, proto )|设置原型

构造器|说明
:---|:---
Proxy ( target, handler )

#### Proxy

属性|说明
:---|:---
Proxy.revocable ( target, handler )|创建可调用的代理对象

## 其它对象

### HTML DOM

由于JavaScript最常用于网页中的客户端脚本，经常要通过DOM与HTML文档打交道，所以经常用到有关的API。具体情况请参考W3和浏览器厂商的文档：
- <http://www.w3.org/DOM/DOMTR>

### JavaScript框架

此外，JavaScript还有很多有用的第三方库，例如：
- [JQuery](http://www.jquery.com)提供了访问DOM、事件处理和AJAX等的一些便捷的方式

