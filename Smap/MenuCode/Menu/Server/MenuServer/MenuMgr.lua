---菜单管理器
---@module MenuMgr
---@copyright Lilith Games, Avatar Team
---@author ropztao, Yuancheng Zhang

-- Local Caches
local world, invoke, Game, PlayerHub = world, invoke, Game, PlayerHub
local S = _G.mS

--* 模块
local M = S.ModuleUtil.New('MenuMgr', S.Base)

--* 数据
local playerInfoTab, playerList = {}, {}
local isSent, isArrived, addedPlayer = false, false

--玩家头像
local headPortrait

---初始化
function Init()
    InitEvents()
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
    GetPlayerProfile(_player)

    playerInfoTab[_player] = headPortrait
    table.insert(playerList, _player)

    addedPlayer = _player

    local broadcast = function()
        M.Kit.Util.Net.Broadcast('NoticeEvent', playerInfoTab, playerList, addedPlayer, true)
        isSent = true
    end
    invoke(broadcast, 1)
end

function OnPlayerRemoved(_player)
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
function Update(_dt)
    if isArrived then return end
    tt = tt + _dt
    if isSent and tt > 1 then
        tt = 0
        M.Kit.Util.Net.Broadcast('NoticeEvent', playerInfoTab, playerList, addedPlayer, true)
    end
end

function ConfirmNoticeEventHandler(_boolean)
    isArrived = _boolean
    isSent = not _boolean
end

function GetPlayerProfile(_player)
    local callback = function(_profile)
        headPortrait = _profile.HeadPortrait
    end

    PlayerHub.GetPlayerProfile(_player.UserId, callback)
end

function MuteLocalEventHandler(_playerId, _isOn)
    for _, v in pairs(playerList) do
        M.Kit.Util.Net.Fire_C('MuteSpecificPlayerEvent', v, _playerId, not _isOn)
    end
end

function TeleportPlayerToFriendGameEventHandler(_player, _roomId)
    local callbackTeleport = function()
        --TODO: 处理回调函数
    end
    Game.TeleportPlayerToRoom(_player, _roomId, {}, callbackTeleport)
end

--! Public methods
M.Init = Init
M.playerList = playerList
M.MuteLocalEventHandler = MuteLocalEventHandler
M.TeleportPlayerToFriendGameEventHandler = TeleportPlayerToFriendGameEventHandler
M.ConfirmNoticeEventHandler = ConfirmNoticeEventHandler
return M
