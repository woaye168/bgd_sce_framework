---@meta

----------------------------------------------------------------------------------------------------
-- SCE 引擎 base 基础库 EmmyLua 类型声明
-- 覆盖范围：单位 / 玩家 / 队伍 / 玩家组（势力）/ 技能 / 增益（Buff）/ 物品 / 任务 / 物品槽 /
--          响应（Response）/ 命令结果（CmdResult）/ 行为交互 / 哈希表，以及 base_lua_plus 触发层接口
-- 来源文件（195 版本 script/common/base/）：
--   unit.lua, player.lua, team.lua, group.lua, force.lua, skill.lua, buff.lua, item.lua,
--   quest.lua, slot.lua, response.lua, cmd_result.lua, behavior.lua, hashtable.lua,
--   base_lua_plus/unit.lua, base_lua_plus/player.lua, base_lua_plus/skill.lua, base_lua_plus/item.lua
-- 说明：base_lua_plus 与主目录同名函数已去重，仅声明一次；
--      形如 `Xxx = base.tsc.__TS__Class()` 的全局类定义不在此声明（仅收集 base.xxx 成员）。
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- unit.lua 单位相关
----------------------------------------------------------------------------------------------------

---根据单位编号获取（或创建）客户端单位对象，编号为空或 0 时返回 nil。
---@param id number 单位编号
---@return any unit 单位对象（Unit 实例）
---@return boolean? new 是否为本次新建的对象
function base.unit(id) end

---从客户端单位缓存中移除指定编号的单位，并清理其技能。
---@param id number 单位编号
function base.remove_unit(id) end

---根据地编节点标记获取默认单位。
---@param node_mark string 地编节点标记
---@return any unit 单位对象（Unit 实例）
function base.get_default_unit(node_mark) end

---根据地编节点标记获取默认物品（仅物品单位可获取，否则返回 nil）。
---@param node_mark string 地编节点标记
---@return any item 物品对象（Item 实例）
function base.get_default_item(node_mark) end

---注册一个自定义单位属性 key 与属性 id 的映射。
---@param name string 属性名
---@param id number 属性 id
function base.add_attribute_key(name, id) end

---获取客户端单位缓存信息（内部调试用）。
---@return table info 包含 unit_map 的信息表
function base.unit_info() end

---获取屏幕坐标下的所有单位（可指定是否精确拾取）。
---@param xy any 屏幕坐标点（Point 实例）
---@param is_accurate boolean? 是否精确检测
---@return any[] units 单位对象数组（Unit 实例）
function base.get_units_from_screen_xy(xy, is_accurate) end

----------------------------------------------------------------------------------------------------
-- unit.lua 单位事件回调（由引擎调用，可在脚本中重写）
----------------------------------------------------------------------------------------------------

---@class base
base.event = base.event or {}

---轻量单位创建回调（包含 GameUnit 与同步 Actor）。
---@param unit_id number 单位编号
---@param attr_map table 单位属性表
---@param is_actor boolean 是否为同步 Actor
function base.event.on_unit_created(unit_id, attr_map, is_actor) end

---受控同步单位创建回调。
---@param id number 单位编号
---@param scene_name string 场景名
---@param unit_type_id number 单位类型 id
---@param unit_slot number 所属玩家槽位
function base.event.on_controlled_sync_unit_created(id, scene_name, unit_type_id, unit_slot) end

---单位普通属性变化回调。
---@param data table 属性数据 [[id, key, value]] 或 {id = attr}
---@param new boolean? 是否为数组格式的新协议
function base.event.on_unit_attributes_changed(data, new) end

---单位表属性（增量同步）变化回调。
---@param data table 属性数据
---@param new boolean? 是否为数组格式的新协议
function base.event.on_unit_table_attributes_changed(data, new) end

---单位模型变化回调。
---@param id number 单位编号
---@param path string 新模型路径
function base.event.on_unit_model_changed(id, path) end

---轻量单位销毁回调（包含 GameUnit 与同步 Actor）。
---@param unit_id number 单位编号
function base.event.on_unit_destory(unit_id) end

