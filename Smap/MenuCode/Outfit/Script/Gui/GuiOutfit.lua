--- 换装系统UI（Landscape）
--- @module Outfit GUI
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
-- cache
local wait, invoke = wait, invoke
local world = world
local Vector2, Color, Enum = Vector2, Color, Enum
local Debug = Debug
local ResourceManager, AvatarManager, ScreenCapture = ResourceManager, AvatarManager, ScreenCapture

--* 模块
local M = {}

-- 本地缓存
local defaultMainType, defaultSubType  -- 打开时，默认类型的ID，
local currMainType, currSubType  -- 当前类型的ID
local currItemList  -- 当前的服装
local newTypes  -- MainType和SubType包含新服装的数量
local itemDataDict = {} -- obj -> data 关联表

-- GUI
-- 根节点（Init时候被赋值）
local root
--* ScreenGUI界面
local gui
-- 主要panel节点
local pnlRight
local pnlMainType, pnlSubType
-- 功能按钮根节点
local imgActions
-- Tips节点
local imgTips
-- 按钮节点
local btnBack, btnRestore, btnRedo, btnUndo
-- 服装的Scroller节点
local sclOutfit

--* 当前选中的SubType按钮
local currStBtn

--* 当前选中的ItemId
local currOutfitId

-- 节点列表
local mainTypeBtns = {}
local subTypePnls = {}
-- 计数器
local resCnt, RES_THRESHOLD = 0, 3 -- GUI Archetype资源加载数和最大数

-- 资源常量
local RES_MAINTYPE_BTN = 'Outfit/Archetype/Gui/Btn_Landscape_MainType'
local RES_SUBTYPE_BTN = 'Outfit/Archetype/Gui/Btn_Landscape_SubType'
local RES_SUBTYPE_PNL = 'Outfit/Archetype/Gui/Pnl_Landscape_SubType'

-- 美术常量
local MAINBTN_BTN_SPACE_Y = 160
local MAINTYPE_BTN_OFFSET_X = 50
local MAINTYPE_BTN_OFFSET_Y = 20
local SUBTYPE_BTN_LEFT_MARGIN = 60
local SUBTYPE_BTN_SPACE_X = 80
local ITEM_LOADING_CYCLE_TIME = 1 -- second
local ITEM_COUNTDOWN_TXT_TIMER_OFFSET_X = 10
local TIPS_IMG_OFFSET_Y = -240

--* 动画相关
local TW_OPEN_DUR = 0.9
local SUBTYPE_BTN_UNDERLINE_TW_DUR = 0.4 -- Tween时间
local moveInPnlRightStartOffsetX, moveInPnlRightEndOffsetX
local moveInPnlMainTypeStartOffsetX, moveInPnlMainTypeEndOffsetX

--- 初始化
function Init(_root)
    root = _root
    InitLocalVars() -- 本地变量
    BindEvent() -- 事件绑定
    InitGuiData() -- GUI数据
    InitBtns() -- 功能按钮
    InitGuiNodes() -- 根据数据生成界面
    InitTweenNodes() -- Tween动画节点
end

--- 初始化本地变量
function InitLocalVars()
    -- GUI nodes
    gui = root.Gui_Outfit
    -- Panel
    pnlRight = gui.Pnl_Right
    imgActions = pnlRight.Img_Actions
    pnlMainType = gui.Pnl_MainType
    pnlSubType = pnlRight.Pnl_SubType
    -- Button
    btnBack = gui.Btn_Back
    btnRestore = imgActions.Btn_Restore
    btnRedo = imgActions.Btn_Redo
    btnUndo = imgActions.Btn_Undo
    -- Scroller
    sclOutfit = gui.Pnl_Right.Pnl_ListView.Scroller_Outfit
    -- Tips
    imgTips = pnlRight.Img_Tips
end

--- 事件绑定
function BindEvent()
    M.Event.Root:Connect(EventHandler)
end

