---@meta

-- ============================================================================
-- SCE base 库：数学 / 表工具 / 几何 / 计时器 / UI 辅助 等基础 API
-- ----------------------------------------------------------------------------
-- 覆盖 client_base 的 script/common/base 目录下以下文件中的 base.* 成员：
--   math.lua                  -> base.math.*（数学函数，角度制三角函数等）
--   utility.lua               -> base.hash / base.get_appendable_enum 等
--   table.lua                 -> base.table / base.skill_table 等数编表接口
--   array.lua                 -> base.array（带默认值的自增数组）
--   area.lua                  -> base.get_scene_area / base.is_point_in_area 等
--   obj_check.lua             -> base.gui_* / base.fade_*（UI 检查与淡入淡出）
--   point.lua                 -> base.point / base.table_to_point 等
--   line.lua                  -> base.line / base.get_scene_line
--   circle.lua                -> base.circle
--   rect.lua                  -> base.rect
--   margin.lua                -> base.margin
--   collision_flags.lua       -> base.collision_flags
--   timer.lua                 -> base.wait / base.next / base.timer / base.loop 等
--   单位组.lua                 -> base.单位组 / base.create_unit_group 等
--   init.lua                  -> base.error / base.callback_info
--   base_lua_plus/point.lua   -> base.point_angle / base.point_move 等
--   base_lua_plus/timer.lua   -> base.timer_wait / base.timer_loop 等（秒级封装）
--   base_lua_plus/global_variable.lua -> base.any_* 哨兵值 / base.table_new
-- 注：base_lua_plus 与主目录同名函数已去重；Point/Line/Timer 等全局类在
--     base_class.d.lua 中声明，此处仅收集 base.* 成员。
-- ============================================================================

-- ============================================================================
-- math.lua：base.math.* 数学函数（三角函数为角度制）
-- ============================================================================

---正弦（角度制）
---@param r number 角度
---@return number
function base.math.sin(r) end

---余弦（角度制）
---@param r number 角度
---@return number
function base.math.cos(r) end

---正切（角度制）
---@param r number 角度
---@return number
function base.math.tan(r) end

---反正弦，返回角度制的角度
---@param v number
---@return number
function base.math.asin(v) end

---反余弦，返回角度制的角度
---@param v number
---@return number
function base.math.acos(v) end

---反正切，返回角度制的角度
---@param v1 number y 分量
---@param v2 number x 分量
---@return number
function base.math.atan(v1, v2) end

---向上取整
---@param v number
---@return integer
function base.math.ceil(v) end

---向下取整
---@param v number
---@return integer
function base.math.floor(v) end

---浮点数相等比较（误差 1e-5 内视为相等）
---@param a number
---@param b number
---@return boolean
function base.math.float_eq(a, b) end

---浮点数不等比较（误差超过 1e-5 视为不等）
---@param a number
---@param b number
---@return boolean
function base.math.float_ueq(a, b) end

---浮点数小于比较（带 1e-5 误差容忍）
---@param a number
---@param b number
---@return boolean
function base.math.float_lt(a, b) end

---浮点数小于等于比较（带 1e-5 误差容忍）
---@param a number
---@param b number
---@return boolean
function base.math.float_le(a, b) end

---浮点数大于比较（带 1e-5 误差容忍）
---@param a number
---@param b number
---@return boolean
function base.math.float_gt(a, b) end

---浮点数大于等于比较（带 1e-5 误差容忍）
---@param a number
---@param b number
---@return boolean
function base.math.float_ge(a, b) end

---取 [a, b] 区间内的随机浮点数
---@param a number
---@param b number
---@return number
function base.math.random_float(a, b) end

---判断一个数是否为整数
---@param n number
---@return boolean
function base.math.is_int(n) end

---取 [a, b] 区间内的随机整数（参数非数字时返回 nil）
---@param a number
---@param b number
---@return integer?
function base.math.random_int(a, b) end

---取浮点数的小数部分（编辑器用）
---@param n number
---@return number
function base.math.float_modf(n) end

