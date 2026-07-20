---@meta

----------------------------------------------------------------------------------------------------
-- SCE 引擎技能（Skill）与伤害对象 EmmyLua 类型声明
-- 覆盖范围：服务端技能 API（属性/方法/事件）、服务端伤害对象（DamageInstance）、客户端技能 API
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/技能/API
--   https://doc.sce.xd.com/技术文档/服务端Lua API/技能/伤害对象
--   https://doc.sce.xd.com/技术文档/客户端Lua API/技能/API
----------------------------------------------------------------------------------------------------

---技能数据表注册表。【服务端】
---需要在技能表中定义过名称为 name 的技能，才能在脚本中创建。
---使用 `unit:add_skill('技能名', '英雄')` 给单位添加技能。
---@type table<string, Skill>
base.skill = base.skill or {}

----------------------------------------------------------------------------------------------------
-- Skill 技能对象
----------------------------------------------------------------------------------------------------

---技能对象（也用于表示施法，施法源自技能）。
---@class Skill
---@field owner Unit 拥有技能的单位。【服务端】不能自定义，为 add_skill 时的对象。
---@field name string 技能名。【服务端】get_name 方法会优先获取这个值，可利用它制作一个技能的多个版本。
local Skill = {}

----------------------------------------------------------------------------------------------------
-- 服务端：方法
----------------------------------------------------------------------------------------------------

---激活冷却。【服务端】
---用法1：skill:active_cd() 激活冷却（如同使用了技能）
---用法2：skill:active_cd(30) 按照指定冷却上限来激活冷却
---用法3：skill:active_cd(30, true) 并决定是否受冷却缩减的影响
---@param max_cd number? 冷却上限（秒）
---@param ignore_cooldown_reduce boolean? 是否无视冷却缩减
function Skill:active_cd(max_cd, ignore_cooldown_reduce) end

---增加剩余冷却。【服务端】
---只对已经在冷却状态的技能有效，单位为秒。用于充能型技能时，可以正确的改变层数。
---@param cd number 冷却（秒）
function Skill:add_cd(cd) end

---增加等级。【服务端】
---技能等级不能降低，且不能在技能的施法事件中改变技能等级。
---@param lv integer 等级
function Skill:add_level(lv) end

---增加层数。【服务端】
---@param stack integer 层数
function Skill:add_stack(stack) end

---引导完成。【服务端】
---立即完成技能的引导，使技能进入施法出手阶段。只能在施法引导阶段中使用。
function Skill:channel_finish() end

---获取当前技能阶段。【服务端】
---@return integer stage 当前技能阶段，-1 表示 skill 为空，0 到 4 分别表示空闲阶段、CastStart、CastChannel、CastShot、CastFinish
function Skill:get_stage() end

---当前技能阶段完成。【服务端】
---立即完成技能当前阶段，使技能进入下一阶段。
function Skill:stage_finish() end

---服务器技能阶段暂停。【服务端】
---只对当前阶段是 channel 和 shot 有效。效果为服务器阶段暂停不再更新，客户端循环播放当前阶段动画。
function Skill:stage_pause() end

---服务器技能阶段恢复。【服务端】
---只对当前阶段是 channel 和 shot 而且暂停了有效。效果为服务器阶段恢复更新。
function Skill:stage_resume() end

---是否处于暂停。【服务端】
---只对当前阶段是 channel 和 shot 有效。
---@return boolean flag 是否处于暂停
function Skill:is_stage_paused() end

---获得当前阶段剩余时间。【服务端】
---@return integer time 剩余时间（毫秒）
function Skill:get_stage_remaining_time() end

---设置当前阶段剩余时间。【服务端】
---仅仅用于 channel 和 shot 阶段，且需要是暂停后，修改剩余时间。修改后只会生效一次，即再次使用技能不会生效。
---@param time integer 剩余时间（毫秒）
function Skill:set_stage_remaining_time(time) end

---造成伤害。【服务端】
---伤害属性等说明见伤害对象文档（DamageInstance）。
---@param data DamageInstance 伤害属性表
---@return boolean success 是否成功
function Skill:add_damage(data) end

