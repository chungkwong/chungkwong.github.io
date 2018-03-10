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

使用静态空间的话，自然就不能用类似于[Wordpress](https://cn.wordpress.org/)（号称世界上30%的网站在用它）之类的内容管理系统（CMS）。但这也不意味着要退回去一个一个地手写每一个HTML页面，我们可以用更浓缩的语言写文章，然后用某种程序生成最终的HTML文件，包括目录等辅助页面，这就是静态生成器，其中Jekyll要算是最流行的。

## 开始使用GitLab pages

现在我们用GitLab pages做个最简单的网站。
1. 登录[GitLab](https://gitlab.com/)
2. Fork这个[jekyll模板仓库](https://gitlab.com/pages/jekyll)
3. 在“Settings”中的“Advanced settings”中的“Rename repository”中把仓库名改成这个样子`你的用户名.gitlab.io`（这样网站将可在`https://你的用户名.gitlab.io`访问；如果仓库是其它名字，网站可在`https://你的用户名.gitlab.io/仓库名`访问）
4. 把仓库克隆到本地，形如：`git clone 'https://gitlab.com/chungkwong/chungkwong.gitlab.io.git'&&cd chungkwong.gitlab.io`
5. 把仓库中`_config.yml`文件中`baseurl: "/jekyll"`以为`baseurl: "/"`（如果你用了`你的用户名.gitlab.io`外的仓库名，把这行的`jekyll`改为仓库名）
6. 提交上述修改：`git commit -a`
7. 推入到GitLab的master分支：`git push origin master`
8. 稍等一会就可以在上面提到过的URL访问到，如果久久都访问不了可以到仓库页的“CI/CD”检查一下。

## 玩转Jekyll


### 在本地预览Jekyll网站

如果每次改动后要推入后等一会才有结果，实验的机会就会大幅减少，结果将是一个更差的网站，所以值得在本地搭建一个可以快速预览效果的环境：

1. 确保Ruby已经安装，如Debian下`sudo apt install ruby-dev`
2. 确保bundler已经安装：`sudo gem install bundler`
3. 确保Jekyll已经安装，在项目目录下`bundle`
4. 在项目目录下`bundle exec jekyll serve`
5. 在浏览器中可通过URL`http://localhost:4000/`看到你的网站

值得一提的是，如果你修改网站（不包括配置文件），效果会很快自动生效。

## 玩转GitLab Pages

### 定制错误页

加入一个类似这样的`403.md`和`404.md`即可：

```
---
layout: default
---

我们真的找不到你要的页面，还是回到[首页](/)吧
```

当然你也可以用HTML页面而不是Markdown。

### 提供压缩文件

通过为每个部署后文件，通过额外提供gzip压缩的版本（压缩加上后缀），有助减低传输时间，这可以通过把`.gitlab-ci.yml`后面改成以下这样来实现：

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
    2. 点击“New Domain”，然后输入你的域名（或子域名，如`www.chungkwong.cc`）、密钥（Debian下位于类似的`/etc/letsencrypt/archive/chungkwong.cc/privkey1.pem`安全地方）和证书（Debian下位于类似的`/etc/letsencrypt/archive/www.chungkwong.cc/fullchain1.pem`安全地方）
    3. 记下验证码
4. 在域名注册商设置解析
    1. 为你上面在GitLab输入的（子）域名增加CNAME记录，值为你的GitLab Pages域名，如`chungkwong.gitlab.io`
    2. 为你上面在GitLab输入的（子）域名的子域名`_gitlab-pages-verification-code`增加TXT记录，值为前面记下的验证码
5. 在每3步最后的页面点击“Verify ownership”
6. 你应该很快可以通过你指定的域名访问你的网站，比如URL`https://www.chungkwong.cc`。但如果之前有人企图访问过该域名，则这可能要等一段时间直到各级缓存过期，你的修改才生效。

遗憾的是，GitLab本身不能在证书到期时自动续期，于是你可能需要每90天重复上述过程来保证SSL证书一直有效。不过如果如果你的电脑总是开启且有联网，一个可行方案是用crontab任务定期更新证书再用[GitLab API](https://docs.gitlab.com/ce/api/pages_domains.html)上传新证书。

如果对Gitlab Pages还有疑问，可以看一下[文档](https://docs.gitlab.com/ce/user/project/pages/introduction.html)
