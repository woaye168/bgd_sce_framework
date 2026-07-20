---@meta

-- ============================================================================
-- SCE 内置控件 / UI组件 类型声明（客户端）
-- ----------------------------------------------------------------------------
-- 覆盖范围：
--   内置控件：简介 / 排版 / 通用控件 / 通用属性 / 字体 / 颜色 / 绑定 / 事件 / 其它API
--   UI组件（@common.base.gui.component / @common.base.gui.control_util）
--   （过渡动画 transition 相关声明见 class_ui_transition.d.lua）
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/客户端Lua API/内置控件/简介
--   https://doc.sce.xd.com/技术文档/客户端Lua API/内置控件/排版
--   https://doc.sce.xd.com/技术文档/客户端Lua API/内置控件/通用控件
--   https://doc.sce.xd.com/技术文档/客户端Lua API/内置控件/通用属性
--   https://doc.sce.xd.com/技术文档/客户端Lua API/内置控件/字体
--   https://doc.sce.xd.com/技术文档/客户端Lua API/内置控件/颜色
--   https://doc.sce.xd.com/技术文档/客户端Lua API/内置控件/绑定
--   https://doc.sce.xd.com/技术文档/客户端Lua API/内置控件/事件
--   https://doc.sce.xd.com/技术文档/客户端Lua API/内置控件/其它API
--   https://doc.sce.xd.com/技术文档/客户端Lua API/UI组件/
-- 备注：
--   「颜色」页为纯概念说明（'#FF0000' / 'rgb(255,0,0)' / 'rgba(255,0,0,0.5)'
--   字符串格式），无独立 API，颜色均以 string 类型表示。
--   「绑定」页为机制说明，绑定对象（bind）声明为 UIBind（动态键值的表）。
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 排版（layout）
-- ----------------------------------------------------------------------------

---四边边框（margin / padding / border 的表格式）
---@class UIEdgeInsets
---@field top? number 上边框（像素）
---@field bottom? number 下边框（像素）
---@field left? number 左边框（像素）
---@field right? number 右边框（像素）
local UIEdgeInsets = {}

---排版属性。所有控件类型都支持排版，排版属性填写在 layout 属性内。【客户端】
---@class UILayout
---@field width? number 控件宽度，默认 -1。>=0 时使用此值；否则按 ratio/拉伸/文本/图片/子控件等情况计算
---@field height? number 控件高度，默认 -1。未定义时计算方式参考 width
---@field width_grow? number 宽度扩展系数。父控件有剩余空间时按系数扩展（0.5 表示占用 50% 剩余空间）
---@field height_grow? number 高度扩展系数。扩展方式参考 width_grow
---@field width_shrink? number 宽度收缩系数。父控件空间不足时按系数收缩（0.5 表示收缩 50% 溢出空间）
---@field height_shrink? number 高度收缩系数。收缩方式参考 width_shrink
---@field grow_width? number （准备弃用，用 width_grow 替代；width_grow > 0 时视为 0）宽度成长，>0 时 width 视为 0
---@field grow_height? number （准备弃用，用 height_grow 替代；height_grow > 0 时视为 0）高度成长，>0 时 height 视为 0
---@field margin? number|UIEdgeInsets 外边框宽度。数字表示四周相同，也可用 {top,bottom,left,right} 分别设置
---@field padding? number|UIEdgeInsets 内边框宽度。计算子控件空间时会扣除。格式同 margin
---@field position_type? string 定位方式：'relative' 相对定位（位置直接使用 position，不参与排版）；'absolute' 绝对定位（排版完成后按 position 偏移）
---@field position? number[] 位置 {x, y}。可能导致控件重叠，请谨慎使用
---@field direction? string 子控件排列方向：'row' 横向 / 'col' 竖向
---@field row_content? string 子控件横向排列方式（默认 'center'）：'start'/'center'/'end'/'space_between'/'space_around'/'stretch'
---@field col_content? string 子控件竖向排列方式（默认 'center'）：'start'/'center'/'end'/'space_between'/'space_around'/'stretch'
---@field row_self? string 自己横向排列方式：'start'/'center'/'end'/'stretch'。父控件 direction 为 'row' 时此属性无效
---@field col_self? string 自己竖向排列方式：'start'/'center'/'end'/'stretch'。父控件 direction 为 'col' 时此属性无效
---@field ratio? number[] 宽高比，如 {2, 1} 表示 2:1。宽度或高度未定义时生效
---@field translate? number[] 平移（官方示例中出现，如 {0.5, 0.5}）
local UILayout = {}

