--- 菜单GUI显示
--- @module MenuDisplay
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang, Fenglei Cai

-- Local Caches
local Enum, Vector2, Color = Enum, Vector2, Color
local world, localPlayer, PlayerHub = world, localPlayer, PlayerHub
local Debug, ResourceManager, Game, Friends, invoke = Debug, ResourceManager, Game, Friends, invoke
local C = _G.mC
--* 模块
local M, this = C.ModuleUtil.New('MenuDisplay', C.Base)

-- 常量
local MUTEALL_OFF_COLOR, MUTEALL_ON_COLOR = Color(38, 121, 217, 255), Color(222, 69, 119, 230)

-- 本地变量
local lastLocalMicVolume = 0
local lastLocalListenVolume = 0;
local isLocalMicVolume = true
local isLocalListenVolume = true
local isOpen, isMuteAll, isOn, isDisplay, mutedPlayerId = false, false, true, false, nil
local headImgCache, length, mutedPlayerTab, friTab = {}, nil, {}, {}
local isNone, isReady = true, false
local gui = {}
local i, headPortrait = 0, nil
local voiceOff = Vector2(196, 0)
local friText, playerText, imText = 'Friends', 'Player', 'Say Something'
local headColorTab = {
    Color(255, 94, 94, 255),
    Color(230, 210, 92, 255),
    Color(91, 25, 157, 255),
    Color(128, 130, 204, 255),
    Color(77, 215, 203, 255),
    Color(81, 155, 72, 255)
}

local playerList = nil

local resReplaceTab = {
    Gaming = 'games',
    FriList = 'friends',
    Setting = 'settings',
}

local GAME_TAG = 'avatar_menu'
local MSG_NATIVE_TO_LUA = 'msg_native_exterior_mgr'
local MSG_LUA_TO_NATIVE = 'msg_exterior_mgr'
--native to lua
local NATIVE_TO_LUA = 'getKeyValueEvent'
--lua to native
local LUA_TO_NATIVE = 'setKeyValueEvent'
local curGraphicQuality, recommendGraphicQuality = -1, nil
local function Native2Lua(_event, ...)
    if _event == MSG_NATIVE_TO_LUA then
        local args = ...
        local json = M.Kit.Util.LuaJson:decode(args[1])
        local test = M.Kit.Util.LuaJson:decode(json.eventData)
        print(test)
    end
end

local function Lua2Native(_param)
    if _param == 0 then
        local msg = {
            gameTag = GAME_TAG,
            eventKey = LUA_TO_NATIVE,
            eventData = {lua_start_menu = Game.GetGraphicQuality()}
        }
        local strMsg = M.Kit.Util.LuaJson:encode(msg)
        Game.EngineEvent:Fire(MSG_LUA_TO_NATIVE, strMsg)
    elseif _param == 1 then
        local msg = {
            gameTag = GAME_TAG,
            eventKey = LUA_TO_NATIVE,
            eventData = {lua_finish_menu = curGraphicQuality}
        }
        local strMsg = M.Kit.Util.LuaJson:encode(msg)
        Game.EngineEvent:Fire(MSG_LUA_TO_NATIVE, strMsg)
    end
end

local function LowQualityWarning(_cur)
    if _cur == 0 then
        M.Kit.Util.Net.Fire_C('LowQualityWarningEvent', localPlayer, false)
    elseif _cur == 1 then
        M.Kit.Util.Net.Fire_C('LowQualityWarningEvent', localPlayer, false)
    else
        M.Kit.Util.Net.Fire_C('LowQualityWarningEvent', localPlayer, true)
    end
end

--- 初始化
function Init()
    Game.ShowSystemBar(false)
    math.randomseed(os.time())
    local co =
        coroutine.create(
        function()
            GameSetting()
        end
    )
    coroutine.resume(co)

    local deferFun = function()
        InitGui()
        InitListener()
    end

    invoke(deferFun)
    Lua2Native(0)
end

function GameSetting()
    curGraphicQuality = Game.GetGraphicQuality()
    Game.SetGlobalGraphicQuality(Enum.GraphicQualityLevel.Auto)
    wait(0.1)
    recommendGraphicQuality = Game.GetGraphicQuality()
    Game.SetGlobalGraphicQuality(curGraphicQuality)
    LowQualityWarning(curGraphicQuality)
    coroutine.yield()
end

function GraphicReady()
    wait(0.1)
    gui.GraphicSetBtnTab[curGraphicQuality].BtnConfirmIc:SetActive(true)
    gui.GraphicSetBtnTab[curGraphicQuality].Color = Color(0, 0, 0, 255)
    gui.GraphicSetBtnTab[curGraphicQuality][string.gsub(gui.GraphicSetBtnTab[curGraphicQuality].Name, 'Btn', 'Text')].Color =
        Color(255, 255, 255, 255)

    gui.GraphicSetBtnTab[recommendGraphicQuality][
            string.gsub(gui.GraphicSetBtnTab[recommendGraphicQuality].Name, 'Btn', 'Text')
        ].AnchorsY = Vector2(0.7, 0.7)
    gui.GraphicSetBtnTab[recommendGraphicQuality][
        string.gsub(gui.GraphicSetBtnTab[recommendGraphicQuality].Name, 'Btn', 'TextRec')
    ]:SetActive(true)
