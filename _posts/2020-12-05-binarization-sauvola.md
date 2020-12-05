---
title:  "局部自适应二值化方法的内存高效快速实现"
layout: post
mathjax: true
tags: 图像处理
---

二值化被广泛用作识别前从背景分离出文本等对象的预处理步骤。通过逐个像素计算阀值，局部自适应二值化方法能较好地分割光照不均或带噪声的受损文档图片。由于阀值往往依赖于矩形窗口中灰度值的一些基于矩的统计量如均值和方差，过往人们常用积分图像去加速计算，代价则是需要额外占用大量内存空间。注意到按行主序，矩形窗口中矩和直方图都可以增量地计算，进而容易得到局部平均、标准差以至分位数，积分图像实际上是不必要的。特别地，这个想法导致Bernsen方法和Niblack型方法如Sauvola方法的新串行实现，它们的时间复杂度与输入图像的大小成正比且与窗口大小无关，而辅助空间关于输入图像大小次线性。

## 常見的二值化方法

二值化是把灰度图像转化为二值图像的图像处理操作，通常用于从背景中区分出对象。特别地，二值化被广泛用作文档分析系统的预处理步骤，使光学文本识别引擎能够假设文本成分已经被提取出来。二值化的质量同时影响版面分析和字符识别的准确性，在处理受损文档图像和车牌等场景文本时尤其重要。

许多流行的二值化方法通过比较像素的灰度值和计算出的阀值工作。按照阀值是否因像素而异，可以把这类方法细分为局部自适应方法和整体方法。与整体方法相比，局部自适应方法对常见的受损情况如噪声、光照不均和穿透更健壮。例如单一阀值对于分离文本和咖啡迹而言可能并不足够。以下，我们把一个$H\times W$灰度输入图像记为$(I\_{ij})\_{0\leq i <H, 0\leq j <W}$，其中按惯例灰度值$I\_{ij}\in\left\\{0, \ldots, 255\right\\}$。相应地，我们把二值图像记为$(B\_{ij})\_{0\leq i <H, 0\leq j <W}$，其中按惯例$B\_{ij}\in\left\\{0, 1\right\\}$。

整体方法对每个输入图像计算一个阀值$T$，然后令
$B\_{ij}=\begin{cases}0&, I\_{ij}\leq T\\\\1&, I\_{ij}> T\end{cases}$。
其中最有代表性的Otsu方法选择阀值使类间灰度值方差最大以顾及图像的亮度和对比度。

局部自适应方法即使对同一图像的不同像素也使用可能不同的阀值。像素$(i, j)$的阀值$T\_{ij}$用它为心的邻域中像素灰度值的某些统计量来计算，然后令
$B\_{ij}=\begin{cases}0&, I\_{ij}\leq T\_{ij}\\\\1&, I\_{ij}> T\_{ij}\end{cases}$。
通常把邻域取为以$(i, j)$为心的$h\times w$矩形窗口，常用的统计量有平均值$\mu\_{ij}$和标准差$\sigma\_{ij}$。特别地，Niblack取
$T\_{ij}=\mu\_{ij}+K\sigma\_{ij}$， 而Sauvola和Pietikäinen取$T\_{ij}=\mu\_{ij}\left(1+K\left(\frac{\sigma\_{ij}}{R}-1\right)\right)$， 其中$K$为一个可调整的正参数而$R$通常取为$128$，注意$\sigma\_{ij}\leq \left(255-0\right)/2<128\text{。}$按照定义
$\mu\_{ij}=\frac{1}{hw}\displaystyle\sum\_{\substack{i-\frac{h}{2}<k\leq i+\frac{h}{2}\\\\j-\frac{w}{2}<\ell\leq j+\frac{w}{2}}}I\_{k\ell}$而
$\sigma\_{ij}=\sqrt{\frac{1}{hw}\displaystyle\sum\_{\substack{i-\frac{h}{2}<k\leq i+\frac{h}{2}\\\\j-\frac{w}{2}<\ell\leq j+\frac{w}{2}}}I\_{k\ell}^2-\mu\_{ij}^2}$。 
Bernsen则取$T\_{ij}=\begin{cases}\frac{1}{2}\left(\min\_{ij}+\max\_{ij}\right)&, \max\_{ij}-\min\_{ij}\geq C\\\\ -1&,  \max\_{ij}-\min\_{ij}<C\end{cases}$，其中$C$为参数，
$\min\nolimits\_{ij}=\min\left\\{I\_{k\ell}\vert i-\frac{h}{2}<k\leq i+\frac{h}{2}, j-\frac{w}{2}<\ell\leq j+\frac{w}{2}\right\\}$，而
$\max\nolimits\_{ij}=\max\left\\{I\_{k\ell}\vert i-\frac{h}{2}<k\leq i+\frac{h}{2}, j-\frac{w}{2}<\ell\leq j+\frac{w}{2}\right\\}$。

