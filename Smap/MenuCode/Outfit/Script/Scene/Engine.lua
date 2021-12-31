--- 换装、换体型系统引擎API调用
--- @module Costom Engine API
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

-- Local Cache
local localPlayer = localPlayer
local Stack = Stack
local stringfy, dump, clear = table.stringfy, table.dump, table.clear
local invoke, wait = invoke, wait
local Debug, AvatarManager = Debug, AvatarManager

--* 模块
local M = {}

-- 根节点（Init时候被赋值）
local root

-- 服装数据
local outfits = {}
-- 玩家上次保存时的服装IDs
local defaultIds = {}
-- 当前身上的服装IDs
local dressedIds = {}
-- MainType和SubType包含新服装的数量
local newTypes = {}

-- 行动栈（撤销栈）
local UndoStack = Stack:New() --* 可撤销栈
local RedoStack = Stack:New() --* 可重做栈

-- 全局引用
local avatar  -- 换装模特

-- 外观信息下载成功
local avatarDownloaded = false

-- 当前数据
local currItemList = {}
local currOutfitId

-- 常量
local MSG_SUCCEEDED = 'succeeded'
local MSG_FAILED = 'failed'

--! 玩家行为Action

local Action = {}

--- 行为栈：新建行为
-- @param _newIds 穿上的服装IDs
-- @param _undressIds 需要脱下的服装IDs
function Action:New(_newIds, _canTakeOff)
    local inst = {
        newIds = _newIds,
        oldIds = {},
        dodo = self.Dodo,
        redo = self.Redo,
        undo = self.Undo,
        canTakeOff = _canTakeOff
    }
    local mt = {
        __index = self,
        __tostring = function()
            return string.format('newIds = %s, oldIds = %s', stringfy(_newIds), stringfy(_undressIds))
        end
    }
    setmetatable(inst, mt)
    return inst
end

