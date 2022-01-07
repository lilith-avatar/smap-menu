--- 游戏内设置
--- @module InGamingImMgr
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local ChatManager = ChatManager
local S = _G.mS

--* 模块
local M = S.ModuleUtil.New('InGamingImMgr', S.Base)

--* 本地变量
local sender  -- 发送者
local enableSub, tarPlayerTab, subPlayerList = false, {}, {}

--- 发送聊天数据
function SendToChat(_content, _tarTab)
    if sender.ClassName == 'PlayerInstance' then
        for _, v in pairs(_tarTab) do
            M.Kit.Util.Net.Fire_C('NormalImEvent', v, sender, _content)
        end
    elseif sender == 'Developer' then
        for _, v in pairs(M.Other.MenuMgr.playerList) do
            M.Kit.Util.Net.Fire_C('NormalImEvent', v, 'OFFICIAL', _content)
        end
    end
end

function InGamingImEventHandler(_sendPlayer, _imContent)
    local callback = function(_imContent, _msg)
        SendToChat(_msg, tarPlayerTab)
    end

    sender = _sendPlayer

    if enableSub then
        for _, v in pairs(subPlayerList) do
            for i, j in pairs(v) do
                if sender == j then
                    tarPlayerTab = v
                end
            end
        end
    else
        tarPlayerTab = M.Other.MenuMgr.playerList
    end

    ChatManager.SensitiveWordCheck(_imContent, callback)
end

function EnableSubChannelEventHandler(_boolean, _list)
    enableSub = _boolean
    subPlayerList = _list
end

--! Public methods
M.InGamingImEventHandler = InGamingImEventHandler
M.EnableSubChannelEventHandler = EnableSubChannelEventHandler
return M
