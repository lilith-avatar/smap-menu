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
    self:GetPlayerProfile(_player)

    self.playerTab[_player.UserId] = {
        headPortrait = self.headPortrait,
        instance = _player
    }

    invoke(function()
        NetUtil.Broadcast('NoticeEvent', self.playerTab)
    end,1)
end

function MenuMgr:OnPlayerRemoved(_player)
    self.playerTab[_player.UserId] = {}

    invoke(function()
        NetUtil.Broadcast('NoticeEvent', self.playerTab)
    end,1)
end

function MenuMgr:GetPlayerProfile(_player)
    self.callback = function(_profile)
        self.headPortrait = _profile.HeadPortrait
    end

    PlayerHub.GetPlayerProfile(_player.UserId, self.callback)
end

return MenuMgr