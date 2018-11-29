---
title:  "图解GIMP滤镜"
layout: post
mathjax: true
tags: 图像处理
ads:
    - <a rel="nofollow" target="_blank" href="https://amazon.cn/gp/product/B00BYCPI7I/ref=as_li_tl?ie=UTF8&tag=chungkwong-23&camp=536&creative=3200&linkCode=as2&creativeASIN=B00BYCPI7I&linkId=247749981cb506638697a9cf48a79c32">GIMP图像处理经典教程</a>
---

[《GIMP图像处理入门》](/gimp.html)中介绍了GIMP的基本用法，这里我们再介绍GIMP以插件形式提供的各种滤镜，可以通过应用算法对图层进行修改来实现各种各样的效果。

按照图像处理的惯例，我们在大多数例子中用[Lena头像](http://www.lenna.org/)作为输入（为了避免被列入黑名单，就不用全身了）：

![Lena头像](/image/gimp_thumb/lena_std.jpeg)

## 模糊滤镜

这类滤镜用于使图像变得模糊。

滤镜|说明|例子
---|---|---
模糊|轻微柔化图像|![效果](/image/gimp_thumb/blur_blur.jpeg)
高斯模糊|通过把像素换成邻近像素的加权平均进行常规模糊，模糊半径越大越模糊|![效果](/image/gimp_thumb/blur_gaussian.jpeg)
选择性高斯模糊|只模糊低对比的部分，可用于模糊背景|![效果](/image/gimp_thumb/blur_selective.jpeg)
动态模糊|用于制造运动中的效果|![效果](/image/gimp_thumb/blur_motion.jpeg)
像素化|可用于对敏感部分打马赛克|![效果](/image/gimp_thumb/blur_pixelise.jpeg)
可平铺模糊|用于对需平铺图像的模糊|![效果](/image/gimp_thumb/blur_tileable.jpeg)

## 增强滤镜

这类滤镜用于修正图像的细节。

滤镜|说明|例子
---|---|---
边缘平滑|用于反（放大图像造成的）锯齿|
去除交错|用于去除相机采用隔行扫描造成的交错|
去除斑点|通过把像素换成邻近像素的中位数去去除小斑点|![效果](/image/gimp_thumb/enhance_despeckle.jpeg)
去除条纹|用于去除劣质扫描仪造成的条纹|
非线性滤波|模糊、去斑点和锐化的组合|![效果](/image/gimp_thumb/enhance_nl.jpeg)
红眼去除|用于去除由于使用闪光灯造成的红眼|![效果](/image/gimp_thumb/enhance_red_eye.jpeg)
锐化|用于整体锐化|![效果](/image/gimp_thumb/enhance_sharp.jpeg)
虚光蒙板|用于锐化高对比的部分，从而避免加大噪声|![效果](/image/gimp_thumb/enhance_mask.jpeg)

## 扭曲滤镜

这类滤镜用于扭曲图像。

滤镜|说明|例子
---|---|---
百叶窗|用于制作从百叶窗看出去效果|![效果](/image/gimp_thumb/distort_blind.jpeg)
曲线扭曲|用于把矩形区域的上下边沿扭曲成各种形状|![效果](/image/gimp_thumb/distort_curve.jpeg)
刻画||![效果](/image/gimp_thumb/distort_engrave.jpeg)
浮雕|用于生成浮雕效果|![效果](/image/gimp_thumb/distort_emboss.jpeg)
隔行擦除|用于生成老电视机逐行显示的效果|![效果](/image/gimp_thumb/distort_another.jpeg)
交互式翘曲|用于生成局部移动、膨胀收缩、旋涡等效果|![效果](/image/gimp_thumb/distort_iwarp.jpeg)
镜头形变|用于生成显示器非平面造成的效果|![效果](/image/gimp_thumb/distort_screen.jpeg)
马赛克|用于生成铺砖效果|![效果](/image/gimp_thumb/distort_mosaic.jpeg)
报纸|用于生成打印机产生的半色调效果|![效果](/image/gimp_thumb/distort_newspaper.jpeg)
页面卷曲|用于生成纸张卷曲产生的效果|![效果](/image/gimp_thumb/distort_curl.jpeg)
极坐标|用于生成（部分）扭曲为球面的效果|![效果](/image/gimp_thumb/distort_polar.jpeg)
波纹|用于生成在平行水波下的效果，可用于生成模拟电视机调台不准确时可能的效果|![效果](/image/gimp_thumb/distort_ripple.jpeg)
滑移|随机平移各行（或列），可用于生成震动效果|![效果](/image/gimp_thumb/distort_shift.jpeg)
颜色繁殖|向指定方向扩散颜色值|![效果](/image/gimp_thumb/distort_propagate.jpeg)
视频|用于生成劣质RGB模拟的效果|![效果](/image/gimp_thumb/distort_video.jpeg)
波|用于生成在环状水波下的效果|![效果](/image/gimp_thumb/distort_wave.jpeg)
旋转与挤压|用于想像印在弹性物料后扭曲的效果|![效果](/image/gimp_thumb/distort_whirl.jpeg)
风|用于生成被风吹等运动的效果|![效果](/image/gimp_thumb/distort_wind.jpeg)
透镜|用于生成通过透镜观看的效果|![效果](/image/gimp_thumb/distort_lens.jpeg)

## 光照和阴影滤镜

这类滤镜用于制作与光照相关的效果。

滤镜|说明|例子
---|---|---
渐变闪光|生成图中物体被强光照射的效果|![效果](/image/gimp_thumb/light_gradient.jpeg)
镜头光晕|生成图中物体被太阳直射的效果|![效果](/image/gimp_thumb/light_lens.jpeg)
光照|生成图中物体被射灯照射的效果|![效果](/image/gimp_thumb/light_lighting.jpeg)
火花|生成火光效果|![效果](/image/gimp_thumb/light_sparkle.jpeg)
超新星|生成发出强光的效果|![效果](/image/gimp_thumb/light_supernova.jpeg)
透视|生成点光源下阴影的效果|![效果](/image/gimp_thumb/light_perspective.jpeg)
Xach-Effect|用于强调图像中一部分|![效果](/image/gimp_thumb/light_xach.jpeg)
投影|生成平行光源阴影的效果|![效果](/image/gimp_thumb/light_shadow.jpeg)

## 噪音滤镜

这类滤镜用于把噪音加到图像中。

滤镜|说明|例子
---|---|---
HSV噪音||![效果](/image/gimp_thumb/noise_hsv.jpeg)
撒|随机化部分像素|![效果](/image/gimp_thumb/noise_hurl.jpeg)
糊|随机下降一些像素，用于生成融化效果|![效果](/image/gimp_thumb/noise_slur.jpeg)
RGB噪音|生成看起来自然的噪声|![效果](/image/gimp_thumb/noise_rgb.jpeg)
捡|随机交换一些像素|![效果](/image/gimp_thumb/noise_pick.jpeg)
扩散|随机扩散一些像素|![效果](/image/gimp_thumb/noise_spread.jpeg)

## 边缘检测滤镜

这类滤镜用于突出图像中对象的边界。

滤镜|说明|例子
---|---|---
高斯差分|使用两个不同半径高斯模糊之差来检测，广泛用于机器视觉|![效果](/image/gimp_thumb/edge_diff.jpeg)
边缘||![效果](/image/gimp_thumb/edge_edge.jpeg)
拉普拉斯|生成单像素宽度的边界|![效果](/image/gimp_thumb/edge_laplace.jpeg)
霓虹|生成霓虹灯效果的边界|![效果](/image/gimp_thumb/edge_neon.jpeg)
Sobel|生成垂直和水平边界|![效果](/image/gimp_thumb/edge_sobel.jpeg)

## 常规滤镜

这类滤镜用途比较广泛。

滤镜|说明|例子
---|---|---
腐蚀|用于收缩较亮的区域|![效果](/image/gimp_thumb/generic_erode.jpeg)
膨胀|用于扩张较亮的区域|![效果](/image/gimp_thumb/generic_dilate.jpeg)

特别要指出“卷积矩阵”是相当通用的，它通过把各像素代之以它为心窗口与你定义的矩阵作卷积得到的值，可以实现众多其它滤镜的效果：

效果|矩阵例子
---|---
模糊|$\begin{pmatrix}\frac{1}{9}&\frac{1}{9}&\frac{1}{9}\\\\\frac{1}{9}&\frac{1}{9}&\frac{1}{9}\\\\\frac{1}{9}&\frac{1}{9}&\frac{1}{9} \end{pmatrix}$
锐化|$\begin{pmatrix}0&-1&0\\\\-1&5&-1\\\\0&-1&0 \end{pmatrix}$
边缘检测|$\begin{pmatrix}0&1&0\\\\1&-4&1\\\\0&1&0 \end{pmatrix}$


## 组合滤镜

这类滤镜用于合并多个图像：
- 深度合并，用于合并两张照片，使部分区域来自一张照片而其它来自另一张
- 胶卷，用于制作把多张照片放到胶卷上的效果

## 艺术滤镜

这类滤镜用于把图像转变成艺术作品的样子。

滤镜|说明|例子
---|---|---
应用画布|用于生成印到画布上的效果|![效果](/image/gimp_thumb/art_canvas.jpeg)
卡通|通过让深色更深来生成卡通效果|![效果](/image/gimp_thumb/art_cartoon.jpeg)
编织|用于生成印到编织品上的效果|![效果](/image/gimp_thumb/art_weave.jpeg)
布状效果|用于生成印到衣服上的效果|![效果](/image/gimp_thumb/art_clothify.jpeg)
立体派|用于生成用纸片构成的效果|![效果](/image/gimp_thumb/art_cubism.jpeg)
印象派艺术家|用于生成绘画效果|![效果](/image/gimp_thumb/art_pressionist.jpeg)
油画|用于生成油画效果|![效果](/image/gimp_thumb/art_oilify.jpeg)
影印|用于生成黑白复印效果|![效果](/image/gimp_thumb/art_photocopy.jpeg)
捕食者|用于生成夜视的效果|![效果](/image/gimp_thumb/art_predator.jpeg)
柔光|用于生成柔光照射的效果|![效果](/image/gimp_thumb/art_softglow.jpeg)
凡高|通过方向模糊来生成材质|![效果](/image/gimp_thumb/art_lic.jpeg)
玻璃瓦片|用于生成印到玻璃瓦片上的效果|![效果](/image/gimp_thumb/art_glass.jpeg)

## 装饰滤镜

这类滤镜用于为图像加上装饰。

滤镜|说明|例子
---|---|---
添加斜面|用于制作斜面效果|![效果](/image/gimp_thumb/decor_bevel.jpeg)
添加边框|用于制作边框|![效果](/image/gimp_thumb/decor_border.jpeg)
咖啡迹|用于添加咖啡迹|![效果](/image/gimp_thumb/decor_coffee.jpeg)
边缘模糊|用于制作边缘不规则的效果|![效果](/image/gimp_thumb/decor_fuzzy.jpeg)
老照片|用于生成老照片的效果|![效果](/image/gimp_thumb/decor_old.jpeg)
圆角|用于制作圆角图像|![效果](/image/gimp_thumb/decor_round.jpeg)
幻灯片|用于把图像放到胶卷上|![效果](/image/gimp_thumb/decor_slide.jpeg)
蜡版雕刻|把灰度且没有Alpha通道的图像雕刻到另一图像上|![效果](/image/gimp_thumb/decor_crave.jpeg)
蜡版镀铬|把灰度且没有Alpha通道的图像镀铬到另一图像上|![效果](/image/gimp_thumb/decor_chrome.jpeg)

## 映射滤镜

这类滤镜用于把图像映射成特定模式。

滤镜|说明|例子
---|---|---
凸凹贴图|通过让图像部分浮起来制作立体效果|![效果](/image/gimp_thumb/map_bump.jpeg)
移位|把每个像素移位|![效果](/image/gimp_thumb/map_displace.jpeg)
分形追溯|用于生成Mandelbrot分形效果|![效果](/image/gimp_thumb/map_fractal.jpeg)
幻像|用于重复相似的图像|![效果](/image/gimp_thumb/map_illusion.jpeg)
无缝处理|用于生成可无缝平铺的图像|![效果](/image/gimp_thumb/map_seamless.jpeg)
映射到物体|用于把图像铺到球面、环面或方体面|![效果](/image/gimp_thumb/map_object.jpeg)
纸片平铺|用于把图像切割后随机移动各块|![效果](/image/gimp_thumb/map_paper.jpeg)
小块平铺|变换为由当前图像缩小后平铺|![效果](/image/gimp_thumb/map_small.jpeg)
平铺|重复图像到指定大小|![效果](/image/gimp_thumb/map_small.jpeg)
翘曲|根据一个灰度图像移动各像素|![效果](/image/gimp_thumb/map_warp.jpeg)

## 绘制滤镜

这类滤镜用于绘制各种类型的对象。

滤镜|说明|例子
---|---|---
差分云|通过稍为修改图像颜色生成云|![效果](/image/gimp_thumb/draw_diff.jpeg)
雾|用于生成烟雾效果|![效果](/image/gimp_thumb/draw_flog.jpeg)
五彩缤纷|用于生成饱和的云|![效果](/image/gimp_thumb/draw_plasma.jpeg)
纯色噪音|用于生成随机材质|![效果](/image/gimp_thumb/draw_solid.jpeg)
火焰|用于生成随机的分形|![效果](/image/gimp_thumb/draw_flame.jpeg)
IFS分形|用于生成IFS分形|![效果](/image/gimp_thumb/draw_ifs.jpeg)
棋盘|用于生成棋盘|![效果](/image/gimp_thumb/draw_checkboard.jpeg)
CML探索器|利用元胞自动机生成材质|![效果](/image/gimp_thumb/draw_cml.jpeg)
衍射图案|用于生成衍射图案|![效果](/image/gimp_thumb/draw_diffus.jpeg)
网格|用于生成网格|![效果](/image/gimp_thumb/draw_grid.jpeg)
拼图|用于生成拼图|![效果](/image/gimp_thumb/draw_puzzle.jpeg)
迷宫|用于生成迷宫|![效果](/image/gimp_thumb/draw_maze.png)
Qbist|用于从图片和颜色梯度生成材质|![效果](/image/gimp_thumb/draw_qbist.jpeg)
正弦|用于生成波状图案|![效果](/image/gimp_thumb/draw_sinus.jpeg)
电路|用于生成电路板状的图案|![效果](/image/gimp_thumb/draw_circut.jpeg)
分形探索器|用于生成各种分形|![效果](/image/gimp_thumb/draw_fractual.jpeg)
几何图形|用于绘制各种几何图形|![效果](/image/gimp_thumb/draw_gfig.jpeg)
熔岩|用于绘制熔岩状图案|![效果](/image/gimp_thumb/draw_lava.jpeg)
新星线|用于生成从中间到外围的一系列线|![效果](/image/gimp_thumb/draw_nova.jpeg)
球面设计器|用于绘制球面|![效果](/image/gimp_thumb/draw_sphere.jpeg)
Spyrogimp|用于绘制利萨如线、外旋轮线和螺旋型星云线|![效果](/image/gimp_thumb/draw_sky.jpeg)

## 网页滤镜

这类滤镜完成一些与网页有关的工作：
- “图像映射”用于制作可点击地图
- “半平整”用于用背景色替换透明度
- “切片”|用于沿参考线分割出多张图像并生成能把它们接起来的HTML文件

## 动画滤镜

这类滤镜可以用于制作动画。

滤镜|说明|例子
---|---|---
混合|以图层作为关键帧创建动画|![效果](/image/gimp_thumb/animation_mix.gif)
烧入||![效果](/image/gimp_thumb/animation_burn.gif)
波纹||![效果](/image/gimp_thumb/animation_ripple.gif)
旋转球||![效果](/image/gimp_thumb/animation_ball.gif)
波||![效果](/image/gimp_thumb/animation_wave.gif)

另外，点“回放”可预览动画效果，点“优化”则往往可减少生成文件的大小。

## Alpha变徽标

这类滤镜可以用于制作图标或横幅。

滤镜|例子
---|---
3D轮廓|![效果](/image/gimp_thumb/icon_partical.jpeg)
冰凉金属|![效果](/image/gimp_thumb/icon_metal.jpeg)
材质|![效果](/image/gimp_thumb/icon_material.jpeg)
裁剪掉|![效果](/image/gimp_thumb/icon_crop.jpeg)
炽热|![效果](/image/gimp_thumb/icon_hot.jpeg)
镀铬|![效果](/image/gimp_thumb/icon_bovination.jpeg)
粉笔|![效果](/image/gimp_thumb/icon_chalk.jpeg)
光泽|![效果](/image/gimp_thumb/icon_glow.jpeg)
混合|![效果](/image/gimp_thumb/icon_mix.jpeg)
基本 I|![效果](/image/gimp_thumb/icon_basic1.jpeg)
基本 II|![效果](/image/gimp_thumb/icon_basic2.jpeg)
渐变斜面|![效果](/image/gimp_thumb/icon_bevel.jpeg)
粒子径迹|![效果](/image/gimp_thumb/icon_partical.jpeg)
漫画书|![效果](/image/gimp_thumb/icon_comics.jpeg)
奶牛斑|![效果](/image/gimp_thumb/icon_milk.jpeg)
霓虹灯|![效果](/image/gimp_thumb/icon_light.jpeg)
奇异灯光|![效果](/image/gimp_thumb/icon_special.jpeg)
奇异霓虹灯|![效果](/image/gimp_thumb/icon_neon.jpeg)
霜冻|![效果](/image/gimp_thumb/icon_cool.jpeg)

