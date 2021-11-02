---@module MenuDisplay
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  MenuDisplay,this = ModuleUtil.New('MenuDisplay', ClientBase)

local isOpen, easeCur = false, 4
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
    self:DataInit()
    self:GuiInit()
end

---数据变量初始化
function MenuDisplay:DataInit()
    self.rootCfg = Xls.RootTable
    self.btnCfg = Xls.BtnBaseTable
    self.btnOutCfg = Xls.BtnOutTable
    self.displayCfg = Xls.DisplayBaseTable
    self.settingCfg = Xls.SettingTable
end

---节点申明
function MenuDisplay:GuiInit()
    self.MenuGui = world:CreateInstance('MenuGui', 'MenuGui', world.Local)
    for k,v in pairs(self.MenuGui:GetDescendants()) do
        self[v.Name] = v
    end

    invoke(function()
        self:SizeCorrection()
    end,0.1)

    self.FunBtnTab = {self.BtnGaming, self.BtnSetting, self.BtnDressUp}
    self.FunDisplayTab = {self.ImgGaming, self.ImgSetting, self.ImgDressUp}
    self:ListenerInit()
end

---事件绑定初始化
function MenuDisplay:ListenerInit()
    self.BtnMenu.OnClick:Connect(function() 
        isOpen = true
        self.ImgBase:SetActive(isOpen)
        self.BtnMenu:SetActive(not isOpen)
        self.BtnVoice:SetActive(not isOpen)
    end)

    self.BtnClose.OnClick:Connect(function()
        isOpen = false
        self.ImgBase:SetActive(isOpen)
        self.BtnMenu:SetActive(not isOpen)
        self.BtnVoice:SetActive(not isOpen)
    end)

    ---左侧功能按钮的底板资源替换
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
    --todo quit的二级弹窗
    self.BtnQuit.OnClick:Connect(function()
        self.BtnTouch:SetActive(true)
        self.ImgPopUps:SetActive(true)
    end)

    self.BtnTouch.OnClick:Connect(function()
        self.BtnTouch:SetActive(false)
        self.ImgPopUps:SetActive(false)
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

---左边栏Btn大小和位置适配
---确保Btn的icon是正方形，两两间距为0个单位
---icon的纵向比不变，AnchorsX的Max值不变
function MenuDisplay:SizeCorrection()
    local firComponent = self.BtnBase:GetChildren()[1]
    local fixedAnchorsxMin = (self.BtnBase.FinalSize.x * (firComponent.AnchorsX.y - firComponent.AnchorsX.x)) / self.BtnBase.FinalSize.y
    for k,v in pairs(self.btnCfg) do
        if v.Id == -1 then
            self[k].AnchorsY = Vector2(0, fixedAnchorsxMin) 
        else
            self[k].AnchorsY = Vector2(1 - (v.Id + 1)*fixedAnchorsxMin, 1 - v.Id*fixedAnchorsxMin)    
        end
    end
end

return MenuDisplay