---@meta

------------------------------------------------------------------------------
-- SCE 引擎 Lua API 类型声明：事件系统 / 触发器 / 客户端-服务端 RPC
--
-- 覆盖来源文件：
--   script/common/base/init.lua                    （base.event = _G.game_events 挂接）
--   script/common/base/event.lua                   （事件注册/通知/分发、序列化、base.game 事件方法）
--   script/common/base/server.lua                  （base.game:server RPC、base.proto 服务端消息处理）
--   script/common/base/trigger.lua                 （base.trig 触发器原型及事件表）
--   script/common/base/trigger_editor_v2/init.lua  （触发器V2辅助：force_as / instance_of / ArrayIterator）
--   script/common/base/base_lua_plus/trigger.lua   （触发器快捷封装 base.trigger_*）
--   script/common/base/shortcut.lua                （base.shortcut 快捷键）
--   script/common/base/cheat.lua                   （base.cheat 调试作弊接口）
--   script/common/base/error_info.lua              （base.get_error_info）
--   script/common/base/state_machine.lua           （base.state_machine 状态机）
--
-- 说明：
--   1. base.auxiliary 命名空间由引擎在服务端运行时动态注入，Lua 源码中不存在定义，
--      为了获得代码补全与类型检查，本文件以手写方式补充其成员声明。
--   2. base.中文名 = base.tsc.__TS__Class() 形式的 TS 触发事件类（如 base.游戏开始）
--      属于数据驱动的触发事件定义，按约定不在此声明。
--   3. base.trig.event.evt_args 下约 50 个事件参数组合函数（args.event_*）为引擎
--      内部使用的参数打包器，仅声明表结构，不逐一展开。
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- 命名空间父表
------------------------------------------------------------------------------

---游戏主事件对象。游戏级事件的注册、通知、分发以及服务端 RPC 都挂在它上面
base.game = {}

---全局事件回调表（实际为 _G.game_events），引擎按事件名回调其中的函数；
---base.assign_event 会把内置事件处理函数挂到此表上
base.event = {}

---触发器原型对象（Trigger.prototype），所有触发器实例共享的方法都挂在它上面；
---同时 base.trig:new 用于创建新的触发器
---@type table
base.trig = {}

---触发器事件配置表，包含 event_list（事件名 -> 参数打包器名映射）与 evt_args（参数打包器集合）
---@type table
base.trig.event = {}

---服务端消息协议处理表，服务端发往客户端的各类消息在此注册处理函数
base.proto = {}

---快捷键管理命名空间
base.shortcut = {}

---调试作弊接口命名空间
base.cheat = {}

---引擎服务端注入的辅助接口命名空间（Lua 源码中无定义，手写声明）
base.auxiliary = {}

---上层拆分事件的订阅映射：拆分后的事件名 -> 实际需要订阅的原始事件名
---（如 ['玩家-界面消息'] = '自定义UI-消息'）
---@type table<string, string>
base.event_subscribe_list = {}

------------------------------------------------------------------------------
-- 事件系统（event.lua）
------------------------------------------------------------------------------

---把事件处理函数挂到全局事件表 base.event 上（引擎按事件名回调）。
---name 为内置事件名（如 '单位-死亡'），f 的第一个参数为事件宿主对象
---@param name string 事件名（如 '游戏-开始'）
---@param f fun(self: any, ...): any 事件处理函数
function base.assign_event(name, f) end

---把指定事件标记为需要转发到服务端。之后客户端 base.event_notify 触发该事件时，
---参数会被序列化并通过 '__client_event_to_server' 消息转发给服务端
---@param name string 需要转发的事件名
function base.forward_event_register(name) end

---分发事件：依次调用宿主对象上注册该事件的触发器回调，
---任一回调返回非 nil 值时提前结束并返回该值（dispatch 语义，用于请求类事件）
---@param obj table 事件宿主对象（单位/玩家/游戏等，实际为各类游戏对象）
---@param name string 事件名（如 '技能-即将施法'）
---@vararg any 事件参数
---@return any res 首个返回非 nil 的回调的第一个返回值
---@return any arg 首个返回非 nil 的回调的第二个返回值
function base.event_dispatch(obj, name, ...) end

---通知事件：调用宿主对象上注册该事件的全部触发器回调（忽略返回值）。
---若事件名已通过 base.forward_event_register 登记，会先向服务端转发
---@param obj table 事件宿主对象（单位/玩家/游戏等，实际为各类游戏对象）
---@param name string 事件名（如 '单位-死亡'）
---@vararg any 事件参数
function base.event_notify(obj, name, ...) end