-- ----------------------------------------------------------------------------
-- 字体（font）
-- ----------------------------------------------------------------------------

---字体阴影
---@class UIFontShadow
---@field color? string 阴影颜色，如 '#000000'
---@field offset? number[] 偏移 {x, y}，如 {2, 2} 表示朝右 2px、朝下 2px
local UIFontShadow = {}

---字体。描述一段文本的样式，仅 label 控件支持。【客户端】
---@class UIFont
---@field size? number 字体大小
---@field color? string 字体颜色，如 '#FF0000'
---@field bold? boolean 加粗
---@field italic? boolean 斜体
---@field family? string 字体系列，目前支持：'Microsoft Yahei'（微软雅黑）、'SimSun'（宋体）
---@field align? string 横向对齐：'left'/'center'/'right'（建议用排版 row_content 代替）
---@field vertical_align? string 纵向对齐：'top'/'center'/'bottom'（建议用排版 col_content 代替）
---@field line_height? number 行高，单位为字体大小的倍数（如 1.2 表示行距为字体大小的 0.2 倍）
---@field shadow? UIFontShadow 阴影
---@field overflow? string 文本超出控件时的处理：'show' 显示 / 'hidden' 隐藏 / 'ellipsis' 超出部分用 ... 显示 / 'shrink' 缩小字体
local UIFont = {}

-- ----------------------------------------------------------------------------
-- 事件（event）
-- ----------------------------------------------------------------------------

---控件事件回调表。通过 bind.event 绑定（推荐），也可在定义的 event 属性中直接注册。【客户端】
---@class UIControlEvent
---@field on_mouse_enter? fun() 鼠标进入
---@field on_mouse_leave? fun() 鼠标离开
---@field on_mouse_down? fun() 鼠标按钮按下
---@field on_mouse_up? fun() 鼠标按钮抬起
---@field on_click? fun() 点击（在控件内鼠标按键按下后抬起时触发）
---@field on_double_click? fun() 双击（PC only）
---@field on_long_click? fun() 长按。长按事件触发后，点击事件不会再触发；可用 base.ui.event.set_long_click_timeout 修改触发延迟（毫秒）
---@field on_long_click_release? fun() 长按松开（触发长按事件后才会触发）
---@field on_input? fun(text: string) 输入框文本变化事件，text 为当前文本
---@field on_focus? fun() 输入框获取焦点
---@field on_focus_lose? fun() 输入框失去焦点
---@field on_drag? fun() 开始拖动控件时触发（需要 enable_drag = true）
---@field on_drop? fun(target: UIControl) 松开拖动的控件时触发（触发控件是被拖动的控件）。target 为松开鼠标时指向的控件，该控件需 enable_drop = true，否则触发 on_throw
---@field on_dropped? fun(source: UIControl) 被拖放目标控件触发，source 为被拖动的控件
---@field on_throw? fun() 控件被拖放到空白区域或未设置 enable_drop = true 的控件上时触发
local UIControlEvent = {}

-- ----------------------------------------------------------------------------
-- 绑定（bind）
-- ----------------------------------------------------------------------------

---绑定对象。base.ui.create 的第二个返回值。【客户端】
---修改其中的数据即可修改绑定的控件属性；阵列控件的绑定需要用索引区分操作对象
---（如 bind.text[1]、bind.item.image[6][6]）。
---命名必须符合 lua 语法，允许包含索引：'icon' / 'item.icon' / 'item["图标"]' / 'item[1]'。
---绑定目标必须是一个具体属性，不支持直接绑定整个结构。
---注意：多个属性绑定到同一对象且初始值各不相同时，读取绑定值的行为是未定义的。
---@class UIBind
local UIBind = {}

-- ----------------------------------------------------------------------------
-- 控件基类
-- ----------------------------------------------------------------------------

