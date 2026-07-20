---@meta

-- ============================================================================
-- SCE 官方文档：服务端 Lua API —— "其它" 分类 + 测试用 API
-- ----------------------------------------------------------------------------
-- 覆盖以下官方文档页面中声明的全部 API（均为服务端）：
--   性能统计
--     https://doc.sce.xd.com/技术文档/服务端Lua API/其它/性能统计
--   服务端发送自定义消息给客户端（base.game:ui / player:ui）
--     https://doc.sce.xd.com/技术文档/服务端Lua API/其它/服务端发送自定义消息给客户端
--   数学库（base.math.*）
--     https://doc.sce.xd.com/技术文档/服务端Lua API/其它/数学库
--   杂项工具函数（base.hash / base.sight_line / base.sight_range / base.split）
--     https://doc.sce.xd.com/技术文档/服务端Lua API/其它/杂项工具函数
--   可见形状（sight_handle:remove）
--     https://doc.sce.xd.com/技术文档/服务端Lua API/其它/可见形状
--   杂项辅助API（base.auxiliary.*）
--     https://doc.sce.xd.com/技术文档/服务端Lua API/其它/杂项辅助API
--   服务端修改客户端界面（base.ui.bind）
--     https://doc.sce.xd.com/技术文档/服务端Lua API/其它/服务端修改客户端界面
--   中途局（base.lobby.*）
--     https://doc.sce.xd.com/技术文档/服务端Lua API/其它/中途局
--   测试 - 其它测试用API（base.test.*）
--     https://doc.sce.xd.com/技术文档/服务端Lua API/测试/其它测试用API
--
-- 以下主题因 API 较多，已拆分为独立的类声明文件：
--   弹道捕获器 Capturer -> class_capturer.d.lua
--   支付       Pay      -> class_pay.d.lua
--   AI / 简易AI          -> class_ai.d.lua
-- ============================================================================

-- ============================================================================
-- 性能统计（结果会打印到服务器局日志的 perf.log.txt）
-- ============================================================================

---登记一个性能统计项，并可选地标记父子关系。建议在代码的最早期执行
---（增加性能统计项之前进行的性能统计会被忽略）。【服务端】
---@param label string 标签名字
---@param father_label? string 可选。表示现在登记的叫 label 的这项在调用关系上是 father_label 这项的儿子。这个父子关系只影响打印到 perf.log.txt 里的东西，不影响别的。father_label 必须被先行登记过
---@return boolean ret 是否增加成功。可能的失败原因：标签被重复登记、父标签尚未登记
function base.perf_add(label, father_label) end

---统计一段代码的性能（平均耗时，最大耗时，总耗时），精度默认是毫秒级（不同机器会有区别）。
---注意过量的统计性能是有额外代价的。【服务端】
---@param label string 标签名字。这个标签必须提前用 base.perf_add 登记过，否则本次调用会被忽略
---@param func fun() 将要统计的代码放这个函数里。函数内的代码会被立即执行
function base.perf(label, func) end

-- ============================================================================
-- 服务端发送自定义消息给客户端
-- （文档待整理，可能已不是最佳实践：尽量使用单位属性、技能属性、玩家属性、
--   游戏局属性从服务端同步数据到客户端。一般只在单独给特定用户发一些一次性
--   消息时，才用自定义消息）
-- ============================================================================

---广播自定义消息给所有客户端。【服务端】
---
---注意：当客户端断线重连时，普通自定义消息客户端是不知道的（各类属性没有这个问题）。
---传入可选参数 true 后该消息为「必定送达」：客户端断线重连后会依次收到所有「必定送达」的消息。
---不要给所有消息都加上 true，只给必要的消息加上即可。
---
---自定义消息的长度/表大小有限制，长度或者序列化后的表长度超过 1300 * 256 时将返回 false。
---@param type string 消息类型
---@param ensure? boolean 可选，传 true 表示消息「必定送达」
---@return fun(data:any):boolean sender 调用返回值发送消息，返回 false 表示消息太长无法发送
function base.game:ui(type, ensure) end

---给特定客户端发送自定义消息。注意事项同 base.game:ui（断线重连、必定送达、长度限制）。【服务端】
---@param type string 消息类型
---@param ensure? boolean 可选，传 true 表示消息「必定送达」
---@return fun(data:any):boolean sender 调用返回值发送消息，返回 false 表示消息太长无法发送
function Player:ui(type, ensure) end

-- ============================================================================
-- 数学库（base.math.*，三角函数为角度制）
-- ============================================================================

---反余弦。【服务端】
---@param cos number 余弦值
---@return number angle 角度
function base.math.acos(cos) end

---反正弦。【服务端】
---@param sin number 正弦值
---@return number angle 角度
function base.math.asin(sin) end

---反正切。返回 y/x 的反正切值（用角度表示）。
---它会使用两个参数的符号来找到结果落在哪个象限中（即使 x 为零时，也可以正确的处理）。
---默认的 x 是 1，因此调用 base.math.atan(y) 将返回 y 的反正切值。【服务端】
---@param y number 对边
---@param x? number 临边，默认为 1
---@return number angle 角度
function base.math.atan(y, x) end

---余弦。【服务端】
---@param angle number 角度
---@return number cos 余弦值
function base.math.cos(angle) end

---求夹角。angle 的范围为 [0, 180]，direction 为 -1 或 1，
---且满足 r1 + angle * direction == r2。【服务端】
---@param r1 number 角度1
---@param r2 number 角度2
---@return number angle 夹角
---@return integer direction 方向（-1 或 1）
function base.math.included_angle(r1, r2) end

---正弦。【服务端】
---@param angle number 角度
---@return number sin 正弦值
function base.math.sin(angle) end

