deque 模块 — 双端队列 / 单端队列

- 路径：`#common.sce_base.deque`
- 引用：
  - `local deque = require '#common.sce_base.deque'.create_deque`
  - `local queue = require '#common.sce_base.deque'.create_queue`

构造函数

- `create_deque() -> Deque`
- `create_queue() -> Queue`

Deque 对象方法

- `push_back(val)`, `push_front(val)` — 入队（后/前）
- `pop_back() -> val|nil`, `pop_front() -> val|nil` — 出队（后/前）
- `back() -> val|nil`, `front() -> val|nil` — 读尾/头不出队
- `__len() -> integer` — 队列长度（Lua 元方法）
- `close(clear_items?, on_clear_item?)` — 关闭队列，可选清理项与回调
- `closed() -> boolean` — 队列是否已关闭

Queue（单端队列）方法

- `push(val)` — 入队尾部
- `pop() -> val|nil` — 出队头部
- 其他行为与 `Deque` 类似，但不支持双端操作。

行为约定

- 队列为空时，`pop_*()` 返回 `nil`。
- 关闭后不再接受 `push_*()`，`pop_*()` 返回 `nil`。
- `close(true, fn)` 可清理现有元素，并对每个元素调用 `fn(item)`。

使用示例

**基本双端队列操作**
```lua
local deque = require '#common.sce_base.deque'.create_deque

local d = deque()
d:push_front(1)
d:push_front(2)
d:push_back(3)
d:push_back(4)

-- 队列内容: [2, 1, 3, 4]
assert(d:front() == 2)  -- 读头部
assert(d:back() == 4)   -- 读尾部
assert(#d == 4)         -- 长度

assert(d:pop_front() == 2)  -- 出队头部
assert(d:pop_back() == 4)   -- 出队尾部
-- 队列内容: [1, 3]
```

**单端队列操作**
```lua
local queue = require '#common.sce_base.deque'.create_queue

local q = queue()
q:push(1)
q:push(2)
q:push(3)

assert(q:pop() == 1)  -- FIFO: 先进先出
assert(q:pop() == 2)
assert(q:pop() == 3)
```

**队列关闭与清理**
```lua
local d = deque()
d:push_back(1)
d:push_back(2)
d:push_back(3)

-- 关闭并清理所有元素
local sum = 0
d:close(function(item)
    sum = sum + item  -- 对每个元素执行清理回调
end)
assert(#d == 0)       -- 队列已清空
assert(sum == 6)      -- 1 + 2 + 3
```

示例参考

- `src/common/example/deque_example.lua`