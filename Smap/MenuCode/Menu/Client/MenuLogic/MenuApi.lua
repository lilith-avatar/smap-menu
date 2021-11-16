---@module MenuApi
---@copyright Lilith Games, Avatar Team
---@author ropztao
local  MenuApi,this = ModuleUtil.New('MenuApi', ClientBase)

---初始化
function MenuApi:Init()
    
end

function MenuApi:DeveloperOfficialMsg(_content)
    NetUtil.Fire_S('InGamingImEvent', 'Developer', _content)
end



return MenuApi