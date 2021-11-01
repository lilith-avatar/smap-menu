--- 游戏服务器主逻辑
--- @module Game Server, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Server = {}

--- 缓存全局变量
local Menu = Menu

--- 已经初始化，正在运行
local initialized, running = false, false

--- 模块列表: 含有InitDefault(), Init(), Update()
local list = {}
local initDefaultList, initList, updateList = {}, {}, {}

--! Public
--- 确定Server存在
Server.Exist = false

--- 运行服务器
function Server:Run()
    print('[MenuKit][Server] Run()')
    InitServer()
    invoke(StartUpdate)
    Server.Exist = true
end

--- 停止Update
function Server:Stop()
    print('[MenuKit][Server] Stop()')
    running = false
    Heartbeat.Stop()
end

--! Private

--- 初始化
function InitServer()
    if initialized then
        return
    end
    print('[MenuKit][Server] InitServer()')
    RequireServerModules()
    InitRandomSeed()
    InitServerCustomEvents()
    GenInitAndUpdateList()
    RunInitDefault()
    InitOtherModules()
    initialized = true
end

function RequireServerModules()
    print('[MenuKit][Server] RequireServerModules()')
    _G.S.Events = Menu.Manifest.Server.Events
    Menu.Util.Mod.LoadManifest(_G.S, Menu.Manifest.Server, Menu.Manifest.Server.ROOT_PATH, list)
end

--- 初始化服务器的CustomEvent
function InitServerCustomEvents()
    print('[MenuKit][Server] InitServerCustomEvents()')
    if world.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world)
    end

    for _, evt in pairs(S.Events) do
        if world.S_Event[evt] == nil then
            world:CreateObject('CustomEvent', evt, world.S_Event)
        end
    end
end

--- 生成需要Init和Update的模块列表
function GenInitAndUpdateList()
    -- TODO: 改成在Ava.Config中配置
    Menu.Util.Mod.GetModuleListWithFunc(list, 'InitDefault', initDefaultList)
    Menu.Util.Mod.GetModuleListWithFunc(list, 'Init', initList)
    Menu.Util.Mod.GetModuleListWithFunc(list, 'Update', updateList)
end

--- 执行默认的Init方法
function RunInitDefault()
    for _, m in ipairs(initDefaultList) do
        m:InitDefault(m)
    end
end

--- 初始化服务器随机种子
function InitRandomSeed()
    math.randomseed(os.time())
end

--- 初始化包含Init()方法的模块
function InitOtherModules()
    for _, m in ipairs(initList) do
        m:Init()
    end
end

--- 开始Update
function StartUpdate()
    print('[Server] StartUpdate()')
    assert(not running, '[MenuKit][Server] StartUpdate() 正在运行')

    running = true

    local dt = 0 -- delta time 每帧时间
    local tt = 0 -- total time 游戏总时间
    local now = Timer.GetTimeMillisecond --时间函数缓存
    local prev, curr = now() / 1000, nil -- two timestamps

    while (running and wait()) do
        curr = now() / 1000
        dt = curr - prev
        tt = tt + dt
        prev = curr
        UpdateServer(dt, tt)
    end
end

--- Update函数
--- @param dt delta time 每帧时间
function UpdateServer(_dt, _tt)
    for _, m in ipairs(updateList) do
        m:Update(_dt, _tt)
    end
end

return Server
