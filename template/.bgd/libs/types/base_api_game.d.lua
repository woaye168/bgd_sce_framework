---@meta

----------------------------------------------------------------------------------------------------
-- SCE 引擎 base 库 - 游戏主流程 API 类型声明
-- 覆盖范围：键盘/鼠标/手柄输入、场景管理、镜头控制、选单位搜索、对局流程、屏幕分辨率、
--           地形纹理、选择英雄、游戏设置、好友、技能指示器（建造）等
-- 来源文件：
--   script/common/base/game.lua
--   script/common/base/scene.lua
--   script/common/base/terrain.lua
--   script/common/base/screen.lua
--   script/common/base/position.lua
--   script/common/base/startup.lua
--   script/common/base/select_hero.lua
--   script/common/base/game_result.lua
--   script/common/base/friend.lua
--   script/common/base/settings.lua
--   script/common/base/spell_assist_control.lua
--   script/common/base/base_lua_plus/game.lua
--   script/common/base/base_lua_plus/lobby.lua
--   script/common/base/base_lua_plus/localization.lua
----------------------------------------------------------------------------------------------------

------------------------------ 命名空间父表 ------------------------------

---游戏主事件对象
base.game = {}

---引擎底层事件回调命名空间
base.event = {}

---服务器消息协议处理命名空间
base.proto = {}

---好友相关接口
base.friend = {}

---地形相关接口
base.terrain = {}

---屏幕/分辨率相关接口
base.screen = {}

---启动流程相关接口
base.startup = {}

---选择英雄相关接口
base.select_hero = {}

---游戏设置相关接口
base.settings = {}

------------------------------ base 成员表 ------------------------------

---默认地编单位缓存（按节点标记索引）
---@type table<string, table>
base.__default_unit_cache = {}

---等待默认地编单位返回的协程列表
---@type table<string, thread[]>
base.__default_unit_co = {}

---场景事件注册表（内部使用）
---@type table<string, table>
base._scene = {}

---三维动态碰撞信息表 [layer][x][y]
---@type table<integer, table<integer, table<integer, boolean>>>
base.collision_info = {}

---玩法自定义单位属性格式化表
---@type table<string, any>|nil
base.gameplay_custom_attribute_format = nil

------------------------------ 场景 ------------------------------

---根据场景名哈希值获取场景名
---@param hash integer 场景名哈希值
---@return string 场景名
function base.get_scene_name_by_hash(hash) end

---根据场景名获取哈希值
---@param name string 场景名
---@return integer 场景名哈希值
function base.get_scene_hash_by_name(name) end

---获取同步下来的自定义游戏属性
---@param key string 属性名
---@return any 属性值
function base.get_game_attribute(key) end

---将指定场景加载到缓存
---@param scene string 场景名
function base.load_map_to_cache(scene) end

---从缓存中删除指定场景
---@param scene string 场景名
function base.purge_map_from_cache(scene) end

------------------------------ 对局流程与杂项 ------------------------------

---获取当前帧率
---@return number 当前FPS
function base.get_current_fps() end

---获取当前网络延迟
---@return number 当前ping值
function base.get_current_ping() end

---设置是否使用右键移动
---@param use boolean 是否启用
function base.set_use_right_click_move(use) end

---获取是否使用右键移动
---@return boolean 是否启用
function base.get_use_right_click_move() end

---获取屏幕坐标点射线命中的单位；未命中时返回地面世界坐标
---@param x number 屏幕坐标X
---@param y number 屏幕坐标Y
---@return table 结果表，含 unit（单位对象）或 x/y/z 世界坐标
function base.raycast_unit_at_screen_xy(x, y) end

---获取矩形区域内的所有单位
---@param point any 区域中心点（点对象）
---@param width number 矩形长度
---@param height number 矩形宽度
---@param face number|nil 朝向角度（度），默认0
---@return any[] 单位对象数组
function base.get_units_from_rect(point, width, height, face) end

---获取扇形区域内的所有单位
---@param point any 扇形圆心（点对象）
---@param radius number 半径
---@param arc number 扇形角度（度）
---@param face number 朝向角度（度）
---@return any[] 单位对象数组
function base.get_units_from_sector(point, radius, arc, face) end

