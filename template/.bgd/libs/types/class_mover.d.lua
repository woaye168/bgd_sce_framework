---@meta

-- ============================================================================
-- SCE 运动器（Mover）类型声明
-- ----------------------------------------------------------------------------
-- 覆盖范围：运动器 API（创建/属性/事件/方法）+ 跟随运动属性
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/运动器/API
--   https://doc.sce.xd.com/技术文档/服务端Lua API/运动器/跟随运动
-- ============================================================================

---运动属性表。【服务端】
---运动的属性需要在创建时作为参数传入。
---@class MoverData
---@field source? Unit 运动来源
---@field skill? Skill 关联技能（创建时自动设置为使用的技能对象，不需要再次设置）
---@field target? Point|Unit 目标。追踪运动时必须是 Unit；直线运动时是可选参数，会在 angle 与 distance 中用到
---@field mover? Unit 运动单位。mover 与 model 这2个参数需要设置其一，运动才能创建成功
---@field model? string 单位名。创建一个临时单位作为运动单位，运动结束后该单位会被移除
---@field start? Point 起点。不填则使用 mover 的位置或 source 的位置作为起点
---@field angle? number 方向。运动的初始方向，不填则为运动单位到 target 的方向
---@field distance? number 距离。直线运动的运动距离
---@field max_distance? number 最大距离。追踪运动的最大距离，默认为运动单位到 target 距离的2倍
---@field speed? number 速度
---@field accel? number 加速度
---@field min_speed? number 速度下限。一般配合加速度使用，使运动速度不会小于该值。默认为0.0
---@field max_speed? number 速度上限。一般配合加速度使用，使运动速度不会大于该值
---@field height? number 起点高度，默认为0
---@field target_height? number 终点高度（离地面）
---@field force_height? number 终点高度（离z=0平面）。直线运动默认值为 height，追踪运动默认值为 target 的受击高度
---@field parabola_height? number 抛物线高度。抛物线的顶点高度，默认为0
---@field turn_speed? number 转身速度。追踪运动每秒改变朝向的速度限制，不填表示无限制
---@field hit_type? string 碰撞类型。设置后运动单位与附近单位碰撞时触发 on_hit 事件。可选值：'敌方'/'友方'/'全部'
---@field hit_area? number 碰撞范围
---@field add_impact_area? number 附加轰击范围，默认为0。最终验证半径 = 目标碰撞半径 + hit_area + add_impact_area
---@field hit_same? boolean 碰撞同一个单位，默认为 false
---@field hit_target? boolean 碰撞追踪目标。追踪运动时，true 表示距离小于 hit_area 即完成；false 表示需到达 target 位置。默认为 true
---@field block? boolean 碰撞地形。为 true 时到达静态碰撞会触发 on_block 事件，若没有注册此事件则移除运动
---@field priority? number 优先级。新运动优先级大于等于当前运动优先级时替换当前运动，否则添加失败
---@field passive? boolean 被动运动，默认为 false。主动运动会使朝向始终朝向运动方向，且拥有定身限制时无法主动运动
---@field animation_point? string|table 已经废弃。动画点：字符串 'skill' 或表 {x, y, z}
---@field pathing_bit_prevent? string[] mover 不能通过的碰撞类型（如 'Unwalkable'/'Unflyable' 等），与 pathing_bit_required 不能有交集
---@field pathing_bit_required? string[] mover 需要的碰撞类型（通行标记），与 pathing_bit_prevent 同时生效且不能有交集
---@field angle_follow? boolean 保持相对角度（跟随运动）
---@field face_follow? boolean 朝向跟随（跟随运动）
---@field angle_speed? number 同步相对角度的速度（跟随运动）
---@field face_speed? number 同步朝向速度（跟随运动）
---@field mover_visiable? boolean 同步给跟随的单位（跟随运动）
---@field target_height_to_ground? number 距离地面高度（跟随运动）
---@field height_follow? boolean 高度是否以跟随的目标为基准（跟随运动）
local MoverData = {}

---运动器对象。【服务端】
---一个单位同一时间只能进行一个运动；单位处于跟随状态时无法添加运动。
---运动可能创建失败，需要判空后再使用。
---@class Mover
local Mover = {}

---碰撞地形事件。只有 block 设置为 true 时才可能触发，返回 true 可以移除运动。【服务端】
---@return boolean remove 是否移除运动
function Mover:on_block() end

---完成事件。直线运动跑完 distance，或追踪运动追上 target 后触发，比 on_remove 先触发。【服务端】
function Mover:on_finish() end

---碰撞单位事件。只有设置了 hit_type 后才可能触发，返回 true 可以移除运动。【服务端】
---@param unit Unit 碰撞到的单位
---@return boolean remove 是否移除运动
function Mover:on_hit(unit) end

---移除事件。运动被移除时触发。【服务端】
function Mover:on_remove() end

---批量更新。立即更新运动，直到运动完成（可用于“探路”）。【服务端】
function Mover:batch_update() end

---移除运动。【服务端】
function Mover:remove() end

---直线运动。使单位沿着固定直线轨迹移动。【服务端】
---@param data MoverData 运动属性
---@return Mover mover 运动对象（可能创建失败，需判空）
function Skill:mover_line(data) end

---追踪运动。设置一个单位作为追踪目标，使单位不停靠近目标。【服务端】
---@param data MoverData 运动属性
---@return Mover mover 运动对象（可能创建失败，需判空）
function Skill:mover_target(data) end