---单位附着关系变化回调。
---@param unit_id number 单位编号
---@param attach_id number? 附着目标编号（nil 表示解除附着）
function base.event.on_unit_attach_changed(unit_id, attach_id) end

---单位悬停回调（id 为 nil 表示悬停结束）。
---@param id number? 单位编号
function base.event.on_unit_hovered(id) end

---单位血条创建回调。
---@param unit_id number 单位编号
function base.event.on_unit_blood_bar_created(unit_id) end

---单位状态机变化回调。
---@param unit_id number 单位编号
---@param state_machines table 状态机数据
function base.event.on_unit_state_machine_changed(unit_id, state_machines) end

---单位状态机跳转回调。
---@param unit_id number 单位编号
---@param sm_name string 状态机名
---@param event_id number 跳转事件 id
function base.event.on_unit_state_machine_transit(unit_id, sm_name, event_id) end

---单位冷却完成回调。
---@param unit_id number 单位编号
---@param cooldown_key string 冷却 key
function base.event.on_unit_cool_down(unit_id, cooldown_key) end

----------------------------------------------------------------------------------------------------
-- player.lua 玩家相关
----------------------------------------------------------------------------------------------------

---获取客户端本地玩家对象（首次调用时按 user_id 匹配并缓存）。
---@return any player 本地玩家对象（Player 实例）
function base.local_player() end

---根据槽位 id 获取玩家对象。
---@param id number 玩家槽位 id
---@return any player 玩家对象（Player 实例）
function base.player(id) end

---遍历所有玩家，可选按类型过滤（'user' / 'computer' 等）。
---@param type string? 玩家类型过滤
---@return fun():any 迭代函数，每次返回一个玩家对象（Player 实例）
function base.each_player(type) end

---玩家表属性（增量同步）变化回调。
---@param key_values table 属性数据 {玩家id = {属性id = 值}}
function base.event.on_player_table_attributes_changed(key_values) end

---玩家属性变化回调（含英雄、队伍、复活时间等特殊属性处理）。
---@param key_values table 属性数据 {玩家id = {属性id = 值}}
function base.event.on_player_attributes_changed(key_values) end

---玩家加载进度通知回调。
---@param slot_id number 玩家槽位 id
---@param progress number 加载进度（0-100）
function base.event.on_loading_progress_notify(slot_id, progress) end

----------------------------------------------------------------------------------------------------
-- team.lua 队伍相关
----------------------------------------------------------------------------------------------------

---根据队伍 id 获取队伍对象。
---@param id number 队伍 id
---@return any team 队伍对象（Team 实例）
function base.team(id) end

----------------------------------------------------------------------------------------------------
-- group.lua 通用对象组
----------------------------------------------------------------------------------------------------

---创建一个通用对象组（弱引用集合，可传初始列表）。
---@param list any[]? 初始对象列表
---@return any group 组对象（支持 insert/remove/has/len/random/ipairs/clear）
function base.group(list) end

----------------------------------------------------------------------------------------------------
-- force.lua 玩家组（势力）
----------------------------------------------------------------------------------------------------

---@class base
base.force = base.force or {}

---创建一个玩家组（势力）。
---@param list any[]? 初始玩家列表（Player 实例）
---@return any force 玩家组对象
function base.force:__call(list) end

---@type any 全部玩家的势力
base.force.all = nil

---@type any 全部电脑玩家的势力
base.force.computer = nil

---@type any 全部用户玩家的势力
base.force.user = nil

---@type table<number, any> 按队伍 id 划分的势力表
base.force.team = nil

----------------------------------------------------------------------------------------------------
-- skill.lua 技能相关
----------------------------------------------------------------------------------------------------

---@type table 技能原型表（Skill 实例的方法集）
base.skill_api = nil

---@class base
base.skill = base.skill or {}

---根据技能名哈希反查技能名。
---@param hash number 技能名哈希值
---@return string? name 技能名（数编 link）
function base.skill.get_skill_name_by_hash(hash) end

---根据技能 id 获取（或创建）技能对象，信息不全时返回 nil。
---@param id number 技能实例 id
---@param hash number? 技能名哈希
---@param owner any? 拥有者单位对象（Unit 实例）
---@param is_silent boolean? 是否静默（不报错）
---@return any skill 技能对象（Skill 实例）
function base.skill.ac_skill(id, hash, owner, is_silent) end