end

-- 更新
local tt = 0
function Update(_, dt)
    tt = tt + dt
    if tt > 1 then
        if isOn and localPlayer:IsSpeaking() then
            gui.IsReallySpeaking.Value = true
        else
            gui.IsReallySpeaking.Value = false
        end

        if isNone then
            M.Kit.Util.Net.Fire_S('ConfirmNoticeEvent', not isNone)
        end

        tt = 0
    end
end

--- 节点申明
function InitGui()
    gui.MenuGui = world.MenuNode.Client.MenuGui
    for _, v in pairs(gui.MenuGui:GetDescendants()) do
        gui[v.Name] = v
    end

    gui.ImgBase.Offset = Vector2(0, 100)
    gui.ImgBase.Color = Color(255, 255, 255, 0)
    gui.DisplayBase:SetActive(false)
    gui.BtnBase:SetActive(false)
    gui.InputFieldIm.Tips = '<color=#dadada>' .. imText .. '</color>'

    gui.FunBtnTab = {gui.BtnGaming, gui.BtnFriList, gui.BtnSetting}
    gui.FunDisplayTab = {gui.ImgGaming, gui.ImgFriList, gui.ImgSetting}
    gui.PnlMenuTab = {gui.TweenMenuBg, gui.TweenImBubbleBg, gui.TweenVoiceBg}

    gui.ImgBase.Size = Vector2(824, -150)
    gui.BtnBase.Size = Vector2(132, 0)
    gui.DisplayBase.Size = Vector2(640, 0)

    local info = VoiceManager.GetPlayerAudioInfo(localPlayer.UserId)
    if info == nil then
        isOn = true
    else
        isOn = not info.MuteSelf
    end
    gui.ImgVoiceMask:SetActive(not isOn)
    SwitchLocalVoiceMicStates()
    M.Kit.Util.Net.Fire_S('MuteLocalEvent', localPlayer, isOn)
    M.Kit.Util.Net.Fire_C('ClientReadyEvent', localPlayer, true)
    isReady = true
end

--remote user voice settings
function RemoteUserPanelSetting()
    local panel = gui.RemoteListernerScroll
    local text = gui.RemoteListenerText

    panel.OnScroll:Connect(function(position,scrollDistance,deltaDistance,scrollSpeed)
        local v = math.floor(panel.ScrollScale)
        text.Text = v
        VoiceManager.SetPlayerVoiceVolume(mutedPlayerId,v)
    end)
end


function OnMicScrollVolume(volume)
    if volume == 0 then
        gui.LocalBtnMicImg.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microoff')
    else
        gui.LocalBtnMicImg.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microon')
    end
    lastLocalMicVolume = volume
end

function OnListenScrollVolume(volume)
   if volume == 0 then
        gui.LocalBtnListenerImg.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeroff')
    else
        gui.LocalBtnListenerImg.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeron')
    end
    lastLocalListenVolume = volume
end

function SetRemoteUserInfos()
    if mutedPlayerTab == nil then
        return
    end
    for pid, v in pairs(mutedPlayerTab) do
        local info = VoiceManager.GetPlayerAudioInfo(pid)
        if info == nil then return end
        v['isMuted'] = info.MuteOthers
        gui['ImgMic' .. v['num']]:SetActive(info.MuteOthers)
        M.Kit.Util.Net.Fire_C(
            'MuteSpecificPlayerEvent',
            localPlayer,
            pid,
            info.MuteOthers
        )
    end
end

function SetLocalUserInfos()
    local panelMic = gui.LocalMicScroll
    local textMic = gui.LocalMicText
    lastLocalMicVolume = VoiceManager.GetMicrophoneVolume()
    panelMic.ScrollScale = lastLocalMicVolume
    VoiceManager.SetMicrophoneVolume(lastLocalMicVolume)

    local panelL = gui.LocalListernerScroll
    local textL = gui.LocalListenerText
    lastLocalListenVolume = VoiceManager.GetAllVoiceVolume()
    panelL.ScrollScale = lastLocalListenVolume
    VoiceManager.SetAllVoiceVolume(lastLocalListenVolume)
    OnMicScrollVolume(lastLocalMicVolume)
    OnListenScrollVolume(lastLocalListenVolume)
end

--lcoal user voice settings
function LocalUserPanelSetting()
    local panelMic = gui.LocalMicScroll
    local textMic = gui.LocalMicText

    panelMic.OnScroll:Connect(function(position,scrollDistance,deltaDistance,scrollSpeed)
        local v =  math.floor(panelMic.ScrollScale)
        textMic.Text = v
        VoiceManager.SetMicrophoneVolume(v)
        OnMicScrollVolume(v)
    end)

    local panelL = gui.LocalListernerScroll
    local textL = gui.LocalListenerText
    panelL.OnScroll:Connect(function(position,scrollDistance,deltaDistance,scrollSpeed)
        local v = math.floor(panelL.ScrollScale)
        textL.Text = v
        VoiceManager.SetAllVoiceVolume(v)
        OnListenScrollVolume(v)
    end)
