---Json模块
---@class CommonJson
local M = {}
local depth_max_default = 5

---Json序列化
---@param data table 对象
---@return string
function M.encode(data)
    return json.encode(data)
end

---Json反序列化
---@param str string json字符串
---@return table
function M.decode(str)
    return json.decode(str)
end

---Json序列化:增强版
---@param data table 对象
---@param depth_max? number 序列化深度
---@return string
function M.encode_x(data, depth_max)
    -- 设置默认深度限制
    depth_max = depth_max or depth_max_default

    local seen = {} -- 用于跟踪已访问的表

    local function is_array(t)
        if type(t) ~= 'table' then
            return false
        end

        local count = 0
        for k in pairs(t) do
            if type(k) ~= 'number' or k < 1 or math.floor(k) ~= k then
                return false
            end
            count = count + 1
        end
        return count > 0 and #t == count
    end

    local function encode_custom(value, current_depth, _key)
        current_depth = current_depth or 0

        -- 添加明确的类型转换和验证
        local num_depth = tonumber(current_depth) or 0
        local num_depth_max = tonumber(depth_max) or depth_max_default

        -- 深度检查 - 使用明确的数值比较
        if num_depth > num_depth_max then
            return '"<max depth exceeded>"'
        end

        local t = type(value)

        -- 检测循环引用
        if t == 'table' then
            if seen[value] then
                return '"<cyclic reference>"'
            end
            seen[value] = true
        end

        -- 自定义处理逻辑
        if t == 'function' then
            return '"<function>"'
        elseif t == 'table' then
            -- 处理数组类型（连续整数索引）
            if is_array(value) then
                local result = {}
                for i = 1, #value do
                    local success_val, item_result = pcall(encode_custom, value[i], num_depth + 1, i)
                    if success_val then
                        table.insert(result, item_result)
                    else
                        table.insert(result, '"<serialization error>"')
                    end
                end
                seen[value] = nil
                return '[' .. table.concat(result, ',') .. ']'
            else
                -- 处理对象类型（键值对）
                local result = {}
                for k, v in pairs(value) do
                    -- 安全处理键
                    local key_str
                    if type(k) == 'string' then
                        key_str = string.format('%q', k)
                    elseif type(k) == 'number' then
                        key_str = string.format('"%d"', k)
                    elseif type(k) == 'boolean' then
                        key_str = string.format('"%s"', tostring(k))
                    else
                        key_str = string.format('"<%s key>"', type(k))
                    end

                    -- 安全处理值
                    local success_val, value_result = pcall(encode_custom, v, num_depth + 1, k)
                    if success_val then
                        table.insert(result, key_str .. ':' .. value_result)
                    else
                        local value_type = type(v)
                        table.insert(result, key_str .. ':"<' .. value_type .. '>"')
                    end
                end
                seen[value] = nil
                return '{' .. table.concat(result, ',') .. '}'
            end
        elseif t == 'userdata' then
            -- 尝试获取userdata的元信息
            local mt = getmetatable(value)
            if mt and mt.__name then
                return string.format('"<userdata:%s>"', mt.__name)
            else
                return '"<userdata>"'
            end
        elseif t == 'thread' then
            return '"<thread>"'
        else
            -- 处理基本类型
            if t == 'string' then
                return string.format('%q', value)
            elseif t == 'number' then
                -- 正确处理整数和浮点数
                if math.floor(value) == value then
                    return string.format('%d', value)
                else
                    return string.format('%.14g', value)
                end
            elseif t == 'boolean' then
                return value and 'true' or 'false'
            elseif t == 'nil' then
                return 'null'
            else
                return string.format('"<%s>"', t)
            end
        end
    end

    local success, result = pcall(encode_custom, data, 0, 'root')
    if success then
        return tostring(result)
    else
        -- 安全处理顶层错误
        return string.format('"<serialization failed: %s>"', tostring(result):gsub('"', '\\"'))
    end
end

return M
