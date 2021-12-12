---@module MenuMgr
---@copyright Lilith Games, Avatar Team
---@author ropztao
local MenuMgr, this = ModuleUtil.New('MenuMgr', ServerBase)
local world, NetUtil, invoke, Game, PlayerHub = world, NetUtil, invoke, Game, PlayerHub
---初始化
function MenuMgr:Init()
    self:DataInit()

    world.OnPlayerAdded:Connect(
        function(_player)
            self:OnPlayerAdded(_player)
        end
    )

    world.OnPlayerRemoved:Connect(
        function(_player)
            self:OnPlayerRemoved(_player)
        end
    )
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

    local broadcast = function()
        NetUtil.Broadcast('NoticeEvent', self.playerInfoTab, self.playerList, changedPlayer, true)
    end
    invoke(broadcast, 1)
end

function MenuMgr:OnPlayerRemoved(_player)
    self.playerInfoTab[_player.UserId] = {}
    for k, v in pairs(self.playerList) do
        if v == _player then
            table.remove(self.playerList, k)
        end
    end

    local changedPlayer = _player
    local broadcast = function()
        NetUtil.Broadcast('NoticeEvent', self.playerInfoTab, self.playerList, changedPlayer, false)
    end
    invoke(broadcast, 1)
end

function MenuMgr:GetPlayerProfile(_player)
    self.callback = function(_profile)
        self.headPortrait = _profile.HeadPortrait
    end

    PlayerHub.GetPlayerProfile(_player.UserId, self.callback)
end

function MenuMgr:MuteLocalEventHandler(_playerId, _isOn)
    for _, v in pairs(self.playerList) do
        NetUtil.Fire_C('MuteSpecificPlayerEvent', v, _playerId, not _isOn)
    end
end

local callbackTeleport = function()
end

function MenuMgr:TeleportPlayerToFriendGameEventHandler(_player, _roomId)
    Game.TeleportPlayerToRoom(_player, _roomId, {}, callbackTeleport)
end

return MenuMgr