--- 事件处理
function EventHandler(_event, ...)
    if _event == M.Event.Enum.OPEN then
        GuiOpen()
    elseif _event == M.Event.Enum.CLOSE then
        GuiClose()
    elseif _event == M.Event.Enum.REFRESH_GUI.ALL then
        -- TODO: 暂时没有
        RefreshGui()
    elseif _event == M.Event.Enum.REFRESH_GUI.ITEMLIST then
        local args = {...}
        currItemList = args[1] or {}
        RefreshScroller()
    elseif _event == M.Event.Enum.REFRESH_GUI.MENU then
        local args = {...}
        newTypes = args[1] or {}
        RefreshAllTypeBtns()
    elseif _event == M.Event.Enum.GOT_PLAYER_OWN_ITEMLIST then
        -- 出发事件，更新最新的 Item List
        M.Fire(M.Event.Enum.UPDATE_CURR_TYPES, currMainType, currSubType)
    elseif _event == M.Event.Enum.ACTION.DONE then
        local args = {...}
        local canRestore, canRedo, canUndo = args[1], args[2], args[3]
        RefreshActionBtns(canRestore, canRedo, canUndo)
    elseif _event == M.Event.Enum.GET_CURR_IDS then
        local args = {...}
        currOutfitId = args[1]
        -- print(table.dump(currOutfitId))
        RefreshAllScollerItemClickState()
    end
end

--- 初始化GUI数据
function InitGuiData()
    for _, mt in ipairs(M.Xls.MainType) do
        defaultMainType = defaultMainType or (mt.Enable and mt.MainType)
        mt.SubTypes = {}
        for _, st in ipairs(M.Xls.SubType) do
            if st.MainType == mt.MainType then
                defaultSubType = defaultSubType or (mt.Enable and st.Enable and st.SubType)
                table.insert(mt.SubTypes, st)
            end
        end
    end
end

--- 初始化功能按钮
function InitBtns()
    -- 返回 Back
    btnBack.OnClick:Connect(
        function()
            -- 关闭界面
            M.Fire(M.Event.Enum.CLOSE_TRANSITION)
        end
    )
    -- 重置 Restore
    btnRestore.OnClick:Connect(
        function()
            Debug.Log('[换装] 重置 Restore')
            M.Fire(M.Event.Enum.ACTION.RESTORE) -- 触发引擎更新行为栈
        end
    )
    -- 重做 Redo
    btnRedo.OnClick:Connect(
        function()
            Debug.Log('[换装] 重做 Redo')
            M.Fire(M.Event.Enum.ACTION.REDO) -- 触发引擎更新行为栈
        end
    )
    -- 撤销 Undo
    btnUndo.OnClick:Connect(
        function()
            Debug.Log('[换装] 撤销 Undo')
            M.Fire(M.Event.Enum.ACTION.UNDO) -- 触发引擎更新行为栈
        end
    )
end

--- 根据数据，初始化Panels
function InitGuiNodes()
    GetGuiArchetypes()
end

-- 加载Archetype
function GetGuiArchetypes()
    local callback = function()
        resCnt = resCnt + 1
        Debug.Log('[换装] GUI Archetypes 加载#' .. tostring(resCnt))

        if resCnt < RES_THRESHOLD then
            return
        end

        --TODO: 叶人铭：native的包跟web的包好像游戏启动的时序有差异，我在自己打的包上测不到这个问题。
        --TODO: 叶人铭：我在12月6号之前想办法把这个bug搞掉
        --TODO: 叶人铭：着急的话可以先用这个invoke临时办法解一下
        local succCallback = function()
            local cnt = 1
            for _, data in ipairs(M.Xls.MainType) do
                if data.Enable then
                    CreateSubTypePnl(data) -- SubType
                    CreateMainTypeBtn(cnt, data) -- MainType
                    cnt = cnt + 1
                end
            end

            -- 根据按钮数量调整滚动区间
            pnlMainType.ScrollRange = MAINTYPE_BTN_OFFSET_X + (cnt - 1) * MAINBTN_BTN_SPACE_Y

            -- Scroller
            InitScroller()
        end

        invoke(succCallback, 0.02)
    end

    ResourceManager.GetArchetype(RES_MAINTYPE_BTN, callback)
    ResourceManager.GetArchetype(RES_SUBTYPE_PNL, callback)
    ResourceManager.GetArchetype(RES_SUBTYPE_BTN, callback)