---为宿主对象注册事件回调。内部创建一个触发器并把事件挂到对象的 _events 表上
---@param obj table 事件宿主对象（单位/玩家/游戏等，实际为各类游戏对象）
---@param name string 事件名（如 '游戏-开始'）
---@param f fun(trg: any, ...): any 回调，首个参数为触发器自身，其后为事件参数
---@return any trg 创建的触发器对象
function base.event_register(obj, name, f) end

---序列化自定义事件参数：把单位/玩家/物品/表现/点等对象转为 '{type|id}' 字符串，
---表递归处理，函数与协程返回 nil（不可序列化）。用于客户端向服务端转发事件
---@param t any 待序列化的值
---@param depth integer|nil 递归深度（内部使用，超过 10 层返回 nil）
---@param event_name string|nil 事件名（用于报错提示）
---@return any 序列化后的值，不可序列化时返回 nil
function base.event_serialize(t, depth, event_name) end

---反序列化事件参数：把 '{unit|id}' '{player|id}' '{point|(x, y, z)}' 等字符串
---还原为对应的游戏对象，表递归处理。用于接收服务端转发的事件
---@param t any 待反序列化的值
---@return any 还原后的值
function base.event_deserialize(t) end

---触发一个游戏级自定义事件（等价于 base.game:event_notify）
---@param event_name string 自定义事件名
---@param event_param any 事件参数
function base.custom_event_notify(event_name, event_param) end

---发送触发器V2自定义事件。event 需包含 obj / event_name 字段；
---event.autoForward 为 true 时会顺带把事件转发到服务端
---@param event table 自定义事件对象（含 obj、event_name、autoForward 等字段）
function base.send_custom_event(event) end

---加入中途局（断线重连/观战补位）。通过大厅接口按 middle_game_key 加入当前地图
---@param middle_game_key string 中途局 key，为空则直接返回
function base.join_middle_game(middle_game_key) end

---发送添加好友申请
---@param user_id any 目标用户 id，为空则直接返回
function base.send_add_friend(user_id) end

---同意对方的好友申请
---@param user_id any 目标用户 id，为空则直接返回
function base.send_agree_add(user_id) end

---拒绝对方的好友申请
---@param user_id any 目标用户 id，为空则直接返回
function base.send_refuse_add(user_id) end

------------------------------------------------------------------------------
-- base.game 事件方法（event.lua）
------------------------------------------------------------------------------

---注册游戏级事件（等价于 base.event_register(base.game, name, f)）
---@param name string 事件名（如 '游戏-开始'）
---@param f fun(trg: any, ...): any 回调，首个参数为触发器自身，其后为事件参数
---@return any trg 创建的触发器对象
function base.game:event(name, f) end

---通知游戏级事件，调用所有注册该事件的触发器回调（忽略返回值）
---@param name string 事件名
---@vararg any 事件参数
function base.game:event_notify(name, ...) end

---分发游戏级事件，任一回调返回非 nil 时提前结束并返回该值
---@param name string 事件名
---@vararg any 事件参数
---@return any res 首个返回非 nil 的回调的第一个返回值
---@return any arg 首个返回非 nil 的回调的第二个返回值
function base.game:event_dispatch(name, ...) end

---监听广播：内部注册 '广播' 事件，当广播消息名与 name 一致时调用回调
---@param name string 广播消息名
---@param f fun(...): any 收到匹配广播时的回调，参数为广播附带数据
---@return any trg 创建的触发器对象
function base.game:broadcast(name, f) end

---构造服务端 RPC 调用。调用形式为 base.game:server'消息名'{参数表}：
---先用字符串参数拿到发送函数，再用参数表调用它把消息打包发往服务端
---@param type string 消息名（服务端 proto 中注册的处理函数名）
---@return fun(data: table) sender 消息发送函数，传入参数表即发送
function base.game:server(type) end

------------------------------------------------------------------------------
-- base.event 全局回调（server.lua，由引擎调用）
------------------------------------------------------------------------------

---处理服务端发来的 UI 消息（旧版通道）：反序列化后按消息名分发给 base.proto 中的处理函数
---@param str string 序列化的消息串
function base.event.on_ui_message(str) end

