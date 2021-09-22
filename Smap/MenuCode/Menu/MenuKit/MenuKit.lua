--- Require each module used in the Global.Module directory in advance and define it as a global variable
--- @module Module Defines
--- @copyright Lilith Games, Avatar Team
--- @author ropztao

local MenuKit = {}

local PATH_ROOT = 'Menu/'
local PATH_MENUKIT = 'Menu/MenuKit/'
local PATH_LUA_EXT = PATH_MENUKIT .. 'LuaExt/'
local PATH_UTIL = PATH_MENUKIT .. 'Util/'
local PATH_FRAMEWORK = PATH_MENUKIT .. 'Framework/'
local PATH_CLIENT = PATH_MENUKIT .. 'Framework/Client/'

local started = false

--- Initialize the Lua extension library
function InitLuaExt()
    require(PATH_LUA_EXT .. 'GlobalExt')
    require(PATH_LUA_EXT .. 'StringExt')
    require(PATH_LUA_EXT .. 'TableExt')
    require(PATH_LUA_EXT .. 'MathExt')
    _G.Queue = require(PATH_LUA_EXT .. 'Queue')
    _G.Stack = require(PATH_LUA_EXT .. 'Stack')
end

--- Initialize MenuKit
function InitMenuKit()
    InitGlobal()
    RequireUtils()
    RequireFramework()
    RequireManifest()
    InitCommonModules()
end

--- Initialize Global
function InitGlobal()
    _G.Menu = {}
    _G.Data = {}
    _G.C = {}
end

--- Reference tool module
function RequireUtils()
    Menu.Util = {}

    -- Require Utils
    Menu.Util.Mod = require(PATH_UTIL .. 'Module')
    Menu.Util.LuaJson = require(PATH_UTIL .. 'LuaJson')
    Menu.Util.Net = require(PATH_UTIL .. 'Net')
    Menu.Util.Event = require(PATH_UTIL .. 'Event')

    -- Init Utils

    --FIXME: for backward compatibility
    _G.ModuleUtil = Menu.Util.Mod
    _G.JSON = Menu.Util.LuaJson
    _G.NetUtil = Menu.Util.Net
end

--- Reference framework
function RequireFramework()
    -- Framework
    Menu.Framework = {}

    -- Client
    Menu.Framework.Client = {}
    Menu.Framework.Client.Base = require(PATH_CLIENT .. 'ClientBase')
    Menu.Framework.Client.Main = require(PATH_CLIENT .. 'ClientMain')

    --FIXME:
    _G.ClientBase = Menu.Framework.Client.Base
    _G.Data.Global = {}
    _G.Data.Player = {}
    _G.Data.Players = {}
    _G.MetaData = Menu.Framework.MetaData
end

--- Reference Manifest
function RequireManifest()
    Menu.Manifest = {}
    Menu.Manifest.Common = require(PATH_ROOT .. 'Common/Manifest')
    Menu.Manifest.Client = require(PATH_ROOT .. 'Client/Manifest')
end

--- Load Common scripts
function InitCommonModules()
    Menu.Util.Mod.LoadManifest(_G, Menu.Manifest.Common, Menu.Manifest.Common.ROOT_PATH)
end

--- Start AvaKit
function MenuKit.Start()
    if started then
        return
    end
    print('[MenuKit] Start()')
    InitLuaExt()
    InitMenuKit()
end

--- Start client
function MenuKit.StartClient()
    MenuKit.Start()
    wait() --1 frame interval
    print('MenuKit.Framework.Client.Main:Run()')
    Menu.Framework.Client.Main:Run()
end

return MenuKit