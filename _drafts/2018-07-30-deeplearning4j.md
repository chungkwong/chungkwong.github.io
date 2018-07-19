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

人工神经网络实际上是通过对“简单映射”进行复合来构造逼近函数族的方法，其中的“简单映射”称为神经元。人工神经网络可以用图直观地表示，其中每个顶点是神经元，值沿着有向边在神经元间流动，直至到达输出神经元成为整个逼近映射的值的一个分量。设计人工神经网络时把它分为若干层，大多数边从一层指向下一层。反馈神经网络中也可能存在反向的边，和时序电路中用类似方法实现记忆类似，这种设计被认为可模拟人“逐渐想起来”的记忆。所谓深度学习说是就是层数较多的意思，通常认为后面的层次保存了较高层次（更整体）的信息。

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

### 转换

ND4J provides a number of classes for performing data normalization. These are implemented as DataSetPreProcessors. The basic pattern for normalization:

    Create your (unnormalized) DataSetIterator or MultiDataSetIterator: DataSetIterator myTrainData = ...
    Create the normalizer you want to use: NormalizerMinMaxScaler normalizer = new NormalizerMinMaxScaler();
    Fit the normalizer: normalizer.fit(myTrainData)
    Set the normalizer/preprocessor on the iterator: myTrainData.setPreProcessor(normalizer); End result: the data that comes from your DataSetIterator will now be normalized.

In general, you should fit only on the training data, and do trainData.setPreProcessor(normalizer) and testData.setPreProcessor(normalizer) with the same/single normalizer that has been fit on the training data only.

Note that where appropriate (NormalizerStandardize, NormalizerMinMaxScaler) statistics such as mean/standard-deviation/min/max are shared across time (for time series) and across image x/y locations (but not depth/channels - for image data).

Data normalization example: link

Available normalizers: DataSet / DataSetIterator
`ImagePreProcessingScaler `|Applies min-max scaling to image activations. Default settings do 0-255 input to 0-1 output (but is configurable). Note that unlike the other normalizers here, this one does not rely on statistics (mean/min/max etc) collected from the data, hence the normalizer.fit(trainData) step is unnecessary (is a no-op).
`NormalizerStandardize `|normalizes each feature value independently (and optionally label values) to have 0 mean and a standard deviation of 1
`NormalizerMinMaxScaler `|normalizes each feature value independently (and optionally label values) to lie between a minimum and maximum value (by default between 0 and 1)
`VGG16ImagePreProcessor `|This is a preprocessor specifically for VGG16. It subtracts the mean RGB value, computed on the training set, from each pixel as reported in Link

Available normalizers: MultiDataSet / MultiDataSetIterator
`ImageMultiPreProcessingScaler `|A MultiDataSet/MultiDataSetIterator version of ImagePreProcessingScaler
`MultiNormalizerStandardize `|MultiDataSet/MultiDataSetIterator version of NormalizerStandardize
`MultiNormalizerMinMaxScaler `|MultiDataSet/MultiDataSetIterator version of NormalizerMinMaxScaler
`MultiNormalizerHybrid `|A MultiDataSet normalizer that can combine different normalization types (standardize, min/max etc) for different input/feature and output/label arrays.

### 加载

Data Classes
Iterators

DataSetIterator is an abstraction that DL4J uses to iterate over minibatches of data, used for training. DataSetIterator returns DataSet objects, which are minibatches, and support a maximum of 1 input and 1 output array (INDArray).

MultiDataSetIterator is similar to DataSetIterator, but returns MultiDataSet objects, which can have as many input and output arrays arrays as required for the network.
Iterators - Build-In (DL4J-Provided Data)