下图比较了一些二值化方法应用于某张样本图片时的效果。Otsu方法把相对暗的一片背景当作了前景，这观察验证了Otsu方法Otsu对背景亮度变化不健壮，因为它是一个整体二值化方法。Bernsen方法基本上去除了暗的背景，但一行文本也失去了，这观察验证了Bernsen方法在低对比度区域效果欠佳，因为它们都被视为背景。Sauvola方法在视觉上几乎提取了所有文本，虽然很多字符断裂了且留下了不少噪声。因此，本文系统使用Sauvola方法。

![二值化方法的例子](image/sauvola/binarization.png)

存在许多其它二值化方法，而且直到近期仍然有新方法被不断地提出来。除启发式方法外，还有一些基于机器学习的方法。有监督学习可以用于直接把像素分类，例如Tensmeyer和Martinez设计了一个全卷积神经网络来整合来自不同尺度的信息。非监督学习可以用于对像素聚类，例如Bhowmik等人用$k$-均值算法去聚类受博弈论启发的特征。不过，机器学习算法通常都是计算密集的，所以当受限的计算资源是关注点时不会是首选，特别是在其它方法的结果可以接受时。

## 局部自适应方法现有实现及其局限性

虽然局部自适应方法一般来说比整体方法更鲁棒，但也更计算密集，现有实现要么慢要么挥霍内存。具体地说，Otsu方法的实现只需$\Theta \left(HW\right)$时间和常量辅助空间：先遍历输入图像中所有像素一遍就能得到灰度值直方图，然后就能得到阀值，最后二值图像在下一轮迭代中得到。相反，直接用定义公式计算阀值的话，Sauvola方法的时间复杂度为$\Theta (HWhw)$，速度随窗口变大而递减。然而，随着高分辨率图片变得普遍，大窗口正变得更有用。

一个以空间换取时间的著名方法是维护积分图像。Bradley和Roth用积分图像去加速窗口中灰度均值的计算。Shafait等人进一步用这技巧去计算标准差。注意到加速Sauvola方法的关键是高效地计算以下形式的量：
$\displaystyle\sum\_{\substack{a<k\leq b\\\\c<\ell\leq d}}f(I\_{k\ell})$，
其中$f$为一个函数。令$J\_{ij}=\displaystyle\displaystyle\sum\_{\substack{k\leq i\\\\\ell\leq j}}f(I\_{k\ell})$， 则
$\displaystyle\sum\_{\substack{a<k\leq b\\\\c<\ell\leq d}}f(I\_{k\ell})=J\_{bd}-J\_{ad}-J\_{bc}+J\_{ac}$，
如下图所示。积分图像$(J\_{ij})\_{0\leq i <H, 0\leq j <W}$可以用以下递推关系计算： 
$J\_{i, j}=\begin{cases}0 &, i<0 \textrm{ 或 }j<0\\\\\left(J\_{i, j-1}-J\_{i-1, j-1}\right)+f\left(I\_{i, j}\right)+J\_{i-1, j} & , \textrm{其它}\end{cases}$。
因此，Sauvola方法的时间复杂度可以降至$\Theta (HW)$，并且与窗口大小无关。然而，为了保存两个积分图像，过渡性内存消耗从$\Theta (1)$剧增到$\Theta (HW)$。它们要占用比输入的灰度图像更大的空间，这种内存消耗对一些应用场景而言过大。

