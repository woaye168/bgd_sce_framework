exception 模块 — 统一异常对象与抛出工具

- 路径：`#common.sce_base.exception`
- 引用：`local E = require '#common.sce_base.exception'`
- 导出：`Exception`, `to_exception`, `throw` 等

Exception 类

- `Exception:ctor(msg?)` — 构造函数，设定消息
- `Exception:set_traceback(tb)` — 设置 traceback 字符串
- `Exception:set_previous_exception(prev)` — 关联前一个异常对象
- `Exception:to_string() -> string` — 转为字符串（含链路）
- `Exception:__tostring() -> string` — 同上（元方法）

工厂与工具函数

- `E.make(msg?, previous?) -> Exception`
- `E._make(msg?, previous?) -> Exception` — 内部构造（语义同上）
- `E.to_exception(any) -> Exception` — 将任意错误包装为异常对象
- `E.throw(any)` — 直接抛出异常（结合默认处理器/traceback）

配套说明

- 与 `promise` 搭配：在失败时以 `Exception` 写入，消费侧统一结构化错误。
- 通过 `to_string()` 获取包含堆栈与前置异常的完整文本。

示例片段

```
local E = require '#common.sce_base.exception'

local ex = E.make('something wrong')
ex:set_traceback(debug.traceback())
error(ex) -- 或 E.throw(ex)
```