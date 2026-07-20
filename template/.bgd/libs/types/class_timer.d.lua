---@meta

--==============================================================
-- SCE 游戏引擎 EmmyLua 类型声明：计时器
-- 覆盖范围：
--   1. Timer 类（pause / remove / resume / restart）
--   2. base.timer / base.loop / base.wait / base.clock
-- 计时器的精度为 1 毫秒，每当计时器到期便会执行回调函数。
-- 服务端与客户端 API 完全一致（双端）。
-- 来源文档：
--   服务端-计时器-API:
--     https://doc.sce.xd.com/技术文档/服务端Lua%20API/计时器/API
--   客户端-计时器-API:
--     https://doc.sce.xd.com/技术文档/客户端Lua%20API/计时器/API
--==============================================================

---计时器对象
---@class Timer
local Timer = {}

---暂停计时器。【双端】
function Timer:pause() end

---移除计时器。【双端】
function Timer:remove() end

---恢复计时器。【双端】
---将计时器从暂停中恢复，它会恢复之前的剩余时间与执行次数继续执行。
function Timer:resume() end

---重启计时器。【双端】
---将计时器的剩余时间重置回周期时间，但不影响执行次数。
function Timer:restart() end

---启动计时器。【双端】
---count 设置为 0 表示永久循环。
---@param timeout integer 周期（毫秒）
---@param count integer 循环次数
---@param on_timer fun(timer:Timer) 回调函数，参数为计时器本身
---@return Timer timer 计时器
function base.timer(timeout, count, on_timer) end

---启动循环计时器。等价于 base.timer(timeout, 0, on_timer)。【双端】
---@param timeout integer 周期（毫秒）
---@param on_timer fun(timer:Timer) 回调函数，参数为计时器本身
---@return Timer timer 计时器
function base.loop(timeout, on_timer) end

---启动单次计时器。等价于 base.timer(timeout, 1, on_timer)。【双端】
---@param timeout integer 周期（毫秒）
---@param on_timer fun(timer:Timer) 回调函数，参数为计时器本身
---@return Timer timer 计时器
function base.wait(timeout, on_timer) end

---获取游戏时间。【双端】
---@return integer gameclock 游戏时间（毫秒）
function base.clock() end
