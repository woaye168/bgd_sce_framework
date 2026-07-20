---@meta

------------------------------------------------------------------------------
-- SCE 引擎 Lua API 类型声明：表现（Actor）/ 镜头（Camera）/ 动画（Anim）/ UI
--
-- 覆盖来源文件：
--   script/common/base/actor.lua
--   script/common/base/camera.lua
--   script/common/base/anim_handlers.lua
--   script/common/base/base_lua_plus/actor.lua
--   script/common/base/base_lua_plus/camera.lua
--   script/common/base/base_lua_plus/gui.lua
--   script/common/base/base_lua_plus/indicator.lua
--   script/common/base/ui/bind.lua
--   script/common/base/ui/ui.lua
--   script/common/base/ui/event.lua
--   script/common/base/ui/control/virtual_joystick_template.lua
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- 表现（Actor）
------------------------------------------------------------------------------

---将表现对象注册到 id -> actor 的映射表中
---@param actor any 表现对象
function base.set_actor_map(actor) end

---设置表现模式（是否允许通过屏幕坐标拾取表现）。开启后 actor_map 使用强引用
---@param allow_ray_cast boolean 是否允许屏幕射线拾取
function base.set_actor_mode(allow_ray_cast) end

---开启单位高亮（颜色分量 0~255，未传默认为 0）
---@param unit any 单位对象
---@param r number 红色分量（0~255）
---@param g number 绿色分量（0~255）
---@param b number 蓝色分量（0~255）
---@param a number 透明度分量（0~255）
---@param time number 持续时间（秒）
function base.set_unit_highlight_on(unit, r, g, b, a, time) end

---关闭单位高亮
---@param unit any 单位对象
function base.set_unit_highlight_off(unit) end

---创建表现对象。可携带服务端 id（避免重复创建）并跳过出生表现
---@param name string 表现名（数编链接）
---@param sid number|nil 服务端表现 id（服务端 rpc 创建时传入）
---@param skip_birth boolean|nil 是否跳过出生表现
---@param scene string|nil 场景名，非当前场景时不创建
---@return any actor 创建的表现对象，失败返回 nil
function base.actor(name, sid, skip_birth, scene) end

---根据客户端表现 id 获取表现对象
---@param id number 表现 id
---@return any actor 表现对象
function base.actor_from_id(id) end

---根据服务端表现 id 获取客户端表现对象
---@param id number 服务端表现 id
---@return any actor 表现对象
function base.actor_from_sid(id) end

---获取表现映射信息（客户端 id 映射与服务端 id 映射）
---@return table info { actor_map, server_actor_map }
function base.actor_info() end

---根据客户端表现 id 获取表现对象（同 base.actor_from_id）
---@param id number 表现 id
---@return any actor 表现对象
function base.get_actor_from_id(id) end

---根据服务端表现 id 获取客户端表现对象（同 base.actor_from_sid）
---@param id number 服务端表现 id
---@return any actor 表现对象
function base.get_actor_from_sid(id) end

---获取屏幕坐标下的所有表现（需先用 base.set_actor_mode 开启拾取模式）
---@param xy number[] 屏幕坐标 {x, y}
---@return any[] actors 表现对象数组
function base.get_actors_from_screen_xy(xy) end

---创建并播放 2D 音效表现
---@param link string 音效表现名（数编链接）
---@return any actor 音效表现对象
function base.play_sound_effect(link) end

---创建闪电/光束表现，连接发射源与目标
---@param link string 光束表现名（数编链接）
---@param source any 发射源（单位 Unit 或点 Point 对象）
---@param target any 发射目标（单位 Unit 或点 Point 对象）
---@return any actor 光束表现对象
function base.create_beam_effect(link, source, target) end

---获取触发器最后创建的表现
---@return any actor 最后创建的表现对象
function base.get_last_created_actor() end

---设置粒子特效表现创建过滤级别，低于该等级的特效将不再创建
---@param level number 过滤级别
function base.set_actor_creation_filter_level(level) end

---在指定位置创建表现
---@param name string 表现名（表现类型）
---@param point any 位置点对象
---@return any actor 创建的表现对象
function base.create_actor_at(name, point) end

---将表现移动到指定点
---@param actor any 表现对象
---@param point any 目标点对象
function base.actor_set_position(actor, point) end

---设置表现的朝向
---@param actor any 表现对象
---@param angle number 角度值
function base.actor_set_facting(actor, angle) end

