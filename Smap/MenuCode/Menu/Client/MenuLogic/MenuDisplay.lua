---@module MenuDisplay
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  MenuDisplay,this = ModuleUtil.New('MenuDisplay', ClientBase)

local isOpen, easeCur, isMute = false, 4, true
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

    self.FunBtnTab = {self.BtnGaming, self.BtnSetting, self.BtnDressUp}
    self.FunDisplayTab = {self.ImgGaming, self.ImgSetting, self.ImgDressUp}
    self:ListenerInit()
end

---事件绑定初始化
function MenuDisplay:ListenerInit()
    self:OpenAndClose()
    ---左侧功能按钮的底板资源替换
    self:ResourceReplace()

    self:GamingBind()
    self:SettingBind()
    self:QuitBind()
end

function MenuDisplay:OpenAndClose()
    self.BtnMenu.OnClick:Connect(function() 
        isOpen = true
        self.ImgBase:SetActive(isOpen)
        self.ImgMenu:SetActive(not isOpen)
        self.ImgVoice:SetActive(not isOpen)
    end)

    self.BtnClose.OnClick:Connect(function()
        isOpen = false
        self.ImgBase:SetActive(isOpen)
        self.ImgMenu:SetActive(not isOpen)
        self.ImgVoice:SetActive(not isOpen)
    end)
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
        Game.SetQualityLevel(0)
    end)

    for k,v in pairs(self.GraphicSetTextTab) do
        v.OnEnter:Connect(function()
            SwitchNodeCtr(self[string.gsub(v.Name, 'Text', 'Btn')], self.GraphicSetBtnTab, false)
        end)
    end

    for i,j in pairs(self.GraphicSetBtnTab) do
        j.OnClick:Connect(function()
            Game.SetQualityLevel(i)
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

---玩家表更新
function MenuDisplay:NoticeEventHandler(_playerTab)
    for i,j in pairs(_playerTab) do
        print(i,j)
        wait(1)
        self:ChangeTexture(j, self['ImgHead'..i])
    end
end

---玩家状态存储更新
function MenuDisplay:PlayerActionChange()

end

return MenuDisplay