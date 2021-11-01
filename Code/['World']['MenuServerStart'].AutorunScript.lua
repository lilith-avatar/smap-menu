--- 启动MenuKit：服务器
--- @module Menu: start client
--- @copyright Lilith Games, Avatar Team

Data = Data or {}
Data.Default = Data.Default or {}

-- 全局变量定义
Data.Default.Global = Data.Default.Global or {}

-- 玩家数据，初始化定义
Data.Default.Player = Data.Default.Player or {}

local MenuKit = MenuKit or require('Menu/MenuKit/MenuKit')
MenuKit.StartServer()