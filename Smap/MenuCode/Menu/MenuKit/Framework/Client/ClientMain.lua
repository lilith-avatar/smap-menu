--- 游戏客户端主逻辑
--- @module Game Manager, Client-side
--- @copyright Lilith Games, Menutar Team
--- @author Yuancheng Zhang
local Client = {}

-- 缓存全局变量
local Menu = Menu

-- 已经初始化，正在运行
local initialized, running = false, false

-- 含有InitDefault(),Init(),Update()的模块列表
local list = {}
local initDefaultList, initList, updateList = {}, {}, {}

--! Public

--- 运行客户端
function Client:Run()
    print('[MenuKit][Client] Run()')
    InitClient()
    StartUpdate()
end

--- 停止Update
function Client:Stop()
    print('[MenuKit][Client] Stop()')
    running = false
end

--! Private

--- 初始化
function InitClient()
    if initialized then
        return
    end
    print('[MenuKit][Client] InitClient()')
    RequireClientModules()
    InitRandomSeed()
    InitClientCustomEvents()
    GenInitAndUpdateList()
    RunInitDefault()
    InitOtherModules()
    initialized = true
end

--- 加载客户端模块
function RequireClientModules()
    print('[MenuKit][Client] RequireClientModules()')
    _G.C.Events = Menu.Manifest.Client.Events
    Menu.Util.Mod.LoadManifest(_G.C, Menu.Manifest.Client, Menu.Manifest.Client.ROOT_PATH, list)
end

--- 初始化客户端的CustomEvent
function InitClientCustomEvents()
    if localPlayer.C_Event == nil then
        world:CreateObject('FolderObject', 'C_Event', localPlayer)
    end

    -- 生成CustomEvent节点
    for _, evt in pairs(C.Events) do
        if localPlayer.C_Event[evt] == nil then
            world:CreateObject('CustomEvent', evt, localPlayer.C_Event)
        end
    end
end

--- 生成需要Init和Update的模块列表
function GenInitAndUpdateList()
    -- print(table.dump(list))
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

--- 初始化客户端随机种子
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
    print('[MenuKit][Client] StartUpdate()')
    assert(not running, '[MenuKit][Client] StartUpdate() 正在运行')
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

return Client
