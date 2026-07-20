---@meta

-- ============================================================================
-- SCE 官方文档：客户端 Lua API —— "其它" 分类
-- ----------------------------------------------------------------------------
-- 覆盖主题：
--   自定义设置 / 客户端发送自定义消息给服务端 / 屏幕后效 / 画面(屏幕杂项) /
--   性能分析 / UI场景 / Spine动画 / 内嵌视频 / 判断平台 / 支付 /
--   自定义虚拟摇杆 / 数学 / 操作模型 / 其它API
-- 来源文档（doc.sce.xd.com 技术文档 > 客户端Lua API > 其它）：
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/自定义设置
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/客户端发送自定义消息给服务端
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/屏幕后效
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/屏幕杂项API
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/性能分析
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/UI场景
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/Spine动画
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/内嵌视频
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/判断平台
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/支付
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/自定义虚拟摇杆
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/数学
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/操作模型
--   https://doc.sce.xd.com/技术文档/客户端Lua API/其它/其它API
-- 注：配套表结构（SafeInsets/UISpineProps/VirtualJoystickProps 等）见
--     class_doc_client.d.lua。
-- ============================================================================

-- ============================================================================
-- 自定义设置（base.setting / base.settings）
-- 使用 get_option 查询某一个 key 时，返回结果优先级从高到低：
--   当前地图下用户设置的值 -> 当前地图设置的默认值 -> 游戏大厅中用户设置的值
--   -> 游戏大厅设置的默认值；如果都没有就返回空，启动页会被算作大厅。
-- 注册的回调不会判断场景，重复注册会覆盖。
-- ============================================================================

---隐藏设置界面。【客户端】
---@return boolean valid 是否合法
function base.setting:hide() end

---显示设置界面。【客户端】
---@return boolean valid 是否合法
function base.setting:show() end

---是否显示。【客户端】
---@return boolean visible 是否显示
function base.setting:is_visible() end

---把某一个 key 对应的 value 存下来（一个 key 只对应一个 value，重复保存会覆盖），
---部分功能已经在 c++ 实现。value 类型：string 对应字符串；bool 布尔值；number 浮点数。【客户端】
---@param key string 该设置的名字
---@param value string|number|boolean 该设置对应的值
function base.settings:save_option(key, value) end

---获取某一个 key 对应的 value（优先级见文件头说明，都没有则返回空）。【客户端】
---@param key string 该设置的名字
---@return string|number|boolean|nil value 该设置对应的值
function base.settings:get_option(key) end

---设置某一个 key 对应的 value，调用设置函数和注册的回调函数，
---但并不把值保存起来，用于设置默认值。【客户端】
---@param key string 该设置的名字
---@param value string|number|boolean 该设置对应的值
function base.settings:set_option(key, value) end

---注册一个回调，当 save 的时候会触发回调。注册的回调不会判断场景，重复注册会覆盖。【客户端】
---@param key string 该设置的名字
---@param callback fun(value: string|number|boolean) 回调函数，传入的参数是 key 对应的 value
function base.settings:register_option(key, callback) end

---为一个地图下的 key 设置默认值。【客户端】
---@param key string 该设置的名字
---@param value string|number|boolean 该设置对应的值
function base.settings:set_default_option(key, value) end

-- ============================================================================
-- 客户端发送自定义消息给服务端
-- 注意：服务端不应信任来自客户端的数据！玩家可以用内存修改器修改客户端内存，
-- 绕过客户端判断条件，发送构造过的协议（文档特别提示）。
-- 服务端接收方式：function base.ui.proto.message_type(player, data) ... end
-- ============================================================================

---客户端发送自定义消息给服务端（server 表示向服务器发）。
---用法：base.game:server 'message_type' (data)。【客户端】
---@param type string 消息类型名
---@return fun(data: table) 发送函数，调用时传入消息数据表
function base.game:server(type) end

-- ============================================================================
-- 屏幕后效（common.*）
-- 可以同时存在多种后效。
-- ============================================================================

