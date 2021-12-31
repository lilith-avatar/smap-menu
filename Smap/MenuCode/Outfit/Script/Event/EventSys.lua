--- 事件系统
--- @module Outfit Event System
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

-- Local Cache
local Debug = Debug

--* 模块
local M = {}

local root = {}

function AddListener(_handler)
    Debug.Assert(type(_handler) == 'function', '[换装] 事件handler必须为function')
    table.insert(root, _handler)
end

function RemoveListener(_handler)
    Debug.Assert(type(_handler) == 'function', '[换装] 事件handler必须为function')
    for i = #root, 1, -1 do
        if root[i] == _handler then
            table.remove(root, i)
        end
    end
end

function RemoveAllListeners()
    root = {}
end

function Dispatch(...)
    for _, hdl in ipairs(root) do
        hdl(...)
    end
end

--! public methods
M.Root = root
M.AddListener = AddListener
M.Dispatch = Dispatch
M.RemoveListener = RemoveListener
M.RemoveAllListeners = RemoveAllListeners

return M
