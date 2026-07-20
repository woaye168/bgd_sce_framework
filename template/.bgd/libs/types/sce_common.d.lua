---@meta

-- ============================================================================
-- SCE 引擎：公共能力表（common）
-- ----------------------------------------------------------------------------
-- common 表由引擎 C++ 层注入 _G，提供平台信息、命令行参数、选项存储、
-- 统计上报、哈希/文件、渲染设置、鼠标输入等系统级能力。
--
-- 注意：部分接口仅存在于特定平台/状态（注释中标注【可选】），
-- 上游代码的惯例是先判 nil 再调用：
---```lua
---if common.reload_pak then common.reload_pak(name) end
---```
-- 成员签名根据 client_base / script-195 的实际调用点推断。
-- ============================================================================

---引擎公共能力表
---@class common
common = {}

-- ============================================================================
-- 平台 / 命令行参数
-- ============================================================================

---获取当前平台名
---@return string platform 'Windows' | 'Android' | 'iOS' | 'Web' | 'Wx' 等
function common.get_platform() end

---判断命令行是否携带某个参数
---@param name string 参数名
---@return boolean
function common.has_arg(name) end

---获取命令行参数值
---@param name string 参数名
---@return string
function common.get_argv(name) end

---追加/修改命令行参数
---@param name string 参数名
---@param value string 参数值
function common.add_argv(name, value) end

---移除命令行参数
---@param name string 参数名
function common.remove_argv(name) end

---获取完整命令行字符串
---@return string
function common.get_full_cmdline() end

---获取应用安装目录
---@return string
function common.get_app_dir() end

---获取二进制（引擎）版本号
---@return string
function common.get_binary_version() end

---【可选】获取二进制包名
---@return string
function common.get_binary() end

---【可选】获取安装包名
---@return string
function common.get_package() end

---【可选】是否在编辑器中运行游戏
---@return boolean
function common.is_game_play_in_editor() end

---【可选】获取调试用的手游模式开关
---@return boolean
function common.get_debug_game_mobile() end

---获取系统语言（可被 Lua 层覆盖重写）
---@return string
function common.get_system_language() end

-- ============================================================================
-- 键值存储 / 游戏选项
-- ============================================================================

---读取持久化键值（字符串）
---@param key string
---@return string
function common.get_value(key) end

---写入持久化键值
---@param key string
---@param value string|number
function common.set_value(key, value) end

---读取游戏选项（graphics/quality 等）
---@param key string 选项名
---@return any
function common.get_option(key) end

---保存字符串选项
---@param key string
---@param value string
---@param save? boolean 是否立即落盘
function common.save_string_option(key, value, save) end

---保存浮点选项
---@param key string
---@param value number
---@param save? boolean 是否立即落盘
function common.save_float_option(key, value, save) end

---保存布尔选项
---@param key string
---@param value boolean
---@param save? boolean 是否立即落盘
function common.save_boolean_option(key, value, save) end

---设置字符串选项（不落盘）
---@param key string
---@param value string
function common.set_string_option(key, value) end

---设置浮点选项（不落盘）
---@param key string
---@param value number
function common.set_float_option(key, value) end

---设置布尔选项（不落盘）
---@param key string
---@param value boolean
function common.set_boolean_option(key, value) end

---设置字符串选项的默认值
---@param key string
---@param value string
function common.set_default_string_option(key, value) end

---设置浮点选项的默认值
---@param key string
---@param value number
function common.set_default_float_option(key, value) end

---设置布尔选项的默认值
---@param key string
---@param value boolean
function common.set_default_boolean_option(key, value) end

---注册一个选项名（注册后才能读写）
---@param name string
function common.register_option(name) end

---【可选】设置当前游戏标识（影响选项作用域）
---@param game string
function common.set_current_game(game) end

-- ============================================================================
-- 时间 / 性能 / 统计上报
-- ============================================================================

---获取 UTC 秒级时间戳
---@return number
function common.utc_time() end

---获取系统时间（高精度计时用）
---@return number
function common.get_system_time() end

---【可选】获取当前 FPS（部分平台为 nil）
---@return number
function common.get_current_fps() end

---获取当前网络延迟（ms）
---@return number
function common.get_current_ping() end

---获取卡顿计数
---@return number
function common.get_jank_count() end

---获取当前 draw call 数
---@return number
function common.get_current_draw_call() end

---发送统计事件
---@param event string 事件名
---@param data table 事件数据
function common.stat_sender(event, data) end

---发送用户统计（单键值）
---@param key string
---@param value string|number
function common.send_user_stat(key, value) end

