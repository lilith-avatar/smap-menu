--- 菜单模块的外部API
--- @module MenuApi
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

local M, this = ModuleUtil.New('MenuApi', ClientBase)

function DeveloperOfficialMsg(_content)
    NetUtil.Fire_S('InGamingImEvent', 'Developer', _content)
end

--! Public
M.DeveloperOfficialMsg = DeveloperOfficialMsg

return M
