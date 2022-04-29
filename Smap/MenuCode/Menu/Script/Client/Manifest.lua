--- 框架默认配置 --* 客户端
--- @module Framework Global FrameworkConfig
--- @copyright Lilith Games, Avatar Team

local M = {}

M.ROOT_PATH = 'Menu/Script/Client/'

M.Events = {
    'NoticeEvent',
    'ClientReadyEvent',
    'NormalImEvent',
    'MuteAllEvent',
    'MuteSpecificPlayerEvent',
    'GetFriendsListEvent',
    'InviteFriendToGameEvent',
    'JoinFriendGameEvent',
    'AddFriendsEvent',
    'SomeoneInviteEvent',
    'ConfirmInviteEvent',
    'MenuSwitchEvent',
    'SwitchVoiceEvent',
    'SwitchInGameMessageEvent',
    'TranslateTextEvent',
    'CreateReadyEvent',
    'DetectMenuDisplayStateEvent',
    'LowQualityWarningEvent',
    'AllowExitEvent', 
    'SwitchVoiceBtnEvent'
}

M.Modules = {
    'MenuLogic/MenuDisplay',
    'MenuLogic/MenuCtr',
    'MenuLogic/MenuClientApi',
    'MenuLogic/MenuLocalization'
}

return M