---正切。【服务端】
---@param angle number 角度
---@return number tan 正切值
function base.math.tan(angle) end

-- ============================================================================
-- 杂项工具函数
-- ============================================================================

---哈希。【服务端】
---@param text string 文本
---@return integer hash 哈希值
function base.hash(text) end

---直线可见形状。返回的点的列表可用于单位的 add_sight。【服务端】
---@param start Point 起点
---@param angle number 方向
---@param len number 长度
---@return table sight 点的列表
function base.sight_line(start, angle, len) end

---圆形可见形状。返回的点的列表可用于单位的 add_sight。【服务端】
---@param poi Point 圆心
---@param radius number 半径
---@return table sight 点的列表
function base.sight_range(poi, radius) end

---分割字符串。分隔符只能是1个字符。【服务端】
---@param text string 要分割的字符串
---@param sep string 分隔符（只能是1个字符）
---@return table result 字符列表
function base.split(text, sep) end

-- ============================================================================
-- 可见形状
-- （一般来说对象被看见的判定范围是对象所在位置。通过可见形状可以给对象附着
--   多个点，只要任意一个点可见，对象就会可见。可见形状是一张存放了数个点的
--   表，这些点会跟着对象移动）
-- ============================================================================

---可见形状句柄（由单位的 add_sight 返回）。【服务端】
---@class SightHandle
local SightHandle = {}

---移除可见形状，目前只有 add_sight 会用到。【服务端】
function SightHandle:remove() end

-- ============================================================================
-- 杂项辅助API
-- （一些不知如何归类的 api，其中不少是因为历史原因才放这儿的）
-- ============================================================================

---获取真实的用户 id。【服务端】
---@param player Player player对象
---@return integer player_id 用户真实id。注意这个id可能会是64位（虽然现在还比较短），而64位整数不能直接传给客户端，会被截断
function base.auxiliary.get_player_id(player) end

---指定播上半身或下半身的动画。【服务端】
---@param unit Unit 要放动画的单位
---@param animation_name string 动画名
---@param scale number 暂时没用的参数
---@param is_loop boolean 是否循环
---@param part? integer 0或不填表示全身动画，1表示上半身，2表示下半身
---@return integer player_id 用户真实id。注意这个id之后会是64位，而64位整数不能直接传给客户端，会被截断
function base.auxiliary.add_animation(unit, animation_name, scale, is_loop, part) end

-- ============================================================================
-- 服务端修改客户端界面
-- （文档待整理，可能已不是最佳实践。数据绑定是单向的，总是从服务器到客户端；
--   每次修改数据或注册事件都会产生网络流量，请谨慎使用）
-- ============================================================================

---界面绑定对象。服务器使用的 bind 是只写的，无法从里面读取出正确的数据。
---修改 bind 上的字段即可修改客户端界面对应属性；给 bind 上的事件字段赋值
---函数即可注册控件事件（如 bind.on_click = function() end）。
---注意：array 被绑定的话，必须给 array 指定个初始值，且 array 必须先改大，
---才能改里面的具体元素。【服务端】
---@class Bind
local Bind = {}

---创建绑定。绑定名指的是界面创建控件时指定的名字。【服务端】
---@param player Player 玩家
---@param name string 绑定名
---@return Bind bind 绑定
function base.ui.bind(player, name) end

-- ============================================================================
-- 中途局
-- ============================================================================

---通知 lobby 用户离开中途局，并调整此中途局的优先级。
---lobby 那边会往优先级高的中途局塞人。【服务端】
---@param user_id integer 用户id
---@param priority integer 优先级
function base.lobby.notify_user_leave_middle_game(user_id, priority) end

---获取可用的槽位。需要实现，提供给 host C++ 调用：当用户加入中途局时，
---调用此方法获取槽位，并将玩家放入这个槽位中。【服务端】
---@param user_id integer 用户id
---@return integer slot_id 槽位id
function base.lobby.get_empty_slot_id(user_id) end

-- ============================================================================
-- 测试 - 其它测试用API
-- !> 不能在正式环境中使用。
-- 通过判断 base.test 是否存在来区分当前是测试环境还是正式环境。
-- ============================================================================

---获取命令行。不能在正式环境中使用。【服务端】
---@return table data 命令行
function base.test.command() end

---显示消息。令客户端显示文本消息。不能在正式环境中使用。【服务端】
---@param text string 消息内容
function base.test.message(text) end

---时间停止。好比传入的 player 按了暂停。不能在正式环境中使用。【服务端】
---@param player Player 玩家
function base.test.pause(player) end

---时间恢复。不能在正式环境中使用。【服务端】
---@param player Player 玩家
function base.test.resume(player) end

---时间跳跃。不能在正式环境中使用。【服务端】
function base.test.update() end

---时间变速。只有服务器会变速。不能在正式环境中使用。【服务端】
---@param factor number 时间倍率
function base.test.speed(factor) end

---获取 lua 对象地址。不能在正式环境中使用。【服务端】
---@param obj any 对象
---@return any pointer 对象地址
function base.test.topointer(obj) end

---获取所有单位。不能在正式环境中使用。【服务端】
---@return table unittable 单位表（一张弱表）
function base.test.unit() end

---单位是否被引擎引用。如果引擎不引用这个单位，意味着这是一个已被删除的单位，
---而脚本还在引用这个单位。不能在正式环境中使用。【服务端】
---@param unit Unit 单位
---@return boolean ref 是否引用
function base.test.unit_coreref(unit) end

---获取 Lua 的内存快照。不能在正式环境中使用。【服务端】
---@return table dump 内存快照
function base.test.snapshot() end
