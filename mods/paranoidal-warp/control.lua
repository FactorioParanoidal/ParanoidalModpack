-- Warp drive, jumps between the sector gates and home orbit, the window next to the drive, the BnL logo on every
-- platform hub (Space Age branch, ПР-077 stage 2); the comfort field, demons, void shield and red alert are in
-- scripts/ship.lua (stage 3); warp years and BnL bills in scripts/years.lua (stage 4); the rift at the first rocket in
-- scripts/rift.lua (stage 5). Without Space Age nothing runs.
if not script.active_mods["space-age"] then return end

local shared = require("shared")
local ship = require("scripts.ship")
local years = require("scripts.years")
local rift = require("scripts.rift")

local SLOW = 10 -- ticks between countdown/window updates
local HUBS = 300 -- ticks between hub logo checks
local GUI = "paranoidal_warp_frame"
local COLOR_AUTO = {r = 0.55, g = 0.8, b = 1}
local COLOR_BAD = {r = 1, g = 0.5, b = 0.4}
local LOGO = "bnl-logo-weathered" -- sprite of zzzparanoidal-start-bnl

local jump_points = {}
for _, name in ipairs(shared.jump_points()) do jump_points[name] = true end

-- storage.drives[unit_number] = {entity, state = "idle"|"spinning", target, platform, from, paused_before, done, text,
-- said}; storage.spinning[unit_number] = true; storage.hubs[hub unit_number] = render object;
-- storage.players[index] = {frame, drive, key}.
local function state()
	storage.drives = storage.drives or {}
	storage.spinning = storage.spinning or {}
	storage.hubs = storage.hubs or {}
	storage.players = storage.players or {}
	return storage
end

local function location_name(name)
	local prototype = prototypes.space_location[name]
	return prototype and prototype.localised_name or name
end

local function charges(entity)
	local inventory = entity.get_inventory(defines.inventory.crafter_input)
	return inventory and inventory.get_item_count(shared.charge) or 0
end

local function seconds_left(entity)
	local speed = entity.crafting_speed
	if not speed or speed <= 0 then speed = 1 end
	return math.ceil((1 - entity.crafting_progress) * prototypes.recipe[shared.jump_recipe].energy / speed)
end

local function say(force, message, color)
	force.print(message, {color = color or COLOR_AUTO})
end

local function unlocked(force, name)
	return name == shared.home or force.is_space_location_unlocked(name)
end

-- Why the drive cannot jump now (a localised string), or nil.
local function problem(record)
	local entity = record.entity
	local platform = entity.surface.platform
	if not platform then return {"paranoidal-warp.status-not-platform"} end
	local here = platform.space_location
	if not here then return {"paranoidal-warp.status-in-flight"} end
	if not jump_points[here.name] then return {"paranoidal-warp.status-not-jump-point"} end
	if not record.target or record.target == here.name or not unlocked(entity.force, record.target) then
		return {"paranoidal-warp.status-no-target"}
	end
	if entity.crafting_progress == 0 and charges(entity) == 0 then return {"paranoidal-warp.status-no-charge"} end
	return nil
end

-- Drives ---------------------------------------------------------------------------------------------------------

-- One drive and one comfort field generator per platform (user 2026-11-07): a second one goes back where it came
-- from. Returns true when the entity was removed.
local function refuse_second(entity, player)
	local surface = entity.surface
	local platform = surface.platform
	if not platform then return false end
	for _, other in pairs(surface.find_entities_filtered({name = entity.name})) do
		if other ~= entity then
			local hub = platform.hub
			local inventory = (player and player.get_main_inventory())
				or (hub and hub.valid and hub.get_inventory(defines.inventory.hub_main)) or nil
			if player then player.print({"paranoidal-warp.one-per-platform", entity.localised_name}, {color = COLOR_BAD}) end
			entity.mine({inventory = inventory, force = true, raise_destroyed = true})
			return true
		end
	end
	return false
end

local function register(entity, player)
	if not (entity and entity.valid) then return end
	if entity.name == shared.field then
		refuse_second(entity, player)
		return
	end
	if entity.name ~= shared.drive or refuse_second(entity, player) then return end
	entity.disabled_by_script = true -- an idle drive never crafts by itself
	state().drives[entity.unit_number] = {entity = entity, state = "idle"}
