---@module MenuDisplay
---@copyright Lilith Games, Avatar Team
---@author ropztao
local MenuDisplay, this = ModuleUtil.New('MenuDisplay', ClientBase)

local isOpen, isMuteAll, isOn, isDisplay, mutedPlayerId = false, false, true, false, nil
local headImgCache, length = {}, nil
local mutedPlayerTab, mutedInfo = {}, {}
local friTab = {}

---开关节点控制器
---@param _bool 期望的布尔值
---@param _tarTab 目标表格
---@param _spNode 排除节点
local function SwitchNodeCtr(_spNode, _tarTab, _bool)
    for k, v in pairs(_tarTab) do
        if v == _spNode then
            v:SetActive(not _bool)
        else
            v:SetActive(_bool)
        end
    end
end

local function SwitchTextureCtr(_tar, _tab, _tex)
    for k, v in pairs(_tab) do
        if v ~= _tar then
            v.Texture = ResourceManager.GetTexture('MenuRes/' .. _tex)
            v:GetChild(tostring(v.Name) .. 'Icon').Texture =
                ResourceManager.GetTexture('MenuRes/Btn_' .. string.gsub(v.Name, 'Btn', ''))
        end
    end
end

local function SwitchDisplayCtr(_tar, _tab, _bool)
    for k, v in pairs(_tab) do
        if v ~= _tar then
            v:SetActive(_bool)
        end
    end
end

---初始化
function MenuDisplay:Init()
    Game.ShowSystemBar(false)
    self:DataInit()
    self:GuiInit()
end

---数据变量初始化
function MenuDisplay:DataInit()
end

---节点申明
function MenuDisplay:GuiInit()
    self.MenuGui = world:CreateInstance('MenuGui', 'MenuGui', world.Local)
    for _, v in pairs(self.MenuGui:GetDescendants()) do
        self[v.Name] = v
    end

    self.FunBtnTab = {self.BtnGaming, self.BtnFriList, self.BtnSetting, self.BtnDressUp}
    self.FunDisplayTab = {self.ImgGaming, self.ImgFriList, self.ImgSetting, self.ImgDressUp}
    self:ListenerInit()
end

---事件绑定初始化
function MenuDisplay:ListenerInit()
    self:OpenAndClose()
    self:SwitchLocalVoice()
    self:InputBind()
    ---左侧功能按钮的底板资源替换
    self:ResourceReplaceAni()

    self:SettingBind()
    self:QuitBind()
    self:GamingBind()

    local test = false
    self.TestBtn.OnClick:Connect(
        function()
            if test then
                Game.ShowSystemBar(false)
                test = false
            else
                Game.ShowSystemBar(true)
                test = true
            end
        end
    )
end

function MenuDisplay:OpenAndClose()
    self.BtnMenu.OnClick:Connect(
        function()
            isOpen = true
            self:DisableCtr(isOpen)
        end
    )

    self.BtnClose.OnClick:Connect(
        function()
            isOpen = false
            self:DisableCtr(isOpen)
        end
    )
end

function MenuDisplay:SwitchLocalVoice()
    self.BtnVoice.OnClick:Connect(
        function()
            if isOn then
                self.IconVoice.Texture = ResourceManager.GetTexture('MenuRes/Btn_Voice_OFF')
                isOn = false
            else
                self.IconVoice.Texture = ResourceManager.GetTexture('MenuRes/Btn_Voice_ON')
                isOn = true
            end
            NetUtil.Fire_S('MuteLocalEvent', localPlayer.UserId, isOn)
        end
    )
end

function MenuDisplay:InputBind()
    self.BtnImBubble.OnClick:Connect(
        function()
            self:DisplayImgIm()
        end
    )

    self.BtnArrow.OnClick:Connect(
        function()
            self:DisplayImgIm()
        end
    )

    self.InputFieldIm.OnInputEnd:Connect(
        function(_text)
            self:PlayerInGameIm(_text)
        end
    )
end

function MenuDisplay:DisplayImgIm()
    if isDisplay then
        isDisplay = false
    else
        isDisplay = true
        self.ImgRedDot:SetActive(false)
    end
    self.ImgIm:SetActive(isDisplay)
end

function MenuDisplay:DisableCtr(isOpen)
    self.ImgBase:SetActive(isOpen)
    self.ImgMenu:SetActive(not isOpen)
    self.ImgVoice:SetActive(not isOpen)
    self.ImgImBubble:SetActive(not isOpen)
    if isOpen then
        self.ImgIm:SetActive(not isOpen)
    else
        self.ImgProfileBg:SetActive(isOpen)
    end
