---@module CtrGui
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  CtrGui,this = ModuleUtil.New('CtrGui', ClientBase)

---初始化
function CtrGui:Init()
    self:DataInit()
    self:GuiInit()
    self:ListenerInit()
end

---数据变量初始化
function CtrGui:DataInit()
    local congfig = Xls.BtnBaseTable
end

---节点申明
function CtrGui:GuiInit()
    self.root = world:CreateObject('UiScreenUiObject', 'MenuGui', world.Local)
    self.imgRoot = world:CreateObject('UiImageObject', 'ImgBase', self.root)
    self.btnRoot = world:CreateObject('UiFigureObject', 'BtnBase', self.root)
end

---事件绑定初始化
function CtrGui:ListenerInit()

end

---Update函数
function CtrGui:Update()

end

---左边栏Btn大小和位置适配
---确保Btn的icon是正方形，两两间距为0.3个单位
function CtrGui:SizeAdapt()
    for k,v in pairs(self.btnRoot:GetChildren()) do
        
    end
end

return CtrGui