---处理服务端发来的 UI 消息（新版通道，带 type_id 映射）：反序列化后分发给 base.proto 处理函数
---@param str string 序列化的消息串
---@param type_id any 消息类型 id
---@param type_name string 消息类型名（首次出现时用于建立 id -> 名称映射）
function base.event.on_ui_message_new(str, type_id, type_name) end

---服务端时钟消息回调（server.lua 中 proto.clock 会调用它，实际定义由引擎/其他模块提供）
---@param clock any 服务端时钟数据
function base.event.on_server_clock(clock) end

------------------------------------------------------------------------------
-- base.proto 服务端消息处理（server.lua）
------------------------------------------------------------------------------

---热重载脚本（直接调用引擎 reload）
function base.proto.reload() end

---服务端写界面变量：按 key 路径定位 base.ui.bind 中的绑定并写入 value，
---成功后通知 '服务器-变量更新' 事件
---@param data table 消息表（含 name 界面名、key 键路径数组、value 写入值）
function base.proto.bind(data) end

---服务端订阅界面变量：把绑定处的值替换为回传函数，被调用时通过
---base.game:server'notify' 把参数回传给服务端
---@param data table 消息表（含 name 界面名、key 键路径数组、value 订阅 id）
function base.proto.subscribe(data) end

---服务端时钟消息：转发给 base.event.on_server_clock
---@param clock any 服务端时钟数据
function base.proto.clock(clock) end

---服务端远程调用客户端对象方法（s2c rpc）：按 cls/method 查注册表并调用
---@param data table 消息表（含 cls 类名、method 方法名、args 参数数组）
function base.proto.s2c_rpc(data) end

---处理服务端转发到客户端的事件：反序列化事件参数后在本地 event_notify
---@param msg table 消息表（含 obj、name、args 字段）
function base.proto.__server_event_to_client(msg) end

---接收服务端返回的地编默认单位查询结果，写入缓存并唤醒等待的协程
---@param msg table 消息表（含 ok、node_mark、unit_id 字段）
function base.proto.__return_default_unit(msg) end

---处理单位拾取物品的结果，回调单位上登记的 _try_pick_item_callback
---@param msg table 消息表（含 ok、unit_id、item_id 字段）
function base.proto.__unit_try_pick_item_result(msg) end

---处理物品丢弃结果，回调物品上登记的 _try_drop_callback
---@param msg table 消息表（含 ok、item_id 字段）
function base.proto.__item_try_drop_result(msg) end

---处理服务端增加自定义属性的通知，调用 base.add_attribute_key 同步到客户端
---@param msg table 消息表（含 struct_name、struct_id 字段）
function base.proto.__add_attribute_and_sync_client(msg) end

---处理服务端设置游戏速度的通知，同步客户端游戏速度
---@param msg table 消息表（含 speed 字段）
function base.proto._set_game_speed(msg) end

---设置自定义单位属性的显示格式
---@param msg table 消息表（含 attr、format 字段）
function base.proto.__set_attribute_custom_format(msg) end

------------------------------------------------------------------------------
-- 触发器原型方法（trigger.lua，base.trig 即 Trigger.prototype）
------------------------------------------------------------------------------

---通过函数创建一个新的触发器
---@param action function 触发器回调（sync 为 true 时会被包装为协程异步执行）
---@param combine_args boolean|nil 是否把事件参数打包为单个表再传给回调
---@param scene any 所属场景对象（传了则注册为场景事件，场景激活时才生效）
---@param sync boolean|nil sync 区别新旧方法，旧方法传进来的 func 已经是协程，不好处理
---@return any trg 新创建的触发器对象
function base.trig:new(action, combine_args, scene, sync) end

---禁用触发器（回调不再执行，但事件仍挂载着）
function base.trig:disable() end

---启用触发器
function base.trig:enable() end

---触发器是否处于启用状态
---@return boolean enable 是否启用
function base.trig:is_enable() end

---摧毁触发器（下一帧移除其挂载的全部事件）
function base.trig:remove() end

---把通用触发事件表挂到触发器上。事件表带 time 字段时按游戏时间事件处理
---@param event table 触发事件表（含 obj、event_name、custom_event、time、periodic 等字段）
function base.trig:add_event_common(event) end

---把通用触发事件表从触发器上移除。事件表带 time 字段时按游戏时间事件匹配移除
---@param event table 触发事件表（含 obj、event_name、time、periodic 等字段）
function base.trig:remove_event_common(event) end

---复制触发器（共享同一个回调）。include_event 为 true 时连同已挂载的事件一起复制
---@param include_event boolean|nil 是否复制已挂载的事件
---@return any trg 复制出的新触发器
function base.trig:replicate(include_event) end

