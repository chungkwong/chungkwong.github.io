---
title:  "联机手写文档分析的现状与未来"
layout: post
tags: 文档分析
---

随着触摸屏和笔式输入设备的普及，人们可以用电子设备代替传统的纸张作为书写的介质，从而更便于共享。不过，仅仅记录书写的轨迹并未充分体现电子化的优势，为了更好地支持编辑、搜索和各种自动化处理，还需要把手写的内容转换为更结构化的形式。与通过扫描或拍照等方式获取的手写文档图片相比，轨迹不但提供了时间、坐标和其它信息（如压感、倾斜角），而且夹杂了更少的的背景噪声，这就使得联机手写文档分析有比脱机手写文档分析做得更好的可能性。然而，做到完美仍然不太可能，所以如何利用不准确的结果就成为实用化的关键。

## 文档分析的任务

传统的联机手写文档分析一般先把笔画分成若干个对象并判断它们的类型，然后再分别识别它们的详细内容，前者被称为版面分析而后者被称为手写识别。这里所说的典型对象包括文本行、公式和绘画等等。

以下是一些现成的SDK:
- MyScript的[Interactive ink](https://developer.myscript.com/)支持约70种自然语言的文本，另外支持数学公式识别和图表识别。
- Google的[ML Kit](https://developers.google.cn/ml-kit/vision/digital-ink-recognition)支持超过300种语言的文本，另外支持形状识别。
- Microsoft的[Win32 API](https://learn.microsoft.com/en-us/windows/win32/tablet/ink-analysis-overview)同时支持版面分析和文本识别。

## 现有的主流技术

固然，我们可以把轨迹渲染为图片再使用脱机文档分析的技术，甚至可以通过把时间等信息嵌入到图像中以避免信息丢失，但这里主要简介联机手写能用的额外技术。

### 版面分析

- 循环神经网络。假设对象间不存在倒笔的情况（即用户写完一个对象再写下一对象），通过判断每条笔画是否与前一笔画属于同一对象，即可以完成对笔迹的分割。同时，还可以通过判断每条笔画所属对象的类型来得到各对象的类型。利用简单的循环神经网络来提取笔画级特征就能实现这两个目的。在需要支持对象间倒笔时，就需要再加上一个步骤来把被过切分的对象合并回来。这个方法简单高效，但不适合倒笔较多的乱写场景。更多细节参见：
    - [HCRNN: A Novel Architecture for Fast Online Handwritten Stroke Classification](https://doi.org/10.1007/978-3-030-86331-9_13)
    - [Spatio-temporal Clustering for Grouping in Online Handwriting Document Layout Analysis with GRU-RNN](https://doi.org/10.1109/ICFHR2020.2020.00058)
- 图神经网络。通过把笔划当作顶点而把在空间或时间上接近的笔画对应的顶点间用边连起，就可以把笔迹看作一个图。于是，把笔迹分割为对象的问题就可以化为对边进行分类的问题（区分两个端点对应的笔画是否属于同一对象），而对对象分类的问题则化为对顶点进行分类的问题（区分相应笔画所属对象的类型）。在这个基础上，还可以得到文档的层次结构，例如可以把分行和分段一起做。这样，图注意力神经网络就可以用上了。这个方法相当一般，文本检测、行分割、表格分析、流程图分析以及数学公式识别等任务都可以用本法处理。更多细节参见：
    - [Joint stroke classiﬁcation and text line grouping in online handwritten documents with edge pooling attention networks](https://doi.org/10.1016/j.patcog.2021.107859)
    - [Table detection and cell segmentation in online handwritten documents with graph attention networks](https://doi.org/10.1145/3444685.3446295)

### 识别

以典型的文字识别为例，我们列出一些标准的方法：
- 切分解码方法。这种方法先生成把行分成字符的多种切分方式，然后对各字符假设进行评分，最后选取最优的切分方式和字符串，参见[Multi-Language Online Handwriting Recognition](https://doi.org/10.1109/TPAMI.2016.2572693)。
- 基于CTC解码的方法。这种方法一般先用双向循环神经网络提取点级别的特征，然后用CTC算法解码，参见[Fast multi-language LSTM-based online handwriting recognition](https://doi.org/10.1007/s10032-020-00350-4)。这种方法的识别速度较快，但对输入作出了较强的假设。比如说，它假设输入和输出间有单调的对齐，即写完一个字符再写下一个字符，因此在存在影响识别的字间倒笔时，可能要检测它们并重排，或者另加特征。同时，它不擅长生成格式化标记（如LaTeX代码），故用于识别数学公式时，就只能做字符切分与识别，结构分析要留给其它算法，参见[Acceleration of Online Recognition of 2D Sequences Using Deep Bidirectional LSTM and Dynamic Programming](https://doi.org/10.1007/978-3-030-20518-8_37)。
- 基于自回归解码的方法。编码器一般仍然是双向循环神经网络，解码器则一般带有注意力机制以优化对非单调的对齐的支持，并加上某种某种收敛机制以抑制多识别和漏识别的情况。这种方法通用性较强而且可以学习语言模型，但由于要多次调用解码器以逐个输出符号或树结点，识别速度相对较慢。
    - 序列解码器。参见[Track, Attend, and Parse (TAP): An End-to-End Framework for Online Handwritten Mathematical Expression Recognition](https://doi.org/10.1109/TMM.2018.2844689)。
    - 树解码器。参见[SRD: A Tree Structure Based Decoder for Online Handwritten Mathematical Expression Recognition](https://doi.org/10.1109/tmm.2020.3011316)。


以公式识别为例，我们列出调参以外的一些可能可提高准确率的策略：
- 数据增强。为了提高识别系统的泛化能力，可以通过合成数据来提高训练样本的多样性，从而抑制过度拟合。
    - 取子公式和进行随机仿射变换。参见[Syntactic data generation for handwritten mathematical expression recognition](https://doi.org/10.1016/j.patrec.2021.12.002)。
    - 通过笔画提取利用图片形式的样本。参见[Stroke Extraction for Offline Handwritten Mathematical Expression Recognition](https://doi.org/10.1109/ACCESS.2020.2984627)。
    - 设计某种按LaTeX或MathML代码合成相应手写样本的工具，然后基于能批量爬取的语料（也可以混入一些随机生成的）去生成大量样本。这些样本天然地带符号与笔画间的对应关系，可以用于引导注意力系数接近真实的对齐。
- 多任务学习。通过设计其它与识别任务共用部分参数的任务并与识别任务一起训练，可以引导模型学习到更通用的知识。
    - 预测从后到前的序列。参见[Handwritten Mathematical Expression Recognition with Bidirectionally Trained Transformer](https://doi.org/10.1007/978-3-030-86331-9_37)。
    - 预测各符号的出现次数。参见[When Counting Meets HMER: Counting-Aware Network for Handwritten Mathematical Expression Recognition](https://doi.org/10.48550/arXiv.2207.11463)。
- 限制识别范围。序列解码器有时会输出不合法的输出（如产生花括号不配对的LaTeX代码）或者输出应用场景不允许的结果（如在数字字段输出“lO”而非“10”）。通过约束识别范围可以确保结果合法并区分相似的符号。
    - 利用上下文无关语法来限制识别识别。参见[Syntax-Aware Network for Handwritten Mathematical Expression Recognition](https://doi.org/10.1109/CVPR52688.2022.00451)。
    - 在语法为LL(1)的情况下（原理上也适用于LL(k)语法），对序列解码过程作轻微的修改即可把预测分析法整合到集束搜索中。
- 与脱机识别模型或语言模型相结合。联机识别模型更着重于时间信息，脱机识别模型更着重于空间信息，语言模型则着重于上下文信息，它们之间有互补性，故组合模型往往比单个模型更可靠。
    - 利用语言困惑度或其它模型对候选公式进行重新排序。
    - 利用n-gram或其它生成模型调整各候选符号的置信度。

## 参考资源

要进入联机手写文档分析领域的话，在公开的数据集上复现前沿论文的工作是一个不错的出发点。

### 数据集

数据集是开发联机手写技术的基本材料，以下是笔者知道的部分联机手写数据集：

数据集|来源|内容|主要用途
---|---|---|---
[IAMonDo](http://www.iapr-tc11.org/mediawiki/index.php/IAM_Online_Document_Database_(IAMonDo-database))|伯恩大学|英文文档|版面分析
[Kondate](http://web.tuat.ac.jp/~nakagawa/database/en/kondate_about.html)|东京农工大学|日文、泰文和英文文档|版面分析
[CASIA-onDo](http://www.nlpr.ia.ac.cn/databases/CASIA-onDo/index.html)|中科院|中文和英文文档|版面分析
[Unipen](https://zenodo.org/record/1195803)|Unipen基金会|英文字符、词和行|文字识别
[IAMonDB](https://fki.tic.heia-fr.ch/databases/iam-on-line-handwriting-database)|伯恩大学|英文文本行|文字识别、手写合成
[VNOnDB](https://tc11.cvc.uab.es/datasets/HANDS-VNOnDB2018_1)|东京农工大学|越南文词、行和段落|文字识别
[CASIA OLHWDB](http://www.nlpr.ia.ac.cn/databases/handwriting/Online_database.html)|中科院|汉字字符和中文文本行|文字识别
[SCUT-COUCH2009](http://hcii-lab.net/data/scutcouch/EN/introduction.html)|华南理工大学|汉字字符、词、拼音和中文文本行|文字识别
[SCUT-onHCCTestDB](http://hcii-lab.net/data/onHCCTestdataset/onHCCTest.html)|华南理工大学|汉字字符|文字识别
[HIT-OR3C](http://www.iapr-tc11.org/mediawiki/index.php/Harbin_Institute_of_Technology_Opening_Recognition_Corpus_for_Chinese_Characters_(HIT-OR3C))|哈工大|汉字字符|文字识别
[Nakayosi](http://web.tuat.ac.jp/~nakagawa/database/en/about_nakayosi.html)|东京农工大学|日文字符|文字识别
[Kuchibue](http://web.tuat.ac.jp/~nakagawa/database/en/about_kuchibue.html)|东京农工大学|日文字符|文字识别
[ADAB](https://ieee-dataport.org/open-access/adab-database)|斯法克斯大学|阿拉伯文地名|文字识别
[AltecOnDB](https://www.altec-center.org/filescms/files/)|ALTEC|阿拉伯文|文字识别
[Online-KHATT](http://onlinekhatt.ideas2serve.net/)|混合|阿拉伯文字符和句子|文字识别
[Omniglot](https://github.com/brendenlake/omniglot)|混合|多语言字符|语言检测
[CROHME](https://tc11.cvc.uab.es/datasets/ICDAR2019-CROHME-TDF_1)|混合|数学公式|公式识别
[Detexify](https://github.com/kirel/detexify-data)|Kirel|数学符号|公式识别
[HWRT](https://zenodo.org/record/50022)|Martin Thoma|数学符号|公式识别
[HOMUS](https://grfia.dlsi.ua.es/homus/)|阿利坎特大学|音符|音符识别
[Quick draw](https://github.com/googlecreativelab/quickdraw-dataset)|Google|手绘|形状识别
[CASIA OHFC](http://www.nlpr.ia.ac.cn/databases/CASIA-OHFC/index.html)|中科院|流程图|图表识别
[OHFCD](https://tc11.cvc.uab.es/datasets/OHFCD_1)|南特大学|流程图|图表识别
[FC](https://cmp.felk.cvut.cz/~breslmar/flowcharts/)|捷克技术大学|流程图|图表识别
[FA](https://cmp.felk.cvut.cz/~breslmar/finite_automata/)|捷克技术大学|有限自动机|图表识别
[SigComp2009](http://www.iapr-tc11.org/mediawiki/index.php/ICDAR_2009_Signature_Verification_Competition_(SigComp2009))|DFKI|签名|签名鉴定
[SigComp2011](http://www.iapr-tc11.org/mediawiki/index.php/ICDAR_2011_Signature_Verification_Competition_(SigComp2011))|DFKI|中文和荷兰文签名|签名鉴定
[SigWiComp2013](https://tc11.cvc.uab.es/datasets/SigWiComp2013_1)|DFKI|日文签名|签名鉴定
[DeepSignDB](https://github.com/BiDAlab/DeepSignDB)|混合|签名|签名鉴定

### 论文

如果希望了解本领域的进展，可以跟进本领域比较有影响力的期刊和会议上发表论文。

会议|年份
---|---
International Conference on Document Analysis and Recognition (ICDAR)|单数年份
International Conference on Frontiers of Handwriting Recognition (ICFHR)|双数年份

期刊|类型
---|---
[International Journal on Document Analysis and Recognition (IJDAR)](https://www.springer.com/journal/10032)|季刊
[Pattern Recognition](https://www.sciencedirect.com/journal/pattern-recognition)|月刊
[Pattern Recognition Letters](https://www.sciencedirect.com/journal/pattern-recognition-letters)|月刊

另外，可以重点关注在本领域有影响力的团队发表的论文，以及它们的参考文献与引用它们的论文。

团队带头人|单位
---|---
[Cheng-Lin Liu (刘成林)](https://people.ucas.ac.cn/~liuchenglin)|中科院
[Lianwen Jin (金连文)](http://www.hcii-lab.net/lianwen/)|华南理工大学
[Jun Du](http://staff.ustc.edu.cn/~jundu/)|中国科学技术大学
[Harold Mouchère](http://pagesperso.ls2n.fr/~mouchere-h/index.php?lg=en)|南特大学
[Masaki Nakagawa](http://web.tuat.ac.jp/~nakagawa/en/nakagawa.html)|东京农工大学
[Richard Zanibbi](https://www.cs.rit.edu/~rlaz/)|罗切斯特理工学院
Olga Radyvonenko|三星研发部（乌克兰）

最后，也可以去预印本网站如[ArXiv](https://arxiv.org/)或论文搜索引擎如[Semantic scholar](https://www.semanticscholar.org/)搜索有关关键词。

## 未来的可能方向

纵使未来无法预知，但凭经验来说，笔者认为以下方向有较大的发展空间：

1. 交互设计。在文档分析系统不容易取得突破的前提下，良好的交互设计正是提高用户体验的关键。呈现和修正文档分析结果的方式有很多可以探索的地方，与键盘和语音等其它输入方式的结合有时也可以弥补手写的弱点。
2. 结果的自动化验证。假如可以较准确地判断结果是否正确并向用户提示可能的错误位置，将可以大幅减低用户校对所需的时间。即使现在的文档分析系统往往能给出置信度，但它们通常并不能准确地反映结果正确的概率（例如不意味着100个置信度99%的结果中大约有99个正确），还需要进行校准或利用其它算法估算。
3. 错误感知的应用。在一些场景下，应用可能应该尝试利用不完全准确识别结果。例如，检索系统可以利用识别候选或识别系统的混淆矩阵做查询扩展，从而提高召回率。又如，在电话号码、证件号和邮箱等输入框，可以把结果限制/修正到相应范围。
4. [无标注笔迹的利用](https://doi.org/10.1109/SMC52423.2021.9658867)。云端存储、分析与识别服务可以收集到大量笔迹，而人手对它们进行标注成本高昂且难以保障用户的隐私，因此如何自动化地利用这些笔迹来优化文档分析系统就是一个重要的课题。半监督学习和联邦学习中的技巧也许可以派上用场。
5. 少样本定制。在只有少量样本或先验知识的情况下支持一个字符或者一种版面有利于提高文档分析系统的可定制性。这可能可以通过设计或学习字符或版面的抽象特征来实现。
6. 用户习惯自适应。每个用户的书写风格和惯用语都不同，通过逐渐学习用户的特点，可以让软件越用越好用。
7. 其它手写对象的识别。设计通用的框架去识别乐谱、化学结构式和各种工程图等等可扩展手写的应用范围。