---@meta

-- ============================================================================
-- SCE 基础库：运行环境信息（IP / client_id / message_box / json）
-- ----------------------------------------------------------------------------
-- 以下全局由 client_base 的 @base.base.* 模块在加载时注入
-- （client_base 不在 .emmyrc.json 的 library 中，因此在此补充声明）：
--   ip.lua          -> _G.IP / _G.update_subpath
--   client_id.lua   -> _G.client_id
--   message_box.lua -> _G.message_box
--   json.lua        -> _G.json
-- ============================================================================

---当前服务器环境 IP/域名（如 'e.master.sce.xd.com'）。
---由命令行参数或环境探测得到，常用于区分内网/外网环境。
---@type string
IP = nil

---更新资源的子路径（通常等于 IP，可能带 tag 后缀）
---@type string
update_subpath = nil

---当前客户端唯一标识（启动时生成并注入）
---@type string
client_id = nil

-- ============================================================================
-- message_box：跨环境消息框（编辑器下弹系统对话框）
-- ============================================================================

---message_box.show 的参数
---@class MessageBoxData
---@field content string 文本内容（必填）
---@field title? string 标题，默认 '提示'
---@field btn_text? string 按钮文本，默认 '我知道了'
---@field show_send_log? boolean 是否显示"发送日志"，默认 true
---@field show_close? boolean 是否显示关闭按钮，默认 true

---消息框接口
---@class message_box
message_box = {}

---弹出消息框（仅在编辑器环境真正弹窗）
---@param data MessageBoxData 消息内容
---@param cb? fun() 关闭后的回调
function message_box.show(data, cb) end

---消息框关闭回调入口（由引擎回调，一般无需手动调用）
---@param message_id integer 消息 id
function message_box.close_call_back(message_id) end

-- ============================================================================
-- json：全局 JSON 编解码（rxi/json.lua 实现）
-- ============================================================================

---全局 JSON 编解码表。
---注意与引擎的 common.json_encode / common.json_decode 是两个独立实现。
---@class json
json = {}

---把 Lua 值编码为 JSON 字符串
---@param val any
---@return string
function json.encode(val) end

---把 JSON 字符串解码为 Lua 值
---@param str string
---@return any
function json.decode(str) end
