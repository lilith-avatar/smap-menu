--- 菜单GUI控制器
--- @module MenuCtr
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local localPlayer = localPlayer
local Debug, Event, VoiceManager, Friends, Game = Debug, Event, VoiceManager, Friends, Game
local C = _G.mC

--* 模块
local M, this = C.ModuleUtil.New('MenuCtr', C.Base)

-- 本地变量
local roomIdTab = {}
local playerTab, playerList
local localRoomIdTab = {}
local content = {}
local tt, ot, isNone = 0, 0, true

---初始化
function Init()
    InitListener()
end

---邀请和加入的事件初始化监听
function InitListener()
    local J_callback = function(_eventType, _eventId, _eventData)
        for _, v in pairs(_eventData) do
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

---拿到好友列表
function GetFriendsList()
    local list = Friends.GetFriendInfos()
    M.Kit.Util.Net.Fire_C('GetFriendsListEvent', localPlayer, list)
end

function Update(_, dt)
    ot = ot + dt
    if ot > 1 and isNone then
        ot = 0
        M.Kit.Util.Net.Fire_S('ConfirmNoticeEvent', not isNone)
    end
end

---玩家加入
function NoticeEventHandler(_playerTab, _playerList, _changedPlayer, _isAdded)
    isNone = false
    M.Kit.Util.Net.Fire_S('ConfirmNoticeEvent', not isNone)
    playerTab = _playerTab
    playerList = _playerList
    GetFriendsList()
end

---屏蔽所有人语音
function MuteAllEventHandler(_isMuted)
    if playerList == nil then return end
    for _, v in pairs(playerList) do
        if v ~= localPlayer then
            VoiceManager.MuteDesignatedPlayer(v.UserId, _isMuted)
        end
    end
end

---屏蔽指定人语音
function MuteSpecificPlayerEventHandler(_specificPlayer, _isMuted)
    VoiceManager.MuteDesignatedPlayer(_specificPlayer, _isMuted)
end

---邀请好友来游戏房间
function InviteFriendToGameEventHandler(_targetPlayerId)
    local callback = function(_msg)
        Debug.Log(_msg)
    end
    Friends.InvitePlayer(_targetPlayerId, callback)
    localRoomIdTab['ROOMID'] = Game.GetRoomID()
    localRoomIdTab['PLAYER'] = localPlayer
    Event.EmitLuaEvent(Event.Scope.APP, 'MENU_INVITE', '100000000', localRoomIdTab)
    localRoomIdTab = {}
end

---去好友的游戏房间
function JoinFriendGameEventHandler(_player, _tarPlayerUserId)
    table.insert(content, 'JOIN_REQUEST')
    Event.EmitLuaEvent(Event.Scope.APP, 'MENU_JOIN', '100000001', content)
    content = {}
end

---添加好友
function AddFriendsEventHandler(_playerId)
    local callback = function(_msg)
        Debug.Log(_msg)
    end
    Friends.SendFriendRequest(_playerId, callback)
end

function ConfirmInviteEventHandler(_player, _roomId)
    M.Kit.Util.Net.Fire_S('TeleportPlayerToFriendGameEvent', _player, _roomId)
end

--! Public methods
M.Init = Init
M.Update = Update
M.NoticeEventHandler = NoticeEventHandler
M.MuteAllEventHandler = MuteAllEventHandler
M.MuteSpecificPlayerEventHandler = MuteSpecificPlayerEventHandler
M.InviteFriendToGameEventHandler = InviteFriendToGameEventHandler
M.JoinFriendGameEventHandler = JoinFriendGameEventHandler
M.AddFriendsEventHandler = AddFriendsEventHandler
M.ConfirmInviteEventHandler = ConfirmInviteEventHandler
return M
