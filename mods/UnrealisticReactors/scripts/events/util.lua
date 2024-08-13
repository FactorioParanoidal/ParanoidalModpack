
local function on(listeners, entity, ...)
	local callback = listeners[entity.name]
	if callback then callback(entity, ...) end
end


return { -- exports
	on = on,
}
