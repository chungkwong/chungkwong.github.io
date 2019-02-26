---
title:  "编写浏览器插件：适用于Chrome、Firefox、Edge和Opera"
layout: post
tags: web
---

浏览器插件（或称扩展）可以修改浏览器的行为，比如可以屏蔽广告、防止跟踪、下载视频、翻译网页、增加搜索引擎等等。在过往不同浏览器有互不兼容的插件机制，但现在包括Chrome、Firefox、Edge和Opera在内的主流浏览器都在某程度上支持了WebExtensions API，因而我们能轻松地编写同时适用于多个浏览器的插件。

## 流程

我们演示如何制作一个简单的插件，它在开启时可以屏蔽网页中的视频。

首先，我们在一个新的目录下编写一个清单文件`manifest.json`描述扩展的元数据：

```json
{
	"manifest_version":2,
	"name":"VideoBlock",
	"description":"Block all videos",
	"version":"0.1",
	"permissions":["webRequest","webRequestBlocking","<all_urls>"], 
	"background":{"scripts":["background.js"]},
	"browser_action":{"default_icon":{"32":"icons/off.png"}}
}
```

在这例子中：
- 清单语法版本为`2`（不要改）
- 扩展名为`VideoBlock`
- 简介为`Block all videos`
- 版本号为`0.1`
- 需要权限为可拦截到所有URI的请求
- 加载扩展后马上运行脚本`background.js`
- 在浏览器工具栏中加入一个按钮，默认图标为`icons/off.png`

其次我们编写`background.js`：

```javascript
var blocking=false;
browser.webRequest.onBeforeRequest.addListener(function(requestDetails){
	if(blocking){
		return {redirectUrl:requestDetails.url};
	}else{
		return {redirectUrl:null};
	}
},{urls:["<all_urls>"],types:["media"]},["blocking"]);
browser.browserAction.onClicked.addListener(function(){
	if(blocking){
		browser.browserAction.setIcon({path: "icons/off.png"});
	}else{
		browser.browserAction.setIcon({path: "icons/on.png"});
	}
	blocking=!blocking;
});
```

这脚本中用变量`blocking`记录屏蔽功能当前是否已启用，然后监视两个事件：
- 当有类型为`media`的请求且屏蔽功能启用时屏蔽之
- 当按钮被点击时启用或关闭屏蔽功能，同时通过修改按钮图标反映新状态

接着我们在下画两个32像素高和宽的图标`icons/off.png`和`icons/on.png`分别用于关闭和开启屏蔽功能时的图标。

现在我们让浏览器加载这个扩展：
- 在Firefox中
    1. 访问URL`about:debugging`
    2. 选中`启用附加组件调试`
    3. 点击`载入临时附加组件`
    4. 选择`manifest.json`文件
- 在Chrome中
    1. 访问URL`chrome://extensions`
    2. 选中`Developer Mode`
    3. 点击`LOAD UNPACKED`
    4. 选择`manifest.json`所在文件夹
- 在Edge中
    1. 访问URL`about:flags`
    2. 选中`Enable extension developer features`
    3. 点击`More (...)`
    4. 点击`Extensions`
    5. 点击`Load extension`
    6. 选择`manifest.json`所在文件夹


加载后点击扩展在工具栏中的按钮，再打开一个带视频的网页，应该就会发现视频播放不了。