end

--- 事件绑定初始化
function InitListener()
    if Game.PlayHubEvent then
        Game.PlayHubEvent:Connect(Native2Lua)
    end
    -- 顶部三个按钮动画
    OpenAndClose()
    SwitchLocalVoice()
    InitLocalVolumeButton()
    SwitchLocalVoiceMicStates()
    InputBind()

    -- 左侧功能按钮的底板资源替换
    ResourceReplaceAni()

    SettingBind()
    QuitBind()
    GamingBind()

    DebugOnly()
    GraphicReady()
    RemoteUserPanelSetting()
    LocalUserPanelSetting()
end

function DebugOnly()
    local count, isShow = 0, false
    local function ShowTest()
        if isShow then
            isShow = false
        else
            isShow = true
        end
        Game.ShowSystemBar(isShow)
    end
    gui.BtnOldMenu.OnClick:Connect(
        function()
            count = count + 1
            if count > 5 then
                count = 0
                ShowTest()
            end
        end
    )
end

---开关节点控制器
---@param _bool 期望的布尔值
---@param _tarTab 目标表格
---@param _spNode 排除节点
function SwitchNodeCtr(_spNode, _tarTab, _bool)
    for _, v in pairs(_tarTab) do
        if v == _spNode then
            v:SetActive(not _bool)
        else
            v:SetActive(_bool)
        end
    end
end

function SwitchTextureCtr(_tar, _tab)
    for _, v in pairs(_tab) do
        if v ~= _tar then
            v:GetChild(tostring(v.Name) .. 'Icon').Texture =
                ResourceManager.GetTexture('Menu/MenuGui/svg_' .. resReplaceTab[string.gsub(v.Name, 'Btn', '')])
            v:GetChild(tostring(v.Name) .. 'Icon').Color = Color(0, 0, 0, 180)
        end
    end
end

function OpenAndClose()
    gui.BtnMenu.OnClick:Connect(
        function()
            isOpen = true
            gui.BtnBase.Size = Vector2(132, 0)
            gui.DisplayBase.Size = Vector2(640, 0)
            DisableCtr(isOpen)
            gui.BtnTouch.Size = Vector2(1, 1)
            gui.BtnTouch.AnchorsY = Vector2(0.001, 0.999)
            gui.BtnTouch.AnchorsX = Vector2(0.001, 0.999)
            gui.BtnTouch:SetActive(true)
            SetLocalUserInfos()
            SetRemoteUserInfos()
        end
    )

    gui.BtnClose.OnClick:Connect(
        function()
            isOpen = false
            DisableCtr(isOpen)
            gui.BtnTouch:SetActive(false)
        end
    )

    gui.IsReallySpeaking.OnValueChanged:Connect(
        function()
            if gui.IsReallySpeaking.Value then
                -- Animation
                gui.ImgVoiceMask.Offset = Vector2(0, -24)
                TweenAni(gui.TweenMask, {Offset = Vector2(0, 0)}, 1, Enum.EaseCurve.BounceInOut)
                gui.TweenMask.Loop = 0
            else
                gui.TweenMask:Complete()
            end
        end
    )
end

function SwitchLocalVoiceMicStates()
    if isOn then
        --gui.LocalBtnMicImg.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microon')
        gui.ImgVoice.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microon')
    else
        --gui.LocalBtnMicImg.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microoff')
        gui.ImgVoice.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microoff')
    end
end

function InitLocalVolumeButton()
    gui.LocalBtnListenerMute.OnClick:Connect(
        function()
            if isLocalListenVolume then
                isLocalListenVolume = false
                gui.LocalBtnListenerImg.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeroff')
                lastLocalListenVolume = VoiceManager.GetAllVoiceVolume()
                VoiceManager.SetAllVoiceVolume(0,false)
            else
                isLocalListenVolume = true
                gui.LocalBtnListenerImg.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeron')
                VoiceManager.SetAllVoiceVolume(lastLocalListenVolume,false)
            end
        end
    )

    gui.LocalBtnMicMute.OnClick:Connect(
          function()
            if isLocalMicVolume then
                isLocalMicVolume = false
                gui.LocalBtnMicImg.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microoff')
                lastLocalMicVolume = VoiceManager.GetMicrophoneVolume()
                VoiceManager.SetMicrophoneVolume(0,false)
            else
                isLocalMicVolume = true
                gui.LocalBtnMicImg.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microon')
                VoiceManager.SetMicrophoneVolume(lastLocalMicVolume,false)
            end
        end
    )
end

