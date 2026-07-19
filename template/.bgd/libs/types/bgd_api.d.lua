-- BGD 框架全局命名空间声明
-- 三个全局命名空间由框架 init 注入（见 templates/init_tp_libs.lua），
-- 具体字段由各 api/config/const 文件在加载时挂载，EmmyLua 会跨文件自动推断。

---BGD 全局 API 命名空间（bgd_api.common / bgd_api.server / bgd_api.client）
bgd_api = {}

---BGD 全局配置命名空间（bgd_config.common / bgd_config.server / bgd_config.client）
bgd_config = {}

---BGD 全局常量命名空间（bgd_const.<常量名>）
bgd_const = {}