end

local function on_built(event)
	local player = event.player_index and game.get_player(event.player_index) or nil
	register(event.entity or event.destination, player)
end

local function stop(record, reason)
	local entity = record.entity
	if entity and entity.valid then entity.disabled_by_script = true end
	local platform = record.platform
	if platform and platform.valid and record.paused_before ~= nil then platform.paused = record.paused_before end
	if record.text and record.text.valid then record.text.destroy() end
	record.text, record.paused_before, record.said = nil, nil, nil
	record.state = "idle"
	if entity and entity.valid and storage.spinning then storage.spinning[entity.unit_number] = nil end
	if reason and entity and entity.valid then say(entity.force, reason, COLOR_BAD) end
end

local function start(record, player)
	local reason = problem(record)
	if reason then
		if player then player.print(reason, {color = COLOR_BAD}) end
		return
	end
	local entity = record.entity
	local platform = entity.surface.platform
	record.state = "spinning"
	record.platform = platform
	record.from = platform.space_location.name
	-- The platform waits at the gate while the drive spins up (its schedule would take it away).
	record.paused_before = platform.paused
	platform.paused = true
	record.done = entity.products_finished
	record.said = {}
	entity.disabled_by_script = false
	record.text = rendering.draw_text({text = "", surface = entity.surface, target = {entity = entity, offset = {0, -3}},
		color = COLOR_AUTO, scale = 3, alignment = "center", vertical_alignment = "middle"})
	storage.spinning[entity.unit_number] = true
	say(entity.force, {"paranoidal-warp.auto-start", location_name(record.target), seconds_left(entity)})
	if record.target ~= shared.home and not ship.has_field(platform) then
		say(entity.force, {"paranoidal-warp.auto-no-field"}, COLOR_BAD)
	end
	entity.surface.play_sound({path = "utility/new_objective", position = entity.position})
end

-- A white-violet flash over the whole platform, fading out.
local function flash(surface, position)
	for _, step in ipairs({{0.8, 10}, {0.45, 25}, {0.2, 45}}) do
		local a = step[1]
		rendering.draw_rectangle({color = {r = 0.85 * a, g = 0.75 * a, b = a, a = a}, filled = true,
			left_top = {position.x - 160, position.y - 100}, right_bottom = {position.x + 160, position.y + 100},
			surface = surface, time_to_live = step[2], render_layer = "cursor"})
	end
end

-- The machine finishes the craft during its own update and may start the next one in the same tick, taking the next
-- charge; the check runs one tick later. Such a craft (at most two ticks in) is undone: the charge goes back.
local function refund_started_craft(entity)
	local progress = entity.crafting_progress
	local per_tick = (entity.crafting_speed or 1) / (prototypes.recipe[shared.jump_recipe].energy * 60)
	if progress > 0 and progress <= per_tick * 2 + 1e-9 then
		local _, quality = entity.get_recipe()
		local inventory = entity.get_inventory(defines.inventory.crafter_input)
		if inventory and inventory.insert({name = shared.charge, count = 1,
			quality = quality and quality.name or "normal"}) == 1 then
			entity.crafting_progress = 0
		end
	end
end

local function jump(record)
	local entity, platform, target = record.entity, record.platform, record.target
	local ok, err = pcall(function() platform.space_location = target end)
	stop(record)
	refund_started_craft(entity)
	if not ok then
		say(entity.force, {"paranoidal-warp.jump-failed", tostring(err)}, COLOR_BAD)
		return
	end
	local hub = platform.hub
	flash(entity.surface, (hub and hub.valid and hub.position) or entity.position)
	entity.surface.play_sound({path = "utility/research_completed", position = entity.position})
	if target == shared.home then
		say(entity.force, {"paranoidal-warp.auto-home"})
	else
		say(entity.force, {"paranoidal-warp.auto-arrived", location_name(target)})
	end
	years.on_jump(platform, target) -- warp years and the BnL bill (stage 4)
end