These iterators download their data as required. The actual datasets they return are not customizable.
`MnistDataSetIterator `|DataSetIterator for the well-known MNIST digits dataset. By default, returns a row vector (1x784), with values normalized to 0 to 1 range. Use .setInputType(InputType.convolutionalFlat()) to use with CNNs.
`EmnistDataSetIterator `|Similar to the MNIST digits dataset, but with more examples, and also letters. Includes multiple different splits (letters only, digits only, letters + digits, etc). Same 1x784 format as MNIST, hence (other than different number of labels for some splits) can be used as a drop-in replacement for MnistDataSetIterator. Reference 1, Reference 2
`IrisDataSetIterator `|An iterator for the well known Iris dataset. 4 features, 3 output classes.
`CifarDataSetIterator `|An iterator for the CIFAR images dataset. 10 classes, 4d features/activations format for CNNs in DL4J: [minibatch,channels,height,width] = [minibatch,3,32,32]. Features are not normalized - instead, are in the range 0 to 255.
`LFWDataSetIterator `|(Source)
`TinyImageNetDataSetIterator (Source) `|A subset of the standard imagenet dataset; 200 classes, 500 images per class
`UciSequenceDataSetIterator (Source) `|UCI synthetic control time series dataset

Iterators - User Provided Data

The iterators in this subsection are used with user-provided data.
`RecordReaderDataSetIterator `|an iterator that takes a DataVec record reader (such as CsvRecordReader or ImageRecordReader) and handles conversion to DataSets, batching, masking, etc. One of the most commonly used iterators in DL4J. Handles non-sequence data only, as input (i.e., RecordReader, no SequenceeRecordReader).
`RecordReaderMultiDataSetIterator `|the MultiDataSet version of RecordReaderDataSetIterator, that supports multiple readers. Has a builder pattern for creating more complex data pipelines (such as different subsets of a reader’s output to different input/output arrays, conversion to one-hot, etc). Handles both sequence and non-sequence data as input.
`SequenceRecordReaderDataSetIterator `|The sequence (SequenceRecordReader) version of RecordReaderDataSetIterator. Users may be better off using RecordReaderMultiDataSetIterator, in conjunction with
`DoublesDataSetIterator `|(Source)
`FloatsDataSetIterator `|(Source)
`INDArrayDataSetIterator `|(Source)

Iterators - Adapter and Utility Iterators
`MultiDataSetIteratorAdapter `|Wrap a DataSetIterator to convert it to a MultiDataSetIterator
`SingletonMultiDataSetIterator `|Wrap a MultiDataSet into a MultiDataSetIterator that returns one MultiDataSet (i.e., the wrapped MultiDataSet is not split up)
`AsyncDataSetIterator `|Used automatically by MultiLayerNetwork and ComputationGraph where appropriate. Implements asynchronous prefetching of datasets to improve performance.
`AsyncMultiDataSetIterator `|Used automatically by ComputationGraph where appropriate. Implements asynchronous prefetching of MultiDataSets to improve performance.
`AsyncShieldDataSetIterator `|Generally used only for debugging. Stops MultiLayerNetwork and ComputationGraph from using an AsyncDataSetIterator.
`AsyncShieldMultiDataSetIterator `|The MultiDataSetIterator version of AsyncShieldDataSetIterator
`EarlyTerminationDataSetIterator `|Wraps another DataSetIterator, ensuring that only a specified (maximum) number of minibatches (DataSet) objects are returned between resets. Can be used to ‘cut short’ an iterator, returning only the first N DataSets.
`EarlyTerminationMultiDataSetIterator `|The MultiDataSetIterator version of EarlyTerminationDataSetIterator
`ExistingDataSetIterator `|Convert an Iterator<DataSet> or Iterable<DataSet> to a DataSetIterator. Does not split the underlying DataSet objects
`FileDataSetIterator `|An iterator that iterates over DataSet files that have been previously saved with DataSet.save(File). Supports randomization, filtering, different output batch size vs. saved DataSet batch size, etc.
`FileMultiDataSetIterator `|A MultiDataSet version of FileDataSetIterator
`IteratorDataSetIterator `|Convert an Iterator<DataSet> to a DataSetIterator. Unlike ExistingDataSetIterator, the underlying DataSet objects may be split/combined - i.e., the minibatch size may differ for the output, vs. the input iterator.
`IteratorMultiDataSetIterator `|The Iterator<MultiDataSet> version of IteratorDataSetIterator
`MultiDataSetWrapperIterator `|Convert a MultiDataSetIterator to a DataSetIterator. Note that this is only possible if the number of features and labels arrays is equal to 1.
`MultipleEpochsIterator `|Treat multiple passes (epochs) of the underlying iterator as a single epoch, when training.
`WorkspaceShieldDataSetIterator `|Generally used only for debugging, and not usually by users. Detaches/migrates DataSets coming out of the underlying DataSetIterator.