---为触发器挂载事件
---@param obj any 事件宿主对象（单位/玩家/游戏等，也可传返回宿主对象的函数）
---@param name string 事件名
---@param custom_event boolean|nil 是否为触发器定义的自定义事件
---@param time number|nil 游戏时间（秒），与 periodic 配合用于游戏时间事件
---@param periodic boolean|nil 是否周期触发
function base.trig:add_event(obj, name, custom_event, time, periodic) end

---挂载游戏时间事件：游戏开始后 time 秒触发一次（periodic 为 true 时每 time 秒循环触发）。
---游戏未开始时登记为待处理，'游戏-开始' 后统一挂载
---@param time number 时间（秒）
---@param periodic boolean 是否周期触发
function base.trig:add_event_game_time(time, periodic) end

---内部实现：立即挂载游戏时间事件（创建引擎计时器并把 '计时器-游戏时间' 事件挂到触发器上）
---@param time number 时间（秒）
---@param periodic boolean 是否周期触发
function base.trig:add_event_game_time_internal(time, periodic) end

---替换触发器的回调函数
---@param action function 新的回调函数
function base.trig:set_action(action) end

------------------------------------------------------------------------------
-- 触发器全局函数（trigger.lua）
------------------------------------------------------------------------------

---统计当前存活的触发器数量（已标记移除的不计）
---@return integer count 触发器数量
function base.trigger_size() end

---遍历全部触发器（pairs 风格的迭代器）
---@return fun(t: table, k: any): any, table, nil iter 迭代器三元组，键为触发器对象
function base.each_trigger() end

---创建触发器（旧方案，不要再使用，请改用 base.trig:new）
---@param event table|nil 事件委托表，传入则把触发器插入该表
---@param callback function 触发器回调
---@return any trg 触发器对象
function base.trigger(event, callback) end

---从函数创建回调型触发器（回调被包装为协程异步执行，combine_args 固定为 true）
---@param func function 触发器回调
---@return any trg 触发器对象
function base.trigger_new_from_function(func) end

------------------------------------------------------------------------------
-- 触发器快捷封装（base_lua_plus/trigger.lua）
------------------------------------------------------------------------------

---关闭（禁用）触发器
---@param trigger any 触发器对象
function base.trigger_disable(trigger) end

---开启（启用）触发器
---@param trigger any 触发器对象
function base.trigger_enable(trigger) end

---触发器是否开启
---@param trigger any 触发器对象
---@return boolean|nil enable 是否开启（trigger 非法时返回 nil）
function base.trigger_is_enable(trigger) end

---移除触发器（连带移除其挂载的全部事件）
---@param trigger any 触发器对象
function base.trigger_remove(trigger) end

---创建触发器并按事件表批量挂载事件
---@param func function 触发器回调
---@param t table|nil 触发事件表数组（元素为各 trigger_event_wrapper_* 的返回值）
---@param disable boolean|nil 创建后是否立即禁用
---@param scene any 所属场景对象
---@param sync boolean|nil 是否同步回调（见 base.trig:new）
---@return any trg 新创建的触发器对象
function base.trigger_new(func, t, disable, scene, sync) end

---为触发器添加一个触发事件
---@param trigger any 触发器对象
---@param trigger_event table 触发事件表（各 trigger_event_wrapper_* 的返回值）
function base.trigger_add_event(trigger, trigger_event) end

---包装单位事件：单位发生指定事件时触发
---@param unit any 单位对象（也接受任意单位/单位id）
---@param event_name string 事件名（如 '单位-死亡'）
---@return table|nil event 触发事件表（含 obj、event_name），参数无效返回 nil
function base.trigger_event_wrapper_unit(unit, event_name) end

---包装技能事件：技能发生指定事件时触发
---@param skill any 技能对象（也接受任意技能/技能id）
---@param event_name string 事件名
---@return table|nil event 触发事件表（含 obj、event_name），参数无效返回 nil
function base.trigger_event_wrapper_skill(skill, event_name) end

---包装玩家事件：玩家发生指定事件时触发
---@param player any 玩家对象（也接受任意玩家）
---@param event_name string 事件名
---@return table|nil event 触发事件表（含 obj、event_name），参数无效返回 nil
function base.trigger_event_wrapper_player(player, event_name) end