---UI 控件基类。包含所有控件的通用属性与实例方法。【客户端】
---通用属性既可在界面定义（模板）中设置，也可通过 bind 动态修改。
---@class UIControl
---@field name? string 命名。无实际功能，控件强制转换为字符串时会带上此名字，用于调试信息
---@field image? string 背景图片，控件会自动扩展为图片的大小
---@field color? string 背景颜色，如 '#ff1111'
---@field scale? number 控件缩放
---@field clip? boolean 裁剪。为 true 时，子控件超出父控件区域的部分会被裁剪掉
---@field enable_drag? boolean 可被拖动。未设置或为 false 时，拖动会向上找第一个可拖动的祖先控件；途中遇到 swallow_event 为 true 则返回
---@field enable_drop? boolean 可被放开。为 true 时允许其他控件拖到本控件上（触发 on_drop 事件）
---@field flip_x? boolean 图片水平翻转
---@field flip_y? boolean 图片竖直翻转
---@field border? number|UIEdgeInsets 九宫格边框。不设置时读取图集中的边框宽度；数字表示四边相同
---@field round_corner_radius? number 圆角半径
---@field mask_image? string 遮罩图片（应带透明通道），控件按透明通道形状剪裁
---@field rotate? number 旋转。使控件绕中心顺时针旋转某一角度
---@field show? boolean 显示。为 false 时控件不可见，也不参与排版
---@field static? boolean 静态。为 true 后控件不接收任何事件（事件可穿透）
---@field disabled? boolean 禁用。为 true 时控件及所有子控件的事件全部失效
---@field swallow_event? boolean 吃掉事件。为 true 后事件不再向父控件传递
---@field swallow_events? string 指定要吃掉的事件（设置后 swallow_event 被忽略）。以 ',' 隔开，如 'mouse_click,mouse_down,drag'；事件集合以 '#' 开头（'#all'、'#mouse'）；前加 '!' 取反（如 '!#mouse'）。事件名：mouse_click/on_click、mouse_double_click/on_double_click、mouse_down/on_mouse_down、mouse_leave/on_mouse_leave、mouse_enter/on_mouse_enter、drag/on_drag、drop/on_drop
---@field z_index? number 层级。多个子控件互相重叠时，z_index 较大的在上面
---@field low_level? boolean 下层 UI 控件。用于 UI 里显示模型时需要 UI 背景的场景；子 UI 不天然是下层 UI，需手动设置。存在 UI 场景时下层 UI 受后效（Bloom）影响，建议主要使用深色。不影响 z_index 层级关系
---@field layout? UILayout 排版属性
---@field event? UIControlEvent 事件回调（推荐使用 bind.event 注册）
---@field bind? table 界面定义中的绑定声明（属性路径 -> 绑定名字符串）
---@field transition? UITransition 过渡动画（见 class_ui_transition.d.lua）
local UIControl = {}

---添加子控件。将一个控件添加为另一个控件的子控件。【客户端】
---@param child UIControl 子控件
---@return boolean result 是否成功
function UIControl:add_child(child) end

---帧事件。给控件注册回调函数，每帧调用。一个控件可注册多个回调；【客户端】
---控件被移除后回调不再运行，也可主动调用返回的销毁器使回调不再运行。
---@param callback fun(delta: number) 回调函数，delta 为经过的时间（毫秒）
---@return fun() destructor 销毁器
function UIControl:on_tick(callback) end

---移除。移除一个控件以及它的所有子控件。【客户端】
---@return boolean result 是否成功
function UIControl:remove() end

---获取 UI 图片的原始宽高。【客户端】
---当前帧无法获取到 id，需要在下一帧调用（如用 base.next 包裹）；无图片时返回 0.0, 0.0。
---@return number width UI 图片的原始宽度
---@return number height UI 图片的原始高度
function UIControl:get_image_wh() end

---获取控件的位置与大小。（官方 UI 组件文档示例中出现，未单独说明）【客户端】
---@return number x
---@return number y
---@return number w
---@return number h
function UIControl:rect() end

-- ----------------------------------------------------------------------------
-- 具体控件
-- ----------------------------------------------------------------------------