-- Every tick, only spinning drives: the jump right after the craft finishes (before the next charge goes far).
local function check_spinning()
	local spinning = storage.spinning
	if not (spinning and next(spinning)) then return end
	for id in pairs(spinning) do
		local record = storage.drives[id]
		local entity = record and record.entity
		if not (entity and entity.valid) then
			if record then stop(record) end
			spinning[id] = nil
			storage.drives[id] = nil
		elseif not (record.platform and record.platform.valid) then
			stop(record)
		elseif entity.products_finished > record.done then
			jump(record)
		end
	end
end

local function update_countdowns()
	for id in pairs(storage.spinning or {}) do
		local record = storage.drives[id]
		local entity = record and record.entity
		if entity and entity.valid and record.state == "spinning" and record.platform and record.platform.valid then
			local here = record.platform.space_location
			if not here or here.name ~= record.from then
				stop(record, {"paranoidal-warp.auto-cancel-moved"})
			elseif not unlocked(entity.force, record.target) then
				stop(record, {"paranoidal-warp.status-no-target"})
			else
				local left = seconds_left(entity)
				if record.text and record.text.valid then record.text.text = tostring(left) end
				for _, mark in ipairs({10, 3}) do
					if left <= mark and not record.said[mark] then
						record.said[mark] = true
						say(entity.force, {"paranoidal-warp.auto-" .. mark})
					end
				end
				if left <= 5 and not record.said["beep" .. left] then
					record.said["beep" .. left] = true
					entity.surface.play_sound({path = "utility/alert_destroyed", position = entity.position,
						volume_modifier = 0.6})
				end
			end
		end
	end
	-- Idle drives stay switched off (a robot or another mod may have touched them).
	for id, record in pairs(storage.drives or {}) do
		local entity = record.entity
		if not (entity and entity.valid) then
			storage.drives[id] = nil
		elseif record.state ~= "spinning" and not entity.disabled_by_script then
			entity.disabled_by_script = true
		end
	end
end

-- Hub: the bridge of the Axiom-7 with the BnL logo --------------------------------------------------------------

local function decorate_hubs()
	if not helpers.is_valid_sprite_path(LOGO) then return end
	local s = state()
	for index, logo in pairs(s.hubs) do
		if not logo.valid then s.hubs[index] = nil end
	end
	for _, force in pairs(game.forces) do
		for _, platform in pairs(force.platforms) do
			local hub = platform.valid and platform.hub
			if hub and hub.valid and not s.hubs[hub.unit_number] then
				s.hubs[hub.unit_number] = rendering.draw_sprite({sprite = LOGO, surface = platform.surface,
					target = {entity = hub, offset = {0, 1.4}}, x_scale = 0.6, y_scale = 0.6,
					tint = {r = 0.9, g = 0.9, b = 0.9, a = 0.9}, render_layer = "higher-object-under"})
			end
		end
	end
end

-- Window next to the drive --------------------------------------------------------------------------------------

local function player_data(player)
	local s = state()
	local data = s.players[player.index]
	if not data then
		data = {}
		s.players[player.index] = data
	end
	return data
end

local function build_window(player, data)
	local relative = player.gui.relative
	if relative[GUI] then relative[GUI].destroy() end
	local frame = relative.add({type = "frame", name = GUI, caption = {"paranoidal-warp.window-title"},
		direction = "vertical", anchor = {gui = defines.relative_gui_type.assembling_machine_gui,
			position = defines.relative_gui_position.right, name = shared.drive}})
	local inner = frame.add({type = "frame", name = "inner", style = "inside_shallow_frame_with_padding",
		direction = "vertical"})
	inner.style.width = 300
	inner.add({type = "label", name = "here", style = "caption_label"})
	inner.add({type = "label", name = "years"})
	local bill = inner.add({type = "label", name = "bill"})
	bill.style.single_line = false
	bill.style.maximal_width = 276
	local caption = inner.add({type = "label", caption = {"paranoidal-warp.targets"}})
	caption.style.top_margin = 8
	local targets = inner.add({type = "flow", name = "targets", direction = "vertical"})
	targets.style.vertical_spacing = 4
	targets.style.top_margin = 4
	local status = inner.add({type = "label", name = "status"})
	status.style.single_line = false
	status.style.top_margin = 8
	status.style.maximal_width = 276
	local row = inner.add({type = "flow", name = "buttons", direction = "horizontal"})
	row.style.top_margin = 8
	row.add({type = "empty-widget"}).style.horizontally_stretchable = true
	row.add({type = "button", name = "paranoidal_warp_cancel", caption = {"paranoidal-warp.cancel"},
		tooltip = {"paranoidal-warp.cancel-tooltip"}, style = "red_button"})
	row.add({type = "button", name = "paranoidal_warp_jump", caption = {"paranoidal-warp.jump"},
		tooltip = {"paranoidal-warp.jump-tooltip"}, style = "green_button"})
	data.frame, data.key = frame, nil
	return frame
