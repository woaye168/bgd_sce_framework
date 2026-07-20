---@meta

----------------------------------------------------------------------------------------------------
-- SCE 引擎 Buff（状态）EmmyLua 类型声明
-- 覆盖范围：服务端 Buff API（创建设置/属性/方法/事件）、客户端 Buff API
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/Buff/API
--   https://doc.sce.xd.com/技术文档/客户端Lua API/Buff/API
-- 注意：文档提示预期 Buff 大部分都应在数据编辑器中制作，文档所述方式很可能已非最佳实践。
--      文档中“Buff”与“状态”指的是同一个东西。
----------------------------------------------------------------------------------------------------

---状态数据表注册表。【服务端】
---如果 ClientBuff 中有同名的状态定义，则会包含定义的属性。
---使用 `unit:add_buff('状态名', { skill = skill })` 给单位添加状态。
---@type table<string, Buff>
base.buff = base.buff or {}

----------------------------------------------------------------------------------------------------
-- Buff 状态对象
----------------------------------------------------------------------------------------------------

---状态（Buff）对象。
---在逻辑上，状态可以用来管理单位的属性与限制变化；在表现上，状态可以用来给单位绑定特效、音效甚至改变单位的模型属性。
---@class Buff
---@field cover_global integer 全局覆盖类型。【服务端】只能在创建时设置。决定如何视为同名状态：0=必须名字和来源都相同才视为同名状态（默认值）；1=只要名字相同就会视为同名状态。
---@field cover_max integer 最大生效数量。【服务端】只能在创建时设置。当单位身上有多个同名状态时，最多可以同时生效的状态数量。默认为0表示无限制。只有当 cover_type 为共存模式时才有意义。
---@field cover_type integer 共存模式。【服务端】只能在创建时设置。决定单位获得多个同名状态时的行为：0=独占模式（单位只能同时保留一个同名状态，on_cover 决定哪个保留）；1=共存模式（可同时保留多个同名状态，on_cover 决定排序）。
---@field keep boolean 死亡后保留。【服务端】只能在创建时设置。true=单位死亡时保留状态，状态也可以添加给死亡的单位；false=单位死亡时移除状态，状态无法添加给死亡的单位（默认值）。
---@field sync string 同步方式。【服务端】只能在创建时设置。决定状态可以被哪些人看见，默认值为 none。同步方式的参照单位为状态的 source，而不是 target。
---@field pulse number 心跳。【服务端】触发 on_pulse 事件的频率（秒），精度受逻辑帧影响，默认值为1帧。可在创建或 unit:add_buff 时设置。
---@field skill Skill 技能（关联技能）。【服务端】在 unit:add_buff 时设置。
---@field source Unit 来源。【服务端】在 unit:add_buff 时设置，影响 sync 属性的参照物。如果不设置，则为 unit:add_buff 时的对象。
---@field target Unit 目标。【服务端】该属性不需要设置，为 unit:add_buff 时的对象。
---@field time number 持续时间（秒）。【服务端】状态会在经过此时间后自动移除，默认为一个非常巨大的值表示持续无限时间。可在创建或 unit:add_buff 时设置。
---@field stack integer 层数。【服务端】可在创建或 unit:add_buff 时设置。
local Buff = {}

----------------------------------------------------------------------------------------------------
-- 服务端：方法
----------------------------------------------------------------------------------------------------

---增加层数。【服务端】
---如果状态的属性允许，层数会显示在状态图标上。
---@param count integer 状态的层数
function Buff:add_stack(count) end

---获取心跳。【服务端】
---@return number pulse 触发 on_pulse 事件的周期
function Buff:get_pulse() end

---获取剩余时间。【服务端】
---@return number time 状态的剩余持续时间（秒）
function Buff:get_remaining() end

---获取层数。【服务端】
---@return integer count 状态的层数
function Buff:get_stack() end

---移除状态。【服务端】
function Buff:remove() end

---设置周期。【服务端】
---@param pulse number 触发 on_pulse 事件的周期
function Buff:set_pulse(pulse) end

---设置剩余时间。【服务端】
---@param time number 状态的剩余持续时间（秒）
function Buff:set_remaining(time) end

---设置层数。【服务端】
---@param count integer 状态的层数
function Buff:set_stack(count) end

---设置时间。【服务端】
---也会重置剩余时间，如果是持续buff，则取消持续。
---@param time number 状态总时长（秒）
function Buff:set_time(time) end

---获取总时长。【服务端】
---@return number time 状态总时长（秒）
function Buff:get_time() end

----------------------------------------------------------------------------------------------------
-- 服务端：事件（需要在创建状态时注册，事件中的 self 表示状态对象）
----------------------------------------------------------------------------------------------------

---获得事件。【服务端】
---每当单位获得该状态时触发此事件。
function Buff:on_add() end

---叠加事件。【服务端】
---每当有新的同名状态添加到单位身上时触发此事件。若状态没有注册此事件，则发生叠加时按照返回 true 的情况处理。
---根据 cover_type 有不同的处理：
---独占模式：true=当前状态被移除，新的状态被添加；false=阻止新的状态添加。
---共存模式：true=新的状态排序到当前状态之前；false=新的状态排序到当前状态之后。
---@param new Buff 新的状态
---@return boolean cover 叠加方式
function Buff:on_cover(new) end

---完成事件。【服务端】
---每当状态因持续时间耗尽而被移除时触发此事件，会比 on_remove 事件先触发。
function Buff:on_finish() end

---心跳事件。【服务端】
---根据 pulse 的设置，周期性触发的事件。
function Buff:on_pulse() end

---失去事件。【服务端】
---每当状态被移除时触发此事件。若状态的 cover_type 为共存模式，且该状态被移除后有一个同名状态即将生效，
---那么那个状态就会被作为参数传入。可以利用这个特性为即将生效的状态进行初始化或数据继承等操作。
---@param new Buff? 新的状态
function Buff:on_remove(new) end

----------------------------------------------------------------------------------------------------
-- 客户端：方法
----------------------------------------------------------------------------------------------------

---获取名字。【客户端】
---@return string name 状态名
function Buff:get_name() end

---获取拥有者。【客户端】
---@return Unit owner 状态拥有者
function Buff:get_owner() end

---注册事件。【客户端】
---这是对 base.event_register 方法的封装。
---@param name string 事件名
---@param callback fun(trigger: Trigger, ...) 事件函数，事件参数为触发器与自定义数据
---@return Trigger trigger 触发器
function Buff:event(name, callback) end

---触发事件。【客户端】
---这是对 base.event_notify 方法的封装。
---@param name string 事件名
---@param ... any 自定义数据
function Buff:event_notify(name, ...) end
