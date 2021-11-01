--- 服务器/客户端文件路径配置
--- @module Manifest, Both-side
--- @copyright Lilith Games, Avatar Team
local Manifest = {}

Manifest.ROOT_PATH = 'Menu/Common/'

Manifest.Modules = {
    {
        Name = 'Define',
        Modules = {
            'Const'
        }
    },
    {
        Name = 'Xls',
        Modules = {
            'BtnBaseTable',
            'RootTable',
            'BtnOutTable',
            'DisplayBaseTable'
        }
    },
    {
        Name = 'Util',
        Modules = {
            'CloudLogUtil'
        }
    }
}

return Manifest
