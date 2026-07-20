---@meta

----------------------------------------------------------------------------------------------------
-- SCE 引擎 Unit（单位）EmmyLua 类型声明
-- 覆盖范围：服务端 单位属性/单位标记/单位类别/单位标签/单位 API/英雄升级，客户端 单位 API
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/单位/单位属性
--   https://doc.sce.xd.com/技术文档/服务端Lua API/单位/单位标记
--   https://doc.sce.xd.com/技术文档/服务端Lua API/单位/单位类别
--   https://doc.sce.xd.com/技术文档/服务端Lua API/单位/单位标签
--   https://doc.sce.xd.com/技术文档/服务端Lua API/单位/API
--   https://doc.sce.xd.com/技术文档/服务端Lua API/单位/英雄升级
--   https://doc.sce.xd.com/技术文档/客户端Lua API/单位/单位
-- 注意：
--   1. “单位标记”以前叫“单位行为限制”，add_restriction/get_restriction/has_restriction/remove_restriction
--      为老 api，与对应的 mark api 效果一样；add_animation 同 play_animation，为兼容才保留。
--   2. 客户端的 attach_model/detach_model/change_model/set_highlight 等 API 文档描述较为简略（待整理），
--      参数说明以文档原文为准。
--   3. 客户端文档中 UnitData 的链接已失效（404），get_data 等价于 base.table.unit[unit:get_name()]。
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 单位属性（枚举型页面，字符串属性名，配合 Unit:get/set/add 等使用）【服务端】
--
-- 单位数值属性由基础值、百分比变化值两部分组成：
--   实际值 = min(最大值, max(最小值, 基础值 * (1 + 百分比 / 100)))
-- 最大值和最小值并不一定存在，不存在时不影响属性。
-- 单位数值属性类型（value_type）：0=最终值（实际值），1=基础值，2=百分比变化值。
-- 在属性名后加 '%' 表示操作百分比部分（如 u:add('攻击%', 10)），
-- 但 get('攻击%') 与 set('攻击%', 10) 会报错。
--
-- 引擎内置属性（16个，无法禁用）：
--   攻击        普通攻击的初始伤害
--   护甲        伤害结算修正：护甲>0 最终伤害=伤害/(1+护甲*0.01)；护甲<0 最终伤害=伤害*(1-护甲*0.01)
--   生命        无法小于0，也无法超过生命上限；百分比无效。直接设置为0不会死亡
--   生命上限    修改会导致生命按比例缩放
--   生命恢复    每秒增长的生命；单位死亡时暂时失效
--   魔法        无法小于0，也无法超过魔法上限；百分比无效
--   魔法上限    修改会导致魔法按比例缩放
--   魔法恢复    每秒增长的魔法；单位死亡时暂时失效
--   攻击速度    影响普通攻击的冷却时间和动画表现
--   移动速度    单位每秒能移动的距离
--   冷却缩减    技能冷却时间减少的比例（40 表示减少 40%）
--   减耗        技能魔法消耗减少的比例（40 表示减少 40%）
--   攻击范围    等价于当前攻击技能的施法范围；百分比无效
--   搜敌范围    搜敌器搜索范围可以超出攻击范围的距离
--   视野范围    单位提供视野的范围
--   单位标记    虽是单位属性，但不要使用属性 api 访问修改，请使用 add_mark 等相关 api
--
-- 脚本库/客户端UI 提供支持的属性（5个，文档详述了其中2个）：
--   等级        用于英雄升级，表示单位的当前等级
--   技能点      用于脚本库学习技能，学习技能需要消耗技能点
-- （英雄升级相关还有 经验、经验上限，见英雄升级一节）
--
-- 自定义属性：数据编辑器中可定义178个自定义属性，引擎不做任何假定和实现。
--
-- 为节约网络资源，默认大多数属性不同步客户端，可用 set_attribute_sync 选择同步哪些属性。
-- 属性的最大值/最小值/同步方式有全局值和单位自己的值，单位的值在创建时从全局值复制，
-- 修改全局值不会影响已存在的单位。
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 单位标记（枚举型页面，字符串标记名，配合 add_mark/remove_mark/get_mark/has_mark 使用）【服务端】
--
-- 所有单位标记只有“有”和“没有”两种状态，但每种标记都有引用计数：
-- 添加两次“无敌”需要删除两次才能不无敌；引用计数不会小于0。
--
-- 可用标记：
--   定身      无法移动，也无法进行主动运动
--   缴械      无法使用攻击技能
--   物免      无法成为攻击技能的目标，不受来自攻击技能的伤害
--   禁魔      无法使用技能
--   魔免      无法成为技能的目标，不受来自技能的伤害
--   免死      不会因受到伤害而死亡，生命被设置为0并继续存活
--   隐身      敌方玩家无法看到这个单位
--   隐藏      所有玩家无法看到这个单位
--   显影      使单位的隐身和逻辑隐藏失效
--   模型隐藏  不显示单位的模型及绑定特效（游戏内单位仍可以看到它）
--   逻辑隐藏  敌方玩家逻辑上看不到这个单位（人类玩家仍可以看到）
--   飞行      移动无视静态碰撞
--   幽灵      移动无视动态碰撞
--   蝗虫      不会被选取器选中
--   失控      忽略所有客户端对其发布的命令
--   天空      提供的视野无视视野阻挡
--   无敌      等价于魔免+物免（添加无敌就是添加魔免和物免）
--   免时停    豁免时间停止效果；免时停期间创建的弹道也豁免时停，且弹道打出后必打完
--   虚空      无视地形高度，高度从0开始，不影响碰撞判断
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 单位类别（枚举型页面）【服务端】
--
-- 单位类别是单位的固有属性，用于区分引擎对这个单位启用了哪些功能：
--   弹道  独有功能：对弹道捕获器可见。单位属性、行为限制、技能、状态、移动、传送等功能不可用
--   生物  会激活大多数的功能
--   阻挡  独有功能：可以提供静态碰撞。无法改变位置（运动、移动、传送），其他和弹道类似
--
-- 注意：单位表中的 UnitClass 支持 弹道/阻挡/生物/建筑/英雄，
-- 其中 建筑 和 英雄 实际的单位类别都是 生物。
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 单位标签（枚举型页面）【服务端】
--
-- 单位标签提供分类功能，可自由添加任意标签，本身没有任何默认行为。
-- 一些老文档里也可能把单位标签称为单位类型。
-- 用途：技能目标允许过滤、搜敌器仇恨修改、选取器选取/过滤、get_tag 自定义功能。
-- 脚本库假定存在单位标签 英雄 和 物品：英雄升级、学习技能、英雄复活等功能只对
-- 标签为 英雄 的单位有效；物品的关联单位的单位标签必须是 物品。
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 英雄升级【服务端】
--
-- 所有单位标签为 英雄 且不是幻象的单位会获得升级能力。
-- 使用 base.game:set_level_exp 设置升级所需经验，同时 base.game.max_level 会被设置为等级上限。
-- 以下功能只在等级上限大于0时对拥有升级能力的单位有效：
--   初始化：等级=1，经验=0，经验上限=1级升2级所需经验。
--   获得经验：先触发 单位-即将获得经验 事件，累加经验；经验大于经验上限则扣除并升级，
--     直到达到等级上限或经验小于经验上限；之后触发 单位-获得经验 事件。
--   提升等级：经验上限设为当前等级升下一级所需经验；若已达等级上限，
--     经验上限与经验都设为0；之后触发 单位-升级 事件。
----------------------------------------------------------------------------------------------------

