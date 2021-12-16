--- 换装系统
--- @module Outfit Manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

local M = {}

--开启Debug日志输出
Debug.EnableLog('ewi')

-- 脚本加载，并设置索引权限
local _ = require('Outfit/Script/Util/LuaExt')
local Xls = {
    MainType = require('Outfit/Script/Xls/XlsMainType'),
    SubType = require('Outfit/Script/Xls/XlsSubType'),
    GlobalText = require('Outfit/Script/Xls/XlsGlobalText'),
    I18N = require('Outfit/Script/Xls/XlsI18N')
}
M.Event = require('Outfit/Script/Event')
local I18N = require('Outfit/Script/Util/I18N')
local Engine = require('Outfit/Script/Scene/Engine')
local PlayerCtrl = require('Outfit/Script/Scene/PlayerCtrl')
local GuiAvatar = require('Outfit/Script/Gui/GuiAvatar')
local GuiOutfit = require('Outfit/Script/Gui/GuiOutfit')
local GuiTransition = require('Outfit/Script/Gui/GuiTransition')
local Cam = require('Outfit/Script/Scene/Cam')

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
    -- 创建事件节点
    if root.Events == nil then
        local eventsNode = world:CreateObject('FolderObject', 'Events', root)
        M.Event.Root = world:CreateObject('CustomEvent', 'Outfit', eventsNode)
    end
end

--- 初始化其他模块
function InitSubModule()
    -- 元表
    local mt = {
        __index = {
            Fire = Fire,
            Event = M.Event,
            Enum = M.Enum,
            Xls = Xls
        }
    }

    InitSubModuleAux(I18N, mt) -- 本地化
    TranslateXls() -- 翻译本地化Xls
    InitSubModuleAux(GuiOutfit, mt) -- GUI
    InitSubModuleAux(GuiAvatar, mt) -- GUI
    InitSubModuleAux(GuiTransition, mt) -- GUI
    InitSubModuleAux(Engine, mt) -- 引擎相关接口
    InitSubModuleAux(PlayerCtrl, mt) -- 玩家控制器
    InitSubModuleAux(Cam, mt) -- 相机
end

-- 初始化辅助函数
function InitSubModuleAux(_module, _mt)
    setmetatable(_module, _mt)
    _module.Init(root)
end

--- 翻译本地化Xls
function TranslateXls()
    -- 需要本地化的表格
    I18N.Translate(Xls.SubType)
    I18N.Translate(Xls.GlobalText)
end

--- 发出事件
function Fire(_event, ...)
    Debug.Assert(_event ~= nil, '[换装] 事件不能为空')
    M.Event.Root:Fire(_event, ...)
end

--- 打开换装系统
function Open()
    if not initialized then
        -- 初始化
        Init()
    end

    -- 发出打开事件
    Fire(M.Event.Enum.OPEN, M.ShowPos)
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
M.ShowPos = nil

return M
