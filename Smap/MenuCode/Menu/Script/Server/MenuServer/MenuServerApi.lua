--- 菜单模块的外部服务端API
--- @module MenuServerApi
--- @copyright Lilith Games, Avatar Team
--- @author ropztao

-- Local Caches
local S = _G.mS

--* 模块
local M = S.ModuleUtil.New('MenuServerApi', S.Base)

function SwitchOfflineState(_boolean)
        M.Kit.Util.Net.Fire_S('SwitchOfflineStateEvent', _boolean)
        M.Kit.Util.Net.Broadcast('SwitchOfflineStateEvent', _boolean)
end

function ChangeQuitInfo()
    print('change quit event server')
    M.Kit.Util.Net.Broadcast('ChangeQuitInfoEvent')
end

--! Public methods
M.SwitchOfflineState = SwitchOfflineState

--! Global Public API
_G.MenuServerApi = M

return M