---设置升级经验。【服务端】
---例如 base.game:set_level_exp({100, 200, 300}) 表示1升2需要100经验，2升3需要200经验，
---3升4需要300经验，同时 base.game.max_level 会被设置为4。
---@param exps number[] 每级升级所需经验的列表
base.game = base.game or {}
function base.game:set_level_exp(exps) end

----------------------------------------------------------------------------------------------------
-- Unit 单位对象
----------------------------------------------------------------------------------------------------

---单位对象（双端可用；单端方法会标注）
---@class Unit
local Unit = {}

----------------------------------------------------------------------------------------------------
-- 服务端：属性
----------------------------------------------------------------------------------------------------

---增加属性。【服务端】
---基础值增加 value，百分比不变；属性名后加 '%' 表示百分比增加。
---@param state string 单位属性
---@param value number 数值
function Unit:add(state, value) end

---增加属性的特定值。【服务端】
---@param state string 单位属性
---@param value number 数值
---@param value_type integer 单位数值属性类型（0=最终值，1=基础值，2=百分比变化值）
function Unit:add_ex(state, value, value_type) end

---获取属性（实际值）。【双端】
---客户端并不一定能获取到单位的真实属性，这取决于单位是否可见以及该属性的同步方式。
---@param state string 单位属性
---@return number|string value 数值或字符串
function Unit:get(state) end

---获取单位属性的特定值。【服务端】
---@param state string 单位属性
---@param value_type? integer 单位数值属性类型（0=最终值，1=基础值，2=百分比变化值）
---@return number|string value 数值或字符串
function Unit:get_ex(state, value_type) end

---设置属性。【服务端】
---会清除属性的百分比部分。
---注意：单位属性涉及底层同步，属性值大小存在上限，当序列化后的属性大小超过
---1300 * 256 - 50 时会抛出异常提示大小受限，不要一次性设置过大的表属性。
---@param state string 单位属性
---@param value number|string|table 数值或字符串、表（内置属性只能为 number）
function Unit:set(state, value) end

