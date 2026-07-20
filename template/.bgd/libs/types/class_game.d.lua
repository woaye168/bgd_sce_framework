---@meta

--==============================================================
-- SCE 游戏引擎 EmmyLua 类型声明：游戏 API
-- 覆盖范围：
--   1. base.game 命名空间（服务端 + 客户端方法）
--   2. 游戏阶段说明（见下方注释）
--   3. base.xxx 游戏级函数（游戏局属性等）
-- 来源文档：
--   服务端-游戏-游戏阶段:
--     https://doc.sce.xd.com/技术文档/服务端Lua%20API/游戏/游戏阶段
--   服务端-游戏-API:
--     https://doc.sce.xd.com/技术文档/服务端Lua%20API/游戏/API
--   客户端-游戏-一些API:
--     https://doc.sce.xd.com/技术文档/客户端Lua%20API/游戏/一些API
--==============================================================

--------------------------------------------------------------
-- 游戏阶段（服务端，待重构，时长在数据编辑器中配置 game_stage）
-- 各阶段按顺序进行：
--   1. 初始化阶段（积分初始化）  time_score_init
--        表在该阶段开始前读好，但 Lua 尚未加载。
--        若 config.ini 配置 ['map']auto_load_scene=1（默认），
--        碰撞和视野等场景信息也在该阶段前加载。
--        积分信息、昵称在该阶段取好；取好后提前结束。
--        本地调试用命令行参数指定不使用积分时该阶段瞬间结束。
--   2. Loading 阶段              time_loading
--        初始化阶段结束的那一刻开始，服务器 Lua 在该阶段第一帧加载。
--        主要任务是等所有玩家声称自己 Loading 完毕，全部完毕则提前进入下一阶段。
--        若配置了不自动加载场景信息，此时可用 base.game.load_scene 加载，
--        并通过游戏局属性 base.game.set 通知客户端加载对应视野。
--   3. 选人阶段                  time_selecthero
--        Lua 控制时由 Lua 判断是否提前结束；
--        C++ 选人逻辑时所有人选完英雄即提前结束。
--   4. 选人倒计时                time_selectfinish（目前没什么用，将废弃）
--      （以前还有 time_start 字段，现已废弃）
--   5. 游戏运行阶段              time_run
--        被 set_winner 设置胜负后提前结束；
--        到达 time_run 指定时间游戏强行结束。
--   6. 游戏结束阶段              time_end
--        最后阶段（算战报等）。该阶段结束后游戏局才真正释放。
-- 另：mode 字段可控制是否跳过选人（mode = 4），以及 Loading 和选人的顺序等。
--------------------------------------------------------------

---游戏全局命名空间表
---@class base.game
base.game = base.game or {}

--==============================================================
-- 服务端 base.game 方法
--==============================================================

---服务端广播自定义消息给所有客户端，返回发送函数。【服务端】
---消息序列化后超过 1300*256 字节时发送函数返回 false。
---@param type string 自定义消息类型
---@param ensure? boolean 为 true 时保证必达（玩家断线重连后也会收到）
---@return fun(data:any):boolean send 发送函数，返回是否发送成功
function base.game:ui(type, ensure) end

---获取游戏模式。【服务端】
---即「创作者中心 -> 运营管理 -> 大厅配置 -> 游戏多模式」里设置的「模式key」。
---没有配置时返回值可能为空，也可能是空字符串。
---注意：只有发布后在真机（或经过大厅的流程）上测试才有效，编辑器内调试拿不到。
---不同的「模式key」的玩家一定不会被匹配到同一局。
---@return string mode_key 模式key
function base.game:get_mode_key() end

---获取胜利队伍。【服务端】
---@return integer team_id 队伍ID
function base.game:get_winner() end

---结束游戏，进入「游戏结束」阶段。【服务端】
---「游戏结束」阶段中所有计时器、单位、技能、Buff 都不会被更新，
---但「玩家-连入」事件依然会触发，自定义协议依然会被处理。
---该阶段时长在 数据编辑器 -> 项目蓝图 -> 地图设置 -> 默认地图设置
--- -> 显示更多属性 -> 时间 - 结束 中配置（毫秒）。
---阶段结束后游戏彻底被销毁，玩家不再能连入。
function base.game:end_game() end

---设置英雄复活回调。【服务端】
---当有单位类型为 `英雄` 的单位死亡时执行回调，
---用回调返回的时间与位置决定复活时间与复活后的位置（位置默认为死亡时的位置）。
---@param callback fun(dead_hero:Unit):integer,Point 回调，返回复活时间（毫秒）与复活位置
function base.game:on_reborn(callback) end

