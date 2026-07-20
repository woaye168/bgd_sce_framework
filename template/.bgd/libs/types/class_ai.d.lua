---@meta

-- ============================================================================
-- SCE 官方文档：服务端 Lua API —— AI（简介 / 简易AI）
-- ----------------------------------------------------------------------------
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/AI/简介
--   https://doc.sce.xd.com/技术文档/服务端Lua API/AI/简易AI
--
-- 注意：AI 模块待重构。
--
-- 这里提供了一个行为树框架，可以利用它来定制 AI。通过 base.ai[name] 创建/
-- 获取 AI，使用 unit:add_ai 给单位添加 AI，例如：
---```lua
---local mt = base.ai['空闲时搜敌']
---mt.pulse = 500                       -- 每500毫秒执行一次 on_idle
---function mt:on_idle()
---    -- 这里的 self 为执行AI的单位
---    local target = ai_attack(self)
---    if target then
---        self:attack(target)
---    end
---end
---u:add_ai '空闲时搜敌' {}
---```
-- ============================================================================

---AI 命名空间：通过 base.ai[name] 创建/获取 AI 对象（给 AI 设定一个合适的
---名字，以便在其他地方添加给单位）。将创建的 AI 保存下来，之后可能需要修改
---它的属性，或是为它注册事件。【服务端】
---@type table<string, AI>
base.ai = {}

---AI 对象。注意：AI 模块待重构。【服务端】
---@class AI
---@field pulse integer 心跳。执行 ai:on_idle 的周期，单位为毫秒。属性只能在创建时设置
local AI = {}

---获得AI事件。单位添加 AI 时触发此事件。
---注意：和其他对象的事件不同，AI 事件中 self 表示执行 AI 的单位，而不是 AI 对象。【服务端】
---@param data table AI数据，使用 add_ai 添加 AI 时作为参数2传入
function AI:on_add(data) end

---空闲事件。这个事件会在以下4种情况触发：
---1. 进入空闲状态。例如技能施放结束；移动结束；攻击结束等。
---2. 攻击冷却完成。
---3. 根据 AI 的 pulse 属性周期性调用。
---4. 使用 execute_ai 主动执行。
---在以下情况下不会触发此事件：
---1. 处于死亡状态。
---2. 正在攻击或施法。
---3. 拥有隐藏。
---4. 使用 base.game:disable_ai 关闭了 AI。
---注意：AI 事件中 self 表示执行 AI 的单位，而不是 AI 对象。【服务端】
function AI:on_idle() end

---移除AI事件。单位移除 AI 时触发此事件。
---注意：AI 事件中 self 表示执行 AI 的单位，而不是 AI 对象。【服务端】
function AI:on_remove() end

---给单位添加 AI。【服务端】
---@param name string AI名（base.ai[name] 创建的名字）
---@param data table AI数据，会作为 on_add 事件的参数传入
function Unit:add_ai(name, data) end

-- ============================================================================
-- 简易AI（base.simple_ai.*）
-- 简易AI的详细说明请见官方文档「简易AI」页面
-- ============================================================================

---增加队伍仇恨。为指定队伍增加仇恨。若有队伍仇恨，则类型仇恨无效。
---仇恨相关见搜敌规则。【服务端】
---@param unit Unit 单位
---@param team integer 队伍id
---@param threat integer 仇恨。threat > 0：队伍获得该等级的仇恨，不同等级的仇恨可以共存，最高的仇恨生效，清空队伍的负仇恨；threat == 0：清空队伍的仇恨；threat < 0：不会搜索到该队伍，清空队伍的正仇恨
function base.simple_ai.add_team_threat(unit, team, threat) end

---增加单位仇恨。为指定单位增加仇恨。若有单位仇恨，则单位的队伍仇恨与
---类型仇恨均无效。仇恨相关见搜敌规则。【服务端】
---@param unit Unit 单位
---@param target Unit 指定单位
---@param threat integer 仇恨。threat > 0：单位获得该等级的仇恨，不同等级的仇恨可以共存，最高的仇恨生效，清空单位的负仇恨；threat == 0：清空单位的仇恨；threat < 0：不会搜索到该单位，清空单位的正仇恨
---@param time? integer 持续时间（毫秒）。若不填时间则表示无限
function base.simple_ai.add_threat(unit, target, threat, time) end

---增加类型仇恨。为指定单位类型增加仇恨。仇恨相关见搜敌规则。【服务端】
---@param unit Unit 单位
---@param type string 单位类型
---@param threat integer 仇恨。threat > 0：单位类型获得该等级的仇恨，不同等级的仇恨可以共存，最高的仇恨生效，清空单位类型的负仇恨；threat == 0：清空单位类型的仇恨；threat < 0：不会搜索到该单位类型，清空单位类型的正仇恨
function base.simple_ai.add_type_threat(unit, type, threat) end

---设置追击距离限制。当自动攻击的追击超出此范围后会强制返回。
---设置为 0 表示不允许追击，设置为 nil 表示无距离限制。默认为无距离限制。【服务端】
---@param unit Unit 单位
---@param limit? number 距离限制
function base.simple_ai.chase_limit(unit, limit) end

---开关自动攻击。默认为开启。【服务端】
---@param unit Unit 单位
---@param open boolean 开启或关闭
function base.simple_ai.search(unit, open) end

---沿着路线移动。单位会沿着列表中的点移动，移动过程中可以自动攻击。【服务端】
---@param unit Unit 单位
---@param points Point[] 点列表
function base.simple_ai.walk(unit, points) end

---自动攻击。【服务端】
---@param unit Unit 单位
---@param enable boolean 是否开启
function base.simple_ai.auto_attack(unit, enable) end
