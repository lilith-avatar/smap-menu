--- 服务器模块基础类, Server Module Base Class
--- @module ServerBase, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Dead Ratman, ropztao
local M = class('ServerBase')

function M:GetSelf()
    return self
end

--- 加载的时候运行的代码
function M:InitDefault(_module)
    Debug.Log(string.format('[ServerBase][%s] InitDefault()', self.name))
    -- 初始化默认监听事件
    M.Kit.Util.Event.LinkConnects(world.MenuNode.S_Event, _module, self)
end

return M
