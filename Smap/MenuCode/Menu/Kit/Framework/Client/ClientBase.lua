--- 客户端模块基础类, Client Module Base Class
--- @module ClientBase, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local world, class = world, class
local Debug = Debug

--* 模块
local M = class('ClientBase')

function M:GetSelf()
    return self
end

--- 加载的时候运行的代码
function M:InitDefault(_module)
    Debug.Log(string.format('[ClientBase][%s] InitDefault()', self.name))
    -- 初始化默认监听事件
    M.Kit.Util.Event.LinkConnects(world.MenuNode.C_Event, _module, self)
end

return M
