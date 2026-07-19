API 文档索引

- 模块根：`#common.sce_base.*`
- 目标：为常用基础模块提供简洁、准确的 API 与用法示例。

包含文档

- [class.md](class.md) — 轻量级类系统与继承
- [co.md](co.md) — 协程与异步工具
- [deque.md](deque.md) — 双端队列与单端队列
- [event_deque.md](event_deque.md) — 可等待事件队列（协程阻塞/超时）
- [promise.md](promise.md) — 一次性结果/错误的承诺对象
- [exception.md](exception.md) — 统一异常对象与抛出工具

约定与引用方式

- 引用：`local M = require '#common.sce_base.<module>'`
- 示例参考：`src/common/example` 下示例脚本（如 `deque_example.lua`）。