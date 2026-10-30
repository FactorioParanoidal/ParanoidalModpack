-- RocketExplosions2 (Paranoidal fork of darkfrei's Rocket Explosions): every launch order may fail.
--
-- Success chance of a launch (decided when the launch is ordered):
--   base failure  = default chance * (0.1*a + 0.1*b + 0.8*a*b)
--   a = research factor ^ researched levels of "Rocket failure revision"
--   b = launch factor ^ experience of the force (successful launches + failed launches * failure share)
--   success       = min(1, (1 - base failure) * (1 + silo bonus) ^ successful launches of this place
--                          + quality bonus * quality steps of the silo above normal)
-- The launches of a place are kept per surface position: they stay when the silo is thrown back to a
-- construction site and rebuilt there.
--
-- A failure is carried out on the next tick. The first failure of a force is nuclear; later failures are
-- nuclear, a big blast or an accident, the heavier outcomes getting rarer with every failure:
--   nuclear  - atomic rocket on the silo; the silo becomes a stage 4 construction site of
--              Rocket-Silo-Construction (same quality, launches of the place kept, modules thrown out
--              on the ground around it, marked for deconstruction);
--   blast    - big explosion with fires and burning debris; the silo becomes a stage 4 site (as above);
--   accident - the rocket breaks up: burning debris flies around, the silo stays.
-- The site or silo keeps 2-15% of its health and cannot be damaged until the blast waves have passed and
-- no fire burns within 16 tiles (at most 10 minutes): a burning ground fire would otherwise finish it, and
-- a lost site or silo leaves a ghost nothing can build.
-- Launches on Blueprint Sandboxes surfaces never fail and count nothing.
--
-- storage.forces[force index] = {failures, nuclear, blast, accident, won, forced}
-- storage.sites["surface:x:y"] = {launches, perfect}
-- storage.silos[unit number]   = {entity, label}  (rocket silos with a reliability label)
-- storage.pending              = scheduled jobs {tick, action, ...}; on_tick is registered only while
--                                there are jobs.

local REVISION = "rocket-failure-revision"
local RSC = "RocketSiloCon"
local PROTECT_TICKS = 240
local FIRE_CHECK_TICKS = 120
local FIRE_RADIUS = 16
local PROTECT_MAX_TICKS = 36000
local ALERT_TICKS = 1800
local HEALTH_MIN, HEALTH_MAX = 0.02, 0.15
local GUI = "re2_reliability"
-- number of random lines per message kind in locale (re2-quip.<kind>-N)
local QUIPS = {
	nuclear = 8, blast = 8, accident = 8, success = 10, first = 4, perfect = 4, rollback = 5,
}
local DEBRIS = 6

local function setting(name)
	return settings.global[name].value
end

local function percent(value)
	return string.format("%.1f%%", value * 100)
end

local function gps(surface, position)
	return string.format("[gps=%.1f,%.1f,%s]", position.x, position.y, surface.name)
end

local function quip(kind)
	return {"re2-quip." .. kind .. "-" .. math.random(QUIPS[kind])}
end

---------------------------------------------------------------------------------------------------
-- State

local function init_storage()
	storage.forces = storage.forces or {}
	storage.sites = storage.sites or {}
	storage.silos = storage.silos or {}
	storage.pending = storage.pending or {}
end

local function force_data(force)
	local data = storage.forces[force.index]
	if not data then
		data = {failures = 0, nuclear = 0, blast = 0, accident = 0}
		storage.forces[force.index] = data
	end
	return data
end

local function site_key(surface, position)
	return string.format("%d:%.1f:%.1f", surface.index, position.x, position.y)
end

local function site_data(surface, position, create)
	local key = site_key(surface, position)
	local data = storage.sites[key]
	if not data and create then
		data = {launches = 0}
		storage.sites[key] = data
	end
	return data
end

local function in_sandbox(entity)
	return string.find(entity.surface.name, "^bpsb%-lab%-") ~= nil
		or string.find(entity.force.name, "^bpsb%-sb%-") ~= nil
end

-- Steps above normal along the "next" chain of qualities; defects and unknown qualities count 0.
local quality_steps
local function quality_step(quality)
	if not quality_steps then
		quality_steps = {}
		local seen, step = {}, 0
		local current = prototypes.quality["normal"]
		while current and not seen[current.name] do
			seen[current.name] = true
			quality_steps[current.name] = step
			step = step + 1
			current = current.next
		end
	end
	return quality_steps[quality.name] or 0
end

-- Highest finished level of rocket-failure-revision, -2 ... -6 and the infinite -7.
local function revision_level(force)
	local technologies = force.technologies
	local first = technologies[REVISION]
	if not (first and first.researched) then
		return 0
	end
	local level = 1
	local index = 2
	while true do
		local technology = technologies[REVISION .. "-" .. index]
		if not technology then
			break
		end
		if technology.researched then
			level = math.max(level, technology.prototype.max_level)
		else
			-- level of an unfinished technology = the level in research; the one before it is finished
			level = math.max(level, technology.level - 1)
			break
		end
		index = index + 1
	end
	return level
end

-- Shares of the outcomes of a failure, by the failures the force had before it.
local function outcome_shares(failures)
	if failures <= 0 then
		return {nuclear = 1, blast = 0, accident = 0}
	end
	local nuclear = math.max(0.03, 0.5 ^ failures)
	local blast = (1 - nuclear) * math.max(0.25, 0.9 - 0.1 * failures)
	return {nuclear = nuclear, blast = blast, accident = 1 - nuclear - blast}
end

-- Everything that makes up the success chance of a launch from this silo.
local function reliability(silo)
	local force = silo.force
	local data = force_data(force)
	local level = revision_level(force)
	local successes = force.rockets_launched
	local experience = successes + data.failures * setting("re-failure-experience") / 100
	local a = (setting("re-research-factor") / 100) ^ level
	local b = (setting("re-launch-factor") / 100) ^ experience
	local base_failure = setting("re-default-failure-chance") / 100 * (0.1 * a + 0.1 * b + 0.8 * a * b)
	local site = site_data(silo.surface, silo.position)
	local launches = site and site.launches or 0
	local multiplier = (1 + setting("re-silo-bonus") / 100) ^ launches
	local step = quality_step(silo.quality)
	local quality_bonus = step * setting("re-quality-bonus") / 100
	local success = math.min(1, (1 - base_failure) * multiplier + quality_bonus)
	return {
		level = level,
		successes = successes,
		failures = data.failures,
		experience = experience,
		base_success = 1 - base_failure,
		launches = launches,
		multiplier = multiplier,
		quality = silo.quality.name,
		step = step,
		quality_bonus = quality_bonus,
		success = success,
		shares = outcome_shares(data.failures),
	}
end

---------------------------------------------------------------------------------------------------
-- Visibility: label over every rocket silo, a panel next to the silo window

local function label_color(success)
	if success >= 1 then
		return {r = 0.4, g = 1, b = 0.4}
	elseif success >= 0.9 then
		return {r = 1, g = 0.9, b = 0.3}
	elseif success >= 0.7 then
		return {r = 1, g = 0.6, b = 0.2}
	end
	return {r = 1, g = 0.3, b = 0.3}
end

local function update_label(record)
	local silo = record.entity
	if not (silo and silo.valid) then
		return false
	end
	if in_sandbox(silo) then
		return true
	end
	local value = reliability(silo).success
	local text = {"re2-label.reliability", percent(value)}
	local color = label_color(value)
	local alt = setting("re-label-alt-mode")
	local label = record.label
	if label and label.valid then
		label.text = text
		label.color = color
		label.only_in_alt_mode = alt
	else
		record.label = rendering.draw_text({
			text = text,
			color = color,
			surface = silo.surface,
			target = {entity = silo, offset = {0, -5.2}},
			forces = {silo.force},
			scale = 1.6,
			alignment = "center",
			vertical_alignment = "middle",
			only_in_alt_mode = alt,
		})
	end
	return true
end

local function track(silo)
	if not (silo and silo.valid and silo.type == "rocket-silo" and silo.unit_number) then
		return
	end
	local record = storage.silos[silo.unit_number]
	if not record then
		record = {entity = silo}
		storage.silos[silo.unit_number] = record
	end
	update_label(record)
end

-- force: only the silos of this force (all when nil).
local function update_labels(force)
	for unit_number, record in pairs(storage.silos) do
		local silo = record.entity
		if not (silo and silo.valid) then
			storage.silos[unit_number] = nil
		elseif not force or silo.force == force then
			update_label(record)
		end
	end
end

local function add_row(table_element, caption, value, tooltip)
	table_element.add({type = "label", caption = caption, tooltip = tooltip})
	local label = table_element.add({type = "label", caption = value, tooltip = tooltip})
	label.style.font = "default-bold"
	return label
end

local function build_panel(player, silo)
	local relative = player.gui.relative
	if relative[GUI] then
		relative[GUI].destroy()
	end
	if in_sandbox(silo) then
		return
	end
	local r = reliability(silo)
	local frame = relative.add({
		type = "frame",
		name = GUI,
		caption = {"re2-gui.title"},
		direction = "vertical",
		anchor = {gui = defines.relative_gui_type.rocket_silo_gui, position = defines.relative_gui_position.right},
	})
	local inner = frame.add({type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical"})
	local rows = inner.add({type = "table", column_count = 2})
	rows.style.horizontal_spacing = 16
	add_row(rows, {"re2-gui.research"}, tostring(r.level), {"re2-gui.research-tooltip"})
	add_row(rows, {"re2-gui.force-experience"},
		{"re2-gui.experience-value", r.successes, r.failures, string.format("%.1f", r.experience)},
		{"re2-gui.force-experience-tooltip", setting("re-failure-experience")})
	add_row(rows, {"re2-gui.base-success"}, percent(r.base_success), {"re2-gui.base-success-tooltip"})
	add_row(rows, {"re2-gui.silo-launches"},
		{"re2-gui.silo-value", r.launches, string.format("%.3f", r.multiplier)},
		{"re2-gui.silo-launches-tooltip", setting("re-silo-bonus")})
	add_row(rows, {"re2-gui.quality"},
		{"re2-gui.quality-value", "[quality=" .. r.quality .. "]", r.step, string.format("%.0f", r.quality_bonus * 100)},
		{"re2-gui.quality-tooltip", setting("re-quality-bonus")})
	inner.add({type = "line"})
	local total = inner.add({type = "table", column_count = 2})
	total.style.horizontal_spacing = 16
	local success = add_row(total, {"re2-gui.success"}, percent(r.success))
	success.style.font = "default-large-bold"
	success.style.font_color = label_color(r.success)
	if r.success < 1 then
		add_row(total, {"re2-gui.failure"}, percent(1 - r.success))
		add_row(total, {"re2-gui.outcomes"},
			{"re2-gui.outcomes-value", percent(r.shares.nuclear), percent(r.shares.blast), percent(r.shares.accident)},
			{"re2-gui.outcomes-tooltip"})
	end
	local footer = inner.add({type = "label", caption = r.success >= 1 and {"re2-gui.footer-perfect"} or {"re2-gui.footer"}})
	footer.style.single_line = false
	footer.style.maximal_width = 330
	footer.style.font_color = {r = 0.7, g = 0.7, b = 0.7}
end

local function update_panels(force)
	for _, player in pairs(force.connected_players) do
		local opened = player.opened_gui_type == defines.gui_type.entity and player.opened
		if opened and opened.valid and opened.type == "rocket-silo" then
			build_panel(player, opened)
		end
	end
end

local function refresh(force)
	update_labels(force)
	update_panels(force)
end

---------------------------------------------------------------------------------------------------
-- Scheduler

local on_tick

local function register_tick()
	if storage.pending and #storage.pending > 0 then
		script.on_event(defines.events.on_tick, on_tick)
	else
		script.on_event(defines.events.on_tick, nil)
	end
end

local function schedule(job)
	table.insert(storage.pending, job)
	register_tick()
end

---------------------------------------------------------------------------------------------------
-- Failures

local function throw_debris(surface, position, count, min_distance, max_distance)
	for _ = 1, count do
		local angle = math.random() * 2 * math.pi
		local distance = min_distance + math.random() * (max_distance - min_distance)
		local target = {x = position.x + math.cos(angle) * distance, y = position.y + math.sin(angle) * distance}
		surface.create_entity({
			name = "re2-rocket-debris-" .. math.random(DEBRIS),
			position = position,
			target = target,
			speed = distance / (50 + math.random(50)),
			force = "neutral",
		})
	end
end

local function protect(entity, fraction, tick)
	entity.health = entity.max_health * fraction
	entity.destructible = false
	schedule({tick = tick + PROTECT_TICKS, action = "unprotect", entity = entity, until_tick = tick + PROTECT_MAX_TICKS})
end

local function alert(force, entity, kind, tick)
	for _, player in pairs(force.players) do
		player.add_custom_alert(entity, {type = "item", name = "rocket-silo"}, {"re2-alert." .. kind}, true)
	end
	force.play_sound({path = "utility/alert_destroyed"})
	schedule({tick = tick + ALERT_TICKS, action = "clear_alert", entity = entity, force = force})
end

-- The rocket and its cargo pod of a failed launch never leave: no on_rocket_launched, no ascending pod.
local function destroy_rocket(rocket)
	if rocket and rocket.valid then
		local pod = rocket.attached_cargo_pod
		if pod and pod.valid then
			pod.destroy()
		end
		rocket.destroy()
	end
end

-- Spills the module stacks around the position, marked for deconstruction by the force; returns the count.
local function spill_modules(surface, position, force, modules)
	local count = 0
	for _, stack in pairs(modules) do
		surface.spill_item_stack({
			position = position,
			stack = {name = stack.name, count = stack.count, quality = stack.quality},
			enable_looted = true,
			force = force,
			allow_belts = false,
		})
		count = count + stack.count
	end
	return count
end

-- Replaces the silo by a stage 4 construction site (or, without Rocket-Silo-Construction, a new silo).
-- The modules of the silo are thrown out on the ground around the site (put back into a new silo).
-- Returns the new entity, whether it is a construction site, and the number of modules thrown out.
local function throw_back(silo)
	local surface, position, force = silo.surface, silo.position, silo.force
	local name, quality, last_user = silo.name, silo.quality.name, silo.last_user
	if string.sub(quality, 1, 10) == "ic-defect-" then
		quality = "normal"
	end
	local module_inventory = silo.get_module_inventory()
	local modules = module_inventory and module_inventory.get_contents() or {}
	silo.destroy({raise_destroy = true})
	local site
	if remote.interfaces[RSC] and remote.interfaces[RSC].create_site then
		site = remote.call(RSC, "create_site", {
			surface = surface, position = position, force = force, stage = 4,
			quality = quality, final_building = name, last_user = last_user,
		})
	end
	if site and site.valid then
		return site, true, spill_modules(surface, position, force, modules)
	end
	site = surface.create_entity({name = name, position = position, force = force, quality = quality, raise_built = true})
	if site and site.valid then
		if last_user then
			site.last_user = last_user
		end
		local inventory = site.get_module_inventory()
		local left = {}
		for _, stack in pairs(modules) do
			local inserted = inventory and inventory.insert({name = stack.name, count = stack.count, quality = stack.quality}) or 0
			if inserted < stack.count then
				left[#left + 1] = {name = stack.name, count = stack.count - inserted, quality = stack.quality}
			end
		end
		modules = left
	end
	return site, false, spill_modules(surface, position, force, modules)
end

local function carry_out_failure(job, tick)
	local silo = job.silo
	if not (silo and silo.valid) then
		return
	end
	local surface, position, force = silo.surface, silo.position, silo.force
	local fraction = HEALTH_MIN + math.random() * (HEALTH_MAX - HEALTH_MIN)
	local kind = job.kind
	local target, rolled_back, dropped
	destroy_rocket(job.rocket)
	if kind == "accident" then
		target = silo
		protect(silo, fraction, tick)
		surface.create_entity({name = "big-explosion", position = position})
		throw_debris(surface, position, 5 + math.random(4), 8, 24)
	else
		target, rolled_back, dropped = throw_back(silo)
		if target and target.valid then
			protect(target, fraction, tick)
		end
		if kind == "nuclear" then
			surface.create_entity({name = "atomic-rocket", position = position, target = target or position, speed = 1,
				force = "neutral"})
		else
			surface.create_entity({name = "re2-rocket-blast", position = position, target = target or position, speed = 1,
				force = "neutral"})
			throw_debris(surface, position, 8 + math.random(6), 10, 32)
		end
	end
	if target and target.valid then
		track(target)
		alert(force, target, kind, tick)
	end
	local where = gps(surface, position)
	local message = {"", {"re2-message.failure-" .. kind, where, percent(job.chance), job.number}, " ", quip(kind)}
	if rolled_back then
		message = {"", message, "\n", {"re2-message.rollback", string.format("%.0f%%", fraction * 100)}, " ", quip("rollback")}
	elseif kind ~= "accident" then
		message = {"", message, "\n", {"re2-message.rebuilt", string.format("%.0f%%", fraction * 100)}}
	else
		message = {"", message, "\n", {"re2-message.accident-health", string.format("%.0f%%", fraction * 100)}}
	end
	if dropped and dropped > 0 then
		message = {"", message, " ", {"re2-message.modules-dropped", dropped}}
	end
	force.print(message, {color = {r = 1, g = 0.45, b = 0.35}})
	refresh(force)
end

local function run(job, tick)
	if job.action == "fail" then
		carry_out_failure(job, tick)
	elseif job.action == "unprotect" then
		local entity = job.entity
		if entity and entity.valid then
			local fires = entity.surface.count_entities_filtered({type = "fire", position = entity.position, radius = FIRE_RADIUS})
			if fires > 0 and tick < (job.until_tick or 0) then
				job.tick = tick + FIRE_CHECK_TICKS
				schedule(job)
			else
				entity.destructible = true
			end
		end
	elseif job.action == "clear_alert" then
		local entity, force = job.entity, job.force
		if force and force.valid then
			for _, player in pairs(force.players) do
				if entity and entity.valid then
					player.remove_alert({entity = entity, type = defines.alert_type.custom})
				end
			end
		end
	end
end

on_tick = function(event)
	local due, keep = {}, {}
	for _, job in ipairs(storage.pending) do
		if job.tick <= event.tick then
			due[#due + 1] = job
		else
			keep[#keep + 1] = job
		end
	end
	storage.pending = keep
	for _, job in ipairs(due) do
		run(job, event.tick)
	end
	register_tick()
end

---------------------------------------------------------------------------------------------------
-- Launch

local function pick_outcome(shares)
	local roll = math.random()
	if roll < shares.nuclear then
		return "nuclear"
	elseif roll < shares.nuclear + shares.blast then
		return "blast"
	end
	return "accident"
end

local function on_success(silo, r)
	local force = silo.force
	local data = force_data(force)
	local site = site_data(silo.surface, silo.position, true)
	site.launches = site.launches + 1
	local where = gps(silo.surface, silo.position)
	if not data.won and force.rockets_launched == 0 then
		data.won = true
		force.play_sound({path = "rocket-win"})
		force.print({"", {"re2-message.first-success", where, percent(1 - r.success)}, " ", quip("first")},
			{color = {r = 0.5, g = 1, b = 0.5}})
	elseif r.success < 1 then
		data.won = true
		force.print({"", {"re2-message.success", where, percent(1 - r.success)}, " ", quip("success")},
			{color = {r = 0.7, g = 0.9, b = 0.7}})
	end
	local after = reliability(silo)
	if after.success >= 1 and not site.perfect then
		site.perfect = true
		force.print({"", {"re2-message.perfect", where, site.launches}, " ", quip("perfect")},
			{color = {r = 0.5, g = 1, b = 0.5}})
	end
end

script.on_event(defines.events.on_rocket_launch_ordered, function(event)
	local silo = event.rocket_silo
	if not (silo and silo.valid) or in_sandbox(silo) then
		return
	end
	local force = silo.force
	local data = force_data(force)
	local r = reliability(silo)
	local forced = data.forced
	data.forced = nil
	local failed
	if forced then
		failed = forced ~= "success"
	else
		failed = math.random() >= r.success
	end
	if not failed then
		on_success(silo, r)
		refresh(force)
		return
	end
	local kind = forced and forced ~= "success" and forced or pick_outcome(r.shares)
	data.failures = data.failures + 1
	data[kind] = (data[kind] or 0) + 1
	schedule({
		tick = event.tick + 1,
		action = "fail",
		kind = kind,
		silo = silo,
		rocket = event.rocket,
		chance = 1 - r.success,
		number = data.failures,
	})
end)

---------------------------------------------------------------------------------------------------
-- Tracking and refresh events

local silo_filter = {{filter = "type", type = "rocket-silo"}}

local function on_built(event)
	track(event.entity or event.destination)
end

script.on_event(defines.events.on_built_entity, on_built, silo_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, silo_filter)
script.on_event(defines.events.script_raised_built, on_built, silo_filter)
script.on_event(defines.events.script_raised_revive, on_built, silo_filter)
script.on_event(defines.events.on_entity_cloned, on_built, silo_filter)

-- force.rockets_launched grows when the cargo pod has left the surface, after on_rocket_launched.
script.on_event(defines.events.on_cargo_pod_finished_ascending, function(event)
	local pod = event.cargo_pod
	if event.launched_by_rocket and pod and pod.valid then
		refresh(pod.force)
	end
end)

local function on_research(event)
	local technology = event.research
	if string.sub(technology.name, 1, #REVISION) == REVISION then
		refresh(technology.force)
	end
end
script.on_event(defines.events.on_research_finished, on_research)
script.on_event(defines.events.on_research_reversed, on_research)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if string.sub(event.setting, 1, 3) == "re-" then
		update_labels()
		for _, force in pairs(game.forces) do
			update_panels(force)
		end
	end
end)

script.on_event(defines.events.on_gui_opened, function(event)
	local entity = event.entity
	if entity and entity.valid and entity.type == "rocket-silo" then
		build_panel(game.get_player(event.player_index), entity)
	end
end)

script.on_event(defines.events.on_gui_closed, function(event)
	if event.gui_type == defines.gui_type.entity then
		local player = game.get_player(event.player_index)
		if player and player.gui.relative[GUI] then
			player.gui.relative[GUI].destroy()
		end
	end
end)

script.on_event(defines.events.on_forces_merged, function(event)
	storage.forces[event.source_index] = nil
	refresh(event.destination)
end)

script.on_event(defines.events.on_force_reset, function(event)
	refresh(event.force)
end)

---------------------------------------------------------------------------------------------------
-- Lifecycle

local function scan()
	for _, surface in pairs(game.surfaces) do
		for _, silo in pairs(surface.find_entities_filtered({type = "rocket-silo"})) do
			track(silo)
		end
	end
	update_labels()
end

script.on_init(function()
	init_storage()
	scan()
end)

script.on_configuration_changed(function()
	init_storage()
	quality_steps = nil
	scan()
	register_tick()
end)

script.on_load(function()
	if storage.pending and #storage.pending > 0 then
		script.on_event(defines.events.on_tick, on_tick)
	end
end)

---------------------------------------------------------------------------------------------------
-- Remote interface

remote.add_interface("RocketExplosions2", {
	-- Table of the success chance parts for a rocket silo (see reliability()).
	get_reliability = function(silo)
		if silo and silo.valid and silo.type == "rocket-silo" then
			return reliability(silo)
		end
	end,
	-- For scenarios and tests: the next launch order of the force succeeds ("success") or fails with
	-- the given outcome ("nuclear", "blast", "accident").
	set_next_outcome = function(force_name, outcome)
		local force = game.forces[force_name]
		if force and (outcome == "success" or outcome == "nuclear" or outcome == "blast" or outcome == "accident") then
			force_data(force).forced = outcome
		end
	end,
})
