--- 菜单模块的外部API
--- @module MenuApi
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local ChatManager = ChatManager
local C = _G.C

--* 模块
local M = C.ModuleUtil.New('MenuApi', C.Base)

function DeveloperOfficialMsg(_content)
    M.Kit.Util.Net.Fire_S('InGamingImEvent', 'Developer', _content)
end

--! Public methods
M.DeveloperOfficialMsg = DeveloperOfficialMsg

return M