## 网络

人工神经网络配置用类`MultiLayerConfiguration`的对象表示，要配置它可以使用的流式API，先创建Builder：`new NeuralNetConfiguration.Builder()`，然后通过调用它的各个方法进行配置，最后调用`build()`。

### 层

#### 前馈层

类|说明
---|---
`DenseLayer `|A simple/standard fully-connected layer
`EmbeddingLayer `|Takes positive integer indexes as input, outputs vectors. Only usable as first layer in a model. Mathematically equivalent (when bias is enabled) to DenseLayer with one-hot input, but more efficient.

#### 输出层

类|说明
---|---
Output layers: usable only as the last layer in a network. Loss functions are set here.
`OutputLayer `|Output layer for standard classification/regression in MLPs/CNNs. Has a fully connected DenseLayer built in. 2d input/output (i.e., row vector per example).
`LossLayer `|Output layer without parameters - only loss function and activation function. 2d input/output (i.e., row vector per example). Unlike Outputlayer, restricted to nIn = nOut.
`RnnOutputLayer `|Output layer for recurrent neural networks. 3d (time series) input and output. Has time distributed fully connected layer built in.
`RnnLossLayer `|The ‘no parameter’ version of RnnOutputLayer. 3d (time series) input and output.
`CnnLossLayer `|Used with CNNs, where a prediction must be made at each spatial location of the output (for example: segmentation or denoising). No parameters, 4d input/output with shape [minibatch, depth, height, width]. When using softmax, this is applied depthwise at each spatial location.
`Yolo2OutputLayer `|Implentation of the YOLO 2 model for object detection in images
`CenterLossOutputLayer `|A version of OutputLayer that also attempts to minimize the intra-class distance of examples’ activations - i.e., “If example x is in class Y, ensure that embedding(x) is close to average(embedding(y)) for all examples y in Y”

#### 卷积层

类|说明
---|---
`ConvolutionLayer / Convolution2D `|Standard 2d convolutional neural network layer. Inputs and outputs have 4 dimensions with shape [minibatch,depthIn,heightIn,widthIn] and [minibatch,depthOut,heightOut,widthOut] respectively.
`Convolution1DLayer / Convolution1D `|Standard 1d convolution layer
`Deconvolution2DLayer `|also known as transpose or fractionally strided convolutions. Can be considered a “reversed” ConvolutionLayer; output size is generally larger than the input, whilst maintaining the spatial connection structure.
`SeparableConvolution2DLayer `|depthwise separable convolution layer
`SubsamplingLayer `|Implements standard 2d spatial pooling for CNNs - with max, average and p-norm pooling available.
`Subsampling1DLayer `|(Source)
`Upsampling2D `|Upscale CNN activations by repeating the row/column values
`Upsampling1D `|1D version of the upsampling layer
`Cropping2D `|Cropping layer for 2D convolutional neural networks
`ZeroPaddingLayer `|Very simple layer that adds the specified amount of zero padding to edges of the 4d input activations.
`ZeroPadding1DLayer `|1D version of ZeroPaddingLayer
`SpaceToDepth `|This operation takes 4D array in, and moves data from spatial dimensions (HW) to channels (C) for given blockSize
`SpaceToBatch `|Transforms data from a tensor from 2 spatial dimensions into batch dimension according to the “blocks” specified

