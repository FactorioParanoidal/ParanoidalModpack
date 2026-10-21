-- Shield names and formulas shared by the data stage (prototypes) and the control stage (runtime).
-- Everything here is a pure function of the startup settings, so it is identical on every peer.
-- The repair side of the defence tower has its own constants in shared.lua.
local M = {}

M.root = "__defence-tower-reforged__"
M.tower = "repair-turret" -- the defence tower (container); the ID of Repair Turret is kept
M.tech_base = "turret-shields-base" -- "Shield generation"
M.tech_size = "turret-shields-size"
M.tech_rate = "turret-shields-speed"
M.tool = "kts-shield-toggle"
M.buffer_prefix = "kts-gen-" -- hidden electric-energy-interface of a tower shield: kts-gen-<size>-<rate>
M.bar_short = "kts-bar-" -- sprites kts-bar-0 .. kts-bar-9 (shield charge bar on the tower)
M.bar_short_steps = 9
M.hit_animation = "kts-shield-hit"
M.hit_frames = 9
M.hit_speed = 0.3 -- frames per tick, the same as the 1.1 smoke
M.hit_smoke = "kts-shield-smoke"
M.turret_types = {"ammo-turret", "electric-turret", "fluid-turret"}

-- Upper bound for generated energy values: absurd setting combinations (100 levels with one step
-- per order of magnitude) would otherwise overflow into "inf" prototype strings.
local MAX_ENERGY = 1e30

function M.read(startup)
	local function value(name)
		return startup[name].value
	end
	return {
		kj_per_hp = value("kts-energy-per-hp"),
		base_hp = value("kts-base-shield"),
		base_rate = value("kts-base-recharge"),
		drain = value("kts-idle-drain") / 100,
		research = value("kts-research"),
		size_steps = value("kts-size-steps"),
		rate_steps = value("kts-rate-steps"),
		max_level = value("kts-max-level"),
		share = value("kts-tower-share"),
	}
end

-- Value after `done` completed levels of an upgrade technology; `steps` levels per order of
-- magnitude (the KingsTurret formula). done = 0 is the base value.
function M.level_value(base, steps, done)
	if done <= 0 then
		return base
	end
	local step = (base * 10 ^ math.ceil(done / steps) - base) / steps
	return base + step * ((done - 1) % steps + 1)
end

function M.buffer_name(size, rate)
	return M.buffer_prefix .. size .. "-" .. rate
end

-- Shield of one tower for the given completed levels of the capacity and the regeneration
-- technologies: the shields of cfg.share turrets of the 1.1 mod pooled in one buffer.
-- hp: shield points; hps: recharge in points per second; buffer: J; recharge, drain: W.
function M.stats(cfg, size, rate)
	local hp = M.level_value(cfg.base_hp, cfg.size_steps, size) * cfg.share
	local hps = M.level_value(cfg.base_rate, cfg.rate_steps, rate) * cfg.share
	local j_per_hp = cfg.kj_per_hp * 1000
	return {
		hp = hp,
		hps = hps,
		buffer = math.min(hp * j_per_hp, MAX_ENERGY),
		recharge = math.min(hps * j_per_hp, MAX_ENERGY),
		drain = math.min(hp * cfg.drain * 1000, MAX_ENERGY),
	}
end

local PREFIXES = {"", "k", "M", "G", "T", "P", "E", "Z", "Y"}

-- Prototype energy string without exponent notation: 5e6, "J" -> "5.000000MJ".
function M.energy(value, unit)
	local i = 1
	while value >= 1000 and i < #PREFIXES do
		value = value / 1000
		i = i + 1
	end
	return string.format("%.6f", value) .. PREFIXES[i] .. unit
end

return M
