local config = require("features.gas-reservoir.shared")
local M = {}
local events = defines.events
local locale = "paranoidal-gas-reservoir."
local frame_name = "paranoidal_gas_reservoir"
local picker_name = "paranoidal_gas_reservoir_picker"
local tank_names = {config.tank, config.legacy}
local is_gas = {}
for _, name in ipairs(config.gases) do is_gas[name] = true end
local picker_filters

local function allowed(name)
	return is_gas[name] and prototypes.fluid[name] ~= nil
end

local function tank(entity)
	-- player.opened can also be a GUI enum instead of a Lua object.
	if not entity or type(entity) == "number" or entity.object_name ~= "LuaEntity" or not entity.valid then
		return false
	end
	local name = entity.type == "entity-ghost" and entity.ghost_name or entity.name
	return name == config.tank or name == config.legacy
end

local function filter_of(entity)
	local filter = entity.get_fluid_filter(1)
	return filter and filter.name
end

local function tag_gas(tags)
	local gas = tags and tags[config.tag]
	if gas == false or allowed(gas) then return gas end
end

local function configured_gas(entity)
	if entity.type == "entity-ghost" then
		local gas = tag_gas(entity.tags)
		if gas ~= nil then return gas end
	end
	local filter = filter_of(entity)
	if filter == config.sealed then return false end
	if allowed(filter) then return filter end
end

local function contents(entity)
	return entity.get_fluid_segment_fluid(1) or entity.get_fluid(1)
end

-- Changing a tank's filter can discard incompatible contents. Check the whole
-- joined pipeline, not just the tank's share. False means explicitly sealed (e.g. in a blueprint).
local function apply_filter(entity, gas)
	if gas ~= false and not allowed(gas) then return false, "unsupported" end
	local name = gas or config.sealed
	if filter_of(entity) == name then return true end
	if entity.type ~= "entity-ghost" then
		local fluid = contents(entity)
		if fluid and fluid.name ~= name then return false, "drain" end
	end
	if not entity.set_fluid_filter(1, name) then return false, "failed" end
	return true
end

local function frame(player)
	return player.gui.relative[frame_name]
end

local function refresh(panel, entity)
	local filter = filter_of(entity)
	local gas = allowed(filter) and filter or nil
	panel[picker_name].elem_value = gas
	if gas then
		panel.status.caption = {locale .. "selected", prototypes.fluid[gas].localised_name}
	elseif entity.name == config.legacy and filter == nil then
		local fluid = contents(entity)
		panel.status.caption = {locale .. ((fluid and not allowed(fluid.name)) and "legacy-drain" or "legacy-unfiltered")}
	else
		panel.status.caption = {locale .. "choose"}
	end
end

local function refresh_viewers(entity)
	for _, player in pairs(game.connected_players) do
		local panel = frame(player)
		if panel and player.opened == entity then refresh(panel, entity) end
	end
end

