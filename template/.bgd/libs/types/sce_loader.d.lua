---@meta

-- ============================================================================
-- SCE 引擎：模块加载器与运行时标志
-- ----------------------------------------------------------------------------
-- 以下全局由引擎 C++ 层在创建 Lua 虚拟机时注入 _G，
-- 任何 Lua 源码中都找不到定义，因此在此补充声明。
-- ============================================================================

---按模块名加载模块（与 require 类似，由引擎预加载环境提供）。
---
---支持三种写法：
---```lua
---include 'base.game'              -- 副作用加载（不使用返回值）
---local co = include 'base.co'     -- 加载并取出模块表
---include '@common.base.player'    -- 带 @ 前缀的别名路径
---```
---@param modname string 点分隔的模块路径，可带 @ 别名前缀
---@return any # 模块返回值（通常是模块表）
function include(modname) end

---按文件夹批量加载其下所有模块（引擎预加载环境提供）。
---@param folder string 模块文件夹路径（点分隔，如 'src.server.const'）
function require_folder(folder) end

---引擎主地图标识字符串（启动时注入）。
---common/main.lua 会据此派生 _G.__GAME_ID__（去掉 '_eq' 后缀）。
---@type string
__MAIN_MAP__ = '__MAIN_MAP__'

---当前 Lua 状态机名称（引擎注入），用于区分运行环境：
---- 'StateEditor'      编辑器进程
---- 'StateGame'        游戏进程（客户端/服务端）
---- 'StateApplication' 应用进程（大厅/更新器）
---@type 'StateEditor'|'StateGame'|'StateApplication'
__lua_state_name = 'StateGame'