#### 反馈层

类|说明
---|---
`LSTM `|LSTM RNN without peephole connections. Supports CuDNN.
`GravesLSTM `|LSTM RNN with peephole connections. Does not support CuDNN (thus for GPUs, LSTM should be used in preference).
`GravesBidirectionalLSTM `|A bidirectional LSTM implementation with peephole connections. Equivalent to Bidirectional(ADD, GravesLSTM). Due to addition of Bidirecitonal wrapper (below), has been deprecated on master.
`Bidirectional `|A ‘wrapper’ layer - converts any standard uni-directional RNN into a bidirectional RNN (doubles number of params - forward/backward nets have independent parameters). Activations from forward/backward nets may be either added, multiplied, averaged or concatenated.
`SimpleRnn `|A standard/’vanilla’ RNN layer. Usually not effective in practice with long time series dependencies - LSTM is generally preferred.
`LastTimeStep `|A ‘wrapper’ layer - extracts out the last time step of the (non-bidirectional) RNN layer it wraps. 3d input with shape [minibatch, size, timeSeriesLength], 2d output with shape [minibatch, size].

#### 非监督层

类|说明
---|---
`VariationalAutoencoder `|A variational autoencoder implementation with MLP/dense layers for the encoder and decoder. Supports multiple different types of reconstruction distributions
`AutoEncoder `|Standard denoising autoencoder layer

#### 其它层

类|说明
---|---
`GlobalPoolingLayer `|Implements both pooling over time (for RNNs/time series - input size [minibatch, size, timeSeriesLength], out [minibatch, size]) and global spatial pooling (for CNNs - input size [minibatch, depth, h, w], out [minibatch, depth]). Available pooling modes: sum, average, max and p-norm.
`ActivationLayer `|Applies an activation function (only) to the input activations. Note that most DL4J layers have activation functions built in as a config option.
`DropoutLayer `|Implements dropout as a separate/single layer. Note that most DL4J layers have a “built-in” dropout configuration option.
`BatchNormalization `|Batch normalization for 2d (feedforward), 3d (time series) or 4d (CNN) activations. For time series, parameter sharing across time; for CNNs, parameter sharing across spatial locations (but not depth).
`LocalResponseNormalization `|Local response normalization layer for CNNs. Not frequently used in modern CNN architectures.
`FrozenLayer `|Usually not used directly by users - added as part of transfer learning, to freeze a layer’s parameters such that they don’t change during further training.

### 顶点

Graph vertex: use with ComputationGraph. Similar to layers, vertices usually don’t have any parameters, and may support multiple inputs.
类|说明
---|---
`ElementWiseVertex `|Performs an element-wise operation on the inputs - add, subtract, product, average, max
`L2NormalizeVertex `|normalizes the input activations by dividing by the L2 norm for each example. i.e., out <- out / l2Norm(out)
`L2Vertex `|calculates the L2 distance between the two input arrays, for each example separately. Output is a single value, for each input value.
`MergeVertex `|merge the input activations along dimension 1, to make a larger output array. For CNNs, this implements merging along the depth/channels dimension
`PreprocessorVertex `|a simple GraphVertex that contains an InputPreProcessor only
`ReshapeVertex `|Performs arbitrary activation array reshaping. The preprocessors in the next section should usually be preferred.
`ScaleVertex `|implements simple multiplicative scaling of the inputs - i.e., out = scalar * input
`ShiftVertex `|implements simple scalar element-wise addition on the inputs - i.e., out = input + scalar
`StackVertex `|used to stack all inputs along the minibatch dimension. Analogous to MergeVertex, but along dimension 0 (minibatch) instead of dimension 1 (nOut/channels)
`SubsetVertex `|used to get a contiguous subset of the input activations along dimension 1. For example, two SubsetVertex instances could be used to split the activations from an input array into two separate activations. Essentially the opposite of MergeVertex.
`UnstackVertex `|similar to SubsetVertex, but along dimension 0 (minibatch) instead of dimension 1 (nOut/channels). Opposite of StackVertex

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