---获取客户端技能缓存信息（内部调试用）。
---@return table info 包含 skill_map 的信息表
function base.skill_info() end

---技能属性变化回调。
---@param key_values table 技能属性数据
function base.event.on_spell_attributes_changed(key_values) end

---技能移除回调。
---@param removed_spells table 被移除的技能 {unit_id = {skill_id = name_hash}}
function base.event.on_remove_spell(removed_spells) end

---技能冷却变化回调。
---@param id number 技能实例 id
---@param cd number 剩余冷却（毫秒）
---@param total number 总冷却（毫秒）
---@param type number 冷却类型（0 普通冷却，1 充能冷却）
function base.event.on_spell_cd_changed(id, cd, total, type) end

---技能冷却完成回调。
---@param id number 技能实例 id
---@param type number 冷却类型（0 普通冷却，1 充能冷却）
function base.event.on_spell_cd_finished(id, type) end

---单位施法接近回调。
---@param unit_id number 单位编号
---@param hash number 技能名哈希
function base.event.on_spell_cast_approach_ex(unit_id, hash) end

---单位施法开始回调。
---@param unit_id number 单位编号
---@param hash number 技能名哈希
---@param time number 当前时间
---@param total number 总时间
function base.event.on_spell_cast_start_ex(unit_id, hash, time, total) end

---单位施法引导（蓄力）回调。
---@param unit_id number 单位编号
---@param hash number 技能名哈希
---@param time number 当前时间
---@param total number 总时间
function base.event.on_spell_cast_notify_ex(unit_id, hash, time, total) end

---单位施法出手回调。
---@param unit_id number 单位编号
---@param hash number 技能名哈希
---@param time number 当前时间
---@param total number 总时间
function base.event.on_spell_cast_shot_ex(unit_id, hash, time, total) end

---单位施法完成（后摇）回调。
---@param unit_id number 单位编号
---@param hash number 技能名哈希
---@param time number 当前时间
---@param total number 总时间
function base.event.on_spell_cast_end_ex(unit_id, hash, time, total) end

---单位施法停止回调。
---@param unit_id number 单位编号
---@param hash number 技能名哈希
---@param time number 当前时间
---@param total number 总时间
function base.event.on_spell_cast_stop_ex(unit_id, hash, time, total) end

---单位施法打断回调。
---@param unit_id number 单位编号
---@param hash number 技能名哈希
function base.event.on_spell_cast_break_ex(unit_id, hash) end

---单位施法失败回调。
---@param unit_id number 单位编号
---@param hash number 技能名哈希
function base.event.on_spell_cast_failed_ex(unit_id, hash) end

---@class base
base.proto = base.proto or {}

---取消忽略摇杆协议处理：通知单位施法失败事件。
---@param msg table 消息体，含 id 字段
function base.proto.cancel_ignore_joy_stick(msg) end

---技能摇杆组显示单位技能协议处理。
---@param msg table 消息体
function base.proto.skill_group_set_unit(msg) end

---同步技能协议处理：创建/更新客户端技能对象并初始化冷却。
---@param msg table 消息体，含 unit_id、skill_id、skill_name、item_unit_id 字段
function base.proto.sync_skill(msg) end

----------------------------------------------------------------------------------------------------
-- buff.lua 增益（状态）相关
----------------------------------------------------------------------------------------------------

---状态获得回调。
---@param unit_id number 单位编号
---@param hash number 状态名哈希
---@param index number 状态索引
---@param time number 总时长（毫秒）
---@param remaining number 剩余时长（毫秒）
---@param stack number 层数
function base.event.on_buff_attached(unit_id, hash, index, time, remaining, stack) end

---状态失去回调。
---@param unit_id number 单位编号
---@param hash number 状态名哈希
---@param index number 状态索引
function base.event.on_buff_detached(unit_id, hash, index) end

