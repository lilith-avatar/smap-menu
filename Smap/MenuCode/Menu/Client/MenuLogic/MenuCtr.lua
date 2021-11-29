---@module MenuCtr
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  MenuCtr,this = ModuleUtil.New('MenuCtr', ClientBase)

---初始化
function MenuCtr:Init()
    
end

function MenuCtr:NoticeEventEventHandler(_playerTab, _playerList, _changedPlayer, _isAdded)
    self.playerList = _playerList
end

function MenuCtr:MuteAllEventHandler(_isMuted)
    
end

function MenuCtr:MuteSpecificPlayerEventHandler(_specificPlayer, _isMuted)
    
end

return MenuCtr