end

--- 初始化Scroller
function InitScroller()
    -- 初始化设为0个长度
    sclOutfit.RefreshItemViewEvent:Connect(RefreshScrollerLine)
    sclOutfit.NumberOfItems = 0
    sclOutfit:ReloadData()
end

--! 节点创建

--- 创建左侧Panel上的按钮
function CreateMainTypeBtn(_idx, _data)
    -- 创建按钮
    local btnObj = world:CreateInstance(RES_MAINTYPE_BTN, 'Btn_' .. _data.MainType, pnlMainType)
    btnObj.Offset = Vector2(MAINTYPE_BTN_OFFSET_X, -MAINTYPE_BTN_OFFSET_Y - 1 * (_idx - 1) * MAINBTN_BTN_SPACE_Y)
    btnObj.Transition = Enum.UITransition.Image
    btnObj.Texture = ResourceManager.GetTexture(_data.ResIcon)

    -- 存储节点列表
    mainTypeBtns[_data.MainType] = {
        obj = btnObj,
        data = _data
    }

    -- 绑定点击事件
    btnObj.OnClick:Connect(
        function()
            BtnMainTypeClicked(btnObj)
        end
    )
end

--- 创建右侧上方Panel
function CreateSubTypePnl(_data)
    -- 创建Panel
    local pnlObj = world:CreateInstance(RES_SUBTYPE_PNL, 'Pnl_SubType_' .. _data.MainType, pnlSubType)
    pnlObj.Scroll = Enum.ScrollBarType.Horizontal
    pnlObj.ShowScrollBar = Enum.ScrollBarShowType.Hide
    pnlObj.Enable = false

    -- 存入节点列表
    subTypePnls[_data.MainType] = {
        obj = pnlObj, -- 节点对象
        data = _data,
        btns = {}, -- 按钮列表
        calOffset = false -- GUI显示时计算按钮OffsetX
    }

    -- 生成Panel中的SubType按钮
    local cnt = 1
    for _, st in ipairs(_data.SubTypes) do
        if st.Enable then
            CreateSubTypeBtn(cnt, pnlObj, st)
            cnt = cnt + 1
        end
    end

    -- 根据按钮数量调整滚动区间
    pnlObj.ScrollRange = (cnt - 1) * SUBTYPE_BTN_SPACE_X
end

--- 创建 SubType Button
function CreateSubTypeBtn(_idx, _root, _data)
    -- 创建按钮
    local btnObj = world:CreateInstance(RES_SUBTYPE_BTN, string.format('Btn_%02d', _data.SN), _root)

    -- 存入节点列表
    subTypePnls[_data.MainType].btns[_data.SubType] = {
        obj = btnObj,
        data = _data,
        idx = _idx
    }

    -- 绑定点击事件
    btnObj.OnClick:Connect(
        function()
            BtnSubTypeClicked(btnObj, subTypePnls[_data.MainType].btns)
        end
    )
end

--! 点击事件

--- MainType按钮点击
function BtnMainTypeClicked(_btnObj)
    -- 停止全部Tween动画
    StopAllTween()

    -- 切换Icon样式
    for mt, lb in pairs(mainTypeBtns) do
        if lb.obj == _btnObj then
            if currMainType ~= mt then
                -- 更新当前MainType
                currMainType = mt
                -- 当前SubType默认设置为All
                currSubType = lb.data.SubTypes[1].SubType
            end
            break
        end
    end

    -- 发送当前主页签和子类型，获取有的Item列表
    M.Fire(M.Event.Enum.UPDATE_CURR_TYPES, currMainType, currSubType)
end

