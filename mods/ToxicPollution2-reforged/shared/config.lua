-- Names and numbers shared by the data and control stages. Pure Lua: no game objects here.
local C = {}

C.MOD = "ToxicPollution2-reforged"
C.PATH = "__ToxicPollution2-reforged__"

-- Kept from toxicPollution2: other mods of the build use these names.
C.RESPIRATOR = "respirator"
C.RESIST_TYPE = "toxin" -- the toxin resistance of an armor slows the wear of its filter resource

C.GAS_MASK = "tpr-gas-mask"
C.FILTER_MODULE = "tpr-filter-module"
C.CLOSED_MODULE = "tpr-closed-breathing"
C.DAMAGE_TYPE = "tpr-intoxication" -- health damage of intoxication; no armor resists it
C.TECH = "tpr-smog-protection" -- levels 1..TECH_LEVELS
C.TECH_LEVELS = 10
C.SIGNAL = "tpr-pollution" -- pollution sensor signal for constant combinators
C.ALERT = { smog = "tpr-alert-smog", danger = "tpr-alert-danger", filters = "tpr-alert-filters" }
C.CLEAN_AIR_DATA = "tpr-clean-air" -- mod-data: machines that absorb pollution

-- Refill of the worn protection (carbon-capture2): the same air filter the air-filter machines burn.
C.REFILL_ITEM = "CW-air-filter"
C.REFILL_RETURN = "CW-used-air-filter"
C.REFILL_AMOUNT = 1500 -- filter resource restored by one filter

-- Armor-slot items (toxicPollution2 behaviour): ANY worn item takes the whole harm of the smog on
-- its filter resource (durability) while the resource lasts; the body is not poisoned meanwhile.
-- `filtration` = toxin resistance = how much slower the resource wears (wear × (1 − share)).
-- Missing names are skipped. Light/heavy armor keep stack 10 as in toxicPollution2; heavy-armor-2/3
-- (ПР-045) and Yuoki (derived from the power armor of its tier) get their values from their owners.
-- Light armor is crafted from a respirator, so it never protects shorter than the respirator.
C.ARMORS = {
	[C.RESPIRATOR] = { filtration = 50, durability = 650 },
	[C.GAS_MASK] = { filtration = 80, durability = 1300 },
	["light-armor"] = { filtration = 50, durability = 1000, stack_size = 10 },
	["heavy-armor"] = { filtration = 30, durability = 5000, stack_size = 10 },
	["modular-armor"] = { filtration = 40, durability = 10000 },
	["power-armor"] = { filtration = 60, durability = 15000 },
	["power-armor-mk2"] = { filtration = 70, durability = 20000 },
	["bob-power-armor-mk3"] = { filtration = 75, durability = 30000 },
	["bob-power-armor-mk4"] = { filtration = 80, durability = 40000 },
	["bob-power-armor-mk5"] = { filtration = 85, durability = 50000 },
	["hazmat-suit"] = { filtration = 85, durability = 3000 },
}
C.DEFAULT_DURABILITY = 10000 -- for other armors without durability (any armor protects, so any wears)
C.DISPOSABLE = { [C.RESPIRATOR] = true } -- never refilled
C.POISON_FILTERS = { [C.RESPIRATOR] = true, [C.GAS_MASK] = true } -- poison 90 %, paid with the resource
C.POISON_SHARE = 0.9

-- Grid modules, best first. power: watts drawn while the air reaching the module is harmful.
C.MODULES = {
	{ name = C.CLOSED_MODULE, filtration = 1.0, power = 200000, buffer = 4000000, input = 400000 },
	{ name = C.FILTER_MODULE, filtration = 0.5, power = 40000, buffer = 800000, input = 80000 },
}

C.MODEL = {
	rate_max = 8, -- %/s, intoxication growth limit
	rate_half = 600, -- excess of inhaled pollution over tolerance that gives half of rate_max
	decay_min = 1, -- %/s at inhaled = tolerance
	decay_max = 5, -- %/s in clean air
	zone_factor = 2, -- decay multiplier near a working air cleaner
	zone_radius = 10,
	damage_from = 50, -- % of intoxication where damage starts (only while inhaling over tolerance)
	damage_share = 0.08, -- share of max health per second at 100 %
	-- Resource per second of the worn item = harmful pollution × (1 − toxin share) / wear_div.
	-- At pollution 500 without research: respirator ≈ 6 min, light armor ≈ 9.5 min, gas mask ≈ 31 min,
	-- heavy armor ≈ 34 min, modular ≈ 79 min, power ≈ 3 h, power MK2 ≈ 5.3 h.
	wear_div = 100,
	tolerance_per_level = 0.10,
	resource_per_level = 0.10,
	exhausted = 1, -- resource below this: the item no longer filters (grid items stop here)
}

C.TIERS = { 25, 50, 75 } -- borders of norm / poisoning / heavy / critical

return C
