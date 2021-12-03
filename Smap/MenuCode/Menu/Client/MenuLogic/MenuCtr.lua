---@module MenuCtr
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  MenuCtr,this = ModuleUtil.New('MenuCtr', ClientBase)

---初始化
function MenuCtr:Init()
    
end

function MenuCtr:NoticeEventHandler(_playerTab, _playerList, _changedPlayer, _isAdded)
    self.playerTab = _playerTab
    self.playerList = _playerList
end

function MenuCtr:MuteAllEventHandler(_isMuted)
    for k,v in pairs(self.playerTab) do
        VoiceManager.MuteDesignatedPlayer(k, _isMuted)
    end
end

function MenuCtr:MuteSpecificPlayerEventHandler(_specificPlayer, _isMuted)
    VoiceManager.MuteDesignatedPlayer(_specificPlayer, _isMuted)
end

return MenuCtr