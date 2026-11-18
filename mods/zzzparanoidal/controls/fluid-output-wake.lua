-- Workaround for a Factorio 2.1.24 engine bug (reproduced without mods, 2026-11-18): a crafting machine whose
-- recipe turns items into a fluid stops with "Output full" when its fluid output is blocked; the inserters
-- loading it go to sleep. When the fluid leaves, nothing in the machine's item inventory changes, so the engine
-- never wakes them; if their source machine has also stopped (output full), the chain stays stuck until a
-- player touches an inserter. Seen with crusher -> inserters -> liquifier groups.
--
-- Machines with an output fluidbox are checked in turn, each about every INTERVAL ticks. A machine short of
-- an item ingredient and without a finished craft since its previous check gets its inserters checked: an
-- inserter waiting for source items with an empty hand, dropping into this machine, whose pickup target holds
-- a missing ingredient at the recipe quality that its filter lets through, is woken by writing the same drop
-- target again (the engine wakes the inserter; settings and positions stay as they are).
local M = {}

local INTERVAL = 150 -- ticks between two checks of one machine
local STEP = 10 -- ticks between check batches; 15 (turret-deploy) and 60 (burner-pump-status) are taken
local CRAFTER_TYPES = { "assembling-machine", "furnace" }
local SHORTAGE = {
	[defines.entity_status.item_ingredient_shortage] = true,
	[defines.entity_status.no_ingredients] = true,
}
local WAITING = defines.entity_status.waiting_for_source_items
local CRAFTER_INPUT = defines.inventory.crafter_input