---打开或修改某后效，参数为后效名称及相关参数，可以同时有多种后效。
---已知后效：
---  "GaussianBlur" 高斯模糊，参数为强度(number)，范围 1-15；
---  "Saturation"   饱和度，参数为一个浮点数 0-1，为 0 时黑白效果，为 1 时原始效果；
---  "Multiply"     正片叠底，参数为四个浮点数，前三个是颜色 rgb，最后一个是强度。【客户端】
---@param name string 后效名称
---@param ... number 后效参数（视后效类型而定）
function common.open_and_set_posteffect(name, ...) end

---关闭某后效。【客户端】
---@param name string 后效名称
function common.remove_posteffect(name) end

-- ============================================================================
-- 画面（屏幕杂项 API，base.screen）
-- ============================================================================

---获取画面分辨率。【客户端】
---@return integer width 宽度
---@return integer height 高度
function base.screen:get_resolution() end

---设置画面分辨率。【客户端】
---@param width integer 宽度
---@param height integer 高度
function base.screen:set_resolution(width, height) end

---获取屏幕方向。【客户端】
---@return string orientation 方向：`Unknown`、`LandscapeRight`、`LandscapeLeft`、`Portrait`、`PortraitUpsideDown`
function base.screen:get_orientation() end

---获取屏幕上下左右边框的安全距离（如刘海的高度），以当前屏幕方向为准。【客户端】
---@return SafeInsets safe_insets 上下左右边框的安全距离
function base.screen:get_safe_insets() end

---设置是否 ui 自动适配，默认关闭。建议使用 get_safe_insets 手动适配。【客户端】
---@param enable boolean 是否启用
function base.screen:enable_safe_area(enable) end

---获取鼠标位置。【客户端】
---@return Point position 位置
function base.screen:input_mouse() end

---隐藏/显示鼠标指针。【客户端】
---@param visible boolean 显示/隐藏
function base.screen:set_cursor_visible(visible) end

-- ============================================================================
-- 性能分析（require 'base.tracer'）
-- 用于分析一段代码的调用耗时。执行完毕后会在控制台输出函数堆栈及各函数
-- 调用耗时（第一列为函数名及定义行号，系统 api 行号为 -1；第二列总耗时；
-- 第三列总调用次数）。
-- ============================================================================

---@class base.tracer
local tracer = {}

---新创建一个 tracer，将要分析的代码段放于 start() 和 finish() 之间。【客户端】
---@return Tracer
function tracer.new() end

-- ============================================================================
-- UI场景（base.ui.scene）
-- ui 场景控件，可显示一个模型。关于相机参数：可在地形编辑器内摆好模型并
-- 调整相机到合适位置，然后把相机参数拷贝到代码里。最好保持地形视口的
-- 宽高比同 ui.scene 控件的宽高比一致，相机参数才够正确。
-- ============================================================================

---创建 ui 场景控件（显示一个模型）。支持的独特属性：light（方向光等，见 UISceneProps）。【客户端】
---@param props UISceneProps 控件属性表
---@return UIControl
function base.ui.scene(props) end

-- ============================================================================
-- Spine动画（base.ui.spine）
-- spine 动画资源需要放到地图 ui/spine 目录下；一套完整资源包括
-- spine/rc_name.atlas、spine/rc_name.skel、spine/rc_name.png 三个文件，
-- resource 属性只传 'spine/rc_name' 即可（不包含扩展名）。
-- ============================================================================

---创建 spine 动画控件。【客户端】
---@param props UISpineProps 控件属性表（resource/loop/animation/skin_name 等）
---@return UIControl
function base.ui.spine(props) end

-- ============================================================================
-- 内嵌视频（base.ui.video）
-- 实验阶段的控件；必须在最上层。可用于播放一段视频。
-- ============================================================================

---创建内嵌视频控件（实验阶段，必须在最上层）。【客户端】
---@param props UIVideoProps 控件属性表（src 为视频资源地址）
---@return UIControl
function base.ui.video(props) end