---数编所有物品，返回物品链接列表
---@return table 物品链接字符串数组
function base.get_obj_items() end

---获取所有技能ID
---@return table 技能ID数组
function base.get_all_skills_id() end

---获取所有buff表ID
---@return table buff ID数组
function base.get_all_buffs_id() end

---获取所有单位ID
---@return table 单位ID数组
function base.get_all_units_id() end

---创建游戏桌面快捷方式
function base.game_shortcut() end

---Lua table 的浅拷贝
---@param tbl table 源表
---@return table 拷贝后的新表
function base.shallow_copy(tbl) end

---设置自定义鼠标指针样式
---@param path string 指针资源路径
function base.set_cursor_shape(path) end

---恢复使用系统默认鼠标指针
function base.use_system_cursor() end

---获取指定世界坐标的地面高度
---@param x number 世界坐标X
---@param y number 世界坐标Y
---@param bool boolean 是否包含水面等额外处理
---@return number 地面高度Z
function base.get_ground_z(x, y, bool) end

---获取指定点处的地面高度
---@param point any 点对象
---@param bool boolean 是否包含水面等额外处理
---@return number 地面高度Z
function base.get_ground_z_from_point(point, bool) end

---获取当前运行平台标识
---@return string 平台标识，如 'win'/'web'/'wx_android' 等
function base.get_platform() end

---当前平台是否为App
---@return boolean 是否为App
function base.get_platform_is_app() end

---通过url协议启动指定地图的游戏
---@param map_name string 地图名
---@param is_to_test boolean|nil 是否以测试模式启动
function base.start_game(map_name, is_to_test) end

---退出游戏（返回大厅）
---@param show_confirm boolean 是否显示确认框
function base.game_exit(show_confirm) end

---获取鼠标在屏幕上的坐标X
---@param touch_id integer|nil 触摸点ID（移动端多触点）
---@return number 屏幕坐标X
function base.game_get_mouse_pos_x(touch_id) end

---获取鼠标在屏幕上的坐标Y
---@param touch_id integer|nil 触摸点ID（移动端多触点）
---@return number 屏幕坐标Y
function base.game_get_mouse_pos_y(touch_id) end

---通过屏幕坐标XY获取对应的场景坐标点
---@param screen_x number 屏幕坐标X
---@param screen_y number 屏幕坐标Y
---@return any 场景点对象
function base.game_screen_to_world(screen_x, screen_y) end

---场景坐标对应的屏幕坐标X
---@param point any 场景点对象
---@return number 屏幕坐标X
function base.game_world_to_screen_x(point) end

---场景坐标对应的屏幕坐标Y
---@param point any 场景点对象
---@return number 屏幕坐标Y
function base.game_world_to_screen_y(point) end

---获取画面分辨率宽度
---@return integer 分辨率宽度
function base.game_get_resolution_width() end

---获取画面分辨率高度
---@return integer 分辨率高度
function base.game_get_resolution_height() end

---设置画面分辨率
---@param width integer 宽度
---@param height integer 高度
function base.game_set_resolution(width, height) end

---获取屏幕方向（横屏/竖屏）
---@return string 屏幕方向
function base.game_get_orientation() end

---以本地玩家身份向服务端发送消息
---@param msg string 消息内容
function base.client_send_message(msg) end

---切换到指定光照组
---@param path string 光照组资源相对路径
---@param time number 混合时间（秒）
function base.use_light_group(path, time) end

---获取当前场景名
---@return string 当前场景名
function base.get_current_scene() end

---获取游戏模式（自定义游戏属性 GameMode）
---@return string 游戏模式，未设置时为空字符串
function base.get_gamemode_key() end

------------------------------ 大厅相关（base_lua_plus/lobby） ------------------------------

---打开指定玩家的个人资料面板
---@param player any 玩家对象
function base.open_friend_info_page(player) end

---返回游戏大厅
function base.return_to_lobby() end

------------------------------ 本地化（base_lua_plus/localization） ------------------------------

---设置客户端语言
---@param language string 语言标识
function base.set_language(language) end

---获取客户端当前语言
---@return string 语言标识
function base.get_language() end

