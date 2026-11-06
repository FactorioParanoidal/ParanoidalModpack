-- Вкладка «Враги» списков сущностей (выбор приоритетных целей турели, Факториопедия): видимые враги — рядами по
-- категориям (решение пользователя 2026-11-06 по обращениям «враги в фильтре приоритетных целей 2-3 раза» и «общий
-- тип врагов»; одна вкладка). Порядок категорий: кусаки, плеваки, летуны, гнёзда и ульи, черви, люди, роботы, боссы,
-- прочее. Ряд — своя подгруппа: в строке сетки 10 значков, фракция Rampant с уровнями 1–10 занимает ровно строку.
-- Подгруппы paranoidal-enemies-<категория>-<NNN>, порядок "c-<категория>-<NNN>" в группе enemies.
-- Ряды роботов (g) задаёт robotarmy-citadel: он грузится позже (prototypes/list-rows.lua).
-- Меняются только subgroup и order видимых врагов; скрытые (копии вожаков и боссов, служебные) не трогаются.
local M = {}

M.prefix = "paranoidal-enemies-"

-- Фракции Rampant в порядке их описания в RampantFixed (libs/Constants.lua); неизвестные — после, по имени.
local RAMPANT_FACTIONS = {"neutral", "acid", "laser", "fire", "inferno", "wasp", "spawner", "electric", "physical",
	"troll", "poison", "suicide", "nuclear", "energy-thief", "fast", "juggernaut", "arachnids"}
-- Виды Rampant: длинные раньше коротких (super-hive раньше hive); категория и место ряда гнезда внутри фракции.
local RAMPANT_KINDS = {
	{"super-hive", "d", 4}, {"biter-spawner", "d", 1}, {"spitter-spawner", "d", 2}, {"hive", "d", 3},
	{"biter", "a"}, {"spawn", "a"}, {"spitter", "b"}, {"flyer", "c"}, {"worm", "e"},
}
-- Стихии Bob (ряд «basic» — ванильные и базовые Bob).
local BOB_ELEMENTS = {"piercing", "electric", "acid", "explosive", "poison", "fire"}
-- Виды «людей» Big Monsters: обычные, затем боссы; неизвестные — после, по имени.
local PEOPLE = {"melee", "pistol_gunner", "machine_gunner", "sniper", "laser", "electric", "rocket", "grenade",
	"flamethrower", "cannon", "cannon_explosive", "cluster_grenade", "erocket", "nuke_rocket",
	"boss_pistol_gunner", "boss_machine_gunner", "boss_sniper", "boss_laser", "boss_electric", "boss_rocket",
	"boss_grenade", "boss_flamethrower", "boss_cannon_explosive", "boss_cluster_grenade", "boss_erocket",
	"boss_nuke_rocket", "ultimate_boss_cannon"}

local CATEGORIES = {"a", "b", "c", "d", "e", "f", "h", "i"}

local function index_of(list, value)
	for i, v in ipairs(list) do
		if v == value then return i end
	end
	return nil
end

local function rank_of(list, value)
	local i = index_of(list, value)
	return i and string.format("%02d", i) or ("99-" .. value)
end

local function escape(s)
	return (s:gsub("%-", "%%-"))
end