---将表现附着到单位的附着点处
---@param actor any 表现对象
---@param host any 宿主单位对象
---@param socket string|nil 绑点名
function base.actor_attach_to_unit(actor, host, socket) end

---将表现附着到另一个表现的附着点处
---@param actor any 表现对象
---@param host any 宿主表现对象
---@param socket string|nil 绑点名
function base.actor_attach_to_actor(actor, host, socket) end

---摧毁表现
---@param actor any 表现对象
---@param flag boolean|nil 是否强制摧毁（否则等待死亡动画结束）
function base.actor_destroy(actor, flag) end

---替换表现的模型资源（仅对模型和粒子表现有效）
---@param actor any 表现对象
---@param asset string 新模型资源
function base.actor_set_asset_model(actor, asset) end

---替换表现的音效资源（仅对音效表现有效）
---@param actor any 表现对象
---@param asset string 新音效资源
function base.actor_set_asset_sound(actor, asset) end

---设置表现所属玩家
---@param actor any 表现对象
---@param owner number 新玩家号
function base.actor_set_owner(actor, owner) end

---设置表现是否显示影子（仅限模型表现）
---@param actor any 表现对象
---@param enable boolean 是否显示影子
function base.actor_set_shadow(actor, enable) end

---设置表现缩放（仅限模型和粒子表现）
---@param actor any 表现对象
---@param scale number 缩放值
function base.actor_set_scale(actor, scale) end

---播放表现（仅限音效和粒子表现）
---@param actor any 表现对象
function base.actor_play(actor) end

---停止播放表现（仅限音效和粒子表现）
---@param actor any 表现对象
function base.actor_stop(actor) end

---暂停表现（仅限音效表现）
---@param actor any 表现对象
function base.actor_pause(actor) end

---继续播放被暂停的表现（仅限音效表现）
---@param actor any 表现对象
function base.actor_resume(actor) end

---设置表现音量（仅限音效表现）
---@param actor any 表现对象
---@param volume number 音量
function base.actor_set_volume(actor, volume) end

---设置网格物体的网格大小（仅限网格表现）
---@param actor any 网格表现对象
---@param size_x number X轴大小
---@param size_y number|nil Y轴大小（未设置同X轴）
function base.actor_set_grid_size(actor, size_x, size_y) end

---设置网格物体的原点偏移和网格范围（仅限网格表现）
---@param actor any 网格表现对象
---@param start_x number X轴偏移
---@param start_y number Y轴偏移
---@param range_x number X轴范围
---@param range_y number Y轴范围
function base.actor_set_grid_range(actor, start_x, start_y, range_x, range_y) end

---设置网格表现中子网格的状态（仅限网格表现）
---@param actor any 网格表现对象
---@param id_x number 子网格X轴坐标
---@param id_y number 子网格Y轴坐标
---@param state number 状态
function base.actor_set_grid_state(actor, id_x, id_y, state) end

---设置表现地面相对高度
---@param actor any 表现对象
---@param height number 地面相对高度
function base.actor_set_grount_height(actor, height) end

---模型表现播放一次动画
---@param actor any 模型表现对象
---@param anim string 动画名
---@param time number 时间因子
---@param time_type number 时间因子类型
---@param start_offset number 起始播放时间
---@param blend_time number 过渡时间（秒）
---@param priority number 优先级
function base.actor_anim_play(actor, anim, time, time_type, start_offset, blend_time, priority) end

---暂停/恢复模型表现的所有动画（新API）
---@param actor any 模型表现对象
---@param paused boolean 暂停与否
function base.actor_anim_set_paused_all(actor, paused) end

---设置模型表现相对播放时间倍数（只影响新API的动画）
---@param actor any 模型表现对象
---@param time_scale number 相对播放时间倍数
function base.actor_set_time_scale_global(actor, time_scale) end

---设置模型表现的 BSD（birth-stand-death）动画
---@param actor any 模型表现对象
---@param anim_birth string birth动画
---@param anim_stand string stand动画
---@param anim_death string death动画
---@param force_one_shot boolean 强制播放一次
---@param kill_on_finish boolean 结束后销毁
---@param priority number 优先级
function base.actor_anim_play_bracket(actor, anim_birth, anim_stand, anim_death, force_one_shot, kill_on_finish, priority) end

---获取表现/单位的父对象（可能是表现或单位）
---@param obj any 表现或单位对象
---@return any parent 父对象（表现或单位）
function base.actor_get_parent(obj) end

