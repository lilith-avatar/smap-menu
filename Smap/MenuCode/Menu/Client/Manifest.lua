--- 框架默认配置
--- @module Framework Global FrameworkConfig
--- @copyright Lilith Games, Avatar Team
local Manifest = {}

Manifest.ROOT_PATH = 'Menu/Client/'

Manifest.Events = {
    'NoticeEvent'
}

Manifest.Modules = {
    {
        Name = 'MenuLogic',
        Modules = {
            'CtrBase',
            'CtrGui'
        }
    }
}

return Manifest