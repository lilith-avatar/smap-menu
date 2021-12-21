--- 换装系统
--- @module Outfit Player Controller
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

local M = {}

-- 本地缓存
local wait = wait
local Enum, Vector2, Vector3, EulerDegree = Enum, Vector2, Vector3, EulerDegree
local world, Game, Debug, Input, ResourceManager, ScreenCapture =
    world,
    Game,
    Debug,
    Input,
    ResourceManager,
    ScreenCapture

-- 根节点（Init时候被赋值）
local root
local booth  -- 换装亭
local npc  -- 换装模特
local avatar  -- 模特形象

--* GUI
local guiAvatar  -- 截屏界面
-- 玩家人物快照：全身、头像
local figTouchZone  --* 触摸区域panel节点，也用于计算fig的大小

--* 本地变量
local mousePos = nil --! TEST ONLY: 开启鼠标右键监听事件

--* 枚举常量
-- 事件常量
local TOUCH_ZONE_PAN_2_NPC_ROT = -0.2 --* 手指滑动位移x转换成NPC转向位移系数
local TOUCH_ZONE_INPUT_2_NPC_ROT = -0.2 --! TEST 鼠标右键滑动位移x转换成NPC转向位移系数

--- 初始化
function Init(_root)
    root = _root
    InitLocalVars()
    BindEvent()
    InitPnls() -- 触摸功能
end

--- 初始化本地变量
function InitLocalVars()
    booth = root.Booth
    npc = booth.Npc
    avatar = npc.NpcAvatar

    --* GUI
    -- 玩家人物快照：全身、头像
    guiAvatar = root.Gui_Avatar
    figTouchZone = guiAvatar.Fig_TouchZone
end

--- 事件绑定
function BindEvent()
    M.Event.Root:Connect(EventHandler)
end

--- 事件处理
function EventHandler(_event, ...)
    if _event == M.Event.Enum.OPEN then
        guiAvatar.Enable = true
    elseif _event == M.Event.Enum.CLOSE then
        guiAvatar.Enable = false
    end
end

--- 初始化界面
function InitPnls()
    --* 拖动Fig转动人物
    local OnTouched = function(_touchInfo)
        if #_touchInfo == 1 then
            local diff = _touchInfo[1].DeltaPosition.X * TOUCH_ZONE_PAN_2_NPC_ROT
            UpdateNpcRotation(nil, diff)
        end
    end
    figTouchZone.OnTouched:Connect(OnTouched)

    --! TEST 鼠标右键旋转
    local OnKeyHoldHandler = function()
        if Input.GetPressKeyData(Enum.KeyCode.Mouse1) == Enum.KeyState.KeyStateHold then
            local pos = Input.GetMouseScreenPos()
            if mousePos then
                local diff = (pos.x - mousePos.x) * TOUCH_ZONE_INPUT_2_NPC_ROT
                -- 发出事件
                UpdateNpcRotation(nil, diff)
            end
            mousePos = pos
        end
    end
    Input.OnKeyHold:Connect(OnKeyHoldHandler)

    --! TEST 鼠标右键旋转
    local OnKeyUpHandler = function()
        if Input.GetPressKeyData(Enum.KeyCode.Mouse1) == Enum.KeyState.KeyStateRelease then
            mousePos = nil
        end
    end
    Input.OnKeyUp:Connect(OnKeyUpHandler)
end

--! 人物旋转

--- 更新玩家旋转
function UpdateNpcRotation(_localRot, _deltaRotY)
    if _localRot then
        avatar.LocalRotation = _localRot
    end

    if _deltaRotY then
        avatar:Rotate(0, _deltaRotY, 0)
    end
end

--! public method
M.Init = Init

return M