---包装游戏事件：游戏发生指定事件时触发
---@param event_name string 事件名（如 '游戏-开始'）
---@return table|nil event 触发事件表（含 obj、event_name），参数无效返回 nil
function base.trigger_event_wrapper_game(event_name) end

---包装循环游戏时间事件：游戏开始后每 time 秒执行
---@param time number 间隔（秒）
---@return table|nil event 触发事件表（含 obj、time、periodic=true）
function base.trigger_event_wrapper_timer_periodic(time) end

---包装单次游戏时间事件：游戏开始后 time 秒执行一次
---@param time number 延迟（秒）
---@return table|nil event 触发事件表（含 obj、time、periodic=false）
function base.trigger_event_wrapper_timer_once(time) end

---包装消息事件：收到指定类型的消息时触发
---@param event_name string 事件名
---@return table|nil event 触发事件表（含 obj、event_name）
function base.trigger_event_wrapper_message(event_name) end

---包装画面事件：画面发生指定事件（分辨率变化等）时触发
---@param event_name string 事件名
---@return table|nil event 触发事件表（含 obj、event_name）
function base.trigger_event_wrapper_screen(event_name) end

---包装输入事件：玩家发生指定输入事件（按键/鼠标等）时触发
---@param event_name string 事件名
---@return table|nil event 触发事件表（含 obj、event_name）
function base.trigger_event_wrapper_input(event_name) end

---包装表现事件：表现（动画/音效等）发生指定事件时触发
---@param event_name string 事件名
---@return table|nil event 触发事件表（含 obj、event_name）
function base.trigger_event_wrapper_actor(event_name) end

---包装状态事件：状态（Buff）发生指定事件时触发
---@param buff any 状态对象
---@param event_name string 事件名
---@return table|nil event 触发事件表（含 obj、event_name），参数无效返回 nil
function base.trigger_event_wrapper_buff(buff, event_name) end

---包装对话事件：对话发生指定事件（开始/结束/选择/跳过）时触发
---@param event_name string 事件名
---@return table|nil event 触发事件表（含 obj、event_name）
function base.trigger_event_wrapper_conversation(event_name) end

---包装自定义事件：游戏级自定义事件发生时触发（custom_event 固定为 true）
---@param event_name string 自定义事件名
---@return table|nil event 触发事件表（含 obj、custom_event、event_name）
function base.trigger_custom_event_wrapper(event_name) end

---手动调用触发器回调。触发器已移除或被禁用时只打警告不执行；
---sync 为 true 时以同步方式调用（要求创建时传了 sync 回调）
---@param trigger any 触发器对象
---@param e any 传给回调的事件参数
---@param sync boolean|nil 是否同步调用
---@return any co 回调所在的协程包装对象
function base.trigger_call(trigger, e, sync) end

------------------------------------------------------------------------------
-- 触发器V2 辅助（trigger_editor_v2/init.lua）
------------------------------------------------------------------------------

---创建数组迭代器（先拷贝一份快照，再从前往后迭代）
---@param array table 数组
---@return fun(self: table, index: integer): integer, any iter 迭代函数
---@return table state 原数组
---@return integer ctrl 初始控制值 -1
function base.ArrayIterator(array) end

---强制类型转换。string/boolean/number 关键字类型走 tostring/tonumber/布尔化；
---其余按 TS 类型系统强制转换，TypeReference 且目标无类型名时原样返回
---@param classTbl any 目标类型（TS 类表或 __TS__Keyword 关键字类型）
---@param obj any 待转换的对象
---@return any 转换结果，转换失败时按 __TS__ForceAs 规则返回
function base.force_as(classTbl, obj) end

---判断对象是否为目标类型的实例（基于 TS 类型系统）
---@param classTbl any 目标类型（TS 类表）
---@param obj any 待判断的对象
---@return boolean result 是否为该类型实例
function base.instance_of(classTbl, obj) end

------------------------------------------------------------------------------
-- 快捷键（shortcut.lua，仅 StateGame 状态可用）
------------------------------------------------------------------------------

---注册快捷键及回调
---@param name string 快捷键名
---@param func fun() 按下时的回调
function base.shortcut:register(name, func) end

---指定快捷键是否已注册
---@param name string 快捷键名
---@return boolean registered 是否已注册
function base.shortcut:has_registered(name) end

---注销快捷键
---@param name string 快捷键名
function base.shortcut:unregister(name) end

---查询快捷键当前是否处于按下状态
---@param name string 快捷键名
---@param repeatable boolean|nil 按住时是否重复返回 true
---@return boolean pressed 是否按下
function base.shortcut:get_shortcut_pressed(name, repeatable) end

