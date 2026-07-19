promise 模块 — 一次性结果/错误的承诺

- 路径：`#common.sce_base.promise`
- 引用：`local P = require '#common.sce_base.promise'`
- 导出：`promise`（构造器）、`multi_promise`（聚合）等

对象创建

- `P.promise() -> Promise`
- `P.multi_promise() -> MultiPromise`

Promise 读取方法

- `get() -> result, error?` — 非阻塞读取，未就绪返回 `nil`
- `co_get() -> result, error?` — 在协程中阻塞直到就绪
- `co_result() -> result` — 协程中获取结果，错误时返回 `nil`
- `co_error() -> error` — 协程中获取错误，成功时返回 `nil`
- `ready() -> boolean` — 是否已完成（成功或失败）

Promise 写入方法

- `set(result_or_error)` / `try_set(...)` — 通用设置（成功/失败）
- `set_result(val)` / `try_set_result(val)` — 设置成功结果
- `set_error(err)` / `try_set_error(err)` — 设置错误对象/消息

MultiPromise（聚合）

- `P.multi_promise(promise_list, join_type?, timeout?) -> MultiPromise`
  - `promise_list`: Promise 数组
  - `join_type`: 聚合策略，可选值：
    - `"any_failed"` (默认) — 任一失败或全部完成时结束
    - `"any_finish"` — 任一完成时结束
    - `"all_finish"` — 全部完成时结束
  - `timeout`: 可选超时时间
- `get()`, `co_get()`, `ready()` — 与普通 Promise 相同的读取接口

as_promise（函数包装）

- `P.as_promise(func, ...) -> Promise`
  - 将函数 `func` 异步执行并返回 Promise
  - 函数成功时设置结果，异常时设置错误
  - 参数 `...` 传递给 `func`

错误与异常

- 错误对象建议使用 `exception` 模块的 `Exception`，利于统一格式与追踪。

示例片段

```
local P = require '#common.sce_base.promise'
local p = P.promise()

co.async(function()
  -- 生产者：异步完成
  p.set_result('ok')
end)

co.async(function()
  -- 消费者：等待结果
  local res, err = p.co_get()
end)
```