-- Prototype caches: rebuilt identically on every client at load, no storage.
local eligible, eligible_names = {}, {}
for name, proto in pairs(prototypes.get_entity_filtered({ { filter = "type", type = CRAFTER_TYPES } })) do
	for _, box in pairs(proto.fluidbox_prototypes or {}) do
		if box.production_type == "output" then
			eligible[name] = true
			eligible_names[#eligible_names + 1] = name
			break
		end
	end
end

-- How far an inserter can stand from the machine it drops into: the longest vector of any inserter (custom
-- vectors of Bob's adjustable inserters reach 3 tiles plus the drop offset) and the inserter's own size.
local function vector_reach(v)
	if not v then return 0 end
	return math.max(math.abs(v.x or v[1] or 0), math.abs(v.y or v[2] or 0))
end
local reach = 0
for _, proto in pairs(prototypes.get_entity_filtered({ { filter = "type", type = "inserter" } })) do
	local r = math.max(vector_reach(proto.inserter_pickup_position), vector_reach(proto.inserter_drop_position))
	if proto.allow_custom_vectors then r = math.max(r, 3.5) end
	r = r + math.max(proto.tile_width or 1, proto.tile_height or 1) / 2 + 0.5
	if r > reach then reach = r end
end

-- recipe name -> list of {item, amount}, or false when the recipe does not turn items into a fluid.
local recipe_specs = {}
local function recipe_spec(recipe)
	local name = recipe.name
	local spec = recipe_specs[name]
	if spec ~= nil then return spec end
	spec = false
	local proto = recipe.prototype
	local fluid_out = false
	for _, product in pairs(proto.products) do
		if product.type == "fluid" then fluid_out = true break end
	end
	if fluid_out then
		local items = {}
		for _, ingredient in pairs(proto.ingredients) do
			if ingredient.type == "item" then items[#items + 1] = { ingredient.name, ingredient.amount } end
		end
		if items[1] then spec = items end
	end
	recipe_specs[name] = spec
	return spec
end

local function state()
	local s = storage.paranoidal_fluid_output_wake
	if not s then
		M.sync() -- also covers an existing save after a code-only update without a version bump
		s = storage.paranoidal_fluid_output_wake
	end
	return s
end

local function add(entity)
	if not (entity and entity.valid and eligible[entity.name]) then return end
	local s = state()
	local id = entity.unit_number
	if not id or s.set[id] then return end
	s.set[id] = true
	s.list[#s.list + 1] = { e = entity, u = id, s = entity.surface.index, p = entity.position }
end

function M.sync()
	local s = { list = {}, set = {}, pos = 1, woken = 0 }
	storage.paranoidal_fluid_output_wake = s
	if not eligible_names[1] then return end
	for _, surface in pairs(game.surfaces) do
		for _, entity in pairs(surface.find_entities_filtered({ type = CRAFTER_TYPES, name = eligible_names })) do
			add(entity)
		end
	end
end

-- The inserter's filter lets the item through (quality conditions are not evaluated: a needless wake only
-- makes the inserter look again and fall asleep).
local function allows(inserter, name)
	if not inserter.use_filters then return true end
	local listed = false
	for i = 1, inserter.filter_slot_count do
		local filter = inserter.get_filter(i)
		if filter and (filter.name == nil or filter.name == name) then
			listed = true
			break
		end
	end
	if inserter.inserter_filter_mode == "blacklist" then return not listed end
	return listed
end

local function wake(inserter, machine)
	inserter.drop_target = machine
end

local function check(s, rec)
	local machine = rec.e
	if not SHORTAGE[machine.status] then
		rec.f = nil
		return
	end
	local finished = machine.products_finished
	if rec.f ~= finished then -- crafted since the previous check, or just started waiting
		rec.f = finished
		return
	end
	local recipe, quality = machine.get_recipe()
	if not recipe then return end
	local spec = recipe_spec(recipe)
	if not spec then return end
	local input = machine.get_inventory(CRAFTER_INPUT)
	if not input then return end
	local q = quality and quality.name or "normal"
	local need
	for _, item in ipairs(spec) do
		if input.get_item_count({ name = item[1], quality = q }) < item[2] then
			need = need or {}
			need[#need + 1] = item[1]
		end
	end
	if not need then return end
	local box = machine.bounding_box
	local area = { { box.left_top.x - reach, box.left_top.y - reach }, { box.right_bottom.x + reach, box.right_bottom.y + reach } }
	for _, inserter in pairs(machine.surface.find_entities_filtered({ area = area, type = "inserter" })) do
		if inserter.status == WAITING and inserter.drop_target == machine and not inserter.held_stack.valid_for_read then
			local source = inserter.pickup_target
			local output = source and source.get_output_inventory()
			if output then
				for _, name in ipairs(need) do
					if allows(inserter, name) and output.get_item_count({ name = name, quality = q }) > 0 then
						if pcall(wake, inserter, machine) then s.woken = s.woken + 1 end
						break
					end
				end
			end
		end
	end
end

-- A machine replaced without a build event (production modes of ic-more-qualities swap with raise_built =
-- false) is picked up at the position of the old one.
local function replaced(rec)
	local surface = game.get_surface(rec.s)
	if not surface then return end
	for _, entity in pairs(surface.find_entities_filtered({ position = rec.p, type = CRAFTER_TYPES })) do
		add(entity)
	end
end

local function step()
	local s = state()
	local list = s.list
	local n = #list
	if n == 0 then return end
	local count = math.ceil(n * STEP / INTERVAL)
	local pos = s.pos
	local dropped = {}
	for _ = 1, count do
		if pos > n then pos = 1 end
		local rec = list[pos]
		if rec.e.valid then
			check(s, rec)
			pos = pos + 1
		else
			s.set[rec.u] = nil
			list[pos] = list[n]
			list[n] = nil
			n = n - 1
			dropped[#dropped + 1] = rec
			if n == 0 then break end
		end
	end
	s.pos = pos
	for _, rec in ipairs(dropped) do replaced(rec) end
end

-- Keep the earlier zzz handlers of the shared events, as the neighbouring modules do.
local function on(event, handler)
	local previous = script.get_event_handler(event)
	script.on_event(event, function(e)
		if previous then previous(e) end
		handler(e)
	end)
end

function M.install()
	for _, event in ipairs({ defines.events.on_built_entity, defines.events.on_robot_built_entity,
		defines.events.script_raised_built, defines.events.script_raised_revive, defines.events.on_entity_cloned }) do
		on(event, function(e) add(e.destination or e.entity) end)
	end
	script.on_nth_tick(STEP, step)
	-- Read-only numbers for tests and diagnostics.
	remote.add_interface("paranoidal_fluid_output_wake", {
		stats = function()
			local s = storage.paranoidal_fluid_output_wake
			return { machines = s and #s.list or 0, woken = s and s.woken or 0, reach = reach, interval = INTERVAL }
		end,
	})
end

return M
