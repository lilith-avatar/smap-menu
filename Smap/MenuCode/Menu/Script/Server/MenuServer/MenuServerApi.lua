--- 菜单模块的外部服务端API
--- @module MenuServerApi
--- @copyright Lilith Games, Avatar Team
--- @author ropztao

-- Local Caches
local S = _G.mS

--* 模块
local M = S.ModuleUtil.New('MenuServerApi', S.Base)

function EnableSubChannel(_boolean, _tab)
    if _boolean then
        M.Kit.Util.Net.Fire_S('EnableSubChannelEvent', _boolean, _tab)
    else
        M.Kit.Util.Net.Fire_S('EnableSubChannelEvent', _boolean)
    end
end

function SwitchOfflineState(_boolean)
    if _boolean then
        M.Kit.Util.Net.Fire_S('SwitchOfflineStateEvent', _boolean)
    else
        M.Kit.Util.Net.Fire_S('SwitchOfflineStateEvent', _boolean)
    end
end

--! Public methods
M.EnableSubChannel = EnableSubChannel
M.SwitchOfflineState = SwitchOfflineState

--! Global Public API
_G.MenuServerApi = M

return M