--- SubType按钮点击
function BtnSubTypeClicked(_btnObj)
    -- 停止全部Tween动画
    StopAllTween()

    -- 刷新按钮样式
    for st, btn in pairs(subTypePnls[currMainType].btns) do
        if btn.obj == _btnObj then
            if currSubType ~= st then
                -- 更新当前SubType
                currSubType = st
                stBtn = btn
            end
        elseif btn == currStBtn and btn.data.CheckNew then
            -- 去掉旧的红点
            local ids = {}
            for _, item in pairs(currItemList) do
                table.insert(ids, item.Id)
            end
            M.Fire(M.Event.Enum.CLEAR_DOT, ids)
        end
    end

    M.Fire(M.Event.Enum.UPDATE_CURR_TYPES, currMainType, currSubType)
end

--- Item按钮点击
function BtnItemClicked(_btnObj)
    -- print(_btnObj)
    -- print(itemDataDict[_btnObj].dataIdx)
    local dataIdx = itemDataDict[_btnObj].dataIdx
    if dataIdx ~= nil and dataIdx <= #currItemList then
        local data = currItemList[dataIdx]
        local id = currItemList[dataIdx].Id
        -- 调用引擎接口换装、红点
        M.Fire(M.Event.Enum.CHANGE_CLOTHES, id, data.New)
        -- 脱衣服时，取消选中
        if id == currOutfitId then
            currOutfitId = nil
        end
    end
end

--- Item按钮长按开始
function BtnItemLongPressBegin(_btnObj)
    Debug.Log(string.format('[换装] 长按开始 btn = %s', _btnObj))
    -- print(itemDataDict[_btnObj].dataIdx)
    local dataIdx, data = itemDataDict[_btnObj].dataIdx, nil
    if dataIdx ~= nil and dataIdx <= #currItemList then
        data = currItemList[dataIdx]
    end

    -- 刷新item点击状态
    RefreshAllScollerItemClickState()

    -- 刷新Tips
    if data ~= nil then
        -- 显示tips
        local lineIdx = (dataIdx - 1) % 4 + 1

        --! TEST 最长字符串
        -- data.Title = 'Kacamata hitam mata kucing'
        -- data.Description =
        --     'Kamu duduk di kolam gua yang menghadap ke Santorini. Koin di kalung, dikatakan membawa pertemuan kebetulan, berayun ditiup angin, membentur tembok, dan menciptakan suara yang indah...'
        -- data.Source =
        --     'Hadiah login pertama yang valid selama 15 hari. Pakaian ini akan menjadi tidak valid setelah event (xxxx/xx/xx).'

        imgTips.Enable = true
        imgTips.Txt_RichText.LocalizeKey = M.Xls.GlobalText.Tips._Text
        imgTips.Txt_RichText.Variable1 = data.Title
        imgTips.Txt_RichText.Variable2 = data.Description
        imgTips.Txt_RichText.Variable3 = data.Source
        local btnScnPos = _btnObj.ScreenPosition
        local pnlRightSize = pnlRight.FinalSize
        local anchorX = 1 / 2
        if btnScnPos.X > 0 and btnScnPos.Y > 0 and pnlRightSize.X > 0 and pnlRightSize.Y > 0 then
            if lineIdx == 2 then
                anchorX = 3 / 4
            elseif lineIdx == 3 then
                anchorX = 1 / 4
            end
            imgTips.AnchorsX = Vector2.One * anchorX
            imgTips.AnchorsY = Vector2.One * 0.5
            imgTips.Offset = Vector2(0, TIPS_IMG_OFFSET_Y)
        else
            -- 隐藏tips
            imgTips.Enable = false
        end
    else
        -- 隐藏tips
        imgTips.Enable = false
    end
end

--- Item按钮长按结束
function BtnItemLongPressEnd(_btnObj)
    Debug.Log(string.format('[换装] 长按结束 btn = %s', _btnObj))
    -- print(itemDataDict[_btnObj].dataIdx)

    -- 隐藏tips
    imgTips.Enable = false

    -- 刷新item点击状态
    RefreshAllScollerItemClickState()
end

--! GUI 界面刷新

