--- 菜单GUI控制器
--- @module MenuCtr
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local Event, VoiceManager, Friends, Game, localPlayer = Event, VoiceManager, Friends, Game, localPlayer

--* 模块
local M, this = ModuleUtil.New('MenuCtr', ClientBase)

---初始化
function M:Init()
    self:GetFriendsList()
    self:InitListener()
end

---玩家加入
function M:NoticeEventHandler(_playerTab, _playerList, _changedPlayer, _isAdded)
    self.playerTab = _playerTab
    self.playerList = _playerList
end

---屏蔽所有人语音
function M:MuteAllEventHandler(_isMuted)
    for _, v in pairs(self.playerList) do
        if v ~= localPlayer then
            VoiceManager.MuteDesignatedPlayer(v.UserId, _isMuted)
        end
    end
end

---屏蔽指定人语音
function M:MuteSpecificPlayerEventHandler(_specificPlayer, _isMuted)
    VoiceManager.MuteDesignatedPlayer(_specificPlayer, _isMuted)
end

---拿到好友列表
function M:GetFriendsList()
    local list = Friends.GetFriendInfos()
    M.Kit.Util.Net.Fire_C('GetFriendsListEvent', localPlayer, list)
end

local tt = 0
function M:Update(dt)
    tt = tt + dt
    if tt > 60 then
        self:GetFriendsList()
        tt = 0
    end
end

local callback = function(msg)
    Debug.Log(msg)
end

---邀请好友来游戏房间
local localRoomIdTab = {}
function M:InviteFriendToGameEventHandler(targetPlayerId)
    Friends.InvitePlayer(targetPlayerId, callback)
    localRoomIdTab['ROOMID'] = Game.GetRoomID()
    localRoomIdTab['PLAYER'] = localPlayer
    Event.EmitLuaEvent(Event.Scope.APP, 'MENU_INVITE', '100000000', localRoomIdTab)
    localRoomIdTab = {}
end

---去好友的游戏房间
local content = {}
function M:JoinFriendGameEventHandler(_player, _tarPlayerUserId)
    table.insert(content, 'JOIN_REQUEST')
    Event.EmitLuaEvent(Event.Scope.APP, 'MENU_JOIN', '100000001', content)
    content = {}
end

local callback1 = function(msg)
end

---添加好友
function M:AddFriendsEventHandler(_playerId)
    Friends.SendFriendRequest(_playerId, callback1)
end

local roomIdTab = {}

---邀请和加入的事件初始化监听
function M:InitListener()
    local J_callback = function(_eventType, _eventId, _eventData)
        for k, v in pairs(_eventData) do
            if v == 'JOIN_REQUEST' then
                roomIdTab['ROOMID'] = Game.GetRoomID()
                Event.EmitLuaEvent(Event.Scope.APP, 'MENU_JOIN_R', '100000002', roomIdTab)
            end
        end
        roomIdTab = {}
    end

    local I_callback = function(_eventType, _eventId, _eventData)
        local inviteRoomTab = _eventData
        M.Kit.Util.Net.Fire_C('SomeoneInviteEvent', localPlayer, inviteRoomTab['PLAYER'], inviteRoomTab['ROOMID'])
        inviteRoomTab = {}
    end

    local R_callback = function(_eventType, _eventId, _eventData)
        M.Kit.Util.Net.Fire_S('TeleportPlayerToFriendGameEvent', localPlayer, _eventData['ROOMID'])
    end

    Event.ListenLuaEvent(Event.Scope.APP, 'MENU_INVITE', '100000000', I_callback)
    Event.ListenLuaEvent(Event.Scope.APP, 'MENU_JOIN', '100000001', J_callback)
    Event.ListenLuaEvent(Event.Scope.APP, 'MENU_JOIN_R', '100000002', R_callback)
end

function M:ConfirmInviteEventHandler(_player, _roomId)
    M.Kit.Util.Net.Fire_S('TeleportPlayerToFriendGameEvent', _player, _roomId)
end

return M
