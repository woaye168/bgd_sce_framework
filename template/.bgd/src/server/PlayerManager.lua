-- PlayerManager.lua (服务端)
-- 玩家数据管理器

---@class PlayerData
---@field uid number        -- 玩家唯一标识
---@field name string       -- 玩家名字
---@field level number      -- 等级
---@field hp number         -- 当前血量
---@field max_hp number     -- 最大血量
---@field mp number         -- 当前蓝量
---@field max_mp number     -- 最大蓝量
---@field exp number        -- 当前经验值
---@field money number      -- 铜币
---@field inventory table   -- 背包

---@class PlayerManager
local M = {}

---@type table<number, PlayerData> 在线玩家的运行时数据
M.OnlinePlayers = {}

---创建玩家数据（GameServer 在玩家连入时调用）
---@param userId number
---@return PlayerData
function M.CreatePlayerData(userId)
    return M.CreateDefaultPlayerData(userId)
end

---清理玩家数据（GameServer 在玩家断线时调用）
---@param userId number
function M.RemovePlayerData(userId)
    M.OnlinePlayers[userId] = nil
end

---定义默认玩家数据结构
---@param userId number
---@return PlayerData
function M.CreateDefaultPlayerData(userId)
    return {
        uid = userId,            -- 玩家唯一标识
        name = "新手玩家",         -- 默认名字
        level = 1,               -- 初始等级
        hp = 100,                -- 当前血量
        max_hp = 100,            -- 最大血量
        mp = 50,                 -- 当前蓝量
        max_mp = 50,             -- 最大蓝量
        exp = 0,                 -- 当前经验值
        money = 0,               -- 铜币
        inventory = {}           -- 空的背包Table
    }
end

return M
