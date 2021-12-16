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
local TOUCH_ZONE_PAN_2_NPC_ROT = -0.5 --* 手指滑动位移x转换成NPC转向位移系数
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
    local OnPanStayHandler = function(_pos, _panDistance, _deltaDistance)
        print('OnPanStayHandler', _pos)
        local diff = _deltaDistance.X * TOUCH_ZONE_PAN_2_NPC_ROT
        M.Fire(M.Event.Enum.NPC_ROT, diff)
    end
    figTouchZone.OnPanStay:Connect(OnPanStayHandler)

    --! TEST 鼠标右键旋转
    local OnKeyHoldHandler = function()
        if Input.GetPressKeyData(Enum.KeyCode.Mouse1) == Enum.KeyState.KeyStateHold then
            local pos = Input.GetMouseScreenPos()
            if mousePos then
                local diff = (pos.x - mousePos.x) * TOUCH_ZONE_INPUT_2_NPC_ROT
                -- 发出事件
                M.Fire(M.Event.Enum.NPC_ROT, diff)
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

--! public method
M.Init = Init

return M