---设置数值属性的特定值。【服务端】
---@param state string 单位属性
---@param value number 数值（内置属性只能为 number）
---@param value_type integer 单位数值属性类型（0=最终值，1=基础值，2=百分比变化值）
function Unit:set_ex(state, value, value_type) end

---获取属性上限。【服务端】
---@param state string 单位属性
---@return number|nil max 上限，若没有上限则返回 nil
function Unit:get_attribute_max(state) end

---获取属性下限。【服务端】
---@param state string 单位属性
---@return number|nil min 下限，若没有下限则返回 nil
function Unit:get_attribute_min(state) end

---设置属性上限。【服务端】
---@param state string 单位属性
---@param value? number 上限值（不填表示移除上限）
function Unit:set_attribute_max(state, value) end

---设置属性下限。【服务端】
---@param state string 单位属性
---@param value? number 下限值（不填表示移除下限）
function Unit:set_attribute_min(state, value) end

---设置属性同步方式。【服务端】
---默认同步方式为 none。
---@param name string 单位属性
---@param sync string 同步方式（如 'all'）
function Unit:set_attribute_sync(name, sync) end

----------------------------------------------------------------------------------------------------
-- 服务端：单位标记
----------------------------------------------------------------------------------------------------

---增加单位标记。【服务端】
---@param type string 单位标记
function Unit:add_mark(type) end

---老 api，和 add_mark 效果一样（单位标记以前叫行为限制）。【服务端】
---@param type string 单位标记
function Unit:add_restriction(type) end

---移除单位标记。【服务端】
---@param type string 单位标记
function Unit:remove_mark(type) end

---老 api，和 remove_mark 效果一样（单位标记以前叫行为限制）。【服务端】
---@param type string 单位标记
function Unit:remove_restriction(type) end

---获取单位标记（行为限制）计数。【服务端】
---@param type string 单位标记
---@return integer count 计数
function Unit:get_mark(type) end

---老 api，和 get_mark 效果一样（单位标记以前叫行为限制）。【服务端】
---@param type string 单位标记
---@return integer count 计数
function Unit:get_restriction(type) end

---是否存在标记。【服务端】
---@param type string 单位标记
---@return boolean result 结果
function Unit:has_mark(type) end

---老 api，和 has_mark 效果一样（单位标记以前叫行为限制）。【服务端】
---@param type string 单位标记
---@return boolean result 结果
function Unit:has_restriction(type) end

----------------------------------------------------------------------------------------------------
-- 服务端：基本信息
----------------------------------------------------------------------------------------------------

---unit 对象可以直接用 print 或 log.info 打印。【服务端】
---@return string
function Unit:__tostring() end

---获取 unit_id。【服务端】
---@return integer unit_id 单位ID
function Unit:get_id() end

---获取单位类别。【双端】
---客户端如果并不知道这个单位的类别是什么，则返回 "未知"。
---@return string class 单位类别（弹道/阻挡/生物）
function Unit:get_class() end

---获取数据。【双端】
---获取这个单位在 UnitData 中对应的数据表，等价于 base.table.unit[unit:get_name()]。
---客户端如果单位名不正确（通常是因为不知道单位名是什么）则会返回 nil。
---@return table data 数据表
function Unit:get_data() end

---获取朝向。【双端】
---服务端：朝向的取值范围为 (-180, 180]。客户端：如果单位不可见，则返回 0.0。
---@return number facing 朝向
function Unit:get_facing() end

---获取高度。【双端】
---服务端：指离地的高度，客户端上的高度表现是离地高度加上地形的高度。
---客户端：如果单位不可见，则返回 0.0。
---@return number height 高度
function Unit:get_height() end

---获取名字。【双端】
---客户端如果并不知道这个单位的名字是什么，则会返回空字符串。
---@return string name 单位名字
function Unit:get_name() end

---获取控制单位的玩家（所有者）。【双端】
---客户端如果并不知道这个单位的所有者是谁，则返回 nil。
---@return Player|nil player 控制单位的玩家
function Unit:get_owner() end

---获取位置。【双端】
---客户端如果单位不可见，则点为 (0.0, 0.0, 0.0)。
---@return Point point 位置
function Unit:get_point() end

---获取单位类型（单位标签）。【双端】
---客户端如果并不知道这个单位的类型是什么，则返回 "未知"。
---@return string type 单位类型
function Unit:get_tag() end

---获取队伍ID。【服务端】
---@return integer team 队伍ID
function Unit:get_team_id() end

---获取坐标。【双端】
---客户端如果单位不可见，则返回 0.0, 0.0。
---@return number x X坐标
---@return number y Y坐标
function Unit:get_xy() end

