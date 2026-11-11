-- Balance of the three cargo teleporters; read by the data stage and by control.lua (one source of numbers).
-- Every tier: half the recharge time, twice the power, more slots; the energy of one send stays 15 GJ.
-- receive_mw: constant draw of a receiver (user 2026-11-11: grows with the tier); without it a receiver takes no cargo.
-- Tier 1 belongs to Muluna, tier 2 to Vulcanus, tier 3 to Fulgora (technologies and prices: prototypes/).
local M = {}

M.tiers = {
	{
		name = "ptl-teleporter-1",
		charger = "ptl-teleporter-1-charger",
		flash = "ptl-teleporter-1-flash",
		slots = 48,
		power_mw = 750,
		receive_mw = 50,
		cycle_s = 20,
		health = 1000,
		tint = nil,
		glow = {r = 0.25, g = 1, b = 0.8, a = 1},
	},
	{
		name = "ptl-teleporter-2",
		charger = "ptl-teleporter-2-charger",
		flash = "ptl-teleporter-2-flash",
		slots = 80,
		power_mw = 1500,
		receive_mw = 100,
		cycle_s = 10,
		health = 1500,
		tint = {r = 0.62, g = 0.82, b = 1, a = 1},
		glow = {r = 0.35, g = 0.6, b = 1, a = 1},
	},
	{
		name = "ptl-teleporter-3",
		charger = "ptl-teleporter-3-charger",
		flash = "ptl-teleporter-3-flash",
		slots = 120,
		power_mw = 3000,
		receive_mw = 200,
		cycle_s = 5,
		health = 2000,
		tint = {r = 1, g = 0.7, b = 1, a = 1},
		glow = {r = 1, g = 0.4, b = 1, a = 1},
	},
}

M.by_name = {}
M.by_charger = {}
M.names = {}
M.charger_names = {}
for index, tier in ipairs(M.tiers) do
	tier.index = index
	tier.energy_j = tier.power_mw * 1000000 * tier.cycle_s
	-- A receiver is a native consumer (J per tick) with a buffer of 4 ticks: its level tells whether the network
	-- supplies it (the same scheme as ic-more-qualities' workshop power).
	tier.receive_tick_j = tier.receive_mw * 1000000 / 60
	tier.receive_buffer_j = tier.receive_tick_j * 4
	M.by_name[tier.name] = tier
	M.by_charger[tier.charger] = tier
	M.names[#M.names + 1] = tier.name
	M.charger_names[#M.charger_names + 1] = tier.charger
end

return M
