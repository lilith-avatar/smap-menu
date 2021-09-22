--- 控件基类
--- @module CtrBase
--- @copyright Lilith Games, Avatar Team
--- @author ropztao
local CtrBase = class('CtrBase')

function CtrBase:initialize(_stateMachineNode, _folder)

end

--绑定所有状态
function CtrBase:ConnectStates(_controller, _folder)

end

--初始化默认状态
function CtrBase:SetDefState(_stateName)

end

--切换状态
function CtrBase:Switch(_state)
    
end

function CtrBase:Update(dt)
    
end

return CtrBase
