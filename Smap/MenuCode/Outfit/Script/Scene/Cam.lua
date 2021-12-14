--- 换装系统相机（Landscape）
--- @module Costom Camera
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

local M = {}

-- 根节点（Init时候被赋值）
local root

-- 对其他模块的索引
local cache, cam = {}
local npc  -- 换装模特
local figTouchZone  -- 玩家的触摸区域，也用作屏幕尺寸的标准

-- 常量
local CAM_LOCAL_POS_2TO1 = Vector3(0.1, 1.88, 8) -- 标准 2:1 的竖屏
local CAM_LOCAL_POS_4TO3 = Vector3(0.58, 1.88, 8) -- 标准 4:3 的竖屏

function Init(_root)
    root = _root
    InitLocalVars()
    BindEvent()
end

--- 初始化本地变量
function InitLocalVars()
    -- 3D
    cam = root.Booth.Cam_Outfit
    npc = root.Booth.Npc
    cam.LookAt = npc
    -- GUI
    figTouchZone = root.Gui_Avatar.Fig_TouchZone
end

--- 设置相机空间位置
function SetCamLocalTrans()
    -- Debug.LogWarning(string.format('[换装] 屏幕尺寸 Pnl_TouchZone.FinalSize = (%s)', figTouchZone.FinalSize))
    --* 根据1:2和3:4两个标准尺寸，算出当前尺寸的相机位置
    local ratioXY = figTouchZone.FinalSize.X / figTouchZone.FinalSize.Y
    local t = (ratioXY - 4 / 3) / (2 / 1 - 4 / 3)
    -- 设置相机位置和方向
    cam.LocalPosition = Vector3.Lerp(CAM_LOCAL_POS_4TO3, CAM_LOCAL_POS_2TO1, t)
end

--- 事件绑定
function BindEvent()
    M.Event.Root:Connect(EventHandler)
end

--- 事件处理
function EventHandler(_event, ...)
    if _event == M.Event.Enum.OPEN then
        CamEnable()
    elseif _event == M.Event.Enum.CLOSE then
        CamDisable()
    end
end

--- 启动换装相机
function CamEnable()
    cache.camera = world.CurrentCamera
    world.CurrentCamera = cam
    SetCamLocalTrans()
end

--- 关闭换装相机，恢复原本的世界相机
function CamDisable()
    world.CurrentCamera = cache.camera
    cam.Enable = false
end

--! public method
M.Init = Init

return M