---计算两个角度之间的夹角
---@param r1 number 角度1
---@param r2 number 角度2
---@return number angle 夹角（0~180）
---@return integer dir 方向（1 或 -1）
function base.math.included_angle(r1, r2) end

---插值运算，t 超出 [0, 1] 时钳制到端点
---@param from number
---@param to number
---@param t number 插值系数（0~1）
---@return number
function base.math.lerp(from, to, t) end

---将值钳制在 [left, right] 区间内（left > right 时自动交换）
---@param value number
---@param left number
---@param right number
---@return number
function base.math.clamp(value, left, right) end

---取最大值
---@vararg number
---@return number
function base.math.max(...) end

---取最小值
---@vararg number
---@return number
function base.math.min(...) end

---三维向量相加，返回 {X, Y, Z}
---@param vector1 table 向量（含 X/Y/Z 字段）
---@param vector2 table 向量（含 X/Y/Z 字段）
---@return table
function base.math.vector_add(vector1, vector2) end

---三维向量相减，返回 {X, Y, Z}
---@param vector1 table 向量（含 X/Y/Z 字段）
---@param vector2 table 向量（含 X/Y/Z 字段）
---@return table
function base.math.vector_sub(vector1, vector2) end

---三维向量数乘，返回 {X, Y, Z}
---@param vector table 向量（含 X/Y/Z 字段）
---@param mul number 倍数
---@return table
function base.math.vector_mul(vector, mul) end

---三维向量点积
---@param vector1 table 向量（含 X/Y/Z 字段）
---@param vector2 table 向量（含 X/Y/Z 字段）
---@return number
function base.math.dot_product(vector1, vector2) end

---三维向量叉积，返回 {X, Y, Z}
---@param vector1 table 向量（含 X/Y/Z 字段）
---@param vector2 table 向量（含 X/Y/Z 字段）
---@return table
function base.math.cross_product(vector1, vector2) end

---平方根
---@param x number
---@return number
function base.math.sqrt(x) end

---对数
---@vararg number
---@return number
function base.math.log(...) end

---次幂（x ^ y）
---@param x number
---@param y number
---@return number
function base.math.pow(x, y) end

---平方
---@param x number
---@return number
function base.math.square(x) end

---自然指数（e^x）
---@param x number
---@return number
function base.math.exp(x) end

---绝对值
---@param x number
---@return number
function base.math.abs(x) end

-- ============================================================================
-- utility.lua：杂项工具
-- ============================================================================

---对字符串计算 djb33 哈希值
---@param str string 输入字符串
---@return integer hash 哈希值
function base.hash(str) end

---读取数编中可追加枚举（AppendableEnum），返回 {枚举值 = 序号} 映射
---@param key string 枚举名
---@return table
function base.get_appendable_enum(key) end

---读取数编中可追加键（AppendableKeys），返回 {键值 = 序号} 映射
---@param key string 键名
---@return table
function base.get_appendable_keys(key) end

-- ============================================================================
-- table.lua：数编表访问
-- ============================================================================

---数编表入口（按名字懒加载数编数据，如 base.table.unit / base.table.skill /
---base.table.buff / base.table.item / base.table.actor 等）
---@type table<string, table>
base.table = base.table or {}

---读取技能数编中指定等级的字段值
---@param name string 技能名
---@param level integer 等级
---@param key string 字段名
---@return any
function base.skill_table(name, level, key) end

---读取单位数编字段；key 为字符串取单字段，为数组时逐级索引
---@param name string 单位名
---@param key string|string[] 字段名或字段路径
---@return any
function base.unit_table(name, key) end

---读取 Buff 数编字段
---@param name string Buff 名
---@param key string 字段名
---@return any
function base.buff_table(name, key) end

---读取普攻（CommonSpellData）数编字段；key 为字符串取单字段，为数组时逐级索引
---@param name string 普攻名
---@param key string|string[] 字段名或字段路径
---@return any
function base.attack_table(name, key) end

---读取物品数编字段
---@param name string 物品名
---@param key string 字段名
---@return any
function base.item_table(name, key) end

---读取客户端技能（ClientSpell）数编字段
---@param name string 技能名
---@param key string 字段名
---@return any
function base.spell_table(name, key) end