---按钮控件。鼠标悬停或按下时可以改变图片。【客户端】
---@class UIButton: UIControl
---@field hover_image? string 悬停图片。鼠标悬停在按钮上时显示
---@field active_image? string 激活图片。鼠标按下按钮时显示
local UIButton = {}

---标签控件。用于显示文本或图片。【客户端】
---@class UILabel: UIControl
---@field text? string 文本。支持富文本标签：color、b、i、u、br（结束标签可省略为 '</>'），支持 '\n' 换行
---@field font? UIFont 字体
local UILabel = {}

---面板控件。最基础的容器模板，只有这个类型的模板才能添加子模板以及设置阵列属性。【客户端】
---@class UIPanel: UIControl
---@field array? integer 阵列。设置后子控件会被复制 N 份
---@field enable_scroll? boolean 滚动条
---@field scroll_direction? string 滚动方向：'horizontal' 水平 / 'vertical' 竖直（默认竖直）
---@field scroll_image? string 滚动条图片
---@field scroll_color? string 滚动条颜色
---@field scroll_width? number 滚动条宽度
local UIPanel = {}

---进度条控件。可以按照指定百分比来显示部分图片。【客户端】
---进度条默认使用九宫图中心部分作为进度，边上八块作为边框；bordered 类型进度部分使用完整九宫图（省略边框）。
---@class UIProgress: UIControl
---@field progress? number 进度，取值范围 [0, 1]
---@field progress_type? string 进度类型：'left' 从右往左 / 'right' 从左往右 / 'up' 从下往上 / 'down' 从上往下 / 'clockwise' 顺时针 / 'counter_clockwise' 逆时针 / 'bordered left' / 'bordered right' / 'bordered up' / 'bordered down'（带边框的进度）
local UIProgress = {}

---UI 特效控件。可以在 UI 上显示一些特定类型的特效。【客户端】
---@class UIParticle: UIControl
---@field effect? string 特效相对路径，必须以 'effect/' 开头。若该特效没有被其他地方引用过，需在数据编辑器创建额外的粒子表现引用该特效并勾选"资源统计"，否则发布后的游戏会丢失该特效
---@field play? boolean 是否播放
---@field direct_scale? number[] 缩放，如 {1, 1}
---@field speed? number 播放速度
local UIParticle = {}

---序列帧动画控件。通过 image 属性设置序列帧图片集。【客户端】
---@class UISprites: UIControl
---@field frame_count? integer 一共有多少帧
---@field row_frame_count? integer 每行有多少帧
---@field start_frame? integer 动画第一帧 [1, frame_count]（可以大于 end_frame）
---@field end_frame? integer 动画最后一帧 [1, frame_count]
---@field sprite_size? number[] 每帧的大小（像素），如 {190, 240}
---@field loop? boolean 是否循环播放
---@field interval? integer 每帧间隔时间（毫秒）
---@field playing? boolean 是否播放
local UISprites = {}

---输入框控件。（通用属性页 return_key 提及）【客户端】
---@class UIInput: UIControl
---@field text? string 文本
---@field return_key? string 软键盘回车键类型：'default'/'go'/'done'/'search'/'next'/'send'
local UIInput = {}

---webview 控件。（通用属性页 url/html 提及）【客户端】
---@class UIWebView: UIControl
---@field url? string webview 加载网页的 url
---@field html? string webview 加载网页的 html 文本
local UIWebView = {}

---video 控件。（通用属性页 src 提及）【客户端】
---@class UIVideo: UIControl
---@field src? string video 加载视频的源 url
local UIVideo = {}

-- ----------------------------------------------------------------------------
-- 控件属性表（模板构造函数的参数）
-- 模板构造时传入的只是属性配置表，不包含实例方法，因此与实例类分开声明；
-- [string] any 兜底用于容纳嵌套的子控件模板（子控件名 -> 模板表）。
-- ----------------------------------------------------------------------------