function SwitchLocalVoice()
    gui.BtnVoice.OnClick:Connect(
        function()
            if isOn then
                --gui.ImgVoice.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microoff')
                gui.ImgVoiceMask:SetActive(false)
                isOn = false
            else
                --gui.ImgVoice.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microon')
                gui.ImgVoiceMask:SetActive(true)
                isOn = true
            end
            M.Kit.Util.Net.Fire_S('MuteLocalEvent', localPlayer, isOn)
            SwitchLocalVoiceMicStates()
        end
    )
end

function InputBind()
    gui.BtnImBubble.OnClick:Connect(
        function()
            DisplayImgIm()
        end
    )

    gui.BtnArrow.OnClick:Connect(
        function()
            DisplayImgIm()
        end
    )

    gui.InputFieldIm.OnInputEnd:Connect(
        function(_text)
            PlayerInGameIm(_text)
        end
    )
end

function DisplayImgIm()
    if isDisplay then
        isDisplay = false
    else
        isDisplay = true
        gui.ImgRedDot:SetActive(false)
    end
    ImgImAni(isDisplay)
end

function ImgImAni(_isDisplay)
    local tarProTab, comFun
    if _isDisplay then
        gui.ImgIm:SetActive(_isDisplay)
        tarProTab = {Offset = Vector2(40, -121), Color = Color(0, 0, 0, 180)}
        gui.ImgImBubble.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_ic_comment1')
    else
        gui.InputFieldIm:SetActive(_isDisplay)
        gui.PnlIm:SetActive(_isDisplay)
        gui.BtnArrow:SetActive(_isDisplay)
        tarProTab = {Offset = Vector2(40, 0), Color = Color(0, 0, 0, 0)}
        gui.ImgImBubble.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_ic_comment')
    end
    comFun = function()
        gui.InputFieldIm:SetActive(_isDisplay)
        gui.PnlIm:SetActive(_isDisplay)
        gui.BtnArrow:SetActive(_isDisplay)
        gui.ImgIm:SetActive(_isDisplay)
    end

    TweenAni(gui.TweenIm, tarProTab, 0.4, Enum.EaseCurve.QuinticInOut, comFun)
end

function DisableCtr(_isOpen)
    ImgBaseAni(_isOpen)
    PnlMenuAni(not _isOpen)
    if _isOpen then
        ImgImAni(not _isOpen)
        isDisplay = not _isOpen
    else
        gui.ImgProfileBg:SetActive(_isOpen)
    end
    ResetImgBase()
end

function PnlMenuAni(_isOpen)
    if not _isOpen then
        gui.TweenMenuBg.Properties = {Offset = Vector2(0, 900)}
        gui.TweenImBubbleBg.Properties = {Offset = Vector2(98, 650)}
        gui.TweenVoiceBg.Properties = {Offset = Vector2(196, 200)}
    else
        gui.TweenMenuBg.Properties = {Offset = Vector2(0, 0)}
        gui.TweenImBubbleBg.Properties = {Offset = Vector2(98, 0)}
        gui.TweenVoiceBg.Properties = {Offset = voiceOff}
    end
    for _, v in pairs(gui.PnlMenuTab) do
        v:Flush()
        v.Duration = 0.4
        v.EaseCurve = Enum.EaseCurve.QuinticInOut
        v:Play()
    end
end

function ResetImgBase()
    gui.BtnGamingIcon.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_games1')
    gui.BtnGamingIcon.Color = Color(0, 0, 0, 255)
    gui.ImgShadow.Offset = gui.BtnGaming.Offset
    SwitchTextureCtr(gui.BtnGaming, gui.FunBtnTab)
    SwitchNodeCtr(gui.ImgGaming, gui.FunDisplayTab, false)
end

function ImgBaseAni(_isOpen)
    local tarProTab, comFun
    if _isOpen then
        gui.ImgBase:SetActive(_isOpen)
        tarProTab = {Offset = Vector2(80, 0), Color = Color(255, 255, 255, 242)}
    else
        tarProTab = {Offset = Vector2(0, 100), Color = Color(255, 255, 255, 0)}
        gui.BtnBase:SetActive(_isOpen)
        gui.DisplayBase:SetActive(_isOpen)
    end
    comFun = function()
        gui.ImgBase.Size = Vector2(824, -150)
        gui.BtnBase.Size = Vector2(132, 0)
        gui.DisplayBase.Size = Vector2(640, 0)
        for _, v in pairs(gui.DisplayBase:GetChildren()) do
            v.Size = Vector2(0, 0)
        end
        gui.DisplayBase:SetActive(_isOpen)
        gui.BtnBase:SetActive(_isOpen)
        gui.ImgBase:SetActive(_isOpen)
    end
    TweenAni(gui.TweenImgBase, tarProTab, 0.4, Enum.EaseCurve.QuinticInOut, comFun)
end

function TweenAni(_tarTween, _tarProTab, _tarDur, _tarEase, _comFun)
    _tarTween:Flush()
    _tarTween.Properties = _tarProTab
    _tarTween.Duration = _tarDur
    _tarTween.EaseCurve = _tarEase
    _tarTween:Play()
    if _comFun ~= nil then
        _tarTween.OnComplete:Connect(_comFun)
    end