---获取移动命令。【服务端】
---可以通过该方法了解单位为什么在移动：返回 'walk' 表示只是在移动，'attack' 表示是为了进行攻击，
---技能名表示是为了使用技能，target 为移动目标（如果有的话）。如果不在移动则返回 nil。
---@return string|nil command 命令
---@return any target 目标
function Unit:get_walk_command() end

---获取选取半径。【服务端】
---@return number radius 选取半径
function Unit:get_attackable_radius() end

---设置选取半径。【服务端】
---在使用选取器/搜敌器/计算施法距离等操作时会考虑选取半径。
---@param radius number 选取半径
function Unit:set_attackable_radius(radius) end

---获取单位所在场景名称。【服务端】
---@return string scene_name 单位所在场景
function Unit:get_scene_name() end

---单位跳转场景，如果目标场景不存在，将返回错误。【服务端】
---@param scene_name string 将要跳转的场景
---@return boolean result 跳转成功与否
function Unit:jump_scene(scene_name) end

---获取默认单位的 node_mark，非默认单位的 node_mark 会返回空字符串。【服务端】
---@return string node_mark 单位的 node_mark
function Unit:get_node_mark() end

---设置朝向。【服务端】
---若不填 time 则按照单位转身速度转身，否则按照 time 指定的时间转身，若 time 为 0 则立即转身。
---@param angle number 朝向
---@param time? integer 转身时间（毫秒）
function Unit:set_facing(angle, time) end

---设置高度（离地高度）。【服务端】
---@param height number 高度
function Unit:set_height(height) end

---增加高度（单位距离地面的高度）。【服务端】
---@param height number 高度
function Unit:add_height(height) end

---设置模型。【服务端】
---修改为指定单位的模型。
---@param name string 单位名称
function Unit:set_model(name) end

---设置模型。【服务端】
---修改单位模型为指定资源。
---@param name string 模型表 ActorModelData 里对应的资源名，对应物编里的模型节点名
function Unit:set_asset(name) end

----------------------------------------------------------------------------------------------------
-- 服务端：状态判定
----------------------------------------------------------------------------------------------------

---是否存活。【服务端】
---@return boolean result 是否存活
function Unit:is_alive() end

---是否是友方。【服务端】
---@param dest Unit|Player 目标单位/目标玩家
---@return boolean result 是否是友方
function Unit:is_ally(dest) end

---是否是敌人。【服务端】
---@param dest Unit|Player 目标单位/目标玩家
---@return boolean result 是否是敌人
function Unit:is_enemy(dest) end

---是否是幻象。【服务端】
---@return boolean result 是否是幻象
function Unit:is_illusion() end

---是否在范围内。【服务端】
---会算上自己的选取半径。
---@param target Point|Unit 目标位置
---@param radius number 范围
---@return boolean result 结果
function Unit:is_in_range(target, radius) end

---是否可见。【双端】
---服务端：判断单位能否被 dest 看到，如果 dest 是单位，则会使用控制 dest 的玩家来计算视野。
---客户端：无参数，单位由不可见变为可见时触发 单位-进入视野 事件，
---由可见变为不可见时触发 单位-离开视野 事件。
---@param dest? Unit|Player 单位/玩家（仅服务端）
---@return boolean result 是否可见
function Unit:is_visible(dest) end

---是否在移动。【服务端】
---@return boolean result 结果
function Unit:is_walking() end

----------------------------------------------------------------------------------------------------
-- 服务端：移动 / 传送
----------------------------------------------------------------------------------------------------

---移动。【服务端】
---令单位移动到目标地点。
---@param target Point 目标地点
---@return integer result 寻路结果枚举：0=成功，1=单位死亡，2=不使用jps不能寻路，3=定身标记，
---4=正在释放技能且不可打断，5=空单位，6=单位当前正在等待(碰到别的单位)，
---7=目标在之前的目标点附近（100距离内），8=单位不可见，9=单位walkable为空
function Unit:walk(target) end

---传送。【服务端】
---若目标位置有静态碰撞或动态碰撞且该单位不能无视它，则会将该单位传送至离目标位置最近的合法位置。
---@param target Point 目标位置
---@param is_relative? boolean 是否发送相对的偏移向量给客户端。走 relative 方式的话，
---客户端和服务器的传送偏移量会严格相等，传送前因网络延迟存在的位置偏差传送后依然存在。默认 false
---@return boolean result 是否成功（仅当单位非法时失败）
function Unit:blink(target, is_relative) end

---打断。【服务端】
---打断攻击、施法和移动。
function Unit:stop() end

---打断攻击。【服务端】
function Unit:stop_attack() end

---打断攻击和施法。【服务端】
function Unit:stop_cast() end