---获取指定ID的本地化文本
---@param id string 文本ID
---@return string 本地化文本
function base.get_text(id) end

------------------------------ 屏幕坐标点（position.lua） ------------------------------

---获取鼠标当前屏幕坐标点对象
---@return any 屏幕坐标点对象（ScreenPos）
function base.mouse_screen_pos() end

---创建屏幕坐标点对象
---@param x number 屏幕坐标X
---@param y number 屏幕坐标Y
---@return any 屏幕坐标点对象（ScreenPos）
function base.position(x, y) end

---创建屏幕坐标点对象
---@param x number 屏幕坐标X
---@param y number 屏幕坐标Y
---@return any 屏幕坐标点对象（ScreenPos）
function base.screen_pos(x, y) end

------------------------------ 建造技能指示器（spell_assist_control.lua） ------------------------------

---建造技能指示器逆时针旋转90度
function base.set_spellbuild_spin_counterclockwise() end

---建造技能指示器顺时针旋转90度
function base.set_spellbuild_spin_clockwise() end

---获取建造技能指示器当前旋转角度
---@return number 旋转角度（度，0/90/180/270）
function base.get_spellbuild_spin() end

------------------------------ base.game 方法 ------------------------------

---返回游戏实例的字符串描述
---@return string 描述字符串
function base.game:__tostring() end

---获取游戏热键配置表
---@return table 热键配置表
function base.game:hotkey() end

---查询指定按键当前是否处于按下状态
---@param key string 按键名
---@return boolean 是否按下
function base.game:key_state(key) end

---获取本地玩家当前选中的单位
---@return any|nil 单位对象
function base.game:selected_unit() end

---发送聊天消息
---@param type string 消息对象类型：'全体' 或 '队伍'
---@param msg string 消息内容
function base.game:chat(type, msg) end

---获取游戏内显示的对局时间（带符号）
---@return number 对局时间
function base.game:show_timer() end

---设置当前游戏场景
---@vararg any 场景参数
---@return any 设置结果
function base.game:set_game_scene(...) end

---获取当前场景名
---@return string 当前场景名
function base.game:get_current_scene() end

---锁定镜头
function base.game:lock_camera() end

---解锁镜头
function base.game:unlock_camera() end

---在指定时间内渐变设置镜头属性
---@param key string 镜头属性名
---@param value any 目标值
---@param time number 过渡时间（秒）
function base.game:set_camera_attribute(key, value, time) end

---获取鼠标所指的世界坐标点
---@return any 点对象
function base.game:input_mouse() end

---获取加载剩余时间
---@return number 剩余秒数，不小于0
function base.game:loading_left() end

---选中指定单位（单位需可见）
---@param unit any 单位对象
function base.game:select_unit(unit) end

---圆形范围搜索单位（只能搜索当前场景）
---@param pos any 圆心点对象（需含场景标识）
---@param radius number 半径
---@param tag string|string[]|nil 单位标签过滤，可为单个标签或标签数组
---@param ignore_center_pos boolean|nil 是否忽略中心点高度，默认true
---@return any[] 单位对象数组
function base.game:circle_selector(pos, radius, tag, ignore_center_pos) end

---矩形（线段）范围搜索单位（只能搜索当前场景）
---@param pos any 起点点对象（需含场景标识）
---@param length number 长度
---@param width number 宽度
---@param face any 朝向点对象（方向向量）
---@param tag string|string[]|nil 单位标签过滤
---@return any[] 单位对象数组
function base.game:line_selector(pos, length, width, face, tag) end

---扇形范围搜索单位（只能搜索当前场景）
---@param pos any 圆心点对象（需含场景标识）
---@param radius number 半径
---@param degree number 扇形角度（度）
---@param face any 朝向点对象（方向向量）
---@param tag string|string[]|nil 单位标签过滤
---@return any[] 单位对象数组
function base.game:sector_selector(pos, radius, degree, face, tag) end

---获取胜利玩家的槽位ID
---@return integer|nil 胜利者玩家槽位ID
function base.game:get_winner() end

---获取胜利方队伍对象
---@return any 队伍对象
function base.game:get_winner_team() end

---向所有客户端发送广播（参数会被json打包）
---@vararg any 广播参数
function base.game:send_broadcast(...) end

