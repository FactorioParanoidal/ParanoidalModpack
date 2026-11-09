-- Protection layers, wear, refill, auto-equip and module energy on mock objects. Not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path

defines = {
	inventory = { character_armor = 1, character_main = 2, character_trash = 3 },
	entity_status = { working = 1 },
}
game = { tick = 0 }
storage = {}

local NORMAL = { name = "normal" }
local function item_prototype(name, percent, durability)
	return {
		type = "armor", localised_name = name,
		resistances = percent and { toxin = { percent = percent / 100, decrease = 0 } } or {},
		get_durability = function() return durability end,
	}
end
prototypes = {
	item = {
		["respirator"] = item_prototype("respirator", 50, 600),
		["tpr-gas-mask"] = item_prototype("tpr-gas-mask", 80, 3000),
		["power-armor-mk2"] = item_prototype("power-armor-mk2", 70, 20000),
		["heavy-armor"] = item_prototype("heavy-armor", 30, 5000),
		["hazmat-plain"] = item_prototype("hazmat-plain", nil, 15),
		["creative-armor"] = item_prototype("creative-armor", nil, nil),
		["CW-air-filter"] = { type = "item" },
		["CW-used-air-filter"] = { type = "item" },
	},
}

local function stack(name, durability, grid)
	local s = { valid_for_read = name ~= nil, name = name, type = "armor", quality = NORMAL, durability = durability,
		grid = grid, count = name and 1 or 0 }
	function s.clear()
		s.valid_for_read, s.name, s.durability, s.grid, s.count = false, nil, nil, nil, 0
	end
	function s.transfer_stack(other)
		if s.valid_for_read or not other.valid_for_read then return false end
		s.valid_for_read, s.name, s.durability, s.grid, s.type = true, other.name, other.durability, other.grid, other.type
		s.count, s.quality = 1, other.quality
		other.count = other.count - 1
		if other.count <= 0 then other.clear() end
		return true
	end
	return s
end