最后我们还可以把扩展发布到网上，让别人通过浏览器的扩展中心发现并安装我们开发的扩展：
- 对于Firefox，发布到[Mozilla附加组件开发者中心](https://addons.mozilla.org/zh-CN/developers/)
- 对于Chrome，[参考这里](https://developer.chrome.com/webstore/publish)
- 对于Edge，[参考这里](https://docs.microsoft.com/en-us/microsoft-edge/extensions/guides/packaging)

## 清单

每个扩展都有一个描述元数据的清单，它是直接位于扩展目录、名为`manifest.json`的JSON文件，常见字段如下：

键|必要性|用途|格式例子
---|---|---|---
`name`|必须|给用户看的扩展名称，不超过45个字符|`"Video blocker"`
`version`|必须|版本号，由一到四个用句点分隔的整数组成|`"1"`、`"1.0"`、`"2.10.2"`、`"3.1.2.4567"` 
`default_locale`|当且仅当扩展目录有子目录`_locales`|存放默认字符串的`_locales`子目录名|`en`
`description`|可选|给用户看的扩展简介|`"Block all videos"`
`icons`|可选|扩展不同大小（以`px`为单位）的图标文件位置|`{"24":"small.jpg","48":"medium.jpg"}`
`developer`|可选|开发者的名称和/或网址|`{"name": "Bighard",  "url": "https://www.bighard.com"}`
`browser_action`|可选|加到浏览器工具栏的按钮，可指定图标、提示和点击时打开的对话框页面，不能与`page_action`共存|`{"default_icon":{"16": "button/geo-16.png","32":"button/geo-32.png"},"default_title": "Whereami?","default_popup": "popup/geo.html"}`
`page_action`|可选|加到浏览器工具栏的按钮，可指定图标、提示和点击时打开的对话框页面，不能与`browser_action`共存|同上
`browser_specific_settings`|可选|浏览器特定的值|`{"gecko":{"strict_min_version": "57.0"}}`（表示要求Firefox的版本至少为57才能安装）
`background`|可选|浏览器加载扩展后即开始运行的脚本，还可指定运行于的页面和是否保持这页面于已加载状态以记忆状态|`{"page": "background.html","scripts": ["background.js"],"persistent":true}`
`content_scripts`|可选|自动把`js`指定的脚本和/或`css`指定的样式表加入每个页面（`all_frames`为`false`时则修改模式`matches`指定的页面或不修改模式`exclude_matches`指定的页面）由`run_at`指定的位置`"document_start"`、`"document_end"`或`"document_idle"`|`{"all_frames": <boolean>,"css": [...],"exclude_matches": [...],"js": [...],"matches": [...],"run_at": "document_end"}`
`content_security_policy`|可选|防止意外执行恶意代码的[内容安全策略](https://www.w3.org/TR/CSP3/)|`"script-src 'self'; object-src 'self';"`
`options_page`|可选|选项页|`"options/options.html"`
`manifest_version`|可选|清单版本，一般为2|`2`
`web_accessible_resources`|可选|容许页面通过`browser.extension.getURL()`访问的资源|`["images/useless.png"]`
`permissions`|可选|需要的额外权限，包括危险API和作危险访问（如绕过同源策略访问有关页面、用`tabs.executeScript`向有关页面插入脚本、用`webRequest`API从有关页面接收事件）的URL|`["activeTab","contextMenus","tabs","webNavigation","webRequestBlocking","*://*.w3.org/*","<all_urls>"]`
`required_keys`|可选|要求浏览器支持指定字段才安装|`["theme"]`
`externally_connectable`|可选|接受来自其它扩展或URL模式的消息|`["ids": [],"matches": []]`
`author`|可选|作者|`Zhang`
`chrome_settings_overrides`|可选|主页和搜索引擎|`{"homepage":"https://www.viewfact.org/","search_provider":{"name":"睇料","search_url":"https://www.viewfact.org/search?q={searchTerms}","keyword":"viewfact","favicon_url":"https://www.viewfact.org/favicon.ico"}}`
`chrome_url_overrides`|可选|特殊页面如新标签页|`{"newtab": "my-new-tab.html"}`
`commands`|可选|命令（包括特殊命令`_execute_browser_action`、`execute_page_action`、`_execute_sidebar_action`）的描述和键盘快捷键（对不同平台`"default"`、`"mac"`、`"linux"`、`"windows"`、`"chromeos"`、`"android"`、`"ios"`可指定不同快捷键）|`{"toggle-feature":{"suggested_key":{"default": "Ctrl+Shift+Y","linux": "Ctrl+Shift+U"},"description": "Send a 'toggle-feature' event"}}`
`devtools_page`|可选|开发者工具|`"devtools/my-page.html"`
`homepage_url`|可选|扩展的主页|`"https://example.org/my-addon"`
`incognito`|可选|区分隐私窗口|`"spanning"`（隐私和非隐私窗口的事件对扩展可见）、 `"split"`（运行两套扩展）、`"not_allowed"`
`offline_enabled`|可选|是否预期在离线时使用|`true`
`omnibox`|可选|用户在地址栏输入指定关键词后，其余部分会发给应用|`{"keyword": "mdn"}`
`optional_permissions`|可选|运行时可能请求用户批准的权限|`[]`
`options_ui`|可选|选项页|`{"page": "options/options.html","open_in_tab":false,"browser_style":true}`
`name`|可选|给用户看的扩展简称，不超过12个字符|`"NoVideo"`
`theme`|可选|外观主题|`{"images":{"headerURL": "images/sun.jpg"},"colors": {"bookmark_text":[0,0,0],"frame_inactive":[0,0,0],"ntp_background":[0,0,0],"ntp_text":[0,0,0],"tab_background_text":[0,0,0],"tab_text":[0,0,0],"toolbar": [0,0,0]},"properties":{}}`
`version_name`|可选|给人看的版本号|`"0.1 beta"`

## 国际化与本地化

为了让扩展支持多种语言，首先找出扩展中所有需要翻译的信息加以国际化，方法是为它们分别起个互不相同的名字（符合正则表达式`[A-Za-z0-9@_]+?`），然后按场合把信息替换为：
- 若在清单或样式表中，则替换为`__MSG_名字__`
- 若在脚本中，则替换为`browser.i18n.getMessage('名字',字符串或其数组)`

预定义的信息名|说明
---|---
`@@extension_id`|扩展ID，不能用于清单
`@@ui_locale`|当前地区
`@@bidi_dir`|当前地区的文字方向：`"ltr"`或`"rtl"`
`@@bidi_reversed_dir`|当前地区的文字反方向：`"ltr"`或`"rtl"`
`@@bidi_start_edge`|当前地区的文字方向：`"left"`或`"right"`
`@@bidi_end_edge`|当前地区的文字反方向：`"right"`或`"left"`

接下来是本地化，方法是在扩展目录的子目录`_locales`下为每种语言创建分别创建子目录（目录名为`语言代码`或`语言代码_地区代码`），再分别在这些子目录创建JSON文件。JSON文件的字段名为各消息的名字，值则是消息模板：
- 对于没有参数的消息模板，形如`"extensionName":{"message": "Image Blocker","description": "Name of the extension"}`
- 对于有参数的消息模板
    - 可以用`$序号`指代位置参数，形如`"of":{"message": "$2的$1","description": "of something"}`
    - 也可以给参数名字，形如`"{"message": "You clicked $URL$.","description":"Tells the user which link they clicked.","placeholders":{"url":{"content":"$1","example":"https://developer.mozilla.org"}}}`

## API

浏览器开放给扩展用Javascript调用的API大多在全局对象（即`window`的字段）`browser`中，用WebIDL可以如下描述各主要类型：

```webidl
[CheckAnyPermissions="browserExt"]
interface BrowserExtGlobal {
    readonly attribute Browser browser;
};
Window implements BrowserExtGlobal;

[NoInterfaceObject] 
interface Browser { 
};
dictionary BrowserExtIcon {
    DOMString path;
    DOMString size;
};
typedef sequence<BrowserExtIcon> BrowserExtIconArray;
dictionary BrowserExtDeveloper {
    DOMString name;
    DOMString? url;
};
dictionary BrowserExtBrowserOrPageAction {
    BrowserExtIcon? defaultIcon; 
    DOMString? defaultPopup;
    DOMString? defaultTitle;
};
dictionary BrowserExtKeyValue {
    DOMString key;
    DOMString? value;
};
dictionary BrowserExtBrowserSpecificSettings {
    DOMString browserName;
    sequence<BrowserExtKeyValue> keyValue;
};
dictionary BrowserExtBackroundOrEvent {
    DOMString? page;
    boolean persistent;
    sequence<DOMString>? scripts;
};
dictionary BrowserExtContentScripts {
    boolean allFrames;
    sequence<DOMString>? css;
    sequence<DOMString>? excludeMatches;
    sequence<DOMString>? js;
    sequence<DOMString> matches;
    DOMString? runAt;
};
dictionary BrowserExtManifest {
    BrowserExtBackroundOrEvent? background;
    BrowserExtBrowserOrPageAction? browserAction;
    BrowserExtBrowserSpecificSettings? browserSpecificSettings;
    BrowserExtContentScripts? contentScripts;
    DOMString? contentSecurityPolicy;
    DOMString? defaultLocale;
    DOMString? description;
    BrowserExtDeveloper? developer;
    BrowserExtIconArray? icons;
    DOMString? manifestVersion;
    DOMString name;
    DOMString? optionsPage;
    BrowserExtBrowserOrPageAction? pageAction;
    sequence<DOMString>? permissions;
    sequence<DOMString>? requiredKeys;
    DOMString? version;
    sequence<DOMString> webAccessibleResources;
};
[NoInterfaceObject, Exposed=(Window,ContentScript), CheckAnyPermissions="browserExt"]
interface BrowserExtEvent {
    void    addListener(Function callback);
    void    removeListener(Function callback);
    boolean hasListener(Function callback);
    boolean hasListeners();
};
```

在WebIDL中，我们用`Exposed`属性描述可用上下文（`Window`表示`background`、`browser_action`、`page_action`、`options_page`等字段引入的脚本,`ContentScript`表示`content_scripts`字段引入的脚本)。

### BrowserAction

`browser.browserAction`给出了浏览器按钮的API：

```webidl
dictionary BrowserExtBrowserActionDefaults {
    BrowserExtIconArray? defaultIcon;
    DOMString? defaultPopup;
    DOMString?  defaultTitle;
};
partial dictionary BrowserExtManifest {
        BrowserExtBrowserActionDefaults? browserActionDefaults;
};
typedef sequence<byte> BrowserExtColorArray;
dictionary BrowserExtTabIdDetails {
    long tabId;
};
dictionary BrowserExtBadgeColorArrayTabId {
    BrowserExtColorArray color;
    long tabId;
};
dictionary BrowserExtBadgePathTabId {
    DOMString path;
    long tabId;
};
dictionary BrowserExtBadgeTextTabId {
    long tabId;
    DOMString text;
};
dictionary BrowserExtBadgeTabIdPopup {
    DOMString popupHTMLFileName;
    long tabId;
};
callback BrowserExtBrowserActionOnClickedCallback = void (BrowserExtTabsTab tab);
[NoInterfaceObject]
interface BrowserExtBrowserAction {
    void disable(long tabId);
    void enable(long tabId);
    Promise<BrowserExtColorArray> getBadgeBackgroundColor(BrowserExtTabIdDetails details);
    Promise<DOMString?> getBadgeText(BrowserExtTabIdDetails details);
    Promise<DOMString?> getPopup(BrowserExtTabIdDetails details);
    BrowserExtEvent onClicked(BrowserExtBrowserActionOnClickedCallback callback);
    void setBadgeBackgroundColor(BrowserExtBadgeColorArrayTabId details);
    void setBadgeText(BrowserExtBadgeTextTabId details);
    Promise<void> setIcon(BrowserExtBadgePathTabId details);
    void setPopup(BrowserExtBadgeTabIdPopup details);
};
[NoInterfaceObject, Exposed=Window, CheckAnyPermissions="browserExtBrowserAction"]
interface BrowserExtBrowserActionAPI {
    readonly attribute BrowserExtBrowserAction browserAction; 
};
Browser implements BrowserExtBrowserActionAPI;
```

### ContextMenus

`browser.contextMenus`给出了上下文菜单的API：

```webidl
enum BrowserExtContextType { "all", "audio", "browser_action", "editable", "frame", "image", "link", "page", "page_action", "selection", "video" };
enum BrowserExtItemType { "checkbox","normal","radio","separator" };
dictionary BrowserExtContextMenuCreateDetails {
    boolean checked;
    sequence<ContextType>? contexts;
    sequence<DOMString>? documentUrlPatterns;
    boolean enabled;
    DOMString? id;
    Function onclick;
    (long or DOMString?) parentId;
    sequence<DOMString>? targetUrlPatterns;
    DOMString? title;
    DOMString? type;
};
dictionary BrowserExtContextMenuUpdateDetails {
    boolean checked;
    sequence<BrowserExtContextType>? contexts;
    sequence<DOMString>? documentUrlPatterns;
    boolean enabled;
    Function onclick;
    long parentId;
    sequence<DOMString>? targetUrlPatterns;
    DOMString? title;
    ItemType? type;
};
dictionary BrowserExtContextMenuOnClickedDetails {
    boolean checked;
    boolean editable;
    long frameId;
    DOMString? frameUrl;
    DOMString? linkUrl;
    DOMString? mediaType;
    (long or DOMString) menuItemId;
    DOMString? pageUrl;
    (long or DOMString?) parentMenuItemId;             
    DOMString? selectionText;
    DOMString? srcUrl;
    boolean wasChecked;
};
callback BrowserExtContextMenuOnClickedCallback = void (BrowserExtContextMenuOnClickedDetails details, BrowserExtTabsTab tab);
[NoInterfaceObject]
interface BrowserExtContextMenus {
    Promise<long> create(BrowserExtContextMenuCreateDetails details);
    BrowserExtEvent onClicked(BrowserExtContextMenuOnClickedCallback callback);
	Promise<void> remove((long or DOMString) itemId);
    Promise<void>  removeAll();
    Promise<void>  update((long or DOMString) itemId, BrowserExtContextMenuUpdateDetails details);
};
[NoInterfaceObject, Exposed=Window, CheckAnyPermissions="browserExtContextMenus"]
interface BrowserExtContextMenusAPI {
    readonly attribute BrowserExtContextMenus contextMenus; 
};
Browser implements BrowserExtContextMenusAPI;
```

### i18n

`browser.i18n`给出了国际化的API：

```webidl
[NoInterfaceObject]
interface BrowserExtI18n {
    DOMString getMessage(DOMString messageName, sequence<DOMString?>? substitutions);
};
[NoInterfaceObject, Exposed=(Window,ContentScript), CheckAnyPermissions="browserExt"] 
interface BrowserExtI18nAPI {
        readonly attribute BrowserExtI18n i18n;
};
Browser implements BrowserExtI18nAPI;
partial dictionary BrowserExtManifest {
    DOMString? defaultLocaleValue;
};
```

### pageAction

`browser.pageAction`给出了页面按钮的API：

```webidl
dictionary BrowserExtPageActionDefaults {
    BrowserExtIconArray? defaultIcon;
    DOMString? defaultPopup;
    DOMString?  defaultTitle;
};
partial dictionary BrowserExtManifest {
    BrowserExtPageActionDefaults? pageActionDefaults;
};
dictionary BrowserExtBadgePath {
    DOMString path;
};
callback BrowserExtPageActionOnClickedCallback = void (BrowserExtTabsTab tab);
interface BrowserExtPageAction {
    Promise<DOMString?> getPopup(BrowserExtTabIdDetails details);
    Promise<DOMString?> getTitle(BrowserExtTabIdDetails details);
    void hide(long tabId);
    BrowserExtEvent onClicked(BrowserExtPageActionOnClickedCallback callback);
    Promise<void> setIcon(BrowserExtBadgePath path);
    void setPopup(BrowserExtBadgePathTabId details);
    void setTitle(BrowserExtBadgeTextTabId details);
    void show(long tabId);
};
[NoInterfaceObject, Exposed=Window, CheckAnyPermissions="browserExtPageAction"]
interface BrowserExtPageActionAPI {
    readonly attribute BrowserExtPageAction pageAction; 
};
Browser implements BrowserExtPageActionAPI;
```

### runtime

`browser.runtime`给出了运行时的API（用于扩展与页面相互通信）：

```webidl
enum BrowserExtRuntimeOnInstalledReason {"browser_update", "extension_install", "extension_update"};
dictionary BrowserExtRuntimeOnInstalledDetails {
    BrowserExtRuntimeOnInstalledReason reason;
    DOMString? previousVersion;
    DOMString? id;
};
dictionary BrowserExtRuntimePort {
    Function disconnect;
    DOMString name;
    object onDisconnect;
    object onMessage;
    Function postMessage;
    BrowserExtRuntimeMessageSender? sender;
};
dictionary BrowserExtRuntimeMessageSender {
    DOMString? id;
    long frameId;
    BrowserExtTabsTab? tab;
    DOMString? url;
};
callback BrowserExtRuntimeOnConnectCallback = void (BrowserExtRuntimePort port);
callback BrowserExtRuntimeOnInstalledCallback = void (BrowserExtRuntimeOnInstalledDetails details);
callback BrowserExtRuntimeOnMessageCallback = void (optional any message, BrowserExtRuntimeMessageSender sender, BrowserExtRuntimeSendResponseCallback callback);
[NoInterfaceObject]
interface BrowserExtBrowserRuntime {
    object getManifest();
    DOMString getURL(DOMString path);
    attribute DOMString id;
    void onConnect(BrowserExtRuntimeOnConnectCallback callback);
    void onInstalled(BrowserExtRuntimeOnInstalledCallback callback);
    void onMessage(BrowserExtRuntimeOnMessageCallback callback);
    Promise<any> sendMessage(optional DOMString extensionId, any message);
    attribute BrowserExtRuntimePort Port;
    attribute BrowserExtRuntimeMessageSender MessageSender;
};
[NoInterfaceObject, Exposed=Window, CheckAnyPermissions="browserExt"]
interface BrowserExtRuntimeAPI {
    readonly attribute BrowserExtRuntime runtime; 
};
Browser implements BrowserExtRuntimeAPI;
```

### tabs

`browser.tabs`给出了标签页的API：

```webidl
enum BrowserExtTabMutedReasonDetails { "user", "capture", "extension" };
enum BrowserExtRunAt { "document_end", "document_idle", "document_start" };
enum BrowserExtTabStatus { "complete", "loading" };
enum BrowserExtWindowTypes { "app", "normal", "panel", "popup" };
enum BrowserExtTabsCaptureVisibleTabFormat { "jpeg", "png" };
dictionary BrowserExtTabsTab {
    boolean active;
    boolean audible;
    DOMString? favIconUrl;
    boolean highlighted;
    long height;
    long id;
    boolean incognito;
    long index;
    TabMutedDetails? mutedDetails;
    long openerTabId;
    boolean pinned;
    DOMString? sessionId;
    DOMString? status;
    DOMString? title;
    DOMString? url;
    long width;
    long windowId;
};
dictionary BrowserExtTabMutedDetails {
    DOMString? extensionId;
    boolean muted;
    TabMutedReasonDetails? reason;
};
dictionary BrowserExtTabConnectDetails {
    long frameId;
    DOMString? name;
};
dictionary BrowserExtTabCreateDetails {
    boolean active;
    long index;
    long openerTabId;
    boolean pinned;
    DOMString? url;
    long windowId;
};
dictionary BrowserExtTabScriptAndCSSDetails {
    boolean allFrames;
    DOMString? code;
    DOMString? file;
    long frameId;
    boolean matchAboutBlank;
    BrowserExtRunAt? runAt;
};
dictionary BrowserExtTabsCaptureVisibleTabDetails {
    BrowserExtTabsCaptureVisibleTabFormat imageCaptureFormat;
    long jpegQuality;
};
dictionary BrowserExtTabQueryDetails {
    boolean active;
    boolean audible;  
    boolean currentWindow;
    boolean highlighted;
    long index;
    boolean lastFocusedWindow;
    boolean muted;
    boolean pinned;
    TabStatus? status;
    DOMString? title;
    (DOMString? or sequence<DOMString>?) url;
    long windowId;
    WindowType? windowType;
};
dictionary BrowserExtTabReloadDetails {
    boolean bypassCache;
};
dictionary BrowserExtTabSendMessageDetails {
    long frameId;
};
dictionary BrowserExtTabUpdateDetails {
    boolean active;
    boolean highlighted;
    boolean muted;
    long openerTabId;
    boolean pinned;
    DOMString? url;
};
dictionary BrowserExtTabIdWindowId {
    long tabId;
    long windowId;
};
dictionary BrowserExtTabsWindowIdIsWindowClosing {
    boolean isWindowClosing;
    long windowId;
};
dictionary BrowserExtTabsOnUpdatedChangeDetails {
    boolean audible;    
    DOMString? favIconUrl;
    TabMutedDetails? mutedDetails;
    boolean pinned;
    DOMString? status;
    DOMString? title;
    DOMString? url;
};
callback BrowserExtTabsOnActivatedCallback = void (BrowserExtTabIdWindowId activeDetails);
callback BrowserExtTabsOnCreatedCallback = void (BrowserExtTabTab tab);
callback BrowserExtTabsOnRemovedCallback = void (long tabId, BrowserExtTabsWindowIdIsWindowClosing removeDetails);
callback BrowserExtTabsOnUpdatedCallback = void (long tabId, BrowserExtTabsOnUpdatedChangeDetails details, BrowserExtTabsTab tab);
[NoInterfaceObject]
interface BrowserExtBrowserTabs {
    Promise<DOMString> captureVisibleTab(long windowId, BrowserExtTabsCaptureVisibleTabDetails details);
    RuntimePort connect(long tabId, BrowserExtTabConnectDetails details);
    Promise<BrowserExtTabsTab> create(BrowserExtTabCreateDetails details);
    void executeScript(long tabId, BrowserExtTabScriptAndCSSDetails details);
    Promise<BrowserExtTabsTab> get(long tabId);
    Promise<BrowserExtTabsTab> getCurrent();
    void insertCSS(long tabId, BrowserExtTabScriptAndCSSDetails details);
    void onActivated(BrowserExtTabsOnActivatedCallback callback);
    void onCreated(BrowserExtTabsOnCreatedCallback callback);
    void onRemoved(BrowserExtTabsOnRemovedCallback callback);
    void onUpdated(BrowserExtTabsOnUpdatedCallback callback);
    Promise<BrowserExtTabsTab> query(BrowserExtTabQueryDetails queryDetails);
    Promise<void> reload(BrowserExtTabReloadDetails details);
    Promise<void> remove((long or sequence<long>) tabIds);
    Promise<any> sendMessage(long tabId, any message, optional BrowserExtTabSendMessageOptions details);
    Promise<BrowserExtTabsTab> update(optional long tabId, BrowserExtTabUpdateDetails details);
};
[NoInterfaceObject, Exposed=Window, CheckAnyPermissions="browserExtTabs"]
interface BrowserExtTabsAPI {
readonly attribute BrowserExtTabs tabs; 
};
Browser implements BrowserExtTabsAPI;
```

### webNavigation

`browser.webNavigation`给出了导航的API：

```webidl
enum BrowserExtTransitionType { "link", "typed" };
dictionary BrowserExtWebNavigationOnBeforeNavigateDetails {
    long frameId;
    long parentFrameId;
    long tabId;
    double timeStamp;
    DOMString url;
};
dictionary BrowserExtWebNavigationOnCommittedDetails {
    long frameId;
    long processId;
    long tabId;
    double timeStamp;
    TransitionType transitionType;
    DOMString url;
};
dictionary BrowserExtWebNavigationOnCompletedDetails {
    long frameId;
    long processId;
    long tabId;
    double timeStamp;
    DOMString url;
};
dictionary BrowserExtWebNavigationOnDOMContentLoadedDetails {
    long frameId;
    long processId;
    long tabId;
    double timeStamp;
    DOMString url;
};
dictionary BrowserExtWebNavigationOnErrorOccurredDetails {
    DOMString error;
    long frameId;
    long tabId;
    double timeStamp;
    DOMString url;
};
dictionary BrowserExtWebNavigationOnReferenceFragmentUpdatedDetails {
    long frameId;
    long processId;
    long tabId;
    double timeStamp;                           
    BrowserExtTransitionType transitionType;
    DOMString url;
};
callback BrowserExtWebNavigationOnBeforeNavigateCallback = void (BrowserExtWebNavigationOnBeforeNavigateDetails details);
callback BrowserExtWebNavigationOnCommittedCallback = void (BrowserExtWebNavigationOnCommittedDetails details);
callback BrowserExtWebNavigationOnCompletedCallback = void (BrowserExtWebNavigationOnCompletedDetails details);
callback BrowserExtWebNavigationOnDOMContentLoadedCallback = void (BrowserExtWebNavigationOnDOMContentLoadedDetails details);
callback BrowserExtWebNavigationOnErrorOccurredCallback = void (BrowserExtWebNavigationOnErrorOccurredDetails details);
callback BrowserExtWebNavigationOnReferenceFragmentUpdated = void (BrowserExtWebNavigationOnReferenceFragmentUpdatedDetails details);
[NoInterfaceObject]
interface BrowserExtBrowserWebNavigation {
    void onBeforeNavigate(BrowserExtWebNavigationOnBeforeNavigateCallback callback);
    void onCommitted(BrowserExtWebNavigationOnCommittedCallback callback);
    void onCompleted(BrowserExtWebNavigationOnCompletedCallback callback);
    void onDOMContentLoaded(BrowserExtWebNavigationOnDOMContentLoadedCallback callback);
    void onErrorOccurred(BrowserExtWebNavigationOnErrorOccurredCallback callback);
    void onReferenceFragmentUpdated(BrowserExtWebNavigationOnReferenceFragmentUpdated callback);
};
    
[NoInterfaceObject, Exposed=Window, CheckAnyPermissions="browserExtWebNavigation"]
interface BrowserExtWebNavigationAPI {
    readonly attribute BrowserExtWebNavigation webNavigation; 
};
Browser implements BrowserExtWebNavigationAPI;
```

### webRequest

`browser.webRequest`给出了web请求的API：

```webidl
enum BrowserExtResourceType { "font", "image", "main_frame", "object", "other", "ping", "script", "stylesheet", "sub_frame", "xmlhttprequest" };
dictionary BrowserExtWebRequestUploadDetails {
    any bytes;
    DOMString? file;
};
dictionary BrowserExtWebRequestRequestBody {
    DOMString? error;
    object? formData;
    sequence<BrowserExtWebRequestUploadData>? rawData;
};
dictionary BrowserExtWebRequestHttpHeader {
    DOMString keyName;
    any value;
};
dictionary BrowserExtWebRequestHttpHeaders {
    sequence<BrowserExtWebRequestHttpHeader> data; 
};
dictionary BrowserExtWebRequestOnBeforeRequestDetails {
    long frameId;
    DOMString method;
    long parentFrameId;
    BrowserExtWebRequestRequestBody? requestBody;
    DOMString requestId;
    long tabId;
    double timeStamp;
    BrowserExtResourceType type;
    DOMString url;
};
dictionary BrowserExtWebRequestOnBeforeSendHeadersDetails {
    long frameId;
    DOMString method;
    long parentFrameId;
    BrowserExtWebRequestHttpHeaders? requestHeaders;
    DOMString requestId;
    long tabId;
    double timeStamp;
    BrowserExtResourceType type;
    DOMString url;
};
dictionary BrowserExtWebRequestOnCompletedDetails {
    long frameId;
    boolean fromCache;
    DOMString method;
    long parentFrameId;
    DOMString requestId;
    BrowserExtWebRequestHttpHeaders? responseHeaders;
    DOMString? serverIP;
    long statusCode;
    DOMString statusLine;
    long tabId;
    double timeStamp;   
    BrowserExtResourceType type;
    DOMString url;
}; 
dictionary BrowserExtWebRequestOnHeadersReceivedDetails {
    long frameId;
    DOMString method;
    long parentFrameId;
    DOMString requestId;
    BrowserExtWebRequestHttpHeaders? responseHeaders;
    long statusCode;
    DOMString statusLine;
    long tabId;
    double timeStamp;   
    BrowserExtResourceType type;
    DOMString url;
};
dictionary BrowserExtWebRequestOnSendHeadersDetails {
    long frameId;
    DOMString method;
    long parentFrameId;
    BrowserExtWebRequestHttpHeaders? requestHeaders;
    DOMString requestId;
    long tabId;
    double timeStamp;   
    BrowserExtResourceType type;
    DOMString url;
};
callback BrowserExtWebRequestOnBeforeRequestCallback = void (BrowserExtWebRequestOnBeforeRequestDetails details);
callback BrowserExtWebRequestOnBeforeSendHeadersCallback = void (BrowserExtWebRequestOnBeforeSendHeadersDetails details);
callback BrowserExtWebRequestOnCompletedCallback = void (BrowserExtWebRequestOnCompletedDetails details);
callback BrowserExtWebRequestOnHeadersReceivedCallback = void (BrowserExtWebRequestOnHeadersReceivedDetails details);
callback BrowserExtWebRequestOnSendHeadersCallback = void (BrowserExtWebRequestOnSendHeadersDetails details);
[NoInterfaceObject]
interface BrowserExtBrowserWebRequest {
    void onBeforeRequest(BrowserExtWebRequestOnBeforeRequestCallback callback);
    void onBeforeSendHeaders(BrowserExtWebRequestOnBeforeSendHeadersCallback callback);
    void onCompleted(BrowserExtWebRequestOnCompletedCallback callback);
    void onHeadersReceived(BrowserExtWebRequestOnHeadersReceivedCallback callback);
    void onSendHeaders(BrowserExtWebRequestOnSendHeadersCallback callback);
};
[NoInterfaceObject, Exposed=Window, CheckAnyPermissions="browserExtWebRequest"]
interface BrowserExtWebRequestAPI {
    readonly attribute BrowserExtWebRequest webRequest; 
};
Browser implements BrowserWebRequestAPI;
```

### windows

`browser.windows`给出了浏览器窗口的API：

```webidl
enum BrowserExtWindowsWindowType { "detached_panel", "normal", "panel", "popup" };
enum BrowserExtWindowsWindowState { "docked", "fullscreen", "maximized", "minimized", "normal" };
dictionary BrowserExtCreateWindowDetails {
    boolean focused;
    long height;
    boolean incognito;
    long left;
    BrowserExtWindowsWindowState? state;
    long tabId;
    long top;
    (DOMString? or sequence<DOMString>?) url;
    long width;
    BrowserExtWindowsWindowType? windowType;
};
dictionary BrowserExtGetWindowDetails {
    boolean populate;
    sequence<BrowserExtWindowsWindowType>? windowTypes;
};
dictionary BrowserExtWindowUpdateDetails {
    boolean drawAttention;
    boolean focused;
    long height;
    long left;
    long top;
    long width;
    BrowserExtWindowState? windowState;
};
dictionary BrowserExtWindowsWindow {
    boolean alwaysOnTop;
    boolean focused;
    long height;
    long id;
    boolean incognito;
    long left;
    sequence<BrowserExtTabsTab>? tabs;
    long top;
    DOMString? sessionId;
    BrowserExtWindowsWindowState? state;
    long width;
    BrowserExtWindowsWindowType? windowType;
};
callback BrowserExtWindowsOnFocusChangedCallback = void (long windowId);
[NoInterfaceObject]
interface BrowserExtWindows {
    Promise<BrowserExtWindowsWindow> create(CreateWindowDetails details);
    Promise<BrowserExtWindowsWindow> get(long windowId, optional BrowserExtGetWindowDetails details);
    Promise<sequence<BrowserExtWindowsWindow>> getAll(optional BrowserExtGetWindowDetail details);
    Promise<BrowserExtWindowsWindow> getCurrent(optional BrowserExtGetWindowDetail details);
    Promise<BrowserExtWindowsWindow> getLastFocused(optional BrowserExtGetWindowDetail details);
    void onFocusChanged(BrowserExtWindowsOnFocusChangedCallback callback);
    Promise<BrowserExtWindowsWindow> update(long windowId, optional BrowserExtWindowUpdateDetails details);
};
    
[NoInterfaceObject, Exposed=Window, CheckAnyPermissions="browserExt"]
interface BrowserExtWindowsAPI {
readonly attribute BrowserExtWindows windows; 
};
Browser implements BrowserExtWindowsAPI;
```

## 更多信息

各浏览器还支持大量其它API在这里未能尽录，请参考：

- [MDN](https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions/Browser_support_for_JavaScript_APIs)汇总了跨浏览器支持情况。
- [Microsoft docs](https://docs.microsoft.com/en-us/microsoft-edge/extensions)描述了Edge扩展。
- [Chrome文档](https://developer.chrome.com/extensions)。
- [W3C浏览器扩展社区小组](https://browserext.github.io/browserext/)提供了一个标准草案。