---打断施法。【服务端】
function Unit:stop_skill() end

---清空命令队列。【服务端】
function Unit:clean_command() end

---跳到空中，即给 z 轴速度增加一个值。仅 3d 模式下有效，到空中后会受到重力加速度的影响。【服务端】
---@param speed number z轴速度
function Unit:add_z_speed(speed) end

---给 z 轴速度设置一个值。仅 3d 模式下有效，会受到重力加速度的影响。【服务端】
---@param speed number z轴速度
function Unit:set_z_speed(speed) end

---获取 z 轴的当前速度。【服务端】
---@return number speed z轴速度
function Unit:get_z_speed() end

----------------------------------------------------------------------------------------------------
-- 服务端：战斗 / 技能
----------------------------------------------------------------------------------------------------

---攻击。【服务端】
---@param target Unit 攻击目标
---@return boolean valid 是否有效
function Unit:attack(target) end

---是否可以攻击目标。【服务端】
---@param target Unit 目标单位
---@return boolean result 结果
function Unit:can_attack(target) end

---获取攻击技能。【服务端】
---@return Skill attack 当前攻击技能
function Unit:attack_skill() end

---切换攻击技能。【服务端】
---@param name string 攻击技能名称
function Unit:replace_attack(name) end

---杀死。【服务端】
---没有凶手时，凶手视为自己。
---@param killer? Unit 凶手
---@return boolean result 是否成功
function Unit:kill(killer) end

---复活。【服务端】
---触发 单位-复活 事件。
---@param where Point 复活位置
function Unit:reborn(where) end

---使用技能。【双端】
---target 由技能属性决定，如果使用了错误的目标（比如无目标技能却传入了单位作为目标）
---会导致技能使用失败。data 中的数据会被设置到施法中。
---@param name string 技能名
---@param target? Unit|Point|any 目标，具体类型视技能目标类型而定
---@param data? table 自定义数据
---@return boolean valid 是否合法
function Unit:cast(name, target, data) end

---获取当前施放的技能。【服务端】
---获取到的技能是施法。如果当前不在放技能，则返回 nil。
---@return Skill|nil skill 施法
function Unit:current_skill() end

---添加技能。【服务端】
---每个类型的技能格子从0开始，最大为99。指定格子时，这个格子上已经有技能的话会添加失败；
---不指定格子时，会找一个最小的空格。
---@param name string 技能名称
---@param type string 技能类型
---@param slot? integer 技能格子
---@return Skill|nil skill 技能
function Unit:add_skill(name, type, slot) end

---寻找技能。【双端】
---指定 type 后只在此类型中寻找技能。如果 name 使用格子，那么必须要指定 type。
---服务端：除非 include_level_zero 传了 true，否则不会找到 0 级技能。客户端：可以找到 0 级技能。
---@param name string|integer 技能名/格子
---@param type? string 技能类型
---@param include_level_zero? boolean 是否包含0级技能（仅服务端）
---@return Skill|nil skill 技能
function Unit:find_skill(name, type, include_level_zero) end

---遍历技能。【双端】
---如果指定了 type，则会遍历到所有技能类型为 type 的技能；否则遍历到所有技能。
---服务端：指定 type 时不包括 0 级技能，不指定时包括 0 级技能。客户端：总是可以遍历到 0 级技能。
---@param type? string 技能类型
---@return fun():Skill|nil 迭代器，遍历到的技能
function Unit:each_skill(type) end

---切换技能。【服务端】
---旧技能不能是隐藏类型，如果新技能还没在单位上，则会先添加为隐藏类型，再替换。
---@param old string 旧技能
---@param new string 新技能
---@return boolean result 是否成功
function Unit:replace_skill(old, new) end

---学技能。【服务端】
---触发 单位-学习技能 事件。
---@param name string 技能名
function Unit:learn_skill(name) end

----------------------------------------------------------------------------------------------------
-- 服务端：状态（Buff）
----------------------------------------------------------------------------------------------------

---添加状态。【服务端】
---指定生效延迟后，状态会在延迟时间后生效，但会立即返回状态，
---因此可以操作这个还未生效的状态，包括移除它。
---@param name string 状态名称
---@param delay? number 生效延迟（秒）
---@param data? table 状态属性
---@return Buff buff 状态
function Unit:add_buff(name, delay, data) end

---寻找状态。【服务端】
---如果有多个同名状态，则返回其中一个状态。
---@param name string 状态名称
---@return Buff|nil buff 找到的状态
function Unit:find_buff(name) end

---遍历状态。【双端】
---当指定了 name 后只会遍历到该名称的状态，否则遍历所有状态。
---@param name? string 状态名
---@return fun():Buff|nil 迭代器，遍历到的状态
function Unit:each_buff(name) end

