--- 框架默认配置 --* 客户端
--- @module Framework Global FrameworkConfig
--- @copyright Lilith Games, Avatar Team

local M = {}

M.ROOT_PATH = 'Menu/Client/'

M.Events = {
    'NoticeEvent',
    'NormalImEvent',
    'MuteAllEvent',
    'MuteSpecificPlayerEvent',
    'GetFriendsListEvent',
    'InviteFriendToGameEvent',
    'JoinFriendGameEvent',
    'AddFriendsEvent',
    'SomeoneInviteEvent',
    'ConfirmInviteEvent',
    'CloseOutfitEvent',
    'MenuSwitchEvent',
    'SwitchOutfitEntranceEvent',
    'SwitchVoiceEvent',
    'SwitchInGameMessageEvent',
    'TranslateTextEvent'
}

M.Modules = {
    'MenuLogic/MenuDisplay',
    'MenuLogic/MenuCtr',
    'MenuLogic/MenuApi',
    'MenuLogic/MenuLocalization'
}

return M