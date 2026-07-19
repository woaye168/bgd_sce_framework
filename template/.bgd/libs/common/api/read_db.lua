---ReadDb模块
---@class CommonReadDb
local _M = {}
_M.__index = _M

-- 暴露类构造方法给触发编辑器
---@param data table 数据库数据
---@return CommonReadDb
function _M.create_db(data)
    return _M.new(data)
end

-- p_cv9d.create_db = _M.create_db --共享给触编才打开

-- 查询链模块
local query_chain = {}
query_chain.__index = query_chain

-- 类型转换和标准化函数
local function normalize_value(value)
    if type(value) == 'string' then
        -- 尝试转换为数值
        local num = tonumber(value)
        if num then
            return num
        end

        -- 尝试转换为布尔值
        local lower_val = string.lower(value)
        if lower_val == 'true' or lower_val == '1' then
            return true
        elseif lower_val == 'false' or lower_val == '0' then
            return false
        end

        -- 保持原字符串
        return value
    end

    return value
end

-- 值比较函数（支持类型转换）
local function values_equal(a, b)
    local norm_a = normalize_value(a)
    local norm_b = normalize_value(b)
    return norm_a == norm_b
end

-- 值比较函数（用于排序，支持类型转换）
local function compare_values(a, b, desc)
    local norm_a = normalize_value(a)
    local norm_b = normalize_value(b)

    -- 处理nil值
    if norm_a == nil and norm_b == nil then
        return false
    elseif norm_a == nil then
        return not desc
    elseif norm_b == nil then
        return desc
    end

    -- 类型一致性检查
    local type_a = type(norm_a)
    local type_b = type(norm_b)

    if type_a ~= type_b then
        -- 不同类型按字符串比较
        norm_a = tostring(norm_a)
        norm_b = tostring(norm_b)
    end

    if desc then
        return norm_a > norm_b
    else
        return norm_a < norm_b
    end
end

-- 范围比较函数
local function value_in_range(value, min_val, max_val)
    local norm_value = normalize_value(value)
    local norm_min = normalize_value(min_val)
    local norm_max = normalize_value(max_val)

    return norm_value and norm_value >= norm_min and norm_value <= norm_max
end

-- 辅助函数：生成缓存键
local function generate_cache_key(sort_fn)
    return string.format('sort_%p', sort_fn)
end

-- 辅助函数：浅拷贝
local function shallow_copy(value)
    if type(value) ~= 'table' then
        return value
    end
    local res = {}
    for k, v in pairs(value) do
        res[k] = v
    end
    return setmetatable(res, getmetatable(value))
end

-- 辅助函数：深拷贝
local function deep_copy(value)
    if type(value) ~= 'table' then
        return value
    end
    local res = {}
    for k, v in pairs(value) do
        res[deep_copy(k)] = deep_copy(v)
    end
    return setmetatable(res, getmetatable(value))
end

-- 数据标准化处理
local function normalize_record(record)
    if type(record) ~= 'table' then
        return record
    end

    local normalized = {}
    for k, v in pairs(record) do
        normalized[k] = normalize_value(v)
    end
    return normalized
end

-- 创建只读数据集
---@param data_array table 数据库数据
---@param auto_normalize? boolean 是否自动标准化
---@return CommonReadDb
function _M.new(data_array, auto_normalize)
    -- 参数验证
    if data_array and type(data_array) ~= 'table' then
        error('数据数组必须是表类型或nil')
    end

    local self = setmetatable({
        _data = data_array or {}, -- 原始数据数组
        _normalized_data = {},    -- 标准化后的数据
        _indexes = {},            -- 多级索引表
        _sorted_views = setmetatable({}, {
            __mode = 'v',
        }),                                        -- 弱引用缓存
        _cache_hit_count = {},                     -- 缓存命中统计
        _max_cache_size = 100,                     -- 最大缓存数量
        _auto_normalize = auto_normalize ~= false, -- 默认开启自动标准化
    }, _M)

    -- 数据标准化
    if self._auto_normalize then
        self:_normalize_data()
    else
        self._normalized_data = self._data
    end

    self:_build_default_indexes()
    return self
end

