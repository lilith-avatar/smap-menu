--- 服务器文件路径配置
--- @module Manifest, Server-side
--- @copyright Lilith Games, Avatar Team
local Manifest = {}

Manifest.ROOT_PATH = 'Menu/Script/Server/'

Manifest.Events = {
    'MuteLocalEvent',
    'TeleportPlayerToFriendGameEvent',
    'ConfirmNoticeEvent',
    'SwitchOfflineStateEvent',
    'ReportInfoEvent',
    'ChangeQuitInfoEvent',
    'InGamingImEvent'
}

Manifest.Modules = {
    'MenuServer/MenuMgr',
    'MenuServer/InGamingImMgr',
    'MenuServer/MenuServerApi'
}

return Manifest