![局部自适应二值化方法的积分图像法实现的原理](image/sauvola/integral.svg)

人们还提出了硬件实现。Chen等人提出了一个Sauvola方法基于GPU的并行实现，但积分图像的构造未有并行化。Najafi和Salehi则提出了一个基于随机电路的完整硬件实现，但它局限于一个小且固定的窗口大小。

许多应用需要局部自适应二值化方法又快又省内存的实现，而且不能依赖于专门的硬件。对于实时应用场景如识别黑板上的内容，学生手中的移动设备要用有限的资源迅速地完成工作。对于批处理应用场景如大型历史文献电子化计划，高效的二值化算法将有助于节省大量时间或硬件。

## Sauvola方法的新实现

本节提出Sauvola方法的一个内存高效且快速的实现，它不要求任何特殊的硬件。在加速Sauvola方法的同时尽可能节约内存的想法来源于两个观察。

基本的观察是两个相近的窗口内含有许多公共的元素，因此灰度值的$f$在一个窗口内的总和可以被重用来计算另一个窗口内的总和。形式地，对整数$a, b, c\text{ 和 }d$，
$\displaystyle\sum\_{\substack{a<k\leq b\\\\c<\ell\leq d}}f(I\_{k\ell})=\displaystyle\sum\_{\substack{a<k\leq b\\\\ c-1<\ell\leq d-1}}f(I\_{k\ell})+\displaystyle\sum\_{a<k\leq b}f(I\_{kd})-\displaystyle\sum\_{a<k\leq b}f(I\_{kc})$，
如下图所示。

![局部自适应二值化方法的本文实现的原理（窗口级）](image/sauvola/window.svg)

类似地，对整数$a, b\text{ 和 }e$，
$\displaystyle\sum\_{a<k\leq b}f(I\_{ke})=\displaystyle\sum\_{a-1<k\leq b-1}f(I\_{ke})+f(I\_{be})-f(I\_{ae})$
，如下图所示。

![局部自适应二值化方法的本文实现的原理（列级）](image/sauvola/stripe.svg)


因此，若按行主序计算各像素的阀值，实现只需维护量
$\displaystyle\displaystyle\sum\_{i-\lfloor\frac{h+1}{2}\rfloor<k\leq i+\lfloor\frac{h}{2}\rfloor}f(I\_{k\ell})$， 
其中$\ell=0, \ldots, W-1$，而不需要积分图像。由公式可见本法中每个像素只需四次加/减法，而由公式可见积分图像法中每个像素需要五次加/减法。由于一旦有了一个像素的阀值就能立即二值化该像素，实现不用记忆阀值。

另一个观察是我们不用显式地计算阀值$T\_{ij}$以达到二值化的目的。注意到在$K$非负的假设下，
$I\_{ij}\leq \mu\_{ij}\left(1+K\left(\frac{\sigma\_{ij}}{R}-1\right)\right)$等价于
$I\_{ij}+\mu\_{ij}(K-1)\leq 0$或$\left(I\_{ij}+\mu\_{ij}\left(K-1\right)\right)^2\leq \frac{K^2\mu\_{ij}^2\sigma\_{ij}^2}{R^2}$。
因此，开根号运算可以代之以远比它快的乘法运算，从而达到强度削减的效果。

结合两个观察，Sauvola方法可以按以下算法实现。为简单起见，我们假设输入图像和输出图像在内存隔离，否则$I\_{i-o, j}$可能被意外地改写。可以修改算法以容许原地二值化，但需要额外空间以保存$oW$个灰度值。

- 输入：
    - 灰度位图$(I\_{ij})\_{0\leq i <H, 0\leq j <W}$ 
    - 窗口的宽度$w$和高度$h$
    - 正参数$K$ 和 $R$
- 输出：
    - 二值位图$(B\_{ij})\_{0\leq i <H, 0\leq j <W}$
