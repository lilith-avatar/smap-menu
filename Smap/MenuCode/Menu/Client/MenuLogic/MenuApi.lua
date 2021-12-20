--- 菜单模块的外部API
--- @module MenuApi
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local invoke, localPlayer = invoke, localPlayer
local ChatManager = ChatManager
local C = _G.mC

--* 模块
local M = C.ModuleUtil.New('MenuApi', C.Base)

function DeveloperOfficialMsg(_content)
    M.Kit.Util.Net.Fire_S('InGamingImEvent', 'Developer', _content)
end

function MenuSwitch(_type, _boolean)
    M.Kit.Util.Net.Fire_C('MenuSwitchEvent', localPlayer, _type, _boolean)
end

function SwichOutfitEntrance(_boolean)
    M.Kit.Util.Net.Fire_C('SwitchOutfitEntranceEvent', localPlayer, _boolean)
end

function SwitchVoice(_boolean)
    M.Kit.Util.Net.Fire_C('SwitchVoiceEvent', localPlayer, _boolean)
end

function SwitchInGameMessage(_boolean)
    M.Kit.Util.Net.Fire_C('SwitchInGameMessageEvent', localPlayer, _boolean)
end

-- 初始化换装
local Outfit = require('Outfit/Script/Main')
invoke(Outfit.Init)

--! Public methods
M.DeveloperOfficialMsg = DeveloperOfficialMsg
M.MenuSwitch = MenuSwitch
M.SwichOutfitEntrance = SwichOutfitEntrance
M.SwitchVoice = SwitchVoice
M.SwitchInGameMessage = SwitchInGameMessage

--* 换装相关API
M.Outfit = {}
M.Outfit.Open = Outfit.Open
M.Outfit.Close = Outfit.Close
M.Outfit.IsOpen = Outfit.IsOpen
M.Outfit.Toggle = Outfit.Toggle

--! Global Public API
_G.Menu = M

return M