---镜头聚焦到指定单位
---@param unit any|nil 单位对象，nil时取消聚焦
function base.game:camera_focus(unit) end

---被踢出游戏时的处理（弹窗提示并退出到大厅）
---@param msg string|nil 踢出原因提示
function base.game:on_kick(msg) end

---客户端从服务器获取默认地编单位（只能在协程中使用，会挂起等待返回）
---@param node_mark string 节点标记
---@return any|nil 单位对象
function base.game.get_default_unit(node_mark) end

---在对象上存储自定义键值（写入对象的 __hashtable）
---@param object table 目标对象
---@param key string 键名
---@param value any 值
function base.game.object_store_value(object, key, value) end

---读取对象上存储的自定义键值
---@param object table 目标对象
---@param key string 键名
---@return any 存储的值
function base.game.object_restore_value(object, key) end

---创建调试绘制表现对象
---@return any|nil 调试绘制表现对象（Actor）
function base.game.create_debug_draw_actor() end

---调试绘制点
---@param actor any 调试绘制表现对象
---@param point any 点对象
---@param color string 颜色
function base.game.debug_draw_point(actor, point, color) end

---调试绘制圆
---@param actor any 调试绘制表现对象
---@param point any 圆心点对象
---@param euler_alpha number 欧拉角alpha
---@param euler_beta number 欧拉角beta
---@param euler_gamma number 欧拉角gamma
---@param radius number 半径
---@param color string 颜色
---@param solid boolean 是否实心
function base.game.debug_draw_circle(actor, point, euler_alpha, euler_beta, euler_gamma, radius, color, solid) end

---调试绘制线段
---@param actor any 调试绘制表现对象
---@param s_point any 起点点对象
---@param e_point any 终点点对象
---@param color string 颜色
function base.game.debug_draw_line(actor, s_point, e_point, color) end

---调试绘制扇形
---@param actor any 调试绘制表现对象
---@param point any 圆心点对象
---@param euler_alpha number 欧拉角alpha
---@param euler_beta number 欧拉角beta
---@param euler_gamma number 欧拉角gamma
---@param radius number 半径
---@param angle number 扇形角度
---@param color string 颜色
---@param solid boolean 是否实心
function base.game.debug_draw_sector(actor, point, euler_alpha, euler_beta, euler_gamma, radius, angle, color, solid) end

---调试绘制文字
---@param actor any 调试绘制表现对象
---@param point any 点对象
---@param text string 文字内容
---@param color string 颜色
---@param displayTop boolean 是否置顶显示
function base.game.debug_draw_text(actor, point, text, color, displayTop) end

---调试绘制矩形
---@param actor any 调试绘制表现对象
---@param v_point any 顶点点对象
---@param w_point any 宽度方向点对象
---@param h_point any 高度方向点对象
---@param color string 颜色
---@param solid boolean 是否实心
function base.game.debug_draw_rectangle(actor, v_point, w_point, h_point, color, solid) end

---清除指定调试绘制表现对象上的所有绘制
---@param actor any 调试绘制表现对象
function base.game.clear_debug_draws(actor) end

---加载拼接场景
---@param scene string 场景名
---@param direction string 拼接方向
function base.game.load_combined_map(scene, direction) end

---释放拼接场景
function base.game.purge_combined_map() end

---创建拼接场景通行模型
---@param scene string 场景名
---@param direction string 拼接方向
function base.game.load_combined_map_deco(scene, direction) end

---释放拼接场景通行模型
function base.game.purge_combined_map_deco() end

---先将场景加载到缓存，再进行拼接
---@param scene string 场景名
---@param direction string 拼接方向
function base.game.load_scene_cache_and_combined(scene, direction) end

---获取模型动画挂点信息（给触发器用的API）
---@param model_path string 模型路径
---@param anim_name string 动画名
---@return any|nil 动画挂点信息对象
function base.game.get_model_anim_point_info(model_path, anim_name) end

---设置是否启用动态点光源（会同时保存到设置项）
---@param val boolean 是否启用
function base.game.set_dynamic_point_light(val) end

---请求服务器再来一局
function base.game.one_more_round() end