---禁用。【服务端】
---触发 on_disable 事件，技能禁用后将不再触发任何事件。
function Skill:disable() end

---启用。【服务端】
---触发 on_enable 事件。
function Skill:enable() end

---获取数据。【服务端】
---对于技能来说，这个操作等价于 skill[key]。对于施法来说，则是从它的源技能上读取数据。
---@param key any 索引（非 nil）
---@return any value 值
function Skill:get(key) end

---获取冷却。【服务端】
---@return number cd 冷却（秒）
function Skill:get_cd() end

---获取等级。【服务端】
---@return integer level 技能等级
function Skill:get_level() end

---获取技能名。【服务端】
---如果技能有 name 属性，则返回 name，否则返回技能名。
---@return string name 技能名
function Skill:get_name() end

---获取格子ID。【服务端】
---@return integer id 格子ID
function Skill:get_slot_id() end

---获取层数。【服务端】
---@return integer stack 层数
function Skill:get_stack() end

---获取目标。【服务端】
---仅用于施法，返回值类型由技能的目标类型属性决定。
---@return Unit|Point target 技能目标
function Skill:get_target() end

---获取类型。【服务端】
---@return string type 技能类型
function Skill:get_type() end

---是否是相同技能。【服务端】
---对于施法来说会使用源技能进行比较，因此可以用来判断2次施法是不是来自同一个技能。
---@param dest Skill 另一个技能
---@return boolean result 结果
function Skill:is(dest) end

---是否是施法。【服务端】
---@return boolean result 结果
function Skill:is_cast() end

---是否是攻击技能。【服务端】
---区别于 attack:is_common_attack。
---@return boolean result 是否是攻击技能
function Skill:is_common_attack() end

---是否启用。【服务端】
---@return boolean result 是否启用
function Skill:is_enable() end

---是否是技能。【服务端】
---总是返回 true。区别于 attack:is_skill。
---@return boolean result 结果
function Skill:is_skill() end

---创建直线运动。【服务端】
---@param data table 运动属性
---@return Mover mover 运动
function Skill:mover_line(data) end

---创建追踪运动。【服务端】
---@param data table 运动属性
---@return Mover mover 运动
function Skill:mover_target(data) end

---伤害通知。【服务端】
---一般用于伤害流程，会产生以下效果：
---根据伤害来源、伤害目标、伤害角度与技能播放特效；
---根据伤害来源、伤害目标、伤害角度与技能播放音效；
---令伤害来源显形一段时间；
---令伤害来源与伤害目标的动画树切换为战斗状态。
---@param damage DamageInstance 伤害
function Skill:notify_damage(damage) end

---重载。【服务端】
---让技能重新加载脚本。不会触发任何事件。
function Skill:reload() end

---移除。【服务端】
function Skill:remove() end

---设置数据。【服务端】
---对于技能来说，这个操作等价于 skill[key] = value。对于施法来说，则是在它的源技能上设置数据。
---@param key any 索引（非 nil）
---@param value any 值
function Skill:set(key, value) end

---设置动画。【服务端】
---设置本次施法使用的动画。
---@param name string 动画名称
function Skill:set_animation(name) end

---设置剩余冷却。【服务端】
---只对已经在冷却状态的技能有效，最小值是0，最大值是当前冷却上限。
---@param cd number 冷却（秒）
function Skill:set_cd(cd) end

---设置等级。【服务端】
---技能等级不能降低，且不能在技能的施法事件中改变技能等级。
---@param lv integer 等级
function Skill:set_level(lv) end

---设置属性。【服务端】
---修改技能的属性，并通知给客户端。
---@param key string 属性名
---@param value number 属性值
function Skill:set_option(key, value) end

---设置是否可以升级。【服务端】
---注意：文档中的方法名即为 set_upgrdable（原文如此，疑为 set_upgradable 的拼写）。
---@param upgradable boolean 是否可以升级
function Skill:set_upgrdable(upgradable) end

