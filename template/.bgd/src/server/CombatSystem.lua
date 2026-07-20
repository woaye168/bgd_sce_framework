-- CombatSystem.lua (服务端)
require("src.server.PlayerManager")
require("src.server.MonsterManager")

local function HandleBasicAttack(_, playerUid, data)
    -- log.info("Req_BasicAttack _: " .. bgd_api.common.json.encode_x(_,6))
    -- log.info("Req_BasicAttack playerObj: " .. bgd_api.common.json.encode_x(playerObj,6))
    -- log.info("Req_BasicAttack data: " .. bgd_api.common.json.encode_x(data,2))

    local uid = playerUid
    local targetId = data.target_id

    local player = PlayerManager.OnlinePlayers[uid]
    local target = MonsterManager.ActiveMonsters[targetId]

    if not player or not target then return end -- 安全校验

    -- 极简伤害计算 (假设玩家有个 atk 属性，你可以在 Day 1 的数据里加上)
    local damage = 10
    target.hp = target.hp - damage

    log.info(player.name .. " 攻击了 " .. target.name .. "，造成了 " .. damage .. " 点伤害！")

    -- 死亡判定
    if target.hp <= 0 then
        log.info(">>> " .. target.name .. " 死亡！")

        -- 【联动 Day1】发奖励！给玩家背包塞一个战利品
        table.insert(player.inventory, { name = "木桩的碎片" })
        log.info(">>> 获得战利品：木桩的碎片。当前背包物品数量：" .. #player.inventory)

        -- 让木桩复活，方便你无限按F测试
        target.hp = target.max_hp
        log.info("测试木桩已重新刷新。")
    else
        log.info(target.name .. " 剩余血量: " .. target.hp .. "/" .. target.max_hp)
    end
end

-- 监听客户端发来的网络事件
base.event_register(base.game, "Req_BasicAttack", HandleBasicAttack)
