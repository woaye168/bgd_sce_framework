---@diagnostic disable
-- BGD 框架 init（由模板自动生成）

-- 申明框架全局命名空间
_G.bgd_const = {}
_G.bgd_config = {}
_G.bgd_api = {}

-- 导入框架入口
require('{{target}}.common')
require('{{target}}.{{module}}')