-- ============================================================================
-- array.lua：带默认值与长度维护的数组
-- ============================================================================

---创建自增数组：越界读索引（>0）时自动以默认值填充并扩展长度。
---返回的表附带 ipairs / set_len / insert / remove / random / convert 方法。
---@param default any 默认值（可为函数，取值时调用）
---@param t? table 初始数组
---@return table
function base.array(default, t) end

-- ============================================================================
-- area.lua：区域相关
-- ============================================================================

---获取地编区域
---@param scene string 场景名
---@param area_type string 区域类型（如 'circle' / 'rect'）
---@param area_name string 区域名
---@param present table 地编数据表
---@return any area 区域对象（圆形或矩形区域）
function base.get_scene_area(scene, area_type, area_name, present) end

---按玩家与单位类型筛选区域内的单位，返回单位组
---@param area any 区域对象（圆形/矩形区域）
---@param player any 玩家对象（base.any_player 表示任意玩家）
---@param unit_id_name any 单位类型名（base.any_unit_id 表示任意单位）
---@param target_filter_string any 目标筛选器（字符串或表）
---@return any 单位组
function base.get_area_player_type_unit_group(area, player, unit_id_name, target_filter_string) end

---获取区域内的所有单位（自动识别圆形/矩形区域）
---@param area any 区域对象（圆形/矩形区域）
---@return any[] 单位数组
function base.get_area_unit(area) end

---获取圆形区域内的所有单位
---@param circle any 圆形区域对象
---@return any[] 单位数组
function base.get_circle_area_unit(circle) end

---获取矩形区域内的所有单位
---@param rect any 矩形区域对象
---@return any[] 单位数组
function base.get_rect_area_unit(rect) end

---获取场景的整个区域（当前固定返回 '1'）
---@return any
function base.get_scene_scale_area() end

---判断单位是否在区域内
---@param unit any 单位对象
---@param area any 区域对象（圆形/矩形区域）
---@return boolean
function base.is_unit_in_area(unit, area) end

---判断点是否在圆形区域内
---@param point any 点对象（Point）
---@param circle any 圆形区域对象
---@return boolean
function base.is_point_in_circle(point, circle) end

---判断点是否在矩形区域内
---@param point any 点对象（Point）
---@param rect any 矩形区域对象
---@return boolean
function base.is_point_in_rect(point, rect) end

---判断点是否在区域内（自动识别圆形/矩形区域）
---@param point any 点对象（Point）
---@param area any 区域对象（圆形/矩形区域）
---@return boolean
function base.is_point_in_area(point, area) end

-- ============================================================================
-- obj_check.lua：UI 控件检查 / 部件获取 / 屏幕淡入淡出
-- ============================================================================

---检查参数是否为有效的 UI 控件
---@param cmpt any UI 控件对象
---@return boolean
function base.gui_check(cmpt) end

---获取组件部件并按 TS 类型转换（供 TS 侧调用）
---@param ts_type any TS 类型标识
---@param cmpt any UI 控件对象
---@param part_name string 部件名
---@return any
function base.gui_get_part_as(ts_type, cmpt, part_name) end

---获取组件上指定名字的部件（供 TS 侧调用）
---@param ts_type any TS 类型标识
---@param cmpt any UI 控件对象
---@param part_name string 部件名
---@return any
function base.gui_get_parts_ts(ts_type, cmpt, part_name) end

---获取数组组件的子项模板控件（供 TS 侧调用）
---@param ts_type any TS 类型标识
---@param cmpt any UI 控件对象
---@return any
function base.gui_get_array_child(ts_type, cmpt) end

---按名字获取子 UI 并按 TS 类型转换（供 TS 侧调用）
---@param ts_type any TS 类型标识
---@param cmpt any UI 控件对象
---@param child_name string 子控件名
---@return any
function base.gui_get_child_ui_by_name_as(ts_type, cmpt, child_name) end

---获取控件的所有子控件
---@param ctrl any UI 控件对象
---@return any
function base.gui_get_children(ctrl) end

