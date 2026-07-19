event_deque 模块 — 带等待能力的事件队列

- 路径：`#common.sce_base.event_deque`
- 引用：
  - `local event_deque = require '#common.sce_base.event_deque'.create_event_deque`
  - `local event_queue = require '#common.sce_base.event_deque'.create_event_queue`

构造函数

- `create_event_deque() -> EventDeque`
- `create_event_queue() -> EventQueue`

EventDeque 对象方法（核心）

- `push_front(val)`, `push_back(val)` — 入队并唤醒等待者（如有）
- `pop_front() -> val|nil`, `pop_back() -> val|nil` — 非阻塞出队
- `co_pop_front(timeout_s?) -> val|nil`, `co_pop_back(timeout_s?) -> val|nil`
  - 在协程中阻塞等待元素；可选超时时间（秒）。
  - 超时返回 `nil`。
- `close(clear_items?, on_clear_item?)` — 关闭并唤醒所有等待者，后续 `pop_*` 返回 `nil`
- `closed() -> boolean`

EventQueue（单端）

- `push(val)`, `pop()`, `co_pop(timeout_s?)` — 语义同上，面向单端队列。

实用模式

- 生产者将事件 `push_*` 入队；消费者在协程中 `co_pop_*` 等待。
- 配合 `co.sleep_one_frame()` 可实现帧级调度。

使用示例

**生产者-消费者模式**
```lua
local event_deque = require '#common.sce_base.event_deque'.create_event_deque
local co = require '#common.sce_base.co'

local d = event_deque()

-- 生产者协程：延迟生产数据
co.async(function()
    co.sleep(500)  -- 等待 500ms
    d:push_back(1)
    co.sleep(1000) -- 等待 1000ms
    d:push_back(2)
    d:push_back(3)
end)

-- 消费者协程：阻塞等待数据
co.async(function()
    local ret = d:co_pop_front()  -- 阻塞等待第一个元素
    assert(ret == 1)
    
    local ret = d:co_pop_front()  -- 阻塞等待第二个元素
    assert(ret == 2)
end)
```

**超时机制**
```lua
local event_queue = require '#common.sce_base.event_deque'.create_event_queue

local q = event_queue()

co.async(function()
    -- 2秒后生产数据
    co.sleep(2000)
    q:push(42)
end)

co.async(function()
    -- 等待数据，1秒超时
    local ret, err = q:co_pop(1000)
    assert(err == 'timeout')  -- 超时返回
    
    -- 等待数据，3秒超时（足够长）
    local ret, err = q:co_pop(3000)
    assert(ret == 42)  -- 成功获取数据
end)
```

**非阻塞操作**
```lua
local d = event_deque()

-- 非阻塞操作，立即返回
local ret, err = d:pop_front()
assert(ret == nil and err == 'empty')

-- 生产数据
d:push_back('hello')

-- 非阻塞操作，立即返回数据
local ret, err = d:pop_front()
assert(ret == 'hello' and err == nil)
```

**队列关闭与唤醒**
```lua
local d = event_deque()

co.async(function()
    -- 消费者等待数据
    local ret, err = d:co_pop_front()
    assert(err == 'closed')  -- 队列被关闭，等待被唤醒
end)

co.async(function()
    co.sleep(1000)
    d:close()  -- 关闭队列，唤醒所有等待者
end)
```

示例参考

- `src/common/example/deque_example.lua`（含 `event_deque` 使用示例）