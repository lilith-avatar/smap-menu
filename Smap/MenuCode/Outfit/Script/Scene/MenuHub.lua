--- 与菜单相关接口（Landscape）
--- @module Menu Related
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

-- Local caches
local localPlayer = localPlayer

--* 模块
local M = {}

function Init()
    BindEvent()
end

--- 事件绑定
function BindEvent()
    M.Event.Root:Connect(EventHandler)
end

--- 事件处理
function EventHandler(_event, ...)
    if _event == M.Event.Enum.CLOSE then
        FireMenuEvent()
    end
end

--- 告诉Menu需要关闭
function FireMenuEvent()
    local closeOutfitEvent = localPlayer.MenuEvent_C.CloseOutfitEvent
    if closeOutfitEvent then
        closeOutfitEvent:Fire()
    end
end

--! public method
M.Init = Init

return M