- 步骤
    1. $o\leftarrow \lfloor \frac{h+1}{2} \rfloor$;
    2. $u\leftarrow \lfloor \frac{h}{2} \rfloor$;
    3. $l\leftarrow \lfloor \frac{w+1}{2} \rfloor$;
    4. $r\leftarrow \lfloor \frac{w}{2} \rfloor$;
    5. 对于 $j\leftarrow 0$ 直到 $W-1$ 进行
        1. $P\_j\leftarrow 0$;
        2. $Q\_j\leftarrow 0$;
        3. 对于 $i\leftarrow 0$ 直到 $\min\left\\{u-1, H-1\right\\}$ 进行
            1. $P\_j\leftarrow P\_j+I\_{ij}$;
            2. $Q\_j\leftarrow Q\_j+I\_{ij}^2$;
    6. 对于 $i\leftarrow 0$ 直到 $H-1$ 进行
        1. 对于 $j\leftarrow 0$ 直到 $W-1$ 进行
            1. 若 $i-o\geq 0$ 则
                1. $P\_j\leftarrow P\_j-I\_{i-o, j}$;
                2. $Q\_j\leftarrow Q\_j-I\_{i-o, j}^2$;
            2. 若 $i+u<H$ 则
                1. $P\_j\leftarrow P\_j+I\_{i+u, j}$;
                2. $Q\_j\leftarrow Q\_j+I\_{i+u, j}^2$;
        2. $p\leftarrow 0$
        3. $q\leftarrow 0$
        4. 对于 $j\leftarrow 0$ 直到 $\min\left\\{r-1, W-1\right\\}$ 进行
            1. $p\leftarrow p+P\_j$;
            2. $q\leftarrow q+Q\_j$;
        5. 对于 $j\leftarrow 0$ 直到 $W-1$ 进行
            1. 若 $j-l\geq 0$ 则
                1. $p\leftarrow p-P\_{j-l}$;
                2. $q\leftarrow q-Q\_{j-l}$;
            2. 若 $j+r<W$ 则
                1. $p\leftarrow p+P\_{j+r}$;
                2. $q\leftarrow q+Q\_{j+r}$;
            3. $n\leftarrow \left(\min\left\\{j+r, W-1\right\\}-\max\left\\{j-l, -1\right\\}\right)\times \left(\min\left\\{i+u, H-1\right\\}-\max\left\\{i-o, -1\right\\}\right)$;
            4. $m\leftarrow\frac{p}{n}$;
            5. $v\leftarrow\frac{q}{n}-m^2$;
            6. 若$I\_{ij}+m(K-1)\leq 0$ 或 $\left(I\_{ij}+m\left(K-1\right)\right)^2\leq \frac{K^2m^2v}{R^2}$（实现其它Niblack型方法时修改这条件），则$B\_{ij}\leftarrow 0$，否则$B\_{ij}\leftarrow 1$。
    }
}

算法需要$\Theta (W)$辅助空间，不包括输入和输出图像占用的空间。通过调换两个坐标轴，可以实现需要$\Theta (H)$辅助空间的变种。因此，通过在运行时因应高宽比选择一个变种可以使辅助空间需求降至$\Theta (\min\\{H, W\\})$，它明显低于积分图像法所需的$\Theta (HW)$。事实上，$\min\left\\{H, W\right\\}\leq\sqrt{HW}\ll HW$。

另外，更小的中间量意味着可以用更短的整数类型保存。在通常应用中，灰度值从0到255，窗口大小不超过257，由直接计算
$255\times 257=65535=2^{16}-1$而$255\times 255\times 257<2^{32}-1$，可见数组$P$的每个元素只需占用一个无符号16位整数而数组$Q$的每个元素只需占用一个32位整数。作为对比，一页A4文档按600DPI扫描后有多达$8.27\times 11.7 \times 600^2=34833240>2^{32}/255$个像素，所以积分图像的每个元素需要占用一个64位整数以防溢出。综上所述，积分图像法需要约$16HW$个字节的辅助空间，而本算法只需要约$6\min\left\\{H, W\right\\}$个字节的辅助空间。

