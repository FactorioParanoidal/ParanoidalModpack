local rpath = (...):match("(.-)[^%.]+$")
local construct = require(rpath .. "construct")
local  destruct = require(rpath ..  "destruct")


local events = { -- defined
	added = {
		entity = {
			defines.events.on_robot_built_entity,
			defines.events.script_raised_revive,
			defines.events.script_raised_built,
			defines.events.on_built_entity,
		},
	},
	removed = {
		surface = {
			defines.events.on_surface_cleared,
			defines.events.on_surface_deleted,
		},
		chunk = {
			defines.events.on_pre_chunk_deleted,
		},
		entity = {
			defines.events.script_raised_destroy,
			defines.events.on_pre_player_mined_item,
			defines.events.on_robot_pre_mined,
			defines.events.on_entity_died,
		},
		ghost = {
			defines.events.on_pre_ghost_deconstructed,
		},
	},
	gui = {
		opened = {
			defines.events.on_gui_opened,
		},
		clicked = {
			defines.events.on_gui_click,
		},
	},
	trigger = {
		effect = {
			defines.events.on_script_trigger_effect,
		},
	},
	pipette = {
		defines.events.on_player_pipette,
	},
	tick = {
		defines.events.on_tick,
	},
}

local filters = {
	added = construct.filters,
	removed = destruct.filters,
}

local listeners = {
	added = construct.listeners,
	removed = destruct.listeners,
}


return { -- exports
	defined = events,
	filters = filters,
	listeners = listeners,
	construct = construct,
	 destruct =  destruct,
}