---通过 HTTP 发送用户统计
---@param subpath string 子路径
---@param event string 事件名
---@param msg string 内容
function common.send_http_user_stat(subpath, event, msg) end

---【可选】记录启动/更新阶段耗时（Lua 层可能兜成空函数）
---@param stage string 阶段，如 'start' / 'end'
---@param name string 阶段名
function common.record_stage(stage, name) end

---发送自动化测试日志
---@param test_id string
---@param log_url string
---@param test_map string
---@param launch_time number
function common.send_autotest_log(test_id, log_url, test_map, launch_time) end

---写入性能采样明细
---@param desc string 描述
---@param write_to_protocol boolean 是否写入协议（录像）
function common.write_profile_detail(desc, write_to_protocol) end

---开始一个性能采样块（与 profile_end_block 配对）
---@param name string 块名
function common.profile_begin_block(name) end

---结束当前性能采样块
function common.profile_end_block() end

---上报游戏包体大小
---@param json string JSON 字符串
function common.report_game_size(json) end

---触发 RenderDoc 抓帧（函数值，常赋给配置字段）
---@type fun()
common.trigger_rdoc_capture = nil

-- ============================================================================
-- 哈希 / 文件 / JSON
-- ============================================================================

---字符串哈希（整数）
---@param s string
---@return number
function common.string_hash(s) end

---计算字符串 MD5
---@param s string
---@return string
function common.get_md5(s) end

---【可选】计算文件 MD5
---@param path string 文件路径
---@param use_cache? boolean 是否使用缓存
---@return string
function common.get_file_md5(path, use_cache) end

---从 HTTP 下载缓冲区计算 MD5
---@param buffer any 下载缓冲区
---@return string
function common.get_md5_from_http_stream(buffer) end

---【可选】计算文件 CRC32
---@param path string 文件路径
---@return number
function common.get_file_crc32(path) end

---JSON 解码
---@param s string JSON 字符串
---@return table data 解码结果
---@return string? err 错误信息（成功时为 nil）
function common.json_decode(s) end

---【可选】JSON 编码
---@param t table
---@param needSort? boolean 是否按键排序输出
---@return string
function common.json_encode(t, needSort) end

-- ============================================================================
-- 进程 / URL / 系统
-- ============================================================================

---退出进程（正常退出）
function common.exit() end

---强制退出进程
function common.force_exit() end

---用系统默认程序打开 URL / 启动外部程序
---@param url string 网址或可执行文件路径
---@param cmdline? string 启动外部程序时的命令行参数
function common.open_url(url, cmdline) end

---创建桌面快捷方式
---@param craft_id string|number 游戏/地图 id
function common.create_shortcut(craft_id) end

---当前是否处于 Wi-Fi 网络
---@return boolean
function common.is_wifi() end

-- ============================================================================
-- 渲染 / 画面设置（多数为【可选】，不同平台支持度不同）
-- ============================================================================

---【可选】获取设备详情档位
---@return string
function common.get_detail() end

---【可选】获取渲染器名称
---@return string
function common.get_renderer_name() end

---【可选】设置渲染质量等级
---@param level integer 0-3
function common.set_render_quality(level) end

---获取渲染质量等级
---@return integer
function common.get_render_quality() end

---【可选】设置粒子 LOD 等级
---@param level integer
function common.set_particle_lod_level(level) end

---【可选】开关点光源
---@param enabled boolean
function common.set_point_light_enabled(enabled) end

---【可选】开关 cluster 光照
---@param enabled boolean
function common.set_use_cluster(enabled) end

---【可选】锁定最大帧率
---@param fps integer
function common.set_lock_max_fps(fps) end

---【可选】开关后处理
---@param enabled boolean
function common.set_postprocess_enabled(enabled) end

---设置游戏逻辑速度倍率
---@param speed number
function common.set_game_speed(speed) end

---设置最大帧率
---@param fps integer
function common.set_max_fps(fps) end

---开关渲染遮罩
---@param enabled boolean
function common.set_render_mask(enabled) end

---设置皮肤类型
---@param index integer
function common.set_skin_type(index) end

---设置音量
---@param volume number 0.0 - 1.0
function common.set_sound_volume(volume) end

---设置背景贴图
---@param index integer
function common.set_background_texture(index) end

---设置背景贴图 UV
---@param us number 起点 u
---@param vs number 起点 v
---@param ue number 终点 u
---@param ve number 终点 v
function common.set_background_texture_uv(us, vs, ue, ve) end

---开关资源缓存清理标记
---@param toggle boolean
function common.set_need_clear_resource_cache(toggle) end

