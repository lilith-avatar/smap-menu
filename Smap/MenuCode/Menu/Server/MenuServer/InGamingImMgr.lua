--- 游戏内设置
--- @module InGamingImMgr
--- @copyright Lilith Games, Avatar Team
--- @author ropztao, Yuancheng Zhang

-- Local Caches
local ChatManager = ChatManager
local S = _G.S

--* 模块
local M = S.ModuleUtil.New('InGamingImMgr', S.Base)

--* 本地变量
local sender  -- 发送者

--- 发送聊天数据
function SendToChat(_content)
    if sender.ClassName == 'PlayerInstance' then
        for _, v in pairs(M.Other.MenuMgr.playerList) do
            M.Kit.Util.Net.Fire_C('NormalImEvent', v, sender, _content)
        end
    elseif sender == 'Developer' then
        for _, v in pairs(M.Other.MenuMgr.playerList) do
            M.Kit.Util.Net.Fire_C('NormalImEvent', v, 'Developer', _content)
        end
    end
end

function M:InGamingImEventHandler(_sendPlayer, _imContent)
    -- 敏感词过滤
    local callback = function(_imContent, _msg)
        SendToChat(_msg)
    end
    sender = _sendPlayer
    ChatManager.SensitiveWordCheck(_imContent, callback)
end

return M
