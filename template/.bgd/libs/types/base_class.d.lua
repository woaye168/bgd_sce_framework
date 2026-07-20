---@meta

-- ============================================================================
-- SCE 基础库：轻量级面向对象（class / instance_of）
-- ----------------------------------------------------------------------------
-- 实现位于 client_base 的 @base.base.class，加载后注入：
--   _G.class / _G.instance_of
--   base.class / base.instance_of
-- client_base 不在 .emmyrc.json 的 library 中，因此在此补充声明。
--
-- 用法：
---```lua
---local Animal = class('Animal')                 -- 声明基类
---function Animal:ctor(name) self.name = name end
---function Animal:speak() end
---
---local Dog = class('Dog', Animal)               -- 继承（也可传父类名字符串）
---function Dog:speak() print('wang') end
---
---local d = Dog.new('旺财')                       -- 创建实例
---print(instance_of(d, Animal))                  -- true
---```
-- ============================================================================

---声明一个类。
---
---返回的类表约定：
---- `Cls.new(...)`      创建实例（内部会调用实例的 `ctor(...)` 构造函数）
---- `Cls:ctor(...)`     构造函数（可选，在实例创建时调用）
---- `Cls.super`         父类引用
---- `Cls.__cname`       类名
---- 实例方法直接定义在类表上（`function Cls:method() end`）
---
---支持三种继承方式：Lua 类表、C++ 原生构造函数、父类名字符串。
---@param classname string 类名（会注册到引擎 ClassMap，重复定义会告警）
---@param super? table|function|string 父类（类表 / C++ 构造函数 / 父类名）
---@return table cls 类表
function class(classname, super) end

---判断实例是否为某个类（或其子类）的实例
---@param ins any 实例
---@param base table|string 类表或类名
---@return boolean
function instance_of(ins, base) end

-- 同一份实现同时挂载在 base 命名空间下（base 本体由 library 中的
-- common/base/init.lua 定义，这里只补充成员，EmmyLua 会自动合并）。

---class() 的 base 命名空间版本，见全局 class()
---@param classname string 类名
---@param super? table|function|string 父类
---@return table cls 类表
function base.class(classname, super) end

---instance_of() 的 base 命名空间版本，见全局 instance_of()
---@param ins any 实例
---@param base table|string 类表或类名
---@return boolean
function base.instance_of(ins, base) end
