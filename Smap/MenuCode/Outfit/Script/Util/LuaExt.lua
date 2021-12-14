--- Lua table 常用方法扩展
--- @script Lua table function extension libraries
--- @copyright Lilith Games, Avatar Team

--- 判断字符串是否为空或者长度为零
--- @param @string 输入的字符串
string.isnilorempty = string.isnilorempty or function(inputStr)
        return inputStr == nil or inputStr == ''
    end

--- 清空表格
--- @param table
table.clear = table.clear or function(t)
        if t ~= nil and type(t) == 'table' then
            for k, _ in pairs(t) do
                t[k] = nil
            end
        end
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

--- 字符串化table中的所有内容
--- @param _tbl table
--- @author Yuancheng Zhang
table.stringfy = table.stringfy or function(_tbl)
        local result = {}
        local function _stringfy(_t, _lastCount)
            if type(_t) ~= 'table' then
                if type(_t) == 'string' then
                    table.insert(result, '"')
                    table.insert(result, _t)
                    table.insert(result, '"')
                else
                    table.insert(result, tostring(_t))
                end
            else
                --Format
                local cnt = _lastCount or 0
                cnt = cnt + 1
                table.insert(result, '{')
                --Key
                for key, value in pairs(_t) do
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

                    _stringfy(value, cnt)

                    if next(_t, key) ~= nil then
                        table.insert(result, ',')
                    end
                end

                table.insert(result, '}')
            end
        end
        _stringfy(_tbl, 0)

        return table.concat(result)
    end

--- Lua数据结构：Stack（栈）
-- @module Lua data structure: stack
-- @copyright Lilith Games, Avatar Team
-- @author Chengzhi

--- 数据结构 栈
-- @usage example
-- local myStack = Stack:New()
-- myStack:Push("a")
-- myStack:Push("b")
-- myStack:Push("c")
-- myStack:PrintElement()
-- print(myStack:Pop())
-- myStack:PrintElement()
-- myStack:Clear()
-- myStack:PrintElement()
local Stack = {}

function Stack:New()
    local inst = {
        _last = 0,
        _stack = {}
    }
    setmetatable(inst, {__index = self})

    return inst
end

function Stack:IsEmpty()
    if self._last == 0 then
        return true
    end
    return false
end

function Stack:Push(inElement)
    self._last = self._last + 1
    self._stack[self._last] = inElement
end

function Stack:Pop()
    if self:IsEmpty() then
        Debug.LogError('Error: the stack is empty')
    end
    local value = self._stack[self._last]
    self._stack[self._last] = nil
    self._last = self._last - 1
    return value
end

function Stack:Exists(element, compairFunc)
    if compairFunc == nil then
        compairFunc = function(a, b)
            return a == b
        end
    end
    for i = self._last, 1, -1 do
        if compairFunc(element, self._stack[i]) then
            return i
        end
    end
    return -1
end

function Stack:RemoveAt(index)
    if index < 1 or index > self._last then
        return
    end
    table.remove(self._stack, index)
    self._last = self._last - 1
end

function Stack:Clear()
    self._stack = nil
    self._stack = {}
    self._last = 0
end

function Stack:Size()
    return self._last
end

function Stack:PrintElement()
    local str = '{'
    for i = self._last, 1, -1 do
        str = str .. tostring(self._stack[i]) .. ','
    end
    str = str .. '}'
    Debug.Log(str)
end

_G.Stack = _G.Stack or Stack

return 0
