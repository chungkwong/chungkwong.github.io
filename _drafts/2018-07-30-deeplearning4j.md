---
title:  "浅谈Deeplearning4j深度学习"
layout: post
mathjax: true
tags: 人工智能 java
---

人工神经网络近年在机器学习中可谓一枝独秀，对自然语言处理（如机器翻译）和计算机视觉（如对象识别）等领域的进步起了重大作用。[Deeplearning4j](https://deeplearning4j.org)（DL4J）是Java世界中比较流行的深度学习库，值得了解一下。

## 基本概念

映射是数学最核心的概念，众多问题（但不是全部）都可以视为映射：
- 人脸识别可以视为一个从人脸图片集到人集的映射，把人脸图片对应到人脸所属的人
- 机器翻译可以视为一个从字符串集到字符串集的映射，把来自一个语言的字符串对应到另一语言中语义相同的字符串

对于给定的映射$f:X\to Y$，我们希望对于每个定义域中的值$x$，可以用计算机算出$f(x)$。对于一些对计算机来说是精确叙述的问题如排序，这是可能严格做到的。但对于人脸识别和机器翻译之类的问题，由于涉及到计算机以外的复杂概念，通常不能期望能完全准确地算出。于是，我们退而求其次，找一个能够计算的映射$g$去近似$f$，并且在某种意义下$f$与$g$接近。在过去，人们通过观察去设计这个近似映射$g$，但对于复杂问题人手设计的启发式规则很快会变得难以维护，而且针对个别问题的方法往往过于特殊，导致重复劳动还不利于总结提高。为了用统一的框架解决不同的问题，人们又想办法自动地构造近似映射$g$。当然我们必须给出关于$f$的一些信息才可能完成这构造，通常给出映射在部分点处的值$(x\_1,f(x\_1)),\dots,(x\_M,f(x\_M))$，由此构造$g$的方法叫机器学习。显然即使给定了一个映射在一些点的值，它在其它点处的值仍然可以是任意的，机器学习只能建基于映射能够被相当“简单”的映射逼近的信念。机器学习方法本质上就是假设假定$f$可以被某族映射$\\{g(\cdot;\theta\_1,\dots,\theta\_N)\\}$逼近，然后算出参数$\theta\_1,\dots,\theta\_N$的估计值使$f$与$g$在已知点处的值接近。可见，与基于大数定律的统计方法一样，只有在数据足够多时我们才能指望学习得出的映射$g$确实能近似$f$。幸运的是，随着互联网的兴起，数据源源不断地从人和各种传感器产生，收集数据变得容易，机器学习因而在许多问题变得可行。

由于数学方法一般在欧氏空间中最好处理，因此往往设计一种编码$e: X\to \mathbb{R}^k$把$f$定义域中的对象对应到某个固定维数的欧氏空间，再设计一种解码单射$d: \mathbb{R}^l\to Y$把某个固定维数的欧氏空间中向量对应到$f$值域中的对象，从而可以把问题归结为寻找近似映射$h:\mathbb{R}^k\to\mathbb{R}^l$再令$g=d\circ h\circ e$即可。例如图像可以对应到各像素亮度组成的向量，而文章可以对应到各单词频率组成的向量。

人工神经网络实际上是通过对“简单映射”进行复合来构造逼近函数族的方法，其中的“简单映射”称为神经元。人工神经网络可以用图直观地表示，其中每个顶点是神经元，值沿着有向边在神经元间流动，直至到达输出神经元成为整个逼近映射的值的一个分量。设计人工神经网络时把它分为若干层，大多数边从一层指向下一层。反馈神经网络中也可能存在反向的边，和时序电路中用类似方法实现记忆类似，这种设计被认为可模拟人“越想越像”的记忆，有利于上下文感知。所谓深度学习说是就是层数较多的意思，通常认为后面的层次保存了较高层次（更整体）的信息。

最后指出，虽然上面主要谈监督学习。但某些非监督学习问题可转化为监督学习问题。例如有损压缩问题相当于寻找压缩函数$f:X\to Y$和解压函数$g:Y\to X$使$g\circ f$在某种意义下接近恒同映射，于是我们可以设计一个神经网络，各层中神经元个数先是递减再递增，输入数与输出数相同，数据集中数据同时用作输入和输出去训练网络，最后前半个神经网络就可作为压缩器而后半个神经网络就可作为解压器。类似技术还可以用于生成文本或图像之类。

## 预备

和使用其它库一样，首先需要声明依赖关系，例如对Maven项目，在`pom.xml`中加入以下样子的内容：

```xml
<dependencies>
	<dependency>
		<groupId>org.nd4j</groupId>
		<artifactId>${nd4j.backend}</artifactId>
		<version>${nd4j.version}</version>
	</dependency>
	<dependency>
		<groupId>org.deeplearning4j</groupId>
		<artifactId>deeplearning4j-core</artifactId>
		<version>${dl4j.version}</version>
	</dependency>
</dependencies>
<properties>
	<!-- 另一个选择是用CUDA：nd4j-cuda-8.0-platform, nd4j-cuda-9.0-platform或 nd4j-cuda-9.1-platform -->
	<nd4j.backend>nd4j-native-platform</nd4j.backend>
	<nd4j.version>1.0.0-beta</nd4j.version>
	<dl4j.version>1.0.0-beta</dl4j.version>
</properties>
```

由于DL4J用到了本地库，默认情况下Maven会把所有所有平台的本地库都纳入到类路径，这可能导致类加载失败。这时可以加上类似`-Djavacpp.platform=linux-x86_64`（改成你的平台）的选项来限制只加载适用平台的本地库。

```
package com.github.chungkwong.example.dl4j;
import java.io.*;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.logging.*;
import org.datavec.api.io.labels.ParentPathLabelGenerator;
import org.datavec.api.split.FileSplit;
import org.datavec.image.loader.NativeImageLoader;
import org.datavec.image.recordreader.ImageRecordReader;
import org.deeplearning4j.datasets.datavec.RecordReaderDataSetIterator;
import org.deeplearning4j.eval.Evaluation;
import org.deeplearning4j.nn.conf.MultiLayerConfiguration;
import org.deeplearning4j.nn.conf.NeuralNetConfiguration;
import org.deeplearning4j.nn.conf.inputs.InputType;
import org.deeplearning4j.nn.conf.layers.ConvolutionLayer;
import org.deeplearning4j.nn.conf.layers.DenseLayer;
import org.deeplearning4j.nn.conf.layers.OutputLayer;
import org.deeplearning4j.nn.conf.layers.SubsamplingLayer;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.nn.weights.WeightInit;
import org.deeplearning4j.optimize.listeners.ScoreIterationListener;
import org.deeplearning4j.util.ModelSerializer;
import org.nd4j.linalg.activations.Activation;
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator;
import org.nd4j.linalg.dataset.api.preprocessor.DataNormalization;
import org.nd4j.linalg.dataset.api.preprocessor.ImagePreProcessingScaler;
import org.nd4j.linalg.learning.config.Nesterovs;
import org.nd4j.linalg.lossfunctions.LossFunctions;
import org.nd4j.linalg.schedule.MapSchedule;
import org.nd4j.linalg.schedule.ScheduleType;
public class MnistRecognizer{
	private static final Logger log=Logger.getLogger(MnistRecognizer.class.getName());
	//从http://github.com/myleott/mnist_png/raw/master/mnist_png.tar.gz下载再解压
	private static final String basePath="数据集路径";
	public static void main(String[] args) throws Exception{
		int height=28;
		int width=28;
		int channels=1; // single channel for grayscale images
		int outputNum=10; // 10 digits classification
		int batchSize=54;
		int nEpochs=1;
		int iterations=1;
		int seed=1234;
		Random randNumGen=new Random(seed);
		log.info("Data load and vectorization...");
		// vectorization of train data
		File trainData=new File(basePath+"/mnist_png/training");
		FileSplit trainSplit=new FileSplit(trainData,NativeImageLoader.ALLOWED_FORMATS,randNumGen);
		ParentPathLabelGenerator labelMaker=new ParentPathLabelGenerator(); // parent path as the image label
		ImageRecordReader trainRR=new ImageRecordReader(height,width,channels,labelMaker);
		trainRR.initialize(trainSplit);
		DataSetIterator trainIter=new RecordReaderDataSetIterator(trainRR,batchSize,1,outputNum);
		// pixel values from 0-255 to 0-1 (min-max scaling)
		DataNormalization scaler=new ImagePreProcessingScaler(0,1);
		scaler.fit(trainIter);
		trainIter.setPreProcessor(scaler);
		// vectorization of test data
		File testData=new File(basePath+"/mnist_png/testing");
		FileSplit testSplit=new FileSplit(testData,NativeImageLoader.ALLOWED_FORMATS,randNumGen);
		ImageRecordReader testRR=new ImageRecordReader(height,width,channels,labelMaker);
		testRR.initialize(testSplit);
		DataSetIterator testIter=new RecordReaderDataSetIterator(testRR,batchSize,1,outputNum);
		testIter.setPreProcessor(scaler); // same normalization for better results
		log.info("Network configuration and training...");
		Map<Integer,Double> lrSchedule=new HashMap<>();
		lrSchedule.put(0,0.06);
		lrSchedule.put(200,0.05);
		lrSchedule.put(600,0.028);
		lrSchedule.put(800,0.0060);
		lrSchedule.put(1000,0.001);
		MultiLayerConfiguration conf=new NeuralNetConfiguration.Builder()
				.seed(seed)
				.l2(0.0005)
				.updater(new Nesterovs(new MapSchedule(ScheduleType.ITERATION,lrSchedule)))
				.weightInit(WeightInit.XAVIER)
				.list()
				.layer(0,new ConvolutionLayer.Builder(5,5)
						.nIn(channels)
						.stride(1,1)
						.nOut(20)
						.activation(Activation.IDENTITY)
						.build())
				.layer(1,new SubsamplingLayer.Builder(SubsamplingLayer.PoolingType.MAX)
						.kernelSize(2,2)
						.stride(2,2)
						.build())
				.layer(2,new ConvolutionLayer.Builder(5,5)
						.stride(1,1) // nIn need not specified in later layers
						.nOut(50)
						.activation(Activation.IDENTITY)
						.build())
				.layer(3,new SubsamplingLayer.Builder(SubsamplingLayer.PoolingType.MAX)
						.kernelSize(2,2)
						.stride(2,2)
						.build())
				.layer(4,new DenseLayer.Builder().activation(Activation.RELU)
						.nOut(500).build())
				.layer(5,new OutputLayer.Builder(LossFunctions.LossFunction.NEGATIVELOGLIKELIHOOD)
						.nOut(outputNum)
						.activation(Activation.SOFTMAX)
						.build())
				.setInputType(InputType.convolutionalFlat(28,28,1)) // InputType.convolutional for normal image
				.backprop(true).pretrain(false).build();
		MultiLayerNetwork net=new MultiLayerNetwork(conf);
		net.init();
		net.setListeners(new ScoreIterationListener(10));
		log.log(Level.INFO,"Total num of params: {}",net.numParams());
		// evaluation while training (the score should go down)
		for(int i=0;i<nEpochs;i++){
			net.fit(trainIter);
			log.log(Level.INFO,"Completed epoch {}",i);
			Evaluation eval=net.evaluate(testIter);
			log.info(eval.stats());
			trainIter.reset();
			testIter.reset();
		}
		ModelSerializer.writeModel(net,new File(basePath+"/model.zip"),true);
	}
}

```

## 预处理

如前所述，数据要转化为欧氏空间中向量的形式才能进入神经网络，因此需要提取、转换和加载的过程（ETL）。

### 提取

`InputSplit`接口管理数据位置，它的实现包括：
- `CollectionInputSplit`记录Uri数组或容器
- `FileSplit`记录根目录，并可设置递归、随机化和容许的文件格式
- `InputStreamInputSplit`记录`InputStream`
- `ListStringSplit`记录`java.util.List<java.util.List<java.lang.String>>`
- `NumberedFileInputSplit`记录含序号文件名模式（模式中用`%d`表示序号）和序号范围
- `OutputStreamInputSplit`记录`OutputStream`
- `StringSplit`记录`String`
- `TransformSplit`记录一个`BaseInputSplit`和施加的转换

`InputFormat`接口中方法`RecordReader createReader(InputSplit split)`或`RecordReader createReader(InputSplit split`
- `Configuration conf)`用于返回`RecordReader`。它的实现包括：
- `BaseInputFormat`
- `CodecInputFormat`
- `CSVInputFormat`
- `ImageInputFormat`
- `LibSvmInputFormat`
- `LineInputFormat`
- `ListStringInputFormat`
- `MatlabInputFormat`
- `SVMLightInputFormat`
- `TextInputFormat`
- `WavInputFormat`

`RecordReader`接口用于把原始数据转换为一系列记录，其中使用前用`void initialize(Configuration conf, InputSplit split)`或`void initialize(InputSplit split)`初始化它。它的实现包括：
- `ArrowRecordReader`
- `BaseAudioRecordReader`
- `BaseCodecRecordReader`
- `BaseImageRecordReader`
- `BaseRecordReader`
- `CodecRecordReader`
- `CollectionRecordReader`
- `CollectionSequenceRecordReader`
- `ComposableRecordReader`
- `ConcatenatingRecordReader`
- `CSVNLinesSequenceRecordReader`
- `CSVRecordReader`
- `CSVRegexRecordReader`
- `CSVSequenceRecordReader`
- `CSVVariableSlidingWindowRecordReader`
- `ExcelRecordReader`
- `FileRecordReader`
- `ImageRecordReader`
- `InMemoryRecordReader`
- `InMemorySequenceRecordReader`
- `JacksonLineRecordReader`
- `JacksonRecordReader`
- `JDBCRecordReader`
- `LibSvmRecordReader`
- `LineRecordReader`
- `ListStringRecordReader`
- `LocalTransformProcessRecordReader`
- `LocalTransformProcessSequenceRecordReader`
- `MapFileRecordReader`
- `MapFileSequenceRecordReader`
- `MatlabRecordReader`
- `NativeAudioRecordReader`
- `NativeCodecRecordReader`
- `ObjectDetectionRecordReader`
- `RegexLineRecordReader`
- `RegexSequenceRecordReader`
- `SVMLightRecordReader`
- `TfidfRecordReader`
- `TransformProcessRecordReader`
- `TransformProcessSequenceRecordReader`
- `VideoRecordReader`
- `WavFileRecordReader`

### 加载

`DataSetIterator`接口用于迭代小批次数据，每次返回一个`DataSet`，最多有一个输入和一个输出数组。`MultiDataSetIterator`类似，但返回`MultiDataSet`。前者的实现包括：
- `CachingDataSetIterator`支持缓存
- `ExistingMiniBatchDataSetIterator`读入现有的小批次数据
- `KFoldIterator`支持k趟交叉验证
- `MiniBatchFileDataSetIterator`支持把数据分成小批次
- `MultipleEpochsIterator`支持多趟处理
- `SamplingDataSetIterator`支持随机抽样
- `ViewIterator`支持视图
- `RecordReaderDataSetIterator`从`RecordReader`读取数据

它们可以通过`setPreProcessor(DataSetPreProcessor preProcessor)`方法设置预处理器：
- `ImagePreProcessingScaler`把0到255转化为0到1
- `NormalizerMinMaxScaler`把最小值和最大值分别放到0和1
- `NormalizerStandardize`把各特征分别正规化为均值0方差1
- `VGG16ImagePreProcessor`减去平均RGB值

注意部分需要统计值的预处理器用之前需要调用调用其`fit`方法。

## 网络

人工神经网络配置用类`MultiLayerConfiguration`的对象表示，要配置它可以使用的流式API，先创建Builder：`new NeuralNetConfiguration.Builder()`，然后通过调用它的各个方法进行配置，最后调用`build()`。

### 层

要创建`MultiLayerNetwork`，调用`list()`方法后再使用`layer`方法可以加入层。

层有一些常见选项可以设置：

- `nIn`
- `nOut`可设置
- `InputPreProcessor`用于对输入预处理，但通常不用手工设置。

类|说明
---|---
`CnnToFeedForwardPreProcessor`|从CNN层到DenseLayer、OutputLayer等
`CnnToRnnPreProcessor`|从CNN层到RNN层
`ComposableInputPreProcessor`|一串预处理器
`FeedForwardToCnnPreProcessor`|从行向量到CNN层
`FeedForwardToRnnPreProcessor`|处理前馈层到RNN层的转换
`RnnToCnnPreProcessor`|把CNN激活序列[minibatch, depth*height*width, timeSeriesLength]转换为 [numExamples*timeSeriesLength, numChannels, inputWidth, inputHeight] 格式
`RnnToFeedForwardPreProcessor`|把时间序列激活 [minibatch,size,timeSeriesLength]转换为 [minibatch*tsLength,size]

#### 前馈层

类|说明
---|---
`DenseLayer`|全连通层
`EmbeddingLayer`|输入正整数输出向量，只能用于首层

#### 输出层

用作最后一层，可设置损失函数。

类|说明
---|---
`OutputLayer`|标准的MLP/CNN分类/回归输出层，内置全连通层，二维输入和输出（每个样本一个行向量）
`LossLayer`|无参输出层，只有损失和激活函数，二维输入和输出（每个样本一个行向量），要求 nIn = nOut
`RnnOutputLayer`|用于反馈神经网络，3维（时间序列）输入和输出，内置时分全连通层
`RnnLossLayer`|`RnnOutputLayer`的无参版本，3维输入和输出
`CnnLossLayer`|CNN中对每个位置作出预测，无参数，输入输出形如[minibatch, depth, height, width]
`Yolo2OutputLayer`|图片对象检测
`CenterLossOutputLayer`|`OutputLayer`企图最小化类中激活间距离的变种

#### 卷积层

类|说明
---|---
`ConvolutionLayer`/`Convolution2D`|标准二维卷积层，输入输出形如 [minibatch,depth,height,width]
`Convolution1DLayer`/`Convolution1D`|标准一维卷积层
`Deconvolution2DLayer`|转置卷积，输出通常比输入大
`SeparableConvolution2DLayer`|分深度的卷积层
`SubsamplingLayer`|通过最大值、平均或p范数缩小
`Subsampling1DLayer`|上面的一维版本
`Upsampling2D`|通过重复行/列的值放大
`Upsampling1D`|上面的一维版本
`Cropping2D`|裁剪层
`ZeroPaddingLayer`|在边沿填充0
`ZeroPadding1DLayer`|上面的一维版本
`SpaceToDepth`|把两个空间维数据按块转换为通道维
`SpaceToBatch`|把两个空间维数据按块转换为批次维

#### 反馈层

类|说明
---|---
`LSTM`|没有窥孔连接的LSTM RNN，支持CuDNN
`GravesLSTM`|有窥孔连接LSTM RNN，不支持CuDNN (故对于GPU, 宜用LSTM)
`Bidirectional`|把单向的RNN包装成双向RNN（前向和反向有独立的参数）
`SimpleRnn`|标准/’vanilla’ RNN层，由于大多长时依赖而不实用
`LastTimeStep`|提取所包装（非双向）RNN层的最后时间步把[minibatch, size, timeSeriesLength]转换为 [minibatch, size]

#### 非监督层

类|说明
---|---
`VariationalAutoencoder`|编码解码器的可变实现，支持多种重构分布
`AutoEncoder`|标准去噪自动编码器层

#### 其它层

类|说明
---|---
`GlobalPoolingLayer`|求和、平均、最大值或p范数，对RNN/时间序列输入[minibatch, size, timeSeriesLength]输出[minibatch, size]，对CNN输入[minibatch, depth, h, w]输出[minibatch, depth]
`ActivationLayer`|对输入应用激活函数 
`DropoutLayer`|把丢弃实现为层
`BatchNormalization`|批次正规化 2d (前馈), 3d (时间序列，参数与时间无关) or 4d (CNN，参数与空间位置无关)
`LocalResponseNormalization`|CNN的局部响应正规化层，不常用
`FrozenLayer`|用于转移学习的冻结层（进一步训练时参数不变）

### 顶点

要创建更灵活的`ComputationGraph`，可以调用`graphBuilder()`后使用`addVertex`方法。

类|说明
---|---
`ElementWiseVertex`|对输入元素进行运算如加、减、乘、平均、最值
`L2NormalizeVertex`|用L2范数正规化输入
`L2Vertex`|计算两个数组间的L2距离
`MergeVertex`|沿维数1合并输入产生更大的输出数组
`PreprocessorVertex`|只有`InputPreProcessor`
`ReshapeVertex`|进行任意数组重整，但通常应首先考虑预处理器
`ScaleVertex`|把输入乘以一个常数
`ShiftVertex`|把输入加上一个常数
`StackVertex`|沿维数0合并输入产生更大的输出数组
`SubsetVertex`|沿维数1（nOut/通道）取输入的子集
`UnstackVertex`|沿维数0（小批次）取输入的子集

### 参数初始值

网络中的初始参数设置方式可以用`weightInit`方法配置，部分常见值有：

`WeightInit`枚举常量|说明
---|---
`DISTRIBUTION`|由`dist`方法指定分布给出
`ZERO`|0
`ONES`|1
`SIGMOID_UNIFORM`|均匀分布 U(-r,r) 其中 r=4*sqrt(6/(fanIn + fanOut))
`NORMAL`|正态分布，均值 0 ，方差 1/sqrt(fanIn)
`LECUN_UNIFORM`|均匀分布 U[-a,a] 其中 a=3/sqrt(fanIn).
`UNIFORM`|均匀分布 U[-a,a] 其中 a=1/sqrt(fanIn)
`XAVIER`|正态分布，均值 0, 方差 2.0/(fanIn + fanOut)
`XAVIER_UNIFORM`|均匀分布 U(-s,s) 其中 s = sqrt(6/(fanIn + fanOut))
`XAVIER_FAN_IN`|正态分布，均值0, 方差 1/fanIn
`RELU`|正态分布，方差 variance 2.0/nIn
`RELU_UNIFORM`|均匀分布 U(-s,s) 其中 s = sqrt(6/fanIn)
`IDENTITY`|单位方阵（只适用于方阵参数）
`VAR_SCALING_NORMAL_FAN_IN`|正态分布，均值 0, 方差 1.0/(fanIn)
`VAR_SCALING_NORMAL_FAN_OUT`|正态分布，均值 0, 方差 1.0/(fanOut)
`VAR_SCALING_NORMAL_FAN_AVG`|正态分布，均值 0, 方差 1.0/((fanIn + fanOut)/2)
`VAR_SCALING_UNIFORM_FAN_IN`|均匀分布 U[-a,a] 其中 a=3.0/(fanIn)
`VAR_SCALING_UNIFORM_FAN_OUT`|均匀分布 U[-a,a] 其中 a=3.0/(fanOut)
`VAR_SCALING_UNIFORM_FAN_AVG`|均匀分布 U[-a,a] 其中 a=3.0/((fanIn + fanOut)/2)

### 激活函数

网络中的激活函数（神经元映射）可以用`activation`方法配置，部分常见值有（也可传递扩展`BaseActivationFunction`的类的对象）：

`Activation`枚举常量|说明
---|---
`CUBE`|f(x) = x^3
`ELU`|指数线性单位
`HARDSIGMOID`|f(x) = min(1, max(0, 0.2*x + 0.5))
`HARDTANH`|分段线性tanh
`IDENTITY`| f(x) = x
`LEAKYRELU`| f(x) = max(0, x) + alpha * min(0, x) 其中默认 alpha=0.01
`RATIONALTANH`|tanh(y) ~ sgn(y) * { 1 - 1/(1+|y|+y^2+1.41645*y^4)} 
`RELU`| f(x) = x （当 x>0）或 f(x) = 0 （其它）
`RRELU`|随机化修正纯属单位
`SIGMOID`|f(x) = 1 / (1 + exp(-x))
`SOFTMAX`|softmax
`SOFTPLUS`|f(x) = log(1+e^x)
`SOFTSIGN`|f(x) = x / (1+|x|)
`TANH`|tanh
`RECTIFIEDTANH`|f(x) = max(0, tanh(x))
`SELU`|正规化指数线性单位
`SWISH`|f(x) = x * sigmoid(x)

### 优化器

网络中的优化器（用于更新梯度）可以用`updater`方法配置，部分常见类有：

类|说明
---|---
`AdaDelta`|
`AdaGrad`|
`AdaMax`|
`Adam`|
`Nadam`|
`Nesterovs`|
`NoOp`|
`RmsProp`|
`Sgd`|

支持学习率（更新的步长，过长容易不收敛，过短收敛则慢）的优化器也支持学习率调度，以下是一些类（实现`ISchedule`的其它类也可以）：

类|说明
---|---
`ExponentialSchedule`|value(i) = initialValue * gamma^i
`InverseSchedule`|value(i) = initialValue * (1 + gamma * i)^(-power)
`MapSchedule`|基于用户提供的映射必须为iteration/epoch为 0时提供值
`PolySchedule`| value(i) = initialValue * (1 + i/maxIter)^(-power)
`SigmoidSchedule`| value(i) = initialValue * 1.0 / (1 + exp(-gamma * (iter - stepSize)))
`StepSchedule`| value(i) = initialValue * gamma^( floor(iter/step) )

### 正则化

可以用`l1(0.1)`、`l2(0.2)`对参数作L1、L2正则化。可以用`l1Bias(0.1)`、`l2Bias(0.2)`对偏向作L1、L2正则化。另外每轮迭代后可以作以下约束：

类|说明
---|---
`MaxNormConstraint`|要求每个单位参数的L2范数小于或等于给定值
`MinMaxNormConstraint`|要求每个单位参数的L2范数位于指定区间
`NonNegativeConstraint`|要求所有参数非负
`UnitNormConstraint`|要求每个单位参数的L2范数为1.0


### 丢弃

在训练阶段把修改激活的值以求预防过度拟合。

类|说明
---|---
`Dropout`|每个激活x以概率1-p置为0，以概率p设为x/p
`GaussianDropout`|加入乘性1均值的高斯噪声
`GaussianNoise`|加入加性0均值的高斯噪声
`AlphaDropout`|企图同时保持均值和方差

### 权重噪声

在训练阶段把修改参数的值以求预防过度拟合。

类|说明
---|---
`DropConnect`|每个参数x以概率1-p置为0，以概率p设为x/p
`WeightNoise`|把加性或乘性的特定分布噪声加入到权重

### 其它

-`seed(long)`方法可设置随机数种子
-`pretrain(boolean)`方法可设置非监督训练
-`backprop(boolean)`方法可设置向后传播

## 训练与使用

有个神经网络配置`conf`后，可以通过`new MultiLayerNetwork(conf)`创建网络，然后应该调用`init()`初始化它。

为了了解神经网络的状态，可以通过调用`setListeners(TrainingListener...)`注册监听器，它们会在训练期每个迭代完成后（或其它元事件）被调用。以下是一些有用的监听器：

类|用途
---|---
`ScoreIterationListener`|每若干个迭代记录损失函数得分到日志
`PerformanceListener`|每若干个迭代记录性能信息到日志
`EvaluativeListener`|每若干个迭代用测试集评估性能
`CheckpointListener`|周期性地保存检查点
`StatsListener`|用于web训练界面
`CollectScoresIterationListener`|每若干个迭代记录损失函数得分到一个列表
`TimeIterationListener`|估计训练所需的剩余时间

要训练网络只用调用`fit`方法传入数据集迭代器，然后可以用`evaluate`等方法作分类或回归，结果为以下类型对象：

类|说明
---|---
`Evaluation`|多类分类结果（softmax + mcxent/negative-log-likelihood），包括准确率、精度、召回率、F1、F-beta, Matthews相关系数、混淆矩阵。可选地包括前N准确率、代价数组
`EvaluationBinary`|多标签二类分类结果（sigmoid + binary cross entropy），每个输出视为独立的二元分类
`EvaluationCalibration`|分类器校正，包括可靠性图、残差图、概率直方图。
`ROC`|二类分类结果（nOut(1) + sigmoid或 nOut(2) + softmax），支持阀值或精确（默认），包括ROC（精度-召回率）曲线面积、并可画出曲线到HTML。
`ROCBinary`|多标签二元分类结果 (sigmoid + binary cross entropy)，包括各输出的ROC
`ROCMultiClass`|多类分类结果(softmax + mcxent/negative-log-likelihood)，包括一组一对其它二元分类的ROC
`RegressionEvaluation`|回归结果(包括多输出的)，包括均方误差。

为了可视化地观察，可以使用以下代码在`localhost:9000`设立基于web的用户界面：

```java
UIServer uiServer = UIServer.getInstance();
StatsStorage statsStorage = new InMemoryStatsStorage();
model.setListeners(new StatsListener(statsStorage),new ScoreIterationListener(1));
uiServer.attach(statsStorage);
```

`ModelSerializer`的静态方法`writeModel`和`restoreMultiLayerNetwork`可以把网络序列化和反序列化。这使得增量训练成为可能。

最后指出，有时我们希望微调一个现有的神经网络，修改部分层和部分参数，这称为转移学习。`TransferLearning.Builder`类可以做这种事情。