---发动效果。【服务端】
---根据技能创建施法并执行回调函数，传入回调函数的技能是一个施法。
---@param effect fun(self: Skill) 回调函数，参数 self 为施法
function Skill:simple_cast(effect) end

---停止施法。【服务端】
---若在施法开始阶段，则进入施法打断阶段；否则进入施法停止阶段。
function Skill:stop() end

----------------------------------------------------------------------------------------------------
-- 服务端：事件（在技能数据表上注册，事件中的 self 表示技能/施法对象）
----------------------------------------------------------------------------------------------------

---获得事件。【服务端】
---每当单位从“没有该技能”变为“拥有该技能”时触发。“没有该技能”有2种情况：
---1. 单位身上没有这个技能；2. 单位身上有这个技能，但等级为0。
function Skill:on_add() end

---失去事件。【服务端】
---每当单位失去此技能时触发。
function Skill:on_remove() end

---升级事件。【服务端】
---每当此技能提升等级时触发。
function Skill:on_upgrade() end

---冷却完成事件。【服务端】
---每当技能冷却完成时触发此事件。对于充能技能来说，每次充能完成一层也会触发此事件。
function Skill:on_cooldown() end

---启用事件。【服务端】
---每当使用 enable，让技能从禁用状态变为启用状态时触发。
function Skill:on_enable() end

---禁用事件。【服务端】
---每当使用 disable，让技能从启用状态变为禁用状态时触发。
function Skill:on_disable() end

---即将施法事件。【服务端】
---每当技能即将发动时触发，此时的技能是施法。在事件中返回 false 来阻止技能的发动。
---在阻止技能发动后，会在客户端上显示 error 文本。
---@return boolean enable 是否允许发动技能
---@return string error 错误消息
function Skill:on_can_cast() end

---即将打断事件。【服务端】
---每当在此技能的施法过程中，想要发动另一个技能时触发。此时的技能和想要发动的另一个技能均为施法。
---在事件中返回 true 来打断当前施法。瞬发技能不会触发此事件（因为本来不会打断技能）。
---@param dest Skill 想要发动的技能
---@return boolean break_cast 是否打断施法
function Skill:on_can_break(dest) end

---施法开始事件。【服务端】
---每当技能进入施法开始阶段时触发。此时的技能为施法。
function Skill:on_cast_start() end

---施法打断事件。【服务端】
---每当技能进入施法打断阶段时触发。此时的技能为施法。
function Skill:on_cast_break() end

---施法引导事件。【服务端】
---每当技能进入施法引导阶段时触发。此时的技能为施法。
function Skill:on_cast_channel() end

---施法出手事件。【服务端】
---每当技能进入施法出手阶段时触发。此时的技能为施法。
function Skill:on_cast_shot() end

---施法完成事件。【服务端】
---每当技能进入施法完成阶段时触发。此时的技能为施法。
function Skill:on_cast_finish() end

---施法停止事件。【服务端】
---每当技能进入施法停止阶段时触发。此时的技能为施法。
function Skill:on_cast_stop() end

---施法失败事件。【服务端】
---每当技能在进入施法开始之前被验证为施法失败时触发。此时的技能为施法。
---进入施法开始后，框架认为该技能已经成功施法，所以不会再调用该回调。
---失败码：0 成功；1 之前正释放的技能不能被打断；2 技能冷却中；3 血不够；4 魔不够；
---7 超出范围；8 没技能或没装备；9 有技能但还没学；10 参数不正确；11 放了一个被动技能；
---12 Lua返回说不让放；13 无普攻技能；14 目标死亡或者被删除；15 当前状态不能释放技能（如被沉默）；
---17 客户端不能释放禁用技能；18 客户端不能释放隐藏技能；19 施法者死亡了；
---20 技能不能对友方单位使用；21 技能不能对敌方单位使用；22 技能不能对无敌单位使用；
---23 技能不能对魔法免疫单位使用；24 技能不能对自己使用；25 技能不能对当前类型施放；26 技能不能没有目标。
---@param failed_code integer 施法失败错误码
function Skill:on_cast_failed(failed_code) end

