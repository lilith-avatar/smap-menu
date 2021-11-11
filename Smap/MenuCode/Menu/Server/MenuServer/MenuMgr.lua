---@module MenuMgr
---@copyright Lilith Games, Avatar Team
---@author ropztao
local MenuMgr,this = ModuleUtil.New('MenuMgr', ServerBase)
---初始化
function MenuMgr:Init()
    self:DataInit()

    world.OnPlayerAdded:Connect(function(_player)
        self:OnPlayerAdded(_player)
    end)

    world.OnPlayerRemoved:Connect(function(_player)
        self:OnPlayerRemoved(_player)
    end)
end

function MenuMgr:DataInit()
    self.playerTab = {}
end

function MenuMgr:OnPlayerAdded(_player)
    table.insert(self.playerTab, _player)
    invoke(function()
        NetUtil.Broadcast('NoticeEvent', self.playerTab)
    end,0.3)
end

function MenuMgr:OnPlayerRemoved(_player)
    for k,v in pairs(self.playerTab) do
        if v == _player then
            table.remove(self.playerTab, k)
        end
    end
    invoke(function()
        NetUtil.Broadcast('NoticeEvent', self.playerTab)
    end,0.3)
end

return MenuMgr