--- 刷新GUI
function RefreshGui()
    -- 刷新MainType和SubType按钮
    RefreshAllTypeBtns()
    -- 刷新物品的Scroller
    RefreshScroller()
end

--- 刷新MainType和SubType按钮
function RefreshAllTypeBtns()
    RefreshMainTypeBtns()
    RefreshSubTypePnl()
end

--- 刷新3个行为按钮：Restore、Redo、Undo（自上而下）
function RefreshActionBtns(canRestore, canRedo, canUndo)
    RefreshActionBtn(btnRestore, btnRestore.Img_Restore, canRestore)
    RefreshActionBtn(btnRedo, btnRedo.Img_Redo, canRedo)
    RefreshActionBtn(btnUndo, btnUndo.Img_Undo, canUndo)
end

--- 刷新行为按钮：
--- @param _btn 行为按钮
--- @param _img 按钮图标
--- @param _flag 1:可点击，0:不可点击
function RefreshActionBtn(_btn, _img, _canClick)
    -- 撤销 Undo
    if _canClick == true then
        _btn.Clickable = true
        _img.Alpha = 1
    else
        _btn.Clickable = false
        _img.Alpha = 0.3
    end
end

--- 切换MainType按钮图标
function RefreshMainTypeBtns()
    for _, mtb in pairs(mainTypeBtns) do
        if mtb.data.MainType == currMainType then
            mtb.obj.Size = Vector2(100, 100)
            mtb.obj.Texture = ResourceManager.GetTexture(mtb.data.ResIconPressed)
        else
            mtb.obj.Size = Vector2(80, 80)
            mtb.obj.Texture = ResourceManager.GetTexture(mtb.data.ResIcon)
        end

        -- 红点：拥有新物品的数量
        local newCnt = newTypes[mtb.data.MainType]
        mtb.obj.Img_Dot.Enable = newCnt ~= nil and newCnt > 0
    end
end

--- 刷新SubType的Panel
function RefreshSubTypePnl()
    --* 当前SubType的下划线
    local imgUnderline = subTypePnls[currMainType].obj.Img_Underline

    -- 切换右侧上方的Panel
    for mt, stp in pairs(subTypePnls) do
        stp.obj.Enable = (mt == currMainType)
    end

    local needCalOffset = not subTypePnls[currMainType].calOffset and gui.Enable

    if needCalOffset then
        wait() --! 等一帧让Panel显示，否则无法触发Dirty
        for _, btn in pairs(subTypePnls[currMainType].btns) do
            -- 计算按钮的Offset
            btn.obj.Txt_Label.LocalizeKey = btn.data._Label
            btn.obj.Offset = Vector2(-500, btn.obj.Offset.Y)
        end
        wait() --! 等一帧让Txt_Label计算Size
    end

    -- 切换按钮的样式：背景下划线、字体加粗
    for st, btn in pairs(subTypePnls[currMainType].btns) do
        if st == currSubType then
            currStBtn = btn --* 当前SubType按钮
            btn.obj.Txt_Label.Color = Color(21, 23, 26, 255)
            btn.obj.Txt_Label.FontType = Enum.FontType.Poppins_Semibold
        else
            btn.obj.Txt_Label.Color = Color(138, 139, 141, 255)
            btn.obj.Txt_Label.FontType = Enum.FontType.Poppins_Regular
        end

        -- 红点：拥有新物品的数量
        local newCnt = 0
        for _, subtype in pairs(st) do
            if newTypes[subtype] ~= nil and newTypes[subtype] > 0 then
                newCnt = newCnt + newTypes[subtype]
            end
        end
        btn.obj.Txt_Label.Img_Dot.Enable = btn.data.CheckNew and newCnt > 0
    end

    if needCalOffset then
        local cumOffsetX = SUBTYPE_BTN_LEFT_MARGIN
        -- 累计的offsetX
        local btns = {}
        for _, btn in pairs(subTypePnls[currMainType].btns) do
            btns[btn.idx] = btn
        end

        for _, btn in ipairs(btns) do
            -- 按钮宽度等于文本宽度，高度等于父节点Panel高度
            btn.obj.Size = Vector2(btn.obj.Txt_Label.Size.X, btn.obj.Parent.Size.Y)
            btn.obj.Offset = Vector2(cumOffsetX, btn.obj.Offset.Y)
            cumOffsetX = cumOffsetX + btn.obj.Txt_Label.Size.X + SUBTYPE_BTN_SPACE_X
        end

        subTypePnls[currMainType].obj.ScrollRange = cumOffsetX - SUBTYPE_BTN_SPACE_X + SUBTYPE_BTN_LEFT_MARGIN
        subTypePnls[currMainType].calOffset = true
        -- 下划线
        imgUnderline.Offset = Vector2(btns[1].obj.Offset.X, imgUnderline.Offset.Y)
        imgUnderline.Size = Vector2(btns[1].obj.Size.X, imgUnderline.Size.Y)
    end

    -- 下划线
    if currStBtn == nil or not gui.Enable then
        imgUnderline.Enable = false
        imgUnderline.Size = Vector2(0, imgUnderline.Size.Y)
    else
        imgUnderline.Enable = true
        imgUnderline.TweenMove:Flush()
        imgUnderline.TweenMove.Properties = {
            Offset = Vector2(currStBtn.obj.Offset.X, imgUnderline.Offset.Y),
            Size = Vector2(currStBtn.obj.Size.X, imgUnderline.Size.Y)
        }
        imgUnderline.TweenMove.EaseCurve = Enum.EaseCurve.CubicInOut
        imgUnderline.TweenMove.Duration = SUBTYPE_BTN_UNDERLINE_TW_DUR
        imgUnderline.TweenMove:Play()
    end
