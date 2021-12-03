---@module MenuCtr
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  MenuCtr,this = ModuleUtil.New('MenuCtr', ClientBase)

---初始化
function MenuCtr:Init()
    self:GetFriendsList()
end

function MenuCtr:NoticeEventHandler(_playerTab, _playerList, _changedPlayer, _isAdded)
    self.playerTab = _playerTab
    self.playerList = _playerList
end

function MenuCtr:MuteAllEventHandler(_isMuted)
    for k,v in pairs(self.playerTab) do
        VoiceManager.MuteDesignatedPlayer(k, _isMuted)
    end
end

function MenuCtr:MuteSpecificPlayerEventHandler(_specificPlayer, _isMuted)
    VoiceManager.MuteDesignatedPlayer(_specificPlayer, _isMuted)
end

function MenuCtr:GetFriendsList()
    local list = Friends.GetFriendInfos()
    NetUtil.Fire_C('GetFriendsListEvent', localPlayer, list)
end

local tt = 0
function MenuCtr:Update(dt)
    tt = tt + dt
    if tt > 30 then
        self:GetFriendsList()
        tt = 0
    end
end

local callback = function(msg)
    print(msg)
end

function MenuCtr:InviteFriendToGameEventHandler(targetPlayerId)
    Friends.InvitePlayer(targetPlayerId,callback)
end

function MenuCtr:JoinFriendGameEventHandler()

end

function MenuCtr:AddFriendsEventHandler()

end

return MenuCtr