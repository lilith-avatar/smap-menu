---@module MenuMgr
---@copyright Lilith Games, Avatar Team
---@author ropztao
local MenuMgr,this = ModuleUtil.New('MenuMgr', ServerBase)
---初始化
function MenuMgr:Init()
    Game.ShowSystemBar(false)
end

return MenuMgr