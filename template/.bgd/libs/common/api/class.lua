local class_name_map = {}

-- 类创建接口
---@param classname string 类名
---@param super? CommonClass 父类
---@return ClassCls
local function class(classname, super)
    ---@class ClassCls
    local cls = {}

    local superType = type(super)
    if superType ~= 'function' and superType ~= 'table' and superType ~= 'string' then
        superType = nil
        super = nil
    end

    if superType == 'string' then
        local super_cls = class_name_map[super]
        if not super_cls then
            -- error(('cannot found super[%s] by string'):format(super))
            log.error(('没有找到名称 [%s] 的父类 ！！'):format(super))
        end

        super = super_cls
        superType = 'table'
    end

    if superType == 'function' or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        if superType == 'table' then
            -- copy fields from super
            for k, v in pairs(super) do
                cls[k] = v
            end
            cls.__create = super.__create
            cls.super = super
        else
            cls.__create = super
            cls.ctor = function()
            end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k, v in pairs(cls) do
                instance[k] = v
            end
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    else
        -- inherited from Lua Object
        cls.super = super
        cls.class = cls
        cls.ctor = not super and function()
        end or nil
        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls
        setmetatable(cls, {
            __index = super,
        })

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance:ctor(...)
            return instance
        end

        cls.class_name = function()
            return cls.__cname
        end
    end

    cls.__supper_map = {}
    cls.__supper_map[cls] = true

    if superType == 'table' and super.__supper_map then
        for k, _ in pairs(super.__supper_map) do
            cls.__supper_map[k] = true
        end
    end

    -- if SCE.ClassMap[cls.__cname] then
    --     log_info.warn('redefine class:' .. cls.__cname)
    -- end
    -- -- 更新继承树
    -- SCE.ClassMap[cls.__cname] = super and super.__cname or ''

    class_name_map[cls.__cname] = cls

    return cls
end

local instance_of = function(ins, base)
    if type(ins) ~= 'table' or not ins.__supper_map then
        return false
    end

    if type(base) == 'string' then
        base = class_name_map[base]
        if base == nil then
            return false
        end
    end

    return ins.__supper_map[base] ~= nil
end

-- base.class = class
-- base.instance_of = instance_of

-- _G.class = class
-- _G.instance_of = instance_of

---类模块
---@class CommonClass
local module = {
    class = class,
    instance_of = instance_of,
}

return module
