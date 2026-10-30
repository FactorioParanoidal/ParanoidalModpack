-- Carbon Capture (2.0): air filter machines stop on clean air and do not waste filters.
--
-- Pollution is stored per chunk, so machines are grouped by chunk: one get_pollution call per
-- chunk, and the machines are written only when the chunk flips between "on" and "off".
-- Hysteresis (start above ON_ABOVE, stop at OFF_AT or below) keeps a chunk from flipping every
-- check near the threshold. Chunks are checked round-robin in SLICES parts, one part every STEP
-- ticks, so every chunk is checked once per STEP * SLICES ticks without a spike on one tick.
-- The tick handler is registered only while at least one machine is tracked.
--
-- storage.cc:
--   list[slot]                 dense array of chunk records (swap-remove)
--   surfaces[surface][key]     chunk record by chunk coordinates
--   units[unit_number]         chunk record of a tracked machine
--   cursor                     next slot to check
--   neutral                    index of the neutral force (ruins: not tracked until claimed)
-- chunk record: surface, index (surface index), key, pos (chunk centre), on, slot, ents[unit] = entity

local NAMES = {}
local NAME_SET = {}
local FILTER = {}
for tier = 1, 6 do
	local name = "CW-air-filter-machine-" .. tier
	NAMES[tier] = name
	NAME_SET[name] = true
	FILTER[tier] = { filter = "name", name = name }
end

local ON_ABOVE = 10 -- start when the chunk pollution rises above this
local OFF_AT = 1 -- stop when it falls to this or below (the original single threshold)
local STEP = 10 -- ticks between slices
local SLICES = 6 -- full cycle: STEP * SLICES = 60 ticks, as before

local STATUS = { diode = defines.entity_status_diode.yellow, label = { "cw-air-filter.status-clean-air" } }
local ENTITY_TARGET = defines.target_type.entity
local RUINS = "AbandonedRuins"

local floor, ceil, next = math.floor, math.ceil, next

local S -- storage.cc

local function apply(entity, on)
	entity.disabled_by_script = not on
	entity.custom_status = (not on) and STATUS or nil
end

local function flip(chunk, on)
	chunk.on = on
	for _, entity in pairs(chunk.ents) do
		if entity.valid then apply(entity, on) end
	end
end

local function step()
	local list = S.list
	local n = #list
	local i = S.cursor
	for _ = 1, ceil(n / SLICES) do
		if i > n then i = 1 end
		local chunk = list[i]
		local pollution = chunk.surface.get_pollution(chunk.pos)
		if chunk.on then
			if pollution <= OFF_AT then flip(chunk, false) end
		elseif pollution > ON_ABOVE then
			flip(chunk, true)
		end
		i = i + 1
	end
	S.cursor = i
end

local function update_tick()
	script.on_nth_tick(STEP, (S and S.list[1]) and step or nil)
end

local function add(entity)
	local unit = entity.unit_number
	if S.units[unit] then return end
	script.register_on_object_destroyed(entity)
	local position = entity.position
	local cx, cy = floor(position.x / 32), floor(position.y / 32)
	local key = cx * 0x40000 + cy -- |cy| < 2^17 on any map, so the key is unique
	local index = entity.surface_index
	local chunks = S.surfaces[index]
	if not chunks then
		chunks = {}
		S.surfaces[index] = chunks
	end
	local chunk = chunks[key]
	if not chunk then
		local surface = entity.surface
		local pos = { x = cx * 32 + 16, y = cy * 32 + 16 }
		local list = S.list
		chunk = {
			surface = surface, index = index, key = key, pos = pos, ents = {}, slot = #list + 1,
			on = surface.get_pollution(pos) > ON_ABOVE,
		}
		list[chunk.slot] = chunk
		chunks[key] = chunk
		if chunk.slot == 1 then update_tick() end
	end
	chunk.ents[unit] = entity
	S.units[unit] = chunk
	apply(entity, chunk.on)
end

local function drop_chunk(chunk)
	local chunks = S.surfaces[chunk.index]
	chunks[chunk.key] = nil
	if next(chunks) == nil then S.surfaces[chunk.index] = nil end
	local list = S.list
	local n = #list
	local last = list[n]
	list[chunk.slot] = last
	last.slot = chunk.slot
	list[n] = nil
	for unit in pairs(chunk.ents) do S.units[unit] = nil end
	if n == 1 then update_tick() end
end

local function remove(unit)
	local chunk = S.units[unit]
	if not chunk then return end
	S.units[unit] = nil
	chunk.ents[unit] = nil
	if next(chunk.ents) == nil then drop_chunk(chunk) end
end

local function rebuild()
	storage.CW_AirFilterTable = nil -- registry of 9.1.4 and earlier
	local neutral = game.forces.neutral.index
	S = { list = {}, surfaces = {}, units = {}, cursor = 1, neutral = neutral }
	storage.cc = S
	for _, surface in pairs(game.surfaces) do
		for _, entity in pairs(surface.find_entities_filtered({ name = NAMES })) do
			if entity.force_index == neutral then
				apply(entity, true) -- the old runtime also switched ruins machines off
			else
				add(entity)
			end
		end
	end
	update_tick()
end

local function on_built(event)
	local entity = event.entity or event.destination
	if S and entity and entity.valid and entity.force_index ~= S.neutral then add(entity) end
end

-- AbandonedRuins claim tool: a neutral ruins machine becomes the player's.
local function on_force_changed(event)
	local entity = event.entity
	if S and entity and entity.valid and NAME_SET[entity.name] and entity.force_index ~= S.neutral then
		add(entity)
	end
end

local function subscribe()
	local interface = remote.interfaces[RUINS]
	if interface and interface.get_on_entity_force_changed_event then
		script.on_event(remote.call(RUINS, "get_on_entity_force_changed_event"), on_force_changed)
	end
end

-- A save of 9.1.4 or earlier loaded without a configuration change (same mod version) has no
-- storage.cc yet; storage cannot be written in on_load, so it is rebuilt on the first tick.
local function migrate()
	script.on_event(defines.events.on_tick, nil)
	if not storage.cc then rebuild() end
end

-- 2.0: an event filter is allowed only when registering a single event.
for _, id in ipairs({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.on_space_platform_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
	defines.events.on_entity_cloned,
}) do
	script.on_event(id, on_built, FILTER)
end

-- Every way of removal (mined, died, destroy() without raise, fast replace, chunk/surface deletion).
-- The event also comes for objects registered by other mods: only own entity unit numbers match.
script.on_event(defines.events.on_object_destroyed, function(event)
	if S and event.type == ENTITY_TARGET then remove(event.useful_id) end
end)

-- The surface becomes invalid after deletion, before on_object_destroyed of its machines.
script.on_event(defines.events.on_pre_surface_deleted, function(event)
	local chunks = S and S.surfaces[event.surface_index]
	if not chunks then return end
	local drop = {}
	for _, chunk in pairs(chunks) do drop[#drop + 1] = chunk end
	for i = 1, #drop do drop_chunk(drop[i]) end
end)

script.on_init(function()
	rebuild()
	subscribe()
end)

script.on_load(function()
	S = storage.cc
	if not S then
		script.on_event(defines.events.on_tick, migrate)
	elseif S.list[1] then
		script.on_nth_tick(STEP, step)
	end
	subscribe()
end)

script.on_configuration_changed(rebuild)
