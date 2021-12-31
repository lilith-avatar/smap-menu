--- 换装系统
--- @module Outfit Player Controller
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

local wait, invoke = wait, invoke
local localPlayer = localPlayer
local Vector2, Vector3, EulerDegree = Vector2, Vector3, EulerDegree
local NotReplicate = NotReplicate
local ResourceManager = ResourceManager

--* 模块
local M = {}

-- 根节点（Init时候被赋值）
local root
local booth  -- 换装亭
local npc  -- 换装模特
local avatar  -- 模特形象
local gui  -- 玩家头上的SurfaceGUI，用于显示换装标志
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

-- 玩家头顶的换装标志路径
local RES_SIGN = 'Outfit/Gui/Icon/svg_Sic_clothes'
local SIGN_LOCAL_POS = Vector3(0, 2.5, 0)

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
    InitSurfaceGui()
    SetGraphicsQuality()
    avatar:SetEnableBatch(false)
    BindEvent()
end

--- 初始化本地变量
function InitLocalVars()
    -- 变量
    booth = root.Booth
    npc = booth.Npc
    avatar = npc.NpcAvatar
    currBodyAnim = 'idle'
    currEmoAnim = 'blink'

    -- 状态
    npc.Enable = false
end

function InitSurfaceGui()
    gui = world:CreateObject('UiSurfaceUiObject', 'Gui_Outfit_Sign', localPlayer)
    gui.LocalPosition = SIGN_LOCAL_POS
    gui.Billboard = true
    local img = world:CreateObject('UiImageObject', 'Img_Sign', gui)
    img.Size = Vector2(80, 80)
    img.Texture = ResourceManager.GetTexture(RES_SIGN)
    gui.Enable = false
end

--- 事件绑定
function BindEvent()
    M.AddEventListener(EventHandler)
end

--- 事件处理
function EventHandler(_event, ...)
    if _event == M.Event.Enum.OPEN then
        booth.Enable = true
        booth.Position = localPlayer.Position
        booth.Rotation = EulerDegree(0, localPlayer.Rotation.Y, 0)
        localPlayer.Avatar.AvatarDisplay.Enable = false
        npc.Enable = true
        avatar.LocalPosition = Vector3.Zero
        avatar.LocalRotation = NPC_DEFAULT_LOCAL_ROT

        -- Sign
        gui.Enable = true
        NotReplicate(
            function()
                gui.Enable = false
            end
        )

        -- Anim
        currBodyAnim = 'idle' -- TODO: 目前默认只有idle
        currEmoAnim = 'blink'
        invoke(PlayBodyAnim)
        invoke(PlayEmoAnim)
    elseif _event == M.Event.Enum.CLOSE then
        booth.Enable = false
        localPlayer.Avatar.AvatarDisplay.Enable = true
        npc.Enable = false
        gui.Enable = false
    end
end

--- 设置人物和画面质量
function SetGraphicsQuality()
    -- 人物LOD设为最高的
    avatar:SetAutoSwitchLOD(false)
    avatar:ForceSwitchToLODLevel(0)
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