---播放音乐。【服务端】
---@param name string 音效名（音效表 SoundData.ini 里填的那个）
function base.game:play_music(name) end

---播放音效。【服务端】
---注意：该 api 的音效现在是队列而不是打断。
---@param name string 音效名（音效表 SoundData.ini 里填的那个）
---@param team? integer 队伍ID（可选）
---@param scene_name? string 场景名（可选），不填为默认场景；填的话必须把 team 也填了。场景不对听不到声音
function base.game:play_sound(name, team, scene_name) end

---新增玩家属性类型。【服务端】
---@param name string 属性名
---@param type integer 类型值（跟 Constant.ini 属性值取值方式一样）
function base.game:player_attribute_add(name, type) end

---删除玩家属性类型。【服务端】
---@param name string 属性名
function base.game:player_attribute_del(name) end

---设置玩家属性同步方式，默认同步方式为 `none`。【服务端】
---@param name string 属性名
---@param sync string 同步方式
function base.game:player_attribute_sync(name, sync) end

---设置客户端显示的时间。【服务端】
---@param time integer 当前时间（毫秒）
---@param type boolean 是否是倒计时
function base.game:show_timer(time, type) end

---设置升级经验。【服务端】
---列表中每一项表示英雄从该等级提升到下一等级所需的经验。
---设置后 base.game.max_level 会被设置为列表大小 + 1。
---@param list number[] 升级所需经验列表
function base.game:set_level_exp(list) end

---获取游戏阶段。【服务端】
---@return integer status 游戏阶段
function base.game:status() end

---设置单位属性上限。只会影响之后创建出来的单位。【服务端】
---@param state string 单位属性
---@param value number 上限值
function base.game:unit_attribute_max(state, value) end

---设置单位属性下限。只会影响之后创建出来的单位。【服务端】
---@param state string 单位属性
---@param value number 下限值
function base.game:unit_attribute_min(state, value) end

---新增单位属性类型。【服务端】
---@param name string 属性名
---@param type integer 类型值（跟 Constant.ini 属性值取值方式一样）
function base.game:unit_attribute_add(name, type) end

---删除单位属性类型。【服务端】
---@param name string 属性名
function base.game:unit_attribute_del(name) end

---设置单位属性同步方式，默认同步方式为 `none`。【服务端】
---只会影响之后创建出来的单位。
---@param state string 单位属性
---@param sync string 同步方式
function base.game:unit_attribute_sync(state, sync) end

---无限火力：令技能无冷却无消耗。【服务端】
---@param enable? boolean 开/关
---@return boolean is_enable 目前的开关状态
function base.game:wtf(enable) end

---使游戏局至少再存活指定秒数，不管其它所有条件。（支持时间：20190808）【服务端】
---就算其它结束游戏的条件满足了，也会等到 keep_alive 时间到了才结束。
---@param keep_alive_seconds number 从现在开始至少再存活的秒数
function base.game:keep_alive(keep_alive_seconds) end

---取消之前所有的 keep_alive 操作。（支持时间：20190808）【服务端】
function base.game:cancel_keep_alive() end

---文字和谐处理。屏蔽字会被处理成星号(*)。【服务端】
---@param words string 要处理的文字
---@return string processed_words 处理后的文字
function base.game:filter_word(words) end

---时间停止。【服务端】
---除了被标记了「免时停」的单位，其它逻辑都会停止（包括全局 timer）；
---时停期间单位不 tick，全局 tick 不进，timer 不算时间，mover 不移动，
---但依然可以创建新的单位（只是不会被 tick）。
---客户端同样会暂停未标记「免时停」的单位，但 UI 不受影响。
---本帧尚未被 tick 的对象依然会被 tick，即从下一帧才开始正式起作用。
---@param time_stop_seconds? number 时停秒数。时停期间再次调用会覆盖而不是延长；
---不填表示一直停止直到手动恢复；填 0 没有效果；小于 1 帧的时间等价于时停 1 帧
function base.game:time_stop(time_stop_seconds) end

---取消时间停止。和 time_stop 类似，也是下一帧才生效。【服务端】
function base.game:cancel_time_stop() end

---返回游戏局ID，全局唯一且 2038 年前必定不会重复。【服务端】
---@return integer game_session_id 游戏局ID（int64）
function base.game:get_session_id() end

---加载场景。该方法是同步（阻塞）的，可能卡几百乃至几千毫秒，【服务端】
---调用前建议处理好客户端相关表现（比如转个圈）。
---@param scene_name string 场景名称
---@return integer ret_value 0=加载成功；1=场景之前已加载过（scene_name 未传也返回1）；2=场景数据文件损坏
function base.game:load_scene(scene_name) end

