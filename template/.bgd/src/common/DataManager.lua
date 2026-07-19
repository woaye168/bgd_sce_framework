-- DataManager.lua (服务端)
-- 物品配置数据管理器

---@class ItemConfig
---@field id number
---@field name string
---@field type string
---@field atk? number
---@field heal? number

---@class DataManager
local M = {}

---@type table<number, ItemConfig>
M.ItemConfigs = {
    -- 测试数据
    [1001] = { id = 1001, name = "新手木剑", type = "weapon", atk = 5 },
    [2001] = { id = 2001, name = "小红药", type = "consumable", heal = 20 }
}

---获取物品配置（等之后策划给你表了再填逻辑）
---@param itemId number
---@return ItemConfig|nil
function M.GetItemData(itemId)
    if not M.ItemConfigs[itemId] then
        return nil
    end
    return M.ItemConfigs[itemId]
end

return M
