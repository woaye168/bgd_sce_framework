-- 导入服务端配置
require('libs.server.config')

-- 导入服务端api
require('libs.server.api')

-- 导入服务端常量
require_folder('libs.server.const')

-- 完成初始化
log.info(string.format(
    '[ bgd-libs ]  %s(%s) 初始化完成',
    bgd_config.server.libs_info.name,
    bgd_config.server.libs_info.version
))

-- 引擎生命周期回调
base.event_register(base.game, '游戏-开始', function(...)
    -- log.info('游戏开始')
    -- log.info('package.loaded', bgd_api.json_encode_x(package.loaded, 1))
end)

base.event_register(base.game, '玩家-连入', function(trg, player, is_reconnect)
    -- local player_id = base.auxiliary.get_player_id(player)
    -- log.info('玩家-连入', player_id, is_reconnect)
end)

base.event_register(base.game, '玩家-断线', function(trg, player)
    -- local player_id = base.auxiliary.get_player_id(player)
    -- log.info('玩家-断线', player_id)
end)

base.event_register(base.game, '玩家-重连', function(trg, player)
    -- local player_id = base.auxiliary.get_player_id(player)
    -- log.info('玩家-重连', player_id)
end)

base.event_register(base.game, '玩家-放弃重连', function(trg, player)
    -- local player_id = base.auxiliary.get_player_id(player)
    -- log.info('玩家-放弃重连', player_id)
end)

base.event_register(base.game, '玩家-暂时离开', function(trg, player)
    local player_id = base.auxiliary.get_player_id(player)
    log.info('玩家-暂时离开', player_id)
end)

base.event_register(base.game, '玩家-回到游戏', function(trg, player)
    -- local player_id = base.auxiliary.get_player_id(player)
    -- log.info('玩家-回到游戏', player_id)
end)

base.event_register(base.game, '玩家-主动退出', function(trg, player)
    -- local player_id = base.auxiliary.get_player_id(player)
    -- log.info('玩家-主动退出', player_id)
end)

base.event_register(base.game, '玩家-按键按下', function(trg, player, key)
    -- log.info('玩家按下:', key)
    -- if key == bgd_const.keyboard.y then
    -- end
end)

base.event_register(base.game, '游戏-帧', function(...)
    -- log.info('游戏-帧')
    --- 服务器每秒为30帧
    -- bgd_base:initialize()
end)