----------------------------------------------------------------------------------------------------
-- 客户端：方法
----------------------------------------------------------------------------------------------------

---是否可升级。【客户端】
---@return boolean result 是否可升级
function Skill:can_upgrade() end

---请求使用技能。【客户端】
---只能使用当前英雄的技能。
---@param smart boolean 是否是智能施法
---@return boolean valid 请求是否合法
function Skill:cast(smart) end

---客户端触发当前技能引导阶段结束。【客户端】
function Skill:client_channel_finish() end

---注册事件。【客户端】
---这是对 base.event_register 方法的封装。
---@param name string 事件名
---@param callback fun(trigger: Trigger, ...) 事件函数，事件参数为触发器与自定义数据
---@return Trigger trigger 触发器
function Skill:event(name, callback) end

---触发事件。【客户端】
---这是对 base.event_notify 方法的封装。
---@param name string 事件名
---@param ... any 自定义数据
function Skill:event_notify(name, ...) end

---获取充能冷却。【客户端】
---如果技能并不在冷却状态，则总冷却为 0。
---@return number cd 剩余冷却（秒）
---@return number total 总冷却（秒）
function Skill:get_charge_cd() end

---获取冷却。【客户端】
---如果技能并不在冷却状态，则总冷却为 0。
---@return number cd 剩余冷却（秒）
---@return number total 总冷却（秒）
function Skill:get_cd() end

---获取所有者。【客户端】
---如果没有所有者，则返回 nil。
---@return Unit? owner 所有者
function Skill:get_owner() end

---获取技能描述。【客户端】
---返回当前等级经过计算后的描述。
---@return string tip 技能描述（Description）
---@return string short 短描述（ShortDes）
---@return string upgrade 升级描述（UpgradeDes）
function Skill:get_tip() end

---隐藏施法范围。【客户端】
---@return boolean valid 是否合法
function Skill:hide_range() end

---移动。【客户端】
---只能移动类型为“物品”的技能。
---@param slot integer 目标槽位
---@return boolean valid 是否合法
function Skill:move(slot) end

---显示施法范围。【客户端】
---指示器默认不跟随鼠标移动。
---@param follow boolean? 指示器是否跟随鼠标
---@return boolean valid 是否合法
function Skill:show_range(follow) end

---请求升级。【客户端】
---只能升级可升级的技能。
---@return boolean valid 是否合法
function Skill:upgrade() end

----------------------------------------------------------------------------------------------------
-- DamageInstance 伤害对象
----------------------------------------------------------------------------------------------------

---伤害对象。【服务端】
---使用 attack:add_damage 或 skill:add_damage 来创建一个伤害对象，并立即结算此伤害。
---创建时还可以添加任何自定义属性（不能重名），之后可从伤害对象中读出。
---@class DamageInstance
---@field source Unit 伤害的来源。可在创建时传入。
---@field target Unit 伤害的目标。可在创建时传入。
---@field skill Skill 关联技能。通过 attack:add_damage 创建时关联技能为 attack；通过 skill:add_damage 创建时关联技能为 skill。
---@field damage number 伤害值。这个属性应该在创建时传入。
---@field current_damage number 当前伤害值。初始化为伤害值，之后可以修改，最终会使用当前伤害来扣除生命。
---@field angle number 伤害方向。客户端会根据伤害方向决定受击特效的方向。如果不填，则会使用来源到目标的方向。
local DamageInstance = {}

---获取伤害方向。【服务端】
---如果创建时传入了 angle 属性，则返回该值。否则，返回当前来源的位置到目标位置的方向。
---@return number angle 伤害方向
function DamageInstance:get_angle() end

---获取伤害值。【服务端】
---@return number damage 伤害值
function DamageInstance:get_damage() end

---获取当前伤害值。【服务端】
---护甲等效果或用户可以在伤害事件中修改伤害值。
---@return number current_damage 当前伤害值
function DamageInstance:get_current_damage() end