---设置表现的动画名映射（单个映射）
---@param obj any 表现对象
---@param name_from string 原动画名
---@param name_to string 目标动画名
---@return any r 设置结果
function base.actor_set_anim_mapping(obj, name_from, name_to) end

---设置表现的动画名映射（映射表）
---@param obj any 表现对象
---@param name_map table 动画名映射表
---@return any r 设置结果
function base.actor_set_anim_mapping_map(obj, name_map) end

------------------------------------------------------------------------------
-- 镜头（Camera）
------------------------------------------------------------------------------

---获取当前镜头的数编链接名
---@return string link 镜头链接名
function base.get_camera_link() end

---获取当前活动镜头对象
---@return any camera 镜头对象
function base.camera() end

---设定相机视角跟随单位
---@param unit any 单位对象
function base.camera_focus(unit) end

---锁定相机视角
function base.camera_lock() end

---解锁相机视角
function base.camera_unlock() end

---判断相机视角是否锁定
---@return boolean locked 是否锁定
function base.camera_is_locked() end

---设置相机属性
---@param key string 属性名
---@param value any 属性值
---@param time number 过渡时间（秒）
function base.set_camera_attribute(key, value, time) end

------------------------------------------------------------------------------
-- 动画（Anim，新API句柄）
------------------------------------------------------------------------------

---获取动画句柄映射表（id -> 动画句柄）
---@return table map 动画句柄映射表
function base.get_anim_map() end

---获取 BSD 动画句柄映射表（id -> BSD 动画句柄）
---@return table map BSD 动画句柄映射表
function base.get_anim_bracket_map() end

---创建动画句柄（新API），并登记到动画映射表
---@param anim_name string 动画名
---@param owner_type string 宿主类型（'actor' 或 'unit'）
---@param owner_id number 宿主 id
---@param owner_name string 宿主名（表现名）
---@param params table 参数表 { id, time, time_type, blend_time, start_offset, priority }
---@return any anim 动画句柄对象
function base.anim(anim_name, owner_type, owner_id, owner_name, params) end

---创建 BSD（birth-stand-death）动画句柄，并登记到 BSD 动画映射表
---@param anim_birth string birth动画
---@param anim_stand string stand动画
---@param anim_death string death动画
---@param params table 参数表 { id, force_one_shot, kill_on_finish, sync, priority }
---@param owner_type string 宿主类型（'actor' 或 'unit'）
---@param owner_id number 宿主 id
---@param owner_name string 宿主名（表现名）
---@return any anim BSD 动画句柄对象
function base.bracket_anim(anim_birth, anim_stand, anim_death, params, owner_type, owner_id, owner_name) end

------------------------------------------------------------------------------
-- 选中指示器
------------------------------------------------------------------------------

---启用选中指示器
function base.enable_select_indicator() end

---禁用选中指示器（并销毁已创建的指示器）
function base.disable_select_indicator() end

------------------------------------------------------------------------------
-- UI（控件/页面）
------------------------------------------------------------------------------

---新建页面实例
---@param name string 页面名
---@return any cmpt 页面控件实例，失败返回 nil
function base.gui_new(name) end

---新建组件实例（依赖库中的组件）
---@param name string 组件类型名
---@return any cmpt 组件实例，失败返回 nil
function base.gui_new_component(name) end

---销毁 UI 控件实例
---@param cmpt any 控件对象
---@return boolean success 是否销毁成功
function base.gui_destory(cmpt) end

---批量设置控件属性（属性名支持点分层级，如 'layout.relative'）
---@param ctrl any 控件对象
---@param prop_table table 属性名 -> 属性值 的表
function base.gui_set_prop(ctrl, prop_table) end

---设置控件单个属性
---@param ctrl any 控件对象
---@param prop_name string 属性名
---@param prop_value any 属性值
---@return any r 设置结果
function base.gui_set_prop2(ctrl, prop_name, prop_value) end

---获取控件属性（属性名支持点分层级）
---@param ctrl any 控件对象
---@param prop_name string 属性名
---@return any value 属性值
function base.gui_get_prop(ctrl, prop_name) end

---获取组件的部件（part）控件
---@param cmpt any 组件实例
---@param part_name string 部件名
---@return any ctrl 部件控件对象
function base.gui_get_part(cmpt, part_name) end

---按名字获取组件的子控件
---@param cmpt any 组件实例
---@param child_name string 子控件名
---@return any ctrl 子控件对象
function base.gui_get_child_ui_by_name(cmpt, child_name) end