--- 行为栈：执行
function Action:Dodo()
    -- 换装：新衣服
    ChangeClothesAux(self.newIds, self.canTakeOff)

    -- 找到脱掉的服装IDs
    local getTakeOffClothesCallback = function(_newDressedIds)
        --- 返回当前玩家身上的服装插值，在换装后执行
        -- Debug.Log(string.format('==> [01]: %s', stringfy(dressedIds)))
        -- Debug.Log(string.format('==> [02]: %s', stringfy(_newDressedIds)))

        local oldIds = {}
        for _, v1 in pairs(dressedIds) do
            local exist = false
            for _, v2 in pairs(_newDressedIds) do
                if v1 == v2 then
                    exist = true
                    break
                end
            end
            if not exist then
                --* 找到脱掉的衣服
                table.insert(oldIds, v1)
            end
        end
        --* 这里赋值dressedIds
        dressedIds = _newDressedIds

        --* 需要针对套装去重
        -- https://stackoverflow.com/questions/20066835/lua-remove-duplicate-elements
        local hash = {}
        for _, v in ipairs(oldIds) do
            if (not hash[v]) then
                self.oldIds[#self.oldIds + 1] = v -- you could print here instead of saving to result table if you wanted
                hash[v] = true
            end
        end

        Debug.Log(string.format('[换装] 脱掉服装IDs, %s', stringfy(self.oldIds)))
    end

    -- 更新当前服装
    --* 传入一个新的{}作为newDressedIds，在回调里赋值dressedIds
    GetCurrClothesIds(avatar, {}, 0.02, getTakeOffClothesCallback)
    -- 更新当前ID
    invoke(GetOutfitCurrId, 0.02)
end

--- 行为栈：重做
function Action:Redo()
    -- 换装：新衣服
    ChangeClothesAux(self.newIds, self.canTakeOff)
    -- 更新当前服装
    GetCurrClothesIds(avatar, dressedIds, 0.02)
    -- 更新当前ID
    invoke(GetOutfitCurrId, 0.02)
end

--- 行为栈：撤销
function Action:Undo()
    -- 换装：旧衣服
    ChangeClothesAux(self.oldIds, self.canTakeOff)
    -- 更新当前服装
    GetCurrClothesIds(avatar, dressedIds, 0.02)
    -- 更新当前ID
    invoke(GetOutfitCurrId, 0.02)
end

--! 初始化

--- 初始化
function Init(_root)
    root = _root
    InitLocalVars()
    BindEvent()
end

--- 初始化本地变量
function InitLocalVars()
    avatar = root.Booth.Npc.NpcAvatar
    avatar:ResetToDefault()
end

--- 事件绑定
function BindEvent()
    M.AddEventListener(EventHandler)
end

--- 事件处理
function EventHandler(_event, ...)
    if _event == M.Event.Enum.OPEN then
        -- 读取玩家服装信息
        GetPlayerOwnedList()
        -- 读取玩家形象
        LoadAvatar()
        -- 清空行为栈
        UndoStack:Clear()
        RedoStack:Clear()
        -- 更新Action状态
        SyncActionStates()
    elseif _event == M.Event.Enum.CLOSE then
        -- 清空行为栈
        UndoStack:Clear()
        RedoStack:Clear()
        -- 保存玩家形象
        SaveAvatar()
    elseif _event == M.Event.Enum.UPDATE_CURR_TYPES then
        local args = {...}
        local mainType, subType = args[1], args[2]
        -- 更新Item列表
        UpdateItemList(subType)
        UpdateNewTypes()
    elseif _event == M.Event.Enum.CHANGE_CLOTHES then
        local args = {...}
        local id = args[1]
        local isNew = args[2]
        Debug.Assert(id ~= nil and id ~= '', '[换装] id为空')
        -- 换装
        Dodo({id}, true)
        -- 取消红点
        if isNew then
            ClearRedDot({id})
        end
    elseif _event == M.Event.Enum.CLEAR_DOT then
        local args = {...}
        local ids = args[1]
        ClearRedDot(ids)
    elseif _event == M.Event.Enum.ACTION.UNDO then
        Undo()
    elseif _event == M.Event.Enum.ACTION.REDO then
        Redo()
    elseif _event == M.Event.Enum.ACTION.RESTORE then
        Restore()
    end
end

--! 数据加载、保存

--- 读取玩家形象
function LoadAvatar()
    if not localPlayer.Avatar then
        Debug.LogWarning('localPlayer.Avatar 不存在!')
        return
    end
    -- 读取玩家形象回调
    local callback = function(_itemIds, _msg)
        Debug.Log(string.format('[换装] 下载服装资源, msg: %s', _msg))
        -- Debug.Log(string.format('[换装] 服装id列表: %s', dump(_itemIds)))

        if _msg == MSG_SUCCEEDED then
            --* 先清空玩家身上的服装，防止重复替换服装消失
            avatar:ResetToDefaultClothes()
            -- 将玩家身上的服装IDs拷贝在NPC身上
            ChangeClothesAux(_itemIds, false)

            -- 初始化玩家当前身上的服装IDs
            GetCurrClothesIds(avatar, defaultIds)
            GetCurrClothesIds(avatar, dressedIds)
            avatarDownloaded = true

            -- 把localPlayer的属性赋值给NPC
            avatar.BodyType = localPlayer.Avatar.BodyType
            avatar.FaceType = localPlayer.Avatar.FaceType
            avatar.SkinColor = localPlayer.Avatar.SkinColor
        else
            Debug.LogWarning(string.format('[换装] 下载服装资源, msg: %s', _msg))
        end

        --- 同步三个行为状态
        SyncActionStates()
    end

    AvatarManager.DownloadCurrentAvatarResource(callback)
end

--- 保存玩家形象
function SaveAvatar()
    if not localPlayer.Avatar then
        Debug.LogWarning('localPlayer.Avatar 不存在!')
        return
    end
    -- 保存玩家体型
    localPlayer.Avatar.BodyType = avatar.BodyType
    localPlayer.Avatar.FaceType = avatar.FaceType
    localPlayer.Avatar.SkinColor = avatar.SkinColor

    --- 保存玩家形象回调
    local callback = function(_msg)
        if _msg == MSG_SUCCEEDED then
            Debug.Log(string.format('[换装] Upload Current Exterior Callback, msg: %s', _msg))
        else
            Debug.LogWarning(string.format('[换装] 上传服装资源, msg: %s', _msg))
        end
    end

    -- 上传接口
    if avatarDownloaded then
        AvatarManager.UploadCurrentAvatarResource(avatar, callback)
    end
end

-- FIXME: --? 表格数据回调 Test only
function TableCallback(luaTable)
    Debug.Log(dump(luaTable))
end

--! 服装数据相关接口

--- 获取玩家当前服装列表
function GetPlayerOwnedList()
    Debug.Log('GetPlayerOwnedList()')

    --- 获取玩家当前服装列表回调
    local callback = function(_ownedItems)
        -- for k, v in ipairs(_ownedItems) do
        --     Debug.Log(string.format('[%02d] %s', k, dump(v)))
        -- end
        if _ownedItems ~= nil and _ownedItems ~= {} then
            outfits = {}
            for k, v in ipairs(_ownedItems) do
                -- 判断服装是否可用，性别是否相符
                outfits[v.itemId] = {
                    Id = v.itemId,
                    index = k, -- 用于排序
                    Gender = v.gender,
                    New = not v.viewed,
                    -- New = true,
                    MainType = string.sub(v.type, 1, 2),
                    SubType = v.type,
                    Enable = true,
                    Title = v.name,
                    Description = v.descriptionText,
                    Source = v.source,
                    Expiration = v.expiredTimestamp or -1
                    -- Expiration = math.random(os.time() - 1000000, os.time() + 2592000) --FIXME: --!TEST 测试一个随机90天的倒计时
                }
            end
        end

        M.Fire(M.Event.Enum.GOT_PLAYER_OWN_ITEMLIST)
    end

    AvatarManager.GetPlayerOwnedDressList(localPlayer.Avatar, 'all', callback)
end

--- 刷新更新服装列表
function UpdateItemList(_subType)
    currItemList = {}
    Debug.Assert(_subType ~= nil, '[换装] _subType为空')

    -- 根据SubType拿到服装列表
    for _, st in ipairs(_subType) do
        Debug.Assert(st ~= nil, '[换装] SubType为空')
        for _, cos in pairs(outfits) do
            if cos.SubType == st then
                table.insert(currItemList, cos)
            end
        end
    end

    -- 排序
    local compare = function(a, b)
        return a.index < b.index
    end
    table.sort(currItemList, compare)

    local callback = function()
        -- 触发GUI物品列表更新
        M.Fire(M.Event.Enum.REFRESH_GUI.ITEMLIST, currItemList)
    end
    GetOutfitCurrId(callback)
end

--- 更新有红点的MainType和SubType
function UpdateNewTypes()
    -- 找到有红点的标签
    newTypes = {}
    for _, cos in pairs(outfits) do
        if cos.New == true then
            newTypes[cos.MainType] = (newTypes[cos.MainType] or 0) + 1
            newTypes[cos.SubType] = (newTypes[cos.SubType] or 0) + 1
        end
    end

    -- 触发GUI更新
    M.Fire(M.Event.Enum.REFRESH_GUI.MENU, newTypes)
end

--- 得到当前的服装
function GetOutfitCurrId(_callback)
    currOutfitId = {}
    local findCurrId = function(_items)
        for _, v1 in pairs(currItemList) do
            for _, v2 in pairs(_items) do
                if v1.Id == v2 then
                    table.insert(currOutfitId, v2)
                end
            end
        end
        M.Fire(M.Event.Enum.GET_CURR_IDS, currOutfitId)
        if _callback and type(_callback) == 'function' then
            _callback()
        end
    end
    avatar:GetCurrentSuits(findCurrId)
end

--! 玩家行为相关接口

--- 取消红点
function ClearRedDot(_ids)
    Debug.Log(string.format('[换装] 清除红点 id = %s', table.stringfy(_ids)))
    for _, id in pairs(_ids) do
        AvatarManager.ClearRedPot(1, id)

        local cos = outfits[id]
        if cos.New then
            newTypes[cos.MainType] = newTypes[cos.MainType] - 1
            newTypes[cos.SubType] = newTypes[cos.SubType] - 1
            cos.New = false
        end
    end
    -- 触发GUI更新
    M.Fire(M.Event.Enum.REFRESH_GUI.MENU, newTypes)
end

--- 同步三个行为状态
function SyncActionStates()
    -- 检查三个状态
    local canRestore = not (table.concat(defaultIds) == table.concat(dressedIds))
    local canUndo = UndoStack:Size() > 0
    local canRedo = RedoStack:Size() > 0
    M.Fire(M.Event.Enum.ACTION.DONE, canRestore, canRedo, canUndo)
end

--- 做：换衣服
function Dodo(_ids, _canTakeOff)
    -- 创建玩家行为
    local action = Action:New(_ids, _canTakeOff)
    action:Dodo()

    -- 栈操作
    UndoStack:Push(action)
    RedoStack:Clear()
    -- GUI同步
    SyncActionStates()
end

--- 撤销：换衣服
function Undo()
    if not UndoStack:IsEmpty() then
        local action = UndoStack:Pop()
        action:Undo()
        RedoStack:Push(action)
    end
    -- GUI同步
    SyncActionStates()
end

--- 重做：换衣服
function Redo()
    if not RedoStack:IsEmpty() then
        local action = RedoStack:Pop()
        action:Redo()
        UndoStack:Push(action)
    end
    -- GUI同步
    SyncActionStates()
end

--- 恢复初始服装
function Restore()
    -- 创建默认服装列表的IDs
    local outfitIds = {}
    for _, id in ipairs(defaultIds) do
        table.insert(outfitIds, id)
    end
    --* 先清空玩家身上的服装，防止重复替换服装消失
    avatar:ResetToDefaultClothes()
    wait()
    -- 执行正常换装
    Dodo(outfitIds, false)
end

--- 换衣服的引擎接口
function ChangeClothesAux(_ids, _canTakeOff)
    -- Debug.Log(string.format('[换装] 更新服装IDs, %s', stringfy(_ids)))
    for _, id in ipairs(_ids) do
        avatar:ChangeClothes(id, _canTakeOff)
    end
end

--- 返回当前玩家身上的服装IDs
function GetCurrClothesIds(_avatar, _outItems, _delay, _cb)
    if _delay and _delay > 0 then
        wait(_delay)
    end
    -- 回调函数
    local callback = function(_items)
        -- Debug.Log(stringfy(_items))
        -- 删除原有的数据
        clear(_outItems)
        -- 添加新的数据
        for _, v in pairs(_items) do
            table.insert(_outItems, v)
        end

        -- 执行传入的回调函数
        if _cb ~= nil then
            _cb(_outItems)
        end
    end

    -- 调用引擎接口
    _avatar:GetCurrentSuits(callback)
end

--! public method
M.Init = Init

return M
