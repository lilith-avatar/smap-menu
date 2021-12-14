--- 事件绑定工具
--- @module Event Connects Handler
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Yen Yuan

--- 遍历所有的events,找到module中对应名称的handler,建立Connect
--- @param _eventFolder 事件所在的节点folder
--- @param _module 模块
--- @param _this module的self指针,用于闭包
function LinkConnects(_eventFolder, _module)
    assert(_eventFolder and _module, string.format('[EventUtil] 参数有空值: %s, %s', _eventFolder, _module))
    local events = _eventFolder:GetChildren()
    for _, evt in pairs(events) do
        if string.endswith(evt.Name, 'Event') then
            local handler = _module[evt.Name .. 'Handler']
            if handler ~= nil then
                print('[EventUtil]', _eventFolder, _module.name, evt)
                evt:Connect(handler)
            end
        end
    end
end

--! Public methods
return {
    LinkConnects = LinkConnects
}