---状态更新回调（剩余时间与层数刷新）。
---@param unit_id number 单位编号
---@param hash number 状态名哈希
---@param index number 状态索引
---@param time number 总时长（毫秒）
---@param remaining number 剩余时长（毫秒）
---@param stack number 层数
function base.event.on_buff_update(unit_id, hash, index, time, remaining, stack) end

----------------------------------------------------------------------------------------------------
-- item.lua 物品相关
----------------------------------------------------------------------------------------------------

---根据物品单位编号获取物品对象，非物品单位或不可见时返回 nil。
---@param id number 物品单位编号
---@param silence boolean? 是否静默（不输出警告日志）
---@return any item 物品对象（Item 实例）
function base.item(id, silence) end

----------------------------------------------------------------------------------------------------
-- quest.lua 任务相关
----------------------------------------------------------------------------------------------------

---将任意值格式化为可打印的字符串（表会递归展开）。
---@param t any 任意值
---@return string str 格式化后的字符串
function base.print_table(t) end

---@class base
base.quest = base.quest or {}

---@type table 任务激活状态枚举（inactive / active）
base.quest.active_state = nil

---@type table 任务完成状态枚举（none / complete / failed）
base.quest.complete_state = nil

---新建任务对象并根据同步数据初始化。
---@param tbl table 任务同步数据（含 link、owner_id、conditions 等）
---@return any quest 任务对象（Quest 实例）
function base.quest:new(tbl) end

---更新任务数据并返回产生的事件列表。
---@param tbl table 任务同步数据
---@return table events 事件列表
function base.quest:update(tbl) end

---标记任务为已移除。
function base.quest:remove() end

---任务的字符串表示。
---@return string
function base.quest:__tostring() end

---批量更新单位身上的任务与任务条件，并派发任务事件。
---@param unit any 单位对象（Unit 实例）
---@param tbl table 任务全量数据
---@param change_table table? 增量变化数据（含 modify/delete）
function base.quest.update_quests(unit, tbl, change_table) end

---@class base
base.quest_condition = base.quest_condition or {}

---新建任务条件对象并根据同步数据初始化。
---@param tbl table 任务条件同步数据
---@return any quest_condition 任务条件对象（QuestCondition 实例）
function base.quest_condition:new(tbl) end

---更新任务条件的剩余时间。
---@param remaining_time table? 剩余时间数据（含 current_time、remaining_time）
function base.quest_condition:update_remaining_time(remaining_time) end

---获取任务条件剩余时间（秒）。
---@return number remaining 剩余秒数
function base.quest_condition:get_remaining_time() end

---更新任务条件数据（首次为初始化）。
---@param tbl table 任务条件同步数据
function base.quest_condition:update(tbl) end

---标记任务条件为已移除。
function base.quest_condition:remove() end

---向服务器提交该任务条件。
function base.quest_condition:submit() end

---获取任务条件的描述文本（含进度拼接）。
---@return string? description 描述文本
function base.quest_condition:get_description() end

---任务条件的字符串表示。
---@return string
function base.quest_condition:__tostring() end

----------------------------------------------------------------------------------------------------
-- slot.lua 物品槽相关
----------------------------------------------------------------------------------------------------

---创建一个物品槽对象。
---@return any slot 物品槽对象（Slot 实例）
function base.create_slot() end

----------------------------------------------------------------------------------------------------
-- response.lua 响应相关
----------------------------------------------------------------------------------------------------

---@class base
base.response = base.response or {}

---@type table 响应位置枚举（Attacker / Defender）
base.response.e_location = nil

---根据数编 link 创建响应对象，缓存不存在时返回 nil。
---@param link string 响应对应的数编 link
---@return any response 响应对象（Response 实例）
function base.response:new(link) end

---设置响应对应的数编缓存。
---@param link string 数编 link
---@return boolean ok 是否设置成功
function base.response:set_cache(link) end

---执行响应：校验概率、目标过滤与验证器后触发响应效果。
---@param in_param any 传入的效果参数（EffectParam 实例）
---@vararg any 额外参数（按响应类型传递）
function base.response:execute(in_param, ...) end

---抽象根响应，直接调用代表出错（应使用具体响应类型）。
---@vararg any
---@return boolean 恒为 false
function base.response:response(...) end