---base.ui.panel 的属性表。【客户端】
---@class UIPanelProps
---@field array? integer 阵列。设置后子控件会被复制 N 份
---@field enable_scroll? boolean 滚动条
---@field scroll_direction? string 滚动方向：'horizontal' 水平 / 'vertical' 竖直（默认竖直）
---@field scroll_image? string 滚动条图片
---@field scroll_color? string 滚动条颜色
---@field scroll_width? number 滚动条宽度
---@field name? string 命名（调试用）
---@field image? string 背景图片
---@field color? string 背景颜色，如 '#ff1111'
---@field scale? number 控件缩放
---@field clip? boolean 裁剪子控件超出部分
---@field enable_drag? boolean 可被拖动
---@field enable_drop? boolean 可被放开
---@field flip_x? boolean 图片水平翻转
---@field flip_y? boolean 图片竖直翻转
---@field border? number|UIEdgeInsets 九宫格边框
---@field round_corner_radius? number 圆角半径
---@field mask_image? string 遮罩图片
---@field rotate? number 旋转角度
---@field show? boolean 显示
---@field static? boolean 静态（不接收事件）
---@field disabled? boolean 禁用
---@field swallow_event? boolean 吃掉事件
---@field swallow_events? string 指定要吃掉的事件
---@field z_index? number 层级
---@field low_level? boolean 下层 UI 控件
---@field layout? UILayout 排版属性
---@field event? UIControlEvent 事件回调
---@field bind? table 绑定声明
---@field transition? UITransition 过渡动画
---@field [string] any 嵌套的子控件模板（控件名 -> 模板表）及其它扩展属性
local UIPanelProps = {}

---base.ui.button 的属性表。【客户端】
---@class UIButtonProps: UIPanelProps
---@field hover_image? string 悬停图片
---@field active_image? string 激活（按下）图片
local UIButtonProps = {}

---base.ui.label 的属性表。【客户端】
---@class UILabelProps: UIPanelProps
---@field text? string 文本（支持富文本标签与 '\n' 换行）
---@field font? UIFont 字体
local UILabelProps = {}

---base.ui.progress 的属性表。【客户端】
---@class UIProgressProps: UIPanelProps
---@field progress? number 进度，取值范围 [0, 1]
---@field progress_type? string 进度类型，如 'left' / 'clockwise' / 'bordered left' 等
local UIProgressProps = {}

---base.ui.particle 的属性表。【客户端】
---@class UIParticleProps: UIPanelProps
---@field effect? string 特效相对路径，必须以 'effect/' 开头
---@field play? boolean 是否播放
---@field direct_scale? number[] 缩放，如 {1, 1}
---@field speed? number 播放速度
local UIParticleProps = {}

---base.ui.sprites 的属性表。【客户端】
---@class UISpritesProps: UIPanelProps
---@field frame_count? integer 一共有多少帧
---@field row_frame_count? integer 每行有多少帧
---@field start_frame? integer 动画第一帧
---@field end_frame? integer 动画最后一帧
---@field sprite_size? number[] 每帧大小（像素）
---@field loop? boolean 是否循环播放
---@field interval? integer 每帧间隔（毫秒）
---@field playing? boolean 是否播放
local UISpritesProps = {}

---base.ui.input 的属性表。【客户端】
---@class UIInputProps: UIPanelProps
---@field text? string 文本
---@field return_key? string 软键盘回车键类型：'default'/'go'/'done'/'search'/'next'/'send'
local UIInputProps = {}

---base.ui.webview 的属性表。【客户端】
---@class UIWebViewProps: UIPanelProps
---@field url? string 加载网页的 url
---@field html? string 加载网页的 html 文本
local UIWebViewProps = {}

-- ----------------------------------------------------------------------------
-- base.ui 模板构造函数与静态 API
-- ----------------------------------------------------------------------------

---定义面板控件模板。【客户端】
---@param props UIPanelProps 控件属性表（子控件模板可直接写在表内，array 属性可复制子控件）
---@return UIPanel template 控件模板（用于 base.ui.create）
function base.ui.panel(props) end

---定义按钮控件模板。【客户端】
---@param props UIButtonProps 控件属性表
---@return UIButton template 控件模板
function base.ui.button(props) end

---定义标签控件模板。【客户端】
---@param props UILabelProps 控件属性表
---@return UILabel template 控件模板
function base.ui.label(props) end

