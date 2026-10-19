-- Rank thresholds. Paranoidal fork: values and level-up formula of heroturrets 9.1.11 (Beta 8).
-- The runtime spreads them over the rank names (prototypes/scripts/turrets.lua).
if not heroturrets.defines then heroturrets.defines = {} end
local D = heroturrets.defines

-- Kills / damage of the four reference ranks before the level-up modifier.
D.turret_initial_kills = {50, 250, 500, 5000}
D.turret_initial_damage = {10000, 50000, 100000, 1000000}

-- Beta 8: value + floor(value * modifier / 10) * 100, modifier = setting / 100.
local percent = settings.startup["heroturrets-setting-level-up-modifier"].value / 100
local function level_up(value)
	return value + (math.floor((value * percent) / 10) * 100)
end

D.turret_levelup_kills = {}
D.turret_levelup_damage = {}
for i = 1, 4 do
	D.turret_levelup_kills[i] = level_up(D.turret_initial_kills[i])
	D.turret_levelup_damage[i] = level_up(D.turret_initial_damage[i])
end