---移除状态。【服务端】
---会移除所有该名称的状态。
---@param name string 状态名称
function Unit:remove_buff(name) end

----------------------------------------------------------------------------------------------------
-- 服务端：物品
----------------------------------------------------------------------------------------------------

---添加物品。【服务端】
---如果物品已经在单位身上，或单位物品栏已满，则会添加失败。
---添加成功且物品之前在另一个单位身上，则之前的单位会先失去该物品。
---@param item Item 物品
---@return boolean result 是否成功
function Unit:add_item(item) end

---创建物品。【服务端】
---创建出来的物品所有者为 unit。target 为点时物品创建在地上；为单位时创建在该单位身上
---（物品栏已满则创建在单位所在位置）；为 nil 时创建在自己身上。
---@param name string 物品名
---@param target? Point|Unit 创建位置
---@return Item item 物品
function Unit:create_item(name, target) end

---丢弃物品。【服务端】
---如果物品不在自己身上则会失败。单位会发动“.丢弃物品”技能来尝试靠近丢弃位置然后丢弃物品。
---@param item Item 物品
---@param target Point 丢弃位置
---@return boolean result 是否成功
function Unit:drop_item(item, target) end

---寻找物品。【服务端】
---name 为字符串时寻找单位身上该名称的物品，多个同名物品返回第一个；
---name 为整数时找到物品栏索引为该值的物品。
---@param name string|integer 物品名/物品栏索引
---@return Item|nil item 找到的物品
function Unit:find_item(name) end

---遍历物品。【服务端】
---当指定了 name 后只会遍历到该名称的物品，否则遍历所有物品。
---@param name? string 物品名
---@return fun():Item|nil 迭代器，遍历到的物品
function Unit:each_item(name) end

---把物品交给另一个单位。【服务端】
---如果物品不在自己身上则会失败。单位会发动“.丢弃物品”技能来尝试靠近对方并把物品交给对方。
---如果交给对方时对方物品栏已满，则物品会丢弃到对方所在的位置。
---@param item Item 物品
---@param target Unit 另一个单位
---@return boolean result 是否成功
function Unit:give_item(item, target) end

---拾取物品。【服务端】
---如果物品不在地上，或单位的物品栏已满，则会失败。
---单位会发动“.拾取物品”技能来尝试靠近然后拾取物品。
---@param item Item 物品
---@return boolean result 是否成功
function Unit:pick_item(item) end

----------------------------------------------------------------------------------------------------
-- 服务端：英雄升级 / 能量
----------------------------------------------------------------------------------------------------

---增加经验。【服务端】
---用于英雄升级库。
---@param exp number 经验值
function Unit:add_exp(exp) end

---获取经验。【服务端】
---用于英雄升级库。
---@return number exp 经验
function Unit:get_exp() end

---获取经验上限。【服务端】
---用于英雄升级库。
---@return number exp 经验上限
function Unit:get_max_exp() end

---提升等级。【服务端】
---用于英雄升级库。等级不能降低。
---@param level integer 等级
function Unit:add_level(level) end

---获取等级。【服务端】
---用于英雄升级。
---@return integer level 等级
function Unit:get_level() end

---设置等级。【服务端】
---用于英雄升级库。等级不能降低。
---@param level integer 等级
function Unit:set_level(level) end

---增加能量。【服务端】
---@param type string 能量类型
---@param value number 数值
function Unit:add_resource(type, value) end

---获取能量。【服务端】
---@param type string 能量类型
---@return number value 数值
function Unit:get_resource(type) end

---获取能量类型。【服务端】
---@return string type 能量类型
function Unit:get_resource_type() end

---设置能量。【服务端】
---@param type string 能量类型
---@param value number 数值
function Unit:set_resource(type, value) end

----------------------------------------------------------------------------------------------------
-- 服务端：视野
----------------------------------------------------------------------------------------------------

---提供视野。【服务端】
---令单位的视野提供给指定队伍。
---@param team integer 队伍ID
function Unit:add_provide_sight(team) end

---不提供视野。【服务端】
---令单位的视野不提供给指定队伍。
---@param team integer 队伍ID
function Unit:remove_provide_sight(team) end

---添加可见形状。【服务端】
---例如体型巨大的单位，希望能在它的轮廓进入视野时就能看到它：
---local sight = base.sight_range(unit:get_point(), 500)
---local sight_handle = unit:add_sight(sight)
---不需要时可 sight_handle:remove()。
---@param sight Sight 可见形状
---@return SightHandle|nil sight_handle 可见形状对象
function Unit:add_sight(sight) end

----------------------------------------------------------------------------------------------------
-- 服务端：AI
----------------------------------------------------------------------------------------------------

---添加AI。【服务端】
---@param name string AI名称
---@param data table AI数据
function Unit:add_ai(name, data) end

