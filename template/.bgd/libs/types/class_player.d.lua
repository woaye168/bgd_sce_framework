---@meta

-- ============================================================================
-- SCE 玩家（Player）/ 队伍（Team）类型声明
-- ----------------------------------------------------------------------------
-- 覆盖范围：服务端玩家 API、客户端玩家 API、客户端队伍 API
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/玩家/简介 （纯概念页，无 API）
--   https://doc.sce.xd.com/技术文档/服务端Lua API/玩家/玩家属性 （枚举型属性说明，见下方列表）
--   https://doc.sce.xd.com/技术文档/服务端Lua API/玩家/API
--   https://doc.sce.xd.com/技术文档/服务端Lua API/玩家/一种低成本实现匹配服的方式 （纯概念页，无 API）
--   https://doc.sce.xd.com/技术文档/客户端Lua API/玩家/玩家
--   https://doc.sce.xd.com/技术文档/客户端Lua API/玩家/队伍
--
-- 玩家属性（player:get/set/add 可用的属性名）：
--   玩家属性有 3 个内置属性和 26 个自定义属性，自定义属性在 Constant 中定义。
--   服务器不关心自定义属性的含义，仅在同步方式允许的情况下将数值转发给客户端。
--   文档中列出的可用于客户端默认 UI 及服务器脚本库的属性名：
--     金钱          - 显示在商店中
--     击杀          - 显示在数据面板中
--     死亡          - 显示在数据面板中
--     助攻          - 显示在数据面板中
--     补刀          - 显示在数据面板中
--     大招状态      - 显示在队友头像处（1=大招未学习，2=大招冷却中，4=魔法不足；同时满足多个状态时数字相加）
--     大招冷却      - 显示在队友头像处，单位秒
--     大招冷却上限  - 显示在队友头像处，单位秒
--     复活时间      - 用于脚本库复活英雄；显示在头像、队友头像、中央进度条处
--     复活时间上限  - 用于脚本库复活英雄；显示在头像、队友头像、中央进度条处
--   注意：玩家属性涉及底层同步，属性值大小存在上限，序列化后超过 1300*256-50 会抛出异常，
--         不要一次性设置过大的表属性。
-- ============================================================================

---获取玩家对象。【双端】
---@param id integer 玩家ID
---@return Player player 玩家
function base.player(id) end

---获取本地玩家。【客户端】
---@return Player player 本地玩家
function base.local_player() end

---遍历玩家。【双端】
---当设置了 type 后，会遍历所有该类型的玩家（根据 config 中的玩家定义）；
---否则会遍历所有玩家。按照玩家ID从小到大的顺序遍历。
---用法：for player in base.each_player 'user' do ... end
---@param type? string 玩家类型
---@return fun():Player iterator 迭代器，每次返回一个玩家
function base.each_player(type) end

---玩家对象。【双端】
---玩家可以是 用户 或 电脑，玩家当前控制的单位被称为玩家的英雄。
---@class Player
local Player = {}

---发送消息属性表。【服务端】
---@class PlayerMessageData
---@field text string 消息内容。支持特殊格式化标志：$player[x]$ 格式化为玩家[x]的名字；&[X][Y]& 格式化为单位[Y]的头像，边框颜色为[X]
---@field type string 消息类型：'ann' 公告 / 'chat' 聊天 / 'error' 错误
---@field time? integer 持续时间（毫秒）
---@field sound? string 音效
---@field effect? string 特效
local PlayerMessageData = {}

---镜头状态表。【服务端】
---@class PlayerCameraData
---@field position Point|table 镜头目标位置，可以直接使用 point，也可以使用 {x, y, z} 表示一个三维位置
---@field rotation? table 镜头旋转，使用 {rx, ry, rz} 表示镜头在3个坐标轴上的旋转，默认为 {0, 0, 0}
---@field focus_distance? number 摄像机与镜头目标之间的距离，默认为0
---@field time? integer 变换时间，默认为0，单位毫秒。为0时镜头立即变换，否则在变换时间内平滑运动
local PlayerCameraData = {}

---服务端给该玩家的客户端发送自定义消息。【服务端】
---返回一个发送函数，调用该函数即发送消息，如：player:ui 'message_type' (table1)。
---ensure 为 true 时表示断线重连后必达。
---注意：此 API 未在“玩家 API”页面列出，声明依据“服务端发送自定义消息给客户端”文档中的用法。
---@param type string 自定义消息类型
---@param ensure? boolean 是否确保断线重连后必达
---@return fun(data:any):boolean send 发送函数，返回是否发送成功
function Player:ui(type, ensure) end

---增加属性。【服务端】
---由c++实现的api。玩家属性说明见本文件头部注释。
---@param state string 属性名称
---@param value number 数值
function Player:add(state, value) end

---获取玩家控制者。【双端】
---服务端由c++实现的api。
---@return string controller 控制者：'human' 用户 / 'none' 空位 / 'computer' 电脑 / 'ai' AI / 'human-ai' 像人AI（仅服务端，客户端无 'human-ai'）
function Player:controller() end

