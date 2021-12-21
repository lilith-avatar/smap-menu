--- 换装系统引擎API调用
--- @module Outfit Engine API
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

-- Local Cache
local localPlayer = localPlayer
local Stack = Stack
local stringfy, dump, clear = table.stringfy, table.dump, table.clear
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

-- 行动栈
local UndoStack = Stack:New() --* 可撤销栈
local RedoStack = Stack:New() --* 可重做栈

-- 全局引用
local avatar  -- 换装模特
local gender  -- 玩家性别

-- 外观信息下载成功
local avatarDownloaded = false

-- 当前数据
local currId

-- 常量
local MSG_SUCCEEDED = 'succeeded'
local MSG_FAILED = 'failed'

--! 玩家行为Action

local Action = {}

--- 行为栈：新建行为
-- @param _dressIds 穿上的服装IDs
-- @param _undressIds 需要脱下的服装IDs
function Action:New(_dressIds)
    local inst = {
        dressIds = _dressIds,
        undressIds = {},
        dodo = self.Dodo,
        redo = self.Redo,
        undo = self.Undo
    }
    local mt = {
        __index = self,
        __tostring = function()
            return string.format('dressIds = %s, undressIds = %s', stringfy(_dressIds), stringfy(_undressIds))
        end
    }
    setmetatable(inst, mt)
    return inst
end

--- 行为栈：执行
function Action:Dodo()
    -- 换装：新衣服
    ChangeClothesAux(self.dressIds)

    -- 找到脱掉的服装IDs
    local getTakeOffClothesCallback = function(_newDressedIds)
        --- 返回当前玩家身上的服装插值，在换装后执行
        -- Debug.Log(string.format('==> [01]: %s', stringfy(dressedIds)))
        -- Debug.Log(string.format('==> [02]: %s', stringfy(_newDressedIds)))
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
                table.insert(self.undressIds, v1)
            end
        end

        --* 这里赋值dressedIds
        dressedIds = _newDressedIds

        Debug.Log(string.format('[换装] 脱掉服装IDs, %s', stringfy(self.undressIds)))
    end

    -- 更新当前服装
    --* 传入一个新的{}作为newDressedIds，在回调里赋值dressedIds
    GetCurrClothesIds(avatar, {}, getTakeOffClothesCallback)
end

--- 行为栈：重做
function Action:Redo()
    -- 换装：新衣服
    ChangeClothesAux(self.dressIds)
    -- 更新当前服装
    GetCurrClothesIds(avatar, dressedIds)
end

--- 行为栈：撤销
function Action:Undo()
    -- 换装：旧衣服
    ChangeClothesAux(self.undressIds)
    -- 更新当前服装
    GetCurrClothesIds(avatar, dressedIds)
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
    M.Event.Root:Connect(EventHandler)
end

--- 事件处理
function EventHandler(_event, ...)
    if _event == M.Event.Enum.OPEN then
        gender = localPlayer.Avatar.Gender
        -- 读取玩家形象
        LoadAvatar()
        -- 读取玩家服装信息
        GetPlayerOwnedList()
        -- 清空行为栈
        UndoStack:Clear()
        RedoStack:Clear()
        -- 更新Action状态
        SyncActionStates()
    elseif _event == M.Event.Enum.CLOSE then
        -- 保存玩家形象
        SaveAvatar()
        -- 清空行为栈
        UndoStack:Clear()
        RedoStack:Clear()
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
        DodoChangeClothes({id})
        -- 取消红点
        if isNew then
            ClearRedDot(id)
        end
    elseif _event == M.Event.Enum.ACTION.UNDO then
        UndoChangeClothes()
    elseif _event == M.Event.Enum.ACTION.REDO then
        RedoChangeClothes()
    elseif _event == M.Event.Enum.ACTION.RESTORE then
        RestoreClothes()
    end
end

--! 数据加载、保存

