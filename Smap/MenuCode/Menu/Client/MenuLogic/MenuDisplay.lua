---@module MenuDisplay
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  MenuDisplay,this = ModuleUtil.New('MenuDisplay', ClientBase)

local norSize, isOpen, isChosen = Vector2(0.25,0.75), false, false
local durT, easeCur = 0.3, 4
local function UiAssignment(k,v)
    for i,j in pairs(v) do
        if i == 'Texture' then
            MenuDisplay[k][i] = ResourceManager.GetTexture(j)
        elseif i == 'Name' then
        elseif i == 'Id' then
        else
            MenuDisplay[k][i] = j
        end
    end
end

local function TextAssignment(k,v)
    for i,j in pairs(v) do
        if i == 'Texture' then
            MenuDisplay[k][i] = ResourceManager.GetTexture(j)
        elseif i == 'Name' then
        elseif i == 'Id' then
        else
            MenuDisplay[k][i] = j
        end
    end
end

---开关节点控制器
---@param _bool 期望的布尔值
---@param _tarTab 目标表格
---@param _spNode 排除节点
local function SwitchNodeCtr(_bool, _tarTab, _spNode)
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

local function ShaBi(_tar)
    _tar.Size = Vector2(1,0)
    _tar.Size = Vector2(0,0)
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
    ---创建Menu根节点
    self.MenuGui = world:CreateObject('UiScreenUiObject', 'MenuGui', world.Local)

    ---创建第一层按钮
    self.BtnMenu = world:CreateObject('UiButtonObject', 'BtnMenu', self.MenuGui)
    self.BtnVoice = world:CreateObject('UiButtonObject', 'BtnVoice', self.MenuGui)
    for k,v in pairs(self.btnOutCfg) do
        UiAssignment(k,v)
    end

    ---信息底板
    self.ImgBase = world:CreateObject('UiImageObject', 'ImgBase', self.MenuGui)
    ShaBi(self.ImgBase)
    ---按钮底板
    self.BtnBase = world:CreateObject('UiFigureObject', 'BtnBase', self.ImgBase)
    ShaBi(self.BtnBase)
    self.ImgBase:SetActive(false)
    ---分割线
    self.SplitLine = world:CreateObject('UiFigureObject', 'SplitLine', self.ImgBase)
    ---功能底板
    self.DisplayBase = world:CreateObject('UiFigureObject', 'DisplayBase', self.ImgBase)
    ---ui赋值
    for m,n in pairs(self.rootCfg) do
        UiAssignment(m,n)
    end

    ---功能面板生成
    for k,v in pairs(self.displayCfg) do
        self[k] = world:CreateObject('UiFigureObject', tostring(v.Name), self.DisplayBase)
        UiAssignment(k,v)
    end

    ---按钮生成和图标设置
    for k,v in pairs(self.btnCfg) do
        self[k] = world:CreateObject('UiButtonObject', tostring(v.Name), self.BtnBase)
        UiAssignment(k,v)
        self[k..'Icon'] = world:CreateObject('UiImageObject', k..'Icon', self[k])
        self[k..'Icon'].RaycastTarget = false
        --todo fix size
        self[k..'Icon'].Size = Vector2(90,90)
        if k ~= 'BtnGaming' then 
            self[k..'Icon'].Texture = ResourceManager.GetTexture('MenuRes/Btn_'..string.gsub(k, 'Btn', ''))
        else
            self[k..'Icon'].Texture = ResourceManager.GetTexture('MenuRes/Btn_'..string.gsub(k, 'Btn', '')..'_1')
        end
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
                v.Texture = ResourceManager.GetTexture('MenuRes/Btn_Selected')
                v:GetChild(tostring(v.Name)..'Icon').Texture = ResourceManager.GetTexture('MenuRes/Btn_'..string.gsub(v.Name, 'Btn', '')..'_1')
                SwitchTextureCtr(v, self.FunBtnTab, 'Btn_Idle')
            end
        end)
    end
    --todo quit的二级弹窗
end

---底板状态的更新
---涉及到水平和竖直锚点，透明度， 开关
function MenuDisplay:BaseStateRefresh()

end

---动效
function MenuDisplay:AniEffect(_obj, _tab, _dur)
    local Tweener = Tween:TweenProperty(_obj, _tab, _dur, easeCur)
    Tweener:Play()
    Tweener.OnComplete:Connect(function()
        if not isOpen then
            self.ImgBase:SetActive(isOpen)
            self.BtnBase:SetActive(isOpen)
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

---setting界面
function MenuDisplay:LoadSettingDisplay()
    for k,v in pairs(self.settingCfg) do
        self[k] = world:CreateObject(v.ClassName, k, self[v.ParentName])
    end
end


return MenuDisplay