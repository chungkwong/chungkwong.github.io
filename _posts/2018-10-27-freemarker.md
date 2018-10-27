---
title:  "Freemarker模板引擎速查"
layout: post
tags: java
---

[Apache Freemarker](https://freemarker.apache.org/)是JVM平台上一个比较流行的通用模板引擎，适合用于生成网页、 邮件、 配置文件等代码。

## 简介

在Web开发中，我们经常需要动态生成网页（HTML文件）以便在响应中包含与请求有关的信息（如用户名、 搜索结果）。这时我们有两种方法：
- 硬编码代码生成的规则。例如：`"亲爱的"+user.getName()+"上午好"`。这种方法对于生成简单的文本时可能比较方便，但当规模变大后就容易失控，而且用于生成HTML或SQL代码时往往成为注入攻击的温床。
- 套用模板。例如：`java.text.MessageFormat.format("亲爱的{0}上午好",user.getName())`。这里`"亲爱的{0}上午好"`就是一个模板，而`user.getName()`则是模型，这种方法体现了MVC（模型-视图-控制器）模式的原则，有利于分离关注点并容许专门人员分别负责展现什么和怎么展示，提高了可维护性。当然`java.text.MessageFormat`的模板语言表达力对于许多用途而言太弱，但freemarker之类的模板引擎克服了这个局限性。JVM平台上其它通用模板引擎包括：
    - [Apache Velocity](http://velocity.apache.org/)
    - [Thymeleaf](https://www.thymeleaf.org/)
    - [StringTemplate](http://www.stringtemplate.org/)

为了使用freemarker，首先我们需要加入对freemarker库的依赖，例如使用Maven的话在`pom.xml`中加入：

```
<dependency>
	<groupId>org.freemarker</groupId>
	<artifactId>freemarker</artifactId>
	<version>2.3.28</version>
</dependency>
```

然后我们编写一个简单的模板`src/main/resources/com/github/chungkwong/template/example.ftl`：

```
亲爱的${name}上午好
```

接着我们演示如何在java程序`src/main/java/com/github/chungkwong/template/Main.java`中使用上述模板：

```java
package com.github.chungkwong.template;
import freemarker.template.*;
import java.io.*;
import java.util.*;
public class Main{
	public static void main(String[] args) throws IOException,TemplateException{
		//创建配置类，配置类应尽可能重用，不必再创建以提高性能
		Configuration configuration=new Configuration(Configuration.getVersion());
		//设置模板所在目录，另外可改为
		// setDirectoryForTemplateLoading(File)
		// setClassLoaderForTemplateLoading(ClassLoader, String)
		configuration.setClassForTemplateLoading(Main.class,"");
		//取得模板  
		Template template=configuration.getTemplate("example.ftl");
		//准备模型
		Map<String,Object> model=new HashMap<>();
		model.put("name","陈大文");
		//套用模板并把结果输出到一个流
		template.process(model,new OutputStreamWriter(System.out));
	}
}
```

运行上述程序应该得到输出`亲爱的陈大文上午好`。

## 模型

模型在内部表示为`TemplateModel`子类型的对象。幸运的是，`freemarker.template.DefaultObjectWrapper`的`TemplateModel handleUnknownType(final Object obj) throws TemplateModelException`方法通常能把Java模型对象自动转换为内部对象，我们很少要清晰区分内部对象。不过如果有兴趣也可以通过`TemplateModel`的子接口了解其类型系统：
- `AdapterTemplateModel`包装动态类型语言的对象
- `TemplateBooleanModel`对应于布尔值
- `TemplateCollectionModel`对应于集合，它的子接口`TemplateCollectionModelEx`支持查询元素数
- `TemplateDateModel`对应于日期和/或时间
- `TemplateDirectiveModel`对应于模板可使用的指令，在需要自定义指令时可覆盖方法`void execute(Environment env,Map params, TemplateModel[] loopVars,TemplateDirectiveBody body) throws TemplateException, IOException`
- `TemplateHashModel`对应于哈希表，它的子接口`TemplateHashModelEx`和`TemplateHashModelEx2`提供迭代键值对的方法
- `TemplateMarkupOutputModel`对于于不应再转义就能输出的代码
- `TemplateMethodModel`对应于模板可调用的方法，它的子接口`TemplateMethodModelEx`要求实参以`TemplateModel`而非`String`传入方法由`TemplateModel exec(List args) throws TemplateModelException`给出的自定义方法
- `TemplateModelWithAPISupport`
- `TemplateNodeModel`对应于XML文档中的结点，它的子接口`TemplateNodeModelEx`支持查找相邻兄弟结点
- `TemplateNumberModel`对应于数值
- `TemplateScalarModel`对应于字符串
- `TemplateSequenceModel`对应于序列
- `WrapperTemplateModel`包装其它Java对象

## 模板

### 语法

模板中形如`<#-- 注释内容 -->`的是注释（注释内容中不能含`-->`），会被忽略。注意注释也可以出现在表达式或指令中。

模板中其余部分由以下构造连接而成：

构造|说明
---|---
`${表达式}`|输出表达式的值
`$变量名`|输出变量的值，其中变量名只可以包含字母(也可以是非拉丁文)、 数字(也可以是非拉丁数字)、 下划线 、 美元符号、 at符号，且首个字符不能为ASCII数字，变量名不能是保留字：`true`、 `false`、 `gt`、 `gte`、 `lt`、 `lte`、 `as`、 `in`、 `using`
`<#指令名 参数>`|开始指令
`</#指令名>`|结束指令（不是所有指令都需要结束）
其它字符|原样输出

### 引用

#### 作用域
    
和其它语言一样，较局部变量会屏蔽较全局的同名变量。从内而外依次为：
1. `Environment` 中变量：
    1. 循环创建在循环变量集合
    2. 宏中宏参数或由`local`指令创建的局部变量集合
    3. 由`assign`指令创建的当前的命名空间中
    4. 由`global`指令创建的变量集合中，它们在所有命名空间可见
2. 传递给`process`方法的模型对象中变量
3. 在 `Configuration` 对象的共享变量

#### 特殊变量

特殊变量|值
---|---
`.current_template_name`|当前所在的模板名称
`.data_model`|模型哈希表
`.error`|在 `recover` 指令体中表示错误信息
`.globals`|全局变量哈希表
`.lang`|当前语言如`en`
`.locale`|当前区域如`en_US`
`.locale_object`|`java.util.Locale`对象
`.locals`|局部变量哈希表
`.main`|主命名空间哈希表
`.main_template_name`|顶级模板的名称
`.namespace`|当前命名空间哈希表
`.node`|当前结点
`.now`|当前的日期时间
`.output_encoding`|当前输出字符集
`.url_escaping_charset`|用于URL转义的字符集
`.vars`|变量哈希表
`.version`|FreeMarker 版本号的字符串形式


### 指令

指令|用途
---|---
`<#assign 变量名1=值1 变量名2=值2 ... 变量名N=值N>`|赋值
`<#assign 变量名1=值1 变量名2=值2 ... 变量名N=值N... in 名字空间>`|
`<#assign 变量名>块</#assign>`|
`<#assign 变量名 in 名字空间>块</#assign>`|
`<#attempt>尝试块<#recover>错误块</#attempt>`|执行`尝试块`，失败的话改为执行`错误块`
`<#compress>块</#compress>`|移除块开始、 结尾的空白并把连续的空白替换为一个空白字符
`<#escape 标识符 as 表达式>块</#escape>`|在块内默认把插值按指定表达式转义
`<#noescape>块</#noescape>`|在块内默认不转义
`<#flush>`|冲洗缓冲
`<#ftl 参数1=值1 参数2=值2 ... 参数N=值N>`|设置参数为常量表达式，其中`encoding`值为字符串、 `strip_whitespace`值为布尔值、 `strip_text`值为布尔值、 `strict_syntax`值为布尔值、 `ns_prefixes`值为把命名空间前缀到位置的哈希表、 `attributes`值为模板属性的哈希表
`<#function 名字 参数1 参数2 ... 参数N>其它<#return 返回表达式>其它</#function>`|声明一个值为方法的变量
`<#function 名字 参数1 参数2 ... 参数N...>其它<#return 返回表达式>其它</#function>`|声明一个值为方法的变量，方法最后一个参数接收余下实参组成的序列
`<#global 变量名1=值1 变量名2=值2 ... 变量名N=值N>`|定义全局变量
`<#global 变量名>块</#global>`|定义全局变量
`<#if 条件表达式>块<#elseif 条件表达式>块...<#else>块</#if>`|分支，`elseif`和`else`可选
`<#import 路径 as 名字空间>`|把指定路径的库引入到指定名字空间
`<#include 路径 选项...>`|把指定路径的文件插入到当前位置，其中选项可以为`encoding=字符串表达式`、 `parse=布尔值表达式`或`ignore_missing=布尔值表达式`
`<#list 序列 as 项>循环体<sep>分隔<#else>序列空时用的块</#list>`|迭代列表，`sep`、 `else`可选，其中可用`<#break>`跳出迭代
`<#list 序列>序列非空时用的块<#items as 项目>循环体<sep>分隔</#items>序列非空时用的块<#else>序列空时用的块</#list>`|迭代列表，`sep`、 `else`可选，其中可用`<#break>`跳出迭代
`<#local 变量名1=值1 变量名2=值2 ... 变量名N=值N>`|定义局部变量
`<#local 变量名>块</#global>`|定义局部变量
`<#macro 名 参数1 参数2 ... 参数N>块<#nested loopvar1, loopvar2, ..., loopvarN>块<#return>块</#macro>`|定义宏
`<#noparse>块</#noparse>`|忽略块中指令
`<#nt>`|禁止本行消除空白
`<#setting 属性名=值表达式>`|设置属性
`<#stop>`|中止处理模板
`<#stop 字符串表达式>`|中止处理模板
`<#switch 表达式><#case 值1>块<#break>...<#case 值N>块<#break><#default>块</#switch>`|按表达式的值分支，其中`break`和`default`可选
`<#t>`|忽略本行首尾所有空白
`<#lt>`|忽略本行首所有空白
`<#rt>`|忽略本行尾所有空白
`<#visit 结点 using 名字空间>`|访问结点，即以它为参数调用同名的指令
`<#visit 结点>`|访问结点，即以它为参数调用同名的指令
`<#recurse 结点 using 名字空间>`|访问所有子结点
`<#recurse 结点>`|访问所有子结点
`<#recurse using 名字空间>`|访问当前结点的所有子结点
`<#recurse>`|访问当前结点的所有子结点
`<#fallback>`|在更多名字空间找结点处理器
`<@指令 参数1=值1 参数2=值2 ... 参数N=值N/>`|用户定义指令

其中可设置的属性有：

属性|含义
---|---
`locale`|区域字符串
`number_format`|数值格式：`number`(默认的)、 `computer`、 `currency`、  `percent`或Java用的格式
`boolean_format`|以逗号分隔的一对字符串来分别展示 `true` 和 `false` 值
`date_format`、 `time_format`、 `datetime_format`|日期时间格式，可以是`SimpleDateFormat`中格式，或者`short`、 `medium`、 `long`、 `full`、 `xs`（XML Schema 格式）、 `iso`（ISO 8601:2004 格式）
`time_zone`|时区名（同Java）
`sql_date_and_time_time_zone`|为仅日期或仅时间值加上的时区
`url_escaping_charset`|用于URL转义的字符集
`output_encoding`|输出编码名
`classic_compatible`|是否兼容经典模式


### 表达式

Freemarker的表达式如下构成：

- 常量
    - 字符串由`'`或`"`包围，其中可用`\`转义，引号前加`r`可禁用转义和插值
    - 数值格式如`123.45`
    - 布尔值：`true`或`false`
    - 序列形如`[元素,...,元素]`
    - 哈希表形如`{字符串键表达式:值表达式, ...}`
- 括号表达式`(表达式)`可用于控制求值顺序
- 引用
    - 变量的值：`变量名`
    - 哈希表中的值： `表.键`、 `表["键"]`
    - 序列中元素：`序列[索引]`
    - 序列中子序列：`序列[范围]`
    - 字符串中字符：`字符串[索引]`
    - 字符串中子字符串：`字符串[范围]`
    - 默认值：`表达式!默认值表达式`
    - 默认值为空序列/字符串/哈希表：`表达式!`
    - 变量存在性：`表达式??`
    - 方法调用：`方法表达式(参数表达式,...)`
    - 内置函数：`表达式?函数`
    - 内置函数：`表达式?函数(参数表达式,...)`
- 前缀运算符
    - 正：`+表达式`
    - 负：`-表达式`
    - 否定：`!表达式`
- 积性数值运算符
    - 积：`数值表达式*数值表达式`
    - 商：`数值表达式/数值表达式`
    - 余：`数值表达式%数值表达式`
- 和性数值运算符
    - 和：`数值表达式+数值表达式`
    - 字符串/序列/哈希表连接：`表达式+表达式`
    - 差：`数值表达式-数值表达式`
- 范围表达式
    - `start..end`表示一个范围（包含`start`和`end`）
    - `start..<end`或`start..!end`表示一个范围（包含`start`但不包含`end`）
    - `start..*length`表示从`start`开始长度为`length`绝对值的范围
    - `start..`表示从`start`开始的无穷序列
- 关系表达式
    - 小于检测：`表达式<表达式`或`表达式 lt 表达式`
    - 小于等于检测：`表达式<=表达式`或`表达式 lte 表达式`
    - 大于检测：`表达式>表达式`或`表达式 gt 表达式`
    - 大于等于检测：`表达式>=表达式`或`表达式 gte 表达式`
- 相等性表达式
    - 相等检测：`表达式==表达式`或`表达式=表达式`
    - 不等检测：`表达式!=表达式`
- 逻辑与：`表达式&&表达式`
- 逻辑与：`表达式||表达式`

转义序列|含义
---|---
`\"`|引号 (u0022)
`\'`|单引号(又称为撇号) (u0027)
`\{`|起始花括号：{
`\\`|反斜杠 (u005C)
`\n`|换行符 (u000A)
`\r`|回车 (u000D)
`\t`|水平制表符 (u0009)
`\b`|退格 (u0008)
`\f`|换页 (u000C)
`\l`|小于号
`\g`|大于号
`\a`|`&`
`\x十六进制数`|Unicode 码

### 内置函数

以下简单介绍各内置函数的用途：

函数|参数|含义
---|---|---
`abs`||绝对值
`ancestors`||结点的祖先序列（从父到根）
`api.方法`||API
`boolean`||字符串转换为布尔值
`byte`||用byte作内部表示
`c`||数字或布尔值转换为字符串
`cap_first`||首字母大写
`capitalize`||大写化
`ceiling`||上取整
`children`||子结点序列
`chop_linebreak`||没有的话行末插入换行
`chunk`|子序列最大长度|把序列转换为子序列的序列
`contains`|子串|检测是否包含
`counter`||当前迭代索引（1开始）
`date`|可选的格式|日期或字符串转换为日期
`date_if_unknown`||不确定时定为日期
`datetime`|可选的格式|日期或字符串转换为日期时间
`datetime_if_unknown`||不确定时定为日期时间
`double`||用double作内部表示
`ends_with`|子串|检测后缀
`ensure_ends_with`|子串|检测后缀并在否定时加上后缀
`ensure_starts_with`|子串|检测前缀并在否定时加上前缀
`ensure_starts_with`|正则表达式,子串,可选的标志|检测前缀并在否定时加上前缀
`eval`||求值表达式
`first`||首个元素
`floor`||下取整
`groups`||匹配的捕获组
`float`||用float作内部表示
`has_api.方法`||是否有API
`has_content`||是否”空“
`has_next`||是否不能迭代下一项
`html`||按HTML格式转义
`index`||换代索引
`index_of`|子串|首次出现位置或-1
`index_of`|子串,起点|首次出现位置或-1
`int`||用int作内部表示
`interpret`||把模板解析为指令
`item_cycle`|参数,...|在各次迭代中轮流返回各参数
`item_parity`||在各次迭代中轮流返回`"odd"`或`"even"`
`item_parity_cap`||在各次迭代中轮流返回`"Odd"`或`"Even"`
`is_even_item`||换代索引是否偶数
`is_first`||是否正迭代首项
`is_infinite`||是否无穷
`is_last`||是否正迭代最后一项
`is_nan`||是否NaN
`is_odd_item`||换代索引是否奇数
`is_类型`||是否指定类型，其中类型可为`string`、 `number`、 `boolean`、 `date`、 `date_like`、 `date_only`、 `time`、 `datetime`、 `unknown_date_like`、 `method`、 `transform`、 `macro`、 `hash`、 `hash_ex`、 `sequence`、 `collection`、 `collection_ex`、 `enumerable`、 `indexable`、 `directive`、 `node`
`iso`|可选的时区|把日期和或时间转换为字符串
`iso_选项`|可选的时区|把日期和或时间转换为字符串，其中选项由可选的时区`iso`或`local`；精度`h`、 `m`、 `ms`组成；忽略时区`nz`，用`_`分隔
`j_string`||按Java字符串格式转义字符串
`join`|分隔字符串|把序列串接为字符串
`js_string`||按JavaScript字符串格式转义字符串
`json_string`||按JSON字符串格式转义字符串
`keep_after`|子串,可选的标志|仅保留子串首个匹配后的字符串
`keep_after_last`|子串,可选的标志|仅保留子串最后一个匹配后的字符串
`keep_before`|子串,可选的标志|仅保留子串首个匹配前的字符串
`keep_before_last`|子串,可选的标志|仅保留子串最后一个匹配后的字符串
`keys`||键序列
`last`||最后一个元素
`last_index_of`|子串|最后出现位置或-1
`last_index_of`|子串,起点|最后出现位置或-1
`left_pad`|长度|用空格在开始处填充字符串到指定长度
`left_pad`|长度,填充字符|在开始填充字符串到指定长度
`length`||字符串长度
`long`||用long作内部表示
`lower_abc`||把数字转换为电子表格式的小写列号
`lower_case`||小写化
`matches`|正则表达式,可选的标志|匹配正则表达式
`namespace`||宏或函数对应的名字空间
`new`|构造器参数|创建指定类对象
`node_namespace`||结点名字空间
`node_name`||结点名
`node_type`||结点类型：`"attribute"`、 `"text"`、 `"comment"`、 `"document_fragment"`、 `"document"`、 `"document_type"`、 `"element"`、 `"entity"`、 `"entity_reference"`、 `"notation"`、 `"pi"`
`number`||字符串转换为数字
`number_to_date`||数字转换为日期
`number_to_datetime`||数字转换为日期时间
`number_to_time`||数字转换为时间
`parent`||父结点
`replace`|子串,替换,可选的标志|替换全部指定子串
`remove_beginning`|前缀|移除指定前缀
`remove_ending`|后缀|移除指定后缀
`reverse`||反序的序列
`right_pad`|长度|用空格在结束处填充字符串到指定长度
`right_pad`|长度,填充字符|在结束处填充字符串到指定长度
`round`||取整
`root`||根结点
`rtf`||RTF转义
`short`||用short作内部表示
`size`||序列元素数
`sort`||升序排序序列
`seq_contains`|元素|是否出现
`seq_index_of`|元素|首次出现的下标或-1
`seq_last_index_of`|元素|最后出现的下标或-1
`sort_by`|用于排序的键序列|升序排序哈希表序列
`split`|分隔,可选的标志|分割字符串
`starts_with`|子串|检测前缀
`string`|可选的格式|把字符串、 数值、 布尔值、 日期、 日期时间、 时间转换为字符串
`string.computer`||把数值转换为字符串
`string.currency`||把数值转换为字符串
`string.number`||把数值转换为字符串
`string.percent`||把数值转换为字符串
`string.short`||把日期时间转换为字符串
`string.medium`||把日期时间转换为字符串
`string.long`||把日期时间转换为字符串
`string.full`||把日期时间转换为字符串
`string.xs`||把日期时间转换为字符串
`string.iso`||把日期时间转换为字符串
`switch`|值1,结果1,...,默认值|按值选结果
`then`|真时的值,假时的值|按真值选择
`time`|可选的格式|字符串/日期/日期时间/时间转换为时间
`time_if_unknown`||不确定时定为时间
`trim`||去除首尾空白
`uncap_first`||首字母小写
`upper_abc`||把数字转换为电子表格式的大写列号
`upper_case`||大写化
`url`||URL转义
`url`|字符集|URL转义
`url_path`||URL转义（保留`/`）
`url_path`|字符集|URL转义（保留`/`）
`values`||值序列
`word_list`||字符串分割为单词
`xhtml`||XHTML转义
`xml`||XML转义

其中标志可以为：

标志|含义
---|---
`i`|大小写不敏感
`f`|只处理第一个匹配
`r`|正则表达式
`m`|多行模式
`s`|`.`匹配任意字符（含行终止符）
`c`|允许正则表达式中的空白和注释


## 配置

`Configuration`对象有一些配置选项，可用以下方法设置（另外可用对应的get、 is或unset方法读取或撤销）：

方法|用途
---|---
`void setAllSharedVariables(TemplateHashModelEx hash)`|设置多个共享变量
`void  setAttemptExceptionReporter(AttemptExceptionReporter attemptExceptionReporter)`|设置`#attempt`块异常处理器
`void  setAutoEscapingPolicy(int autoEscapingPolicy)`|设置是否按输出格式自动转义
`void  setCacheStorage(CacheStorage cacheStorage)`|设置缓存空间
`void  setClassForTemplateLoading(java.lang.Class resourceLoaderClass, java.lang.String basePackagePath)`|设置模板所在的包
`void  setClassLoaderForTemplateLoading(java.lang.ClassLoader classLoader, java.lang.String basePackagePath)`|设置模板所在的包
`void  setDefaultEncoding(java.lang.String encoding)`|设置默认字符编码
`void  setDirectoryForTemplateLoading(java.io.File dir)`|设置模板所在的目录
`void  setEncoding(java.util.Locale locale, java.lang.String encoding)`|设置用于指定区域的字符编码
`void  setIncompatibleImprovements(Version incompatibleImprovements)`|设置freemarker语法版本
`void  setInterpolationSyntax(int interpolationSyntax)`|设置变量语法（`${x}`还是`[=x]`）
`void  setLocale(java.util.Locale locale)`|设置区域
`void  setLocalizedLookup(boolean localizedLookup)`|设置是否启用本地化模板查找
`void  setLogTemplateExceptions(boolean value)`|设置是否把模板处理中异常记录到日志
`void  setNamingConvention(int namingConvention)`|设置标识符命名规则
`void  setObjectWrapper(ObjectWrapper objectWrapper)`|设置Java对象到freemarker对象的转换器
`void  setOutputFormat(OutputFormat outputFormat)`|设置默认输出格式
`void  setRecognizeStandardFileExtensions(boolean recognizeStandardFileExtensions)`|设置是否用文件扩展名猜测输出格式
`void  setRegisteredCustomOutputFormats(java.util.Collection<? extends OutputFormat> registeredCustomOutputFormats)`|设置输出格式名(参考`OutputFormat.getName()`)集合
`void  setServletContextForTemplateLoading(java.lang.Object servletContext, java.lang.String path)`|设置模板所在位置
`void  setSetting(java.lang.String name, java.lang.String value)`|设置选项
`void  setSharedVariable(java.lang.String name, java.lang.Object value)`|设置共享变量
`void  setSharedVariable(java.lang.String name, TemplateModel tm)`|设置一个共享变量
`void  setSharedVaribles(java.util.Map map)`|设置全部共享变量
`void  setTabSize(int tabSize)`|设置制表符大小（占用列数）
`void  setTagSyntax(int tagSyntax)`|设置默认指令格式（`<#if x>`还是`[#if x]`）|
`void  setTemplateConfigurations(TemplateConfigurationFactory templateConfigurations)`|设置模板特定的配置选项
`void  setTemplateExceptionHandler(TemplateExceptionHandler templateExceptionHandler)`|设置模板异常处理器
`void  setTemplateLoader(TemplateLoader templateLoader)`|设置模板加载器
`void  setTemplateLookupStrategy(TemplateLookupStrategy templateLookupStrategy)`|设置按名寻找模板的策略
`void  setTemplateNameFormat(TemplateNameFormat templateNameFormat)`|设置模板名格式
`void  setTemplateUpdateDelayMilliseconds(long millis)`|设置检查模板更新的最短时间间隔
`void  setTimeZone(java.util.TimeZone timeZone)`|设置时区
`void  setWhitespaceStripping(boolean b)`|设置是否去除FTL指令两侧的空白
`void  setWrapUncheckedExceptions(boolean value)`|是否把表达式求值或执行指令时的非检查型异常包装为`TemplateException`


## 结语

由于模板语言过于强大，应该在控制器做的事情在模板中也能完成（图灵完备），因此仅仅使用模板语言并不意味着完全把视图和控制器隔离。为了保证可维护性，必须始终明确什么事情是业务逻辑而什么是视图。