------------------------------ base.proto 服务器协议处理 ------------------------------

---处理服务器跳转场景请求，转发'场景-请求切换'事件
---@param msg table 消息表，含 old_scene/new_scene
function base.proto.__server_jump_scene(msg) end

---默认的游戏结束表现（播放胜利/失败特效并显示结束界面）
---@param data table 数据表，含 result 字段（'win' 为胜利）
function base.proto.default_game_result(data) end

---大厅通知游戏退出
---@param data table 数据表，含 show_confirm 字段
function base.proto.lobby_game_exit(data) end

---处理"再来一局"请求，向所有客户端广播
---@param data table 数据表
function base.proto.__one_more_round(data) end

---服务器下发好友列表，分发'好友-初始化好友列表'事件
---@param data table 好友列表数据
function base.proto.InGame_S2C_init_friend_list(data) end

---服务器下发好友申请列表，分发'好友-初始化好友申请列表'事件
---@param data table 好友申请列表数据
function base.proto.InGame_S2C_init_friend_apply_list(data) end

---服务器通知好友申请列表状态变化，分发'好友-申请列表状态变化'事件
---@param data table 状态变化数据
function base.proto.InGame_S2C_notice_friend_state(data) end

---服务器通知添加好友失败，分发'好友-添加好友失败'事件
---@param data table 失败数据
function base.proto.InGame_S2C_friend_apply_fail(data) end

------------------------------ base.friend 好友接口 ------------------------------

---发送添加好友申请（不能添加自己）
---@param user_id integer|string 目标用户ID
function base.friend.send_add_friend(user_id) end

---同意好友申请
---@param user_id integer|string 目标用户ID
function base.friend.send_agree_add(user_id) end

---拒绝好友申请
---@param user_id integer|string 目标用户ID
function base.friend.send_refuse_add(user_id) end

------------------------------ base.terrain 地形接口 ------------------------------

---获取指定坐标处的地形纹理名
---@param x number 世界坐标X
---@param y number 世界坐标Y
---@return string 纹理名
function base.terrain:get_texture_name(x, y) end

---获取指定坐标处的地形纹理标签
---@param x number 世界坐标X
---@param y number 世界坐标Y
---@return string 纹理标签
function base.terrain:get_texture_tag(x, y) end

---获取指定坐标处的地形纹理信息
---@param x number 世界坐标X
---@param y number 世界坐标Y
---@return string 纹理名
---@return string 纹理标签
function base.terrain:get_texture_info(x, y) end

------------------------------ base.screen 屏幕接口 ------------------------------

---获取屏幕方向（横屏/竖屏）
---@return string 屏幕方向
function base.screen:get_orientation() end

---获取画面分辨率
---@return integer 宽度
---@return integer 高度
function base.screen:get_resolution() end

---设置画面分辨率（移动端设置逻辑分辨率）
---@param width integer 宽度
---@param height integer 高度
function base.screen:set_resolution(width, height) end

---获取刘海屏高度（已废弃）
---@return number 刘海高度
function base.screen:get_bangs_height() end

---获取鼠标（或指定触摸点）的屏幕坐标点对象
---@param touch_id integer|nil 触摸点ID，范围1~62
---@return any 屏幕坐标点对象
function base.screen:input_mouse(touch_id) end

---设置鼠标指针是否可见
---@param visible boolean 是否可见
function base.screen:set_cursor_visible(visible) end

---获取屏幕安全区内边距
---@return table 含 left/top/right/bottom 的内边距表
function base.screen:get_safe_insets() end

---启用/禁用安全区适配（会调整主布局边距）
---@param enable boolean 是否启用
function base.screen:enable_safe_area(enable) end

------------------------------ base.startup 启动流程接口 ------------------------------

---注册"游戏即将进入前台"的确认回调
---@param callback fun(confirm:function, cancel:function) 回调函数，需调用 confirm 或 cancel
function base.startup.register_pre_enter_foreground_callback(callback) end

---注册启动检测模块（用于装备图自动弹窗流程）
---@param check_is_startup fun():boolean 检测是否为启动弹窗模块
---@param startup_dialog fun(next:function) 弹出启动界面，完成后调用 next
function base.startup.register_startup_function(check_is_startup, startup_dialog) end

