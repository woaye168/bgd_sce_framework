---@meta

-- ============================================================================
-- SCE 小地图（Minimap）类型声明
-- ----------------------------------------------------------------------------
-- 覆盖范围：小地图 API（图标/信号）+ 小地图配置（MiniMapTemplate / 脚本配置）
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/小地图/API
--   https://doc.sce.xd.com/技术文档/服务端Lua API/小地图/小地图配置
-- ============================================================================

---小地图图标对象。【服务端】
---创建后是不可见的，需要使用 show 来显示。
---@class MinimapIcon
local MinimapIcon = {}

---隐藏。若指定队伍，则该队伍的玩家无视同步方式立即隐藏。【服务端】
---@param team? integer 立即通知的队伍ID
function MinimapIcon:hide(team) end

---设置同步方式，默认为 'sight'。【服务端】
---@param sync string 同步方式（'all'/'sight'/'none' 等，见同步方式文档）
function MinimapIcon:set_sync(sync) end

---设置时间。客户端可以使用这个时间在图标上显示倒计时。【服务端】
---@param time integer 时间（毫秒）
function MinimapIcon:set_time(time) end

---显示。【服务端】
function MinimapIcon:show() end

---创建小地图图标。根据单位名，在小地图上创建这个单位的小地图图标。【服务端】
---@param player Player 玩家
---@param name string 单位名
---@param point Point 创建位置
---@return MinimapIcon icon 小地图图标
function base.minimap.icon(player, name, point) end

---发送小地图信号。信号名称在 Constant 中设置。【服务端】
---@param player Player 看到信号的玩家
---@param name string 信号名称
---@param point Point 信号位置
function base.minimap.signal(player, name, point) end

-- ----------------------------------------------------------------------------
-- 小地图配置（MiniMapTemplate.json 配置表结构）
-- ----------------------------------------------------------------------------

---MiniMapTemplate 布局项
---@class MiniMapTemplateLayout
---@field Name string 固定为 'MainMiniMap'
---@field Type string 固定为 'MINIMAP'
---@field Rect number[] 区域 [x, y, w, h]
---@field Color integer[] 小地图颜色 [r, g, b, a]
---@field MapSize number[] 地图场景大小 [w, h]
---@field TexturePath string 图片资源路径
local MiniMapTemplateLayout = {}

---MiniMapTemplate 样式组（可配置多个样式，用于多地图游戏）
---@class MiniMapTemplateItem
---@field TemplateName string 小地图样式名称，也是场景目录名称
---@field Anchor number[] 锚点 [x, y]
---@field Layout MiniMapTemplateLayout[] 布局列表
local MiniMapTemplateItem = {}

---MiniMapTemplate 配置（game_hud/MiniMapTemplate.json）
---@class MiniMapTemplate
---@field Scale number[] xy缩放比，通常不变 [sx, sy]
---@field Templates MiniMapTemplateItem[] 小地图样式组
local MiniMapTemplate = {}

---minimap_canvas 控件属性。【客户端】
---特殊控件 base.ui.minimap_canvas{}，用于影响 MiniMapTemplate。
---若没有 follow_target_id 或 map_ratio==0，则显示整张地图。
---@class MiniMapCanvasData
---@field follow_target_id? integer 需要跟随的单位id，绑定后以单位为小地图中心，默认为 nil
---@field map_ratio? number 一个设计像素对应的场景大小（场景地图和小地图的像素比），默认为0
---@field layout? table 像普通控件一样定制排版信息
local MiniMapCanvasData = {}

---创建小地图画布控件（用于客户端 lua 脚本中）。【客户端】
---@param data MiniMapCanvasData 控件属性
---@return table ui 控件
function base.ui.minimap_canvas(data) end