---获取控件的矩形区域，返回 {x, y, w, h}
---@param ctrl any UI 控件对象
---@return table?
function base.gui_get_rect(ctrl) end

---获取控件的父控件
---@param ctrl any UI 控件对象
---@return any
function base.gui_get_parent(ctrl) end

---屏幕淡入或淡出（fade_type 为 'fade_in' 或 'fade_out'）
---@param fade_type string 淡入淡出类型（'fade_in' / 'fade_out'）
---@param fade_time number 渐变时间（秒）
---@param is_wait boolean 是否阻塞等待渐变完成
---@param color? string 颜色，形如 '0, 0, 0'
---@param opacity? number 不透明度（0~100）
---@param curve_type? string 过渡曲线，默认 'linear'
---@param z_index? number 层级，默认 9999
function base.fade_in_out(fade_type, fade_time, is_wait, color, opacity, curve_type, z_index) end

---屏幕淡入（出现一层遮罩）
---@param fade_time number 渐变时间（秒）
---@param is_wait boolean 是否阻塞等待渐变完成
---@param color? string 颜色，形如 '0, 0, 0'
---@param opacity? number 不透明度（0~100）
---@param curve_type? string 过渡曲线，默认 'linear'
---@param z_index? number 层级，默认 9999
function base.fade_in(fade_time, is_wait, color, opacity, curve_type, z_index) end

---屏幕淡出（移除遮罩）；未淡入过时返回 false
---@param fade_time number 渐变时间（秒）
---@param is_wait boolean 是否阻塞等待渐变完成
---@param color? string 颜色，形如 '0, 0, 0'
---@param opacity? number 不透明度（0~100）
---@param curve_type? string 过渡曲线，默认 'linear'
---@param z_index? number 层级，默认 9999
---@return boolean?
function base.fade_out(fade_time, is_wait, color, opacity, curve_type, z_index) end

-- ============================================================================
-- point.lua / line.lua / circle.lua / rect.lua / margin.lua：几何对象构造
-- ============================================================================

---创建一个点
---	base.point(x, y, z)
---@param x number
---@param y number
---@param z number
---@param scene string?
---@return any point 点对象（Point）
function base.point(x, y, z, scene) end

---将形如 {x, y, ...} 的表转换为点；前两个元素不是数字时返回 nil
---@param table table
---@return any? point 点对象（Point），转换失败返回 nil
function base.table_to_point(table) end

---获取地编点
---@param scene string 场景名
---@param area_name string 点名
---@param present table 地编数据表
---@return any? point 点对象（Point）
function base.get_scene_point(scene, area_name, present) end

---由点数组创建一条线
---@param points any[] 点对象（Point）数组
---@return any line 线对象（Line）
function base.line(points) end

---获取地编线
---@param scene string 场景名
---@param area_name string 线名
---@param present table 地编数据表
---@return any line 线对象（Line）
function base.get_scene_line(scene, area_name, present) end

---创建圆形区域
---@param point any 圆心点（Point）
---@param range number 半径
---@param scene_name? string 场景名（缺省取点的场景或 'default'）
---@return any circle 圆形区域对象
function base.circle(point, range, scene_name) end

---创建矩形区域。
---两种用法：base.rect(点1, 点2 [, 场景名]) 或 base.rect(中心点, 宽, 高 [, 场景名])
---@vararg any
---@return any rect 矩形区域对象
function base.rect(...) end

---客户端空实现（逻辑全在服务端）
---@vararg any
function base.margin(...) end

---创建碰撞标记对象，可用 contains(flag) 判断是否包含某类碰撞、
---each_collision(callback) 遍历为真的碰撞类型
---@param mask integer 碰撞位掩码
---@return any collision_flags 碰撞标记对象
function base.collision_flags(mask) end

-- ============================================================================
-- timer.lua：计时器 / 帧回调
-- ============================================================================

---获取当前逻辑时钟（当前帧计数）
---@return number
function base.clock() end

---协程式等待：timeout 后执行一次 on_timer 回调。
---内部实现按帧调度（inner 调试分支多一个 timer 参数，对外接口一致）。
---@param timeout number 超时时间（秒，浮点数）
---@param on_timer fun() 结束时回调
---@return any timer 计时器对象（Timer）
function base.wait(timeout, on_timer) end

