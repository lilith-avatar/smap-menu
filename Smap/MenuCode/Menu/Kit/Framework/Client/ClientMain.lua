--- 游戏客户端主逻辑
--- @module Game Manager, Client-side
--- @copyright Lilith Games, Menutar Team
--- @author Yuancheng Zhang，ropztao

-- Local Cache
local world, wait = world, wait
local Debug, Timer = Debug, Timer

--* 模块
local M = {}

-- 已经初始化，正在运行
local initialized, running = false, false

-- 含有InitDefault(),Init(),Update()的模块列表
local list = {}
local initDefaultList, initList, updateList = {}, {}, {}

-- 客户端事件
local events = {}

--- 初始化
function InitClient()
    if initialized then
        return
    end
    Debug.Log('[MenuKit][Client] InitClient()')
    RequireClientModules()
    SetKitRef()
    SetOtherModuleRef()
    InitClientCustomEvents()
    GenInitAndUpdateList()
    RunInitDefault()
    InitOtherModules()
    initialized = true
end

--- 加载客户端模块
function RequireClientModules()
    --* 临时开放 _G.C, 用于require其他lua模块
    _G.C = {}
    _G.C.Base = M.Kit.Framework.Client.Base
    _G.C.ModuleUtil = M.Kit.Util.Mod
    Debug.Log('[MenuKit][Client] RequireClientModules()')
    events = M.Kit.Manifest.Client.Events
    M.Kit.Util.Mod.LoadManifest(_G.C, M.Kit.Manifest.Client, M.Kit.Manifest.Client.ROOT_PATH, list)
    --* 关闭 _G.C
    _G.C = nil
end

--- 模块对MenuKit的引用
function SetKitRef()
    for _, mod in pairs(list) do
        mod.Kit = M.Kit
    end
end

--- 设置跨模块引用
function SetOtherModuleRef()
    for _, mod in pairs(list) do
        mod.Other = {}
        for _, modOther in pairs(list) do
            if modOther ~= mod then
                mod.Other[modOther.name] = modOther
            end
        end
    end
end

--- 初始化客户端的CustomEvent
function InitClientCustomEvents()
    if world.MenuNode.C_Event == nil then
        world:CreateObject('FolderObject', 'C_Event', world.MenuNode)
    end

    -- 生成CustomEvent节点
    for _, evt in pairs(events) do
        if world.MenuNode.C_Event[evt] == nil then
            world:CreateObject('CustomEvent', evt, world.MenuNode.C_Event)
        end
    end
end

--- 生成需要Init和Update的模块列表
function GenInitAndUpdateList()
    -- Debug.Log(table.dump(list))
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
    Debug.Log('[MenuKit][Client] StartUpdate()')
    assert(not running, '[MenuKit][Client] StartUpdate() 正在运行')
    running = true

    local dt  -- delta time 每帧时间
    local tt = 0 -- total time 游戏总时间
    local now = Timer.GetTimeMillisecond --时间函数缓存
    local prev, curr = now() / 1000 -- two timestamps

    while (running and wait()) do
        curr = now() / 1000
        dt = curr - prev
        tt = tt + dt
        prev = curr
        UpdateClient(dt, tt)
    end
end

--- Update函数
-- @param dt delta time 每帧时间
function UpdateClient(_dt, _tt)
    for _, m in ipairs(updateList) do
        m:Update(_dt, _tt)
    end
end

--- 运行客户端
function Run()
    Debug.Log('[MenuKit][Client] Run()')
    InitClient()
    StartUpdate()
end

--- 停止Update
function Stop()
    Debug.Log('[MenuKit][Client] Stop()')
    running = false
end

--! Public methods
M.Run = Run
M.Stop = Stop
return M