---将响应挂载到单位上（按响应类型与位置分类排序）。
---@param unit any 单位对象（Unit 实例）
---@param ref_param any? 引用效果参数（EffectParam 实例）
function base.response:add(unit, ref_param) end

---从所属单位上移除该响应。
function base.response:remove() end

---启用该响应。
function base.response:enabled() end

---禁用该响应。
function base.response:disabled() end

---开启响应冷却（按数编配置的 Cooldown）。
---@return boolean|nil ok 缓存不存在时返回 false
function base.response:start_cooldown() end

---@class base.response
base.response.ResponseDamage = base.response.ResponseDamage or {}

---伤害响应验证器。
---@param in_param any 传入效果参数（EffectParam 实例）
---@param damage any 伤害对象（Damage 实例）
---@return any result 验证结果（CmdResult）
function base.response.ResponseDamage:validate(in_param, damage) end

---伤害响应执行：按配置修正伤害数值。
---@param in_param any 传入效果参数（EffectParam 实例）
---@param damage any 伤害对象（Damage 实例）
---@return boolean ok 是否响应成功
function base.response.ResponseDamage:exectue(in_param, damage) end

---@class base.response
base.response.ResponseMissileImpact = base.response.ResponseMissileImpact or {}

---弹道命中响应执行：可反射弹道。
---@param in_param any 传入效果参数（EffectParam 实例）
---@return boolean ok 是否响应成功
function base.response.ResponseMissileImpact:exectue(in_param) end

---@class base.response
base.response.ResponseEffectImpact = base.response.ResponseEffectImpact or {}

---效果命中响应执行：判断传入效果是否为要求的来源效果。
---@param in_param any 传入效果参数（EffectParam 实例）
---@return boolean ok 是否响应成功
function base.response.ResponseEffectImpact:exectue(in_param) end

---@class base.response
base.response.ResponseSpell = base.response.ResponseSpell or {}

---施法响应执行：按施法事件与技能分类过滤。
---@param in_param any 传入效果参数（EffectParam 实例）
---@param event string 施法事件名
---@param skill any 技能对象（Skill 实例）
---@return boolean ok 是否响应成功
function base.response.ResponseSpell:exectue(in_param, event, skill) end

---@class base.response
base.response.ResponseBuff = base.response.ResponseBuff or {}

---状态响应执行：按状态分类过滤并修正持续时间。
---@param in_param any 传入效果参数（EffectParam 实例）
---@param data table 状态数据（含 link、time 等）
---@return boolean ok 是否响应成功
function base.response.ResponseBuff:exectue(in_param, data) end

---@class base.response
base.response.ResponseUnit = base.response.ResponseUnit or {}

---单位事件响应执行：按单位事件名匹配。
---@param in_param any 传入效果参数（EffectParam 实例）
---@param event string 单位事件名
---@return boolean ok 是否响应成功
function base.response.ResponseUnit:exectue(in_param, event) end

----------------------------------------------------------------------------------------------------
-- cmd_result.lua 命令结果相关
----------------------------------------------------------------------------------------------------

---@class base
base.cmd_result = base.cmd_result or {}

---创建一个命令结果对象（默认为 Unknown）。
---@return any cmd_result 命令结果对象（CmdResult 实例）
function base.cmd_result:new() end

---比较两个命令结果是否相等。
---@param other any 另一个命令结果（CmdResult 实例）
---@return boolean
function base.cmd_result:__eq(other) end

---比较命令结果是否小于另一个。
---@param other any 另一个命令结果（CmdResult 实例）
---@return boolean
function base.cmd_result:__lt(other) end

---比较命令结果是否小于等于另一个。
---@param other any 另一个命令结果（CmdResult 实例）
---@return boolean
function base.cmd_result:__le(other) end

---获取命令结果的数值。
---@return integer value 结果码
function base.cmd_result:get_value() end

---获取命令结果对应的文本描述。
---@return string text 结果文本
function base.cmd_result:get_text() end

----------------------------------------------------------------------------------------------------
-- behavior.lua 交互行为相关
----------------------------------------------------------------------------------------------------

---单位获得交互技能协议处理。
---@param msg table 消息体，含 unit_id、skill_link 字段
function base.proto.unit_get_interaction_spell(msg) end