local function open_panel(player, entity)
	local panel = frame(player)
	if panel then panel.destroy() end
	if not tank(entity) or entity.type == "entity-ghost" then return end
	if not picker_filters then
		local names = {}
		local visible = prototypes.get_fluid_filtered({{filter = "hidden", invert = true}})
		for _, name in ipairs(config.gases) do
			if visible[name] then names[#names + 1] = name end
		end
		picker_filters = {{filter = "name", name = names}}
	end
	panel = player.gui.relative.add({type = "frame", name = frame_name, direction = "vertical",
		caption = {locale .. "title"}, anchor = {gui = defines.relative_gui_type.pipe_gui,
		position = defines.relative_gui_position.right, names = tank_names}})
	panel.add({type = "label", name = "status"})
	local picker = panel.add({type = "choose-elem-button", name = picker_name, elem_type = "fluid", style = "big_slot_button",
		elem_filters = picker_filters, tooltip = {locale .. "picker-tooltip"}})
	picker.style.size = 80 -- twice the native 40 px slot, in both dimensions
	refresh(panel, entity)
end

local function tell(player, reason)
	if player then player.create_local_flying_text({text = {locale .. reason}, create_at_cursor = true}) end
end

local function configure_from_event(entity, gas, player_index)
	local ok, reason = apply_filter(entity, gas)
	if not ok then
		if player_index then tell(game.get_player(player_index), reason) end
	elseif entity.type == "entity-ghost" then
		local tags = entity.tags or {}
		tags[config.tag] = gas
		entity.tags = tags
	else
		refresh_viewers(entity)
	end
	return ok
end

function M.on_opened(event)
	if event.gui_type == defines.gui_type.entity and tank(event.entity) then
		open_panel(game.get_player(event.player_index), event.entity)
	end
end

function M.on_pick(event)
	local element = event.element
	if not (element.valid and element.name == picker_name) then return end
	local player = game.get_player(event.player_index)
	local panel = frame(player)
	local entity = player.opened
	if not (panel and panel[picker_name] == element and tank(entity) and entity.type ~= "entity-ghost") then return end
	configure_from_event(entity, element.elem_value or false, player.index)
	refresh(panel, entity) -- restore the current icon if the change was refused
end

function M.on_built(event)
	local entity = event.entity
	if not tank(entity) then return end
	local tags = event.tags
	if not tags and entity.type == "entity-ghost" then tags = entity.tags end
	local gas = tag_gas(tags)
	-- Untagged old tanks and blueprints keep the unfiltered prototype's behaviour.
	-- New tanks already start sealed at the prototype level.
	if gas ~= nil then configure_from_event(entity, gas) end
end

function M.on_blueprint(event)
	local blueprint = event.stack
	if not (blueprint and blueprint.valid and blueprint.valid_for_read and blueprint.is_blueprint) then
		blueprint = event.record
	end
	if not (blueprint and blueprint.valid) then return end
	for index, entity in pairs(event.mapping.get()) do
		if tank(entity) then
			local gas = configured_gas(entity)
			blueprint.set_blueprint_entity_tag(index, config.tag, gas)
		end
	end
end

function M.sync()
	picker_filters = nil
	for _, player in pairs(game.players) do open_panel(player, player.opened) end
end

local function on(event, handler, filters)
	local previous = script.get_event_handler(event)
	if previous then
		script.on_event(event, function(e)
			previous(e)
			handler(e)
		end)
	else
		script.on_event(event, handler, filters)
	end
end

function M.install()
	local filters = {}
	for _, name in ipairs(tank_names) do
		filters[#filters + 1] = {filter = "name", name = name}
		filters[#filters + 1] = {filter = "ghost_name", name = name}
	end
	for _, event in ipairs({events.on_built_entity, events.on_robot_built_entity, events.on_space_platform_built_entity,
		events.script_raised_built, events.script_raised_revive}) do
		on(event, M.on_built, filters)
	end
	on(events.on_entity_cloned, function(e) M.on_built({entity = e.destination}) end, filters)
	on(events.on_gui_opened, M.on_opened)
	on(events.on_gui_closed, function(e)
		if not tank(e.entity) then return end
		local panel = frame(game.get_player(e.player_index))
		if panel then panel.destroy() end
	end)
	on(events.on_gui_elem_changed, M.on_pick)
	on(events.on_player_flushed_fluid, function(e)
		if tank(e.entity) then refresh_viewers(e.entity) end
	end)
	on(events.on_player_setup_blueprint, M.on_blueprint)
	on(events.on_blueprint_settings_pasted, function(e)
		local entity = e.entity
		if not tank(entity) then return end
		local tags = e.tags
		if entity.type == "entity-ghost" then tags = entity.tags end
		local gas = tag_gas(tags)
		if gas ~= nil then configure_from_event(entity, gas, e.player_index) end
	end)
	on(events.on_entity_settings_pasted, function(e)
		if not (tank(e.source) and tank(e.destination)) then return end
		local gas = configured_gas(e.source)
		if gas ~= nil then configure_from_event(e.destination, gas, e.player_index) end
	end)
end

return M