---定义进度条控件模板。【客户端】
---@param props UIProgressProps 控件属性表
---@return UIProgress template 控件模板
function base.ui.progress(props) end

---定义 UI 特效控件模板。【客户端】
---@param props UIParticleProps 控件属性表
---@return UIParticle template 控件模板
function base.ui.particle(props) end

---定义序列帧动画控件模板。【客户端】
---@param props UISpritesProps 控件属性表
---@return UISprites template 控件模板
function base.ui.sprites(props) end

---定义输入框控件模板。（通用属性页 return_key 提及该控件类型）【客户端】
---@param props UIInputProps 控件属性表
---@return UIInput template 控件模板
function base.ui.input(props) end

---定义 webview 控件模板。（通用属性页 url/html 提及该控件类型）【客户端】
---@param props UIWebViewProps 控件属性表
---@return UIWebView template 控件模板
function base.ui.webview(props) end

---创建控件。创建模板时其内部子控件会被一并创建。【客户端】
---name 命名用于服务器修改界面（服务端通过命名访问绑定）。
---@param template table 界面定义（base.ui.panel{} 等模板构造函数返回的模板）
---@param name? string 命名
---@return UIControl ui 控件
---@return UIBind bind 绑定对象
function base.ui.create(template, name) end

---将绑定对象绑定到单位。（官方文档 remove 一节示例中出现：base.ui.bind_unit(poi.hero, bind, 0, 50)，未单独说明）【客户端】
---@param unit Unit 单位
---@param bind UIBind 绑定对象
---@param x number 偏移 X
---@param y number 偏移 Y
---@return any
function base.ui.bind_unit(unit, bind, x, y) end

---设置长按判定时间（触发长按的延迟），单位毫秒。【客户端】
---@param time number 长按时长（毫秒）
function base.ui.event.set_long_click_timeout(time) end

---当前 UI 的缩放值。【客户端】
---UI 屏幕分辨率适配：参考分辨率为 2340x1080，ui 根据实际分辨率与参考分辨率的比值缩放，
---ui 上固定像素值的属性（border、font.size、layout.width/height/position 等）都会乘上该缩放值。
---@return number result 当前 UI 的缩放值
function base.ui.auto_scale.current_scale() end

-- ----------------------------------------------------------------------------
-- UI 组件（@common.base.gui.component）
-- ----------------------------------------------------------------------------

---UI 组件实例。【客户端】
---以下为实例保留字段，不要修改这些字段，否则行为未定义。
---@class UIComponent
---@field class UIComponentClass 所属组件
---@field base UIComponent|UIControl 基控件（组件模板定义的根控件，可理解为继承关系）
---@field part table<string, UIComponent[]|UIControl[]> 部件表（部件名 -> 含所有该名部件控件的表）
---@field prop table<string, any> 属性表
---@field method table<string, function> 方法表
---@field data table<string, any> 数据表（实例私有数据，与一般 lua 表一致）
---@field child UIComponent[]|UIControl[] 子控件（组件定义外添加的控件）
---@field parent UIComponent|UIControl|nil 父控件
---@field ui UIControl 根内置控件
---@field bind UIBind 老绑定表
---@field state any 状态接口
---@field connection any 事件注册表
local UIComponent = {}

---（生命周期）初始化时调用。一般只覆写，不要在外部显式调用。【客户端】
function UIComponent:init() end

---（生命周期）每帧调用。一般只覆写，不要在外部显式调用。【客户端】
---@param delta_time number 距上一帧经过的时间
function UIComponent:update(delta_time) end

---（生命周期）销毁时调用。一般只覆写，不要在外部显式调用。【客户端】
function UIComponent:on_destroy() end

---根据选择字串在当前控件处构建选择器。部件名以 '@' 引导（如 '@btn'、'@btn.layout'）。【客户端】
---@param selector_str string 选择字串
---@return UIComponentSelector selector 选择器
function UIComponent:select(selector_str) end

---触发组件自定义事件（事件参数在 emit 时传入）。组件自定义事件按连接顺序多播。【客户端】
---@param event_name_str string 事件名
---@param ... any 事件参数
function UIComponent:emit(event_name_str, ...) end

