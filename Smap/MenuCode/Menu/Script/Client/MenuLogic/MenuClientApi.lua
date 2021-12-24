--- 菜单模块的外部客户端API
--- @module MenuClientApi
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local invoke, localPlayer = invoke, localPlayer
local ChatManager = ChatManager
local C = _G.mC
local isReady = false

--* 模块
local M = C.ModuleUtil.New('MenuClientApi', C.Base)

function DeveloperOfficialMsg(_content)
    M.Kit.Util.Net.Fire_S('InGamingImEvent', 'Developer', _content)
end

-- @param _type 都关 = 0，只关外部三个按钮为1，只关菜单显示为2
-- @param _boolean 打开还是关闭
function MenuSwitch(_type, _boolean)
    M.Kit.Util.Net.Fire_C('MenuSwitchEvent', localPlayer, _type, _boolean)
end

-- @param _boolean 打开还是关闭，下同
function SwitchOutfitEntrance(_boolean)
    M.Kit.Util.Net.Fire_C('SwitchOutfitEntranceEvent', localPlayer, _boolean)
end

function SwitchVoice(_type, _boolean)
    M.Kit.Util.Net.Fire_C('SwitchVoiceEvent', localPlayer, _type, _boolean)
end

function SwitchInGameMessage(_boolean)
    M.Kit.Util.Net.Fire_C('SwitchInGameMessageEvent', localPlayer, _boolean)
end

-- 检测状态并反向操作（如果开则关，如果关则开）
-- @param _type im弹窗为0,菜单显示为1
function DetectMenuDisplayState(_type)
    M.Kit.Util.Net.Fire_C('DetectMenuDisplayStateEvent', localPlayer, _type)
end

function EnableSubChannel(_boolean, _tab)
    if _boolean then
        M.Kit.Util.Net.Fire_S('EnableSubChannelEvent', _boolean, _tab)
    else
        M.Kit.Util.Net.Fire_S('EnableSubChannelEvent', _boolean)
    end
end

function ClientReadyEventHandler(_isReady)
    isReady = _isReady
end

function IsReady()
    return isReady
end

-- 初始化换装
local Outfit = require('Outfit/Script/Main')
invoke(Outfit.Init)

--! Public methods
M.ClientReadyEventHandler = ClientReadyEventHandler
M.DeveloperOfficialMsg = DeveloperOfficialMsg
M.MenuSwitch = MenuSwitch
M.SwitchOutfitEntrance = SwitchOutfitEntrance
M.SwitchInGameMessage = SwitchInGameMessage
M.DetectMenuDisplayState = DetectMenuDisplayState
M.EnableSubChannel = EnableSubChannel
M.IsReady = IsReady

--* 换装相关API
M.Outfit = {}
M.Outfit.Open = Outfit.Open
M.Outfit.Close = Outfit.Close
M.Outfit.IsOpen = Outfit.IsOpen
M.Outfit.Toggle = Outfit.Toggle

--! Global Public API
_G.Menu = M

return M
