---
title:  "用OpenLayers设计地理信息网站"
layout: post
tags: web
---

在网页上提供地理信息是一个常见的需求，例如连锁店的网站需要展示各门店的位置和前往路线。[OpenLayers](https://openlayers.org/en/latest/examples/)就是其中一个经常用于显示地图的Javascript库，可以让用户交互式地与各种地理信息打交道。

## 何时使用OpenLayers

为了显示一张地图，最简单的方法是用`<iframe>`标签嵌入各大地图网站。例如[OpenStreetMap](https://www.openstreetmap.org/)、[必应地图](https://www.bing.com/maps/embed-a-map)、[高德地图](https://lbs.amap.com/console/show/card)和[百度地图](http://api.map.baidu.com/lbsapi/creatmap/)都可以生成可用来显示当前地图的HTML代码。比如说OpenStreetMap生成的代码形如：

```html
<iframe width="425" height="350" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://www.openstreetmap.org/export/embed.html?bbox=114.14517045021059%2C22.48035154717487%2C114.15284156799318%2C22.484599442229353&amp;layer=mapnik&amp;marker=22.48247551099446%2C114.14900600910187" style="border: 1px solid black"></iframe><br/><small><a href="https://www.openstreetmap.org/?mlat=22.48248&amp;mlon=114.14901#map=18/22.48248/114.14901">查看更大的地图</a></small>
```

实际显示效果像下面这样：

<iframe width="425" height="350" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://www.openstreetmap.org/export/embed.html?bbox=114.14517045021059%2C22.48035154717487%2C114.15284156799318%2C22.484599442229353&amp;layer=mapnik&amp;marker=22.48247551099446%2C114.14900600910187" style="border: 1px solid black"></iframe><br/><small><a href="https://www.openstreetmap.org/?mlat=22.48248&amp;mlon=114.14901#map=18/22.48248/114.14901">查看更大的地图</a></small>

上述方法对于标示单一个位置的用途而言已经足够，但有时我们需要更大的灵活性。例如连锁店的网站可能需要同时展示多个门店的位置，并容许客户在地图上选取一个门店以查看营业时间和前往路线等信息。这时一个解决方案就是使用类似于[OpenLayers](https://openlayers.org/en/latest/examples/)或者[Leaflet](https://leafletjs.com/)的库。

为了了解OpenLayers能做什么，不妨先看一下我们制作的一个地图网站（[https://www.viewfact.org/map.html](https://www.viewfact.org/map.html)）。它包含了以下功能：

- 基本地图和影像地图切换器
- 地名语言切换器
- 定位
- 比例尺
- 全屏开关
- 缩略图
- 下载
- 持久链接
- 搜索
- 用户定义标记
    - 标点和坐标显示
    - 画线和长度显示
    - 画多边形和面积显示
    - 画圆和面积显示
    - 颜色设置
    - 撤销和重做

## 基本用法

以下HTML文件用OpenLayers展示一个简单的地图：

```html
<!doctype html>
<html lang="en">
  <head>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.2.1/css/ol.css" type="text/css">
    <style>
      .map {
        height: 400px;
        width: 100%;
      }
    </style>
    <script src="https://cdn.polyfill.io/v2/polyfill.min.js?features=requestAnimationFrame,Element.prototype.classList"></script>
    <script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.2.1/build/ol.js"></script>
    <title>OpenLayers基本例子</title>
  </head>
  <body>
    <div id="map" class="map"></div>
    <script type="text/javascript">
      var map = new ol.Map({
        target: 'map',
        layers: [
          new ol.layer.Tile({
            source: new ol.source.OSM()
          })
        ],
        view: new ol.View({
          center: ol.proj.fromLonLat([114.1490,22.4825]),
          zoom: 17
        })
      });
    </script>
  </body>
</html>
```

效果如下：

<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.2.1/css/ol.css" type="text/css">
<style>
  .map {
    height: 400px;
    width: 100%;
  }
</style>
<script src="https://cdn.polyfill.io/v2/polyfill.min.js?features=requestAnimationFrame,Element.prototype.classList"></script>
<script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.2.1/build/ol.js"></script>
<div id="map" class="map"></div>
<script type="text/javascript">
var map = new ol.Map({
target: 'map',
layers: [
  new ol.layer.Tile({
    source: new ol.source.OSM()
  })
],
view: new ol.View({
  center: ol.proj.fromLonLat([114.1490,22.4825]),
  zoom: 17
})
});
</script>

以下我们仔细分析这个例子。

首先，我们在HTML文件的头部包含了OpenLayers的样式表和Javascript库（版本为6.2.1），同时也包含了`polyfill`以支持老旧的IE和Android 4.x。这里我们使用了jsDelivr提供的CDN服务来获取资源，但由于这种CDN不总是可用，而且相对臃肿（包含了所有模块），在正式部署时应考虑把有关URL切换到自己构建的版本。

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.2.1/css/ol.css" type="text/css">
<script src="https://cdn.polyfill.io/v2/polyfill.min.js?features=requestAnimationFrame,Element.prototype.classList"></script>
<script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.2.1/build/ol.js"></script>
```

接着，我们在文档体内增加一个用于放置地图的容器元素，它的高度和宽度可以如常用CSS控制。

```html
<div id="map" class="map"></div>
```

最后，我们创建类型为`ol.Map`的地图，`target`参数指定把地图放到哪里（在本例中是`id`为`'map'`的元素），`layers`参数指定地图的内容（在本例中只有一个图层，来自OpenStreetMap），`view`参数指定地图初始的视图（例如本例中地图中心对应于东经114.1490北纬22.4825的位置，而缩放级为17）。

```html
<script type="text/javascript">
  var map = new ol.Map({
    target: 'map',
    layers: [
      new ol.layer.Tile({
        source: new ol.source.OSM()
      })
    ],
    view: new ol.View({
      center: ol.proj.fromLonLat([114.1490,22.4825]),
      zoom: 17
    })
});
</script>
```

## 定制地图

既然直接使用OpenLayers之类的库的主要优势在于可定制性，我们以下就看看如何灵活地定制地图的各个方面。

### 调整图层

地图由若干个图层组成，例如地形图和地名标签可以分成两个图层以简化需支持多种底图和多种语言的地图渲染服务器。我们除了可以在创建地图时通过`layers`参数设定组件集合，也可以通过`getLayers()`取得图层集合并加以修改。

图层大致可以分为位图和向量图两大类，也可以分为完整图和拼合图两大类，于是共有四小类。

完整位图的每个视图由一张完整的图片给出，创建方法如`new ol.layer.Image({source: 来源})`，其中来源提供图片。OpenLayers支持多种来源，例如ArcGISRest、Canvas、MapGuide、静态图片、WMS和光栅。

拼合位图的每个视图由多张预先渲染的图片拼合而成，创建方法如`new ol.layer.Tile({source: 来源})`，其中来源提供各图片。OpenLayers支持多种来源，例如Bing地图、CartoDB、IIIF、OSM、Stamen、TileArcGISRest、TileJSON、TileWMS、WMTS、XYZ、Zoomify和块坐标。前面我们已经用过`new ol.source.OSM()`来获取OpenStreetMap的数据。一般地，我们可以指定图片来源的URL模板，不必过于依赖个别的地图数据供应商。比如以下代码指定了缩放级`{z}`对应块坐标`({x},{y})`的地图块可从`https://mapapi.geodata.gov.hk/gs/api/v1.0.0/xyz/label/hk/tc/wgs84/{z}/{x}/{y}.png`取得，顺便也指出了版权信息。

```
new ol.source.XYZ({
  url:'https://mapapi.geodata.gov.hk/gs/api/v1.0.0/xyz/label/hk/tc/wgs84/{z}/{x}/{y}.png',
  attributions:'<a href="https://api.portal.hkmapservice.gov.hk/disclaimer" target="_blank" class="copyrightDiv">&copy; 香港特區政府</a>',
  minZoom: 10,
  maxZoom: 18,
  crossOrigin: "Anonymous"	
})
```

完整位图通常用于显示客户端作出的标记，创建方法如`new ol.layer.Vector({source: 来源})`。如果来源用`new ol.source.Vector()`创建，我们可以用`addFeature(特征)`和`removeFeature(特征)`方法向来源增删特征。在用`new ol.Feature()`新建特征后，可用`setGeometry(几何对象)`设置几何对象，也可用`setStyle(样式)`设置样式。

代码|几何对象
---|---
`new ol.grom.Circle(中心坐标,半径)`|圆
`new ol.grom.LineString(坐标数组)`|折线
`new ol.grom.MultiLineString(折线数组)`|若干条折线
`new ol.grom.MultiPoint(坐标数组)`|若干个点
`new ol.grom.MultiPolygon(多边形数组)`|若干个多边形
`new ol.grom.Point(坐标)`|点
`new ol.grom.Polygon(坐标数组)`|多边形
`new ol.grom.GeometryCollection(形状数组)`|若干个形状


拼合位图通常用于显示服务器提供的原始地理数据，创建方法如`new ol.layer.VectorTile({source: new ol.source.VectorTile({format:格式,url:网址模板})})`，其中支持的格式包括EsriJSON、GeoJSON、GML、GPX、IGC、KML、MVT、OSMXML、Polyline、TopoJSON、WFS、WKT和WMSGetFeatureInfo。

另外，`ol.layer.Graticule`可用于显示[网格](https://openlayers.org/en/latest/examples/graticule.html)，`ol.layer.Heatmap`可用于显示[热力图](https://openlayers.org/en/latest/examples/heatmap-earthquakes.html)。

### 调整视图

我们除了可以在创建地图时通过`view`参数设定组件集合，也可以通过`getView()`取得视图并加以修改，以下是一些常用的参数：

参数|获得方法|设置方法|说明
---|---|---|---
`center`|`getCenter()`|`setCenter(中心)`|地图中心对应的坐标
`rotation`|`getRotation()`|`setRotation(角度)`|方位角，0表示地图上方对应北
`zoom`|`getZoom()`|`setZoom(缩放级)`|缩放级，通常在0到20之间
`minZoom`|`getMinZoom()`|`setMinZoom(缩放级)`|最小缩放级
`maxZoom`|`getMaxZoom()`|`setMaxZoom(缩放级)`|最大缩放级


由于用户可以拖动或缩放地图，我们可以用`map.on('moveend', 回调函数)`监察这些变化以便更新持久链接或者视图内的标记。

值得注意的是地图中位置的坐标一般按墨托卡投影（EPSG:3857）而非经纬度（EPSG:4326）计算，所以需要时要用`ol.proj.fromLonLat(坐标)`和`ol.proj.toLonLat(坐标)`进行转换。

### 调整组件

在默认情况下，地图上有分别用于放大和缩小的“+”按钮与“-”按钮、一个用于显示地图版权信息的“i”按钮和一个用于重置旋转的按钮（仅在上方不向北时显示）。我们可以在创建地图时通过`controls`参数设定控件集合，比如以下把默认组件的工具提示改成中文：

```javascript
var map = new ol.Map({
    target: 'map',
    controls: ol.control.defaults({
        attributionOptions:{tipLabel:'资料来源'},
        rotateOptions:{tipLabel:'重置方位'},
        zoomOptions:{zoomInTipLabel:'放大',zoomOutTipLabel:'缩小'}
    }),
    layers: [
      new ol.layer.Tile({
        source: new ol.source.OSM()
      })
    ],
    view: new ol.View({
      center: ol.proj.fromLonLat([114.1490,22.4825]),
      zoom: 17
    })
});
```

也可以稍后通过`getControls()`取得控件集合并加以修改。比如说，以下代码可以向地图`map`加上[比例尺](https://openlayers.org/en/latest/examples/scale-line.html)：

```javascript
map.getControls().push(new ol.control.ScaleLine({unit: "metric"}));
```

以下代码可以向地图`map`加上[全屏开关](https://openlayers.org/en/latest/examples/full-screen.html)：

```javascript
map.getControls().push(new ol.control.FullScreen());
```

以下代码可以向地图`map`加上[缩放级滑动条](https://openlayers.org/en/latest/examples/zoomslider.html)：

```javascript
map.getControls().push(new ol.control.ZoomSlider());
```

以下代码可以向地图`map`加上[转到预定视图的按钮](https://openlayers.org/en/latest/examples/navigation-controls.html)：

```javascript
map.getControls().push(new ol.control.ZoomToExtent({
  extent: [minx, miny, maxx, maxy]
}));
```

以下代码可以向地图`map`加上[缩略图开关](https://openlayers.org/en/latest/examples/overviewmap.html)（打开后会在较大尺度的地图上用矩形标出当前视图对应的位置）：

```javascript
map.getControls().push(new ol.control.OverviewMap({
    layers: [
        new ol.layer.Tile({source: ol.source.OSM()})
    ],
    tipLabel:'缩略图',
    collapseLabel:'◹',
    label:'◳'
}));
```

以下代码可以向地图`map`加上[显示鼠标位置对应坐标的控件](https://openlayers.org/en/latest/examples/mouse-position.html)：

```
map.getControls().push(new ol.control.MousePosition({
  coordinateFormat: ol.coordinate.createStringXY(4),
  projection: 'EPSG:4326',
  undefinedHTML: '&nbsp;'
}))
```

一般地，我们可以自己创建元素并用作控件：

```javascript
map.getControls().push(new ol.control.Control({element:元素}));
```

除了控件外，我们还可以在地图上放置一些[覆盖物](https://openlayers.org/en/latest/examples/overlay.html)以呈现地理信息，例如以下代码可以把指定元素放置在对应于指定坐标的位置对上7个像素：

```javascript
map.addOverlay(new ol.Overlay({
  element: 元素,
  position: 坐标, 
  offset: [0, -7],
  stopEvent:false,
  positioning: 'bottom-center'
}));
```

当然我们也可以用`removeOverlay`移除它们。

### 调整交互

在默认的情况下，地图支持以下交互：
- 同时按下`Shift`和`Alt`键时点击再拖动会旋转地图
- 双击时放大地图
- 拖动时移动视图
- 在触摸屏上扭手指时旋转地图
- 在触摸屏上夹手指时缩放地图
- 按方向键时移动视图
- 按加减键时缩放地图
- 滚动鼠标轮时缩放地图
- 按下`Shift`键再拖放时把选定区域放大

此外，我们可以用`map.addInteraction(交互)`和`map.removeInteraction(交互)`增删交互操作。以下是一些常见交互：

操作|用途|相关事件
---|---|---
`new ol.interaction.DragBox({})`|通过拖动选取矩形|`boxdrag`、`boxend`、`boxstart`
`new ol.interaction.DragAndDrop({source: 向量来源})`|通过拖放接收特征| `addfeatures`
`new ol.interaction.DragRotateAndZoom()`|按下`Shift`键后拖动可关于缩放和旋转地图而保持中心不变|
`new ol.interaction.Draw({source: 向量来源,type: 形状,style:样式})`|绘画形状（`'Point'`、`'LineString'`、`'Polygon'`或`'Circle'`），可以用`getGeometry()`取得最近画的形状|`drawend`、`drawstart`
`new ol.interaction.Extent({})`|通过拖动选取和修改矩形|`extentchanged`
`new ol.interaction.Modify({source: 向量来源})`|通过拖动修改特征中的顶点和边| `modifyend`、`modifystart`
`new ol.interaction.Select({style:样式,multi:false,features:[]})`|通过拖动选中特征|`select`
`new ol.interaction.Snap({source: 向量来源})`|吸附到特征中的顶点和边|
`new ol.interaction.Translate({})`|通过拖动移动特征|`translateend`、`translatestart`、`translating`

## 下一步

我们仅仅介绍了OpenLayers的基本用法，但它其实还能实现很多其它功能，官方的[例子](https://openlayers.org/en/latest/examples/)展示了它们的用法，更详细的信息参见[API 文档](https://openlayers.org/en/latest/apidoc/)。