------------------------------ base.select_hero 选择英雄接口 ------------------------------

---获取可选英雄列表
---@return any 英雄名列表（base.array）
function base.select_hero:hero_list() end

---选择指定英雄
---@param name string 英雄单位数编名
function base.select_hero:select_hero(name) end

---点击（预览）指定英雄
---@param name string 英雄单位数编名
function base.select_hero:click_hero(name) end

---点击随机英雄
function base.select_hero:click_random_hero() end

---获取选择英雄剩余时间
---@return number 剩余秒数
function base.select_hero:show_timer() end

---展示指定英雄（预留接口，当前无实现）
---@param name string 英雄单位数编名
---@param distance number 镜头距离
---@param offset number 偏移
---@param height number 高度
function base.select_hero:show_hero(name, distance, offset, height) end

---是否显示随机英雄选项
---@return boolean 是否显示
function base.select_hero:show_random() end

------------------------------ base.settings 游戏设置接口 ------------------------------

---获取设置项的值
---@param key string 设置项名
---@return any 设置项值
function base.settings:get_option(key) end

---保存全局设置项（跨游戏生效）
---@param key string 设置项名
---@param para string|number|boolean 设置项值
function base.settings:save_global_option(key, para) end

---保存设置项
---@param key string 设置项名
---@param para string|number|boolean 设置项值
function base.settings:save_option(key, para) end

---设置设置项（不持久化保存）
---@param key string 设置项名
---@param para string|number|boolean 设置项值
function base.settings:set_option(key, para) end

---设置设置项的默认值
---@param key string 设置项名
---@param para string|number|boolean 默认值
function base.settings:set_default_option(key, para) end

---注册设置项并绑定变化回调
---@param name string 设置项名
---@param func fun(val:any) 设置项变化时的回调
function base.settings:register_option(name, func) end

---设置当前游戏标识（用于设置项按游戏隔离）
---@param current_game string 当前游戏标识
function base.settings:set_current_game(current_game) end

---获取当前游戏标识
---@return string|nil 当前游戏标识
function base.settings:get_current_game() end

------------------------------ base.event 引擎事件回调（game.lua） ------------------------------

---技能施放结果消息回调，转发'消息-技能'事件
---@param msg any 消息内容
function base.event.on_spell_cast_result(msg) end

---错误提示消息回调，转发'消息-错误'事件
---@param msg any 消息内容
---@param time number 显示时长（毫秒）
function base.event.on_error_tip(msg, time) end

---系统消息回调，按类型转发'消息-公告'/'消息-聊天'/'消息-错误'事件
---@param msg any 消息内容
---@param type integer 消息类型（1公告 2聊天 3错误）
---@param time number 显示时长（毫秒）
function base.event.on_system_message(msg, type, time) end

---聊天消息通知回调，转发'消息-聊天'事件
---@param player_slot_id integer 玩家槽位ID
---@param type integer 消息类型
---@param msg any 消息内容
---@param time number 显示时长
function base.event.on_notify_chat_message(player_slot_id, type, msg, time) end

---单位被点击回调，处理本地选中单位逻辑并转发'单位-点击'等事件
---@param id integer|nil 单位ID，nil表示取消选中
function base.event.on_unit_clicked(id) end

---技能指示器控制回调，转发'技能指示器-控制'事件
---@param control boolean 显示/隐藏指示器
---@param spell_id integer 技能ID哈希
---@param type integer 指示器类型
---@param shape integer 形状类型
---@param range number 施法范围
---@param width number 宽度
---@param plane_range number 平面范围
---@param id integer 技能实例ID
function base.event.on_control_spell_assist(control, spell_id, type, shape, range, width, plane_range, id) end

---技能指示器更新回调，转发'技能指示器-更新'事件
---@param spell_id integer 技能ID哈希
---@param time number 当前时间
---@param id integer 技能实例ID
function base.event.on_spell_assist_update(spell_id, time, id) end

---游戏即将进入前台回调，转发'游戏即将进入前台'事件（携带确认/取消回调）
function base.event.on_game_will_enter_foreground() end

---游戏进入前台回调，转发'游戏进入前台'事件
function base.event.on_game_enter_foreground() end

