--- 提供一组常用函数，以及对 Lua 标准库的扩展
--- @module Lua global function extension libraries
--- @copyright Lilith Games, Avatar Team

--- 处理对象
--- @param mixed obj Lua 对象
--- @param function method 对象方法
--- @return function
_G.handler = function(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

return 0
