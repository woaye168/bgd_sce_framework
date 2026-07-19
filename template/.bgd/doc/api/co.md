co 模块 — 协程与异步工具

- 路径：`#common.sce_base.co`
- 引用：`local co = require '#common.sce_base.co'`
- 主要导出：`wrap`, `async`, `async_next`, `sleep`, `sleep_one_frame`

API 概览

- `wrap(fn_with_callback) -> fn_co`
  - 将回调式异步函数包装为可在协程中 `yield`/恢复的函数。

- `async(fn)`
  - 在新协程中异步执行 `fn`，可用于启动异步任务。

- `async_next(fn)`
  - 在下一帧异步执行 `fn`，配合渲染/帧驱动流程。

- `sleep(seconds)`
  - 当前协程休眠指定秒数。

- `sleep_one_frame()`
  - 当前协程休眠一帧。

配套说明

- 内部包含 `coroutine_resume_with_check` 的错误包装，用于恢复协程时的错误追踪与处理。
- 与 `event_deque`、`promise` 搭配可实现“等待事件”或“等待结果”的自然写法。

示例片段

```
local co = require '#common.sce_base.co'

co.async(function()
  co.sleep(0.5)
  -- 下一帧继续执行
  co.async_next(function() print('next frame') end)
end)
```