网络中的激活函数可以用`activation`方法配置，部分常见值有（也可传递扩展`BaseActivationFunction`的类的对象）：

`Activation`枚举常量|说明
---|---
`CUBE `|f(x) = x^3
`ELU `|指数线性单位
`HARDSIGMOID `|f(x) = min(1, max(0, 0.2*x + 0.5))
`HARDTANH `|分段线性tanh
`IDENTITY `| f(x) = x
`LEAKYRELU `| f(x) = max(0, x) + alpha * min(0, x) 其中默认 alpha=0.01
`RATIONALTANH `|tanh(y) ~ sgn(y) * { 1 - 1/(1+|y|+y^2+1.41645*y^4)} 
`RELU `| f(x) = x （当 x>0）或 f(x) = 0 （其它）
`RRELU `|随机化修正纯属单位
`SIGMOID `|f(x) = 1 / (1 + exp(-x))
`SOFTMAX `|softmax
`SOFTPLUS `|f(x) = log(1+e^x)
`SOFTSIGN `|f(x) = x / (1+|x|)
`TANH `|tanh
`RECTIFIEDTANH `|f(x) = max(0, tanh(x))
`SELU `|正规化指数线性单位
`SWISH `|f(x) = x * sigmoid(x)

### 优化器

网络中的优化器（用于更新梯度）可以用`updater`方法配置，部分常见类有：

类|说明
---|---
`AdaDelta `|
`AdaGrad `|
`AdaMax `|
`Adam `|
`Nadam `|
`Nesterovs `|
`NoOp `|
`RmsProp `|
`Sgd `|

支持学习率的优化器也支持学习率调度，以下是一些类（实现`ISchedule`的其它类也可以）：

类|说明
---|---
`ExponentialSchedule `|value(i) = initialValue * gamma^i
`InverseSchedule `|value(i) = initialValue * (1 + gamma * i)^(-power)
`MapSchedule `|基于用户提供的映射必须为iteration/epoch为 0时提供值
`PolySchedule `| value(i) = initialValue * (1 + i/maxIter)^(-power)
`SigmoidSchedule `| value(i) = initialValue * 1.0 / (1 + exp(-gamma * (iter - stepSize)))
`StepSchedule `| value(i) = initialValue * gamma^( floor(iter/step) )

### 正则化

可以用`l1(0.1)`、`l2(0.2)`对参数作L1、L2正则化。可以用`l1Bias(0.1)`、`l2Bias(0.2)`对偏向作L1、L2正则化。另外每轮迭代后可以作以下约束：

类|说明
---|---
`MaxNormConstraint `|要求每个单位参数的L2范数小于或等于给定值
`MinMaxNormConstraint `|要求每个单位参数的L2范数位于指定区间
`NonNegativeConstraint `|要求所有参数非负
`UnitNormConstraint `|要求每个单位参数的L2范数为1.0


### 随机化

在训练阶段把修改激活的值以求预防过度拟合。

类|说明
---|---
`Dropout `|每个激活x以概率1-p置为0，以概率p设为x/p
`GaussianDropout `|加入乘性1均值的高斯噪声
`GaussianNoise `|加入加性0均值的高斯噪声
`AlphaDropout `|企图同时保持均值和方差

### 权重噪声

在训练阶段把修改参数的值以求预防过度拟合。

类|说明
---|---
`DropConnect`|每个参数x以概率1-p置为0，以概率p设为x/p
`WeightNoise`|把加性或乘性的特定分布噪声加入到权重



Input Pre Processors

An InputPreProcessor is a simple class/interface that operates on the input to a layer. That is, a preprocessor is attached to a layer, and performs some operation on the input, before passing the layer to the output. Preprocessors also handle backpropagation - i.e., the preprocessing operations are generally differentiable.

