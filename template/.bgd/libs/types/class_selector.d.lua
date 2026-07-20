---@meta

-- ============================================================================
-- SCE 选取器（Selector）类型声明（双端合并）
-- ----------------------------------------------------------------------------
-- 覆盖范围：服务端选取器 API + 客户端选取器 API
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/选取器/API
--   https://doc.sce.xd.com/技术文档/客户端Lua API/选取器/选取器
-- ============================================================================

---选取器对象。【服务端】
---选取器可以通过指定一个形状和若干规则来选取某个区域内的多个单位。
---默认规则：形状为半径99999的圆形；不选取拥有无敌或蝗虫行为限制的单位；只选取活着的生物。
---选取器只能拥有一个形状，后设置的形状覆盖之前的形状。
---@class Selector
local Selector = {}

---直线形状。【服务端】
---@param start Point 起点
---@param angle number 方向
---@param len number 长度
---@param width number 宽度
---@return Selector selector 选取器
function Selector:in_line(start, angle, len, width) end

---圆形形状。【服务端】
---@param center Point 圆心
---@param range number 半径
---@return Selector selector 选取器
function Selector:in_range(center, range) end

---扇形形状。【服务端】
---@param center Point 圆心
---@param range number 半径
---@param angle number 角度
---@param section number 扇形区间
---@return Selector selector 选取器
function Selector:in_sector(center, range, angle, section) end

---设定选取场景，不设置的话为默认场景 'default'。【服务端】
---@param scene_name string 选取场景
---@return Selector selector 选取器
function Selector:of_scene(scene_name) end

---只选取友方。【服务端】
---@param who Unit|Player 参考单位或玩家
---@return Selector selector 选取器
function Selector:is_ally(who) end

---只选取敌方。【服务端】
---@param who Unit|Player 参考单位或玩家
---@return Selector selector 选取器
function Selector:is_enemy(who) end

---排除指定单位。【服务端】
---@param unit Unit 排除的单位
---@return Selector selector 选取器
function Selector:is_not(unit) end

---添加选取类型。【服务端】
---@param type string 单位类型
---@return Selector selector 选取器
function Selector:of_add(type) end

---移除选取类型。【服务端】
---@param type string 单位类型
---@return Selector selector 选取器
function Selector:of_remove(type) end

---设置选取类型。【服务端】
---@param list table 单位类型列表
---@return Selector selector 选取器
function Selector:of_type(list) end

---只选取可见单位。【服务端】
---@param unit Unit 参考单位
---@return Selector selector 选取器
function Selector:of_visible(unit) end

---排除幻象单位。【服务端】
---@return Selector selector 选取器
function Selector:of_not_illusion() end

---允许选取无敌单位。【服务端】
---@return Selector selector 选取器
function Selector:allow_god() end

---自定义规则。可添加多个，按添加顺序依次执行。
---规则函数接收一个单位作为参数，返回 false 表示该单位被排除。【服务端】
---@param filter fun(unit:Unit):boolean 规则
---@return Selector selector 选取器
function Selector:add_filter(filter) end

---排序：近的单位在前面。【服务端】
---@param where Point|Unit 参考位置
---@return Selector selector 选取器
function Selector:sort_nearest_unit(where) end

---自定义排序。排序器接收2个单位为参数，当第1个单位需要排在第2个单位之前时返回 true。
---内部使用 table.sort 实现。【服务端】
---@param sorter fun(unit1:Unit, unit2:Unit):boolean 排序器
---@return Selector selector 选取器
function Selector:set_sorter(sorter) end

---执行选取。【服务端】
---@return Unit[] group 单位列表
function Selector:get() end

---遍历选取结果。【服务端】
---@return fun(t:table, i:integer):integer, Unit
---@return table
---@return integer
function Selector:ipairs() end

---随机。返回选取单位列表中的随机单位，如果单位列表为空则返回 nil。【服务端】
---@return Unit|nil unit 单位
function Selector:random() end

---创建选取器。【服务端】
---@return Selector selector 选取器
function base.selector() end

---设置默认选取类型。设置后相当于创建选取器后自动使用了 of_type。【服务端】
---@type string[]
base.selector_type_of = nil

-- ----------------------------------------------------------------------------
-- 客户端选取器
-- ----------------------------------------------------------------------------

---圆形单位搜索。【客户端】
---@param position Point 搜索起点坐标
---@param radius number 搜索半径
---@param Tag? string|table 搜索标签（可选，不填写默认搜索全部标签）
---@return Unit[] targets 所有搜索到的单位
function base.game:circle_selector(position, radius, Tag) end

---扇形单位搜索。【客户端】
---@param position Point 搜索起点坐标
---@param radius number 搜索半径
---@param degree number 搜索角度
---@param face Point 扇形中心单位向量
---@param Tag? string|table 搜索标签（可选，不填写默认搜索全部标签）
---@return Unit[] targets 所有搜索到的单位
function base.game:sector_selector(position, radius, degree, face, Tag) end

---线形单位搜索。【客户端】
---@param position Point 搜索起点坐标
---@param length number 搜索长度
---@param width number 搜索宽度
---@param face Point 搜索方向单位向量
---@param Tag? string|table 搜索标签（可选，不填写默认搜索全部标签）
---@return Unit[] targets 所有搜索到的单位
function base.game:line_selector(position, length, width, face, Tag) end
