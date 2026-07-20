---@meta

-- ============================================================================
-- SCE 引擎：编辑器上下文（ImportSCEContext）
-- ----------------------------------------------------------------------------
-- ImportSCEContext 由引擎注入，仅在编辑器相关进程中可用，
-- 返回的 SCEContext 用于访问引擎类注册表、状态机基类、消息框等。
-- 游戏客户端纯 Lua 环境下调用前应先判空（参见 base/state_machine.lua）。
-- ============================================================================

---编辑器消息框对象
---@class EMessageBox
local EMessageBox = {}

---设置消息框字体
---@param family string 字体族名，如 'Regular'
function EMessageBox:set_font_family(family) end

---弹出消息框
---@param content string 内容，格式为 '内容;;标题'
function EMessageBox:begin(content) end

---编辑器通用接口（SCE.Common）
---@class SCECommon
local SCECommon = {}

---弹出简易消息框
---@param content string 文本内容
---@param message_id? integer 消息 id（需要关闭回调时传入）
function SCECommon.show_message_box(content, message_id) end

---弹出可配置消息框（支持标题/按钮/关闭回调）
---@param content string 文本内容
---@param title string 标题
---@param btn_text string 按钮文本
---@param show_send_log boolean 是否显示"发送日志"
---@param show_close boolean 是否显示关闭按钮
---@param message_id? integer 消息 id（需要关闭回调时传入）
function SCECommon.show_message_box_extra(content, title, btn_text, show_send_log, show_close, message_id) end

---SCE 编辑器上下文
---@class SCEContext
---@field ClassMap table<string, string> 类名 -> 父类名 的继承注册表（class() 会写入）
---@field StateMachine table 引擎状态机基类，可作为 class() 的父类
---@field SMState table 引擎状态基类，可作为 class() 的父类
---@field Common SCECommon 编辑器通用接口
local SCEContext = {}

---获取编辑器消息框对象
---@return EMessageBox
function SCEContext:GetEMessageBox() end

---导入 SCE 编辑器上下文（引擎注入，仅编辑器环境可用）。
---```lua
---if ImportSCEContext and __lua_state_name == 'StateGame' then
---    local SCE = ImportSCEContext()
---end
---```
---@return SCEContext
function ImportSCEContext() end

---LuaPanda 调试器的断点函数。
---由 common/preload/luapanda.lua 在连接调试器后注入（_G.debug_bp = LuaPanda.BP），
---未连接调试器时为 nil，调用前必须判空：
---```lua
---if debug_bp then debug_bp() end
---```
---@type fun(...)|nil
debug_bp = nil
