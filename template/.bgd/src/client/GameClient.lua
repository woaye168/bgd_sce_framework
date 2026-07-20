-- GameClient.lua (客户端)
local function OnKeyDown(_trg, keyCode)
    if keyCode == "F" then
        log.info("客户端：按下了F键，向服务端请求攻击！")
        
        -- 向服务端发送自定义事件，附带目标ID(暂时写死打999木桩)
        local playerUid = base.local_player()._user_id
        base.forward_event_register('Req_BasicAttack')
        base.event_notify(base.game, 'Req_BasicAttack',playerUid ,{ target_id = 999 })
    end
end

-- 统一注册引擎的事件
base.event_register(base.game, '按键-按下', OnKeyDown)