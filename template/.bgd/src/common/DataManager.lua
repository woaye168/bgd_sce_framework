-- DataManager.lua (服务端)
DataManager = {}
DataManager.ItemConfigs = {
    -- 测试数据
    [1001] = { id = 1001, name = "新手木剑", type = "weapon", atk = 5 },
    [2001] = { id = 2001, name = "小红药", type = "consumable", heal = 20 }
}

-- 写一个空壳函数，等之后策划给你表了再填逻辑
function DataManager.GetItemData(itemId)
    if not DataManager.ItemConfigs[itemId] then
        return nil
    end
    return DataManager.ItemConfigs[itemId]
end

return DataManager