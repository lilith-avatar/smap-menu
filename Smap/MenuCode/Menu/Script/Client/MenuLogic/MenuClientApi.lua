--- 菜单模块的外部客户端API
--- @module MenuClientApi
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local invoke, localPlayer = invoke, localPlayer
local ChatManager, world = ChatManager, world
local C = _G.mC
local isReady = false

--* 模块
local M = C.ModuleUtil.New('MenuClientApi', C.Base)

---@param _sender PlayerInstance
---@param _content String
function SendMsg(_sender, _content)
    M.Kit.Util.Net.Fire_S('InGamingImEvent', _sender, _content)
end

-- @param _type 都关 = 0，只关外部三个按钮为1，只关菜单显示为2
-- @param _boolean 打开还是关闭
function MenuSwitch(_type, _boolean)
    M.Kit.Util.Net.Fire_C('MenuSwitchEvent', localPlayer, _type, _boolean)
end

-- @param _boolean 打开还是关闭，下同
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

function ClientReadyEventHandler(_isReady)
    isReady = _isReady
end

function LowQualityWarningEventHandler(_bool)
    if world.PerformanceEffects == nil then
        return
    else
        world.PerformanceEffects:SetActive(_bool)
    end
end

function IsReady()
    return isReady
end

function AllowExit(_boolean)
    M.Kit.Util.Net.Fire_C('AllowExitEvent', localPlayer, _boolean)
end

function SwitchVoiceRelated(_boolean)
    M.Kit.Util.Net.Fire_C('SwitchVoiceBtnEvent', localPlayer, _boolean)
end

function SwitchFriendsInteraction(_boolean)
    M.Kit.Util.Net.Fire_C('SwitchFriendsInteractionEvent', localPlayer, _boolean)
end

--! Public methods
M.ClientReadyEventHandler = ClientReadyEventHandler
M.LowQualityWarningEventHandler = LowQualityWarningEventHandler
M.MenuSwitch = MenuSwitch
M.SwitchVoice = SwitchVoice
M.SwitchInGameMessage = SwitchInGameMessage
M.DetectMenuDisplayState = DetectMenuDisplayState
M.IsReady = IsReady
M.AllowExit = AllowExit
M.SwitchVoiceRelated = SwitchVoiceRelated
M.SendMsg = SendMsg
M.SwitchFriendsInteraction = SwitchFriendsInteraction

--! Global Public API
_G.Menu = M

return M