end

local function refresh_window(player)
	local data = storage.players and storage.players[player.index]
	local frame = data and data.frame
	if not (frame and frame.valid and data.drive) then return end
	local record = storage.drives[data.drive]
	local entity = record and record.entity
	if not (entity and entity.valid) then return end
	local inner = frame.inner
	local platform = entity.surface.platform
	local here = platform and platform.space_location
	inner.here.caption = here and {"paranoidal-warp.here", location_name(here.name)} or {"paranoidal-warp.here-flight"}
	if platform then
		local chronometer, bill, overdue = years.window_lines(platform)
		inner.years.caption = chronometer
		inner.bill.caption = bill or {"paranoidal-warp.bill-none"}
		inner.bill.style.font_color = overdue and COLOR_BAD or {r = 1, g = 1, b = 1}
	end

	-- Jump targets: home orbit and the open sector gates except where the ship is; rebuilt only when the set changes.
	local list = {}
	for _, name in ipairs(shared.jump_points()) do
		if (not here or name ~= here.name) and unlocked(entity.force, name) then list[#list + 1] = name end
	end
	local key = table.concat(list, ",")
	local flow = inner.targets
	if data.key ~= key then
		flow.clear()
		for _, name in ipairs(list) do
			local prototype = prototypes.space_location[name]
			flow.add({type = "radiobutton", caption = location_name(name), state = false,
				tooltip = prototype and prototype.localised_description or nil, tags = {paranoidal_warp_target = name}})
		end
		data.key = key
	end
	local spinning = record.state == "spinning"
	for _, child in pairs(flow.children) do
		child.state = child.tags.paranoidal_warp_target == record.target
		child.enabled = not spinning
	end

	local reason = not spinning and problem(record) or nil
	local status = inner.status
	if spinning then
		status.caption = entity.status == defines.entity_status.low_power and {"paranoidal-warp.status-low-power",
			seconds_left(entity)} or {"paranoidal-warp.status-spinning", seconds_left(entity)}
		status.style.font_color = COLOR_AUTO
	elseif reason then
		status.caption = reason
		status.style.font_color = COLOR_BAD
	elseif entity.crafting_progress > 0 then
		status.caption = {"paranoidal-warp.status-ready-resume", math.floor(entity.crafting_progress * 100)}
		status.style.font_color = {r = 1, g = 1, b = 1}
	else
		status.caption = {"paranoidal-warp.status-ready"}
		status.style.font_color = {r = 1, g = 1, b = 1}
	end
	inner.buttons.paranoidal_warp_jump.visible = not spinning
	inner.buttons.paranoidal_warp_jump.enabled = reason == nil
	inner.buttons.paranoidal_warp_cancel.visible = spinning
end

local function refresh_open_windows()
	for index, data in pairs(storage.players or {}) do
		if data.drive and data.frame and data.frame.valid then
			local player = game.get_player(index)
			if player and player.connected then refresh_window(player) end
		end
	end
end

local function record_of(player)
	local data = storage.players and storage.players[player.index]
	return data and data.drive and storage.drives[data.drive] or nil
end

-- Events ---------------------------------------------------------------------------------------------------------

local function rescan()
	local s = state()
	for _, surface in pairs(game.surfaces) do
		if surface.platform then
			for _, entity in pairs(surface.find_entities_filtered({name = shared.drive})) do
				if not s.drives[entity.unit_number] then
					entity.disabled_by_script = true
					s.drives[entity.unit_number] = {entity = entity, state = "idle"}
				end
			end
		end
	end
end

script.on_init(function()
	rescan()
	decorate_hubs()
end)

script.on_configuration_changed(function()
	rescan()
	-- The window is rebuilt on the next open (its layout may have changed).
	for index, data in pairs(storage.players) do
		if data.frame and data.frame.valid then data.frame.destroy() end
		storage.players[index] = {}
	end
	decorate_hubs()
end)

local filter = {{filter = "name", name = shared.drive}, {filter = "name", name = shared.field}}
for _, name in ipairs({"on_built_entity", "on_robot_built_entity", "on_space_platform_built_entity",
	"script_raised_built", "script_raised_revive", "on_entity_cloned"}) do
	script.on_event(defines.events[name], on_built, filter)
end

script.on_event(defines.events.on_tick, function()
	check_spinning()
	rift.tick()
end)
script.on_event(defines.events.on_rocket_launched, rift.on_rocket_launched)
script.on_nth_tick(SLOW, function()
	update_countdowns()
	refresh_open_windows()
	ship.animate()
end)
script.on_nth_tick(60, ship.update)
script.on_nth_tick(5, ship.shield_scan)
script.on_event(defines.events.on_entity_damaged, ship.on_damaged, {{filter = "damage-type", type = "impact"}})
for _, name in ipairs({"on_player_mined_tile", "on_robot_mined_tile", "on_space_platform_mined_tile"}) do
	script.on_event(defines.events[name], ship.on_tile_mined)
end
script.on_nth_tick(HUBS, decorate_hubs)

script.on_event(defines.events.on_gui_opened, function(event)
	local entity = event.entity
	if not (entity and entity.valid and entity.name == shared.drive) then return end
	local player = game.get_player(event.player_index)
	if not storage.drives[entity.unit_number] then register(entity) end
	if not storage.drives[entity.unit_number] then return end
	local data = player_data(player)
	if not (data.frame and data.frame.valid) then build_window(player, data) end
	data.drive, data.key = entity.unit_number, nil
	refresh_window(player)
end)

script.on_event(defines.events.on_gui_closed, function(event)
	local entity = event.entity
	if entity and entity.valid and entity.name == shared.drive then
		local data = storage.players[event.player_index]
		if data then data.drive = nil end
	end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
	local element = event.element
	local target = element.valid and element.tags and element.tags.paranoidal_warp_target
	if not target then return end
	local player = game.get_player(event.player_index)
	local record = record_of(player)
	if record and record.state ~= "spinning" then record.target = target end
	refresh_window(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	if not (element.valid and (element.name == "paranoidal_warp_jump" or element.name == "paranoidal_warp_cancel")) then
		return
	end
	local player = game.get_player(event.player_index)
	local record = record_of(player)
	if not (record and record.entity and record.entity.valid) then return end
	if element.name == "paranoidal_warp_jump" then
		if record.state ~= "spinning" then start(record, player) end
	elseif record.state == "spinning" then
		stop(record, {"paranoidal-warp.auto-cancel-player"})
	end
	refresh_window(player)
end)

-- For the local autotest only (test-runs): the same actions the window performs.
remote.add_interface("paranoidal-warp", {
	select_target = function(unit_number, target)
		local record = storage.drives[unit_number]
		if record and record.state ~= "spinning" then record.target = target end
		return record ~= nil
	end,
	jump = function(unit_number)
		local record = storage.drives[unit_number]
		if record and record.state ~= "spinning" then start(record) end
		return record and record.state or nil
	end,
	problem = function(unit_number)
		local record = storage.drives[unit_number]
		return record and problem(record) or nil
	end,
	-- Stage 3: field strength, demons, alert reasons, shield energy of a platform (by index).
	status = function(platform_index)
		return ship.status(platform_index)
	end,
	-- Stage 4: warp years, open bills and the field cap of a platform (by index); expire_bills makes them due now.
	years_status = function(platform_index)
		local platform
		for _, force in pairs(game.forces) do
			for _, p in pairs(force.platforms) do
				if p.index == platform_index then platform = p end
			end
		end
		return platform and years.status(platform) or nil
	end,
	-- Stage 5: the rift scene of a force (done, running, what it left).
	rift_status = function(force_index)
		return rift.status(force_index)
	end,
	expire_bills = function(platform_index)
		for _, force in pairs(game.forces) do
			for _, p in pairs(force.platforms) do
				if p.index == platform_index then years.expire(p) end
			end
		end
	end,
})