end

---左侧功能按钮的底板资源替换
function MenuDisplay:ResourceReplace()
    for k, v in pairs(self.FunBtnTab) do
        v.OnClick:Connect(
            function()
                if tostring(v.Texture) == 'Btn_Idle' then
                    ---按钮本身贴图替换
                    v.Texture = ResourceManager.GetTexture('MenuRes/Btn_Selected')
                    v:GetChild(tostring(v.Name) .. 'Icon').Texture =
                        ResourceManager.GetTexture('MenuRes/Btn_' .. string.gsub(v.Name, 'Btn', '') .. '_1')
                    SwitchTextureCtr(v, self.FunBtnTab, 'Btn_Idle')

                    ---显示对应功能面板
                    SwitchNodeCtr(self[string.gsub(v.Name, 'Btn', 'Img')], self.FunDisplayTab, false)
                end
            end
        )
    end
end

function MenuDisplay:ResourceReplaceAni()
    for k, v in pairs(self.FunBtnTab) do
        v.OnClick:Connect(
            function()
                local aniTween = world:CreateObject('TweenObject', 'aniTween', self.BtnAniShadow)
                aniTween.Properties = {AnchorsY = v.AnchorsY}
                aniTween.Duration = 0.1
                aniTween.EaseCurve = Enum.EaseCurve.Linear
                aniTween:Play()
                aniTween.OnComplete:Connect(
                    function()
                        v:GetChild(tostring(v.Name) .. 'Icon').Texture =
                            ResourceManager.GetTexture('MenuRes/Btn_' .. string.gsub(v.Name, 'Btn', '') .. '_1')
                        SwitchTextureCtr(v, self.FunBtnTab, 'Btn_Idle')
                        ---显示对应功能面板
                        SwitchNodeCtr(self[string.gsub(v.Name, 'Btn', 'Img')], self.FunDisplayTab, false)
                    end
                )
            end
        )
    end
end

function MenuDisplay:ProfileBgFix(_playerId)
    local theGuy = world:GetPlayerByUserId(_playerId)
    if friTab[theGuy.Name] then
        self.BtnProfileAdd:SetActive(false)
        self.BtnProfileMute.AnchorsX = Vector2(0.5, 0.5)
    else
        self.BtnProfileAdd:SetActive(true)
        self.BtnProfileMute.AnchorsX = Vector2(0.7, 0.7)
    end

    if theGuy == localPlayer then
        self.BtnProfileAdd:SetActive(false)
        self.BtnProfileMute.AnchorsX = Vector2(0.5, 0.5)
    end
end

local function MuteAll(_isMuteAll)
    for _, v in pairs(mutedPlayerTab) do
        v['isMuted'] = _isMuteAll
        MenuDisplay['ImgMic' .. v['num']]:SetActive(_isMuteAll)
        MenuDisplay['ImgMic' .. v['num']].Texture = ResourceManager.GetTexture('MenuRes/Btn_Gaming_MuteAll_OFF')
    end
end

