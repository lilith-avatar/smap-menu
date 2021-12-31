--- 换装系统
--- @module Outfit Manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

-- Local Cache
local world = world
local Debug = Debug

--* 模块
local M = {}

--开启Debug日志输出
Debug.EnableLog('ewi')

-- 脚本加载，并设置索引权限
local _ = require('Outfit/Script/Util/LuaExt')
local Xls = {
    MainType = require('Outfit/Script/Xls/XlsMainType'),
    SubType = require('Outfit/Script/Xls/XlsSubType'),
    GlobalText = require('Outfit/Script/Xls/XlsGlobalText')
}
local EventSys = require('Outfit/Script/Event/EventSys')
local Event = require('Outfit/Script/Event/Event')
local Engine = require('Outfit/Script/Scene/Engine')
local NpcCtrl = require('Outfit/Script/Scene/NpcCtrl')
local GuiAvatar = require('Outfit/Script/Gui/GuiAvatar')
local GuiOutfit = require('Outfit/Script/Gui/GuiOutfit')
local GuiTransition = require('Outfit/Script/Gui/GuiTransition')
local Cam = require('Outfit/Script/Scene/Cam')
local MenuHub = require('Outfit/Script/Scene/MenuHub')

-- 全局事件 --! Public
M.Event = Event
-- 全局枚举 --! Public
M.Enum = {
    TYPE = {
        -- 特殊的主类
        BODY = 'Body',
        -- 特殊的子类
        FACE = 'Face', -- 换脸
        FIGURE = 'Figure' -- 换身体
    }
}

-- 根节点
local root = world.MenuNode.Outfit
-- 初始化flag
local initialized = false

--- 初始化
function Init()
    InitEvent()
    InitSubModule()
    initialized = true
end

--- 初始化事件
function InitEvent()
    M.Event.Root = EventSys.Root
end

--- 初始化其他模块
function InitSubModule()
    -- 元表
    local mt = {
        __index = {
            Fire = Fire,
            AddEventListener = AddEventListener,
            Event = M.Event,
            Enum = M.Enum,
            Xls = Xls
        }
    }

    InitSubModuleAux(MenuHub, mt) -- Menu相关
    InitSubModuleAux(NpcCtrl, mt) -- 玩家控制器
    InitSubModuleAux(GuiOutfit, mt) -- GUI
    InitSubModuleAux(GuiAvatar, mt) -- GUI
    InitSubModuleAux(GuiTransition, mt) -- GUI
    InitSubModuleAux(Engine, mt) -- 引擎相关接口
    InitSubModuleAux(Cam, mt) -- 相机
end

-- 初始化辅助函数
function InitSubModuleAux(_module, _mt)
    setmetatable(_module, _mt)
    _module.Init(root)
end

--- 发出事件
function Fire(_event, ...)
    Debug.Assert(_event ~= nil, '[换装] 事件不能为空')
    EventSys.Dispatch(_event, ...)
end

--- 绑定事件Listener
function AddEventListener(_handler)
    EventSys.AddListener(_handler)
end

--- 打开换装系统
function Open()
    if not initialized then
        -- 初始化
        Init()
    end

    -- 发出打开事件
    Fire(M.Event.Enum.OPEN)
end

--- 关闭换装系统
function Close()
    if not initialized then
        -- 初始化
        Init()
    end

    -- 发出关闭事件
    Fire(M.Event.Enum.CLOSE_TRANSITION)
end

--- 开关换装系统
function Toggle()
    if IsOpen() then
        Close()
    else
        Open()
    end
end

--- 返回换装系统状态
function IsOpen()
    return GuiOutfit.IsOpen()
end

--! public methods
M.Init = Init
M.Open = Open
M.Close = Close
M.IsOpen = IsOpen
M.Toggle = Toggle
M.ToggleEvent = root.IsOpen.OnValueChanged

return M
