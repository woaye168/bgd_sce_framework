class 模块 — 轻量级类系统

- 路径：`#common.sce_base.class`
- 引用：`local Class = require '#common.sce_base.class'`
- 导出：`class`, `instance_of`

API 概览

- `class(name, super?) -> Class`
  - 创建一个新类，`name` 为类名。
  - `super` 可为字符串（父类名）或类对象（Lua/C++）。
  - 生成构造函数 `Class.new(...)`，内部调用实例方法 `ctor(...)`（如定义）。
  - 类对象含字段 `class_name`（字符串）。

- `instance_of(obj, ClassOrName) -> boolean`
  - 判断对象是否为指定类或其父类的实例。
  - `ClassOrName` 支持类对象或类名字符串。

使用示例

```
local class = require '#common.sce_base.class'.class

local Animal = class('Animal')
function Animal:ctor(name)
  self.name = name
end

local Dog = class('Dog', Animal)
function Dog:ctor(name)
  Animal.ctor(self, name)
end

local d = Dog.new('buddy')
-- d 是 Dog，同时也是 Animal
```

注意事项

- 若与 C++ 对象混合继承，父类可使用字符串类名进行桥接。
- `ctor` 为约定构造器，若未定义则 `new(...)` 不会报错但不做初始化。