---游戏进入后台回调，转发'游戏进入后台'事件
function base.event.on_game_enter_background() end

---游戏内点击回调，转发'游戏-点击'事件
---@param screen_pos any 屏幕坐标
---@param actorsID any 点击到的表现ID
---@param button integer 鼠标按键
function base.event.on_click(screen_pos, actorsID, button) end

---按键按下回调，转发'按键-按下'事件并同步服务器
---@param unkey string 引擎原始按键名
function base.event.on_key_down(unkey) end

---按键松开回调，转发'按键-松开'事件并同步服务器
---@param unkey string 引擎原始按键名
function base.event.on_key_up(unkey) end

---鼠标按下回调，转发'鼠标-按下'事件并同步服务器
---@param button_type integer 鼠标按键类型
function base.event.on_mouse_down(button_type) end

---鼠标松开回调，转发'鼠标-松开'事件并同步服务器
---@param button_type integer 鼠标按键类型
function base.event.on_mouse_up(button_type) end

---鼠标移动回调，转发'鼠标-移动'事件
function base.event.on_mouse_move() end

---滚轮滚动回调，转发'滚轮-移动'事件并同步服务器
---@param delta_wheel number 滚轮滚动量
function base.event.on_wheel_move(delta_wheel) end

---手柄按键按下回调，转发'手柄-按键按下'事件
---@param button_name string 手柄按键名
function base.event.on_joystick_button_down(button_name) end

---手柄按键松开回调，转发'手柄-按键松开'事件
---@param button_name string 手柄按键名
function base.event.on_joystick_button_up(button_name) end

---手柄摇杆/扳机移动回调，转发'手柄-摇杆'/'手柄-扳机'事件
---@param axis_name string 轴名（LeftX/LeftY/RightX/RightY/TriggerLeft/TriggerRight）
---@param position number 轴位置值
function base.event.on_joystick_axis_move(axis_name, position) end

---手柄十字键状态变化回调，转发'手柄-十字键'事件
---@param state integer 十字键状态位掩码
function base.event.on_joystick_hat_move(state) end

---开始加载回调，记录加载截止时间
---@param time number 加载时限（秒）
function base.event.on_start_loading(time) end

---进入游戏回调，转发'游戏-初始化'/'游戏-开始'事件
function base.event.on_enter_game() end

---录像播放停止回调，按参数上传日志或退出
function base.event.on_replay_stopped() end

---游戏结果回调，记录胜利者并转发'游戏-结束'事件
---@param json string 游戏结果json字符串
function base.event.on_game_result(json) end

---场景加载回调，转发'场景-加载'事件
---@param scene_name string 场景名
function base.event.on_load_scene(scene_name) end

---场景加载完成回调，转发'场景-加载完成'事件
---@param scene_name string 场景名
function base.event.on_load_scene_over(scene_name) end

---联合场景区域通知回调，转发'联合场景-跨越区域/进入区域/离开区域/区域通知'事件
---@vararg any 依次为 from_scene, from_dir, to_scene, to_dir
function base.event.on_combined_scene_area_notify(...) end

---游戏设置变化回调，清空热键缓存并转发'游戏-设置变化'事件
function base.event.on_game_setting_changed() end

---创建漂浮文字失败回调，输出警告日志
---@param riselettertype integer 漂浮文字类型
---@param templatename string 模板名
function base.event.on_create_riseletter_failed(riselettertype, templatename) end

---游戏开始加载回调，转发'加载地图'事件
---@vararg any 依次为 map_name, map_kind, session_id, background_loading
function base.event.on_game_start(...) end

---游戏加载进度回调，转发'加载地图进度'事件
---@param content string 加载内容描述
---@param percent number 进度百分比
function base.event.on_game_loading(content, percent) end

---游戏加载完成回调，转发'加载地图完成'事件
---@vararg any 依次为 map_name, map_kind, session_id, background_loading
function base.event.on_game_started(...) end

---游戏退出回调，处理语音房间退出并转发'卸载地图'事件
---@param map_name string 地图名
---@param map_kind integer 地图类型
---@param session_id string 会话ID
---@vararg any 其他参数
function base.event.on_game_exit(map_name, map_kind, session_id, ...) end