-- 数据标准化处理
function _M:_normalize_data()
    self._normalized_data = {}
    for i, record in ipairs(self._data) do
        self._normalized_data[i] = normalize_record(record)
    end
end

-- 构建基础索引（ID必建）
function _M:_build_default_indexes()
    if #self._normalized_data == 0 then
        return
    end

    -- 检查是否有id字段
    local has_id = false
    for field, _ in pairs(self._normalized_data[1]) do
        if field == 'id' then
            has_id = true
            break
        end
    end

    if has_id then
        self:add_index('id', true) -- 唯一索引
    end

    -- 自动检测其他可索引字段
    for field, _ in pairs(self._normalized_data[1]) do
        if field ~= 'id' and type(self._normalized_data[1][field]) ~= 'table' then
            self:add_index(field)
        end
    end
end

-- 添加数据索引（增强版，支持类型转换）
function _M:add_index(field_name, is_unique)
    -- 参数验证
    if type(field_name) ~= 'string' or field_name == '' then
        error('字段名必须是非空字符串')
    end

    if self._indexes[field_name] then
        return false, '索引已存在'
    end

    -- 检查字段是否存在
    if #self._normalized_data > 0 then
        local sample_record = self._normalized_data[1]
        if sample_record[field_name] == nil then
            return false, string.format('字段 \'%s\' 在数据记录中不存在', field_name)
        end
    end

    local new_index = {
        values = {},
        unique = is_unique or false,
    }

    -- 使用标准化数据构建索引
    for _, record in ipairs(self._normalized_data) do
        local value = record[field_name]
        if value ~= nil then
            if new_index.unique then
                if new_index.values[value] then
                    error(string.format('唯一索引 \'%s\' 存在重复值 \'%s\'', field_name, tostring(value)))
                end
                new_index.values[value] = record
            else
                if not new_index.values[value] then
                    new_index.values[value] = {}
                end
                table.insert(new_index.values[value], record)
            end
        end
    end

    self._indexes[field_name] = new_index
    return true
end

-- 移除索引
function _M:remove_index(field_name)
    if self._indexes[field_name] then
        self._indexes[field_name] = nil
        return true
    end
    return false
end

-- 重建索引
function _M:rebuild_index(field_name)
    if not self._indexes[field_name] then
        return false, '索引不存在'
    end

    local is_unique = self._indexes[field_name].unique
    self._indexes[field_name] = nil
    return self:add_index(field_name, is_unique)
end

-- 获取索引值（增强版，支持类型转换）
function _M:get_index(field_name, value)
    local index = self._indexes[field_name]
    if not index then
        return nil
    end

    -- 先尝试直接匹配
    local result = index.values[value]
    if result then
        return result
    end

    -- 尝试标准化值后匹配
    local normalized_value = normalize_value(value)
    return index.values[normalized_value]
end

-- 智能缓存清理
function _M:_cleanup_cache()
    local cache_count = 0
    for _ in pairs(self._sorted_views) do
        cache_count = cache_count + 1
    end

    if cache_count > self._max_cache_size then
        -- 清理使用频率最低的缓存
        local sorted_cache = {}
        for key, _ in pairs(self._sorted_views) do
            table.insert(sorted_cache, {
                key = key,
                hits = self._cache_hit_count[key] or 0,
            })
        end
        table.sort(sorted_cache, function(a, b)
            return a.hits < b.hits
        end)

        -- 清理一半的缓存
        local clear_count = math.floor(cache_count / 2)
        for i = 1, clear_count do
            self._sorted_views[sorted_cache[i].key] = nil
            self._cache_hit_count[sorted_cache[i].key] = nil
        end
    end
end

-- 查询链构造函数
function query_chain.new(source)
    return setmetatable({
        source = source,
        current_set = source._normalized_data, -- 使用标准化数据
        filters = {},
        sort_fn = nil,
        limit_count = nil,
        projection = nil,
        _use_index = false,
        _execution_order = {}, -- 记录方法调用顺序
    }, query_chain)
end

-- WHERE 条件筛选
function query_chain:where(condition_fn)
    if type(condition_fn) ~= 'function' then
        error('条件函数必须是函数类型')
    end
    table.insert(self.filters, condition_fn)
    table.insert(self._execution_order, {
        type = 'filter',
        fn = condition_fn,
    })
    return self