Note that in many cases (such as the XtoYPreProcessor classes), users won’t need to (and shouldn’t) add these manually, and can instead just use .setInputType(InputType.feedForward(10)) or similar, which whill infer and add the preprocessors as required.
`CnnToFeedForwardPreProcessor `|handles the activation reshaping necessary to transition from a CNN layer (ConvolutionLayer, SubsamplingLayer, etc) to DenseLayer/OutputLayer etc.
`CnnToRnnPreProcessor `|handles reshaping necessary to transition from a (effectively, time distributed) CNN layer to a RNN layer.
`ComposableInputPreProcessor `|simple class that allows multiple preprocessors to be chained + used on a single layer
`FeedForwardToCnnPreProcessor `|handles activation reshaping to transition from a row vector (per example) to a CNN layer. Note that this transition/preprocessor only makes sense if the activations are actually CNN activations, but have been ‘flattened’ to a row vector.
`FeedForwardToRnnPreProcessor `|handles transition from a (time distributed) feed-forward layer to a RNN layer
`RnnToCnnPreProcessor `|handles transition from a sequence of CNN activations with shape [minibatch, depth*height*width, timeSeriesLength] to time-distributed [numExamples*timeSeriesLength, numChannels, inputWidth, inputHeight] format
`RnnToFeedForwardPreProcessor `|handles transition from time series activations (shape [minibatch,size,timeSeriesLength]) to time-distributed feed-forward (shape [minibatch*tsLength,size]) activations.

## 训练与使用

有个神经网络配置`conf`后，可以通过`new MultiLayerNetwork(conf)`创建网络，然后应该调用`init()`初始化它。

为了了解神经网络的状态，可以通过调用`setListeners(TrainingListener...)`注册监听器，它们会在训练期每个迭代完成后（或其它元事件）被调用。以下是一些有用的监听器：

类|用途
---|---
`ScoreIterationListener `|每若干个迭代记录损失函数得分到日志
`PerformanceListener `|每若干个迭代记录性能信息到日志
`EvaluativeListener `|每若干个迭代用测试集评估性能
`CheckpointListener `|周期性地保存检查点
`StatsListener `|用于web训练界面
`CollectScoresIterationListener `|每若干个迭代记录损失函数得分到一个列表
`TimeIterationListener `|估计训练所需的剩余时间

要训练网络只用调用`fit`方法传入数据集迭代器，然后可以用`evaluate`等方法作分类或回归，结果为以下类型对象：

类|说明
---|---
`Evaluation`|多类分类结果（softmax + mcxent/negative-log-likelihood），包括准确率、精度、召回率、F1、F-beta, Matthews相关系数、混淆矩阵。可选地包括前N准确率、代价数组
`EvaluationBinary`|多标签二类分类结果（sigmoid + binary cross entropy），每个输出视为独立的二元分类
`EvaluationCalibration`|分类器校正，包括可靠性图、残差图、概率直方图。
`ROC`|二类分类结果（nOut(1) + sigmoid或 nOut(2) + softmax），支持阀值或精确（默认），包括ROC（精度-召回率）曲线面积、并可画出曲线到HTML。
`ROCBinary`|多标签二元分类结果 (sigmoid + binary cross entropy)，包括各输出的ROC
`ROCMultiClass`|多类分类结果(softmax + mcxent/negative-log-likelihood)，包括一组一对其它二元分类的ROC
`RegressionEvaluation `|回归结果(包括多输出的)，包括均方误差。

`ModelSerializer`的静态方法`writeModel`和`restoreMultiLayerNetwork`可以把网络序列化和反序列化。这使得增量训练成为可能。

最后指出，有时我们希望微调一个现有的神经网络，修改部分层和部分参数，这称为转移学习。`TransferLearning.Builder`类可以做这种事情。
