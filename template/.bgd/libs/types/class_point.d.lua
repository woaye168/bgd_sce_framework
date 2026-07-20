---@meta

-- ============================================================================
-- SCE 引擎：点（Point）/ 屏幕位置（ScreenPos）/ 坐标转换（双端合并声明）
-- ----------------------------------------------------------------------------
-- 覆盖范围：
--   * Point     点 / 场景点（XY 平面上的位置，客户端的点额外包含高度 z）
--   * ScreenPos 屏幕位置（画面坐标，左上角为 (0,0)，X 轴向右为正，Y 轴向下为正）
--   * game      客户端坐标转换（场景坐标 <-> 屏幕坐标）
--
-- 说明：文档中“场景点”页描述的就是 Point 类（客户端点带高度），未单独定义
-- ScenePoint 类型，故此处统一声明为 Point。
--
-- 来源文档：
--   服务端-点(场景点)：
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E6%9C%8D%E5%8A%A1%E7%AB%AFLua%20API/%E7%82%B9/%E5%9C%BA%E6%99%AF%E7%82%B9
--   服务端-屏幕位置：
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E6%9C%8D%E5%8A%A1%E7%AB%AFLua%20API/%E7%82%B9/%E5%B1%8F%E5%B9%95%E4%BD%8D%E7%BD%AE
--   客户端-场景点：
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E5%AE%A2%E6%88%B7%E7%AB%AFLua%20API/%E7%82%B9/%E5%9C%BA%E6%99%AF%E7%82%B9
--   客户端-屏幕位置：
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E5%AE%A2%E6%88%B7%E7%AB%AFLua%20API/%E7%82%B9/%E5%B1%8F%E5%B9%95%E4%BD%8D%E7%BD%AE
--   客户端-坐标转换：
--     https://doc.sce.xd.com/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/%E5%AE%A2%E6%88%B7%E7%AB%AFLua%20API/%E7%82%B9/%E5%9D%90%E6%A0%87%E8%BD%AC%E6%8D%A2
-- ============================================================================

---点对象，表示 XY 平面上的位置。
---
---引擎内部不会修改一个已有点的位置（建议也不要自己去修改），所有会返回点的
---API 都会返回一个创建出来的点。例如将点向某个方向移动，实际上是创建了一个
---新的点，而不是修改了传入的点。
---
---与服务器使用的点不同，客户端使用的点包含 **高度**，但在对 2 个点之间求长度
---或角度时，依然只计算 XY 平面。
---
---支持的运算符：
---- `-point`         取反，返回新的点，这个点的 x,y,z = -x,-y,-z
---- `point + point2` 相加，返回新的点
----                  [new_x, new_y, new_z] = [self.x + point2.x, self.y + point2.y, self.z + point2.z]
---
---以下语法糖即将被废弃，请勿使用：
---- `point / target`            等价于 point:angle(target)
---- `point * target`            等价于 point:distance(target)
---- `point - {angle, distance}` 等价于 point:polar_to{angle, distance}
---@class Point
---@operator unm: Point
---@operator add(Point): Point
local Point = {}

---求角度。【双端】
---@param target Point 目标点
---@return number angle `point` 到 `target` 的方向，范围为 (-180, 180]
function Point:angle(target) end

---复制。【双端】
---@return Point new_point 复制出来的点
function Point:copy() end

---求距离。【双端】
---@param target Point 目标点
---@return number distance `point` 到 `target` 的距离
function Point:distance(target) end

---获取点（返回对象自己，不会创建新点）。【双端】
---@return Point point 自己
function Point:get_point() end

---获取坐标。【双端】
---@return number x X坐标
---@return number y Y坐标
function Point:get_xy() end

---获取高度。【客户端】
---@return number height 高度
function Point:get_height() end

---获取位置（点对应的画面位置）。【客户端】
---@return ScreenPos position 画面位置
function Point:get_position() end

