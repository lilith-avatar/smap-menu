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
    self.playerInfoTab = {}
    self.playerList = {}
end

function MenuMgr:OnPlayerAdded(_player)    
    self:GetPlayerProfile(_player)

    self.playerInfoTab[_player] = self.headPortrait
    table.insert(self.playerList, _player)

    local changedPlayer = _player
    invoke(function()
        NetUtil.Broadcast('NoticeEvent', self.playerInfoTab, self.playerList, changedPlayer, true)
    end,1)
end

function MenuMgr:OnPlayerRemoved(_player)
    self.playerInfoTab[_player.UserId] = {}
    for k,v in pairs(self.playerList) do
        if v == _player then
            table.remove(self.playerList, k)
        end
    end

    local changedPlayer = _player
    invoke(function()
        NetUtil.Broadcast('NoticeEvent', self.playerInfoTab, self.playerList, changedPlayer, false)
    end,1)
end

function MenuMgr:GetPlayerProfile(_player)
    self.callback = function(_profile)
        self.headPortrait = _profile.HeadPortrait
    end

    PlayerHub.GetPlayerProfile(_player.UserId, self.callback)
end

function MenuMgr:MuteLocalEventHandler(_playerId, _isOn)
    for k,v in pairs(self.playerList) do
        NetUtil.Fire_C('MuteSpecificPlayerEvent', v, _playerId, _isOn)
    end
end

return MenuMgr