---创建循环计时器，每隔 timeout 执行一次 on_timer（周期不能小于一帧）
---@param timeout number
---@param on_timer fun()
---@return any timer 计时器对象（Timer）
function base.loop(timeout, on_timer) end

---创建惰性循环计时器：帧数被跳过时不会追帧补偿
---@param timeout number 周期
---@param on_timer fun() 每次触发回调
---@return any timer 计时器对象（Timer）
function base.loop_lazy(timeout, on_timer) end

---下一帧执行回调（实际在第 2 帧触发）
---@param cb fun() 回调函数
function base.next(cb) end

---创建计时器：每隔 timeout 执行 on_timer，共执行 count 次；
---count 为 0 时等价于 base.loop 无限循环
---@param timeout number 周期
---@param count integer 执行次数（0 表示无限循环）
---@param on_timer fun() 每次触发回调
---@return any timer 计时器对象（Timer）
function base.timer(timeout, count, on_timer) end

---在单位上挂接一次性等待计时器（单位移除时统一清理）
---@param u any 单位对象
---@param timeout number 超时时间
---@param on_timer fun() 结束时回调
---@return any timer 计时器对象（Timer）
function base.uwait(u, timeout, on_timer) end

---在单位上挂接循环计时器（单位移除时统一清理）
---@param u any 单位对象
---@param timeout number 周期
---@param on_timer fun() 每次触发回调
---@return any timer 计时器对象（Timer）
function base.uloop(u, timeout, on_timer) end

---在单位上挂接计次计时器（单位移除时统一清理）
---@param u any 单位对象
---@param timeout number 周期
---@param count integer 执行次数
---@param on_timer fun() 每次触发回调
---@return any timer 计时器对象（Timer）
function base.utimer(u, timeout, count, on_timer) end

---设置计时器单帧耗时告警阈值（毫秒）
---@param w number 阈值（毫秒）
function base.set_timer_warning(w) end

---获取计时器内部调试信息（计时器队列与时钟记录）
---@return table
function base.timer_info() end

---逻辑帧回调入口（由引擎每帧驱动，delta 为帧数）
---@param delta number 流逝帧数
function base.event.on_tick(delta) end

---更新回调入口（由引擎驱动，delta 为秒）
---@param delta number 流逝时间（秒）
function base.event.on_update(delta) end

---后更新回调入口（由引擎驱动）
---@param delta number 流逝时间（秒）
function base.event.on_post_update(delta) end

---预渲染更新回调入口（由引擎驱动）
---@param delta number 流逝时间（秒）
function base.event.on_prerender_update(delta) end

---服务器时钟同步回调入口（由引擎驱动）
---@param clock number 服务器时钟
function base.event.on_server_clock(clock) end

-- ============================================================================
-- 单位组.lua：单位组
-- ============================================================================

---创建单位组
---@param 单位数组? any[] 初始单位数组
---@return any 单位组
function base.单位组(单位数组) end

---创建单位组（支持传单个单位或单位数组）
---@param units any 单位对象或单位数组
---@return any 单位组
function base.create_unit_group(units) end

---从单位组中随机取一个单位（空组返回 nil）
---@param ug any 单位组
---@return any unit 单位对象
function base.unit_group_random_unit(ug) end

---从单位组中随机取 cnt 个不重复单位组成新单位组；
---cnt 不小于组大小时返回整组的拷贝
---@param ug any 单位组
---@param cnt integer 数量
---@return any 单位组
function base.unit_group_random_units(ug, cnt) end

---遍历单位组，回调返回真值时中断遍历。
---回调形如 fun(self, element_1, element_2)，element_2 为下一个元素（可能为 nil）
---@param ug any 单位组
---@param callbackfn fun(self: any, element_1: any, element_2: any): boolean? 遍历回调
function base.unit_group_forEachEx(ug, callbackfn) end

-- ============================================================================
-- init.lua：错误处理 / 回调统计
-- ============================================================================

