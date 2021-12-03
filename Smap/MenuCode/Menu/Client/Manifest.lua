--- 框架默认配置
--- @module Framework Global FrameworkConfig
--- @copyright Lilith Games, Avatar Team
local Manifest = {}

Manifest.ROOT_PATH = 'Menu/Client/'

Manifest.Events = {
    'NoticeEvent', 
    'NormalImEvent', 
    'MuteAllEvent',
    'MuteSpecificPlayerEvent', 
    'GetFriendsListEvent',
    'InviteFriendToGameEvent',
    'JoinFriendGameEvent',
    'AddFriendsEvent'
}

Manifest.Modules = {
    {
        Name = 'MenuLogic',
        Modules = {
            'CtrBase',
            'MenuDisplay',
            'MenuCtr', 
            'MenuApi'
        }
    }
}

return Manifest