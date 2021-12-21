--- 服务器文件路径配置
--- @module Manifest, Server-side
--- @copyright Lilith Games, Avatar Team
local Manifest = {}

Manifest.ROOT_PATH = 'Menu/Server/'

Manifest.Events = {
    'InGamingImEvent',
    'MuteLocalEvent',
    'TeleportPlayerToFriendGameEvent',
    'ConfirmNoticeEvent'
}

Manifest.Modules = {
    'MenuServer/MenuMgr',
    'MenuServer/InGamingImMgr'
}

return Manifest