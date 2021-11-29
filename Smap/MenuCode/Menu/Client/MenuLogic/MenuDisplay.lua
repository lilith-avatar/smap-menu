---@module MenuDisplay
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  MenuDisplay,this = ModuleUtil.New('MenuDisplay', ClientBase)

local isOpen, easeCur, isMute, isOn, isDisplay = false, 4, true, true, false
---开关节点控制器
---@param _bool 期望的布尔值
---@param _tarTab 目标表格
---@param _spNode 排除节点
local function SwitchNodeCtr(_spNode, _tarTab, _bool)
	for k,v in pairs(_tarTab) do
		if v == _spNode then
			v:SetActive(not _bool)
		else
			v:SetActive(_bool)
		end
    end
end

local function SwitchTextureCtr(_tar, _tab, _tex)
    for k,v in pairs(_tab) do
        if v ~= _tar then
            v.Texture = ResourceManager.GetTexture('MenuRes/'.._tex)
            v:GetChild(tostring(v.Name)..'Icon').Texture = ResourceManager.GetTexture('MenuRes/Btn_'..string.gsub(v.Name, 'Btn', ''))
        end
    end
end

local function SwitchDisplayCtr(_tar, _tab, _bool)
    for k,v in pairs(_tab) do
        if v ~= _tar then
            v:SetActive(_bool)
        end
    end
end

---初始化
function MenuDisplay:Init()
    Game.ShowSystemBar(true)
    self:DataInit()
    self:GuiInit()
end

---数据变量初始化
function MenuDisplay:DataInit()

end

---节点申明
function MenuDisplay:GuiInit()
    self.MenuGui = world:CreateInstance('MenuGui', 'MenuGui', world.Local)
    for k,v in pairs(self.MenuGui:GetDescendants()) do
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
    self:ResourceReplace()

    self:GamingBind()
    self:SettingBind()
    self:QuitBind()
end

function MenuDisplay:OpenAndClose()
    self.BtnMenu.OnClick:Connect(function() 
        isOpen = true
        self:DisableCtr(isOpen)
    end)

    self.BtnClose.OnClick:Connect(function()
        isOpen = false
        self:DisableCtr(isOpen)
    end)
end

function MenuDisplay:SwitchLocalVoice()
    self.BtnVoice.OnClick:Connect(function()
        if isOn then
            self.IconVoice.Texture = ResourceManager.GetTexture('MenuRes/Btn_Voice_OFF')
            isOn = false
        else
            self.IconVoice.Texture = ResourceManager.GetTexture('MenuRes/Btn_Voice_ON')
            isOn = true
        end
        NetUtil.Fire_C('MuteSpecificPlayerEvent', localPlayer, localPlayer, isOn)
    end)
end

function MenuDisplay:InputBind()
    self.BtnImBubble.OnClick:Connect(function()
        self:DisplayImgIm()
    end)

    self.BtnArrow.OnClick:Connect(function()
        self:DisplayImgIm()
    end)

    self.InputFieldIm.OnInputEnd:Connect(function(_text)
        self:PlayerInGameIm(_text)
    end)
end

function MenuDisplay:DisplayImgIm()
    if isDisplay then
        isDisplay = false
    else
        isDisplay = true
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
    end
end

---左侧功能按钮的底板资源替换
function MenuDisplay:ResourceReplace()
    for k,v in pairs(self.FunBtnTab) do
        v.OnClick:Connect(function()
            if tostring(v.Texture) == 'Btn_Idle' then
                ---按钮本身贴图替换
                v.Texture = ResourceManager.GetTexture('MenuRes/Btn_Selected')
                v:GetChild(tostring(v.Name)..'Icon').Texture = ResourceManager.GetTexture('MenuRes/Btn_'..string.gsub(v.Name, 'Btn', '')..'_1')
                SwitchTextureCtr(v, self.FunBtnTab, 'Btn_Idle')

                ---显示对应功能面板
                SwitchNodeCtr(self[string.gsub(v.Name, 'Btn', 'Img')], self.FunDisplayTab, false)
            end
        end)
    end
end

function MenuDisplay:GamingBind()
    self.BtnMuteAll.OnClick:Connect(function()
        if isMute then
            isMute = false         
            self.ImgMuteAll.Texture = ResourceManager.GetTexture('MenuRes/Btn_Gaming_MuteAll_OFF')
            self.BtnMuteAll.TextColor = Color(222,69,119,230)
        else
            isMute = true
            self.ImgMuteAll.Texture = ResourceManager.GetTexture('MenuRes/Btn_Gaming_MuteAll_ON')
            self.BtnMuteAll.TextColor = Color(38,121,217,255)
        end
    end)
