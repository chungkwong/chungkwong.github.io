---
title:  "图解GIMP滤镜"
layout: post
tags: 图像处理
---

[《GIMP修图入门》]({% link 2018-04-04-gimp.md %})中介绍了GIMP的基本用法，这里我们再介绍GIMP以插件形式提供的各种滤镜，可以通过应用算法对图层进行修改来实现各种各样的效果。


## 模糊滤镜
滤镜|说明|例子
---|---|---
模糊|轻微柔化图像|[效果](http://assets.chungkwong.cc/image/gimp/blur_blur.jpeg)
高斯模糊|通过把像素换成邻近像素的加权平均进行常规模糊，模糊半径越大越模糊|[效果](http://assets.chungkwong.cc/image/gimp/blur_gaussian.jpeg)
选择性高斯模糊|只模糊低对比的部分，可用于模糊背景|[效果](http://assets.chungkwong.cc/image/gimp/blur_selective.jpeg)
动态模糊|用于制造运动中的效果|[效果](http://assets.chungkwong.cc/image/gimp/blur_motion.jpeg)
像素化|可用于对敏感部分打马赛克|[效果](http://assets.chungkwong.cc/image/gimp/blur_pixelise.jpeg)
可平铺模糊|用于对需平铺图像的模糊|[效果](http://assets.chungkwong.cc/image/gimp/blur_tileable.jpeg)

## 增强滤镜
滤镜|说明|例子
---|---|---
边缘平滑|用于反锯齿|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
去除交错|用于去除相机采用隔行扫描造成的交错|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
去除斑点|通过把像素换成邻近像素的中位数去去除小斑点|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
去除条纹|用于去除劣质扫描仪造成的条纹|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
非线性滤波|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
红眼去除|用于去除由于使用闪光灯造成的红眼|[效果](http://assets.chungkwong.cc/image/gimp/enhance_red_eye.jpeg)
锐化|用于整体锐化|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
虚光蒙板|用于锐化高对比的部分，从而避免加大噪声|[效果](http://assets.chungkwong.cc/image/gimp/enhance_mask.jpeg)

## 扭曲滤镜
滤镜|说明|例子
---|---|---
百叶窗|用于制作从百叶窗看出去效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_blind.jpeg)
曲线扭曲|用于把矩形区域的上下边沿扭曲成各种形状|[效果](http://assets.chungkwong.cc/image/gimp/distort_curve.jpeg)
刻画||[效果](http://assets.chungkwong.cc/image/gimp/distort_engrave.jpeg)
浮雕|用于生成浮雕效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_emboss.jpeg)
隔行擦除|用于生成老电视机逐行显示的效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_another.jpeg)
交互式翘曲|用于生成局部移动、膨胀收缩、旋涡等效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_iwarp.jpeg)
镜头形变|用于生成显示器非平面造成的效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_screen.jpeg)
马赛克|用于生成铺砖效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_mosaic.jpeg)
报纸|用于生成打印机产生的半色调效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_newspaper.jpeg)
页面卷曲|用于生成纸张卷曲产生的效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_curl.jpeg)
极坐标|用于生成（部分）扭曲为球面的效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_polar.jpeg)
波纹|用于生成在平行水波下的效果，可用于生成模拟电视机调台不准确时可能的效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_ripple.jpeg)
滑移|随机平移各行（或列），可用于生成震动效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_shift.jpeg)
颜色繁殖|向指定方向扩散颜色值|[效果](http://assets.chungkwong.cc/image/gimp/distort_propagate.jpeg)
视频|用于生成劣质RGB模拟的效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_video.jpeg)
波|用于生成在环状水波下的效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_wave.jpeg)
旋转与挤压|用于想像印在弹性物料后扭曲的效果|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
风|用于生成被风吹等运动的效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_wind.jpeg)
透镜|用于生成通过透镜观看的效果|[效果](http://assets.chungkwong.cc/image/gimp/distort_lens.jpeg)
## 光照和阴影滤镜
滤镜|说明|例子
---|---|---
渐变闪光|生成图中物体被强光照射的效果|[效果](http://assets.chungkwong.cc/image/gimp/light_gradient.jpeg)
镜头光晕|生成图中物体被太阳直射的效果|[效果](http://assets.chungkwong.cc/image/gimp/light_lens.jpeg)
光照|生成图中物体被射灯照射的效果|[效果](http://assets.chungkwong.cc/image/gimp/light_lighting.jpeg)
火花|生成火光效果|[效果](http://assets.chungkwong.cc/image/gimp/light_sparkle.jpeg)
超新星|生成发出强光的效果|[效果](http://assets.chungkwong.cc/image/gimp/light_supernova.jpeg)
透视|生成阴影的效果|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
Xach-Effect|用于强调图像中一部分|[效果](http://assets.chungkwong.cc/image/gimp/light_xach.jpeg)
投影|生成阴影的效果|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
## 噪音滤镜
滤镜|说明|例子
---|---|---
HSV噪音||[效果](http://assets.chungkwong.cc/image/gimp/noise_hsv.jpeg)
撒|随机化部分像素|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
糊|随机下降一些像素，用于生成融化效果|[效果](http://assets.chungkwong.cc/image/gimp/noise_hurl.jpeg)
RGB噪音|生成看起来自然的噪声|[效果](http://assets.chungkwong.cc/image/gimp/noise_rgb.jpeg)
捡|随机交换一些像素|[效果](http://assets.chungkwong.cc/image/gimp/noise_pick.jpeg)
扩散|随机扩散一些像素|[效果](http://assets.chungkwong.cc/image/gimp/noise_spread.jpeg)
## 边缘检测滤镜
滤镜|说明|例子
---|---|---
高斯差分|使用两个不同半径高斯模糊之差来检测，广泛用于机器视觉|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
边缘||[效果](http://assets.chungkwong.cc/image/gimp/edge_edge.jpeg)
拉普拉斯|生成单像素宽度的边界|[效果](http://assets.chungkwong.cc/image/gimp/edge_laplace.jpeg)
霓虹|生成霓虹灯效果的边界|[效果](http://assets.chungkwong.cc/image/gimp/edge_neon.jpeg)
Sobel|生成垂直和水平边界|[效果](http://assets.chungkwong.cc/image/gimp/edge_sobel.jpeg)
## 通用滤镜
滤镜|说明|例子
---|---|---
卷积矩阵|通过把像素代之以它为心窗口与你定义的矩阵作卷积得到的值，可以实现众多效果|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
腐蚀|用于收缩较亮的区域|[效果](http://assets.chungkwong.cc/image/gimp/generic_erode.jpeg)
膨胀|用于扩张较亮的区域|[效果](http://assets.chungkwong.cc/image/gimp/dilate.jpeg)
## 组合滤镜
滤镜|说明|例子
---|---|---
深度合并|用于合并多张照片|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
胶卷|用于从多疑照片放到胶卷上的效果|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
## 艺术滤镜
滤镜|说明|例子
---|---|---
应用画布|用于生成印到画布上的效果|[效果](http://assets.chungkwong.cc/image/gimp/art_canvas.jpeg)
卡通|通过让深色更深来生成卡通效果|[效果](http://assets.chungkwong.cc/image/gimp/art_cartoon.jpeg)
编织|用于生成印到编织品上的效果|[效果](http://assets.chungkwong.cc/image/gimp/art_weave.jpeg)
布状效果|用于生成印到衣服上的效果|[效果](http://assets.chungkwong.cc/image/gimp/art_clothify.jpeg)
立体派|用于生成用纸片构成的效果|[效果](http://assets.chungkwong.cc/image/gimp/art_cubism.jpeg)
印象派艺术家|用于生成绘画效果|[效果](http://assets.chungkwong.cc/image/gimp/art_pressionist.jpeg)
油画|用于生成油画效果|[效果](http://assets.chungkwong.cc/image/gimp/art_oilify.jpeg)
影印|用于生成黑白复印效果|[效果](http://assets.chungkwong.cc/image/gimp/art_photocopy.jpeg)
捕食者|用于生成夜视的效果|[效果](http://assets.chungkwong.cc/image/gimp/art_predator.jpeg)
柔光|用于生成柔光照射的效果|[效果](http://assets.chungkwong.cc/image/gimp/art_softglow.jpeg)
凡高|通过方向模糊来生成材质|[效果](http://assets.chungkwong.cc/image/gimp/art_lic.jpeg)
玻璃瓦片|用于生成印到玻璃瓦片上的效果|[效果](http://assets.chungkwong.cc/image/gimp/art_glass.jpeg)
## 装饰滤镜
滤镜|说明|例子
---|---|---
添加斜面|用于制作斜面效果|[效果](http://assets.chungkwong.cc/image/gimp/decor_bevel.jpeg)
添加边框|用于制作边框|[效果](http://assets.chungkwong.cc/image/gimp/decor_border.jpeg)
咖啡迹|用于添加咖啡迹|[效果](http://assets.chungkwong.cc/image/gimp/decor_coffee.jpeg)
边缘模糊|用于制作边缘不规则的效果|[效果](http://assets.chungkwong.cc/image/gimp/decor_fuzzy.jpeg)
老照片|用于生成老照片的效果|[效果](http://assets.chungkwong.cc/image/gimp/decor_old.jpeg)
圆角|用于制作圆角图像|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
幻灯片|用于把图像放到胶卷上|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
蜡版雕刻|把灰度且没有Alpha通道的图像雕刻到另一图像上|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
蜡版镀铬|把灰度且没有Alpha通道的图像镀铬到另一图像上|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
## 映射滤镜
滤镜|说明|例子
---|---|---
凸凹贴图|通过让图像部分浮起来制作立体效果|[效果](http://assets.chungkwong.cc/image/gimp/map_bump.jpeg)
移位|把每个像素移位|[效果](http://assets.chungkwong.cc/image/gimp/map_displace.jpeg)
分形追溯|用于生成Mandelbrot分形效果|[效果](http://assets.chungkwong.cc/image/gimp/map_fractal.jpeg)
幻像|用于重复相似的图像|[效果](http://assets.chungkwong.cc/image/gimp/map_illusion.jpeg)
无缝处理|用于生成可无缝平铺的图像|[效果](http://assets.chungkwong.cc/image/gimp/map_seamless.jpeg)
映射到物体|用于把图像铺到球面、环面或方体面|[效果](http://assets.chungkwong.cc/image/gimp/map_object.jpeg)
纸片平铺|用于把图像切割后随机移动各块|[效果](http://assets.chungkwong.cc/image/gimp/map_paper.jpeg)
小块平铺|变换为由当前图像缩小后平铺|[效果](http://assets.chungkwong.cc/image/gimp/map_small.jpeg)
平铺|重复图像到指定大小|[效果](http://assets.chungkwong.cc/image/gimp/map_small.jpeg)
翘曲|根据一个灰度图像移动各像素|[效果](http://assets.chungkwong.cc/image/gimp/map_warp.jpeg)
## 绘制滤镜
滤镜|说明|例子
---|---|---
差分云|通过稍为修改图像颜色生成云|[效果](http://assets.chungkwong.cc/image/gimp/draw_diff.jpeg)
雾|用于生成烟雾效果|[效果](http://assets.chungkwong.cc/image/gimp/draw_flog.jpeg)
五彩缤纷|用于生成饱和的云|[效果](http://assets.chungkwong.cc/image/gimp/draw_plasma.jpeg)
纯色噪音|用于生成随机材质|[效果](http://assets.chungkwong.cc/image/gimp/draw_solid.jpeg)
火焰|用于生成随机的分形|[效果](http://assets.chungkwong.cc/image/gimp/draw_flame.jpeg)
IFS分形|用于生成IFS分形|[效果](http://assets.chungkwong.cc/image/gimp/draw_ifs.jpeg)
棋盘|用于生成棋盘|[效果](http://assets.chungkwong.cc/image/gimp/draw_checkboard.jpeg)
CML探索器|利用元胞自动机生成材质|[效果](http://assets.chungkwong.cc/image/gimp/draw_cml.jpeg)
衍射图案|用于生成衍射图案|[效果](http://assets.chungkwong.cc/image/gimp/draw_diffus.jpeg)
网格|用于生成网格|[效果](http://assets.chungkwong.cc/image/gimp/draw_grid.jpeg)
拼图|用于生成拼图|[效果](http://assets.chungkwong.cc/image/gimp/draw_puzzle.jpeg)
迷宫|用于生成迷宫|[效果](http://assets.chungkwong.cc/image/gimp/draw_maze.png)
Qbist|用于从图片和颜色梯度生成材质|[效果](http://assets.chungkwong.cc/image/gimp/draw_qbist.jpeg)
正弦|用于生成波状图案|[效果](http://assets.chungkwong.cc/image/gimp/draw_sinus.jpeg)
电路|用于生成电路板状的图案|[效果](http://assets.chungkwong.cc/image/gimp/draw_circut.jpeg)
分形探索器|用于生成各种分形|[效果](http://assets.chungkwong.cc/image/gimp/draw_fractual.jpeg)
几何图形|用于绘制各种几何图形|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
熔岩|用于绘制熔岩状图案|[效果](http://assets.chungkwong.cc/image/gimp/draw_lava.jpeg)
新星线|用于生成从中间到外围的一系列线|[效果](http://assets.chungkwong.cc/image/gimp/draw_nova.jpeg)
球面设计器|用于绘制球面|[效果](http://assets.chungkwong.cc/image/gimp/draw_sphere.jpeg)
Spyrogimp|用于绘制利萨如线、外旋轮线和螺旋型星云线|[效果](http://assets.chungkwong.cc/image/gimp/draw_sky.jpeg)
## 网页滤镜
滤镜|说明|例子
---|---|---
图像映射|用于生成用于网页的可点击地图|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
半平整||[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
切片|用于生成多张图像和能把它们接起来的HTML文件|[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
## 动画滤镜
滤镜|说明|例子
---|---|---
混合|以图层作为关键帧创建动画|[效果](http://assets.chungkwong.cc/image/gimp/animation_mix.gif)
烧入||[效果](http://assets.chungkwong.cc/image/gimp/animation_burn.gif)
波纹||[效果](http://assets.chungkwong.cc/image/gimp/animation_ripple.gif)
旋转球||[效果](http://assets.chungkwong.cc/image/gimp/animation_ball.gif)
波||[效果](http://assets.chungkwong.cc/image/gimp/animation_wave.gif)

另外，点“回放”可预览动画效果，点“优化”则往往可减少生成文件的大小。

## Alpha变徽标
滤镜|说明|例子
---|---|---
3D轮廓||[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
冰凉金属||[效果](http://assets.chungkwong.cc/image/gimp/icon_metal.jpeg)
材质||[效果](http://assets.chungkwong.cc/image/gimp/icon_material.jpeg)
裁剪掉||[效果](http://assets.chungkwong.cc/image/gimp/icon_crop.jpeg)
炽热||[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
镀铬||[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
粉笔||[效果](http://assets.chungkwong.cc/image/gimp/icon_chalk.jpeg)
光泽||[效果](http://assets.chungkwong.cc/image/gimp/icon_glow.jpeg)
混合||[效果](http://assets.chungkwong.cc/image/gimp/icon_mix.jpeg)
基本 I||[效果](http://assets.chungkwong.cc/image/gimp/icon_basic1.jpeg)
基本 II||[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
渐变斜面||[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
粒子径迹||[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
漫画书||[效果](http://assets.chungkwong.cc/image/gimp/icon_comics.jpeg)
奶牛斑||[效果](http://assets.chungkwong.cc/image/gimp/icon_milk.jpeg)
霓虹灯||[效果](http://assets.chungkwong.cc/image/gimp/icon_light.jpeg)
奇异灯光||[效果](http://assets.chungkwong.cc/image/gimp/icon_special.jpeg)
奇异霓虹灯||[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)
霜冻||[效果](http://assets.chungkwong.cc/image/gimp/.jpeg)

