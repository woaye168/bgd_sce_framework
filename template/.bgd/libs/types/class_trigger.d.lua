---@meta

--==============================================================
-- SCE 游戏引擎 EmmyLua 类型声明：事件 / 触发器 / 状态机
-- 覆盖范围：
--   1. Trigger 类（disable / enable / is_enable / remove / 调用执行）
--   2. 事件注册与发起 API（base.event_register / event_notify /
--      event_dispatch，及 base.game / Unit / Player / Skill / Buff 的封装）
--   3. StateMachine / StateMachineState 类（服务端 + 客户端状态机）
-- 来源文档：
--   服务端-触发器和事件-事件:
--     https://doc.sce.xd.com/技术文档/服务端Lua%20API/触发器和事件/事件
--   服务端-触发器和事件-触发器:
--     https://doc.sce.xd.com/技术文档/服务端Lua%20API/触发器和事件/触发器
--   服务端-状态机-API:
--     https://doc.sce.xd.com/技术文档/服务端Lua%20API/状态机/API
--   客户端-触发器和事件-事件:
--     https://doc.sce.xd.com/技术文档/客户端Lua%20API/触发器和事件/事件
--   客户端-触发器和事件-触发器:
--     https://doc.sce.xd.com/技术文档/客户端Lua%20API/触发器和事件/触发器
--   客户端-状态机-API:
--     https://doc.sce.xd.com/技术文档/客户端Lua%20API/状态机/API
--
-- 事件机制说明（双端一致）：
--   可以在任意对象上以某个事件名注册触发器；发起事件时可传入 N 个自定义参数。
--   同一对象同一事件名下可注册多个触发器，发起时按注册顺序反序执行。
--   执行过程中删除排队中的触发器则它不会执行；新建触发器本次也不执行。
--   event_notify 与 event_dispatch 的区别：event_dispatch 可以获取触发器返回值，
--   当触发器返回非 nil 值后事件被终止，返回值返回给调用方；
--   event_notify 的事件无法被终止，也不关心返回值。
--   封装规则：
--     - base.game 事件：全局事件。
--     - Player 事件：发起完毕后会用同样参数再发起一次全局事件。
--     - Unit 事件（服务端）：发起完毕后还会再发起一次玩家事件（玩家为单位控制者）
--       和一次全局事件。
--     - Skill / Buff 事件（客户端）：发起完毕后会用同样参数再发起一次全局事件。
--
-- 内置事件名清单（服务端）：
--   单位：单位-初始化 / 单位-创建 / 单位-即将死亡(返回false阻止) / 单位-死亡 /
--         单位-复活 / 单位-升级 / 单位-即将获得状态(返回false阻止) / 单位-获得状态 /
--         单位-购买物品 / 单位-出售物品 / 单位-撤销物品 / 单位-获得物品 /
--         单位-失去物品 / 单位-丢弃物品 / 单位-攻击开始 / 单位-攻击出手 /
--         单位-请求命令(返回false阻止) / 单位-发布命令 / 单位-执行命令 /
--         单位-移动(每帧触发，勿过多注册) / 单位-着陆 / 单位-撞头 /
--         单位-学习技能(返回非nil阻止脚本库默认行为) / 单位-学习技能完成 /
--         单位-即将获得经验 / 单位-获得经验
--   技能：技能-获得 / 技能-失去 / 技能-即将施法(返回false阻止，可再返回提示字符串) /
--         技能-即将打断(返回false不允许打断) / 技能-施法开始 / 技能-施法打断 /
--         技能-施法引导 / 技能-施法出手 / 技能-施法完成 / 技能-施法停止 /
--         技能-施法失败 / 技能-冷却完成
--   玩家：玩家-输入作弊码 / 玩家-输入聊天 / 玩家-选择英雄 / 玩家-连入 /
--         玩家-断线 / 玩家-重连(已过时，请用 玩家-连入) / 玩家-放弃重连 /
--         玩家-暂时离开 / 玩家-回到游戏 / 玩家-小地图信号
--
-- 内置事件名清单（客户端）：
--   单位：单位-进入视野 / 单位-离开视野 / 单位-选中 / 单位-取消选中 /
--         单位-属性变化 / 单位-施法开始 / 单位-施法引导 / 单位-施法出手 / 单位-施法停止
--   技能：技能-获得 / 技能-失去 / 技能-属性变化 / 技能-等级变化 / 技能-层数变化 /
--         技能-槽位变化 / 技能-可用状态变化 / 技能-学习状态变化 /
--         技能-冷却激活 / 技能-冷却完成 / 技能-充能激活 / 技能-充能完成
--   状态：状态-获得 / 状态-失去 / 状态-层数变化
--   玩家：玩家-改变英雄 / 玩家-改变队伍 / 玩家-属性变化
--   游戏：游戏-更新(每帧) / 游戏-属性变化 / 消息-技能 / 消息-错误 / 消息-公告 /
--         画面-分辨率变化 / 按键-按下 / 按键-松开 / 鼠标-按下 / 鼠标-松开 / 鼠标-移动
--==============================================================