---创建物品。【服务端】
---创建出来的物品所有者为该玩家。当 target 为点，物品创建在地上；当 target 为单位，
---物品创建在单位身上，但如果该单位的物品栏已满则会创建在单位所在的位置上。
---@param name string 物品名
---@param target Point|Unit 创建位置
---@return Item item 创建的物品
function Player:create_item(name, target) end

---创建单位。【服务端】
---由c++实现的api。创建出来的单位由该玩家控制。
---如果 name 是字符串，创建名称为 name 的单位；如果 name 是一个单位，则会复制该单位
---（目前该行为等同于 create_illusion）。
---创建流程：执行 on_init -> 触发[单位-初始化]事件 -> 添加技能 -> 触发[单位-创建]事件。
---注意：创建单位后在当帧立即在客户端使用该单位的信息可能有问题，详见[单位-初始化]事件描述。
---@param name string|Unit 单位名字/要复制的单位
---@param where Point 创建位置
---@param face number 面朝方向
---@param on_init? fun(unit:Unit) 初始化函数，单位创建后最先执行
---@return Unit unit 创建的单位
function Player:create_unit(name, where, face, on_init) end

---注册事件。【双端】
---这是对 base.event_register 方法的封装。
---事件回调参数：trigger (Trigger) 触发器, ... 自定义数据
---@param name string 事件名
---@param callback fun(trigger:Trigger, ...) 事件函数
---@return Trigger trigger 触发器
function Player:event(name, callback) end

---触发事件（dispatch）。【双端】
---这是对 base.event_dispatch 方法的封装。
---@param name string 事件名
---@param ... any 自定义数据
function Player:event_dispatch(name, ...) end

---触发事件（notify）。【双端】
---这是对 base.event_notify 方法的封装。
---@param name string 事件名
---@param ... any 自定义数据
function Player:event_notify(name, ...) end

---获取游戏状态。【双端】
---@return string state 状态：'none' 空位 / 'online' 在线 / 'offline' 离线
function Player:game_state() end

---获取属性。【双端】
---服务端由c++实现的api。玩家属性说明见本文件头部注释。
---@param state string 属性名称
---@return number|string value 数值或字符串
function Player:get(state) end

---获取英雄。【双端】
---服务端由c++实现的api。如果玩家没有英雄，则返回 nil。
---@return Unit|nil hero 玩家的英雄
function Player:get_hero() end

---获取玩家ID（槽位ID）。【双端】
---服务端由c++实现的api。
---@return integer id 玩家ID
function Player:get_slot_id() end

---获取队伍ID。【双端】
---服务端由c++实现的api。
---@return integer id 队伍ID
function Player:get_team_id() end

---获取鼠标位置。【服务端】
---由c++实现的api。该属性由客户端上传，需要客户端支持鼠标才有意义。
---@return Point mouse 鼠标位置
function Player:input_mouse() end

---获取摇杆方向。【服务端】
---由c++实现的api。该属性由客户端上传，需要客户端支持摇杆才有意义。
---如果摇杆是松开状态，则返回 nil。
---@return number|nil rocker 摇杆方向
function Player:input_rocker() end

---是否放弃游戏。【服务端】
---放弃游戏的玩家无法再重连回游戏。
---@return boolean result 结果
function Player:is_abort() end

---踢出游戏。【服务端】
---由c++实现的api。
---@param backend string 服务器记录的原因
---@param frontend string 客户端显示的原因
function Player:kick(backend, frontend) end

---获取退出原因。【服务端】
---由c++实现的api。
---@return string leave_reason 原因
function Player:leave_reason() end

---创建闪电。【服务端】
---由c++实现的api。闪电的属性与相关信息见闪电文档（LightningData）。
---@param data LightningData 属性表
---@return Lightning lightning 闪电
function Player:lightning(data) end

---锁定镜头。【服务端】
---由c++实现的api。锁定镜头后，玩家无法通过客户端操作改变镜头状态，set_camera 无效。
---使用 unlock_camera 解锁镜头。
function Player:lock_camera() end

---锁定滚轮改变镜头。【服务端】
---由c++实现的api。锁定后玩家无法通过鼠标滚轮改变镜头状态，手机上禁用双指改变镜头。
---使用 unlock_camera_by_mouse_wheel 解锁滚轮。
function Player:lock_camera_by_mouse_wheel() end

---发送消息。【服务端】
---由c++实现的api。
---@param data PlayerMessageData 属性表
function Player:message(data) end

---弹框消息。【服务端】
---由c++实现的api。
---@param text string 消息内容
function Player:message_box(text) end

---播放音乐。【服务端】
---由c++实现的api。
---@param name string 音效名（音效表 SoundData.ini 里填的那个）
function Player:play_music(name) end

---播放音效。【服务端】
---由c++实现的api。
---注意：官方文档注明“这个api的音效现在是队列而不是打断，感觉有点问题，待之后一起改了”。
---@param name string 音效名（音效表 SoundData.ini 里填的那个）
function Player:play_sound(name) end

