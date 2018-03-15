---
title:  "用Jekyll在GitLab pages上搭建博客"
layout: post
tags: web
---

虽然已经有很多可免费使用的博客平台，但对于不善交际的程序员来说，更多社交化功能还不如更大的自主权。仅就可以自由地运用JS这点，不仅可以渲染数学公式、高亮的代码和乐谱等，还可以分析页面流量。由于大家可能比较熟悉GitHub pages，这里就介绍一下GitLab pages。我们仍然用最流行Jekyll作静态生成器，但GitLab的持续集成完全容许你使用其它的静态生成器，甚至可以是自己发明的。

## 博客的选项

想搭建博客，有许多方法。从对服务器的控制权由大到小（通常也由昂贵到便宜）可分为：

- 自己搭建实体服务器。由于独立公网IP的成本和维护服务器的烦杂工作，现在一般小站长都不会自己搭建服务器。
- 租用机房的实体服务器。由于上述原因仍然存在，在发生硬件故障时更可能要不远千里跑到机房处置，现在一般小站长也不会这样做。
- 租用云服务器。能够控制一个虚拟机实例，如安装软件。
- 租用虚拟主机。通常不能安装软件，只能用提供方指定的软件（如PHP），但足以运行动态网站。
- 租用网页空间。只能存放静态网站。