---base 错误处理入口（记录日志并触发断点）
---@param err any 错误信息
---@vararg any 附加信息
function base.error(err, ...) end

---获取回调统计信息，返回 {callback = 回调次数}
---@return table
function base.callback_info() end

-- ============================================================================
-- base_lua_plus/point.lua：点 / 线的便捷操作（编辑器触发器用）
-- ============================================================================

---两点连线的角度
---@param point any 点1（Point）
---@param target any 点2（Point）
---@return number
function base.point_angle(point, target) end

---复制点
---@param point any 点（Point）
---@return any point 新点对象（Point）
function base.point_copy(point) end

---两点间的距离
---@param point any 点1（Point）
---@param target any 点2（Point）
---@return number
function base.point_distance(point, target) end

---点的 X 坐标
---@param point any 点（Point）
---@return number
function base.point_get_x(point) end

---点的 Y 坐标
---@param point any 点（Point）
---@return number
function base.point_get_y(point) end

---点的碰撞类型检测：是否存在"有标记 prevent_bits 且没有标记 required_bits"的碰撞
---@param point any 点（Point）
---@param prevent_bits integer 碰撞标记位 1
---@param required_bits integer 碰撞标记位 2
---@return boolean
function base.point_is_block2(point, prevent_bits, required_bits) end

---点沿指定角度移动指定距离后的新点（极坐标偏移）
---@param point any 点（Point）
---@param angle number 角度
---@param distance number 距离
---@return any point 移动后的新点（Point）
function base.point_move(point, angle, distance) end

---线上的第 index 个点
---@param line any 线对象（Line）
---@param index integer 位置
---@return any point 点对象（Point）
function base.line_get(line, index) end

---两点间的通行路径，返回由途经点组成的线；无法寻路时返回 nil
---@param st any 起点（Point）
---@param ed any 终点（Point）
---@return any line 线对象（Line）
function base.pathing_way_points(st, ed) end

-- ============================================================================
-- base_lua_plus/timer.lua：秒级计时器封装（编辑器触发器用）
-- ============================================================================

---每隔一段时间循环执行动作
---@param time number 周期（秒）
---@param func fun() 每次执行的动作
---@return any timer 计时器对象（Timer）
function base.timer_loop(time, func) end

---每隔一段时间循环执行动作（惰性循环，不追帧补偿）
---@param time number 周期（秒）
---@param func fun() 每次执行的动作
---@return any timer 计时器对象（Timer）
function base.timer_loop_lazy(time, func) end

---等待一段时间后执行动作
---@param time number 等待时间（秒）
---@param func fun() 到时执行的动作
---@return any timer 计时器对象（Timer）
function base.timer_wait(time, func) end

---每隔一段时间执行动作，共执行 times 次
---@param time number 周期（秒）
---@param times integer 执行次数
---@param func fun() 每次执行的动作
---@return any timer 计时器对象（Timer）
function base.timer_timer(time, times, func) end

---移除计时器
---@param timer any 计时器对象（Timer）
function base.timer_remove(timer) end

---计时器剩余的秒数
---@param timer any 计时器对象（Timer）
---@return integer
function base.remaining(timer) end

---等待一段时间（协程睡眠）
---@param time number 等待时间（秒）
---@return any
function base.timer_sleep(time) end

-- ============================================================================
-- base_lua_plus/global_variable.lua：任意对象哨兵值 / 空表
-- ============================================================================

---任意单位（哨兵值，用于触发器筛选）
---@type any
base.any_unit = nil

---任意单位类型（哨兵值，用于触发器筛选）
---@type any
base.any_unit_id = nil

---任意玩家（哨兵值，用于触发器筛选）
---@type any
base.any_player = nil

---任意技能（哨兵值，用于触发器筛选）
---@type any
base.any_skill = nil

---任意效果参数（哨兵值，用于触发器筛选）
---@type any
base.any_eff_param = nil

---任意运动器（哨兵值，用于触发器筛选）
---@type any
base.any_mover = nil

---任意物品（哨兵值，用于触发器筛选）
---@type any
base.any_item = nil

---创建一个空表
---@return table
function base.table_new() end
