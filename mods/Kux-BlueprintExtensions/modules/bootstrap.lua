local function init_globals()
    storage.playerdata = storage.playerdata or {}
end

local function on_init()
	-- FIXME: Update all gui and shortcut bars.
	init_globals()
end

local function on_configuration_changed()
	-- FIXME: Update all gui and shortcut bars.
	init_globals()
end

EventDistributor.register("on_init",on_init)
EventDistributor.register("on_configuration_changed",on_configuration_changed)