---禁用AI。【服务端】
---令单位不再执行 AI。
function Unit:disable_ai() end

---启用AI。【服务端】
function Unit:enable_ai() end

---执行AI。【服务端】
function Unit:execute_ai() end

----------------------------------------------------------------------------------------------------
-- 服务端：创建 / 移除
----------------------------------------------------------------------------------------------------

---创建单位。【服务端】
---创建出来的单位属于 unit。name 是字符串时创建名称为 name 的单位；
---name 是单位时复制该单位（目前该行为等同于 create_illusion）。
---单位创建后会最先执行 on_init，可以在这里给单位初始化一些数据。
---创建流程：执行 on_init → 触发 单位-初始化 事件 → 添加技能 → 触发 单位-创建 事件。
---注意：创建单位后在当帧立即在客户端使用该单位的信息可能有问题，详见 单位-初始化 中的描述。
---@param name string|Unit 单位名字/要复制的单位
---@param where Point 创建位置
---@param face number 面朝方向
---@param on_init? fun(new_unit:Unit) 初始化函数
---@return Unit new_unit 单位
function Unit:create_unit(name, where, face, on_init) end

---创建幻象。【服务端】
---镜像复制目标默认为对象自己。复制流程：触发 单位-初始化 事件 → 复制技能 →
---复制单位属性 → 触发 单位-创建 事件。
---@param where Point 创建位置
---@param face number 朝向
---@param dest? Unit 镜像复制目标
---@return Unit|nil illusion 幻象
function Unit:create_illusion(where, face, dest) end

---移除。【服务端】
function Unit:remove() end

----------------------------------------------------------------------------------------------------
-- 服务端：动画 / 表现
----------------------------------------------------------------------------------------------------

---添加动画。【服务端】
---@param name string 动画名称
---@param data? table 动画参数：speed(number 播放速度，默认1.0)、loop(boolean 循环播放，默认false)、
---part(integer 播哪部分动作，0=全身(默认)，1=上半身，2=下半身)、
---blend_in_time(integer 渐入时间ms)、blend_out_time(integer 渐出时间ms)
function Unit:play_animation(name, data) end

---添加动画。同 play_animation，为了兼容才保留的。【服务端】
---@param name string 动画名称
---@param data? table 动画参数，同 play_animation
function Unit:add_animation(name, data) end

---移除动画。【服务端】
---@param name string 动画名称
function Unit:remove_animation(name) end

---漂浮文字（跳字）。【服务端】
---同步方式的参考单位为对象自己。如果看不到跳字也没有报错，可能就是同步类型不对，
---比如用一个你没有视野的单位来跳字，同步类型又传了 self，就会看不到这个跳字。
---@param target Unit 创建位置
---@param text string 文本内容
---@param type string 漂浮文字类型
---@param sync string 同步方式
---@param data? table 属性：r/g/b(integer RGB通道[0,255]，只有“其他”支持)、size(integer 漂浮文字大小，默认10)
function Unit:texttag(target, text, type, sync, data) end

---创建闪电。【服务端】
---@param data table 闪电属性，如 { model = '闪电名称', source = {unit, 'socket_hit'}, target = {point, 100} }
---@return Lightning lightning 闪电
function Unit:lightning(data) end

----------------------------------------------------------------------------------------------------
-- 服务端：运动 / 弹道
----------------------------------------------------------------------------------------------------

---创建弹道捕获器。【服务端】
---@param data table 弹道捕获器属性，如 { radius = 500 }
---@return Capturer capturer 弹道捕获器
function Unit:capturer(data) end

---遍历运动。【服务端】
---@return fun():Mover|nil 迭代器，遍历到的运动
function Unit:each_mover() end

---创建一个跟随当前单位的移动，附加到 mover 上。【服务端】
---附加后 target 会被添加上 幽灵、失控、定身 标记，如果参数里没有 Block 还会被加上 飞行 标记。
---@param data table 跟随属性，如 { source = unit, skill = skill, mover = target }
---@return Mover|nil mover 运动
function Unit:follow(data) end

----------------------------------------------------------------------------------------------------
-- 服务端：事件
----------------------------------------------------------------------------------------------------

---注册事件。【双端】
---这是对 base.event_register 方法的封装。
---@param name string 事件名
---@param callback fun(trigger:Trigger, ...) 事件函数
---@return Trigger trigger 触发器
function Unit:event(name, callback) end

---触发事件。【服务端】
---这是对 base.event_dispatch 方法的封装。
---@param name string 事件名
---@param ... any 自定义数据
function Unit:event_dispatch(name, ...) end

---是否订阅事件。【服务端】
---@param name string 事件名
---@return boolean result 结果
function Unit:event_has(name) end

