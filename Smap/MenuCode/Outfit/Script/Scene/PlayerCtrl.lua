--- 换装系统
--- @module Costom Player Controller
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

local M = {}

-- 根节点（Init时候被赋值）
local root
local booth  -- 换装亭
local npc  -- 换装模特
local avatar  -- 模特形象
local currAnim  --当前动画

-- 动画资源根目录
local RES_ANIM_ROOT_PATH = 'Outfit/Anim/'

-- NPC形象默认旋转
local NPC_DEFAULT_LOCAL_ROT = EulerDegree(0, 0, 0)

-- 动画资源名称
local anims = {
    idle = 'm_01_idle_stand_01',
    sit = 'h_01_sit_loop_02'
}

--- 初始化
function Init(_root)
    root = _root
    InitLocalVars()
    BindEvent()
end

--- 初始化本地变量
function InitLocalVars()
    -- 变量
    booth = root.Booth
    npc = booth.Npc
    avatar = npc.NpcAvatar
    currAnim = 'idle'

    -- 状态
    npc.Enable = false
end

--- 事件绑定
function BindEvent()
    M.Event.Root:Connect(EventHandler)
end

--- 事件处理
function EventHandler(_event, ...)
    if _event == M.Event.Enum.OPEN then
        local args = {...}
        booth.Position = args[1] or localPlayer.Position
        localPlayer.Enable = false
        npc.Enable = true
        currAnim = 'idle' -- TODO: 目前默认只有idle
        avatar.LocalRotation = NPC_DEFAULT_LOCAL_ROT
        PlayAnim()
    elseif _event == M.Event.Enum.CLOSE then
        localPlayer.Enable = true
        npc.Enable = false
    elseif _event == M.Event.Enum.NPC_ROT then
        local args = {...}
        local diff = args[1]
        UpdateNpcRotation(nil, diff)
    end
end

--- 更新玩家旋转
function UpdateNpcRotation(_localRot, _deltaRotY)
    if _localRot then
        avatar.LocalRotation = _localRot
    end

    if _deltaRotY then
        avatar:Rotate(0, _deltaRotY, 0)
    end
end

--- 播放动画
function PlayAnim()
    avatar:ImportAnimation(ResourceManager.GetAnimation(RES_ANIM_ROOT_PATH .. anims[currAnim]))
    avatar:PlayAnimation(anims[currAnim], 2, 1, 0, true, true, 1)
end

--! public method
M.Init = Init

return M