end

function ResourceReplaceAni()
    for _, v in pairs(gui.FunBtnTab) do
        v.OnClick:Connect(
            function()
                local aniTween = gui.ImgShadow.aniTween
                aniTween:Flush()
                aniTween.Properties = {Offset = v.Offset}
                aniTween.Duration = 0.1
                aniTween.EaseCurve = Enum.EaseCurve.Linear
                aniTween:Play()
                aniTween.OnComplete:Connect(
                    function()
                        v:GetChild(tostring(v.Name) .. 'Icon').Texture =
                            ResourceManager.GetTexture(
                            'Menu/MenuGui/svg_' .. resReplaceTab[string.gsub(v.Name, 'Btn', '')] .. '1'
                        )
                        v:GetChild(tostring(v.Name) .. 'Icon').Color = Color(0, 0, 0, 255)
                        SwitchTextureCtr(v, gui.FunBtnTab)
                        ---显示对应功能面板
                        SwitchNodeCtr(gui[string.gsub(v.Name, 'Btn', 'Img')], gui.FunDisplayTab, false)
                    end
                )
            end
        )
    end
end

function ProfileBgFix(_playerId)
    local theGuy = world:GetPlayerByUserId(_playerId)
    if friTab[theGuy.Name] then
        gui.BtnProfileAdd:SetActive(false)
        --gui.BtnProfileMute.Offset = Vector2(-158, -384)
    else
        gui.BtnProfileAdd:SetActive(true)
        --gui.BtnProfileMute.Offset = Vector2(-50, -384)
    end

    if theGuy == localPlayer then
        gui.BtnProfileAdd:SetActive(false)
        --gui.BtnProfileMute.Offset = Vector2(-158, -384)
    end
end

function MuteAll(_isMuteAll)
    if mutedPlayerTab == nil then
        return
    end
    for _, v in pairs(mutedPlayerTab) do
        v['isMuted'] = _isMuteAll
        gui['ImgMic' .. v['num']]:SetActive(_isMuteAll)
        gui['ImgMic' .. v['num']].Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_ic_speakeroff1')
    end
end

function UpdateRemotePanel(playerId)
    local info = VoiceManager.GetPlayerAudioInfo(playerId)
    local panel = gui.RemoteListernerScroll
    local text = gui.RemoteListenerText
    panel.ScrollScale = info.RemoteVolume
    text.Text = info.RemoteVolume
end

function GamingBind()
    for i = 1, 12 do
        gui['BtnMic' .. i].OnClick:Connect(
            function()
                ProfileBgFix(gui['FigBg' .. i].PlayerInfo.Value)
                gui.ImgProfileHeadBg.Color = gui['ImgBg' .. i].Color
                gui.ImgProfileHeadBg.ImgProfileHead.Texture = gui['ImgHead' .. i].Texture
                gui.TextProfileName.Text = gui['TextName' .. i].Text
                gui.ImgProfileBg:SetActive(true)
                gui.BtnTouch:SetActive(true)
                mutedPlayerId = gui['FigBg' .. i].PlayerInfo.Value

                -- if local player adjust the menu position
                if mutedPlayerId == localPlayer.UserId then
                    gui.RemoteUserBg.Offset = Vector2(140,-384)
                else
                    gui.RemoteUserBg.Offset = Vector2(196,-384)
                    UpdateRemotePanel(mutedPlayerId)
                end
                
                if mutedPlayerTab[mutedPlayerId]['isMuted'] then
                    gui.ImgProfileMute.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeroff')
                else
                    gui.ImgProfileMute.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeron')
                end
                if isMuteAll then
                    gui.ImgProfileMute.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeroff')
                end
            end
        )
    end
    gui.BtnMuteAll.OnClick:Connect(
        function()
            if isMuteAll then
                isMuteAll = false
                gui.TextMuteAll.Color = MUTEALL_OFF_COLOR
                gui.ImgMuteAll.Color = MUTEALL_OFF_COLOR
                gui.ImgMuteAll.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeron')
            else
                isMuteAll = true
                gui.TextMuteAll.Color = MUTEALL_ON_COLOR
                gui.ImgMuteAll.Color = MUTEALL_ON_COLOR
                gui.ImgMuteAll.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeroff')
            end
            MuteAll(isMuteAll)
            gui.ImgProfileBg:SetActive(false)
            M.Kit.Util.Net.Fire_C('MuteAllEvent', localPlayer, isMuteAll)
        end
    )

    gui.BtnProfileCancel.OnClick:Connect(
        function()
            gui.ImgProfileBg:SetActive(false)
        end
    )

    gui.BtnProfileMute.OnClick:Connect(
        function()
            if mutedPlayerTab[mutedPlayerId]['isMuted'] then
                gui.ImgProfileMute.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeron')
                gui.ImgMuteAll.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeron')
                gui.ImgMuteAll.Color = MUTEALL_OFF_COLOR
                gui.TextMuteAll.Color = MUTEALL_OFF_COLOR
            else
                gui.ImgProfileMute.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_speakeroff')
            end
            mutedPlayerTab[mutedPlayerId]['isMuted'] = not mutedPlayerTab[mutedPlayerId]['isMuted']
            gui['ImgMic' .. mutedPlayerTab[mutedPlayerId]['num']]:SetActive(mutedPlayerTab[mutedPlayerId]['isMuted'])
            M.Kit.Util.Net.Fire_C(
                'MuteSpecificPlayerEvent',
                localPlayer,
                mutedPlayerId,
                mutedPlayerTab[mutedPlayerId]['isMuted']
            )
        end
    )

    local function showAdd()
        gui.ImgAddFb:SetActive(true)
        invoke(
            function()
                gui.ImgAddFb:SetActive(false)
            end,
            3
        )
    end

    gui.BtnProfileAdd.OnClick:Connect(
        function()
            M.Kit.Util.Net.Fire_C('AddFriendsEvent', localPlayer, mutedPlayerId)
            gui.ImgProfileAdd.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_addfriends1')
            showAdd()
        end
    )