---注册/连接事件响应函数。【客户端】
---@param event_name_str string 事件名
---@param handler fun(self: UIComponent, ...: any) 事件响应函数
---@return UIComponentConnection connection 事件连接（可用 connection:remove() 或 self:disconnect(connection) 注销）
function UIComponent:connect(event_name_str, handler) end

---注销/断开事件响应。【客户端】
---@param connection UIComponentConnection 事件连接
function UIComponent:disconnect(connection) end

---销毁组件及其子控件。【客户端】
function UIComponent:destroy() end

---设置对应状态到指定状态值。状态初值都为 nil（未指定）。【客户端】
---@param state_name string 状态名
---@param state_value any 状态值
function UIComponent:set_state(state_name, state_value) end

---返回对应状态的当前状态值。【客户端】
---@param state_name string 状态名
---@return any state_value 当前状态值
function UIComponent:get_state(state_name) end

---根据模板创建子控件并返回。【客户端】
---@param template table 控件模板（组件模板或内置控件模板）
---@return UIComponent|UIControl ctrl 创建的子控件
function UIComponent:new_child(template) end

---UI 组件类型（component 函数定义组件的返回值）。【客户端】
---使用 `<组件>{}` 可创建组件模板（可填写属性修改或选择器设置），模板不会创建实例。
---@class UIComponentClass
local UIComponentClass = {}

---创建组件实例。也可用 component.new(<组件模板/内置控件模板>) 创建。【客户端】
---@return UIComponent instance 组件实例
function UIComponentClass:new() end

---UI 组件选择器。【客户端】
---@class UIComponentSelector
local UIComponentSelector = {}

---使用选择器获取部件（单个控件）。【客户端】
---@return UIComponent|UIControl ctrl 选中的控件
function UIComponentSelector:get() end

---使用选择器设置部件属性。【客户端】
---@param props table<string, any> 属性表（如 {width = 100, height = 100}）
function UIComponentSelector:set(props) end

---UI 组件事件连接（connect 的返回值，类似触发的对象）。【客户端】
---@class UIComponentConnection
local UIComponentConnection = {}

---注销事件连接。【客户端】
function UIComponentConnection:remove() end

---UI 组件库，通过 `require '@common.base.gui.component'` 获取。【客户端】
---模块本身可调用：`component { def }` 或 `component 'Name' { def }` 定义组件类型并返回 UIComponentClass。
---组件定义表可包含：[1] 组件模板定义、prop 属性定义、data 数据定义、method 方法定义、event 事件定义、state 状态定义（均可缺省）。
---@class UIComponentLib
---@field bind any 绑定到属性。可索引（bind.width）也可调用（bind 'height'），用于将控件属性单向绑定到组件属性；组件属性被修改时会设置所有绑定到它的目标属性
---@field alias_by any 别名转发表。在部件模板中使用（如 color = alias_by.color），在组件中创建对应别名属性
---@field default_child_slot any 子控件插入位置标记。放在组件模板中表示子控件的默认插入位置
local UIComponentLib = {}

---从组件模板/内置控件模板创建实例（不支持直接传组件类型）。【客户端】
---@param template table 组件模板或内置控件模板（如 A{}、base.ui.panel{}）
---@return UIComponent|UIControl ctrl 创建的实例
function UIComponentLib.new(template) end

---销毁组件实例/内置控件实例。也可用 `<组件实例>:destroy()`。【客户端】
---@param instance UIComponent|UIControl 组件实例或内置控件实例
function UIComponentLib.destroy(instance) end

---定义 getset 属性。对属性的读写会对应调用 get 与 set 函数。【客户端】
---set 返回 true 时触发属性修改事件与绑定传播，否则不触发。
---@param def { get: fun(self: UIComponent): any, set: fun(self: UIComponent, v: any): boolean } get/set 定义
---@return any prop 属性定义（填入 prop 表）
function UIComponentLib.getset(def) end

---定义别名属性。转发读写到部件属性，对别名属性读写如同对目标属性进行。【客户端】
---返回值可用初值调用：`alias '@inner_panel.layout.height' (100)`，100 作为初值。
---@param selector_str string 选择器字符串（如 '@btn.color'）
---@return any prop 属性定义（填入 prop 表）
function UIComponentLib.alias(selector_str) end

