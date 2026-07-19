-- 导入客户端配置
require('libs.client.config')

-- 导入客户端api
require('libs.client.api')

-- 导入客户端常量
require_folder('libs.client.const')

-- 完成初始化
log.info(
    string.format(
        '[ bgd-libs ]  %s(%s) 初始化完成', bgd_config.client.libs_info.name, bgd_config.client.libs_info.version
    )
)

-- 引擎生命周期回调
base.event_register(base.game, '游戏进入前台', function (trg, ...)
    -- log.info('[ bgd-libs ]  客户端(client) 游戏进入前台')
end)

base.event_register(base.game, '游戏-开始', function (_trg)
    -- log.info('[ bgd-libs ]  客户端(client) 游戏-开始')
end)

base.event_register(base.game, '场景-加载完成', function (trg, scene_name)
    -- log.info('场景-加载完成 ', scene_name)
end)

base.event_register(base.game, '加载地图进度', function (trg, content, percent)
    -- log.info('[ bgd-libs ]  客户端(client) 加载地图进度 ', percent)
end)

base.event_register(base.game, '按键-按下', function (_trg, key)
    -- log.info('[ bgd-libs ]  客户端(client) 按键-按下 ', key)
    -- if key == bgd_const.keyboard.y then
    -- end
end)

base.game:event('场景-加载完成', function (_trg, scene_name)
    -- log.info('[ bgd-libs ]  客户端(client) 场景-加载完成', scene_name)
end)