算法的时间复杂度为$\Theta (HW)$且与窗口大小无关，和积分图像法一样在量级上最优，Sauvola方法不可能有次线性时间的串行实现。因为更低的内存占用意味着更高的缓存命中率，加上加减法次数的减少，速度还可能有所提升。当有多个处理器时，算法可以通过用若干个矩形覆盖输入图像来并行化。

## 其它方法的实现

虽然前文用Sauvola方法为例进行阐述，但同样的技巧也可以用于加速很多其它二值化方法。

只用修改算法中的一个`if`语句中的条件后即可实现大部分基于Niblack方法的局部二值化方法，因为它们的阀值公式也只涉及矩形窗口中的均值和方差（可能还有一些整体量），下表列出了其中一些，其中$L$、$M$和$S$分别为整体最小值、均值和标准差，$\alpha$、$\gamma$、$K$、$K\_1$、$K\_2$、$p$、$q$和$R$均为参数，更多的例子参见有关的综述。显然，这种修改不影响对时间和空间复杂度的分析，所以依然只需$\Theta \left(HW\right)$时间和$O \left(\min\left\\{H, W\right\\}\right)$辅助空间即可二值化一个$H\times W$图像。

Niblack型方法的例子 | 阀值
---|---
Niblack | $\mu\_{ij}+K\sigma\_{ij}$ 
Sauvola和Pietikäinen | $\mu\_{ij}\left(1+K\left(\frac{\sigma\_{ij}}{R}-1\right)\right)$ 
Wolf等人 | $\mu\_{ij}-K\left(\mu\_{ij}-L\right)\left(1-\frac{\sigma\_{ij}}{R}\right)$ 
Feng和Tan | $\alpha\mu\_{ij}+K\_1\left(\frac{\sigma\_{ij}}{R}\right)^{1+\gamma}\left(\mu\_{ij}-L\right)+K\_2\left(\frac{\sigma\_{ij}}{R}\right)^{\gamma}L$
Rais 等人|$\mu\_{ij}+0.3\frac{\mu\_{ij}\sigma\_{ij}-MS}{\max\\{\mu\_{ij}\sigma\_{ij}, MS\\}}\sigma\_{ij}$
Khurshid 等人|$\mu\_{ij}+K\sqrt{\sigma\_{ij}^2+\mu\_{ij}^2\frac{hw-1}{hw}}$
Phansalkar 等人|$\mu\_{ij}\left(1+pe^{-q\mu\_{ij}}+K\left(\frac{\sigma\_{ij}}{R}-1\right)\right)$

注意到局部直方图也可以递推地计算，而最大值、最小值、中位数以至任何分位数都可以从直方图轻易得到，类似方法也能够加速用到相应局部统计量的局部自适应二值化方法。事实上，中值滤波器的一种快速实现就用了这原理。特别地，Bernsen方法只需$\Theta \left(HW\right)$时间和$\Theta \left(\min\left\\{W, H\right\\}\right)$辅助空间。对于Bernsen方法，由于只用到用局部最大值和局部最小值，还有一种巧妙地用最长单调子序列取代直方图的实现，它的时间复杂度量级同样最优但常数因子较低。注意Bernsen方法的直接实现需要$\Theta \left(HWhw\right)$时间和$\Theta \left(1\right)$辅助空间。Otsu方法的局部版本也基于局部直方图，所以可以省去极度耗费内存的积分直方图（典型地每像素占用1 KiB内存）。

基于本法所支持的二值化方法的复合方法也会受惠。例如可以加入预处理和后处理步骤以降噪，修改阀值以消除离群值，或者应用多次局部自适应二值化来找不同大小的文本。另外，一些预处理过程和后处理过程也可用同样方法加速。例如灰度值的范围可用于估计灰度图像的局部对比度，一阶矩可以用于在二值图像中寻找孤立的前景或背景像素。

