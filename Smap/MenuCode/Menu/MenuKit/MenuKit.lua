--- Require each module used in the Global.Module directory in advance and define it as a global variable
--- @module Module Defines
--- @copyright Lilith Games, Avatar Team

local MenuKit = {}

local PATH_ROOT = 'Menu/'
local PATH_MENUKIT = 'Menu/MenuKit'
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
    Menu.Util.Time = require(PATH_UTIL .. 'Time')

    -- Init Utils
    Menu.Util.Time.Init()

    --FIXME: for backward compatibility
    _G.ModuleUtil = Menu.Util.Mod
    _G.JSON = Menu.Util.LuaJson
    _G.NetUtil = Menu.Util.Net
end

--- Reference framework
function RequireFramework()
    -- Framework
    Menu.Framework = {}
    Menu.Framework.MetaData = require(PATH_FRAMEWORK .. 'MetaData')

    -- Client
    Menu.Framework.Client = {}
    Menu.Framework.Client.Base = require(PATH_CLIENT .. 'ClientBase')
    Menu.Framework.Client.DataSync = require(PATH_CLIENT .. 'ClientDataSync')
    Menu.Framework.Client.Heartbeat = require(PATH_CLIENT .. 'ClientHeartbeat')
    Menu.Framework.Client.Main = require(PATH_CLIENT .. 'ClientMain')

    --FIXME:
    _G.ClientBase = Menu.Framework.Client.Base
    _G.Data.Global = {}
    _G.Data.Player = {}
    _G.Data.Players = {}
    _G.MetaData = Menu.Framework.MetaData
end

return MenuKit