end

--- 刷新服装的Scroller
function RefreshScroller()
    -- 刷新Scroller
    sclOutfit.NumberOfItems = math.ceil(#currItemList / 4)
    sclOutfit:ReloadData()
    -- 刷新全部item的click状态
    RefreshAllScollerItemClickState()
end

--- 刷新Scroller中的每一行（4个item）
function RefreshScrollerLine(_itemObj, _lineIdx)
    if currItemList ~= nil then
        for k, obj in ipairs(_itemObj:GetChildren()) do
            if obj.ClassName == 'UiPanelObject' then
                -- 按钮
                RefreshScrollerItem(obj, (_lineIdx - 1) * 4 + k)
            else
                -- 其他，包括：Tips
                obj.Enable = false
            end
        end
    end
end

--- 刷新全部item上的点击状态表现
function RefreshAllScollerItemClickState()
    -- 关闭Tips
    imgTips.Enable = false

    for _, line in ipairs(sclOutfit:GetChildren()) do
        for _, obj in ipairs(line:GetChildren()) do
            if obj.ClassName == 'UiPanelObject' then
                -- 按钮的外轮廓
                obj.Img_Frame.Enable = false
                if itemDataDict[obj] and itemDataDict[obj].dataIdx then
                    local data = currItemList[itemDataDict[obj].dataIdx]
                    if data and table.contains(currOutfitId, data.Id) then
                        obj.Img_Frame.Enable = true
                        obj.Img_Dot.Enable = false
                    end
                end
            else
                -- 其他，包括：Tips
                obj.Enable = false
            end
        end
    end
end

--- 刷新单一item上的资源数据
function RefreshScrollerItem(_obj, _dataIdx)
    if _dataIdx > #currItemList then
        _obj.Enable = false
    else
        --* 换装
        RefreshScrollerItemOutfit(_obj, _dataIdx)
    end
end

-- 刷新换装Item
function RefreshScrollerItemOutfit(_obj, _dataIdx)
    local data = currItemList[_dataIdx]
    _obj.Enable = true
    _obj.Img_Item.Enable = false
    _obj.Img_Load.Enable = true
    _obj.Img_Load.Angle = 360

    itemDataDict[_obj] = itemDataDict[_obj] or {}

    -- 绑定物品Id
    itemDataDict[_obj].dataIdx = _dataIdx

    -- 绑定：点击事件
    if itemDataDict[_obj].onClick == nil then
        itemDataDict[_obj].onClick = function()
            BtnItemClicked(_obj)
        end
        _obj.Btn_Item.OnClick:Connect(itemDataDict[_obj].onClick)
    end

    -- 绑定：长按事件开始
    if itemDataDict[_obj].onLongPressBegin == nil then
        itemDataDict[_obj].onLongPressBegin = function()
            BtnItemLongPressBegin(_obj)
        end
        -- 长按
        _obj.Btn_Item.OnLongPressBegin:Connect(itemDataDict[_obj].onLongPressBegin)
        --! TEST ONLY: 鼠标中键
        _obj.Btn_Item.OnMiddleMouseDown:Connect(itemDataDict[_obj].onLongPressBegin)
    end

    -- 绑定：长按事件结束
    if itemDataDict[_obj].onLongPressEnd == nil then
        itemDataDict[_obj].onLongPressEnd = function()
            BtnItemLongPressEnd(_obj)
        end
        -- 长按
        _obj.Btn_Item.OnLongPressEnd:Connect(itemDataDict[_obj].onLongPressEnd)
        --! TEST ONLY: 鼠标中键
        _obj.Btn_Item.OnMiddleMouseUp:Connect(itemDataDict[_obj].onLongPressEnd)
    end

    -- GUI
    _obj.Img_Dot.Enable = data.New or false
    _obj.Txt_Item.Text = data.Title
    _obj.Btn_Item.Clickable = true
    _obj.Img_Item.Alpha = 1

    -- 根据PreferredSize来给文本补行，以免字体过大
    -- 先隐藏字体颜色，算好PreferredSize之后再将正确的颜色赋值回来
    local obj = _obj
    obj.Txt_Item.Color = Color(255, 255, 255, 1)
    local adjustText = function()
        wait()
        if obj.Txt_Item.PreferredSize.X < obj.Txt_Item.Size.X then
            local txt = obj.Txt_Item.Text
            txt = txt:gsub('\n', '') -- 删掉原有的换行
            obj.Txt_Item.Text = txt .. '\n' -- 加上新的换行
        end
        obj.Txt_Item.Color = Color(0, 0, 0, 255)
    end
    invoke(adjustText)

    -- GUI 限时服装
    if data.Expiration > -1 then
        _obj.Img_Countdown.Enable = true

        -- 剩余时间
        local restTime = data.Expiration - os.time()
        local var1, key = ShowRestTime(restTime)
        _obj.Img_Countdown.Txt_Timer.LocalizeKey = key
        _obj.Img_Countdown.Txt_Timer.Variable1 = var1

        if restTime > 0 then
            --* 显示限时倒计时
            _obj.Btn_Item.Clickable = true
            _obj.Img_Countdown.Img_Timer.Enable = true
            _obj.Img_Countdown.Txt_Timer.Offset = Vector2(ITEM_COUNTDOWN_TXT_TIMER_OFFSET_X, 0)
        else
            --TODO: 已过期：需要Disable，改GUI
            _obj.Btn_Item.Clickable = false
            _obj.Img_Countdown.Img_Timer.Enable = false
            _obj.Img_Countdown.Txt_Timer.Offset = Vector2.Zero
            _obj.Img_Item.Alpha = 0.3
        end
    else
        _obj.Img_Countdown.Enable = false
    end

    -- loading 动画
    _obj.Img_Load.Tween.Properties = {Angle = 0.003}
    _obj.Img_Load.Tween.EaseCurve = Enum.EaseCurve.Linear
    _obj.Img_Load.Tween.Duration = ITEM_LOADING_CYCLE_TIME
    _obj.Img_Load.Tween.Loop = 0

    -- 播放 loading 动画
    _obj.Img_Load.Tween:Flush()
    _obj.Img_Load.Tween:Play()

    -- 加载服装Thumbnail资源
    local callback = function(_resRef, _msg)
        if _resRef then
            _obj.Img_Frame.Enable = table.contains(currOutfitId, data.Id)
            _obj.Img_Dot.Enable = _obj.Img_Dot.Enable and not table.contains(currOutfitId, data.Id)
            _obj.Img_Item.Texture = _resRef
            _obj.Img_Item.Enable = true
            _obj.Img_Load.Enable = false
            _obj.Img_Load.Tween:Complete()
        end
    end

    AvatarManager.GetAvatarResourceThumbnailTexture(data.Id, callback)
end

--- 停止所有Tween动画
function StopAllTween()
    for obj, _ in pairs(itemDataDict) do
        if obj ~= nil then
            obj.Img_Load.Tween:Complete()
        end
    end
end

--- 恢复默认标签
function ResetToDefault()
    currMainType = defaultMainType
    currSubType = defaultSubType
end

--- 得到当前剩余时间
-- @param @number _restTime 剩余时间（秒）
-- @return @string 显示文本
function ShowRestTime(_restTime)
    local day = M.Xls.GlobalText.Day._Text
    local hour = M.Xls.GlobalText.Hour._Text
    local minute = M.Xls.GlobalText.Minute._Text
    local expired = M.Xls.GlobalText.Expired._Text
    if _restTime >= 86400 then
        return tostring(math.floor(_restTime / 86400)), day
    elseif _restTime >= 3600 then
        return tostring(math.floor(_restTime / 3600)), hour
    elseif _restTime >= 60 then
        return tostring(math.floor(_restTime / 60)), minute
    elseif _restTime > 0 then
        return '< 1', minute
    end
    return expired
end

--! GUI 动画

--- 初始化Tween动画节点
function InitTweenNodes()
    --* 右侧动画
    moveInPnlRightStartOffsetX = (pnlRight.FinalSize.X + imgActions.Size.X) + imgActions.Offset.X
    moveInPnlRightEndOffsetX = pnlRight.Offset.X
    pnlRight.TweenMoveIn.Properties = {Offset = Vector2(moveInPnlRightEndOffsetX, pnlRight.Offset.Y)}
    pnlRight.TweenMoveIn.EaseCurve = Enum.EaseCurve.Linear
    pnlRight.TweenMoveIn.Duration = TW_OPEN_DUR

    --* 左侧动画：主类别
    moveInPnlMainTypeStartOffsetX = pnlMainType.Size.X * -2 --! 两倍是猜的，别怪我
    moveInPnlMainTypeEndOffsetX = pnlMainType.Offset.X
    pnlMainType.TweenMoveIn.Properties = {Offset = Vector2(moveInPnlMainTypeEndOffsetX, pnlMainType.Offset.Y)}
    pnlMainType.TweenMoveIn.EaseCurve = Enum.EaseCurve.Linear
    pnlMainType.TweenMoveIn.Duration = TW_OPEN_DUR
end

function GuiMoveInAnim()
    -- 设置动画前参数
    pnlRight.Offset = Vector2(moveInPnlRightStartOffsetX * 3, pnlRight.Offset.Y)
    pnlMainType.Offset = Vector2(moveInPnlMainTypeStartOffsetX * 3, pnlMainType.Offset.Y)
    pnlMainType.ScrollScale = 0

    --* 右侧动画
    pnlRight.TweenMoveIn:Flush()
    pnlRight.TweenMoveIn:Play()

    --* 左侧动画：主类别
    pnlMainType.TweenMoveIn:Flush()
    pnlMainType.TweenMoveIn:Play()
end

--! GUI 开关

--- 打开界面
function GuiOpen()
    -- 恢复默认页签
    ResetToDefault()
    gui.Enable = true

    -- 显示默认页签
    currMainType = defaultMainType
    currSubType = defaultSubType

    GuiMoveInAnim()
    -- print(currMainType, currSubType)
end

--- 关闭界面
function GuiClose()
    --! 延缓关闭
    gui.Enable = false
    -- 恢复默认页签
    ResetToDefault()
end

--- 判断GUI是否开启
function IsOpen()
    return gui.Enable
end

--! public methods
M.Init = Init
M.IsOpen = IsOpen

return M