---锁定快捷键（按下不再触发回调）
---@param name string 快捷键名
function base.shortcut:lock(name) end

---解锁快捷键
---@param name string 快捷键名
function base.shortcut:unlock(name) end

---锁定全部快捷键
function base.shortcut:lock_all() end

---解锁全部快捷键
function base.shortcut:unlock_all() end

---测试用快捷键的键值（快捷键映射常量）
---@type integer
base.shortcut.TEST = 5000

------------------------------------------------------------------------------
-- 调试作弊接口（cheat.lua）
------------------------------------------------------------------------------

---可视化绘制效果节点的搜索范围与父子连线（调试数编效果树用）
---@param eff_data table 效果节点数据（含 root_id、id、point、parent_id 等字段）
function base.cheat.VRP(eff_data) end

---将技能来源与目标用红线连接，并在来源头上标注技能信息（调试 AI 施法用）
---@param source_id integer 来源单位 id
---@param target_id integer 目标单位 id
---@param info string 标注文本
function base.cheat.VAO_cast(source_id, target_id, info) end

---可视化单位接近目标的过程：持续绘制来源到目标的连线（调试 AI 接近用）
---@param source_id integer 来源单位 id
---@param target_id any 目标（单位 id 或点对象）
---@param info string 标注信息（'start' 表示开始）
function base.cheat.VAO_approach(source_id, target_id, info) end

---销毁指定来源单位的接近调试绘制（源码函数名拼写如此，保留原名）
---@param source_id integer 来源单位 id
function base.cheat.VAO_approach_destory(source_id) end

---GM 调试：更新单位属性调试面板
---@param msg table 消息表（含 props 字段，json 字符串）
function base.proto.__gm_debug_unit(msg) end

---GM 调试：更新玩家属性调试面板
---@param msg table 消息表（含 all_trace_player_props 字段，json 字符串）
function base.proto.__gm_debug_player(msg) end

---GM 调试：更新游戏数据调试面板
---@param msg table 消息表（含 props 字段，json 字符串）
function base.proto.__gm_debug_game(msg) end

---GM 调试：销毁全部效果调试绘制并清空效果树
---@param msg table 消息表（未使用）
function base.proto.__gm_debug_eff_destory_all(msg) end

---GM 调试：销毁指定效果节点的调试绘制（源码函数名拼写如此，保留原名）
---@param msg table 消息表（含 props.root_id、props.id 字段）
function base.proto.__gm_debug_eff_destory(msg) end

---GM 调试：登记效果节点信息并触发可视化绘制
---@param msg table 消息表（含 props 效果节点数据）
function base.proto.__gm_debug_eff_info(msg) end

---GM 调试：设置效果调试绘制是否全部常驻
---@param msg table 消息表（含 all_keep_alive 字段）
function base.proto.__gm_debug_eff_keep(msg) end

---GM 调试：处理 AI 指令可视化（cast 施法 / approach 接近）
---@param msg table 消息表（含 type、source_id、target_id、info 字段）
function base.proto.__gm_debug_ai_order(msg) end

------------------------------------------------------------------------------
-- 其他（error_info.lua / state_machine.lua）
------------------------------------------------------------------------------

---获取地图错误信息（地图名与版本号），用于错误上报
---@return table info 信息表（map_name 地图名、version 版本号，读不到时为 -1）
function base.get_error_info() end

---创建自定义状态机（仅 StateGame 状态下可用）
---@param name string 状态机名
---@param priority integer|nil 优先级，默认 0
---@param layer integer|nil 所在层，默认 0
---@return any sm 状态机对象
function base.state_machine(name, priority, layer) end

---创建状态机状态对象
---@param name string 状态名
---@param id any 状态 id
---@return any state 状态对象
function base.state_machine_state(name, id) end

------------------------------------------------------------------------------
-- base.auxiliary（引擎服务端注入，Lua 源码中无定义，以下为手写声明）
------------------------------------------------------------------------------

---获取玩家的用户 ID（uid）
---@param player any 玩家对象
---@return any uid 用户 ID
function base.auxiliary.get_player_id(player) end

---获取地图类型（2 表示某种特殊类型）
---@return integer kind 地图类型
function base.auxiliary.get_map_kind() end

---获取系统毫秒时间戳
---@return number time 系统毫秒时间戳
function base.auxiliary.get_system_time() end
