---@meta

-- ============================================================================
-- SCE 基础库：异常体系（Exception / throw / try）
-- ----------------------------------------------------------------------------
-- 实现位于 client_base 的 @base.base.exception / @base.base.try，加载后注入：
--   _G.Exception / _G.to_exception / _G.throw
--   _G.get_default_exception_handler / _G.set_default_exception_handler
--   _G.try / _G.try_wrap / _G.FINALLY_RETURN
--   base.Exception / base.to_exception / base.throw
-- client_base 不在 .emmyrc.json 的 library 中，因此在此补充声明。
--
-- try 用法（类似 Python 的 try/except/finally）：
---```lua
---local result = try {
---    function() return risky_call() end,          -- [1] 要执行的函数
---    catch = function(err)                        -- 捕获异常
---        log.error(tostring(err))
---        return nil                               -- 返回 nil/false 吃掉异常；返回 err 继续抛出
---    end,
---    finally = function() cleanup() end,          -- 无论是否异常都会执行
---}
---```
-- ============================================================================

---异常对象。
---通过 `Exception.new(msg)` 或子类创建，tostring(err) 可得到带调用栈的完整文本。
---@class Exception
---@field msg any 异常信息
---@field traceback string 捕获时的调用栈
---@field previous_exception Exception 前序异常（rethrow 链）
---@field is_exception boolean 固定为 true，用于识别异常对象
Exception = {}

---创建异常实例
---@param msg any 异常信息
---@return Exception
function Exception.new(msg) end

---基于现有类创建异常（自动捕获调用栈）
---@param cls table 异常类（通常是 Exception 的子类）
---@vararg any 传给构造函数的参数
---@return Exception
function Exception.make(cls, ...) end

---转为字符串（含调用栈与前序异常链）
---@return string
function Exception:to_string() end

---设置调用栈（一般由框架内部调用）
---@param trace string
function Exception:set_traceback(trace) end

---设置前序异常（rethrow 时串联异常链）
---@param err Exception
function Exception:set_previous_exception(err) end

---把任意 error 值转换为 Exception（已是 Exception 则原样返回）
---@param err any
---@return Exception
function to_exception(err) end

---抛出异常（比 error() 多一层 Exception 包装与异常链维护）
---@param e Exception|any 异常对象或任意错误值
function throw(e) end

---获取默认异常处理器
---@return fun(err: any) handler
function get_default_exception_handler() end

---设置默认异常处理器（未捕获异常的最终归宿）
---@param func fun(err: any)
function set_default_exception_handler(func) end

---try 的参数表
---@class TryArgs
---@field [1] fun(...): any 要执行的函数
---@field args? any[] 传给执行函数的参数（可选；不传时参数表其余数组元素作为参数）
---@field catch? fun(err: Exception): any 异常处理；返回 nil/false 吃掉异常，返回 err 则 rethrow
---@field finally? fun(): any 收尾逻辑，必定执行；返回 FINALLY_RETURN 可让 finally 的返回值成为 try 的返回值

---类似 Python 的 try/except/finally。
---返回执行函数的返回值；发生异常时按 catch/finally 规则处理。
---@param args_table TryArgs
---@return any ...
function try(args_table) end

---把一组 try 配置包装成可重复调用的函数
---@param args_table TryArgs
---@return fun(...): any
function try_wrap(args_table) end

---在 finally 中返回此标记，可让 finally 的返回值覆盖 try 的整体返回值
---@type table
FINALLY_RETURN = {}

-- 以下成员同时挂载在 base 命名空间下（base 本体由 library 定义，此处自动合并）。

---Exception 的 base 命名空间版本，见全局 Exception
---@type Exception
base.Exception = nil

---to_exception() 的 base 命名空间版本，见全局 to_exception()
---@param err any
---@return Exception
function base.to_exception(err) end

---throw() 的 base 命名空间版本，见全局 throw()
---@param e Exception|any
function base.throw(e) end
