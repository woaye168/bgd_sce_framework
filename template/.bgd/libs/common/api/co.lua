---@diagnostic disable

local table_pack = table.pack
local table_unpack = table.unpack
local coroutine_running = coroutine.running
local coroutine_create = coroutine.create
local coroutine_yield = coroutine.yield
local coroutine_resume = coroutine.resume
local coroutine_wrap = coroutine.wrap
local error = error
local type = type
local tostring = tostring
local xpcall = xpcall
local base_next = base.next
local base_wait = base.wait
local debug_traceback = debug.traceback
local debug_sethook = debug.sethook

local error_pending_kill = base.error_pending_kill or {}
base.error_pending_kill = error_pending_kill

local function coroutine_resume_with_check(co, ...)
    local ok, err = coroutine_resume(co, ...)
    if ok or err == error_pending_kill then
        return
    end
    -- log.error(debug_traceback(co, tostring(err)))
    log.error(err)
    if debug_bp then
        debug_bp()
    end
end

-- 将异步回调转换为协程
local function wrap(func)
    return function(...)
        -- if not check(func) then return false end
        local co, main = coroutine_running()
        if main then
            log.error('不能用主线程包装协程！！')
            return func
        end

        local has_yield = false
        local ret = nil
        local called = false
        local cb = function(...)
            if called then
                return
            end
            called = true
            if not has_yield then
                ret = table_pack(...)
                return
            end
            -- local curr = coroutine.running()
            -- log_file.info(('\n>>>0\nresume\niiid: %d, curr: [thread:%d] :%s\nco: [thread:%d]:%s\n<<<0\n'):format(iiid, get_tm(curr), debug.traceback(curr), get_tm(co), debug.traceback(co)))
            -- log_file.info(('\n>>>1\nreturn: %s\niiid: %d, co: [thread:%d] :%s\n<<<1\n'):format(tostring(result), iiid, get_tm(co), debug.traceback(co)))
            return coroutine_resume_with_check(co, ...)
        end
        local args = table_pack(...)
        args[args.n + 1] = cb
        func(table_unpack(args, 1, args.n + 1))
        if ret then
            -- log_file.info(('\n>>>2\nimmediately return\niiid: %d, co: [thread:%d]'):format(iiid, get_tm(co)))
            -- 如果func调用时在内部立即调用了cb, 则不能等yield返回, 应该立即return
            return table_unpack(ret, 1, ret.n)
        end
        has_yield = true
        -- log_file.info(('\n>>>2\nyield\niiid: %d, co: [thread:%d] :%s\n<<<2\n'):format(iiid, get_tm(co), debug.traceback(co)))
        return coroutine_yield()
    end
end

local function call(func, ...)
    return wrap(func)(...)
end

local function async(fn, ...)
    if type(fn) ~= 'function' then
        -- log.error(debug_traceback('参数1必须是一个函数！！'))
        log.error('参数1必须是一个函数！！')
        return false
    end

    local co = coroutine_create(fn)
    return coroutine_resume_with_check(co, ...)
end

local async_next = (function(fn, ...)
    local args = table_pack(...)
    base_next(function()
        async(fn, table_unpack(args, 1, args.n))
    end)
end)

local sleep = function(timeout)
    local _sleep = wrap(base_wait)
    return _sleep(timeout)
end

local sleep_one_frame = function()
    local _sleep_one_frame = wrap(base_next)
    return _sleep_one_frame()
end

local will_async = function(func)
    return function(...)
        async(func, ...)
    end
end

---协程模块
---@class CommonCo
local module = {
    wrap = wrap,
    call = call,
    async = async,
    async_next = async_next,
    will_async = will_async,
    sleep = sleep,
    sleep_one_frame = sleep_one_frame,
}

return module
