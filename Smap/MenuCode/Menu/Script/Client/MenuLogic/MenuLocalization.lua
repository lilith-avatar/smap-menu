--- 本地化
--- @module MenuLocalization
--- @copyright Lilith Games, Avatar Team
--- @author ropztao

local C = _G.mC
--* 模块
local M = C.ModuleUtil.New('MenuLocalization', C.Base)

local LocalizationTab = {
    TextGameName = {
        Key = 'TextGameName',
        zh_CN = '游戏中',
        en = 'Gaming',
        id = 'Dalam permainan'
    },
    TextMuteAll = {
        Key = 'TextMuteAll',
        zh_CN = '静音所有',
        en = 'Mute All',
        id = 'Bisu semua'
    },
    TextSetting= {
        Key = 'TextSetting',
        zh_CN = '设置',
        en = 'Setting',
        id = 'Pengaturan'
    },
    TextAutoSet = {
        Key = 'TextAutoSet',
        zh_CN = '画质自动',
        en = 'Graphic Auto Set',
        id = 'Grafik atur otomatis'
    },
    TextGraphicSetting = {
        Key = 'TextGraphicSetting',
        zh_CN = '画质设定',
        en = 'Graphic Setting',
        id = 'Pengaturan Grafis'
    },
    TextShut = {
        Key = 'TextShut',
        zh_CN = '关闭',
        en = 'OFF',
        id = 'Penutup'
    },
    TextOpen = {
        Key = 'TextOpen',
        zh_CN = '打开',
        en = 'On',
        id = 'Membuka'
    },
    TextLow = {
        Key = 'TextLow',
        zh_CN = '低',
        en = 'Low',
        id = 'Rendah'
    },
    TextMedium = {
        Key = 'TextMedium',
        zh_CN = '中',
        en = 'Medium',
        id = 'Sedang'
    },
    TextHigh = {
        Key = 'TextHigh',
        zh_CN = '高',
        en = 'High',
        id = 'Tinggi'
    },
    TextPopUps = {
        Key = 'TextPopUps',
        zh_CN = '确定要退出吗？',
        en = 'Quit Game?',
        id = 'Keluar dari permainan?'
    },
    BtnCancel = {
        Key = 'BtnCancel',
        zh_CN = '取消',
        en = 'Cancel',
        id = 'Tidak'
    },
    BtnOk = {
        Key = 'BtnOk',
        zh_CN = '确定',
        en = 'Ok',
        id = 'Oke'
    },
    BtnShut = {
        Key = 'BtnShut',
        zh_CN = '关闭',
        en = 'OFF',
        id = 'Penutup'
    },
    BtnOpen = {
        Key = 'BtnOpen',
        zh_CN = '打开',
        en = 'On',
        id = 'Membuka'
    },
    BtnLow = {
        Key = 'BtnLow',
        zh_CN = '低',
        en = 'Low',
        id = 'Rendah'
    },
    BtnMedium = {
        Key = 'BtnMedium',
        zh_CN = '中',
        en = 'Medium',
        id = 'Sedang'
    },
    BtnHigh = {
        Key = 'BtnHigh',
        zh_CN = '高',
        en = 'High',
        id = 'Tinggi'
    }
}

local LocalizationTabSp = {
    TextFriList= {
        Key = 'TextFriList',
        zh_CN = '好友',
        en = 'Friends',
        id = 'Teman-Teman'
    },
    TextPlayNum = {
        Key = 'TextPlayNum',
        zh_CN = '玩家',
        en = 'Player',
        id = 'Pemain'
    },
    InputFieldIm = {
        Key = 'InputFieldIm',
        zh_CN = '说点什么吧',
        en = 'Say Something',
        id = 'Katakan sesuatu'
    },
}

local archTab = {
    TextInvite = {
        Key = 'TextInvite',
        zh_CN = '邀请',
        en = 'Invite',
        id = 'Undang'
    },
    BtnInviteOk = {
        Key = 'BtnInviteOk',
        zh_CN = '确定',
        en = 'Ok',
        id = 'Oke'
    }
}

-- 当前语言
local currLang
local gui = {}

--* 常量
local DEFAULT_LANG = 'en' -- 默认语言为英文
local DEBUG_LANG = 'zh_CN'

function Init()
    currLang = Localization:GetLanguage()

    if string.isnilorempty(currLang) then
        currLang = 'en'
    end

    Debug.Log(string.format('[menu] 当前语言：%s', currLang))

    gui.MenuGui = world.MenuNode.Client.MenuGui
    for _, v in pairs(gui.MenuGui:GetDescendants()) do
        gui[v.Name] = v
    end
end

function ClientReadyEventHandler()
    Translate(LocalizationTab)
    TranslateSp(LocalizationTabSp)
end

--- 将本地语言改成对应的
function Translate(_tab)
    for k,v in pairs(_tab) do
        gui[k].Text = v[currLang]
    end
end

function TranslateSp(_tab)
    for _,v in pairs(_tab) do
        M.Kit.Util.Net.Fire_C('TranslateTextEvent', localPlayer, v[currLang], v['Key'])
    end
end

--! public method
M.Init = Init
M.NoticeEventHandler = NoticeEventHandler

return M
