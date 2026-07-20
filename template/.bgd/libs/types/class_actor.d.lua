---@meta

-- ============================================================================
-- SCE 表现（Actor）类型声明（双端合并）
-- ----------------------------------------------------------------------------
-- 覆盖范围：服务端表现 API + 客户端表现 API
-- 服务器通过 rpc 调用客户端的表现 api，两端基本一致。
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/表现/API
--   https://doc.sce.xd.com/技术文档/客户端Lua API/表现/API
-- ============================================================================

---表现对象。【双端】
---@class Actor
local Actor = {}

---销毁表现。【双端】
---@param force? boolean 不填默认为 false。
---对 ModelActor，true 表示不播放 death 动画，直接销毁；
---对 SoundActor，false 表示当前 Sound 立刻开始按照 ActorSoundData 里 FadeTime 淡出，淡出后销毁 actor
function Actor:destroy(force) end

---设置表现所属玩家，影响该表现对于不同玩家的可见性。【双端】
---@param owner_id number 玩家的 slot_id
function Actor:set_owner(owner_id) end

---动态替换表现的资源，比如模型表现换模型，音效表现换音效，特效表现换特效。【双端】
---@param asset string ActorModelData 或者 ActorSoundData 中的资源名
function Actor:set_asset(asset) end

---仅对拥有 CEAnimatedModel 的模型表现生效，显示或隐藏阴影。【双端】
---@param enable boolean 是否显示阴影
function Actor:set_shadow(enable) end

---设置表现在场景中的位置，attach 之后设置表现相对于父节点的偏移。
---可传 (x, y, z) 或者 (point)。【双端】
---@param x number|Point x 坐标或 point
---@param y? number y 坐标
---@param z? number z 坐标
function Actor:set_position(x, y, z) end

---获取 actor 当前的世界坐标位置。
---由于弱同步，服务端无返回值，所以仅客户端有这个 api。【客户端】
---@return Point point 世界坐标位置
function Actor:get_position() end

---设置表现相对于地面的高度，一次性设置。set_position 和 set_ground_z 后调用的覆盖先调用的。
---对于 attach 到其他单位/表现的表现不生效。【双端】
---@param z number 高度
function Actor:set_ground_z(z) end

---设置表现在场景中的朝向（欧拉角）。【双端】
---@param x number 欧拉角 pitch，绕 x 轴旋转值
---@param y number 欧拉角 yaw，绕 y 轴旋转值
---@param z number 欧拉角 roll，绕 z 轴旋转值
function Actor:set_rotation(x, y, z) end

---设置表现在场景中的平面内朝向（为了兼容旧地图保留的）。
---等价于 actor:set_rotation(0, 0, facing)。【服务端】
---@param facing number 等价于欧拉角 roll，绕 z 轴旋转值
function Actor:set_facing(facing) end

---设置表现在场景中的比例大小。【双端】
---@param x number 三个维度的比例大小均为 x
function Actor:set_scale(x) end

---将表现附着在别的表现或者单位上。【双端】
---@param target Unit|Actor|number 可以是单位/表现/actor_id/unit_id
---@param socket? string 可以不填，或者填 target 上的 socket 名字
function Actor:attach_to(target, socket) end

---播放音效/特效，当前支持音效/特效表现。【双端】
function Actor:play() end

---模型特效播放动画。【双端】
---@param anim string 模型表现 Asset 路径下的某个动画文件名，不带 .ani
---@param params? table 播放参数，当前支持 loop（默认 false）、speed（默认 1.0）
function Actor:play_animation(anim, params) end

---停止音效/特效，当前支持音效/特效表现。
---如果是模型表现，表示停止通过 play_animation 播放的动画，开始播放 stand 动画；
---如果当前没有播放通过 play_animation 播放的动画，则没有效果。【双端】
---@param fade? boolean 仅客户端支持，不填默认为 false。
---仅对 SoundActor 有效，true 表示当前播放的 sound 按照 ActorSoundData 里的 FadeTime 时间淡出后停止
function Actor:stop(fade) end

---暂停音效，当前只支持音效表现。【双端】
function Actor:pause() end

---继续播音效，当前只支持音效表现。【双端】
function Actor:resume() end

---设置音量，当前只支持音效表现。【双端】
---@param volume number 音量
function Actor:set_volume(volume) end

---创建表现。【服务端】
---@param name string ActorData 中声明的表现名
---@param exclude? table 哪些玩家不需要创建表现，比如 {1,2} 表示玩家1,2 客户端不需要创建表现
---@param sync? boolean attach_to 单位后是否跟单位同步（即跟单位一起在视野出现或消失），默认为 true。
---典型应用场景是 ForceOneShot=1 的模型表现：sync=true 时单位再次出现在视野会播 stand、death 动画然后销毁；
---sync=false 时单位再次出现在视野里表现不会出现
---@return Actor actor 表现
function base.actor(name, exclude, sync) end

---创建表现。【客户端】
---@param name string ActorData 中声明的表现名
---@return Actor actor 表现
function base.actor(name) end

---actor_info 返回的映射表信息。【双端】
---@class ActorInfo
---@field actor_map table<number, Actor> actor_id 到 actor 的映射表（actor id 均为负数）
---@field server_actor_map table<number, Actor> 服务器通知创建的 server_actor_id 到 actor 的映射表（仅客户端）。
---服务器创建 api 会先生成一个 s_id（负数），然后通知客户端创建一个 actor，
---客户端自己生成 actor_id（负数），并维护 s_id 到 actor 的映射在 server_actor_map 里
local ActorInfo = {}

---获取当前所有的 id 到 actor 映射表。【双端】
---@return ActorInfo info 映射表信息
function base.actor_info() end

---设置音效类型音量，音效的音量等于音效类型音量乘以音效资源的音量。【客户端】
---@param category string 类型
---@param volume number 音量
function game.sound_category_volume(category, volume) end

---停止播放某一类型的所有音效表现。【客户端】
---@param category string 类型
function game.sound_category_stop(category) end

---改 C++ 表里的声音的音量。注意：不会改变 base.table.sound 里的音量数据，
---但会影响运行时之前或之后创建的所有用到这个 sound 的 SoundActor 的音量。【客户端】
---@param name string ActorSoundData 里的表名
---@param volume number 调整后的声音大小
function game.set_sound_table_volume(name, volume) end

---改 C++ 表里的音效表现的衰减系数。注意：不会改变 base.table.actor 里的数值，
---但会影响运行时之前或之后创建的所有用到这个衰减系数的 Actor。【客户端】
---@param name string ActorData 里的表名
---@param value number 调整后的衰减系数
function game.set_sound_table_rolloff_factor(name, value) end

---改 C++ 表里的音效表现的最远收听距离。注意：不会改变 base.table.actor 里的数值，
---但会影响运行时之前或之后创建的所有用到这个最远收听距离的 Actor。【客户端】
---@param name string ActorData 里的表名
---@param value number 调整后的最远收听距离
function game.set_sound_table_far_distance(name, value) end