end

-- 快捷索引查询（增强版，支持类型转换）
function query_chain:with(field, value)
    -- 优先使用索引查询
    local index_result = self.source:get_index(field, value)
    if index_result then
        if type(index_result) == 'table' and index_result[1] then
            -- 非唯一索引，返回数组
            self.current_set = index_result
        elseif index_result then
            -- 唯一索引，返回单个记录
            self.current_set = { index_result }
        else
            self.current_set = {}
        end
        self._use_index = true
        table.insert(self._execution_order, {
            type = 'index',
            field = field,
            value = value,
        })
        return self
    end

    -- 回退到过滤器方式（支持类型转换）
    return self:where(function(record)
        return values_equal(record[field], value)
    end)
end

-- 范围查询支持（增强版，支持类型转换）
---@param field string 字段名
---@param min_val number 最小值
---@param max_val number 最大值
function query_chain:range(field, min_val, max_val)
    table.insert(self._execution_order, {
        type = 'range',
        field = field,
        min = min_val,
        max = max_val,
    })
    return self:where(function(record)
        return value_in_range(record[field], min_val, max_val)
    end)
end

-- 排序控制
function query_chain:sort_by(sort_fn)
    if type(sort_fn) ~= 'function' then
        error('排序函数必须是函数类型')
    end
    self.sort_fn = sort_fn
    table.insert(self._execution_order, {
        type = 'sort',
        fn = sort_fn,
    })
    return self
end

-- 便捷排序（增强版，支持类型转换）
function query_chain:order_by(field, desc)
    if type(field) ~= 'string' or field == '' then
        error('排序字段必须是非空字符串')
    end

    local is_desc = desc == true

    table.insert(self._execution_order, {
        type = 'order',
        field = field,
        desc = is_desc,
    })
    return self
end

-- 取前N条
function query_chain:limit(count)
    if type(count) ~= 'number' or count < 0 then
        error('限制数量必须是非负数')
    end
    self.limit_count = math.floor(count)
    table.insert(self._execution_order, {
        type = 'limit',
        count = self.limit_count,
    })
    return self
end

-- 选择特定字段
function query_chain:select(fields)
    if type(fields) == 'string' then
        self.projection = { fields }
    elseif type(fields) == 'table' then
        self.projection = fields
    else
        error('字段参数必须是字符串或表类型')
    end
    table.insert(self._execution_order, {
        type = 'select',
        fields = self.projection,
    })
    return self
end

-- 分组查询支持
function query_chain:group_by(field)
    table.insert(self._execution_order, {
        type = 'group',
        field = field,
    })
    -- 分组查询立即执行并返回结果
    local results = self:_execute_pipeline()
    local groups = {}

    for _, record in ipairs(results) do
        local key = record[field]
        if not groups[key] then
            groups[key] = {}
        end
        table.insert(groups[key], record)
    end

    return groups
end

-- 统计数量
function query_chain:count()
    local results = self:_execute_pipeline()
    return #results
end

-- 执行管道（按调用顺序执行，支持类型转换）
function query_chain:_execute_pipeline()
    local results = self.current_set
    local results_len = #results

    -- 按照调用顺序执行操作
    for _, operation in ipairs(self._execution_order) do
        if operation.type == 'filter' then
            -- 应用过滤器
            local filtered = {}
            local count = 0
            for i = 1, results_len do
                local record = results[i]
                if operation.fn(record) then
                    count = count + 1
                    filtered[count] = record
                end
            end
            results = filtered
            results_len = count
        elseif operation.type == 'index' then
            -- 索引查询已在 with 方法中处理
        elseif operation.type == 'range' then
            -- 范围查询已转换为过滤器
        elseif operation.type == 'sort' then
            -- 应用自定义排序函数
            if results_len > 1 then
                local sorted_results = {}
                for i = 1, results_len do
                    sorted_results[i] = results[i]
                end
                table.sort(sorted_results, operation.fn)
                results = sorted_results
            end
        elseif operation.type == 'order' then
            -- 应用字段排序（支持类型转换）
            if results_len > 1 then
                local sorted_results = {}
                for i = 1, results_len do
                    sorted_results[i] = results[i]
                end

                local field = operation.field
                local is_desc = operation.desc

                table.sort(sorted_results, function(a, b)
                    return compare_values(a[field], b[field], is_desc)
                end)
                results = sorted_results
            end
        elseif operation.type == 'limit' then
            -- 应用限制
            if operation.count and operation.count > 0 and results_len > operation.count then
                local limited = {}
                for i = 1, operation.count do
                    limited[i] = results[i]
                end
                results = limited
                results_len = operation.count
            end
        end
    end

    return results