---单位失去交互技能协议处理。
---@param msg table 消息体，含 unit_id、skill_link 字段
function base.proto.unit_remove_interaction_spell(msg) end

---刷新本地玩家主控单位的交互摇杆显示。
function base.refresh_interact_joystick() end

----------------------------------------------------------------------------------------------------
-- hashtable.lua 哈希表相关
----------------------------------------------------------------------------------------------------

---创建一个哈希表对象（弱键，不可遍历元素，支持 save/load/flush 等方法）。
---@return any hashtable 哈希表对象
function base.hashtable() end

---@type any 全局共享哈希表实例
base.Hashtable = nil

----------------------------------------------------------------------------------------------------
-- base_lua_plus/unit.lua 单位触发层接口
----------------------------------------------------------------------------------------------------

---地编节点标记透传（直接返回 node_mark）。
---@param node_mark string 节点标记
---@param unit_name string? 单位名
---@return string node_mark 节点标记
function base.node_mark(node_mark, unit_name) end

---获取单位的属性值。
---@param unit any 单位对象（Unit 实例）
---@param state string 单位属性名
---@return any value 属性值
function base.unit_get_attribute(unit, state) end

---获取单位的 Id（数编 link 名）。
---@param unit any 单位对象（Unit 实例）
---@return string name 单位 Id
function base.unit_get_name(unit) end

---从单位编号获取单位对象。
---@param id number 单位编号
---@return any unit 单位对象（Unit 实例）
function base.get_unit_from_id(id) end

---设置单位位置（客户端）。
---@param unit any 单位对象（Unit 实例）
---@param position any 目标位置（Point 实例）
function base.set_unit_location(unit, position) end

---设置单位位置和高度（客户端）。
---@param unit any 单位对象（Unit 实例）
---@param position any 目标位置（Point 实例）
---@param height number 高度
function base.set_unit_location_and_height(unit, position, height) end

---创建漂浮文字（客户端，按 link 指定模板）。
---@param position any? 飘字位置（Point 实例，nil 表示默认位置）
---@param text string 飘字内容
---@param link string 飘字类型模板 link
---@param color any 颜色
---@param fontsize number 字体大小
---@return any riseletter 飘字对象
function base.create_riseletter_by_link(position, text, link, color, fontsize) end

---创建漂浮文字（客户端，按模板名）。
---@param position any? 飘字位置（Point 实例，nil 表示默认位置）
---@param text string 飘字内容
---@param templatename string 飘字类型模板名
---@param color any 颜色
---@param fontsize number 字体大小
---@return any riseletter 飘字对象
function base.create_riseletter_by_templatename(position, text, templatename, color, fontsize) end

---删除指定编号的漂浮文字（客户端）。
---@param riseletter_id number 飘字编号
function base.remove_riseletter(riseletter_id) end

---设置漂浮文字位置（客户端，屏幕相对坐标）。
---@param riseletter_id number 飘字编号
---@param position any 位置（Point 实例）
function base.set_riseletter_position(riseletter_id, position) end

---设置漂浮文字世界位置（客户端）。
---@param riseletter_id number 飘字编号
---@param position any 世界位置（Point 实例）
function base.set_riseletter_world_position(riseletter_id, position) end

---设置漂浮文字所属单位（客户端）。
---@param riseletter_id number 飘字编号
---@param unit any 单位对象（Unit 实例）
function base.set_riseletter_unit(riseletter_id, unit) end

---设置单位朝向（客户端）。
---@param unit any 单位对象（Unit 实例）
---@param angle number 朝向角度
function base.set_unit_facing(unit, angle) end

---获取单位随机模型索引（客户端）。
---@param unit any 单位对象（Unit 实例）
---@return number index 随机模型索引
function base.get_unit_random_model_index(unit) end

---获取单位的标签。
---@param unit any 单位对象（Unit 实例）
---@return string tag 单位标签
function base.unit_get_tag(unit) end

---获取单位的编号。
---@param unit any 单位对象（Unit 实例）
---@return number id 单位编号
function base.unit_get_id(unit) end

