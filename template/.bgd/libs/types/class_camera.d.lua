---@meta

-- ============================================================================
-- SCE 镜头（Camera）类型声明
-- ----------------------------------------------------------------------------
-- 覆盖范围：客户端镜头 API
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/客户端Lua API/镜头/镜头
-- ============================================================================

---摄像机状态。【客户端】
---@class CameraStatus
---@field position table 摄像机位置 {x, y, z}
---@field rotation table 摄像机旋转 {pitch, raw, roll}
---@field focus_distance number 离观察点距离
local CameraStatus = {}

---摄像机设置。【客户端】
---@class CameraSettings
---@field position? table|Point 摄像机位置 {x, y, z} 或 point
---@field rotation? table 摄像机旋转 {pitch, raw, roll}
---@field focus_distance? number 离观察点距离
---@field time? number 变化时间，设置后朝目标点移动的时间
local CameraSettings = {}

---获取摄像机的位置和旋转。【客户端】
---@return CameraStatus camera_status 摄像机状态
function game.get_camera() end

---设置摄像机的位置、旋转。【客户端】
---@param settings CameraSettings 摄像机设置
function game.set_camera(settings) end

---设置相机跟随单位。【客户端】
---@param unit? Unit 跟随的单位，为空时取消跟随
function base.game:camera_focus(unit) end

---获取摄像机焦点区域。当使用 min/max_focus_position 时返回的就是 min/max_focus_position，
---使用场景边界时根据场景大小计算。【客户端】
---@return number min_x x轴最小值
---@return number min_y y轴最小值
---@return number max_x x轴最大值
---@return number max_y y轴最大值
function game.get_camera_area() end

---判断摄像机是否是锁定状态。【客户端】
---@return boolean locked 是否锁定
function game.is_camera_locked() end

---锁定摄像机，效果跟服务器的 player:lock_camera() 一致。【客户端】
function game.lock_camera() end

---解锁摄像机，效果跟服务器的 player:unlock_camera() 一致。【客户端】
function game.unlock_camera() end
