---菜单管理器
---@module MenuMgr
---@copyright Lilith Games, Avatar Team
---@author ropztao, Yuancheng Zhang

-- Local Caches
local world, invoke, Game, PlayerHub = world, invoke, Game, PlayerHub
local VoiceManager, channel = VoiceManager, nil
local S = _G.mS

--* 模块
local M = S.ModuleUtil.New('MenuMgr', S.Base)

--* 数据
local playerInfoTab, playerList = {}, {}
local isSent, isArrived, addedPlayer = false, false
local isOffLine = false

--玩家头像
local headPortrait = nil

---初始化
function Init()
    InitEvents()
    InitVoiceChannel()
end

---初始化游戏事件
function InitEvents()
    -- 玩家加入事件
    world.OnPlayerAdded:Connect(OnPlayerAdded)
    -- 玩家离开事件
    world.OnPlayerRemoved:Connect(OnPlayerRemoved)
end

---玩家加入事件
function OnPlayerAdded(_player)
    SwitchChannel(_player, true)

    if playerList ~= {} then
        for k,v in pairs(playerList) do
            if _player == v then
                goto finished
            end
        end
    end
    -- GetPlayerProfile(_player)
    playerInfoTab[_player] = headPortrait
    table.insert(playerList, _player)

    addedPlayer = _player

    local broadcast = function()
        M.Kit.Util.Net.Broadcast('NoticeEvent', playerInfoTab, playerList, addedPlayer, true)
        isSent = true
    end
    invoke(broadcast, 1)
    ::finished::
end

function OnPlayerRemoved(_player)
    SwitchChannel(_player, false)
    playerInfoTab[_player.UserId] = {}
    for k, v in pairs(playerList) do
        if v == _player then
            table.remove(playerList, k)
        end
    end

    local changedPlayer = _player
    local broadcast = function()
        M.Kit.Util.Net.Broadcast('NoticeEvent', playerInfoTab, playerList, changedPlayer, false)
        isSent = true
    end
    invoke(broadcast, 1)
end

local tt = 0
function Update(_, _dt)
    if isArrived then return end
    tt = tt + _dt
    if tt > 1 then
        tt = 0
        M.Kit.Util.Net.Broadcast('NoticeEvent', playerInfoTab, playerList, addedPlayer, true)
    end
end

function ConfirmNoticeEventHandler(_boolean)
    isArrived = _boolean
    if _boolean then
        isSent = not _boolean
    end
end

function GetPlayerProfile(_player)
    local callback = function(_profile)
        headPortrait = _profile.HeadPortrait
    end

    PlayerHub.GetPlayerProfile(_player.UserId, callback)
end

function SwitchChannel(_player, _type)
    if _type then
        channel:AddSpeaker(_player)
    else
        channel:RemoveSpeaker(_player)
    end
end

function InitVoiceChannel()
    -- VoiceManager.CreateChannel('DefaultVoiceChannel')
    channel = VoiceManager.GetChannel('DefaultVoiceChannel')
    -- channel.SpeakerAdded:Connect(function(_player)
    --     channel:MuteSpeaker(_player, true)
    -- end)
end

function MuteLocalEventHandler(_player, _isOn)
    channel:MuteSpeaker(_player, not _isOn)
end

function TeleportPlayerToFriendGameEventHandler(_player, _roomId)
    local callbackTeleport = function()
        --TODO: 处理回调函数
    end
    Game.TeleportPlayerToRoom(_player, _roomId, {}, callbackTeleport)
end

function SwitchOfflineStateEventHandler(_boolean)
    isOffLine = _boolean
end

--! Public methods
M.Init = Init
M.Update = Update
M.playerList = playerList
M.MuteLocalEventHandler = MuteLocalEventHandler
M.TeleportPlayerToFriendGameEventHandler = TeleportPlayerToFriendGameEventHandler
M.ConfirmNoticeEventHandler = ConfirmNoticeEventHandler

return M
