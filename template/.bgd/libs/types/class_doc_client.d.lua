---@meta

-- ============================================================================
-- SCE 官方文档：客户端 Lua API —— "其它" 分类配套的表结构/类声明
-- ----------------------------------------------------------------------------
-- 与 base_doc_client.d.lua 配套使用，来源文档相同
-- （doc.sce.xd.com 技术文档 > 客户端Lua API > 其它）。
-- ============================================================================

-- ============================================================================
-- 画面：安全距离
-- ============================================================================

---屏幕上下左右边框的安全距离（如刘海的高度），以当前屏幕方向为准。【客户端】
---@class SafeInsets
---@field left number 左边框安全距离
---@field top number 上边框安全距离
---@field right number 右边框安全距离
---@field bottom number 下边框安全距离

-- ============================================================================
-- 性能分析：tracer 实例
-- ============================================================================

---性能分析 tracer 实例（require 'base.tracer' 的 new() 创建）。【客户端】
---@class Tracer
local Tracer = {}

---开始分析（与 finish 配套，将待分析代码段放于两者之间）。【客户端】
function Tracer:start() end

---结束分析，执行完毕后会在控制台输出函数堆栈及各函数调用耗时。【客户端】
function Tracer:finish() end

-- ============================================================================
-- UI场景控件属性
-- ============================================================================

---ui 场景控件的方向光设置。【客户端】
---@class UISceneLightDirectional
---@field direction number[] 方向，如 {-1148, -1530, 1000}
---@field color number[] 颜色，如 {1, 1, 1.1}
---@field shadow boolean 是否产生阴影

---ui 场景控件的光照设置。【客户端】
---@class UISceneLight
---@field directional UISceneLightDirectional 方向光

---base.ui.scene 控件属性表。【客户端】
---@class UISceneProps
---@field light UISceneLight 光照设置（显示模型时使用）
---@field [string] any 其它通用 UI 控件属性（layout 等）

-- ============================================================================
-- Spine动画控件属性
-- ============================================================================

---base.ui.spine 控件属性表。
---spine 动画资源需要放到地图 ui/spine 目录下；一套完整资源包括
---spine/rc_name.atlas、spine/rc_name.skel、spine/rc_name.png 三个文件。【客户端】
---@class UISpineProps
---@field resource string 资源路径，不包含扩展名，如 'spine/spineboy'
---@field loop boolean 是否循环播放
---@field animation string 指定播放的动画名，如 'idle'、'run' 等
---@field skin_name string 显示的皮肤
---@field [string] any 其它通用 UI 控件属性（layout 等）

-- ============================================================================
-- 内嵌视频控件属性
-- ============================================================================

---base.ui.video 控件属性表（实验阶段的控件；必须在最上层）。【客户端】
---@class UIVideoProps
---@field src string 视频资源地址，如 '/url/to/video_resource'
---@field [string] any 其它通用 UI 控件属性（layout 等）

-- ============================================================================
-- 自定义虚拟摇杆控件属性
-- ============================================================================

---base.ui.virtual_joystick 控件属性表（父控件，响应自定义事件）。
---提供的事件 on_vj_press / on_vj_release / on_vj_move_start / on_vj_move /
---on_vj_move_end 均传递参数 x, y, percent（x,y 为摇杆方向(ui坐标系)，
---percent 为摇杆百分比）。【客户端】
---@class VirtualJoystickProps
---@field vj_press_region_type integer 可点击区域类型（0方 1圆）
---@field vj_active_percent number 移动超过主摇杆 move_radius 多少时才触发 move 相关事件
---@field vj_center number[] 摇杆中心位置，以此算方向与百分比
---@field vj_is_press_center boolean 是否以按下时的位置为中心
---@field vj_is_release_reset boolean 松开的时候是否设置到按下之前的位置
---@field vj_auto_move boolean c++ 会处理移动
---@field vj_auto_skill boolean c++ 会处理技能指示器的位置
---@field on_vj_press fun(x: number, y: number, percent: number) 摇杆按下，取代 on_mouse_down
---@field on_vj_release fun(x: number, y: number, percent: number) 摇杆松开，取代 on_mouse_up
---@field on_vj_move_start fun(x: number, y: number, percent: number) 摇杆开始移动，百分比超过 vj_active_percent 时触发
---@field on_vj_move fun(x: number, y: number, percent: number) 摇杆移动，百分比超过 vj_active_percent 后有移动才会触发
---@field on_vj_move_end fun(x: number, y: number, percent: number) 会在 on_vj_release 之前触发
---@field [string] any 其它通用 UI 控件属性（layout、子控件等）

---base.ui.virtual_joystick_slider 控件属性表（子控件/拖动杆，
---可以以某点为中心跟随鼠标移动，其中需要有一个为主拖动杆）。【客户端】
---@class VirtualJoystickSliderProps
---@field vj_is_main_slider boolean 是否是主拖动杆（用来计算数据 x, y, percent）
---@field vj_toggle_show boolean 是否在按下和松开的时候改变 visible
---@field vj_move_radius number 移动范围半径（当 vj_is_press_center=false 时，将按下前位置作为中心；为 true 时以按下的位置为中心。按父节点高为 1）
---@field vj_move_ratio number 相对于鼠标移动的多少，默认是 1。即若鼠标移动 100，UI 会在移动范围内移动 100 * vj_move_ratio
---@field [string] any 其它通用 UI 控件属性（layout 等）

-- ============================================================================
-- 支付
-- ============================================================================

---支付商品（pay.fetch_products 返回列表中的元素）。【客户端】
---@class PayProduct
---@field [string] any 商品字段（文档未列出具体字段）

---支付结果（pay.pay 的返回值）。【客户端】
---@class PayResult
---@field result integer 结果码
---@field debugMessage string 失败原因
