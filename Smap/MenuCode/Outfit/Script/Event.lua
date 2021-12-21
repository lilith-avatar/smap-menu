--- 换装、换体型系统事件
--- @module Outfit Engine API
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

-- 全局事件
local Event = {
    -- 事件根节点，初始化时创建
    Root = nil,
    --* 创建事件节点枚举类型
    Enum = {
        OPEN = 1, -- 开启换装
        CLOSE = 2, -- 关闭换装
        CLOSE_TRANSITION = 2.1, -- 播放换装过渡动画
        -- 刷新GUI
        REFRESH_GUI = {
            ALL = 31, -- 刷新全部GUI
            MENU = 32, -- 刷新菜单：MainType，SubType
            ITEMLIST = 33 -- 刷新物品列表
        },
        -- 动作栈
        ACTION = {
            DONE = 41, -- 完成行为，用于刷新GUI
            UNDO = 42, -- 撤销上一步操作
            REDO = 43, -- 重做上一步操作
            RESTORE = 44 -- 恢复到初始玩家形态
        },
        -- 刷新最新的物品列表数据
        UPDATE_CURR_TYPES = 5,
        -- 已经获得玩家物品列表
        GOT_PLAYER_OWN_ITEMLIST = 6,
        -- 换装
        CHANGE_CLOTHES = 7
    }
}

return Event
