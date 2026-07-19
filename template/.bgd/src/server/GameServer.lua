-- 服务端脚本：GameServer.lua
-- 这是服务端的主入口文件

-- 1. 引入其他模块
local DataManager = require('src.common.DataManager')
local PlayerManager = require('src.server.PlayerManager')

-- 2. 玩家连接事件的回调函数
local function OnPlayerJoin(trg, playerObj, is_reconnect)
    -- local uid = playerObj:GetUserId()
    local uid = base.auxiliary.get_player_id(playerObj)

    -- 核心：在这里调度 Manager！
    local playerData = PlayerManager.CreatePlayerData(uid)
    PlayerManager.OnlinePlayers[uid] = playerData

    -- 验证输出
    log.info("====== 玩家上线 ======")
    log.info("UID: " .. tostring(uid))
    log.info("玩家数据已就绪")
end

-- 3. 玩家断开事件的回调函数
local function OnPlayerLeave(trg, playerObj)
    -- local uid = playerObj:GetUserId()
    local uid = base.auxiliary.get_player_id(playerObj)
    log.info("玩家 " .. tostring(uid) .. " 断开连接")

    -- 调度清理
    PlayerManager.RemovePlayerData(uid)
    log.info("玩家 " .. tostring(uid) .. " 断开连接，数据已清理。")
end

-- 4. 在文件末尾，统一注册引擎的事件
-- base.event_register(base.game, '游戏-开始', function(...)
--     -- log.info('游戏开始')
-- end)
base.event_register(base.game, '玩家-连入', OnPlayerJoin)
base.event_register(base.game, '玩家-断线', OnPlayerLeave)
-- base.event_register(base.game, '玩家-重连', OnPlayerJoin)
-- base.event_register(base.game, '玩家-放弃重连', OnPlayerLeave)
-- base.event_register(base.game, '玩家-暂时离开', OnPlayerLeave)
-- base.event_register(base.game, '玩家-回到游戏', OnPlayerJoin)
-- base.event_register(base.game, '玩家-主动退出', OnPlayerLeave)

log.info("GameServer 初始化完成，正在监听事件...")
