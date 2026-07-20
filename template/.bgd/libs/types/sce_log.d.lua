---@meta

-- ============================================================================
-- SCE 引擎：日志（log）
-- ----------------------------------------------------------------------------
-- log 表由引擎 C++ 层注入 _G，提供 5 个基础级别：
--   debug / info / warn / error / alert
--
-- common/base/log.lua 会在其上继续扩展格式化方法：
--   log.debugf / log.infof / log.warnf / log.errorf / log.alertf
--   log.fail / log.failf / log.traceback_debug_bp
-- 这些扩展方法由 .emmyrc.json 的 library（script/195）自动索引合并，
-- 无需在此重复声明。
--
-- 另外 _G.log_file（= log，文件日志通道）在 common/init.lua 中定义，
-- 库已索引，同样无需在此声明。
-- ============================================================================

---引擎日志表
---@class log
log = {}

---调试级日志（最详细，通常仅在调试构建输出）
---@param msg string 日志内容
---@vararg any 附加参数，会被拼接输出
function log.debug(msg, ...) end

---信息级日志（常规运行信息）
---@param msg string 日志内容
---@vararg any 附加参数
function log.info(msg, ...) end

---警告级日志（可恢复的问题）
---@param msg string 日志内容
---@vararg any 附加参数
function log.warn(msg, ...) end

---错误级日志（运行错误，编辑器下可能弹窗）
---@param msg string 日志内容
---@vararg any 附加参数
function log.error(msg, ...) end

---严重级日志（最高级别）
---@param msg string 日志内容
---@vararg any 附加参数
function log.alert(msg, ...) end
