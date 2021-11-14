---@module InGamingIm
---@copyright Lilith Games, Avatar Team
---@author ropztao
local InGamingIm,this = ModuleUtil.New('InGamingIm', ServerBase)
---初始化
function InGamingIm:Init()
    self:DataInit()

end

function InGamingIm:DataInit()
    
end

local callback = function(_content, _msg)
    if _msg == 0 then
        InGamingIm:SendToChat(_content)
    end
end

function InGamingIm:InGamingImEventHandler(_sendPlayer, _imContent)
    -- 敏感词过滤
    self.sender = _sendPlayer
    ChatManager.SensitiveWordCheck(_imContent, callback)
end

function InGamingIm:SendToChat(_content)
    if self.sender.ClassName == "PlayerInstance" then
        for k,v in pairs(self.playerTab) do
            if v ~= self.sender then
                NetUtil.Fire_C('NormalImEvent', v, _content)
            end
        end

    elseif self.sender == 'Developer' then
        NetUtil.Broadcast('DeveloperBroadcastEvent', _content)
    end
end

return InGamingIm