---@module InGamingImMgr
---@copyright Lilith Games, Avatar Team
---@author ropztao
local InGamingImMgr,this = ModuleUtil.New('InGamingImMgr', ServerBase)
---初始化
function InGamingImMgr:Init()
    self:DataInit()

end

function InGamingImMgr:DataInit()
    
end

local callback = function(_imContent,_msg)
    InGamingImMgr:SendToChat(_msg)
end

function InGamingImMgr:InGamingImEventHandler(_sendPlayer, _imContent)
    -- 敏感词过滤
    self.sender = _sendPlayer
    ChatManager.SensitiveWordCheck(_imContent, callback)
end

function InGamingImMgr:SendToChat(_content)
    if self.sender.ClassName == "PlayerInstance" then
        for k,v in pairs(MenuMgr.playerList) do
            NetUtil.Fire_C('NormalImEvent', v, self.sender,_content)
        end
    elseif self.sender == 'Developer' then
        for k,v in pairs(MenuMgr.playerList) do
            NetUtil.Fire_C('NormalImEvent', v, 'Developer',_content)
        end
    end
end

return InGamingImMgr