---获取地编单位。
---@param node_mark string 地编节点标记
---@return any unit 单位对象（Unit 实例）
function base.get_default_unit_v1(node_mark) end

---获取地编物品。
---@param node_mark string 地编节点标记
---@return any item 物品对象（Item 实例）
function base.get_default_item_v1(node_mark) end

---模型单位播放一次动画（新动画 API）。
---@param unit any 单位对象（Unit 实例）
---@param anim string 动画名
---@param time number 时间因子
---@param time_type number 时间因子类型（0 默认速度，1 持续时间，2 相对倍率，3 绝对倍率）
---@param start_offset number 起始播放时间
---@param blend_time number 渐入（混合）时长
---@param priority number 优先级
function base.anim_play(unit, anim, time, time_type, start_offset, blend_time, priority) end

---暂停/恢复单位模型动画（新 API）。
---@param unit any 单位对象（Unit 实例）
---@param paused boolean 是否暂停
function base.anim_set_paused_all(unit, paused) end

---设置单位模型动画相对播放时间倍数（只影响新 API 的动画）。
---@param unit any 单位对象（Unit 实例）
---@param time_scale number 相对播放时间倍数
function base.set_time_scale_global(unit, time_scale) end

---设置模型表现的 BSD 动画（新 API）。
---@param unit any 单位对象（Unit 实例）
---@param anim_birth string birth 动画
---@param anim_stand string stand 动画
---@param anim_death string death 动画
---@param force_one_shot boolean 强制播放一次
---@param kill_on_finish boolean 播完后自动销毁
---@param priority number 优先级
---@param sync boolean 是否同步
function base.anim_play_bracket(unit, anim_birth, anim_stand, anim_death, force_one_shot, kill_on_finish, priority, sync) end

---获取单位的显示名。
---@param unit any 单位对象（Unit 实例）
---@return string name 显示名
function base.unit_get_display_name(unit) end

---设置单位的显示名。
---@param unit any 单位对象（Unit 实例）
---@param display_name string 显示名
function base.unit_set_display_name(unit, display_name) end

---在单位上验证目标过滤器（透传 base.target_filter_validate）。
---@vararg any 过滤、过滤单位、基准单位
---@return boolean ok 是否通过过滤
function base.target_filter_validate_on_unit(...) end

---验证目标过滤器：以基准单位（缺省为过滤单位自身）校验过滤单位是否通过。
---注：源码参数名为 过滤 / 过滤单位 / 基准单位（中文标识符），此处改用拼音命名以保证语法合法。
---@param guo_lv any 目标过滤器（TargetFilters 实例，源码参数名“过滤”）
---@param guo_lv_unit any 被过滤的单位对象（Unit 实例，源码参数名“过滤单位”）
---@param base_unit any? 基准单位对象（Unit 实例，源码参数名“基准单位”）
---@return boolean ok 是否通过过滤
function base.target_filter_validate(guo_lv, guo_lv_unit, base_unit) end

---按目标过滤器过滤单位组（透传 base.unit_group_filter_group）。
---@vararg any 单位组、过滤、基准单位
---@return any group 过滤后的单位组
function base.unit_group_filter_group_on_unit(...) end

---按目标过滤器过滤单位组中的单位，返回过滤后的单位组。
---注：源码参数名为 单位组 / 过滤 / 基准单位（中文标识符），此处改用英文命名以保证语法合法。
---@param unit_group any 待过滤的单位组（源码参数名“单位组”）
---@param guo_lv any 目标过滤器（TargetFilters 实例，源码参数名“过滤”）
---@param base_unit any? 基准单位对象（Unit 实例，源码参数名“基准单位”）
---@return any group 过滤后的单位组
function base.unit_group_filter_group(unit_group, guo_lv, base_unit) end

----------------------------------------------------------------------------------------------------
-- base_lua_plus/player.lua 玩家触发层接口
----------------------------------------------------------------------------------------------------

---获取客户端本地玩家。
---@return any player 本地玩家对象（Player 实例）
function base.player_local() end

---获取玩家的游戏状态。
---@param player any 玩家对象（Player 实例）
---@return string state 游戏状态（'none' / 'online' / 'offline'）
function base.player_game_state(player) end

