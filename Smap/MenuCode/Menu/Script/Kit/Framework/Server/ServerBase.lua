--- 服务器模块基础类, Server Module Base Class
--- @module ServerBase, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Dead Ratman, ropztao

-- Local Caches
local world, class = world, class
local Debug = Debug

--* 模块
local M = class('ServerBase')

function M:GetSelf()
    return self
end

--- 加载的时候运行的代码
function M:InitDefault(_module)
    Debug.Log(string.format('[ServerBase][%s] InitDefault()', self.name))
    -- 初始化默认监听事件
    M.Kit.Util.Event.LinkConnects(world.MenuNode.MenuEvent_S, _module)
end

return M
