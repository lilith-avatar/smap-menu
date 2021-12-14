--- 过渡动画UI（Landscape）
--- @module Costom GUI
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

local M = {}

-- cache 缓存本地变量
local Vector2, Color, Enum, invoke = Vector2, Color, Enum, invoke

-- GUI
-- 根节点（Init时候被赋值）
local root
--* ScreenGUI界面
local gui
-- 过场动画节点
local imgBg, imgIcon

-- 过场动画参数
local screenX  -- 屏幕宽度
local moveInStartOffsetX, moveInEndOffsetX  -- 入场动画：背景位移
local moveOutStartOffsetX, moveOutEndOffsetX  -- 出场动画：背景位移

-- Const 常量
local SCALE_X = 0.262 -- 斜度与中间部分的比例
local TW_OPEN_DUR = 0.8 -- 入场动画时间
local TW_CLOSE_DUR = 0.5 -- 出场动画时间
local COLOR_WHITE_TRANSPARENT = Color(255, 255, 255, 0)
local COLOR_WHITE_FULL = Color(255, 255, 255, 255)

--- 初始化
function Init(_root)
    root = _root
    InitLocalVars() -- 本地变量
    BindEvent() -- 事件绑定
    InitGuiNodes() -- GUI节点
    InitTweenNodes() -- Tween动画节点
end

--- 初始化本地变量
function InitLocalVars()
    -- GUI nodes
    gui = root.Gui_Transition
end

--- 事件绑定
function BindEvent()
    M.Event.Root:Connect(EventHandler)
end

--- 事件处理
function EventHandler(_event, ...)
    if _event == M.Event.Enum.OPEN then
        PlayOpenAnim()
    elseif _event == M.Event.Enum.CLOSE_TRANSITION then
        PlayCloseAnim()
    end
end

--- 初始化GUI节点
function InitGuiNodes()
    imgBg = gui.Img_Bg
    imgIcon = gui.Img_Icon

    screenX = imgBg.FinalSize.X / (imgBg.AnchorsX.Y - imgBg.AnchorsX.X) -- 屏幕宽度
end

--- 初始化Tween动画节点
function InitTweenNodes()
    InitOpenTweens()
    InitCloseTweens()
end

-- 初始化入场动画
function InitOpenTweens()
    moveInStartOffsetX = screenX
    moveInEndOffsetX = -imgBg.FinalSize.X
    -- 背景动画 MoveIn
    imgBg.TweenMoveIn.Properties = {Offset = Vector2(moveInEndOffsetX, 0)}
    imgBg.TweenMoveIn.EaseCurve = Enum.EaseCurve.Linear
    imgBg.TweenMoveIn.Duration = TW_OPEN_DUR
    imgBg.TweenMoveIn.OnComplete:Connect(
        function()
            gui.Enable = false --! 播放后关闭GUI
        end
    )

    -- Icon Alpha
    imgIcon.TweenAlpha.Properties = {Color = COLOR_WHITE_FULL}
    imgIcon.TweenAlpha.Loop = 2
    imgIcon.TweenAlpha.LoopType = Enum.LoopType.Yoyo
    imgIcon.TweenAlpha.EaseCurve = Enum.EaseCurve.Linear
    imgIcon.TweenAlpha.Duration = TW_OPEN_DUR * 0.5
    imgIcon.TweenAlpha.OnComplete:Connect(
        function()
            imgIcon.TweenAlpha.Parent.Color = COLOR_WHITE_TRANSPARENT
        end
    )
end

-- 初始化出场动画
function InitCloseTweens()
    moveOutStartOffsetX = -imgBg.FinalSize.X
    moveOutEndOffsetX = -imgBg.FinalSize.X * SCALE_X
    -- 背景动画 MoveOut
    imgBg.TweenMoveOut.Properties = {Offset = Vector2(moveOutEndOffsetX, 0)}
    imgBg.TweenMoveOut.EaseCurve = Enum.EaseCurve.Linear
    imgBg.TweenMoveOut.Duration = TW_CLOSE_DUR
    imgBg.TweenMoveOut.OnComplete:Connect(
        function()
            M.Fire(M.Event.Enum.CLOSE)
            imgBg.TweenAlpha:Flush()
            imgBg.TweenAlpha:Play() --! 播放淡出动画
        end
    )

    -- 背景动画 Alpha
    imgBg.TweenAlpha.Properties = {Color = COLOR_WHITE_TRANSPARENT}
    imgBg.TweenAlpha.EaseCurve = Enum.EaseCurve.CubicOut
    imgBg.TweenAlpha.Duration = TW_CLOSE_DUR * 0.5
    imgBg.TweenAlpha.OnComplete:Connect(
        function()
            gui.Enable = false --! 播放后关闭GUI
        end
    )
end

--! 转场动画

-- 开场动画
function PlayOpenAnim()
    gui.Enable = true
    -- 设置动画前参数
    imgBg.Color = COLOR_WHITE_FULL
    imgBg.Offset = Vector2(moveInStartOffsetX, 0)
    imgIcon.Color = COLOR_WHITE_TRANSPARENT

    --* 背景动画 MoveIn
    imgBg.TweenMoveIn:Flush()
    imgBg.TweenMoveIn:Play()

    --* Icon动画
    imgIcon.TweenAlpha:Flush()
    imgIcon.TweenAlpha:Play()
end

-- 结束动画
function PlayCloseAnim()
    gui.Enable = true
    -- 设置动画前参数
    imgBg.Offset = Vector2(moveOutStartOffsetX, 0)
    imgBg.Color = COLOR_WHITE_FULL
    imgIcon.Color = COLOR_WHITE_TRANSPARENT

    --* 背景动画 Move，然后自动播放 imgBg.TweenAlpha
    imgBg.TweenMoveOut:Flush()
    imgBg.TweenMoveOut:Play()
end

--! public methods
M.Init = Init

return M
