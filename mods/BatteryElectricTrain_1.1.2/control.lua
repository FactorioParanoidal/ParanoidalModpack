require("names")

local function check_locomotive(event)	-- entity, player_index
	local burner = event.entity.burner
	local burning = burner.currently_burning

	if not burning then
		return
	end

	local fuel = burning.name:match("^(.+)-full$")

	if not fuel then
		game.print("Unexpected fuel in locomotive: "..burning.name)
		return
	end

	if burner.burnt_result_inventory.insert({name=fuel.."-empty"}) > 0 then
		burner.currently_burning = nil
	else
		local printer = game.players[event.player_index]
		if not printer then
			printer = game
		end
		printer.print("You just lost a battery pack because you removed a locomotive with too many discharged battery packs inside.")
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

	local handler = nil

	if settings.global[setting_return_partial_batteries].value then
		handler = check_locomotive
	end

	install_handler(defines.events.on_marked_for_deconstruction,	handler)
	install_handler(defines.events.on_pre_player_mined_item,		handler)
end


local function settings_handler(event)
	if event.setting == setting_return_partial_batteries then
		maybe_install_locomotive_handler()
	end
end


local function on_initload()
	script.on_event(defines.events.on_runtime_mod_setting_changed, settings_handler)

	maybe_install_locomotive_handler()
end

script.on_init(on_initload)
script.on_load(on_initload)
