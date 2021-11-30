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
local PATH_SERVER = PATH_MENUKIT .. 'Framework/Server/'

local started = false

--- Initialize the Lua extension library
function InitLuaExt()
    require(PATH_LUA_EXT .. 'GlobalExt')
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
    _G.S = {}
end

--- Reference tool module
function RequireUtils()
    Menu.Util = {}

    -- Require Utils
    Menu.Util.Mod = require(PATH_UTIL .. 'Module')
    Menu.Util.Net = require(PATH_UTIL .. 'Net')
    Menu.Util.Event = require(PATH_UTIL .. 'Event')

    -- Init Utils

    --FIXME: for backward compatibility
    _G.ModuleUtil = Menu.Util.Mod
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

    -- Server
    Menu.Framework.Server = {}
    Menu.Framework.Server.Base = require(PATH_SERVER .. 'ServerBase')
    Menu.Framework.Server.Main = require(PATH_SERVER .. 'ServerMain')

    --FIXME:
    _G.ClientBase = Menu.Framework.Client.Base
    _G.ServerBase = Menu.Framework.Server.Base
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
    Menu.Manifest.Server = require(PATH_ROOT .. 'Server/Manifest')
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
    InitMenuKit()
end

--- Start client
function MenuKit.StartClient()
    MenuKit.Start()
    wait() --1 frame interval
    print('MenuKit.Framework.Client.Main:Run()')
    Menu.Framework.Client.Main:Run()
end

--- Start server
function MenuKit.StartServer()
    MenuKit.Start()
    wait() --间隔1帧
    print('MenuKit.Framework.Server.Main:Run()')
    Menu.Framework.Server.Main:Run()
end

return MenuKit