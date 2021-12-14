--- 多语言工具：根据游戏内语言设置返回对应的语言文本
--- @module Localization Utility, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local M = {}

-- 当前语言
local currLang

--* 常量
local DEFAULT_LANG = 'en' -- 默认语言为英文
local DEBUG_LANG = 'zh_CN'

--- 初始化
function Init()
    currLang = Localization:GetLanguage()

    if string.isnilorempty(currLang) then
        currLang = DEFAULT_LANG
    end

    Debug.Log(string.format('[换装] 当前语言：%s', currLang))
end

--- 将本地语言改成对应的
function Translate(_xls)
    -- 辅助函数
    local translate = function(_data)
        for k, v in pairs(_data) do
            if type(k) == 'string' and string.sub(k, 1, 1) == '_' then
                local newKey = string.sub(k, 2)
                _data[newKey] = M.Xls.I18N[v][currLang]
                if string.isnilorempty(_data[newKey]) then
                    _data[newKey] = string.format('*%s', M.Xls.I18N[v][DEBUG_LANG])
                end
            end
        end
    end

    --TODO: 目前只支持单一主键
    for _, v1 in pairs(_xls) do
        if type(v1) == 'table' then
            translate(v1)
        end
    end
end

--! public method
M.Init = Init
M.Translate = Translate

return M
