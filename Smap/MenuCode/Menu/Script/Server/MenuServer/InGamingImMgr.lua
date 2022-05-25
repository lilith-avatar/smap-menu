--- 游戏内设置
--- @module InGamingImMgr
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local ChatManager = ChatManager
local S = _G.mS
local world = world

--* 模块
local M = S.ModuleUtil.New('InGamingImMgr', S.Base)

--* 本地变量
local enableSub, tarPlayerTab, subPlayerList = false, {}, {}

--- 发送聊天数据
function SendToChat(_content, _tarTab, _sender)
    if _sender.ClassName == 'PlayerInstance' then
        for _, v in pairs(_tarTab) do
            M.Kit.Util.Net.Fire_C('NormalImEvent', world:GetPlayerByUserId(v.id), _sender, _content)
        end
    end
end

function InGamingImEventHandler(_sendPlayer, _imContent)
    local callback = function(_imContent, _msg)
        SendToChat(_msg, tarPlayerTab, _sendPlayer)
    end

    tarPlayerTab = M.Other.MenuMgr.playerList

    ChatManager.SensitiveWordCheck(_imContent, callback)
end

--! Public methods
M.InGamingImEventHandler = InGamingImEventHandler
return M