虽然存在一些免费试用的云服务器，如Redhat的[OpenShift](https://www.openshift.com/)或[IBM Cloud](https://console.bluemix.net/registration/)，但国外云（包括收费的）有速度不是特别理想和容易被封锁的硬伤，国内主要云服务器的最低收费对于个人来说不能说便宜，还可能在备案时被卡一段时间才能开始用。至于虚拟主机，除了也不太便宜的云提供商外，很难找到靠谱的供应商（不管免费还是便宜），要么乱插广告、要么随时下线甚至倒闭，还可能由于与暴力色情网站为邻而被牵连。由于网页空间成本最低，所以在预算受限时使用网页空间比较可能得到靠谱的服务，其中GitHub和GitLab等面向程序员的大规模网站相对值得信赖。

- [GitHub pages](https://pages.github.com/)是在程序员间极为流行的一个平台，有着良好的文档、速度和稳定性良好；不足则是限制比较多，只能用少数指定的Jekyll插件、定制域名不支持HTTPS以及最要命的是403封杀百度蜘蛛导致百度一般不能收录。
- [GitLab pages](https://about.gitlab.com/features/pages/)作为上者的开源山寨品，容许私服、容许免费的私有仓库、定制域名支持HTTPS、可灵活配置构建过程用的静态生成器及插件；不足则有文档相对不完整、用户少导致求助困难还有不能301重定向到HTTPS。
- [码云 pages](http://git.mydoc.io/?t=154714)作为上者的一个定制私服，优点是国内访问速度快，但似乎没有别的好处，限制还多回去

使用静态空间的话，自然就不能用类似于[Wordpress](https://cn.wordpress.org/)（号称世界上30%的网站在用它）或[Joomla](https://www.joomla.org/)（也有百万计网站基于它）之类的内容管理系统（CMS）。但这也不意味着要退回去一个一个地手写每一个HTML页面，我们可以用更浓缩的语言写文章，然后用某种程序生成最终的HTML文件，包括目录等辅助页面，这就是静态生成器，其中Jekyll要算是最流行的。通过借助其它服务器上的服务，即使静态网站也能实现站内搜索、评论之类的功能。

{% raw %}

## 开始使用GitLab pages

### 启用GitLab pages

现在我们用GitLab pages做个最简单的网站。
1. 登录[GitLab](https://gitlab.com/)
2. Fork这个[jekyll模板仓库](https://gitlab.com/pages/jekyll)
3. 在“Settings”中的“Advanced settings”中的“Rename repository”中把仓库名改成这个样子`你的用户名.gitlab.io`（这样网站将可在`https://你的用户名.gitlab.io`访问；如果仓库是其它名字，网站可在`https://你的用户名.gitlab.io/仓库名`访问）
4. 把仓库克隆到本地，形如：`git clone 'https://gitlab.com/你的用户名/你的用户名.gitlab.io.git'&&cd 你的用户名.gitlab.io`
5. 把仓库中`_config.yml`文件中`baseurl: "/jekyll"`以为`baseurl: "/"`（如果你用了`你的用户名.gitlab.io`外的仓库名，把这行的`jekyll`改为仓库名）
6. 提交上述修改：`git commit -a`
7. 推入到GitLab的master分支：`git push origin master`
8. 稍等一会就可以在上面提到过的URL访问到，如果久久都访问不了可以到仓库页的“CI/CD”检查一下。

如果你不想Fork，而要从头开始也是可以的。方法如下：
1. 新建一个仓库（名称规则同上）
2. 在仓库页上点击“Set up CI/CD”
3. 把仓库克隆到本地
4. 把部署脚本`.gitlab-ci.yml`设置好（可以先参考上述模板中的）
5. `jekyll new`
6. 提交
7. 推入

### 编写载客文章

每写一篇博客文章，在`_posts`目录中新增一个文件名形如`年年年年-月月-日日-用户看到的文件名.后缀`的文件，它的开始部分是被两个`---`包围的导言区，用于以[YAML格式](http://www.yaml.org/spec/1.2/spec.html)指定关于博文的各种可选的元数据。

```
---
layout: post # 用于布局的模板（不带后缀），null表示不用模板
permalink: /latest/events.html # 用于指定生成页面的路径
published: false # 用于指定是否生成页面
title:  "文章标题" # 用于指定给人看的文章标题
date:   2016-03-24 15:32:14 +0800 # 发布日期（优先于标题中的），用于排序
categories: 类别 子类别 # 用空格分隔的分类
tags: 标签1 标签2 标签3 # 用空格分隔的标签
# 也可以使用其它变量，其值可以在布局或可重用组件中通过{{page.变量名}}引用
---
```	

导言区后的是内容，格式化方法取决于文件名后缀，如通常`md`表示Markdown，`html`表示HTML。以下以Markdown为例，除了[标准Markdown](https://daringfireball.net/projects/markdown/)外，还可以使用[GitHub风格的Markdown](https://guides.github.com/features/mastering-markdown/)，比如要高亮显示代码，只用这样：

<div class="language-markdown highlighter-rouge"><div class="highlight"><pre class="highlight"><code>    <span class="sb">
&#x60;&#x60;&#x60;ruby
require 'redcarpet'
markdown = Redcarpet.new("Hello World!")
puts markdown.to_html
&#x60;&#x60;&#x60;</span>
</code></pre></div></div>

编写其它页面和编写博文类似，只是文件路径不同，如`目录/标题.后缀`，会在渲染后默认直接放到`目录/标题.html`。

## 玩转Jekyll

这里我们介绍Jekyll的一些基本定制，完整的信息参考[文档](https://jekyllrb.com/docs/home/)。

### 在本地预览Jekyll网站

如果每次改动后要推入后等一会才有结果，实验的机会就会大幅减少，结果将是一个更差的网站，所以值得在本地搭建一个可以快速预览效果的环境：

1. 确保Ruby已经安装，如Debian下`sudo apt install ruby-dev`
2. 确保bundler已经安装：`sudo gem install bundler`
3. 确保Jekyll已经安装，在项目目录下`bundle`
4. 在项目目录下`bundle exec jekyll serve`
5. 在浏览器中可通过URL`http://localhost:4000/`看到你的网站

值得一提的是，如果你修改网站（不包括配置文件），效果会很快自动生效。

### 目录结构

Jekyll源的目录结构不难理解，以下简单说明一些文件（包括目录）的用途：

文件（包括目录）|用途
---|---
`_config.yml`|保存配置信息
`_drafts`|用于存放未发表博文的目录，其中博文文件名形如`标题.后缀`（不加日期），可以用`bundle exec jekyll serve --drafts`预览
`_includes`|用于存放可重用组件（如页眉、页脚、边栏、作者介绍）的目录，其中名如`文件名`的文件可以在布局或博文中通过`{% include 文件名 %}`引用
`_layouts`|用于存放布局模板的目录，如果一个博文或布局模板的导言指定了`layout: 模板`，则会通过把内容代入这目录下的`模板.html`中的`{{ content }}`来生成页面
`_posts`|用来存放你的博文的目录，其中博文文件名形如`年-月-日-标题.后缀`
`_data`|用来存放站点的结构化数据的目录，可以是名如`数据.yml`、`数据.yaml`、`数据.json`或`数据.csv`的文件，这些数据可通过`site.data.数据`访问
`_sass`|用来存放后缀为`scss`的CSS文件片段，它们将被用（通过在用户样式表中`@import "{{ site.theme }}";`之类引用）于生成最终的样式表
`_site`|用来存放本地预览生成的目录，应该在`.gitignore`文件忽略它。
`.jekyll-metadata`|用来帮助本地预览跟踪文件修改，应该在`.gitignore`文件忽略它。
其它后缀为`.html`、`.markdown`、`.md`或`.textile`的文件|有YAML导言的话会被`Jekyll`处理并在生成站点的对应路径生成`.html`文件
其它|会被原样复制到生成的站点，如样式表、图像、站点图标`favicon.ico`

### 配置

默认的配置文件`_config.yml`形如：

```yaml
source:          .         # Jekyll读取输入的目录
destination:     ./_site   # Jekyll生成输出的目录
collections_dir: .        
plugins_dir:     _plugins  # 用于存放插件的目录
layouts_dir:     _layouts  # 用于存放布局模板的目录
data_dir:        _data     # 用于存在站点相关数据的目录
includes_dir:    _includes # 用于存放可重用组件的目录
collections:
  posts:                   # 建立一个称为posts的集合
    output:   true         # 是否处理这集合
                           # 可以在这里为这集合中的文章设置默认属性，如permalink

# Handling Reading
safe:                 false # 是否禁用自定义插件和忽略符号链接
include:              [".htaccess"] # 在生成站点时包含可能默认会被忽略的文件（包括目录）
exclude:              ["Gemfile", "Gemfile.lock", "node_modules", "vendor/bundle/", "vendor/cache/", "vendor/gems/", "vendor/ruby/"] # 在生成站点时忽略可能默认会被包含的文件（包括目录）
keep_files:           [".git", ".svn"] # 在重建站点保留的文件（包括目录，相对于输出目录），通常用于不是Jekyll生成的文件
encoding:             "utf-8" # 文件编码方式
markdown_ext:         "markdown,mkdown,mkdn,mkd,md" # Markdown文件后缀
strict_front_matter: false # 是否在有YAML语法错误时构建失败

# Filtering Content
show_drafts: null  # 是否处理和显示未发布的博文
limit_posts: 0     # 最多发布的博文数
future:      false # 是否渲染日期在未来的博文
unpublished: false # 是否渲染标记为unpublished的博文

# Plugins
whitelist: []
plugins:   [] # 在Jekyll 3.4前用gems属性

# Conversion
markdown:    kramdown
highlighter: rouge
lsi:         false        # 是否生成相关帖子索引，要求classifier-reborn插件
excerpt_separator: "\n\n"
incremental: false

# Serving
detach:  false          # 是否让服务器与终端分离
port:    4000           # 默认端口号
host:    127.0.0.1      # 预览响应的域名
baseurl: ""             # 预览的根路径（相对于域名）
show_dir_listing: false #

# Outputting
permalink:     /:categories/:year/:month/:day/:title:output_ext # 博文生成的路径，可用变量：year、month、i_month、day、i_day、y_day、short_year、hour、minute、second、title、slug、categories
paginate_path: /page:num # 分页路径
timezone:      null # 用于站点生成的时区

quiet:    false # 是否抑制输出
verbose:  false # 是否生成详细的输出
defaults: []    # 把默认值应用到一组文件，例子如下：
#defaults:
#  -
#    scope:
#      path: "" # 应用到的路径（包括后裔，最特殊优先），空白表示所有文件
#      type: "posts" # 应用到的类型（可选）：pages、 posts、drafts或你在collection中定义的集合
#    values:
#      layout: "default" # 默认属性

liquid:
  error_mode: warn # Liquid语法错误的处理方法： lax、warn或strict

# Markdown Processors
rdiscount:
  extensions: []

redcarpet:
  extensions: [] # 启用的Redcarpet::Markdown类扩展如autolink

kramdown:
  auto_ids:       true
  entity_output:  as_char
  toc_levels:     1..6
  smart_quotes:   lsquo,rsquo,ldquo,rdquo
  input:          GFM
  hard_wrap:      false
  footnote_nr:    1
  show_warnings:  false
```

在你的`_config.yml`中，只用列出你需要的与默认不同的设置。值得注意的是，有的选项可以在通过命令参数改写。

### 设计外观

#### 使用现成主题

为了快速得到一个大致满意的样子，可以寻找一个[Jekyll主题](https://rubygems.org/search?utf8=%E2%9C%93&query=jekyll-theme)，然后如下应用：

1. 在`Gemfile`加入一行类似`gem "jekyll-theme-主题"`
2. `bundle install`
3. 在`_config.yml`加入一行类似`theme: jekyll-theme-主题`
4. 生成站点

当然你也可以自己打造自己的主题并与世界分享。

#### 定制

其实主题的作用不外是代你提供一些文件。如果你对主题不全满意，可以自己复写`assets`、`_layouts`、`_includes`和`_sass`等目录中的文件（你的文件存在时来自主题的对应文件会被忽略）。

##### 索引

简单的博文目录形如：

```html
<ul>
  {% for post in site.posts %} <!-- 分页时改为paginator.posts, 并在_config.yml中加入行paginate: 每页文章数 -->
    <li>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
      <blockquote>{{ post.excerpt }}</blockquote><!-- 不需要摘要可去掉这行 -->
    </li>
  {% endfor %}
</ul>
```

而如果要为每个标签（或分类）建立索引页，可以先建立一个模板`_layouts/tag.html`：

```html
---
layout: default
---

<h1>{{page.tags}}</h1>

{% for post in site.tags[page.tags] %}
  <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
  {% for tag in post.tags %}
  <span class="tag"><a href="{{ '/tag/' | relative_url }}{{ tag }}">{{ tag }}</a></span>
  {% endfor %}
  <blockquote>{{ post.excerpt }}</blockquote>
{% endfor %}
```

然后为每个标签建立一文件`tag/标签.html`内容形如：

```
---
layout: tag
title: 标签
tags: 标签
---
```

当然手动生成每个这种文件不是好方法。我们可以用类似下面的脚本代劳（这个脚本并不完全正确，因为没有真正去解析YAML）：

```
#!/bin/bash

mkdir -p tag;
for tag in `grep -h -m 1 '^tags:' _posts/* | sed 's/^tags://g;s/ /\n/g'`;do
	echo "---
layout: tag
title: ${tag}
tags: ${tag}
---" > "tag/${tag}.html";
done;
```

在GitHub Pages中我们只能每次推入前在本地运行为种脚本再`git add tag/* && git commit`，而在GitLab Pages，这完全可以交给持续集成服务器去做。（其实已经有Jekyll插件`jekyll-tagging`做这件事，但因GitHub不支持所以才在这里补充这样的变通方法）

最后，我们应该让每个博文页面上有指向它各标签索引页的链接，这可以通过在`_layouts/post.html`中加入以下样子的代码实现：

```html
{% if page.tags.size>0 %}
标签：
{% for tag in page.tags %}
<span class="tag"><a href="{{ '/tag/' | relative_url }}{{ tag }}">{{ tag }}</a></span>
{% endfor %}
{% endif %}
```

##### 数学公式

要支持LaTeX数学公式，可以加入使用MathJax：

```javascript
<script type="text/x-mathjax-config">
    MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$']]}});
</script>
<script type="text/javascript" async src="https://cdn.jsdelivr.net/npm/mathjax@2.7.2/MathJax.js?config=TeX-MML-AM_CHTML">
</script>
```

然后就可以在两个`$`间用LaTeX写数学公式。不过由于LaTeX与Markdown的元字符有些冲突，而Markdown是先于LaTeX解析的，所以`_`要转义、`|`要改为`\vert`等等。

### 使用插件

Jekyll插件可以在多方面扩充Jekyll的功能：
- 可以生成变量的值甚至页面
- 可以提供更多Markdown外的转换器
- 可以提供更多Jekyll子命令
- 可以提供更多Liquid标签和过滤器
- 可以在生成站点的各个子步骤间插入其它过程

存在许多现成的[Jekyll插件](https://jekyllrb.com/docs/plugins/)可以使用，安装方法如下：

1. 在`Gemfile`中加入一行类似`gem 'jekyll-插件'`
2. `bundle install`
3. 在`_config.yml`中在`plugins`列表中加入`jekyll-插件`

常用的插件包括：
  - `jekyll-sitemap`可自动生成`sitemap.xml`和`robots.txt`，有利于帮助搜索引擎发现你的页面。不想被收录的页面可以把`sitemap`变量设为`false`。
  - `jekyll-seo-tag`提供标签`{% seo %}`以便生成[SEO需要的标签](https://github.com/jekyll/jekyll-seo-tag/blob/master/docs/usage.md)
  - `jekyll-paginate`用于分页
  - `jekyll-feed`容许读者通过Atom订阅你的博客
  - `jekyll-redirect-from`容许你在修改URL时能把旧URL的流量引导到新位置，例如如果你把`permalink`从`date`转换为`none`，则运行一次以下脚本可帮你大忙：

```bash
#!/bin/bash

mkdir -p tag;
for file in `ls _posts`;do
	path=`sed "s/^\([0-9]\{4\}\)-\([0-9]\{1,2\}\)-\([0-9]\{1,2\}\)-\(.*\)\.md$/\/\1\/\2\/\3\/\4.html/" <<< "${file}"`;
	sed -i "1aredirect_from: ${path}" "_posts/${file}";
done;

```

当然你可以自己开发插件，放在`_plugins`目录中后缀为`rb`的Ruby文件中。

### 编程

如果上面的调整不足以满足你的需要，则你可以用编程方式生成你想要的代码。

#### 语言



Jekyll使用[Liquid](https://shopify.github.io/liquid)作为模板语言，这样语言的代码嵌入到（就像PHP）HTML或Markdown文件中：
- 被`{{`或`{{-`与`}}`或`-}}`包围（`-`的效果是去空白），中间如下：
    - 一个值（可以是变量）
    - 零个或多个过滤器（由左到右应用），每个由`|`开始，然后是过滤器名称，接着可以有`:`和由`,`分隔的各参数
- 被`{%`与`{%-`与`%}`或`-%}`包围（`-`的效果是去空白）的称为标签，包括：
    - 标签`{% comment %}`与`{% endcomment %}`间的内容会被忽略
    - 标签`{% if 表达式 %}`、若干`{% elsif 表达式 %}`、可选的`{% else %}`与`{% endif %}`可用于实现条件处理
    - 标签`{% unless 表达式 %}`、若干`{% elsif 表达式 %}`、可选的`{% else %}`与`{% endunless %}`可用于实现条件处理
    - 标签`{% case 变量 %}`、若干`{% when 值 %}`、`{% else %}`与`{% endcase %}`可用于实现条件处理
    - 标签`{% for 变量 in 数组 %}`与`{% endfor %}`间内容将随数组元素迭代，其中可用`变量`引用元素，还可用标签{% break %}和`{% continue %}`。数组也可改为整数范围如`首个整数:最后整数`，在`数组`后可以加上以下参数：
        - `limit:最大迭代次数`
        - `offset:开始的下标`
        - `reversed`表示反方向迭代
    - 在迭代中标签`{% cycle 值, ... , 值 %}`的效果是在每次迭代时循环地输出各个值
    - 标签`{% tablerow 变量 in 数组 %}`与`{% endtablerow %}`与for类似，但用于生成表格，其中可用参数`cols:列数`
    - 标签{% endraw %}`{{"{"}}% raw %}`与`{{"{"}}% endraw %}`{% raw %}间的标签不会被特别看待
    - 标签`{% assign 变量 = 值 %}`将初始化变量
    - 标签`{% capture 变量 %}`与`{% endcapture %}`间的内容会用于初始化变量
    - 标签`{% increment 变量 %}`会把变量（前两条的变量在不同名字空间）的值加1再输出（首次调用得0）
    - 标签`{% decrement 变量 %}`会把变量（前两条的变量在不同名字空间）的值减1再输出（首次调用得-1）

Liquid中有以下类型：
- 字符串，可以用单引号或双引号包围来表示
- 数值，整数和浮点数可以用通常语法表示
- 布尔值，用`true`或`false`表示
- Nil，用于表示不存在的值，没有字面表示方法，输出的话为空
- 数组和散列表，没有字面表示方法

表达式中可用值、变量和中缀操作符（包括`==`、`!=`、`>`、`<`、`>=`、`<=`、`or`、`and`和`contains`），另外可用`数组[下标]`的形式访问数组或散列表元素，用`数组.下标`访问散列表元素，用`数组.size`访问数组长度。除了`nil`和`false`外所有东西都视为假。

#### 全局变量

语言本身并没有太大作用，关键是如何获取输入。

##### 站点

可用以下变量了解站点特定的信息：

变量|值
---|---
`site.time`|生成网站的时间
`site.pages`|页面列表
`site.posts`|博文列表（时间倒序）
`site.related_posts`|相关页面列表，默认为最近的十篇博文
`site.static_files`|静态文件列表（不经Jekyll转换器处理），每个文件有子属性`path`、`modified_time`、`name`、`basename`和`extname`
`site.html_pages`|`site.pages`后缀为`.html`的子集
`site.html_files`|`site.static_files`后缀为`.html`的子集
`site.collections`|集合列表，每个集合又有属性如`label`、`docs`、`files`、`relative_directory`、`directory`、`output`
`site.data`|来自`_data`目录的数据列表
`site.documents`|所有集合中全部文档列表
`site.categories.分类`|特定分类中全部博文列表
`site.tags.标签`|特定标签中全部博文列表
`site.url`|网站根URL
`site.自定义变量`|在`_config.yml`或命令行中定义的变量

##### 页面

可用以下变量了解页面特定的信息：

变量|值
---|---
`page.content`|页面内容
`page.title`|页面标题
`page.excerpt`|文档的摘要（未渲染）
`page.url`|页面位置（不带域名，但带前导`/`）
`page.date`|页面日期
`page.id`|页面的惟一标识
`page.categories`|页面的分类列表
`page.tags`|页面的标签列表
`page.path`|页面的源路径
`page.next`|下一博文，没有则`nil`
`page.previous`|上一博文，没有则`nil`
`page.自定义变量`|在导言中定义的变量

##### 内容

每个文件中导言后的部分保存到变量`content`中。

##### 布局

可用以下变量了解布局特定的信息：

变量|值
---|---
`layout.自定义变量`|在导言中定义的变量

##### 分页

在设置`paginate`了选项时，可用以下变量了解分页情况：

变量|值
---|---
`paginator.per_page`|每页最多的博文数
`paginator.posts`|当前页显示的博文
`paginator.total_posts`|总博文数
`paginator.total_pages`|总页码
`paginator.page`|当前页的页码
`paginator.previous_page`|上一页的页码
`paginator.previous_page_path`|到上一页的路径
`paginator.next_page`|下一页的页码
`paginator.next_page_path`|到下一页的路径

#### Jekyll标签

- `{% include 文件名 %}`用于包含`_includes`目录下指定文件
- `{% highlight 语言 %}`与`{% endhighlight %}`间内容将进行语法加亮，`语言`后加上`linenos`可显示行号
- `{% post_url 年年年年-月月-日日-标题 %}`可生成指向博文的链接
- `{% link 源文件路径 %}`可得到生成文件的路径

#### Jekyll过滤器

- `relative_url`把`baseurl`加到前面
- `absolute_url`把`url`和`baseurl`加到前面
- `date_to_xmlschema`把日期按ISO 8601格式化
- `date_to_rfc822`把日期按RFC 822格式化
- `date_to_string`把日期用短格式表示
- `date_to_long_string`把日期用长格式表示
- `where`选取由首参数给出属性的值为次参数的元素组成和子数组
- `where_exp`选取由满足次参数给出表达式（其中可通过首参数给出的名字引用元素）的元素组成和子数组
- `group_by`用于按参数给出的属性对数组元素分组
- `group_by_exp`用于按首参数给出次参数给出表达式（其中可通过首参数给出的名字引用元素）输出对数组元素分组
- `xml_escape`用于作XML转义
- `cgi_escape`用于URI转义
- `uri_escape`用于作URI转义，但保留字不会
- `number_of_words`统计单词个数
- `array_to_sentence_string`把数组格式化为可读字符串，可选参数为最后的连词
- `markdownify`用于把Markdown格式化为HTML
- `smartify`自动把引号变为开关引号 }}
- `scssify`用于把Sass或SCSS格式的字符串转换为CSS
- `slug`用于生成适合用于url的小写标题，可选参数可决定提取算法是`pretty`、`ascii`还是`latin`
- `jsonify`用于把数组或散列表转换为JSON
- `normalize_whitespace`用于把连续的空白替换为一个空格
- `sort`用于对数组排序，可选的参数有排序属性名和`nil`是`first`还是`last`
- `sample`用于在数组中随机选一个元素，可选参数决定选几个（默认1）
- `to_integer`用于把字符串或布尔值转换为整数
- `push`把参数加到数组后面得到新数组
- `pop`把数组最后元素移除得到新数组
- `unshift`把参数加到数组前面得到新数组
- `shift`把数组首个元素移除得到新数组
- `inspect`把值转换为字符串

{% endraw %}

## 玩转GitLab Pages

### 定制错误页

加入一个类似这样的`403.md`和`404.md`即可：

```
---
layout: default
---

我们真的找不到你要的页面，还是回到[首页]({{ '/' | relative_url }})吧
```

当然你也可以用HTML页面而不是Markdown。

### 控制部署过程

GitLab Pages的一个强大之处在于支持自定义部署脚本，在你推入后在他们的服务器上根据你的指示生成网站。

作为例子，我们通过为每个部署后文件额外提供gzip压缩的版本来减低传输时间，这可以通过把`.gitlab-ci.yml`后面改成以下这样来实现：

```
pages:
  stage: deploy
  script:
  - bundle exec jekyll build -d public/
  - find public -type f -iregex '.*\.\(htm\|html\|txt\|text\|js\|css\)$' -execdir gzip -f --keep {} \;
  artifacts:
    paths:
    - public
  only:
  - master
```

### 使用定制域名

Gitlab Pages支持多个自定义域名而且可以自定义SSL证书。使用自定义域名除了能显示个性外，还有助保证可迁移性（即使GitLab下线，你也可以把通过修改DNS解析记录把流量重定向到后备站点）

1. 假如你没有域名，先购买一个，比如在[万网](https://wanwang.aliyun.com/)或[Godaddy](https://sg.godaddy.com/zh)上。以下假设你的域名为本站的`chungkwong.cc`。
2. （可选）为你的域名获取SSL证书，以下以已经签发超过上亿张免费证书、获得各大浏览器默认信任、后台强大的签发机构[Let's Encrypt](https://letsencrypt.org/)为例：
    1. 确保你的电脑已经安装[certbot](https://certbot.eff.org/)，例如在Debian GNU/Linux下只用`sudo apt install certbot`
    2. 运行certbot，例如在Debian GNU/Linux下只用`sudo certbot certonly --manual`
    3. 输入你准备用于你的网站的域名
    4. `y`同意记录你的IP
    5. 按提示你把一个文本放到指定的URL然后回车
    6. 成功验证后就会签发证书保存到特定目录
3. 把你的域名和证书告知Gitlab
    1. 在GitLab打开你的网站项目页，如本网站是`https://gitlab.com/chungkwong/chungkwong.gitlab.io`，然后导航到“Settings”中的“Pages”
    2. 点击“New Domain”，然后输入你的域名（或子域名，如`www.chungkwong.cc`）、密钥（Debian下位于类似的`/etc/letsencrypt/archive/chungkwong.cc/privkey1.pem`安全地方）和证书（Debian下位于类似的`/etc/letsencrypt/archive/chungkwong.cc/fullchain1.pem`安全地方）
    3. 记下验证码
4. 在域名注册商设置解析
    1. 为你上面在GitLab输入的（子）域名增加CNAME记录，值为你的GitLab Pages域名，如`chungkwong.gitlab.io`
    2. 为你上面在GitLab输入的（子）域名的子域名`_gitlab-pages-verification-code`增加TXT记录，值为前面记下的验证码
5. 在每3步最后的页面点击“Verify ownership”
6. 你应该很快可以通过你指定的域名访问你的网站，比如URL`https://www.chungkwong.cc`。但如果之前有人企图访问过该域名，则这可能要等一段时间直到各级缓存过期，你的修改才生效。

遗憾的是，GitLab本身不能在证书到期时自动续期，于是你可能需要每90天重复上述过程来保证SSL证书一直有效（更新证书可用`sudo certbot renew`而不用重复第二步全部步骤）。不过如果如果你的电脑总是开启且有联网，一个可行方案是用crontab任务定期更新证书再用[GitLab API](https://docs.gitlab.com/ce/api/pages_domains.html)上传新证书。

如果对Gitlab Pages还有疑问，可以看一下[文档](https://docs.gitlab.com/ce/user/project/pages/introduction.html)