---设置逻辑分辨率
---@param width number
---@param height number
function common.set_logic_view(width, height) end

---设置窗口分辨率
---@param width number
---@param height number
function common.set_resolution(width, height) end

---获取窗口分辨率
---@return number width
---@return number height
function common.get_resolution() end

---获取屏幕方向
---@return any
function common.get_orientation() end

---获取刘海屏高度
---@return number
function common.get_bangs_height() end

---获取安全区域边距
---@param compute_scale boolean 是否按缩放换算
---@return number left
---@return number top
---@return number right
---@return number bottom
function common.get_safe_area_insets(compute_scale) end

---锁定场景视图（编辑器）
function common.lock_scene_view() end

---解锁场景视图（编辑器）
function common.unlock_scene_view() end

---断线测试开关
---@param a boolean
---@param b boolean
function common.disconnect_test(a, b) end

---显示/隐藏系统导航栏
---@param mode integer
function common.show_nav(mode) end

---显示调试视图
---@param mode integer
function common.show_debug_view(mode) end

---立即烘焙一次阴影贴图
function common.baking_shadowmap_once() end

---调试开关：显示单位半径
function common.toggle_show_unit_radius() end

---调试开关：显示选中框
function common.toggle_show_select() end

---调试开关：显示包围盒
function common.toggle_show_boundingbox() end

---调试开关：显示单位碰撞格
function common.toggle_show_unit_collision_grid() end

---调试开关：游戏 UI 显隐
function common.toggle_game_ui() end

---调试开关：垂直同步
function common.toggle_vsync() end

---调试开关：实例化渲染
function common.toggle_instance() end

---调试开关：地形显隐
function common.toggle_terrain() end

---调试开关：粒子显隐
function common.toggle_particle() end

---调试开关：背景显隐
function common.toggle_bg() end

---调试开关：阴影显隐
function common.toggle_shadow() end

---调试开关：动画模型显隐
function common.toggle_animated_model() end

---调试开关：动画播放
function common.toggle_animation() end

---调试开关：后处理
function common.toggle_postprocess() end

---调试开关：cluster 光照
function common.toggle_cluster() end

---合并平行光与点光源开关
---@param enabled boolean
function common.set_merge_directional_light_and_point_light(enabled) end

---合并网格计算开关
---@param enabled boolean
function common.set_enable_compute_merge_mesh(enabled) end

---【可选】重载字体映射
function common.reload_font_map() end

---【可选】重载指定 pak 包
---@param name string 包名
function common.reload_pak(name) end

---【可选】重载着色器缓存
function common.reload_shadercache() end

---【可选】加载着色器缓存与 pak 包
function common.load_shadercache_and_paks() end

---切换编辑器 API 版本
---@param old_version any
---@param new_version any
function common.change_editor_api(old_version, new_version) end

---获取地图 pak 版本号
---@param key string
---@return string|number
function common.get_map_pak_version(key) end

---设置地图 pak 版本号
---@param map_or_key string 地图或键名
---@param pak_name string 包名
---@param pak_version string|number 版本号
function common.set_map_pak_version(map_or_key, pak_name, pak_version) end

-- ============================================================================
-- 鼠标 / 光标 / 输入
-- ============================================================================

---获取鼠标（或触摸点）屏幕坐标
---@param touch_id? integer 触摸点 id（多端触控时使用）
---@return number x
---@return number y
function common.get_mouse_screen_pos(touch_id) end

---设置自定义光标
---@param name string 光标名
---@param path string 光标资源路径
function common.set_cursor_shape(name, path) end

---是否使用系统光标
---@param use boolean
function common.set_use_system_cursor(use) end

---设置光标可见性
---@param visible boolean
function common.set_cursor_visible(visible) end

-- ============================================================================
-- 其他
-- ============================================================================

---设置血条画布可见性
---@param visible boolean
function common.set_bloodstrip_canvas_visible(visible) end

---发送广播消息
---@param json string JSON 字符串
function common.send_broadcast(json) end

---设置客户端 id / token（防作弊校验用）
---@param id string client_id 或 token
---@param type integer 0 = client_id，1 = client_token
---@param noise any 噪声值
---@param unixtime number 时间戳
---@param server_noise any 服务端噪声值
---@param map_name string 地图名
function common.set_client_id_token(id, type, noise, unixtime, server_noise, map_name) end

---【可选】获取大区选择（注意大写开头）
---@param mode string 如 'single'
---@return string
function common.GetRegionSelect(mode) end

---强制选择大区
---@param region string
function common.ForceRegionSelect(region) end
