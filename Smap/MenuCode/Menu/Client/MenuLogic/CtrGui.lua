---@module CtrGui
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  CtrGui,this = ModuleUtil.New('CtrGui', ClientBase)

local norSize, isOpen, isChosen = Vector2(0.25,0.75), false, false
local durT, easeCur = 0.3, 4
local function UiAssignment(k,v)
    for i,j in pairs(v) do
        if i == 'Texture' then
            CtrGui[k][i] = ResourceManager.GetTexture(j)
        elseif i == 'Name' then
        else
            CtrGui[k][i] = j
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
        end
    end
end

---Interpolation
local function Lerp(a, b, f)
    return a + (b - a) * f
end

---初始化
function CtrGui:Init()
    self:DataInit()
    self:GuiInit()
end

---数据变量初始化
function CtrGui:DataInit()
    self.rootCfg = Xls.RootTable
    self.btnCfg = Xls.BtnBaseTable
end

---节点申明
function CtrGui:GuiInit()
    self.root = world:CreateObject('UiScreenUiObject', 'MenuGui', world.Local)

    ---menu开关
    self.BtnSwitch = world:CreateObject('UiButtonObject', 'BtnSwitch', self.root)
    -- self.BtnSwitch.Color = self.rootCfg.BtnBase.Color
    self.BtnSwitch.AnchorsY = Vector2(self.rootCfg.BtnBase.AnchorsY.y, self.rootCfg.ImgBase.AnchorsY.y)
    local fixedXmin = self.root.Size.y * (self.BtnSwitch.AnchorsY.y - self.BtnSwitch.AnchorsY.x) / self.root.Size.x
    self.BtnSwitch.AnchorsX = Vector2(fixedXmin ,self.rootCfg.BtnBase.AnchorsX.y)
    --todo 等编辑器bug修好再接着做这部分逻辑
    for i = 4,1,-1 do
        self['point'..i] = world:CreateObject('UiFigureObject', 'point'..1, self.BtnSwitch)
    end

    ---信息底板
    self.ImgBase = world:CreateObject('UiImageObject', 'ImgBase', self.root)
    ---按钮底板
    self.BtnBase = world:CreateObject('UiFigureObject', 'BtnBase', self.root)
    self.ImgBase:SetActive(false)
    self.BtnBase:SetActive(false)

    ---ui赋值
    for m,n in pairs(self.rootCfg) do
        UiAssignment(m,n)
    end

    ---按钮生成和图标设置
    for k,v in pairs(self.btnCfg) do
        self[k] = world:CreateObject('UiButtonObject', tostring(v.Name), self.BtnBase)
        UiAssignment(k,v)
        self[k..'Icon'] = world:CreateObject('UiImageObject', k..'Icon', self[k])
        self[k..'Icon'].RaycastTarget = false
        self[k..'Icon'].AnchorsX = norSize
        self[k..'Icon'].AnchorsY = norSize
        self[k..'Icon'].Texture = ResourceManager.GetTexture('MenuRes/Icon_'..string.gsub(k, 'Btn', ''))
    end
    
    invoke(function()
        self:SizeCorrection()
    end,0.1)

    self.imgWidth = self.rootCfg.ImgBase.AnchorsX.y - self.rootCfg.ImgBase.AnchorsX.x
    self.btnHeight = self.rootCfg.BtnBase.AnchorsY.y - self.rootCfg.BtnBase.AnchorsY.x
    self.ImgBase.AnchorsX = Vector2(self.BtnSwitch.AnchorsX.x, self.BtnSwitch.AnchorsX.x + self.imgWidth)
    self.BtnBase.AnchorsY = Vector2(self.BtnSwitch.AnchorsY.y - self.btnHeight, self.BtnSwitch.AnchorsY.y)
    self.ImgBase.Color = Color(255,255,255,0)
    self.FunBtnTab = {}
    for k,v in pairs(self.BtnBase:GetChildren()) do
        if v.Name ~= 'BtnQuit' then
            table.insert(self.FunBtnTab,v)
        end
    end

    self:ListenerInit()
end

---事件绑定初始化
function CtrGui:ListenerInit()
    self.BtnSwitch.OnClick:Connect(function() 
        if isOpen then     
            isOpen = false
        else 
            isOpen = true 
        end
        self:BaseStateRefresh(isOpen)
    end)

    ---左侧功能按钮的底板资源替换
    for k,v in pairs(self.FunBtnTab) do
        v.OnClick:Connect(function()
            if tostring(v.Texture) == 'Icon_Idle' then
                v.Texture = ResourceManager.GetTexture('MenuRes/Icon_Selected')
                SwitchTextureCtr(v, self.FunBtnTab, 'Icon_Idle')
            end
        end)
    end

    --todo quit的二级弹窗
end

---底板状态的更新
---涉及到水平和竖直锚点，透明度， 开关
function CtrGui:BaseStateRefresh()
    if isOpen then
        self.ImgBase:SetActive(isOpen)
        self.BtnBase:SetActive(isOpen)
        self:AniEffect(self.ImgBase, 
        {AnchorsX = Vector2(self.BtnSwitch.AnchorsX.y, self.BtnSwitch.AnchorsX.y + self.imgWidth),
         Color = Color(255, 255, 255, 255)}, durT)
        self:AniEffect(self.BtnBase, 
        {AnchorsY = Vector2(self.BtnSwitch.AnchorsY.x - self.btnHeight, self.BtnSwitch.AnchorsY.x)}, durT)
        for k,v in pairs(self.BtnBase:GetChildren()) do
            self:AniEffect(v, {Color = Color(255, 255, 255, 255)}, durT)
            self:AniEffect(v[v.Name..'Icon'], {Color = Color(255, 255, 255, 255)}, durT)
        end
    else
        self:AniEffect(self.ImgBase, 
        {AnchorsX = Vector2(self.BtnSwitch.AnchorsX.x, self.BtnSwitch.AnchorsX.x + self.imgWidth),
         Color = Color(255, 255, 255, 0)}, durT)
        self:AniEffect(self.BtnBase, 
        {AnchorsY = Vector2(self.BtnSwitch.AnchorsY.y - self.btnHeight, self.BtnSwitch.AnchorsY.y)}, durT)
        for k,v in pairs(self.BtnBase:GetChildren()) do
            self:AniEffect(v, {Color = Color(255, 255, 255, 0)}, durT)
            self:AniEffect(v[v.Name..'Icon'], {Color = Color(255, 255, 255, 0)}, durT)
        end
    end
end

---动效
function CtrGui:AniEffect(_obj, _tab, _dur)
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
function CtrGui:Update()

end

---左边栏Btn大小和位置适配
---确保Btn的icon是正方形，两两间距为0.3个单位
---icon的纵向比不变，AnchorsX的Max值不变
function CtrGui:SizeCorrection()
    local firComponent = self.BtnBase:GetChildren()[1]
    local fixedAnchorsxMin = 1- (self.BtnBase.FinalSize.y * (firComponent.AnchorsY.y - firComponent.AnchorsY.x)) / self.BtnBase.FinalSize.x
    for k,v in pairs(self.BtnBase:GetChildren()) do
        v.AnchorsX = Vector2(fixedAnchorsxMin, v.AnchorsX.y)       
    end
end

return CtrGui