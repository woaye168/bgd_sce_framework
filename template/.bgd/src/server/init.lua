-- 导入服务端配置
require('src.server.config')

-- 导入服务端api
require('src.server.api')

-- 导入服务端常量
require_folder('src.server.const')

-- 完成初始化
log.info(string.format(
    '[ bgd-game ]  %s(%s) 初始化完成',
    bgd_config.server.game_info.name,
    bgd_config.server.game_info.version
))

-- 载入服务端逻辑
require('src.server.GameServer')