-- ============================================================================
-- 判断平台（require 'base.platform'）
-- 用于判断客户端运行环境，返回值都为 bool 类型。
-- ============================================================================

---@class base.platform
local platform = {}

---判断是否为 PC。【客户端】
---@return boolean
function platform.is_win() end

---判断是否为网页。【客户端】
---@return boolean
function platform.is_web() end

---判断是否为 pc 网页。【客户端】
---@return boolean
function platform.is_web_pc() end

---判断是否为移动端网页。【客户端】
---@return boolean
function platform.is_web_mobile() end

---判断是否为 ios 网页。【客户端】
---@return boolean
function platform.is_web_ios() end

---判断是否为安卓网页。【客户端】
---@return boolean
function platform.is_web_android() end

---判断是否为微信。【客户端】
---@return boolean
function platform.is_wx() end

---判断是否为微信（iOS）。【客户端】
---@return boolean
function platform.is_wx_ios() end

---判断是否为微信（安卓）。【客户端】
---@return boolean
function platform.is_wx_android() end

---判断是否为微信（开发者工具）。【客户端】
---@return boolean
function platform.is_wx_devtool() end

---判断是否为 QQ。【客户端】
---@return boolean
function platform.is_qq() end

---判断是否为 QQ（iOS）。【客户端】
---@return boolean
function platform.is_qq_ios() end

---判断是否为 QQ（安卓）。【客户端】
---@return boolean
function platform.is_qq_android() end

---判断是否为 QQ（开发者工具）。【客户端】
---@return boolean
function platform.is_qq_devtool() end

---是否为安卓 app。【客户端】
---@return boolean
function platform.is_android() end

---是否为 iOS app。【客户端】
---@return boolean
function platform.is_ios() end

---是否为移动 app，等价于 is_android() or is_ios()。【客户端】
---@return boolean
function platform.is_mobile() end

---是否为启动页 lua 环境，如果是游戏 lua 环境，返回 false。【客户端】
---@return boolean
function platform.is_app() end

-- ============================================================================
-- 支付（require '@common.base.pay'，配合 require '@common.base.co'）
-- 支付 api 基本都涉及网络等耗时操作，不会同步完成，为避免回调套回调，
-- api 封装成需要在协程中使用：co.async(function() ... end)。
-- 支付完成后，后端发放商品成功后会给 host 推送一个消息。
-- ============================================================================

---@class common.base.co
local co = {}

---在协程中执行函数（支付等耗时 api 需在协程中调用）。【客户端】
---@param fn fun() 要在协程中执行的函数
function co.async(fn) end

---@class common.base.pay
local pay = {}

---获取商品列表（需在协程中调用）。【客户端】
---@return PayProduct[] items 商品列表
function pay.fetch_products() end

---购买某个商品（需在协程中调用）。
---支付完成后，后端发放商品成功后会给 host 推送一个消息。【客户端】
---@param item PayProduct 商品（fetch_products 返回列表中的一项）
---@param count integer 购买数量
---@return PayResult res 支付结果 {result = code, debugMessage = '失败原因'}
function pay.pay(item, count) end

-- ============================================================================
-- 自定义虚拟摇杆（base.ui.virtual_joystick / base.ui.virtual_joystick_slider）
-- 虚拟摇杆主要由一个父 UI 和多个子 UI 组成，父 UI 为 virtual_joystick，
-- 子 UI 为 virtual_joystick_slider，其中子 UI 需要有一个为主拖动杆。
-- 新事件 on_vj_press / on_vj_release / on_vj_move_start / on_vj_move /
-- on_vj_move_end 均传递参数 x, y, percent（x,y 为摇杆方向(ui坐标系)，
-- percent 为摇杆百分比），可正确判断多指同时按下的情况。
-- ============================================================================

