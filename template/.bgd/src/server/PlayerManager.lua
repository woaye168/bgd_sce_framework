-- PlayerManager.lua (服务端)
PlayerManager = {}
PlayerManager.OnlinePlayers = {} -- 存放在线玩家的运行时数据

-- 核心任务：定义玩家长什么样
function PlayerManager.CreateDefaultPlayerData(userId)
    -- 尝试从 DataManager 获取假数据 (假设1001是木剑，2001是红药)
    local startingWeapon = DataManager.GetItemData(1001)
    local startingPotion = DataManager.GetItemData(2001)

    local initialInventory = {}
    if startingWeapon then table.insert(initialInventory, startingWeapon) end
    if startingPotion then table.insert(initialInventory, startingPotion) end

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
        inventory = initialInventory           -- 初始背包
    }
end

function PlayerManager.RemovePlayerData(uid)
    if PlayerManager.OnlinePlayers[uid] then
        PlayerManager.OnlinePlayers[uid] = nil
    end
end