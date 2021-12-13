--- 游戏服务器主逻辑
--- @module Game Server, Server-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, ropztao

-- Local Cache
local world = world
local Debug = Debug

--* 模块
local M = {}
--- 已经初始化，正在运行
local initialized, running = false, false

--- 模块列表: 含有InitDefault(), Init(), Update()
local list = {}
local initDefaultList, initList, updateList = {}, {}, {}

--- 确定Server存在
local exist = false

--- 初始化
function InitServer()
    if initialized then
        return
    end
    Debug.Log('[MenuKit][Server] InitServer()')
    RequireServerModules()
    InitServerCustomEvents()
    GenInitAndUpdateList()
    RunInitDefault()
    InitOtherModules()
    initialized = true
end

function RequireServerModules()
    Debug.Log('[MenuKit][Server] RequireServerModules()')
    _G.S.Events = M.Kit.Manifest.Server.Events
    M.Kit.Util.Mod.LoadManifest(_G.S, M.Kit.Manifest.Server, M.Kit.Manifest.Server.ROOT_PATH, list)
end

--- 初始化服务器的CustomEvent
function InitServerCustomEvents()
    Debug.Log('[MenuKit][Server] InitServerCustomEvents()')
    if world.MenuNode.S_Event == nil then
        world:CreateObject('FolderObject', 'S_Event', world.MenuNode)
    end

    for _, evt in pairs(S.Events) do
        if world.MenuNode.S_Event[evt] == nil then
            world:CreateObject('CustomEvent', evt, world.MenuNode.S_Event)
        end
    end
end

--- 生成需要Init和Update的模块列表
function GenInitAndUpdateList()
    -- TODO: 改成在Ava.Config中配置
    M.Kit.Util.Mod.GetModuleListWithFunc(list, 'InitDefault', initDefaultList)
    M.Kit.Util.Mod.GetModuleListWithFunc(list, 'Init', initList)
    M.Kit.Util.Mod.GetModuleListWithFunc(list, 'Update', updateList)
end

--- 执行默认的Init方法
function RunInitDefault()
    for _, m in ipairs(initDefaultList) do
        m:InitDefault(m)
    end
end

--- 初始化包含Init()方法的模块
function InitOtherModules()
    for _, m in ipairs(initList) do
        m:Init()
    end
end

--- 开始Update
function StartUpdate()
    Debug.Log('[Server] StartUpdate()')
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

--- 运行服务器
function Run()
    Debug.Log('[MenuKit][Server] Run()')
    InitServer()
    invoke(StartUpdate)
    exist = true
end

--- 停止Update
function Stop()
    Debug.Log('[MenuKit][Server] Stop()')
    running = false
end

--! Public
M.Run = Run
M.Stop = Stop

return M