end

function MenuDisplay:SettingBind()
    self.GraphicSetTextTab = {self.TextHigh,self.TextMedium,self.TextLow}
    self.GraphicSetBtnTab = {}
    self.GraphicSetBtnTab[1] = self.BtnHigh
    self.GraphicSetBtnTab[2] = self.BtnMedium
    self.GraphicSetBtnTab[3] = self.BtnLow

    self.TextShut.OnEnter:Connect(function()
        self.BtnShut:SetActive(true)
        self.BtnOpen:SetActive(false)
        self.GraphicMask:SetActive(false)
    end)

    self.TextOpen.OnEnter:Connect(function()
        self.BtnShut:SetActive(false)
        self.BtnOpen:SetActive(true)
        self.GraphicMask:SetActive(true)
        Game.SetFPSQuality(0)
    end)

    for k,v in pairs(self.GraphicSetTextTab) do
        v.OnEnter:Connect(function()
            SwitchNodeCtr(self[string.gsub(v.Name, 'Text', 'Btn')], self.GraphicSetBtnTab, false)
        end)
    end

    for i,j in pairs(self.GraphicSetBtnTab) do
        j.OnClick:Connect(function()
            Game.SetFPSQuality(i)
        end)
    end
end

function MenuDisplay:QuitBind()
    ---Quit的二级弹窗
    self.BtnQuit.OnClick:Connect(function()
        self.BtnTouch:SetActive(true)
        self.ImgPopUps:SetActive(true)
    end)

    self.BtnTouch.OnClick:Connect(function()
        self.BtnTouch:SetActive(false)
        self.ImgPopUps:SetActive(false)
    end)

    self.BtnCancel.OnClick:Connect(function()
        self.BtnTouch:SetActive(false)
        self.ImgPopUps:SetActive(false)
    end)

    self.BtnOk.OnClick:Connect(function()
        Game.Quit()
    end)
end

---动效
function MenuDisplay:AniEffect(_obj, _tab, _dur)
    local Tweener = Tween:TweenProperty(_obj, _tab, _dur, easeCur)
    Tweener:Play()
    Tweener.OnComplete:Connect(function()
        if not isOpen then
            
        end
    end)
end

---Update函数
function MenuDisplay:Update()

end

function MenuDisplay:ChangeTexture(_player, _tarObj)
    -- 获得玩家uid
    local uid = _player.UserId

    local Img_Head = MenuDisplay[_tarObj]

    -- GetPlayerProfile的回调函数
    local callback = function(_profile)
        Img_Head.Texture = _profile.HeadPortrait
    end

    -- 获取当前玩家的Profile信息
    PlayerHub.GetPlayerProfile(uid, callback)
end

local headImgCache, length = {}, nil
function MenuDisplay:NoticeEventHandler(_playerTab, _playerList, _changedPlayer, _isAdded)
    length = #_playerList
    self.TextPlayNum.Text = 'Player('..length..')'
    if _isAdded then
        headImgCache = _playerList
        self:AdjustHeadPos(headImgCache, _playerTab)   
    else
        for k,v in pairs(headImgCache) do
            if v == _changedPlayer then
                table.remove(headImgCache, k)
            end
        end
        self:AdjustHeadPos(headImgCache, _playerTab)
    end
end

function MenuDisplay:AdjustHeadPos(_tarTab, _playerTab)
    for k,v in pairs(_tarTab) do
        self['ImgHead'..k].Texture = _playerTab[v]
        self['FigBg'..k]:SetActive(true)
        self['FigBg'..k].PlayerInfo.Value = v.UserId
        self['TextName'..k].Text = v.Name
    end
    self['FigBg'..(#_tarTab + 1)]:SetActive(false)
end

---玩家状态存储更新
function MenuDisplay:PlayerActionChange()

end

---游戏内IM
function MenuDisplay:PlayerInGameIm(_text)
    local textMessage = _text
    NetUtil.Fire_S('InGamingImEvent', localPlayer, textMessage)

    ---重置输入栏
    self.InputFieldIm.Text = ''
end

---消息更新
function MenuDisplay:NormalImEventHandler(_content)



    ---收到消息时前端界面有三种状态
end

---收到游戏开发者的消息
function MenuDisplay:DeveloperBroadcastEventHandler(_content)

end

---创建消息函数
function MenuDisplay:CreateMessage()

end

return MenuDisplay