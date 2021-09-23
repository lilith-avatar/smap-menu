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
    --self.root:SetActive(false)
    self.ImgBase = world:CreateObject('UiImageObject', 'ImgBase', self.root)
    self.BtnBase = world:CreateObject('UiFigureObject', 'BtnBase', self.root)
    for m,n in pairs(self.rootCfg) do
        UiAssignment(m,n)
    end

    for k,v in pairs(self.btnCfg) do
        self[k] = world:CreateObject('UiButtonObject', tostring(v.Name), self.BtnBase)
        UiAssignment(k,v)
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
    local strV
    for k,v in pairs(self.BtnBase:GetChildren()) do
        v.AnchorsX = Vector2(fixedAnchorsxMin, v.AnchorsX.y)
        strV = tostring(v)
        self[strV..'Icon'] = world:CreateObject('UiImageObject', strV..'Icon', v)
        self[strV..'Icon'].AnchorsX = norSize
        self[strV..'Icon'].AnchorsY = norSize
        self[strV..'Icon'].Texture = ResourceManager.GetTexture('MenuRes/Icon_'..string.gsub(strV, 'Btn', ''))
    end
end

return CtrGui