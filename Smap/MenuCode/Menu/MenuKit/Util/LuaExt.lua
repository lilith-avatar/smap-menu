--- Lua string 常用方法扩展
--- @module Lua string function extension libraries
--- @copyright Lilith Games, Avatar Team

--- 判断字符串是否为空或者长度为零
--- @param @string 输入的字符串
string.isnilorempty = string.isnilorempty or function(inputStr)
        return inputStr == nil or inputStr == ''
    end

--- 用指定字符或字符串分割输入字符串，返回包含分割结果的数组
--- @param @string input 输入的字符串
--- @param @string delimiter 分隔符
--- @return array
--- @usage example #1
---      local input = "Hello,World"
---      local res = string.split(input, ",")
---      >> res = {"Hello", "World"}
--- @usage example #2
---      local input = "Hello-+-World-+-Quick"
---      local res = string.split(input, "-+-")
---      >> res = {"Hello", "World", "Quick"}
string.split = string.split or function(input, delimiter)
        input = tostring(input)
        delimiter = tostring(delimiter)
        if (delimiter == '') then
            return false
        end
        local pos, arr = 0, {}
        -- for each divider found
        for st, sp in function()
            return string.find(input, delimiter, pos, true)
        end do
            table.insert(arr, string.sub(input, pos, st - 1))
            pos = sp + 1
        end
        table.insert(arr, string.sub(input, pos))
        return arr
    end

--- 检查字符串是否以指定字符串结尾
--- @param @string target
--- @param @string start
--- @return @boolean
string.endswith = string.endswith or function(str, ending)
        return ending == '' or str:sub(-(#ending)) == ending
    end

--- 打印table中的所有内容
--- @param data table
--- @param @boolean showMetatable 是否显示元表
table.dump = table.dump or function(data, showMetatable)
        local result, tab = {}, '    '
        local function _dump(data, showMetatable, lastCount)
            if type(data) ~= 'table' then
                if type(data) == 'string' then
                    table.insert(result, '"')
                    table.insert(result, data)
                    table.insert(result, '"')
                else
                    table.insert(result, tostring(data))
                end
            else
                --Format
                local count = lastCount or 0
                count = count + 1
                table.insert(result, '{\n')
                --Metatable
                if showMetatable then
                    for _ = 1, count do
                        table.insert(result, tab)
                    end
                    local mt = getmetatable(data)
                    table.insert(result, '"__metatable" = ')
                    _dump(mt, showMetatable, count)
                    table.insert(result, ',\n')
                end
                --Key
                for key, value in pairs(data) do
                    for _ = 1, count do
                        table.insert(result, tab)
                    end
                    if type(key) == 'string' then
                        table.insert(result, '"')
                        table.insert(result, key)
                        table.insert(result, '" = ')
                    elseif type(key) == 'number' then
                        table.insert(result, '[')
                        table.insert(result, key)
                        table.insert(result, '] = ')
                    else
                        table.insert(result, tostring(key))
                    end
                    _dump(value, showMetatable, count)
                    table.insert(result, ',\n')
                end
                --Format
                for i = 1, lastCount or 0 do
                    table.insert(result, tab)
                end
                table.insert(result, '}')
            end
            --Format
            if not lastCount then
                table.insert(result, '\n')
            end
        end
        _dump(data, showMetatable, 0)

        --- print('dump: \n' .. table.concat(result))
        return 'dump: \n' .. table.concat(result)
    end

return 0