local function ends_with(s, tail)
	return s:sub(-#tail) == tail
end

-- Категория, ряд (ключ сортировки рядов внутри категории) и ключ сортировки значка в ряду; nil — не враг этого прохода.
local function classify(ptype, name, prototype)
	if name:sub(1, 11) == "replicator-" then return nil end -- ряды robotarmy-citadel
	if ptype == "unit" or ptype == "unit-spawner" or ptype == "turret" then
		if prototype.subgroup ~= "enemies" then return nil end -- свои дроиды и турели в других подгруппах
		for _, kind in ipairs(RAMPANT_KINDS) do
			local faction, variation, tier = name:match("^(.-)%-" .. escape(kind[1]) .. "%-v(%d+)%-t(%d+)%-rampant$")
			if faction then
				local row = "1-" .. rank_of(RAMPANT_FACTIONS, faction) .. "-" .. (kind[3] or 0)
				return kind[2], row, string.format("%02d-%02d", tonumber(tier), tonumber(variation))
			end
		end
		local kind, level = name:match("^bm_fake_human_(.+)_(%d+)$")
		if kind then return "f", "1-" .. rank_of(PEOPLE, kind), string.format("%02d", tonumber(level)) end
		level = name:match("^maf%-boss%-biter%-(%d+)$")
		if level then return "h", "1", string.format("%02d", tonumber(level)) end
		level = name:match("^maf%-boss%-acid%-spitter%-(%d+)$")
		if level then return "h", "2", string.format("%02d", tonumber(level)) end
		local zilla
		zilla, level = name:match("^biterzilla([123])(%d+)$")
		if zilla then return "h", (zilla == "3") and "4" or "3", zilla .. "-" .. string.format("%02d", tonumber(level)) end
		level = name:match("^bm%-motherbiterzilla(%d+)$")
		if level then return "h", "4", "4-" .. string.format("%02d", tonumber(level)) end
		local element
		element, level = name:match("^maf%-giant%-(%a+)%-spitter(%d+)$")
		if element then return "h", "5", element .. "-" .. string.format("%02d", tonumber(level)) end
		local big = name:sub(1, 4) == "maf-" or name:sub(1, 4) == "maf_" or name:sub(1, 3) == "bm-"
		local category
		if ptype == "unit-spawner" then
			category = "d"
		elseif ptype == "turret" then
			category = "e"
		elseif ends_with(name, "spitter") then
			category = "b"
		elseif ends_with(name, "biter") then
			category = "a"
		end
		if big and category then return category, "3-big-monsters", prototype.order or name end
		if category then
			element = "basic"
			for _, el in ipairs(BOB_ELEMENTS) do
				if name:find("-" .. el .. "-", 1, true) then element = el end
			end
			local row = "2-" .. ((element == "basic") and "00" or rank_of(BOB_ELEMENTS, element))
			return category, row, (prototype.order or "") .. "-" .. name
		end
		return "i", "9-" .. ptype, prototype.order or name
	elseif ptype == "combat-robot" then
		local source, kind, variation, tier = name:match("^(.-)%-(%a+)%-v(%d+)%-t(%d+)%-drone%-rampant$")
		if source then
			return "i", "3-" .. kind .. "-" .. rank_of(RAMPANT_FACTIONS, source) .. "-" .. source,
				string.format("%02d-%02d", tonumber(tier), tonumber(variation))
		end
	elseif ptype == "radar" then
		local tier = name:match("^crystal%-v(%d+)%-drain%-rampant$")
		if tier then return "i", "1", string.format("%02d", tonumber(tier)) end
		if name:match("^targetDummy%a+%-rampant$") then return "i", "2", name end
	elseif ptype == "spider-vehicle" then
		local level = name:match("^maf_flying_saucer_(%d+)$")
		if level then return "h", "6", string.format("%02d", tonumber(level)) end
		level = name:match("^bm%-spidertron_(%d+)$")
		if level then return "h", "7", string.format("%02d", tonumber(level)) end
	end
	return nil
end

function M.apply(raw, log_fn)
	local rows = {} -- категория → ключ ряда → список {prototype, ключ значка}
	local placed, fallback = 0, {}
	for _, ptype in ipairs({"unit", "unit-spawner", "turret", "combat-robot", "radar", "spider-vehicle"}) do
		for name, prototype in pairs(raw[ptype] or {}) do
			if not prototype.hidden then
				local category, row, key = classify(ptype, name, prototype)
				if category then
					rows[category] = rows[category] or {}
					rows[category][row] = rows[category][row] or {}
					table.insert(rows[category][row], {prototype, key})
					if row:sub(1, 2) == "9-" then fallback[#fallback + 1] = name end
				end
			end
		end
	end
	local subgroups, counts = {}, {}
	for _, category in ipairs(CATEGORIES) do
		local keys = {}
		for row in pairs(rows[category] or {}) do keys[#keys + 1] = row end
		table.sort(keys)
		for number, row in ipairs(keys) do
			local subgroup = string.format("%s%s-%03d", M.prefix, category, number)
			subgroups[#subgroups + 1] = {type = "item-subgroup", name = subgroup, group = "enemies",
				order = string.format("c-%s-%03d", category, number)}
			for _, entry in ipairs(rows[category][row]) do
				entry[1].subgroup = subgroup
				entry[1].order = entry[2]
				placed = placed + 1
			end
		end
		counts[#counts + 1] = category .. "=" .. #keys
	end
	if #subgroups > 0 then data:extend(subgroups) end
	table.sort(fallback)
	log_fn("enemies-tab: " .. placed .. " enemies in " .. #subgroups .. " rows (" .. table.concat(counts, ", ")
		.. "), other: " .. #fallback .. (#fallback > 0 and (" " .. table.concat(fallback, " ", 1, math.min(#fallback, 20))) or ""))
end

return M