local function inventory(stacks)
	local inv = { items = {} }
	for index, s in ipairs(stacks) do inv[index] = s end
	setmetatable(inv, { __len = function(t) return #stacks end })
	function inv.get_contents()
		local out = {}
		for name, count in pairs(inv.items) do
			if count > 0 then out[#out + 1] = { name = name, quality = "normal", count = count } end
		end
		return out
	end
	function inv.remove(spec)
		local have = inv.items[spec.name] or 0
		local taken = math.min(have, spec.count)
		inv.items[spec.name] = have - taken
		return taken
	end
	function inv.insert(spec)
		inv.items[spec.name] = (inv.items[spec.name] or 0) + spec.count
		return spec.count
	end
	return inv
end

local printed, sounds = {}, {}
local function player()
	return {
		mod_settings = { ["tpr-sounds"] = { value = true }, ["tpr-auto-equip"] = { value = true } },
		print = function(message) printed[#printed + 1] = message end,
		play_sound = function(spec) sounds[#sounds + 1] = spec.path end,
		create_local_flying_text = function() end,
	}
end

local function character(armor_stack, main_stacks, vehicle)
	local armor = inventory({ armor_stack })
	local main = inventory(main_stacks or {})
	local trash = inventory({})
	return {
		valid = true, position = { x = 0, y = 0 }, force = "player", vehicle = vehicle,
		surface = { spill_item_stack = function() end },
		get_inventory = function(id)
			if id == defines.inventory.character_armor then return armor end
			if id == defines.inventory.character_main then return main end
			if id == defines.inventory.character_trash then return trash end
		end,
		get_main_inventory = function() return main end,
		armor = armor, main = main,
	}
end

local P = require("scripts.protection")

local function near(a, b, message)
	assert(math.abs(a - b) < 1e-6, (message or "") .. ": " .. tostring(a) .. " ~= " .. tostring(b))
end

-- Respirator in P=500: protects fully, wear (500-150)*(1-0.5)/100 = 1.75 per second ------------------
do
	local s = stack("respirator", 600)
	local ch = character(s)
	local state = P.evaluate(player(), ch, {}, 500, 150, 0, 1, true)
	assert(state.protected, "a worn respirator protects")
	near(state.inhaled, 0, "nothing reaches the body")
	near(state.filtration, 0, "no cabin/module filtration")
	near(s.durability, 600 - 1.75, "respirator wear")
	near(state.armor.wear, 1.75, "wear per second for the forecast")
	assert(state.filters == nil, "disposable: no refill counter")
end

-- No protection: the body breathes everything -------------------------------------------------------
do
	local state = P.evaluate(player(), character(stack(nil)), {}, 500, 150, 0, 1, true)
	assert(not state.protected and state.armor == nil)
	near(state.inhaled, 500, "inhaled unprotected")
end

-- No wear at or below the tolerance ---------------------------------------------------------------------
do
	local s = stack("tpr-gas-mask", 3000)
	P.evaluate(player(), character(s), {}, 150, 150, 0, 1, true)
	near(s.durability, 3000, "no wear in tolerable air")
end

-- Any armor protects (toxicPollution2): without toxin resistance it wears fastest ----------------------
do
	local s = stack("hazmat-plain", 15)
	local state = P.evaluate(player(), character(s), {}, 650, 150, 0, 1, true)
	assert(state.protected and state.inhaled == 0, "armor without resistance still protects")
	near(s.durability, 15 - 5 / 3, "armor endurance: (650-150)/100/3")
	-- an armor without a resource (creative) protects and never wears
	local c = stack("creative-armor", nil, { equipment = {} })
	local infinite_character = character(c)
	infinite_character.main.items["CW-air-filter"] = 2
	local state2 = P.evaluate(player(), infinite_character, {}, 5000, 150, 0, 1, true)
	assert(state2.protected and state2.armor.infinite and c.valid_for_read)
	assert(infinite_character.main.items["CW-air-filter"] == 2, "infinite grid armor must not be serviced")
end

-- Worn-out mask is destroyed and the BEST spare is put on (old bug: the worst one) --------------------
do
	printed, sounds = {}, {}
	local s = stack("respirator", 1)
	local spare_resp = stack("respirator", 600)
	local spare_mask = stack("tpr-gas-mask", 100)
	local spare_heavy = stack("heavy-armor", 5000)
	local ch = character(s, { spare_resp, spare_heavy, spare_mask })
	P.evaluate(player(), ch, {}, 1000, 150, 0, 1, true)
	-- endurance = resource / (1 - share): respirator 1200, gas mask 500, heavy 7143 → heavy lasts longest
	assert(ch.armor[1].valid_for_read and ch.armor[1].name == "heavy-armor", "longest-lasting first: " .. tostring(ch.armor[1].name))
	assert(not spare_heavy.valid_for_read, "the spare moved")
	assert(#printed == 0 and #sounds == 1, "automatic replacement is quiet except the equip sound")
end

-- Worn out with no spare: lost, the body is unprotected from this second on ------------------------
do
	local s = stack("respirator", 1)
	local state = P.evaluate(player(), character(s), {}, 1000, 150, 0, 1, true)
	assert(state.armor.lost and not state.protected and state.inhaled == 1000)
end

-- Worn out and replaced: the state describes the new item -----------------------------------------
do
	local s = stack("respirator", 1)
	local state = P.evaluate(player(), character(s, { stack("tpr-gas-mask", 3000) }), {}, 1000, 150, 0, 1, true)
	assert(state.armor.replaced and state.armor.name == "tpr-gas-mask" and state.protected)
end

-- Grid armor is never destroyed: the resource stops below `exhausted`, filtration becomes 0 ------------
do
	printed = {}
	local grid = { equipment = {} }
	local s = stack("power-armor-mk2", 1.1, grid)
	local ch = character(s)
	local data = {}
	P.evaluate(player(), ch, data, 2000, 150, 0, 1, true)
	assert(s.valid_for_read and s.name == "power-armor-mk2", "grid armor kept")
	assert(s.durability > 0 and s.durability < 1, "stopped at the floor: " .. s.durability)
	local state = P.evaluate(player(), ch, data, 2000, 150, 0, 1, true)
	assert(state.armor.exhausted and not state.protected and state.inhaled == 2000, "exhausted armor does not protect")
	assert(#printed == 1, "one exhausted notice")
end

-- Refill with an air filter: +1500, a used filter comes back; respirator never refilled -------------
do
	sounds = {}
	local s = stack("tpr-gas-mask", 1000)
	local ch = character(s)
	ch.main.items["CW-air-filter"] = 2
	local state = P.evaluate(player(), ch, {}, 500, 150, 0, 1, true)
	near(s.durability, 1000 + 1500 - 350 * 0.2 / 100, "refilled then worn")
	assert(ch.main.items["CW-air-filter"] == 1 and ch.main.items["CW-used-air-filter"] == 1)
	assert(state.filters == 1, "HUD counter")
	local r = stack("respirator", 10)
	local ch2 = character(r)
	ch2.main.items["CW-air-filter"] = 5
	P.evaluate(player(), ch2, {}, 500, 150, 0, 1, true)
	assert(ch2.main.items["CW-air-filter"] == 5, "respirator is disposable")
	-- no filters: retry is throttled
	local m = stack("tpr-gas-mask", 100)
	local data = {}
	P.evaluate(player(), character(m), data, 500, 150, 0, 1, true)
	assert(data.refill_retry and data.refill_retry > game.tick)
end

-- Layers: vehicle → module (energy) → armor; the module protects the armor's filters ---------------
do
	local module = { name = "tpr-filter-module", energy = 100000 }
	local grid = { equipment = { module, { name = "tpr-closed-breathing", energy = 0 } } }
	local s = stack("power-armor-mk2", 20000, grid)
	local ch = character(s, {}, { type = "car", name = "tank" })
	local state = P.evaluate(player(), ch, {}, 4000, 150, 0, 1, true)
	-- best module = closed breathing, but it has no charge → share 0, status empty
	assert(state.module.name == "tpr-closed-breathing" and state.module.status == "empty")
	near(state.vehicle.share, 0.85)
	local reaching = 4000 * 0.15
	near(state.reaching, reaching, "air reaching the armor")
	assert(state.protected and state.inhaled == 0)
	near(s.durability, 20000 - (reaching - 150) * 0.3 / 100 / 3, "armor wear after the vehicle")

	grid.equipment[2].energy = 1e6
	local s2 = stack("power-armor-mk2", 20000, grid)
	local state2 = P.evaluate(player(), character(s2, {}, nil), {}, 4000, 150, 0, 1, true)
	near(state2.filtration, 1, "closed breathing with charge filters everything")
	assert(state2.armor.wear == 0)
	near(grid.equipment[2].energy, 1e6 - 200000, "200 kW for one second")
	near(s2.durability, 20000, "the armor behind a closed module does not wear")

	local idle = { name = "tpr-filter-module", energy = 5000 }
	local s3 = stack("power-armor-mk2", 20000, { equipment = { idle } })
	local state3 = P.evaluate(player(), character(s3), {}, 100, 150, 0, 1, true)
	assert(state3.module.status == "standby" and idle.energy == 5000, "no energy spent in clean air")
end

-- Read-only evaluation spends nothing ------------------------------------------------------------------
do
	local module = { name = "tpr-filter-module", energy = 100000 }
	local s = stack("power-armor-mk2", 20000, { equipment = { module } })
	P.evaluate(player(), character(s), {}, 3000, 150, 0, 1, false)
	assert(module.energy == 100000 and s.durability == 20000)
end

-- Exhaustion -> filter arrives -> ordinary update restores protection; getters cannot service it.
do
	local grid = { equipment = {} }
	local s = stack("power-armor-mk2", 0.5, grid)
	local ch, p, data = character(s), player(), {}
	local empty = P.evaluate(p, ch, data, 2000, 150, 0, 1, true)
	assert(empty.armor.exhausted and data.refill_retry > game.tick)
	ch.main.items["CW-air-filter"] = 3
	data.refill_retry = nil -- inventory-change handler clears only this persistent throttle
	for _ = 1, 3 do
		assert(not P.evaluate(p, ch, data, 2000, 150, 0, 1, false).protected)
	end
	assert(ch.main.items["CW-air-filter"] == 3 and s.durability == 0.5)
	local state = P.evaluate(p, ch, data, 2000, 150, 0, 1, true)
	assert(state.protected and state.inhaled == 0 and s.grid == grid)
	near(s.durability, 1500.5 - 1850 * 0.3 / 100 / 3)
	assert(ch.main.items["CW-air-filter"] == 2 and ch.main.items["CW-used-air-filter"] == 1,
		"one transaction, not service plus spend refills")
	-- Usable armor still does not refill in clean air; exhausted armor can.
	s.durability = 10
	P.evaluate(p, ch, data, 0, 150, 0, 1, true)
	assert(ch.main.items["CW-air-filter"] == 2 and s.durability == 10)
	s.durability = 0.5
	assert(P.evaluate(p, ch, data, 0, 150, 0, 1, true).protected)
	assert(ch.main.items["CW-air-filter"] == 1 and s.durability == 1500.5)
end

-- Small real-cap resource: cap, one quality-preserving return spilled from a full inventory.
do
	prototypes.item["small-grid"] = item_prototype("small-grid", 40, 800)
	local grid = { equipment = {} }
	local s = stack("small-grid", 0.5, grid)
	s.quality = { name = "ic-defect-5" }
	local ch, taken, returned, spilled = character(s), 0, 0, 0
	ch.main.get_contents = function() return { { name = "CW-air-filter", quality = "uncommon", count = 5 } } end
	ch.main.remove = function(spec) assert(spec.quality == "uncommon"); taken = taken + 1; return 1 end
	ch.main.insert = function(spec) assert(spec.quality == "uncommon"); returned = returned + 1; return 0 end
	ch.surface.spill_item_stack = function(spec)
		assert(spec.stack.quality == "uncommon" and spec.stack.name == "CW-used-air-filter")
		spilled = spilled + 1
	end
	P.evaluate(player(), ch, {}, 0, 150, 0, 1, true)
	assert(s.durability == 800 and s.grid == grid and s.quality.name == "ic-defect-5")
	assert(taken == 1 and returned == 1 and spilled == 1)
end

-- Same-name replacement at another quality must report its own cap, not the spent item's.
do
	prototypes.item["quality-mask"] = item_prototype("quality-mask", nil, 10)
	prototypes.item["quality-mask"].get_durability = function(quality) return quality.name == "normal" and 10 or 20 end
	local worn, spare = stack("quality-mask", 0.5), stack("quality-mask", 20)
	spare.quality = { name = "uncommon" }
	local state = P.evaluate(player(), character(worn, { spare }), {}, 1000, 150, 0, 1, true)
	assert(state.armor.replaced and state.armor.quality == "uncommon" and state.armor.max == 20)
	assert(state.armor.wear == 0 and state.armor.resource == 20)
end

print("protection: OK")
