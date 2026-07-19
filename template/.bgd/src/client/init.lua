-- 导入客户端配置
require('src.client.config')

-- 导入客户端api
require('src.client.api')

-- 导入客户端常量
require_folder('src.client.const')

-- 完成初始化
log.info(
    string.format(
        '[ bgd-game ]  %s(%s) 初始化完成', bgd_config.client.game_info.name, bgd_config.client.game_info.version
    )
)