--==============================================================
-- Trigger 类（双端）
--==============================================================

---触发器对象，包含一个回调函数，挂载在事件之下。【双端】
---@class Trigger
local Trigger = {}

---禁用触发器，禁用后的触发器不会执行。【双端】
function Trigger:disable() end

---启用触发器。【双端】
function Trigger:enable() end

---获取触发器是否启用。【双端】
---@return boolean result 是否启用
function Trigger:is_enable() end

---移除触发器。【双端】
function Trigger:remove() end

---执行触发器，返回回调函数的返回值。【双端】
---@vararg any 自定义参数
---@return any ... 回调函数的返回值
function Trigger:__call(...) end

--==============================================================
-- 事件注册与发起（双端）
--==============================================================

---注册事件。【双端】
---@param object table|userdata 对象
---@param name string 事件名
---@param callback fun(trigger:Trigger,...):any 回调函数；
---第一个参数为触发器对象，之后为自定义数据；
---回调返回值只有使用 event_dispatch 发起时才有意义
---@return Trigger trigger 触发器对象
function base.event_register(object, name, callback) end

---发起事件（关心返回值）。【双端】
---当接收事件的触发器返回非 nil 值后，事件被终止，返回值返回给调用方。
---@param obj table|userdata 对象
---@param name string 事件名
---@param ... any 自定义数据
---@return any ... 触发器的返回值
function base.event_dispatch(obj, name, ...) end

---发起事件（不关心返回值）。【双端】
---事件无法被终止，也不关心触发器返回值。
---@param obj table|userdata 对象
---@param name string 事件名
---@param ... any 自定义数据
function base.event_notify(obj, name, ...) end

--==============================================================
-- base.game 全局事件封装（双端）
--==============================================================

---注册全局事件。【双端】
---@param name string 事件名
---@param callback fun(trigger:Trigger,...):any 回调函数
---@return Trigger trigger 触发器对象
function base.game:event(name, callback) end

---发起全局事件（关心返回值）。【双端】
---@param name string 事件名
---@param ... any 自定义数据
---@return any ... 触发器的返回值
function base.game:event_dispatch(name, ...) end

---发起全局事件（不关心返回值）。【双端】
---@param name string 事件名
---@param ... any 自定义数据
function base.game:event_notify(name, ...) end

--==============================================================
-- Unit / Player / Skill / Buff 事件封装
--==============================================================

---@class Unit
local Unit = {}

---注册单位事件。【双端】
---单位事件发起完毕后还会用同样参数再发起玩家事件（服务端，玩家为单位控制者）和全局事件。
---@param name string 事件名
---@param callback fun(trigger:Trigger,...):any 回调函数
---@return Trigger trigger 触发器对象
function Unit:event(name, callback) end

---发起单位事件（关心返回值）。【双端】
---@param name string 事件名
---@param ... any 自定义数据
---@return any ... 触发器的返回值
function Unit:event_dispatch(name, ...) end

---发起单位事件（不关心返回值）。【双端】
---@param name string 事件名
---@param ... any 自定义数据
function Unit:event_notify(name, ...) end

---@class Player
local Player = {}

---注册玩家事件。【双端】
---玩家事件发起完毕后会用同样参数再发起一次全局事件。
---@param name string 事件名
---@param callback fun(trigger:Trigger,...):any 回调函数
---@return Trigger trigger 触发器对象
function Player:event(name, callback) end

---发起玩家事件（关心返回值）。【双端】
---@param name string 事件名
---@param ... any 自定义数据
---@return any ... 触发器的返回值
function Player:event_dispatch(name, ...) end

---发起玩家事件（不关心返回值）。【双端】
---@param name string 事件名
---@param ... any 自定义数据
function Player:event_notify(name, ...) end

---@class Skill
local Skill = {}

---注册技能事件。【客户端】
---技能事件发起完毕后会用同样参数再发起一次全局事件。
---@param name string 事件名
---@param callback fun(trigger:Trigger,...):any 回调函数
---@return Trigger trigger 触发器对象
function Skill:event(name, callback) end

---发起技能事件（关心返回值）。【客户端】
---@param name string 事件名
---@param ... any 自定义数据
---@return any ... 触发器的返回值
function Skill:event_dispatch(name, ...) end

---发起技能事件（不关心返回值）。【客户端】
---@param name string 事件名
---@param ... any 自定义数据
function Skill:event_notify(name, ...) end

---@class Buff
local Buff = {}

---注册状态事件。【客户端】
---状态事件发起完毕后会用同样参数再发起一次全局事件。
---@param name string 事件名
---@param callback fun(trigger:Trigger,...):any 回调函数
---@return Trigger trigger 触发器对象
function Buff:event(name, callback) end

---发起状态事件（关心返回值）。【客户端】
---@param name string 事件名
---@param ... any 自定义数据
---@return any ... 触发器的返回值
function Buff:event_dispatch(name, ...) end

