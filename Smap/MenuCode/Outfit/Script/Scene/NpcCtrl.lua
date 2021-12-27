--- 换装系统
--- @module Outfit Player Controller
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

local wait, localPlayer = wait, localPlayer
local Vector3, EulerDegree = Vector3, EulerDegree
local ResourceManager = ResourceManager

--* 模块
local M = {}

-- 根节点（Init时候被赋值）
local root
local booth  -- 换装亭
local shelter  -- 玩家隐藏点
local npc  -- 换装模特
local avatar  -- 模特形象
local currBodyAnim  --当前全身动画
local currEmoAnim  --当前表情动画

-- 当前已播放标签动画
local emoAnimIsPlaying = false

-- 动画资源根目录
local RES_ANIM_ROOT_PATH = 'Outfit/Anim/'

-- 眨眼间隔时间
local EMO_MIN, EMO_MAX = 3, 5

-- NPC形象默认旋转
local NPC_DEFAULT_LOCAL_ROT = EulerDegree(0, 0, 0)

-- 隐藏点深度
local SHELTER_POS_Y = -50

-- localPlayer 的临时缓存位置
local cachePos

-- 动画资源名称
local anims = {
    body = {
        idle = 'm_01_idle_stand_01'
    },
    emo = {
        default = 'u_01_face_emotion_default_01',
        special = 'u_01_face_emotion_special_01'
    }
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
    shelter = root.Shelter
    npc = booth.Npc
    avatar = npc.NpcAvatar
    currBodyAnim = 'idle'
    currEmoAnim = 'blink'

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
        booth.Enable = true
        shelter.Enable = true
        shelter.Position = Vector3(localPlayer.Position.X, SHELTER_POS_Y, localPlayer.Position.Z)
        booth.Position = localPlayer.Position
        booth.Rotation = EulerDegree(0, localPlayer.Rotation.Y, 0)
        cachePos = localPlayer.Position
        localPlayer.Position = shelter.Position
        npc.Enable = true
        avatar.LocalPosition = Vector3.Zero
        currBodyAnim = 'idle' -- TODO: 目前默认只有idle
        currEmoAnim = 'blink'
        avatar.LocalRotation = NPC_DEFAULT_LOCAL_ROT
        PlayBodyAnim()
        PlayEmoAnim()
    elseif _event == M.Event.Enum.CLOSE then
        booth.Enable = false
        shelter.Enable = false
        localPlayer.Position = cachePos
        npc.Enable = false
    end
end

--- 播放身体动画
function PlayBodyAnim()
    avatar:ImportAnimation(ResourceManager.GetAnimation(RES_ANIM_ROOT_PATH .. anims.body[currBodyAnim]))
    local graph = avatar.AnimationGraph
    local animBody = graph:AddAnimationTree('animBody')
    local anim = animBody:AddClipNode(anims.body[currBodyAnim])
    anim.Loop = true
    graph:InstantiateAnimationGraphTo(avatar)
    avatar:PlayAnimationTree('animBody')
    -- avatar:PlayAnimation(anims.body[currBodyAnim], 2, 1, 0, true, true, 1)
end

--- 播放表情动画
function PlayEmoAnim()
    if not emoAnimIsPlaying then
        emoAnimIsPlaying = true
        local graph = avatar.AnimationGraph
        local animEmo = graph:AddAnimationTree('animEmo')
        for _, name in pairs(anims.emo) do
            local clip = animEmo:AddClipNode(name)
            clip.Loop = false
        end
        while (wait(math.random(EMO_MIN, EMO_MAX))) do
            local head = avatar:GetHeadObject()
            if head ~= nil then
                head.BlendSpaceNodeEnabled = true
                if currEmoAnim == 'default' then
                    currEmoAnim = 'special'
                else
                    currEmoAnim = 'default'
                end
                -- Debug.LogWarning(string.format('[换装]当前动画：%s', anims.emo[currEmoAnim]))
                head:ImportAnimation(ResourceManager.GetAnimation(RES_ANIM_ROOT_PATH .. anims.emo[currEmoAnim]))
                graph:InstantiateAnimationGraphTo(head)
                head:PlayAnimationTree('animEmo')
            -- head:PlayAnimation(anims.emo[currEmoAnim], 2, 1, 0, true, false, 1)
            end
        end
    end
end

--! public method
M.Init = Init

return M
