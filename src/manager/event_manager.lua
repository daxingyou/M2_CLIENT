local event_manager = {}

local handler_id = 0
local handler_map = {}

function event_manager:registerEvent(event_name, callback)
    if not handler_map[event_name] then
        handler_map[event_name] = {}
    end

    handler_id = handler_id + 1
    handler_map[event_name][handler_id] = {callback = callback}
    return handler_id
end

function event_manager:unregisterEvent(event_name, handler_id)
    local handlers = handler_map[event_name]
    if handlers then
        handlers[handler_id] = nil
    end
end

function event_manager:unregisterAll(event_name)
    handler_map[event_name] = nil
end

function event_manager:dispatchEvent(event_name, ...)
    local handlers = handler_map[event_name]
    if handlers then
        for _, handler in pairs(handlers) do
            handler.callback(...)
        end
    end
end

return event_manager