---获取主页面控件实例
---@return any cmpt 主页面控件实例
function base.gui_get_main_page() end

---移动控件到新的父控件
---@param source any 被移动控件
---@param target any 新的父控件
function base.gui_move_to_new_parent(source, target) end

---鼠标在UI坐标系上的坐标X
---@return number x UI坐标X
function base.gui_get_mouse_pos_x() end

---鼠标在UI坐标系上的坐标Y
---@return number y UI坐标Y
function base.gui_get_mouse_pos_y() end

---设置可附着面板的附着单位
---@param cmpt any 可附着面板控件
---@param target any 单位对象
function base.gameui_attachable_panel_attach_to(cmpt, target) end

---输出信息到聊天窗口
---@param text string 聊天信息
---@param user string 发送人用户名
function base.gamechatclient_send_message(text, user) end

---获取输入框文本（经过敏感词检测后通过回调返回）
---@param input any 输入框控件
---@param callback fun(text: string)|nil 文本回调
function base.gui_get_input_text(input, callback) end

---设置输入框文本
---@param input any 输入框控件
---@param text string 文本内容
function base.gui_set_input_text(input, text) end

---获取 UI 内部状态信息（调试用途）
---@return table info { ui_map, tick_map, wait_to_create, callback }
function base.ui_info() end

---创建数据绑定对象，用于 UI 模板的数据绑定
---@param outer any|nil 外层绑定对象
---@return any bind 绑定对象（含 watch 表）
function base.bind(outer) end

------------------------------------------------------------------------------
-- base.event 命名空间
------------------------------------------------------------------------------

---UI 帧事件命名空间
---@class base.event
base.event = {}

---UI 每帧回调：执行控件帧回调并渲染本帧新创建的控件
---@param delta number 帧间隔时间
function base.event.on_ui_tick(delta) end

------------------------------------------------------------------------------
-- base.proto 协议处理
------------------------------------------------------------------------------

---协议处理函数表
---@class base.proto
base.proto = {}

---处理服务端切换镜头协议消息
---@param msg table 协议消息 { camera_id_name, time }
function base.proto.set_camera(msg) end

---处理服务端敏感词检测返回协议消息
---@param msg table 协议消息 { origin_text, text }
function base.proto.__return_check_text(msg) end

------------------------------------------------------------------------------
-- base.ui 命名空间
------------------------------------------------------------------------------

---UI 框架命名空间
---@class base.ui
base.ui = {}

---所有已创建控件的映射（id -> 控件对象）
---@type table<string, any>
base.ui.map = {}

---已命名 UI 的数据绑定 api 映射（名字 -> 绑定 api）
---@type table<string, any>
base.ui.bind = {}

---底层控件属性设置接口代理（set_xxx 系列）
---@type table
base.ui.gui = {}

---控件实例的元表（含 on_tick/remove/add_child/subscribe 等方法）
---@type table
base.ui.mt = {}

---已命名 UI 列表（名字 -> 根控件）
---@type table<string, any>
base.ui.list = {}

---UI 自动缩放模块
---@type table
base.ui.auto_scale = {}

---根据模板创建 UI，返回根控件与绑定 api
---@param template table UI 模板
---@param name string|nil UI 名字（命名后登记到 base.ui.list）
---@param bind any|nil 数据绑定对象（不传则新建）
---@param p any|nil 父控件
---@return any ui 根控件对象
---@return any api 数据绑定 api
---@return any slot_ui 插槽控件（可能为 nil）
function base.ui.create(template, name, bind, p) end

---创建一个视图控件（自动分配 id 并挂到 main 下）
---@param data table 控件数据表
---@return any ui 控件对象
function base.ui.view(data) end

---监听模板属性并绑定到控件，属性变化时同步到底层控件
---@param ui any 控件对象
---@param template table UI 模板
---@param bind any 数据绑定对象
---@param key string 属性名
---@param format fun(v: any): any|nil 值格式化函数
function base.ui.watch(ui, template, bind, key, format) end

---设置数组控件的元素个数（增减子控件）
---@param self any 控件对象
---@param v number 目标元素个数
---@param template table UI 模板
---@param bind any 数据绑定对象
function base.ui.set_array(self, v, template, bind) end

---刷新/清理 UI（不传参数时删除所有标记为 collect 的 UI）
---@param mode string|table|nil 刷新模式字符串或待标记的 UI 对象
function base.ui.flush(mode) end