---是否是静态碰撞。【服务端】
---由 C++ 实现的 API。
---@param scene_name string 该点所在的场景名
---@param prevent_bits? string|table 格子有该标记则阻挡，默认是所有标记
---@param required_bits? string|table 格子没有该标记则阻挡，默认没有标记
---@return boolean result 是否是静态碰撞
function Point:is_block(scene_name, prevent_bits, required_bits) end

---当前坐标在当前场景下是否是碰撞。【客户端】
---@return boolean|nil flag 是否是碰撞（有任意非通行 bit 都算碰撞）。
---如果返回 nil 则表示客户端 Collision.dat 读取有问题
function Point:is_block() end

---是否可见，判断点能否被 `dest` 看到。【服务端】
---由 C++ 实现的 API。如果 `dest` 是单位，则会使用控制 `dest` 的玩家来计算视野。
---@param dest Unit|Player 单位/玩家
---@param scene_name string 场景名
---@return boolean result 结果
function Point:is_visible(dest, scene_name) end

---播放音效。多次播放的音效互不影响。【服务端】
---由 C++ 实现的 API。当玩家的英雄与点的距离超过截断距离时，将听不到音效。
---@param name string 音效名（音效表 SoundData.ini 里填的那个）
---@param distance number 截断距离
---@param scene_name string 场景名
function Point:play_sound(name, distance, scene_name) end

---移动（按方向与距离创建一个新的点）。【双端】
---@param pos {angle:number, distance:number} angle 为方向，distance 为距离
---@return Point new_point 新的点
function Point:polar_to(pos) end

---坐标系映射。【双端】
---self 的当前坐标系是：origin: base.point(0, 0), facing: 0。
---将 self 从当前坐标系映射到坐标系 (origin, facing) 后，返回 self 在该坐标系里的位置。
---@param origin Point 目标坐标系的原点
---@param facing number 目标坐标系在 z 轴旋转的角度
---@return Point new_point 相对于目标坐标系的位置
function Point:to_coordinate(origin, facing) end

---创建点。【双端】
---客户端使用的点包含高度，可额外传入 z。
---@param x number X坐标
---@param y number Y坐标
---@param z? number 高度（仅客户端）
---@return Point point 点
function base.point(x, y, z) end

---屏幕位置对象，使用 (X, Y) 的形式描述画面上的一个位置。
---描述时，以屏幕左上角为 (0, 0)，X 轴向右为正，Y 轴向下为正。
---@class ScreenPos
local ScreenPos = {}

---获取坐标。【双端】
---@return integer x X坐标
---@return integer y Y坐标
function ScreenPos:get_xy() end

---获取点（画面位置对应的点）。【客户端】
---@return Point point 点
function ScreenPos:get_point() end

---创建屏幕位置。【双端】
---@param x integer X坐标
---@param y integer Y坐标
---@return ScreenPos position 位置
function base.position(x, y) end

---客户端 game 命名空间（坐标转换）。【客户端】
game = game or {}

---场景内的坐标转成屏幕坐标。【客户端】
---@param x number 场景坐标x
---@param y number 场景坐标y
---@param z number 场景坐标z
---@return number x 屏幕坐标x
---@return number y 屏幕坐标y
function game.world_to_screen(x, y, z) end

---屏幕坐标转场景内的坐标（屏幕射线与地形的交点）。【客户端】
---@param x number 屏幕坐标x
---@param y number 屏幕坐标y
---@return number x 场景坐标x
---@return number y 场景坐标y
---@return number z 场景坐标z
function game.screen_to_world(x, y) end

---屏幕坐标转场景 XOY 平面坐标。【客户端】
---screen_to_world 表示的是屏幕射线与地形的交点，screen_to_xy 表示的是跟 XOY 平面的交点。
---@param x number 屏幕坐标x
---@param y number 屏幕坐标y
---@return number x 场景坐标x
---@return number y 场景坐标y
function game.screen_to_xy(x, y) end
