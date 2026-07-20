---@meta

-- ============================================================================
-- SCE 引擎：区域（Region）（服务端）
-- ----------------------------------------------------------------------------
-- 覆盖范围：
--   * Region     区域对象（由多个顶点构成的闭合形状）
--   * base.region 区域创建接口
--
-- 说明：以下概念页经确认不包含 API，仅作记录：
--   场景 / 逻辑帧 / 同步方式 / 视野 / 伤害结算 / 护盾（均为概念说明，
--   视野页提到的 add_provide_sight / remove_provide_sight 属于单位 API，
--   伤害结算页提到的 add_damage 属于技能/普通攻击 API，护盾通过状态(Buff)维护）。
--
-- 来源文档：
--   服务端-区域：
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E6%9C%8D%E5%8A%A1%E7%AB%AFLua%20API/%E5%8C%BA%E5%9F%9F/%E5%8C%BA%E5%9F%9F
--   服务端-一些概念（场景/逻辑帧/视野/同步方式/伤害结算/护盾）：
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E6%9C%8D%E5%8A%A1%E7%AB%AFLua%20API/%E4%B8%80%E4%BA%9B%E6%A6%82%E5%BF%B5/%E5%9C%BA%E6%99%AF
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E6%9C%8D%E5%8A%A1%E7%AB%AFLua%20API/%E4%B8%80%E4%BA%9B%E6%A6%82%E5%BF%B5/%E9%80%BB%E8%BE%91%E5%B8%A7
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E6%9C%8D%E5%8A%A1%E7%AB%AFLua%20API/%E4%B8%80%E4%BA%9B%E6%A6%82%E5%BF%B5/%E8%A7%86%E9%87%8E
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E6%9C%8D%E5%8A%A1%E7%AB%AFLua%20API/%E4%B8%80%E4%BA%9B%E6%A6%82%E5%BF%B5/%E5%90%8C%E6%AD%A5%E6%96%B9%E5%BC%8F
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E6%9C%8D%E5%8A%A1%E7%AB%AFLua%20API/%E4%B8%80%E4%BA%9B%E6%A6%82%E5%BF%B5/%E4%BC%A4%E5%AE%B3%E7%BB%93%E7%AE%97
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E6%9C%8D%E5%8A%A1%E7%AB%AFLua%20API/%E4%B8%80%E4%BA%9B%E6%A6%82%E5%BF%B5/%E6%8A%A4%E7%9B%BE
-- ============================================================================

---区域对象，由多个顶点构成的闭合形状。
---
---当单位进入该区域时会触发 on_enter 事件，当单位离开该区域时会触发 on_leave
---事件。此外创建区域时，已经在区域内的单位也会触发 on_enter 事件，移除区域时
---还待在区域内的单位也会触发 on_leave 事件。
---@class Region
local Region = {}

---事件：单位进入区域。【服务端】
---注意：创建区域时，已经在区域内的单位也会触发本事件。
---@param unit Unit 进入区域的单位
function Region:on_enter(unit) end

---事件：单位离开区域。【服务端】
---注意：移除区域时还待在区域内的单位也会触发本事件。
---@param unit Unit 离开区域的单位
function Region:on_leave(unit) end

---移除区域。【服务端】
---由 C++ 实现的 API。
---@param notify boolean 是否触发 on_leave
function Region:remove(notify) end

---base 库区域命名空间。【服务端】
base.region = base.region or {}

---创建多边形区域。【服务端】
---顶点列表是一个存放了多个 Point 的序列，这些点依次连接起来（最后一个点连接
---第一个点）形成一个区域。注意，如果这个列表无法形成一个闭合形状（比如连线
---有交叉），那么相关事件的行为是未定义的。
---
---用法：
---```lua
---local region = base.region.polygon({
---    points = { point1, point2, point3, point4 },
---}, scene_name)
---```
---@param list {points:Point[]} 顶点列表
---@param scene_name string 场景
---@return Region region 区域
function base.region.polygon(list, scene_name) end