---获取玩家的属性值。
---@param player any 玩家对象（Player 实例）
---@param state string 玩家属性名
---@return any value 属性值
function base.player_get_attribute(player, state) end

---获取玩家的主控单位（英雄）。
---@param player any 玩家对象（Player 实例）
---@return any hero 主控单位对象（Unit 实例）
function base.player_get_hero(player) end

---获取玩家的槽位 Id。
---@param player any 玩家对象（Player 实例）
---@return number slot_id 槽位 Id
function base.player_get_slot_id(player) end

----------------------------------------------------------------------------------------------------
-- base_lua_plus/skill.lua 技能触发层接口
----------------------------------------------------------------------------------------------------

---获取技能的自定义属性值。
---@param skill any 技能对象（Skill 实例）
---@param attr string 属性名
---@return any value 属性值
function base.skill_get_attribute(skill, attr) end

---获取技能的等级。
---@param skill any 技能对象（Skill 实例）
---@return number level 技能等级
function base.skill_get_level(skill) end

---获取技能的拥有者单位。
---@param skill any 技能对象（Skill 实例）
---@return any owner 拥有者单位对象（Unit 实例）
function base.skill_get_owner(skill) end

---获取技能的 Id（数编 link 名）。
---@param skill any 技能对象（Skill 实例）
---@return string name 技能 Id
function base.skill_get_name(skill) end

---获取单位身上一个指定 Id 的技能。
---@param unit any 单位对象（Unit 实例）
---@param id string 技能 Id
---@param include_level_zero any 是否包含等级为 0 的技能
---@return any skill 技能对象（Skill 实例）
function base.unit_find_skill_by_name(unit, id, include_level_zero) end

---获取单位身上指定英雄槽位的技能。
---@param unit any 单位对象（Unit 实例）
---@param slot number 槽位
---@return any skill 技能对象（Skill 实例）
function base.unit_find_skill_by_slot(unit, slot) end

---获取技能的提示信息。
---@param skill any 技能对象（Skill 实例）
---@return string tip 提示信息
function base.skill_get_tip(skill) end

----------------------------------------------------------------------------------------------------
-- base_lua_plus/item.lua 物品触发层接口
----------------------------------------------------------------------------------------------------

---获取物品在地上时对应的物品单位。
---@param item any 物品对象（Item 实例）
---@return any unit 物品单位对象（Unit 实例）
function base.item_unit(item) end

---获取物品单位对应的物品对象。
---@param unit any 物品单位对象（Unit 实例）
---@return any item 物品对象（Item 实例）
function base.item_unit_get_item(unit) end

---获取物品的 Id（数编 link 名）。
---@param item any 物品对象（Item 实例）
---@return string name 物品 Id
function base.item_get_name(item) end

---获取物品的使用次数（堆叠数）。
---@param item any 物品对象（Item 实例）
---@return number stack 使用次数
function base.item_get_stack(item) end

---获取物品的拥有者玩家。
---@param item any 物品对象（Item 实例）
---@return any player 拥有者玩家对象（Player 实例）
function base.item_get_owner(item) end

---获取物品的持有者单位。
---@param item any 物品对象（Item 实例）
---@return any unit 持有者单位对象（Unit 实例）
function base.item_get_holder(item) end

---获取物品所在的背包/格子编号（源码中同名函数定义了两次，此处合并声明一次）。
---@param item any 物品对象（Item 实例）
---@return number index 背包或格子编号
function base.item_get_inventory(item) end

---令单位尝试拾取物品，根据结果执行回调。
---@param unit any 单位对象（Unit 实例）
---@param item any 物品对象（Item 实例）
---@param callback fun(...) 拾取结果回调
function base.unit_try_pick_item(unit, item, callback) end

---尝试卸下物品，根据结果执行回调。
---@param item any 物品对象（Item 实例）
---@param callback fun(...) 卸下结果回调
function base.try_drop_item(item, callback) end

---获取单位身上所有物品的编号列表。
---@param unit any 单位对象（Unit 实例）
---@return number[] ids 物品编号数组
function base.get_unit_item(unit) end