end

function ClearChildren(_parent)
    local children = _parent:GetChildren()
    if #children == 0 then
        return
    end
    for _, v in pairs(children) do
        if v.OnClick then
            v.OnClick:Clear()
        end
        v:Destroy()
    end
end

local function SettingSwitch(_clickBtn)
    for _, v in pairs(gui.ImgSettingBg:GetChildren()) do
        if v == _clickBtn then
            v.BtnConfirmIc:SetActive(true)
            v.Color = Color(0, 0, 0, 255)
            gui[string.gsub(v.Name, 'Btn', 'Text')].Color = Color(255, 255, 255, 255)
        else
            v.BtnConfirmIc:SetActive(false)
            v.Color = Color(0, 0, 0, 0)
            gui[string.gsub(v.Name, 'Btn', 'Text')].Color = Color(0, 0, 0, 255)
        end
    end
end

local function SettingGraphics(v)
    for i, j in pairs(gui.GraphicSetBtnTab) do
        if j == v then
            Game.SetGlobalGraphicQuality(i)
            LowQualityWarning(i)
        end
    end
end

function SettingBind()
    gui.GraphicSetBtnTab = {}
    gui.GraphicSetBtnTab[3] = gui.BtnHigh
    gui.GraphicSetBtnTab[2] = gui.BtnMedium
    gui.GraphicSetBtnTab[1] = gui.BtnLow
    gui.GraphicSetBtnTab[0] = gui.BtnMin

    for _,v in pairs(gui.GraphicSetBtnTab) do
       v.OnClick:Connect(
            function()
                SettingSwitch(v)
                SettingGraphics(v)
            end)
    end
    --[[for _, v in pairs(gui.ImgSettingBg:GetChildren()) do
        v.OnClick:Connect(
            function()
                SettingSwitch(v)
                SettingGraphics(v)
            end
        )
    end--]]
end

function QuitBind()
    --todo 安卓返回键
    ---Quit的二级弹窗
    gui.BtnQuit.OnClick:Connect(
        function()
            gui.BtnTouch:SetActive(true)
            gui.ImgPopUps:SetActive(true)
            Lua2Native(1)
        end
    )

    gui.BtnTouch.OnClick:Connect(
        function()
            gui.BtnTouch:SetActive(false)
            gui.ImgPopUps:SetActive(false)
            for _, v in pairs(gui.PnlFriList:GetChildren()) do
                if v then
                    v.ImgFriMoreBg:SetActive(false)
                end
            end
            gui.ImgProfileBg:SetActive(false)
            isOpen = false
            DisableCtr(isOpen)
        end
    )

    gui.BtnCancel.OnClick:Connect(
        function()
            gui.BtnTouch:SetActive(false)
            gui.ImgPopUps:SetActive(false)
        end
    )

    gui.BtnOk.OnClick:Connect(
        function()
            Game.Quit()
        end
    )
end

