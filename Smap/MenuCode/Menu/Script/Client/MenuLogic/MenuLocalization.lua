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
        en = 'In a game',
        id = 'Dalam game'
    },
    TextMuteAll = {
        Key = 'TextMuteAll',
        zh_CN = '静音所有',
        en = 'Mute All',
        id = 'Senyapkan Semua'
    },
    TextSetting = {
        Key = 'TextSetting',
        zh_CN = '设置',
        en = 'Graphic Setting',
        id = 'Pengaturan kualitas gambar'
    },
    TextMin = {
        Key = 'TextMin',
        zh_CN = '极低画质',
        en = 'Min',
        id = 'Sangat rendah'
    },
    TextLow = {
        Key = 'TextLow',
        zh_CN = '低画质',
        en = 'Low',
        id = 'Rendah'
    },
    TextMedium = {
        Key = 'TextMedium',
        zh_CN = '中画质',
        en = 'Medium',
        id = 'Medium'
    },
    TextHigh = {
        Key = 'TextHigh',
        zh_CN = '高画质',
        en = 'High',
        id = 'Tinggi'
    },
    TextPopUps = {
        Key = 'TextPopUps',
        zh_CN = '确定要退出吗？',
        en = 'Really leave?',
        id = 'Benar-benar keluar?'
    },
    BtnCancel = {
        Key = 'BtnCancel',
        zh_CN = '取消',
        en = 'Cancel',
        id = 'Batal'
    },
    BtnOk = {
        Key = 'BtnOk',
        zh_CN = '确定',
        en = 'OK',
        id = 'OK'
    },
    TextInviteFb = {
        Key = 'TextInviteFb',
        zh_CN = '已发送邀请',
        en = 'Invitation sent',
        id = 'Undangan dikirim'
    },
    TextAddFb = {
        Key = 'TextAddFb',
        zh_CN = '已发送好友申请',
        en = 'Friend request sent',
        id = 'Permintaan teman terkirim'
    },
    TextRecHigh = {
        Key = 'TextRecHigh',
        zh_CN = '推荐画质',
        en = 'Recommend',
        id = 'Rekomendasi'
    },
    TextRecMedium = {
        Key = 'TextRecMedium',
        zh_CN = '推荐画质',
        en = 'Recommend',
        id = 'Rekomendasi'
    },
    TextRecLow = {
        Key = 'TextRecLow',
        zh_CN = '推荐画质',
        en = 'Recommend',
        id = 'Rekomendasi'
    },
    TextRecMin = {
        Key = 'TextRecMin',
        zh_CN = '推荐画质',
        en = 'Recommend',
        id = 'Rekomendasi'
    }
}

local LocalizationTabSp = {
    TextFriList = {
        Key = 'TextFriList',
        zh_CN = '好友',
        en = 'Friends',
        id = 'Teman'
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
    }
}

local archTab = {
    TextInvite = {
        Key = 'TextInvite',
        zh_CN = '邀请了你',
        en = 'has invited you',
        id = 'telah mengundangmu'
    },
    TextFriInviteOut = {
        Key = 'TextFriInviteOut',
        zh_CN = '邀请',
        en = 'Invite',
        id = 'Undang'
    },
    TextFriInvite = {
        Key = 'TextFriInvite',
        zh_CN = '邀请',
        en = 'Invite',
        id = 'Undang'
    },
    TextFriJoin = {
        Key = 'TextFriJoin',
        zh_CN = '加入',
        en = 'Join',
        id = 'Bergabung'
    },
    BtnInviteOk = {
        Key = 'BtnInviteOk',
        zh_CN = '确定',
        en = 'OK',
        id = 'OK'
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
    for k, v in pairs(_tab) do
        gui[k].Text = v[currLang]
    end
end

function TranslateSp(_tab)
    for _, v in pairs(_tab) do
        M.Kit.Util.Net.Fire_C('TranslateTextEvent', localPlayer, v[currLang], v['Key'])
    end
end

function CreateReadyEventHandler(_tarNode, _type, _invitePlayer)
    if _tarNode == nil then
        return
    end
    if _type == 0 then
        _tarNode.BtnFriInviteOut.TextFriInviteOut.Text = archTab['TextFriInviteOut'][currLang]
        _tarNode.ImgFriMoreBg.BtnFriInvite.TextFriInvite.Text = archTab['TextFriInvite'][currLang]
        _tarNode.ImgFriMoreBg.BtnFriJoin.TextFriJoin.Text = archTab['TextFriJoin'][currLang]
    elseif _type == 1 then
        _tarNode.TextInvite.Text = tostring(_invitePlayer.Name) .. archTab['TextInvite'][currLang]
        _tarNode.BtnInviteOk.Text = archTab['BtnInviteOk'][currLang]
    end
end

--! public method
M.Init = Init
M.ClientReadyEventHandler = ClientReadyEventHandler
M.CreateReadyEventHandler = CreateReadyEventHandler

return M
