---@meta

-- ============================================================================
-- SCE 闪电（Lightning）类型声明
-- ----------------------------------------------------------------------------
-- 覆盖范围：闪电 API（创建/属性/方法）
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/闪电/API
-- ============================================================================

---闪电端点。【服务端】
---支持以下3种格式：
---1. Point - 表示端点在该点处
---2. {Point, height} - 表示端点在投影为该点、高度为 height 处
---3. {Unit, socket} - 表示端点在单位的 socket 节点处，socket 是由模型决定的字符串
---@alias LightningEnd Point|table

---闪电属性表。【服务端】
---所有特效的属性要作为创建特效时的参数传入。
---@class LightningData
---@field model string 闪电名称
---@field source LightningEnd 闪电起点
---@field target LightningEnd 闪电终点
---@field sync? string 同步方式（见同步方式文档）
local LightningData = {}

---闪电对象。【服务端】
---闪电是一种拥有2个端点的特效，端点既可以是点，也可以是单位。
---只有当闪电的2个端点均可见时，闪电才可见；若2个端点均为单位，
---那么只要其中一个单位可见，另一个单位就可见。
---@class Lightning
local Lightning = {}

---移除闪电。【服务端】
function Lightning:remove() end

---创建闪电特效。【服务端】
---@param data LightningData 闪电属性
---@return Lightning lightning 闪电对象
function Unit:lightning(data) end

---创建闪电特效。【服务端】
---@param data LightningData 闪电属性
---@return Lightning lightning 闪电对象
function Player:lightning(data) end