---游戏踢人回调，转发'游戏踢人'事件
---@vararg any 踢人相关参数
function base.event.on_game_kick(...) end

---游戏重连回调，转发'游戏重连'事件
---@vararg any 重连相关参数
function base.event.on_game_reconnected(...) end

---url启动游戏回调，转发'url启动游戏'事件
---@param map_name string 地图名
function base.event.on_url_launch(map_name) end

---监测文件夹变化回调，转发'file_changed'事件
---@param file_path string 文件路径
---@param file_name string 文件名
---@param change_list any 变化列表
function base.event.on_file_changed(file_path, file_name, change_list) end

---收到广播回调，解包json后转发'广播'事件
---@param args string 广播json字符串
function base.event.on_broadcast(args) end

---自定义游戏属性同步回调，转发'游戏-属性变化'事件
---@param key string 属性名
---@param value any 属性值
function base.event.on_sync_custom_game_attribute(key, value) end

---表现事件回调，转发'表现-音效事件'/'表现-动画事件开始/结束'事件
---@param actor_id integer 表现ID
---@param msg string 事件消息
---@param anim string 动画名，空串表示音效事件
---@param start boolean 动画事件是否为开始
function base.event.on_actor_event(actor_id, msg, anim, start) end

---游戏时间暂停回调，转发'游戏-时间暂停'事件
function base.event.on_game_time_pause() end

---游戏时间继续回调，转发'游戏-时间继续'事件
function base.event.on_game_time_resume() end

---表现销毁回调，释放对应表现对象
---@param actor_id integer 表现ID
function base.event.on_actor_destroy(actor_id) end

---调试作弊码回调，转发'玩家-输入作弊码'事件
---@param cheat_codes string 作弊码
function base.event.on_debug_cheat(cheat_codes) end

---表现动画播放结束回调，转发'表现-动画结束'事件
---@param actor_id integer 表现ID
---@param anim string 动画名
---@param operation any 操作参数
function base.event.on_actor_finish_animation(actor_id, anim, operation) end

---单位动画播放结束回调，转发'单位-动画结束'事件
---@param unit_id integer 单位ID
---@param anim string 动画名
---@param operation any 操作参数
function base.event.on_unit_finish_animation(unit_id, anim, operation) end

---同步单位自定义属性配置回调，注册属性键
---@param attribute_config table 属性配置表（键为属性key，值为属性名）
function base.event.on_game_sync_unit_attribute_config(attribute_config) end

------------------------------ base.event 引擎事件回调（screen.lua） ------------------------------

---屏幕分辨率变化回调，转发'画面-分辨率变化'事件
---@param w integer 宽度
---@param h integer 高度
function base.event.on_screen_resolution_changed(w, h) end

---屏幕朝向变化回调，自动纠正分辨率并转发'画面-分辨率变化'事件
---@param orientation string 屏幕朝向（'Portrait' 竖屏等）
function base.event.on_orientation_changed(orientation) end

------------------------------ base.event 引擎事件回调（select_hero.lua） ------------------------------

---选择英雄开始通知回调，初始化可选英雄列表并转发'游戏-选择英雄'事件
---@param json string 选择英雄信息json字符串
function base.event.on_hero_pick_start_notify(json) end

---玩家点击英雄通知回调，转发'选择英雄-点击'事件
---@param slot_id integer 玩家槽位ID
---@param hero_id integer 英雄ID
function base.event.on_select_hero_click_hero_notify(slot_id, hero_id) end

---玩家选择英雄通知回调，转发'选择英雄-选择'事件
---@param slot_id integer 玩家槽位ID
---@param hero_id integer 英雄ID
function base.event.on_select_hero_pick_notify(slot_id, hero_id) end

---所有玩家确认选择英雄通知回调，转发'游戏-选择英雄完成'事件
---@param time number 剩余确认时间（秒）
function base.event.on_select_hero_pick_all_confirmed_notify(time) end

------------------------------ base.event 引擎事件回调（settings.lua） ------------------------------

---设置项变化回调，调用注册的变化处理函数
---@param pressed string 变化的设置项名
---@param val any 新值
function base.event.on_settings_changed(pressed, val) end