---定义老绑定属性（用于过渡，应尽量避免使用）。【客户端】
---通过该属性读写如同对对应的 self.bind.<bind_name> 进行。
---@param bind_name string 绑定名
---@return any prop 属性定义（填入 prop 表）
function UIComponentLib.legacy_bind_prop(bind_name) end

---自定义值动画插值（暂只支持数值的线性插值），用于关键帧状态数据中。【客户端】
---time 单位毫秒。用法：anim_trans{time = 4000; 1000, 0.1}
---@param def table 插值定义（含 time 字段与数值序列）
---@return table anim 插值数据
function UIComponentLib.anim_trans(def) end

---定义关键帧状态。【客户端】
---第一个表是选择器字符串数组，表示状态数据中各下标处数据的目标；
---第二个表键为状态值，值为关键帧数据，进入某状态值时数据会设置到对应目标。
---用法：key_frame_state{'b_height', '@a.layout.grow_width'}{ active = { anim_trans{...} } }
---@param targets string[] 选择器字符串数组
---@return fun(state_data: table): table state 状态定义
function UIComponentLib.key_frame_state(targets) end

---控件辅助函数库，通过 `require '@common.base.gui.control_util'` 获取。【客户端】
---@class UICtrlUtil
local UICtrlUtil = {}

---设置控件属性（内置控件需要通过本函数设置属性）。【客户端】
---@param ctrl UIControl|UIComponent 控件
---@param prop_name string 属性名
---@param value any 属性值
function UICtrlUtil.set_ctrl_prop(ctrl, prop_name, value) end

---获取控件属性。【客户端】
---@param ctrl UIControl|UIComponent 控件
---@param prop_name string 属性名
---@return any value 属性值
function UICtrlUtil.get_ctrl_prop(ctrl, prop_name) end

---获取控件类型名（如 'label'）。【客户端】
---@param ctrl UIControl|UIComponent 控件
---@return string type_name 控件类型名
function UICtrlUtil.get_ctrl_type_name(ctrl) end

---判断控件是否存在。【客户端】
---@param ctrl UIControl|UIComponent 控件
---@return boolean exists 是否存在
function UICtrlUtil.is_ctrl_exists(ctrl) end

---获取最终扩展组件。【客户端】
---@param ctrl UIControl|UIComponent 控件
---@return UIComponent component 最终扩展组件
function UICtrlUtil.get_final_ext_component(ctrl) end

---把控件移动到新的父控件下。【客户端】
---@param ctrl UIControl|UIComponent 控件
---@param new_parent UIControl|UIComponent 新父控件
function UICtrlUtil.move_to_new_parent(ctrl, new_parent) end

---判断是否为组件控件。【客户端】
---@param ctrl UIControl|UIComponent 控件
---@return boolean is_component 是否为组件控件
function UICtrlUtil.is_component_ctrl(ctrl) end

---将控件属性绑定到本地玩家的属性上。【客户端】
---通过 `require '@common.base.gui.on_player_prop'` 获取，返回的可调用对象用法：
---`base.ui.label { text = on_player_prop('金钱') }`。
---玩家属性由服务端同步（玩家增加属性 / 设置玩家字符型属性 / 设置玩家数值型属性）。
---@alias on_player_prop fun(prop_name: string): any

-- ----------------------------------------------------------------------------
-- UI 组件内置事件（在组件定义 event 字段中定义，内置事件会被自动定义为 true，
-- 除非手动在定义中置为 false）
--   on_prop_change_<prop_name>(self, value)  对应属性被修改后触发
--   on_tick(self, delta_time)                （定义后）每帧触发
--   on_remove(self)                          组件的根内置控件销毁时触发
-- UI 组件子控件插入位置相关回调（method 中定义）：
--   on_add_child(self, ctrl)                 对新的子控件实例进行读写
--   on_new_child(self, t) -> template|nil    对将要创建的子控件模板预处理（返回值不是模板则不会被创建）
-- ----------------------------------------------------------------------------