function MenuDisplay:GamingBind()
    for i = 1, 12 do
        self['BtnMic' .. i].OnClick:Connect(
            function()
                self:ProfileBgFix(self['FigBg' .. i].PlayerInfo.Value)
                self.ImgProfileHead.Texture = self['ImgHead' .. i].Texture
                self.TextProfileName.Text = self['TextName' .. i].Text
                self.ImgProfileBg:SetActive(true)
                self.BtnTouch:SetActive(true)
                mutedPlayerId = self['FigBg' .. i].PlayerInfo.Value
                if mutedPlayerTab[mutedPlayerId]['isMuted'] then
                    self.BtnProfileMute.Texture = ResourceManager.GetTexture('MenuRes/Btn_ProfileMute1')
                else
                    self.BtnProfileMute.Texture = ResourceManager.GetTexture('MenuRes/Btn_ProfileMute')
                end
                if isMuteAll then
                    self.BtnProfileMute.Texture = ResourceManager.GetTexture('MenuRes/Btn_ProfileMute1')
                end
            end
        )
    end
    self.BtnMuteAll.OnClick:Connect(
        function()
            if isMuteAll then
                isMuteAll = false
                self.ImgMuteAll.Texture = ResourceManager.GetTexture('MenuRes/Btn_Gaming_MuteAll_ON')
                self.BtnMuteAll.TextColor = Color(38, 121, 217, 255)
            else
                isMuteAll = true
                self.ImgMuteAll.Texture = ResourceManager.GetTexture('MenuRes/Btn_Gaming_MuteAll_OFF')
                self.BtnMuteAll.TextColor = Color(222, 69, 119, 230)
            end
            MuteAll(isMuteAll)
            NetUtil.Fire_C('MuteAllEvent', localPlayer, isMuteAll)
        end
    )

    self.BtnProfileCancel.OnClick:Connect(
        function()
            self.ImgProfileBg:SetActive(false)
        end
    )

    self.BtnProfileMute.OnClick:Connect(
        function()
            if mutedPlayerTab[mutedPlayerId]['isMuted'] then
                self.BtnProfileMute.Texture = ResourceManager.GetTexture('MenuRes/Btn_ProfileMute')
                self['ImgMic' .. mutedPlayerTab[mutedPlayerId]['num']].Texture =
                    ResourceManager.GetTexture('MenuRes/Btn_Gaming_MuteAll_OFF')
                self.ImgMuteAll.Texture = ResourceManager.GetTexture('MenuRes/Btn_Gaming_MuteAll_ON')
                self.BtnMuteAll.TextColor = Color(38, 121, 217, 255)
            else
                self.BtnProfileMute.Texture = ResourceManager.GetTexture('MenuRes/Btn_ProfileMute1')
            end
            mutedPlayerTab[mutedPlayerId]['isMuted'] = not mutedPlayerTab[mutedPlayerId]['isMuted']
            self['ImgMic' .. mutedPlayerTab[mutedPlayerId]['num']]:SetActive(mutedPlayerTab[mutedPlayerId]['isMuted'])
            NetUtil.Fire_C(
                'MuteSpecificPlayerEvent',
                localPlayer,
                mutedPlayerId,
                mutedPlayerTab[mutedPlayerId]['isMuted']
            )
        end
    )

    self.BtnProfileAdd.OnClick:Connect(
        function()
            NetUtil.Fire_C('AddFriendsEvent', localPlayer, mutedPlayerId)
            self.BtnProfileAdd.Texture = ResourceManager.GetTexture('MenuRes/Btn_ProfileAdded')
        end
    )
end

local function ClearChildren(_parent)
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

function MenuDisplay:GetFriendsListEventHandler(_list)
    local i = 0
    for k, v in pairs(_list) do
        i = i + 1
    end
    self.TextFriList.Text = 'Friends(' .. i .. ')'
    ClearChildren(self.PnlFriList)
    for k, v in pairs(_list) do
        self[k] = world:CreateInstance('FigFriInfo', k, self.PnlFriList)
        self[k].TextName.Text = v.Name
        --todo
        self[k].ImgHead.Texture = nil
        if v.Status == 'PLAYING' then
            self[k].BtnFriMore:SetActive(true)
            self[k].BtnFriInviteOut:SetActive(false)
            self[k].ImgHead.ImgInGame:SetActive(true)
            self[k].TextGameName.Text = 'Playing' .. v.GameName
            self[k].TextName.AnchorsY = Vector2(0.7, 0.7)
        else
            self[k].BtnFriMore:SetActive(false)
            self[k].BtnFriInviteOut:SetActive(true)
            self[k].ImgHead.ImgInGame:SetActive(false)
            self[k].TextName.AnchorsY = Vector2(0.5, 0.5)
        end
        self[k].BtnFriMore.OnClick:Connect(
            function()
                if self[k].ImgFriMoreBg.ActiveSelf then
                    self[k].ImgFriMoreBg:SetActive(false)
                    self.BtnTouch:SetActive(false)
                else
                    self[k].ImgFriMoreBg:SetActive(true)
                    self.BtnTouch:SetActive(true)
                end
            end
        )

        self[k].BtnFriInviteOut.OnClick:Connect(
            function()
                NetUtil.Fire_C('InviteFriendToGameEvent', localPlayer, k)
            end
        )

        self[k].ImgFriMoreBg.BtnFriInvite.OnClick:Connect(
            function()
                NetUtil.Fire_C('InviteFriendToGameEvent', localPlayer, k)
            end
        )

        self[k].ImgFriMoreBg.BtnFriJoin.OnClick:Connect(
            function()
                --todo join
                NetUtil.Fire_C('InviteFriendToGameEvent', localPlayer, k)
            end
        )
    end

    for k, v in pairs(self.PnlFriList:GetChildren()) do
        v.AnchorsY = Vector2(1 - 0.15 * k, 1.15 - 0.15 * k)
    end
end

