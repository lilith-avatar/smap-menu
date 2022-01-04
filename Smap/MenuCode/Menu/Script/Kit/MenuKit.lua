--- Require each module used in the Global.Module directory in advance and define it as a global variable
--- @module Module Defines
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Cache
local wait = wait
local Debug = Debug

--开启Debug日志输出
Debug.EnableLog('ewi')

--* 模块
local M = {}

--* 常量
local PATH_ROOT = 'Menu/Script/'
local PATH_MENUKIT = 'Menu/Script/Kit/'
local PATH_UTIL = PATH_MENUKIT .. 'Util/'
local PATH_LUA_EXT = PATH_MENUKIT .. 'Util/LuaExt'
local PATH_CLIENT = PATH_MENUKIT .. 'Framework/Client/'
local PATH_SERVER = PATH_MENUKIT .. 'Framework/Server/'

--* 本地变量
local started = false
local Kit = {} -- 用于给其他模块引用相关工具

--- Initialize MenuKit
function InitMenuKit()
    RequireUtils()
    RequireFramework()
    RequireManifest()
end

--- Reference tool module
function RequireUtils()
    Kit.Util = {}

    -- Require Utils
    require(PATH_LUA_EXT)
    Kit.Util.Mod = require(PATH_UTIL .. 'Module')
    Kit.Util.LuaJson = require(PATH_UTIL .. 'LuaJson')
    Kit.Util.Net = require(PATH_UTIL .. 'Net')
    Kit.Util.Event = require(PATH_UTIL .. 'Event')
end

--- Reference framework
function RequireFramework()
    -- Framework
    Kit.Framework = {}

    -- Client
    Kit.Framework.Client = {}
    Kit.Framework.Client.Base = require(PATH_CLIENT .. 'ClientBase')
    Kit.Framework.Client.Main = require(PATH_CLIENT .. 'ClientMain')
    Kit.Framework.Client.Base.Kit = Kit
    Kit.Framework.Client.Main.Kit = Kit

    -- Server
    Kit.Framework.Server = {}
    Kit.Framework.Server.Base = require(PATH_SERVER .. 'ServerBase')
    Kit.Framework.Server.Main = require(PATH_SERVER .. 'ServerMain')
    Kit.Framework.Server.Base.Kit = Kit
    Kit.Framework.Server.Main.Kit = Kit
end

--- Reference Manifest
function RequireManifest()
    Kit.Manifest = {}
    Kit.Manifest.Client = require(PATH_ROOT .. 'Client/Manifest')
    Kit.Manifest.Server = require(PATH_ROOT .. 'Server/Manifest')
end

--- Start AvaKit
function Start()
    if started then
        return
    end
    Debug.Log('[MenuKit] Start()')
    InitMenuKit()
end

--- Start client
function StartClient()
    Start()
    wait() --1 frame interval
    Debug.Log('MenuKit.Framework.Client.Main:Run()')
    Kit.Framework.Client.Main:Run()
end

--- Start server
function StartServer()
    Start()
    wait() --间隔1帧
    Debug.Log('MenuKit.Framework.Server.Main:Run()')
    Kit.Framework.Server.Main:Run()
end

--! Public methods

M.StartClient = StartClient
M.StartServer = StartServer

return M