---发起状态事件（不关心返回值）。【客户端】
---@param name string 事件名
---@param ... any 自定义数据
function Buff:event_notify(name, ...) end

--==============================================================
-- 状态机（StateMachine）
-- 服务端：自定义状态机附属于单位，可同时生效 tick；
--   创建时可同步给客户端（客户端创建同样结构的状态机播动画）。
-- 客户端：状态机有 layer 和 priority 属性（服务端没有）；
--   只有优先级最高的状态机控制单位播动画。
--   layer：0=全身，1=上半身，2=下半身；
--   priority：移动状态机=0，技能状态机=1，自定义状态机一般 >= 2。
-- 注意：创建状态机时默认创建 id 为 -1、name 为 'exit' 的状态，
--   且状态机的当前状态为 'exit'。
-- 状态切换回调顺序：旧状态 on_exit -> 新状态 on_enter -> 每帧 on_update(delta)。
--==============================================================

---状态机对象
---@class StateMachine
local StateMachine = {}

---状态机添加状态，如果 id 已存在则返回已有状态。【双端】
---@param name string 状态名（只起描述性作用）
---@param id integer 状态id
---@return StateMachineState state 状态的 lua 对象
function StateMachine:add_state(name, id) end

---根据 id 获取状态机的状态。【双端】
---@param id integer 状态id
---@return StateMachineState state 状态的 lua 对象
function StateMachine:get_state(id) end

---根据 id 设置状态机的当前状态。【双端】
---注意 id 对应的状态必须先添加到状态机，否则不生效。
---@param id integer 状态id
function StateMachine:set_current_state(id) end

---状态机根据 event id 切换状态。【双端】
---注意 id 对应的事件必须先添加到状态转移表里，否则不生效。
---如果是同步给客户端的状态机，服务端切状态后客户端对应状态机也会切状态。
---@param id integer 事件id（>=0 且 <=255）
function StateMachine:transit(id) end

---设置同步到客户端的状态机的 priority。仅对同步状态机有效。【服务端】
---客户端移动状态机优先级是 0，技能状态机是 1，自定义状态机一般应 >= 2。
---@param priority integer 优先级（大于等于 0）
function StateMachine:set_priority(priority) end

---设置同步到客户端的状态机的 layer。仅对同步状态机有效。【服务端】
---@param layer integer 仅能取 0/1/2：0=影响全身，1=影响上半身，2=影响下半身
function StateMachine:set_layer(layer) end

---获取状态机优先级。【客户端】
---@return integer priority 优先级
function StateMachine:get_priority() end

---状态机设置播放的动画，如果状态机优先级在排序中胜出，模型就会播放。【客户端】
function StateMachine:set_animation_state() end

---状态对象
---@class StateMachineState
local StateMachineState = {}

---状态添加转移表，即什么事件可以使状态机从当前状态切换到下一个状态。【双端】
---@param id integer 事件id（uint8，可用 enum 封装以明确含义）
---@param next StateMachineState 下一个状态的 lua 对象
function StateMachineState:add_transition(id, next) end

---获取状态名。【客户端】
---@return string name 状态名
function StateMachineState:get_name() end

---获取状态id。【客户端】
---@return integer id 状态id
function StateMachineState:get_id() end

---进入状态的时候调用（回调，由引擎触发）。【双端】
function StateMachineState:on_enter() end

---状态 tick 的时候调用（回调，由引擎触发）。【双端】
---@param delta number 更新的 delta 时间（秒）
function StateMachineState:on_update(delta) end

---离开状态的时候调用（回调，由引擎触发）。【双端】
function StateMachineState:on_exit() end

---创建自定义服务端状态机，如果已经存在就返回存在的状态机。【服务端】
---@param name string 状态机名字，同一单位上不能重复；不要使用形如 "skill" 的名字（被默认状态机占用）
---@param sync? boolean 是否将状态机同步给客户端，默认 false；同步后客户端单位上会创建同样结构的状态机来播动画
---@return StateMachine sm 状态机 lua 对象
---@return boolean new 是否是新创建的
function Unit:get_or_create_state_machine(name, sync) end

---创建自定义客户端状态机，如果已经存在就返回存在的状态机。【客户端】
---@param name string 状态机名字，同一单位上不能重复；不要使用形如 "skill" 的名字（被默认状态机占用）
---@param priority integer 优先级（自定义状态机一般设为 2 或以上）
---@param layer integer 影响层级，仅取值 0（全身）/1（上半身）/2（下半身）
---@return StateMachine sm 状态机 lua 对象
---@return boolean new 是否是新创建的
function Unit:get_or_create_state_machine(name, priority, layer) end

---单位同步状态机到客户端。一般是服务器状态机建好之后再同步，减少通信成本。【服务端】
---状态机名字是唯一 id。客户端会先清理服务端没有的同步状态机（不清理客户端独有的），
---再添加服务端同步过来的新状态机；客户端已有同名的则不处理。
function Unit:sync_state_machines() end