---设置属性。【服务端】
---由c++实现的api。玩家属性说明见本文件头部注释。
---注意：属性值大小存在上限，序列化后超过 1300*256-50 会抛出异常，不要一次性设置过大的表属性。
---@param state string 属性名称
---@param value number|string|table 属性值
function Player:set(state, value) end

---设置为挂机。【服务端】
---由c++实现的api。
function Player:set_afk() end

---设置镜头。【服务端】
---由c++实现的api。使用该方法会立即中断上次的镜头变换。
---@param data PlayerCameraData 镜头状态
function Player:set_camera(data) end

---设置英雄。【服务端】
---由c++实现的api。
---@param hero Unit 玩家的英雄
function Player:set_hero(hero) end

---设置队伍ID。【服务端】
---由c++实现的api。
---@param id integer 队伍ID
function Player:set_team_id(id) end

---屏幕震动。【服务端】
---由c++实现的api。目前支持的震动类型为 0，1，2，3。
---@param type integer 震动类型
function Player:shake_camera(type) end

---解锁镜头。【服务端】
---由c++实现的api。
function Player:unlock_camera() end

---解锁滚轮改变镜头。【服务端】
---由c++实现的api。
function Player:unlock_camera_by_mouse_wheel() end

---用户客户端。【服务端】
---由c++实现的api。用于分辨用户使用的客户端，该值由客户端上传。
---@return string agent 客户端
function Player:user_agent() end

---虚拟的用户ID。【服务端】
---由c++实现的api。
---官方文档注明：这个用户ID没啥用，除了能保证每个人唯一且比较小。
---真实的 user_id 要用 base.auxiliary.get_player_id。
---@return integer id 用户ID
function Player:user_id() end

---用户信息。【服务端】
---由c++实现的api。
---类型为 '英雄' 时，返回用户可用英雄的名单；类型 '免费英雄' 时，返回用户免费英雄的名单；
---类型为 '养成' 时，返回用户使用的符卡名单。
---@param type string 类型
---@return table list 信息列表
function Player:user_info(type) end

---用户等级。【服务端】
---由c++实现的api。
---@return integer level 平台等级
function Player:user_level() end

---用户名字。【服务端】
---由c++实现的api。
---@return string user_name 用户名字
function Player:get_user_name() end

---用户昵称。【服务端】
---由c++实现的api。
---@return string nick_name 用户昵称
function Player:get_nick_name() end

---获取玩家自定义属性。【服务端】
---由c++实现的api。
---@param key string 在 config.ini 里写的 user_info
---@return string|integer value 属性值
function Player:get_user_info(key) end

---摄像机跟随单位。【服务端】
---由c++实现的api。
---@param unit Unit 跟随的单位
---@return boolean result 是否成功
function Player:camera_focus(unit) end

---获取玩家的场景。【服务端】
---由c++实现的api。
---@return string scene_name 玩家所在场景
function Player:get_scene_name() end

---玩家跳转场景。【服务端】
---由c++实现的api。如果目标场景不存在，将返回 false。
---@param scene_name string 玩家将要跳转的场景
---@param keep_hero? boolean 是否带上主控单位（默认 false）。为 true 时主控单位一起切换场景；
---否则主控单位留在原场景的同时，失去主控单位资格
---@return boolean result 跳转成功与否
function Player:jump_scene(scene_name, keep_hero) end

---设置英雄上半身朝向。【客户端】
---@param angle number 朝向角度，世界坐标系，范围 0 - 360。传小于0的值表示取消上半身单独朝向
---@param sync_to_server boolean 是否同步给服务器
---@return boolean result 是否成功
function Player:set_hero_upper_body_facing(angle, sync_to_server) end

---取消英雄上半身单独朝向。【客户端】
---花 time 的时间（单位ms）逐渐使上半身接近下半身的朝向，时间到了之后上半身不再有单独朝向。
---时间未到时如再次调用 set_hero_upper_body_facing 或 cancel_hero_upper_body_facing，
---会被后面的调用的效果覆盖。
---@param time number 过渡时间（毫秒）
---@return boolean result 是否成功
function Player:cancel_hero_upper_body_facing(time) end

---获取英雄名字。【客户端】
---如果玩家没有英雄，则返回空字符串。
---@return string name 玩家的英雄的名字
function Player:get_hero_name() end

---获取用户名。【客户端】
---若该玩家是空位，则返回空字符串。
---@return string name 用户名
function Player:user_name() end

---获取用户称号。【客户端】
---若该玩家是空位，则返回空字符串。
---@return string title 用户的称号
function Player:user_title() end

---获取队伍对象。【客户端】
---@param id integer 队伍ID
---@return Team team 队伍
function base.team(id) end

---队伍对象。【客户端】
---@class Team
local Team = {}

---获取队伍ID。【客户端】
---@return integer id 队伍ID
function Team:get_id() end

---遍历队伍中的玩家。【客户端】
---用法：for player in team:each_player() do ... end
---@return fun():Player iterator 迭代器，每次返回遍历到的玩家
function Team:each_player() end
