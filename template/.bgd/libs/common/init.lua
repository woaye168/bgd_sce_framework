-- 导入公共端配置
require('libs.common.config')

-- 导入公共端api
require('libs.common.api')

-- 导入公共端常量
require_folder('libs.common.const')

-- 完成初始化
log.info(
    string.format(
        '[ bgd-libs ]  %s(%s) 初始化完成', bgd_config.common.libs_info.name, bgd_config.common.libs_info.version
    )
)
