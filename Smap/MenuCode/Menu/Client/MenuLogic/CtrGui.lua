---@module CtrGui
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  CtrGui,this = ModuleUtil.New('CtrGui', ClientBase)

local norSize = Vector2(0.25,0.75)
local function UiAssignment(k,v)
    for i,j in pairs(v) do
        if i == 'Texture' then
            CtrGui[k][i] = ResourceManager.GetTexture(j)
        elseif i == 'Texture2' then
        elseif i == 'Name' then
        else
            CtrGui[k][i] = j
        end
    end
end

---初始化
function CtrGui:Init()
    self:DataInit()
    self:GuiInit()
    self:ListenerInit()
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
    self.BtnSwitch = world:CreateObject('UiImageObject', 'BtnSwitch', self.root)
    for i = 4,1,-1 do
        self['point'..1] = world:CreateObject('UiFigureObject', 'point'..1, self.BtnSwitch)
    end
    self.BtnSwitch.Color = self.rootCfg.BtnBase.Color
    self.BtnSwitch.AnchorsY = Vector2(self.rootCfg.BtnBase.AnchorsY.y, self.rootCfg.ImgBase.AnchorsY.y)
    local fixedXmin = self.root.Size.y * (self.BtnSwitch.AnchorsY.y - self.BtnSwitch.AnchorsY.x) / self.root.Size.x
    self.BtnSwitch.AnchorsX = Vector2(fixedXmin ,self.rootCfg.BtnBase.AnchorsX.y)


    self.ImgBase = world:CreateObject('UiImageObject', 'ImgBase', self.root)
    self.BtnBase = world:CreateObject('UiFigureObject', 'BtnBase', self.root)
    self.ImgBase:SetActive(false)
    self.BtnBase:SetActive(false)
    for m,n in pairs(self.rootCfg) do
        UiAssignment(m,n)
    end

    for k,v in pairs(self.btnCfg) do
        self[k] = world:CreateObject('UiButtonObject', tostring(v.Name), self.BtnBase)
        UiAssignment(k,v)
        self[k..'Icon'] = world:CreateObject('UiImageObject', k..'Icon', self[k])
        self[k..'Icon'].AnchorsX = norSize
        self[k..'Icon'].AnchorsY = norSize
        self[k..'Icon'].Texture = ResourceManager.GetTexture('MenuRes/Icon_'..string.gsub(k, 'Btn', ''))
    end
    
    invoke(function()
        self:SizeCorrection()
    end,0.1)
end

---事件绑定初始化
function CtrGui:ListenerInit()

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