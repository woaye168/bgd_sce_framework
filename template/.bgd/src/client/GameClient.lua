-- GameClient.lua (客户端)
-- 客户端按键事件处理函数
local function OnKeyDown(_trg, keyCode)
    if keyCode == "F" then
        log.info("客户端：按下了F键，向服务端请求攻击！")

        -- 向服务端发送自定义事件，附带目标ID(暂时写死打999木桩)
        local playerUid = base.local_player()._user_id
        base.forward_event_register('Req_BasicAttack')
        base.event_notify(base.game, 'Req_BasicAttack', playerUid, { target_id = 999 })
    end
end

-- 统一注册引擎的事件
base.event_register(base.game, '按键-按下', OnKeyDown)

-- 监听服务端广播的回调函数
local function OnReceiveCombatResult(data)
    -- 这里的 data 就是服务端下发的 resultData

    -- 模拟飘红字表现
    log.info("【客户端视觉表现】屏幕飘起巨大红字：-" .. tostring(data.damage_value))
    log.info("【客户端视觉表现】播放击中音效：Duang!")

    -- 模拟更新怪物的血条 UI
    log.info("【客户端UI刷新】木桩当前血量变更为：" .. tostring(data.current_hp))

    local bag = base.ui.panel {
        layout = {
            width = 600,
            height = 100
        },
        image = '背包.png'
    }
end

base.proto.Sync_CombatResult = OnReceiveCombatResult