---注册一个 UI 类型模板，返回模板构造函数
---@param ui any 创建函数或类
---@param type_name string 类型名
---@return fun(str_or_props: any): any ctor 模板构造函数
function base.ui.template(ui, type_name) end

---注册一个 UI 组件类型，返回组件定义对象
---@param type_name string 组件类型名
---@param base any|nil 基类（组件类）
---@return any component 组件定义对象
function base.ui.component(type_name, base) end

---更新控件事件回调注册
---@param self any 控件对象
---@param k string 事件名
---@param v fun(...)|nil 事件回调
function base.ui.update_event(self, k, v) end

---创建本帧等待创建的控件
---@return number used 耗时（ms）
---@return number count 创建个数
function base.ui.check_create_new() end

---深拷贝表
---@param t any 待拷贝的值
---@return any copy 拷贝结果
function base.ui.deep_copy(t) end

---把控件加入等待创建队列
---@param ui_ctrl any 控件对象
function base.ui.add_wait_to_create_ctrl(ui_ctrl) end

---派发控件属性变化事件
---@param ctrl any 控件对象
---@param prop_name string|table 属性名（或属性路径）
---@param value any 属性值
function base.ui.emit_prop_changed(ctrl, prop_name, value) end

---获取屏幕坐标处的控件
---@param x number 屏幕坐标X
---@param y number 屏幕坐标Y
---@param enabledOnly boolean|nil 是否只取可用控件
---@return any ui 控件对象
function base.ui.get_ui_at_position(x, y, enabledOnly) end

------------------------------------------------------------------------------
-- base.ui.mt（控件元表方法）
------------------------------------------------------------------------------

---订阅控件事件（含事件代理对，如 on_click 会同时订阅 on_mouse_up/on_mouse_down）
---@param name string 事件名
function base.ui.mt:subscribe(name) end

---取消订阅控件事件
---@param name string 事件名
function base.ui.mt:unsubscribe(name) end

---控件真正创建完成后立即注册所有已订阅事件
function base.ui.mt:subscribe_now() end

------------------------------------------------------------------------------
-- base.ui.event 命名空间
------------------------------------------------------------------------------

---UI 事件处理命名空间
---@class base.ui.event
base.ui.event = {}

---触发控件上注册的事件回调
---@param event_name string 事件名
---@param id string 控件 id
---@vararg any 事件参数
---@return any ui 控件对象
---@return any res 回调返回值
function base.ui.event.call(event_name, id, ...) end

---释放控件的事件状态（如鼠标移入状态）
---@param ui any 控件对象
function base.ui.event.release_event(ui) end

---设置长按判定时间
---@param time number 长按时长（毫秒）
function base.ui.event.set_long_click_timeout(time) end

------------------------------------------------------------------------------
-- base.control 命名空间（虚拟摇杆模板）
------------------------------------------------------------------------------

---控件模板命名空间
---@class base.control
base.control = {}

---构建移动虚拟摇杆模板（固定中心，圆形按下区域）
---@param body table 摇杆父 UI 模板
---@param background table 背景子 UI 模板
---@param slider table 摇杆滑块子 UI 模板
---@return any ui 虚拟摇杆 UI 模板
function base.control.move_virtual_joystick_template(body, background, slider) end

---构建移动虚拟摇杆模板（以按下位置为中心，方形按下区域）
---@param body table 摇杆父 UI 模板
---@param background table 背景子 UI 模板
---@param slider table 摇杆滑块子 UI 模板
---@return any ui 虚拟摇杆 UI 模板
function base.control.move_virtual_joystick_press_center_template(body, background, slider) end

---构建技能虚拟摇杆模板（固定中心，圆形按下区域）
---@param body table 摇杆父 UI 模板
---@param background table 背景子 UI 模板
---@param skill_icon table 技能图标子 UI 模板
---@param slider table 摇杆滑块子 UI 模板
---@return any ui 虚拟摇杆 UI 模板
function base.control.spell_virtual_joystick_template(body, background, skill_icon, slider) end

---构建技能虚拟摇杆模板（以按下位置为中心，方形按下区域）
---@param body table 摇杆父 UI 模板
---@param background table 背景子 UI 模板
---@param skill_icon table 技能图标子 UI 模板
---@param slider table 摇杆滑块子 UI 模板
---@return any ui 虚拟摇杆 UI 模板
function base.control.spell_virtual_joystick_press_center_template(body, background, skill_icon, slider) end
