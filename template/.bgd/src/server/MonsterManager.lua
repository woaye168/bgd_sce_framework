MonsterManager = {}
MonsterManager.ActiveMonsters = {}

function MonsterManager.InitTestDummy()
    local dummy = {
        uid = 999,
        name = "测试木桩",
        hp = 50,
        max_hp = 50
    }
    MonsterManager.ActiveMonsters[999] = dummy
    log.info("测试木桩已生成，当前血量: 50/50")
end