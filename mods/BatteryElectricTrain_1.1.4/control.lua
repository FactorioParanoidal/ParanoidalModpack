require("names")

local function player_print(player, msg)
	local printer = game.players[player] or game
	printer.print(msg)
end


local function on_loc_remove(event) -- entity, player_index
	local burner = event.entity.burner
	local burning = burner.currently_burning

	if not burning then
		return
	end

	local fuel = burning.name:match("^(.+)-full$")

	if not fuel then
		player_print(event.player_index, "Unexpected fuel in locomotive: "..burning.name)
		return
	end

	if burner.burnt_result_inventory.insert({name=fuel.."-empty"}) > 0 then
		burner.currently_burning = nil
	else
		player_print(event.player_index, "You just lost a battery pack because you removed a locomotive with too many discharged battery packs inside.")
	end
end


local function maybe_install_locomotive_handler()
	local function install_handler(event_id, h)
		if h then
			script.on_event(event_id, h, {{filter = "name", name = name_locomotive}})
		else
			script.on_event(event_id, nil, nil)
		end
	end

	local handler = settings.global[setting_return_partial_batteries].value and on_loc_remove

	install_handler(defines.events.on_marked_for_deconstruction,	handler)
	install_handler(defines.events.on_pre_player_mined_item,		handler)
end


local function on_initload()
	script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
		if event.setting == setting_return_partial_batteries then
			maybe_install_locomotive_handler()
		end
	end)

	maybe_install_locomotive_handler()
end

script.on_init(on_initload)
script.on_load(on_initload)
