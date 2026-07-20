---@meta

-- ============================================================================
-- SCE 引擎：协议打包与脚本桥接（cmsg_pack / js / game）
-- ----------------------------------------------------------------------------
-- 这三个全局均由引擎 C++ 层注入 _G。
-- ============================================================================

---引擎消息打包器（类 MessagePack 的二进制协议）
---@class cmsg_pack
cmsg_pack = {}

---把 Lua 表打包为二进制字符串
---@param data table
---@return string data_str
function cmsg_pack.pack(data) end

---把二进制字符串解包为 Lua 值
---@param data_str string
---@return any data
function cmsg_pack.unpack(data_str) end

---设置单包最大字节数（超过会拆包/报错）
---@param count integer 字节数
function cmsg_pack.set_max_pack_byte_count(count) end

---JavaScript 桥（仅 Web / 微信小游戏平台注入）
---@class js
js = {}

---执行一段 JS 代码（不取返回值）
---@param code string JS 代码
function js.execute(code) end

---执行 JS 表达式并取返回值
---@param code string JS 表达式
---@return any result 返回值（boolean / string / number 等）
function js.call(code) end

---向微信宿主发送事件
---@param name string 事件名
---@param json_args string JSON 格式的参数
function js.send_event_to_wx(name, json_args) end

---调用微信 API
---@param name string API 名
---@param json_args string JSON 格式的参数
---@return any result
function js.call_wx_api(name, json_args) end

---引擎游戏对象（仅 StateGame 状态注入，使用前需判空）。
---已知成员来自 base/voice.lua 等调用点，引擎实际能力远不止这些。
---@class game
game = {}

---获取当前对局信息
---@return table info 对局信息（已知字段：map_kind integer 地图类型，0 表示正式图）
function game.get_game_info() end

---【可选】获取当前受控单位的位置
---@return any point
function game.get_controled_unit_position() end