---触发事件。【双端】
---这是对 base.event_notify 方法的封装。
---@param name string 事件名
---@param ... any 自定义数据
function Unit:event_notify(name, ...) end

---订阅事件。【服务端】
---订阅拥有计数，使用 event 会自动订阅事件。
---@param name string 事件名
function Unit:event_subscribe(name) end

---取消订阅事件。【服务端】
---订阅拥有计数，删除触发器时会自动取消订阅相关事件。
---@param name string 事件名
function Unit:event_unsubscribe(name) end

----------------------------------------------------------------------------------------------------
-- 服务端：计时器
----------------------------------------------------------------------------------------------------

---启动计时器。【服务端】
---count 设置为 0 表示永久循环。只要有可能，就应该使用此方法来启动计时器，而不是使用 base.timer。
---@param timeout integer 周期（毫秒）
---@param count integer 循环次数
---@param on_timer fun(timer:Timer) 回调函数
---@return Timer timer 计时器
function Unit:timer(timeout, count, on_timer) end

---启动循环计时器。【服务端】
---等价于 unit:timer(timeout, 0, on_timer)。只要有可能，就应该使用此方法来启动计时器，而不是使用 base.loop。
---@param timeout integer 周期（毫秒）
---@param on_timer fun(timer:Timer) 回调函数
---@return Timer timer 计时器
function Unit:loop(timeout, on_timer) end

---启动单次计时器。【服务端】
---等价于 unit:timer(timeout, 1, on_timer)。只要有可能，就应该使用此方法来启动计时器，而不是使用 base.wait。
---@param timeout integer 周期（毫秒）
---@param on_timer fun(timer:Timer) 回调函数
---@return Timer timer 计时器
function Unit:wait(timeout, on_timer) end

----------------------------------------------------------------------------------------------------
-- 服务端：附着 / 状态机
----------------------------------------------------------------------------------------------------

---将单位附着在别的单位上。【双端】
---注意该单位的碰撞仍然在原处。
---@param target Unit 目标单位
---@param socket? string 可以不填，或者填 target 上的 socket 名字
function Unit:attach_to(target, socket) end

---创建自定义服务端状态机，如果已经存在就返回存在的状态机。【服务端】
---@param name string 状态机名字，同一个单位上的状态机名字不能重复。
---注意不要使用形如 "skill" 的名字，这些被默认状态机占用了
---@param sync? boolean 是否将状态机同步给客户端，不填默认 false。
---同步的作用是让客户端的单位上创建一个同样结构的状态机来播动画
---@return table sm 状态机 lua 对象
---@return boolean new 是否是新创建的
function Unit:get_or_create_state_machine(name, sync) end

---单位同步状态机到客户端。【服务端】
---一般是服务器状态机建好之后再同步，减少通信成本。状态机名字是唯一 id。
---首先客户端会清理服务端没有的同步状态机（不会清理客户端独有的状态机），
---然后添加服务端同步过来的新状态机，如果客户端已经有同名的，则不处理。
---参见客户端 lua 里 base.event.on_unit_state_machine_changed 的逻辑。
function Unit:sync_state_machines() end

----------------------------------------------------------------------------------------------------
-- 客户端：表现
----------------------------------------------------------------------------------------------------

---获取 socket 位置以及朝向。【客户端】
---@param socketname string socket名字
---@return number x X坐标
---@return number y Y坐标
---@return number z Z坐标
---@return number a Pitch
---@return number b Yaw
---@return number c Roll
function Unit:get_socket_point(socketname) end

---附加模型。【客户端】
---@param path string 模型 prefab 文件所在目录
---@param hand_point? string 模型附加到的关节/绑点名，如果没有或者没找到会挂到单位原点
---@param hold_point? string 模型附加后 hand_point 相对于模型原点的位置、旋转、缩放，
---prefab 文件里存在 basic_info 的 sockets 里
function Unit:attach_model(path, hand_point, hold_point) end

---移除附加模型。【客户端】
---@param path string 模型 prefab 文件所在目录
function Unit:detach_model(path) end

---改变单位的模型。【客户端】
---@param path string 模型 prefab 所在目录
function Unit:change_model(path) end

---获取是否高亮。【客户端】
---@return boolean on_or_off 是否高亮
function Unit:get_highlight() end

---设置高亮。【客户端】
---@param on boolean 开或者关
---@param data? table 高亮参数：color_r/color_g/color_b/color_a(颜色通道)、time(持续时间，填0表示永久生效)
function Unit:set_highlight(on, data) end

---获取遮挡显示是否可用。【客户端】
---@return boolean enable 是否可用
function Unit:get_xray_enable() end

---设置遮挡显示是否可用。【客户端】
---@param on boolean 开或者关
function Unit:set_xray_enable(on) end