---释放指定场景。【服务端】
---当前场景有玩家存在时不能释放；场景被成功释放或本就不存在时返回 true。
---@param scene_name string 场景名称
---@return boolean success 是否释放成功
function base.game:close_scene(scene_name) end

---获取游戏中所有场景的名称。【服务端】
---@return string[] scene_names 场景名称列表
function base.game:get_all_scene_name() end

---获取游戏中所有场景的默认单位。【服务端】
---返回表中包含用默认单位信息创建出来的单位，该单位可能为空。
---@param scene_name? string 场景名，不填返回所有（已加载）场景的默认单位
---@return table default_units 被询问场景的单位表，获取某个场景用 default_units['scene_name']
function base.game:get_default_units(scene_name) end

---通过 node_mark 获取游戏中的默认单位（主要是触发编辑器使用）。【服务端】
---@param node_mark string 默认单位的 node_mark
---@return Unit|nil default_unit 对应单位；单位不存在（未创建或已删除）时返回 nil
function base.game:get_default_unit(node_mark) end

---设置（游戏局）属性并同步给客户端。【服务端】
---如果此时客户端不在线，等他登录（或重连）后会拿到最新的游戏局属性。
---会通过「游戏-属性变化」事件通知给客户端 Lua。
---@param key string 属性名称
---@param value string 属性的值（暂时只提供字符串类型）
function base.game:set(key, value) end

---开启 ai。【服务端】
function base.game:enable_ai() end

---关闭 ai。【服务端】
function base.game:disable_ai() end

---同 skill 里同名函数。【服务端】
---@param ... any
function base.game:mover_line(...) end

---同 skill 里同名函数。【服务端】
---@param ... any
function base.game:mover_target(...) end

---同 skill 里同名函数。【服务端】
---@param ... any
function base.game:add_damage(...) end

---设置服务器一个逻辑帧内的更新次数，默认为 1。【服务端】
---@param speed integer 一个逻辑帧的更新次数
function base.game:set_game_speed(speed) end

---设置游戏局开始的时间戳，可以通过 os.time 获取想要的时间戳。【服务端】
---@param timestamp integer 开始的时间戳
function base.game:set_session_start_time(timestamp) end

---等级上限。【服务端】
---用于「英雄升级」库，表示单位可以通过经验达到的等级上限。
---@type integer
base.game.max_level = nil

--==============================================================
-- 客户端 base.game 方法
--==============================================================

---发送聊天。【客户端】
---@param target string 聊天对象：'全体'=所有玩家可见；'队伍'=仅同队伍玩家可见
---@param msg string 聊天内容
function base.game:chat(target, msg) end

---退出游戏。【客户端】
function base.game:exit() end

---获取鼠标位置。【客户端】
---@return Point point 位置
function base.game:input_mouse() end

---获取按键状态。【客户端】
---按键名使用 `"Ctrl"` 判断任意一个 Ctrl 键，
---使用 `"LeftCtrl"` 与 `"RightCtrl"` 精确判断某一个 Ctrl 键。Alt 键与 Shift 键同理。
---@param key string 按键名
---@return boolean state 是否按下
function base.game:key_state(key) end

---获取选中的单位。【客户端】
---@return Unit|nil unit 选中的单位；没有选中时返回 nil
function base.game:selected_unit() end

---获取显示时间。【客户端】
---@return number time 显示时间（秒），负数表示处于倒计时状态
function base.game:show_timer() end

---加载游戏场景（切换客户端场景，影响地形、小地图、声音）。【客户端】
---可以在 MapInfo.ini 中配置 bAutoLoadScene 来控制是否自动加载场景。
---@param scene_name string 目标场景名称
---@param map_file string map.xml 文件名
---@param height_file string HeightData.dat 文件名
---@param sight_file string Sight.dat 文件名
---@param minmap_template_name string MiniMap_Template 小地图模板名称
---@return boolean success 是否创建成功（太早创建可能失败，一般在收到「游戏-属性变化」后调用）
function base.game:set_game_scene(scene_name, map_file, height_file, sight_file, minmap_template_name) end

---切换灯光组。【客户端】
---@param path string light group 文件资源路径
---@param time number 切换时间（秒）
function base.game:use_light_group(path, time) end

---获取屏幕位置的单位和模型表现。【客户端】
---返回摄像机对屏幕位置发射射线所碰到的所有单位或模型表现的 id 列表：
---单位的 id > 0，模型表现的 id < 0。
---@param x number 屏幕位置x
---@param y number 屏幕位置y
---@return integer[] actors id 列表
function base.game:get_actors_at_screen_xy(x, y) end
