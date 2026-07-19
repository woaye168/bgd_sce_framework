-- 导入公共端配置
require('src.common.config')

-- 导入公共端api
require('src.common.api')

-- 导入公共端常量
require_folder('src.common.const')

-- 完成初始化
log.info(
    string.format(
        '[ bgd-game ]  %s(%s) 初始化完成', bgd_config.common.game_info.name, bgd_config.common.game_info.version
    )
)