end

-- 保持向后兼容的内部方法
function query_chain:_apply_filters_and_sort()
    return self:_execute_pipeline()
end

-- 执行查询
function query_chain:exec()
    local results = self:_execute_pipeline()

    -- 最后一步：应用字段投影
    if self.projection then
        local projected = {}
        local projection_fields = self.projection
        local field_count = #projection_fields

        for i, record in ipairs(results) do
            local new_rec = {}
            for j = 1, field_count do
                local field = projection_fields[j]
                new_rec[field] = record[field]
            end
            projected[i] = new_rec
        end
        results = projected
    end

    return results
end

-- 链式查询系统
function _M:query()
    return query_chain.new(self)
end

-- 获取所有数据
function _M:get_all()
    return self._normalized_data
end

-- 通过ID获取记录（增强版，支持类型转换）
function _M:get_by_id(id)
    return self:get_index('id', id) or self:get_index('ID', id)
end

-- 批量通过ID获取记录（增强版，支持类型转换）
function _M:batch_get_by_ids(ids)
    if type(ids) ~= 'table' then
        error('ID列表必须是表类型')
    end

    local results = {}
    for _, id in ipairs(ids) do
        local record = self:get_by_id(id)
        if record then
            table.insert(results, record)
        end
    end
    return results
end

-- 获取数据总数
function _M:count()
    return #self._normalized_data
end

-- 检查索引是否存在
function _M:has_index(field_name)
    return self._indexes[field_name] ~= nil
end

-- 获取所有索引字段
function _M:get_index_fields()
    local fields = {}
    for field, _ in pairs(self._indexes) do
        table.insert(fields, field)
    end
    return fields
end

-- 数据验证
function _M:validate_data()
    local errors = {}

    for i, record in ipairs(self._data) do
        if type(record) ~= 'table' then
            table.insert(errors, string.format('第%d条记录不是表类型', i))
        end
    end

    return #errors == 0, errors
end

-- 获取统计信息
function _M:get_stats()
    return {
        record_count = #self._normalized_data,
        index_count = self:_count_indexes(),
        cache_size = self:_count_cache(),
        memory_usage = collectgarbage('count'),
        auto_normalize = self._auto_normalize,
    }
end

function _M:_count_indexes()
    local count = 0
    for _ in pairs(self._indexes) do
        count = count + 1
    end
    return count
end

function _M:_count_cache()
    local count = 0
    for _ in pairs(self._sorted_views) do
        count = count + 1
    end
    return count
end

-- 清除所有缓存视图
function _M:clear_cache()
    self._sorted_views = setmetatable({}, {
        __mode = 'v',
    })
    self._cache_hit_count = {}
end

-- 重建所有索引
function _M:rebuild_indexes()
    local old_indexes = {}
    for field, index in pairs(self._indexes) do
        old_indexes[field] = index.unique
    end

    self._indexes = {}

    for field, is_unique in pairs(old_indexes) do
        self:add_index(field, is_unique)
    end
end

-- 重新标准化数据
function _M:renormalize_data()
    if self._auto_normalize then
        self:_normalize_data()
        self:rebuild_indexes()
    end
end

-- 设置自动标准化
function _M:set_auto_normalize(enabled)
    self._auto_normalize = enabled
    if enabled then
        self:renormalize_data()
    end
end

-- 导出辅助函数
_M.deep_copy = deep_copy
_M.shallow_copy = shallow_copy
_M.normalize_value = normalize_value
_M.values_equal = values_equal
_M.compare_values = compare_values

return _M