function AdjustHeadPos(_tarTab, _playerTab)
    for k, v in pairs(_tarTab) do
        local callback = function(_profile)
            gui['ImgHead' .. k].Texture = _profile.HeadPortrait
            gui['ImgBg' .. k].Color = headColorTab[math.fmod(k, #headColorTab)]
        end

        PlayerHub.GetPlayerProfile(v.UserId, callback)
        gui['FigBg' .. k]:SetActive(true)
        gui['FigBg' .. k].PlayerInfo.Value = v.UserId
        gui['TextName' .. k].Text = v.Name

        mutedPlayerTab[v.UserId] = {
            isMuted = false,
            num = k
        }
    end
    gui['FigBg' .. (#_tarTab + 1)]:SetActive(false)
end

---游戏内IM
function PlayerInGameIm(_text)
    local textMessage = _text
    if #tostring(_text) == 0 then
        return
    end
    M.Kit.Util.Net.Fire_S('InGamingImEvent', localPlayer, textMessage)

    ---重置输入栏
    gui.InputFieldIm.Text = ''
end

--! Event handlers
function TranslateTextEventHandler(_text, _com)
    if not isReady then
        return
    end
    if _com == 'TextPlayNum' then
        playerText = _text
    elseif _com == 'TextFriList' then
        friText = _text
        gui.TextFriList.Text = friText .. ' ' .. '(' .. i .. ')'
    elseif _com == 'InputFieldIm' then
        imText = _text
        gui.InputFieldIm.Tips = '<color=#dadada>' .. imText .. '</color>'
    end
end

local function showInvite()
    gui.ImgInviteFb:SetActive(true)
    invoke(
        function()
            gui.ImgInviteFb:SetActive(false)
        end,
        3
    )
end

function GetFriendsListEventHandler(_list)
    if not isReady then
        return
    end
    i = 0
    for _ in pairs(_list) do
        i = i + 1
    end
    gui.TextFriList.Text = friText .. ' ' .. '(' .. i .. ')'
    ClearChildren(gui.PnlFriList)
    for k, v in pairs(_list) do
        gui[k] = world:CreateInstance('Menu/Archetype/FigFriInfo', k, gui.PnlFriList)
        M.Kit.Util.Net.Fire_C('CreateReadyEvent', localPlayer, gui[k], 0)

        gui[k].TextName.Text = v.Name
        local callback = function(_profile)
            gui[k].ImgBg.ImgHead.Texture = _profile.HeadPortrait
            gui[k].ImgBg.Color = headColorTab[math.random(1, 6)]
        end
        PlayerHub.GetPlayerProfile(k, callback)
        if v.Status == 'PLAYING' then
            gui[k].BtnFriMore:SetActive(true)
            gui[k].BtnFriInviteOut:SetActive(false)
            gui[k].ImgInGame:SetActive(true)
            gui[k].TextGameName.Text = 'Playing ' .. v.GameName
            gui[k].TextName.AnchorsY = Vector2(0.7, 0.7)
        else
            gui[k].BtnFriMore:SetActive(false)
            gui[k].BtnFriInviteOut:SetActive(true)
            gui[k].ImgInGame:SetActive(false)
            gui[k].TextName.AnchorsY = Vector2(0.5, 0.5)
        end
        gui[k].BtnFriMore.OnClick:Connect(
            function()
                if gui[k].ImgFriMoreBg.ActiveSelf then
                    gui[k].ImgFriMoreBg:SetActive(false)
                    gui.BtnTouch:SetActive(false)
                else
                    gui[k].ImgFriMoreBg:SetActive(true)
                    gui.BtnTouch:SetActive(true)
                end
            end
        )

        gui[k].BtnFriInviteOut.OnClick:Connect(
            function()
                M.Kit.Util.Net.Fire_C('InviteFriendToGameEvent', localPlayer, k)
                showInvite()
            end
        )

        gui[k].ImgFriMoreBg.BtnFriInvite.OnClick:Connect(
            function()
                M.Kit.Util.Net.Fire_C('InviteFriendToGameEvent', localPlayer, k)
                showInvite()
            end
        )

        gui[k].ImgFriMoreBg.BtnFriJoin.OnClick:Connect(
            function()
                M.Kit.Util.Net.Fire_C('JoinFriendGameEvent', localPlayer, k)
            end
        )
    end

    for k, v in pairs(gui.PnlFriList:GetChildren()) do
        v.Offset = Vector2(0, -130 * k + 130)
    end
end

function NoticeEventHandler(_playerTab, _playerList, _changedPlayer, _isAdded)
    playerList = _playerList
    Game.ShowSystemBar(false)
    friTab = Friends.GetFriendshipList()
    length = #_playerList

    if not isReady then
        return
    end
    isNone = false
    M.Kit.Util.Net.Fire_S('ConfirmNoticeEvent', not isNone)

    gui.TextPlayNum.Text = playerText .. ' (' .. length .. ')'
    if _isAdded then
        headImgCache = _playerList
        AdjustHeadPos(headImgCache, _playerTab)
    else
        for k, v in pairs(headImgCache) do
            if v == _changedPlayer then
                table.remove(headImgCache, k)
            end
        end
        AdjustHeadPos(headImgCache, _playerTab)
    end
end

---消息更新
local messageCache, length = '', 0
function NormalImEventHandler(_sender, _content)
    if not isReady then
        return
    end
    length = string.len((_sender.Name) .. _content)
    gui.TextImContent.Text =
        messageCache .. '\n' .. '<color=#dfdfdf>' .. '[' .. _sender.Name .. ']' .. '</color>' .. _content
    messageCache = gui.TextImContent.Text

    ---红点
    if not gui.ImgIm.ActiveSelf then
        gui.ImgRedDot:SetActive(true)
    end
end

function SomeoneInviteEventHandler(_invitePlayer, _roomId)
    if not isReady then
        return
    end

    if gui.ImgInviteBg then
        return
    end

    gui.ImgInviteBg = world:CreateInstance('Menu/Archetype/ImgInviteBg', 'ImgInviteBg' .. _invitePlayer.Name, gui.MenuGui)
    gui.ImgInviteBg.AnchorsY = Vector2(0, 9, 0.9)

    local callback = function(_profile)
        gui.ImgInviteBg.ImgProfileBg.ImgProfile.Texture = _profile.HeadPortrait
        gui.ImgInviteBg.ImgProfileBg.Color = headColorTab[math.random(1, 6)]
    end

    PlayerHub.GetPlayerProfile(_invitePlayer.UserId, callback)

    M.Kit.Util.Net.Fire_C('CreateReadyEvent', localPlayer, gui.ImgInviteBg, 1, _invitePlayer)

    gui.BtnInviteOk.OnClick:Connect(
        function()
            M.Kit.Util.Net.Fire_C('ConfirmInviteEvent', localPlayer, _invitePlayer, _roomId)
        end
    )
    local inviteWin = function()
        gui.ImgInviteBg:Destroy()
    end
    invoke(inviteWin, 5)
end

function CheckPnlMenu(_boolean, _gui)
    _gui:SetActive(_boolean)
    if not gui.ImgImBubbleBg.ActiveSelf then
        voiceOff = gui.ImgImBubbleBg.Offset
        gui.ImgVoiceBg.Offset = voiceOff
        isDisplay = false
        ImgImAni(isDisplay)
    else
        voiceOff = Vector2(196, 0)
        gui.ImgVoiceBg.Offset = voiceOff
    end
end

function MenuSwitchEventHandler(_type, _boolean)
    if gui.MenuGui == nil then
        return
    end
    if _type == 0 then
        gui.MenuGui:SetActive(_boolean)
    elseif _type == 1 then
        gui.PnlMenu:SetActive(_boolean)
    elseif _type == 2 then
        gui.ImgBase:SetActive(_boolean)
    end
end

function SwitchVoiceCtr()
    if not isOn then
        gui.ImgVoice.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microoff')
        gui.ImgVoiceMask:SetActive(false)
    else
        gui.ImgVoice.Texture = ResourceManager.GetTexture('Menu/MenuGui/svg_microon')
        gui.ImgVoiceMask:SetActive(true)
    end
    M.Kit.Util.Net.Fire_S('MuteLocalEvent', localPlayer, isOn)
end

function SwitchVoiceEventHandler(_type, _boolean)
    if _type == 0 then
        CheckPnlMenu(_boolean, gui.ImgVoiceBg)
    elseif _type == 1 then
        isOn = _boolean
        SwitchVoiceCtr()
    end
end

function SwitchInGameMessageEventHandler(_boolean)
    CheckPnlMenu(_boolean, gui.ImgImBubbleBg)
end

function DetectMenuDisplayStateEventHandler(_type)
    if _type == 0 then
        isDisplay = false
        ImgImAni(isDisplay)
    elseif _type == 1 then
        isOpen = false
        DisableCtr(isOpen)
    end
end

function AllowExitEventHandler(_boolean)
    if gui.ImgPopUps.ActiveSelf then
        gui.ImgPopUps:SetActive(false)
    end

    gui.BtnQuit.Clickable = _boolean
    
    if _boolean then
        gui.BtnQuit.Color = Color(255,58,58,255)
        gui.BtnQuit.HoverColor = Color(255,58,58,255)
        gui.BtnQuit.PressedColor = Color(255,58,58,255)
        gui.BtnQuit.DisabledColor = Color(255,58,58,255)
    else
        gui.BtnQuit.Color = Color(181, 181,181, 255)
        gui.BtnQuit.HoverColor = Color(181, 181,181, 255)
        gui.BtnQuit.PressedColor = Color(181, 181,181, 255)
        gui.BtnQuit.DisabledColor = Color(181, 181,181, 255)
    end
end

function SwitchVoiceBtnEventHandler(_bool)
    gui.BtnMuteAll:SetActive(_bool)
    gui.VoiceTextSetting:SetActive(_bool)
    for i = 1, 12 do
        gui['BtnMic' .. i]:SetActive(_bool)
        gui['ImgMic' .. i]:SetActive(_bool)
    end
end

--! Public methods
M.Init = Init
M.Update = Update
M.NoticeEventHandler = NoticeEventHandler
M.NormalImEventHandler = NormalImEventHandler
M.SomeoneInviteEventHandler = SomeoneInviteEventHandler
M.GetFriendsListEventHandler = GetFriendsListEventHandler
M.MenuSwitchEventHandler = MenuSwitchEventHandler
M.SwitchVoiceEventHandler = SwitchVoiceEventHandler
M.SwitchInGameMessageEventHandler = SwitchInGameMessageEventHandler
M.TranslateTextEventHandler = TranslateTextEventHandler
M.DetectMenuDisplayStateEventHandler = DetectMenuDisplayStateEventHandler
M.AllowExitEventHandler = AllowExitEventHandler
M.SwitchVoiceBtnEventHandler = SwitchVoiceBtnEventHandler

return M