--- 读取玩家形象
function LoadAvatar()
    -- 读取玩家形象回调
    local callback = function(_itemIds, _msg)
        Debug.Log(string.format('[换装] 下载服装资源, msg: %s', _msg))
        -- Debug.Log(string.format('[换装] 服装id列表: %s', dump(_itemIds)))

        if _msg == MSG_SUCCEEDED then
            Debug.Log(string.format('[换装] Download Current Exterior Callback, msg: %s', _msg))
            -- Debug.Log(string.format('[换装] 服装id列表: %s', stringfy(_itemIds)))

            -- 将NPC变为白模
            avatar:ResetToDefault()
            -- 将玩家身上的服装IDs拷贝在NPC身上
            ChangeClothesAux(_itemIds)

            -- 初始化玩家当前身上的服装IDs
            GetCurrClothesIds(avatar, defaultIds)
            GetCurrClothesIds(avatar, dressedIds)

            -- 把localPlayer的属性赋值给NPC
            avatar.BodyType = localPlayer.Avatar.BodyType
            avatar.FaceType = localPlayer.Avatar.FaceType
            avatar.SkinColor = localPlayer.Avatar.SkinColor
            avatar.Gender = localPlayer.Avatar.Gender

            avatarDownloaded = true
        else
            Debug.LogWarning(string.format('[换装] 下载服装资源, msg: %s', _msg))
        end
    end

    AvatarManager.DownloadCurrentAvatarResource(callback)
end

--- 保存玩家形象
function SaveAvatar()
    -- 保存玩家体型
    localPlayer.Avatar.BodyType = avatar.BodyType
    localPlayer.Avatar.FaceType = avatar.FaceType
    localPlayer.Avatar.SkinColor = avatar.SkinColor
    localPlayer.Avatar.Gender = avatar.Gender

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
            for _, v in ipairs(_ownedItems) do
                if v.gender == 0 or v.gender == gender then
                    -- 判断服装是否可用，性别是否相符
                    outfits[v.itemId] = {
                        Id = v.itemId,
                        Gender = v.gender,
                        New = not v.viewed,
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
        end

        M.Fire(M.Event.Enum.GOT_PLAYER_OWN_ITEMLIST)
    end

    AvatarManager.GetPlayerOwnedDressList(localPlayer.Avatar, 'all', callback)
end

--- 刷新更新服装列表
function UpdateItemList(_subType)
    local currItemList = {}
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

    local callback = function()
        -- 触发GUI物品列表更新
        M.Fire(M.Event.Enum.REFRESH_GUI.ITEMLIST, currItemList, currId)
    end
    GetOutfitCurrId(currItemList, callback)
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
function GetOutfitCurrId(_currItemList, _callback)
    currId = nil
    local findCurrId = function(_items)
        for _, v1 in pairs(_currItemList) do
            for _, v2 in pairs(_items) do
                if v1.Id == v2 then
                    currId = v2
                    _callback()
                    return
                end
            end
        end
        _callback()
    end
    avatar:GetCurrentSuits(findCurrId)
end

--! 玩家行为相关接口

--- 取消红点
function ClearRedDot(_id)
    Debug.Log(string.format('[换装] 清除红点 id = %s', _id))
    AvatarManager.ClearRedPot(1, _id)

    local cos = outfits[_id]
    if cos.New then
        newTypes[cos.MainType] = newTypes[cos.MainType] - 1
        newTypes[cos.SubType] = newTypes[cos.SubType] - 1
        cos.New = false
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
function DodoChangeClothes(_ids)
    -- 创建玩家行为
    local action = Action:New(_ids)
    action:Dodo()

    -- 栈操作
    UndoStack:Push(action)
    RedoStack:Clear()
    -- GUI同步
    SyncActionStates()
end

--- 撤销：换衣服
function UndoChangeClothes()
    if not UndoStack:IsEmpty() then
        local action = UndoStack:Pop()
        action:Undo()
        RedoStack:Push(action)
    end
    -- GUI同步
    SyncActionStates()
end

--- 重做：换衣服
function RedoChangeClothes()
    if not RedoStack:IsEmpty() then
        local action = RedoStack:Pop()
        action:Redo()
        UndoStack:Push(action)
    end
    -- GUI同步
    SyncActionStates()
end

--- 恢复初始服装
function RestoreClothes()
    -- 将NPC变为白模
    avatar:ResetToDefault()

    -- 创建默认服装列表的IDs
    local ids = {}
    for _, id in ipairs(defaultIds) do
        table.insert(ids, id)
    end

    -- 执行正常换装
    DodoChangeClothes(ids)
end

--- 换衣服的引擎接口
function ChangeClothesAux(_ids)
    Debug.Log(string.format('[换装] 更新服装IDs, %s', stringfy(_ids)))
    for _, id in ipairs(_ids) do
        avatar:ChangeClothes(id, true)
    end
end

--- 返回当前玩家身上的服装IDs
function GetCurrClothesIds(_avatar, _outItems, _cb)
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
