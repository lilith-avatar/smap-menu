--- 菜单模块的外部API
--- @module MenuApi
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local invoke = invoke
local ChatManager = ChatManager
local C = _G.C

--* 模块
local M = C.ModuleUtil.New('MenuApi', C.Base)

function DeveloperOfficialMsg(_content)
    M.Kit.Util.Net.Fire_S('InGamingImEvent', 'Developer', _content)
end

-- 初始化换装
local Outfit = require('Outfit/Script/Main')
invoke(Outfit.Init)

--! Public methods
M.DeveloperOfficialMsg = DeveloperOfficialMsg

--* 换装相关API
M.Outfit = {}
M.Outfit.Open = Outfit.Open
M.Outfit.Close = Outfit.Close
M.Outfit.IsOpen = Outfit.IsOpen
M.Outfit.Toggle = Outfit.Toggle

--! Global Public API
_G.Menu = M

return M