---创建虚拟摇杆父控件，用来响应一些自定义事件（属性见 VirtualJoystickProps）。【客户端】
---@param props VirtualJoystickProps 控件属性表
---@return UIControl
function base.ui.virtual_joystick(props) end

---创建虚拟摇杆拖动杆（子控件），可以以某点为中心跟随鼠标移动
---（属性见 VirtualJoystickSliderProps）。【客户端】
---@param props VirtualJoystickSliderProps 控件属性表
---@return UIControl
function base.ui.virtual_joystick_slider(props) end

-- ============================================================================
-- 数学（base.math.*，三角函数为角度制）
-- ============================================================================

---反余弦。【客户端】
---@param cos number 余弦值
---@return number angle 角度
function base.math.acos(cos) end

---反正弦。【客户端】
---@param sin number 正弦值
---@return number angle 角度
function base.math.asin(sin) end

---反正切。返回 y/x 的反正切值（用角度表示），会使用两个参数的符号来判断
---结果落在哪个象限（即使 x 为零时也可以正确处理）。默认的 x 是 1，
---因此调用 base.math.atan(y) 将返回 y 的反正切值。【客户端】
---@param y number 对边
---@param x? number 临边，默认 1
---@return number angle 角度
function base.math.atan(y, x) end

---余弦。【客户端】
---@param angle number 角度
---@return number cos 余弦值
function base.math.cos(angle) end

---求夹角。angle 的范围为 [0, 180]，direction 为 -1 或 1，
---且满足 r1 + angle * direction == r2。【客户端】
---@param r1 number 角度1
---@param r2 number 角度2
---@return number angle 夹角
---@return integer direction 方向（-1 或 1）
function base.math.included_angle(r1, r2) end

---正弦。【客户端】
---@param angle number 角度
---@return number sin 正弦值
function base.math.sin(angle) end

---正切。【客户端】
---@param angle number 角度
---@return number tan 正切值
function base.math.tan(angle) end

-- ============================================================================
-- 操作模型（game.*，全局 game 对象）
-- 文档待整理，描述的可能已非最佳实践。
-- ============================================================================

---创建模型。【客户端】
---@param name string 模型名称
---@return boolean result 创建结果
---@return number id 模型id
function game.create_unit(name) end

---设置模型当前位置。【客户端】
---@param id number 模型id
---@param x number 场景x坐标
---@param y number 场景y坐标
---@param z number 场景z坐标
function game.set_unit_location(id, x, y, z) end

---设置模型朝向。【客户端】
---@param id number 模型id
---@param angle number 角度
function game.set_unit_facing(id, angle) end

---设置模型缩放。【客户端】
---@param id number 模型id
---@param scale number 缩放大小
function game.set_unit_scale(id, scale) end

---设置模型播放的动画。【客户端】
---@param id number 模型id
---@param animName string 动画名称
function game.unit_play_animation(id, animName) end

-- ============================================================================
-- 其它API（common.*）
-- ============================================================================

---改变客户端每一个逻辑帧更新时间的长短，默认为 1.0，相当于游戏速度变快或
---变慢的倍数。每一个逻辑帧客户端更新 timeStep_ * speed，其中 timeStep_ 是
---客户端逻辑帧的间隔时间。由 c++ 实现的 api。【客户端】
---@param speed number 速度倍数
function common.set_game_speed(speed) end

---锁定场景画面，以提高性能。用于场景画面静止不动且开销较大时（如高斯模糊时），
---锁定时 UI 可以正常描画。【客户端】
function common.lock_scene_view() end

---解锁场景画面，和 lock_scene_view 配套使用。【客户端】
function common.unlock_scene_view() end

-- ============================================================================
-- 命令行参数（require 'base.argv'）
-- ============================================================================

---@class base.argv
local argv = {}

---是否指定了命令行参数。【客户端】
---@param name string 参数名
---@return boolean
function argv.has(name) end

---获取命令行参数值。【客户端】
---@param name string 参数名
---@return string 参数值
function argv.get(name) end