一般地，本文所用技巧的应用决不限于二值化，它能被应用到图像处理中的一些其它任务以消除积分图像的若干典型用法，并且仍然有在大致保持速度的前提下节省内存的效果。比如说，双边滤镜和导向滤镜之类的滤镜的实现既不需要积分直方图也不需要积分图像，它们的应用包括细节增强、去雾、光照调整、样式化、联合上采样和匹配。由于它们可能需要应用在移动设备如相机上，故计算开销是一个考虑因素。通过一些小修改可得到更大的灵活性，例如滑动窗口的中心不一定为当前像素，多个滑动窗口可以同时考虑等等。然而，它并不能在所有情况下取代积分图像，因为积分图像容许随机访问任意矩形中的总和，而这技巧只能按一定顺序获取总和。

## 速度评测

为了检验本文实现的性能，我们实现了Sauvola方法的三种串行算法：直接算法、基于积分图像的算法和本文提出的算法。我们也同时评测了一些其它方法。所有实验用到的程序已经公开，代码见<https://github.com/chungkwong/binarizer>。

我们测量了二值化来自2009年与2018年间历次文档图像二值化竞赛（the Document Image Binarization COntests，DIBCO）和手写文档图像二值化竞赛（Handwritten Document Image Binarization COmpetitions，H-DIBCO）的116张图片所用的时间。实验在一台带Intel&reg; Core&trade; i5-7500 CPU @ 3.40GHz和8 GB 内存的机器上进行。

不论对Sauvola方法还是Bernsen方法，下图都验证了本文实现的运行时间与窗口大小无关，与直接实现不同。

![窗口大小与二值化运行时间的关系](image/sauvola/time.svg)

下表显示了窗口大小为21时具体的计算时间。对Sauvola方法，本文实现大约比基于积分图像的实现快了一倍，但仍然比Otsu方法慢。值得注意的是，用于避免积分图像的增量方法与强度削减技巧都有助于加速，虽然前者主要为节省内存而引入。

二值化方法|平均运行时间（秒/图片）
---|---
固定阀值|0.00096
Otsu方法|0.00151
Sauvola方法（直接实现）|0.47614
Sauvola方法（积分图像实现）|0.02739
Sauvola方法（积分图像实现加上强度削减）|0.01619
Sauvola方法（本文实现去除强度削减）|0.02458
**Sauvola方法（本文实现）**|**0.01349**
Bernsen方法（直接实现）|0.48895
**Bernsen方法（本文实现）**|**0.07483**

## 结论

我们为一大类常见的局部自适应二值化方法提出了内存高效的快速实现。特别地，假定输入灰度图像大小为$H\times W$而窗口大小为$h\times w$，Sauvola方法和其它Niblack型方法的各种实现的复杂度如表下表所示，本文方法在理论和实验上都明显优于流行的积分图像法，同时时空权衡比直接算法更平衡。

算法|时间复杂度|辅助空间复杂度
---|---|---
直接算法（Sauvola等，2000）|$\Theta (HWhw)$|$\mathbf{\Theta (1)}$
积分图像法（Shafait等，2008）|$\mathbf{\Theta (HW)}$|$\Theta (HW)$
**本文方法（Chan，2019）**|$\mathbf{\Theta (HW)}$|$\Theta (\min\\{H,W\\})$

类似技巧也适用于图像处理中的一些其它任务以消除积分图像的若干典型用法，从而在大致保持速度的前提下节省内存。由于空间和时间对资源受限设备上的实时应用都是重要的，本文算法对其它问题有借镜意义。

**如果您希望在学术论文中引用本算法，请引用<https://arxiv.org/abs/1905.13038>，谢谢。**

```
Chungkwong Chan. Memory-efficient and fast implementation of local adaptive binarization methods. CoRR abs/1905.13038 (2019)
```

```bibtex
@article{DBLP:journals/corr/abs-1905-13038,
  author    = {Chungkwong Chan},
  title     = {Memory-efficient and fast implementation of local adaptive binarization
               methods},
  journal   = {CoRR},
  volume    = {abs/1905.13038},
  year      = {2019},
  url       = {http://arxiv.org/abs/1905.13038},
  archivePrefix = {arXiv},
  eprint    = {1905.13038},
  timestamp = {Thu, 30 May 2019 13:17:18 UTC},
  biburl    = {https://dblp.org/rec/journals/corr/abs-1905-13038.bib},
  bibsource = {dblp computer science bibliography, https://dblp.org}
}
```