function MenuDisplay:SettingBind()
    self.GraphicSetTextTab = {self.TextHigh, self.TextMedium, self.TextLow}
    self.GraphicSetBtnTab = {}
    self.GraphicSetBtnTab[3] = self.BtnHigh
    self.GraphicSetBtnTab[2] = self.BtnMedium
    self.GraphicSetBtnTab[1] = self.BtnLow

    self.TextShut.OnEnter:Connect(
        function()
            self.BtnShut:SetActive(true)
            self.BtnOpen:SetActive(false)
            self.GraphicMask:SetActive(false)
        end
    )

    self.TextOpen.OnEnter:Connect(
        function()
            self.BtnShut:SetActive(false)
            self.BtnOpen:SetActive(true)
            self.GraphicMask:SetActive(true)
            Game.SetGraphicQuality(0)
        end
    )

    for k, v in pairs(self.GraphicSetTextTab) do
        v.OnEnter:Connect(
            function()
                SwitchNodeCtr(self[string.gsub(v.Name, 'Text', 'Btn')], self.GraphicSetBtnTab, false)
            end
        )
    end

    for i, j in pairs(self.GraphicSetBtnTab) do
        j.OnClick:Connect(
            function()
                Game.SetGraphicQuality(i)
            end
        )
    end
end

function MenuDisplay:QuitBind()
    ---Quit的二级弹窗
    self.BtnQuit.OnClick:Connect(
        function()
            self.BtnTouch:SetActive(true)
            self.ImgPopUps:SetActive(true)
        end
    )

    self.BtnTouch.OnClick:Connect(
        function()
            self.BtnTouch:SetActive(false)
            self.ImgPopUps:SetActive(false)
            for k, v in pairs(self.PnlFriList:GetChildren()) do
                if v then
                    v.ImgFriMoreBg:SetActive(false)
                end
            end
            self.ImgProfileBg:SetActive(false)
        end
    )

    self.BtnCancel.OnClick:Connect(
        function()
            self.BtnTouch:SetActive(false)
            self.ImgPopUps:SetActive(false)
        end
    )

    self.BtnOk.OnClick:Connect(
        function()
            Game.Quit()
        end
    )
end

function MenuDisplay:NoticeEventHandler(_playerTab, _playerList, _changedPlayer, _isAdded)
    friTab = Friends.GetFriendshipList()
    length = #_playerList
    self.TextPlayNum.Text = 'Player(' .. length .. ')'
    if _isAdded then
        headImgCache = _playerList
        self:AdjustHeadPos(headImgCache, _playerTab)
    else
        for k, v in pairs(headImgCache) do
            if v == _changedPlayer then
                table.remove(headImgCache, k)
            end
        end
        self:AdjustHeadPos(headImgCache, _playerTab)
    end
end

function MenuDisplay:AdjustHeadPos(_tarTab, _playerTab)
    for k, v in pairs(_tarTab) do
        self['ImgHead' .. k].Texture = _playerTab[v]
        self['FigBg' .. k]:SetActive(true)
        self['FigBg' .. k].PlayerInfo.Value = v.UserId
        self['TextName' .. k].Text = v.Name

        mutedPlayerTab[v.UserId] = {
            isMuted = false,
            num = k
        }
    end
    self['FigBg' .. (#_tarTab + 1)]:SetActive(false)
end

---游戏内IM
function MenuDisplay:PlayerInGameIm(_text)
    local textMessage = _text
    NetUtil.Fire_S('InGamingImEvent', localPlayer, textMessage)

    ---重置输入栏
    self.InputFieldIm.Text = ''
end

---消息更新
local messageCache, length = '', 0
function MenuDisplay:NormalImEventHandler(_sender, _content)
    length = string.len((_sender.Name) .. _content)
    if length < 20 then
        self.TextImContent.Text =
            messageCache .. '\n' .. '<color=#c8ffffff>' .. '[' .. _sender.Name .. ']' .. '</color>' .. _content
    else
        --todo 换行
        self.TextImContent.Text = messageCache .. '\n' .. '[' .. _sender.Name .. ']' .. _content
    end
    messageCache = self.TextImContent.Text

    ---红点
    if not self.ImgIm.ActiveSelf then
        self.ImgRedDot:SetActive(true)
    end
end

function MenuDisplay:SomeoneInviteEventHandler(_invitePlayer, _roomId)
    self.ImgInviteBg = world:CreateInstance('ImgInviteBg', 'ImgInviteBg' .. _invitePlayer.Name, self.MenuGui)

    self.BtnInviteOk.OnClick:Connect(
        function()
            NetUtil.Fire_C('ConfirmInviteEvent', localPlayer, _invitePlayer, _roomId)
        end
    )
end

return MenuDisplay
