---@meta

-- ============================================================================
-- SCE 内置控件 - 过渡（transition / 动画）类型声明（客户端）
-- ----------------------------------------------------------------------------
-- 覆盖范围：控件的 transition 过渡动画（属性过渡、曲线函数、自定义运动轨迹、
--   自定义数值过渡）。控件本体声明见 class_ui.d.lua。
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/客户端Lua API/内置控件/过渡
-- ============================================================================

---过渡曲线函数。【客户端】
---内置曲线：'linear' / 'ease' / 'ease_in' / 'ease_out' / 'ease_in_out'；
---'curve' 用于 position 过渡的自定义运动轨迹（需配合 anchors）；
---也可用 4 个数字的数组自定义三次贝塞尔曲线（如 {0.04, 1.14, 0.98, -0.04}，
---效果可参考 https://cubic-bezier.com/ ）。
---@alias UITransitionFunc
---| 'linear'
---| 'ease'
---| 'ease_in'
---| 'ease_out'
---| 'ease_in_out'
---| 'curve'
---| number[]

---单条属性过渡配置。【客户端】
---@class UITransitionItem
---@field time integer 过渡时间（毫秒）。属性变化时从初始状态过渡到新状态花费的时间
---@field func UITransitionFunc 过渡曲线（内置曲线名字符串、'curve' 或自定义贝塞尔数组）
---@field anchors? number[][] 曲线路径锚点（仅当 position 过渡且 func = 'curve' 时使用）。数组内存放每个锚点的 xy 绝对坐标，锚点可有多个，控件根据锚点计算运动曲线。详细例子见 Script/test/transition_curve.lua
local UITransitionItem = {}

---控件过渡动画表（填写在控件定义的 transition 属性内，可经 bind 绑定）。【客户端】
---当控件的部分属性被修改后，控件会平滑过渡到新的状态，可用来实现动画效果。
---@class UITransition
---@field size? UITransitionItem 控件大小改变时生效（包括宽度改变和高度改变）
---@field position? UITransitionItem 控件坐标改变时生效
---@field show? UITransitionItem 控件隐藏或显示时生效
---@field opacity? UITransitionItem 控件透明度改变时生效
---@field progress? UITransitionItem 进度条进度改变时生效（仅对进度条控件有效）
---@field scale? UITransitionItem 控件缩放改变时生效（包括横向缩放和纵向缩放）
---@field rotate? UITransitionItem 控件旋转改变时生效
---@field custom? UITransitionItem 自定义数值过渡（需在控件定义时通过 bind 指定 transition.custom，详细见 UICustomTransition）
local UITransition = {}

---自定义数值过渡（赋值给绑定到 transition.custom 的绑定名）。【客户端】
---没有初始化值，控件定义时需通过 bind 指定：
---  base.ui.label { bind = { text = 'text', transition = { custom = 'custom' } } }
---然后 bind.custom = { time = ..., func = ..., from = ..., to = ..., callback = ... }
---可实现不断变化的文本等自定义动画效果。
---@class UICustomTransition
---@field time integer 过渡时间（毫秒）
---@field func UITransitionFunc 过渡函数曲线
---@field from number 指定数值变化的起始值（浮点数）
---@field to number 指定数值变化的目标值（浮点数）
---@field callback fun(value: number) 每次值变化时调用的回调，value 为当前插值
local UICustomTransition = {}
