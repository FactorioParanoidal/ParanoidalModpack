-- Every planet mod has defined its items and science packs by now.
local names = require("shared.names")
local raw = data.raw

local function exists(name)
	return raw.item[name] ~= nil or raw.tool[name] ~= nil
end

-- One material of every planet of the build (absent ones are skipped with a log line).
local PLANET_PARTS = {
	{"paranoidal-pobedit", 100}, -- Vulcanus (pobedit)
	{"supercapacitor", 100}, -- Fulgora
	{"carbon-fiber", 100}, -- Gleba
	{"paranoidal-ice-silver", 100}, -- Aquilo (ice silver)
	{"aluminum-plate", 200}, -- Muluna (lunite plate)
	{"gold-plate", 100}, -- Secretas (aurite plate)
	{"silicon-carbide", 100}, -- Moshine (carborundum)
	{"maraxsis-glass-panes", 100}, -- Maraxsis (triplex)
}

-- Every science pack of the build, in research order.
local PACKS = {"automation-science-pack", "logistic-science-pack", "military-science-pack", "chemical-science-pack",
	"production-science-pack", "utility-science-pack", "space-science-pack", "metallurgic-science-pack",
	"electromagnetic-science-pack", "agricultural-science-pack", "cryogenic-science-pack", "interstellar-science-pack",
	"hydraulic-science-pack", "golden-science-pack", "promethium-science-pack"}

local missing = {}
local recipe = raw.recipe[names.ark]
for _, part in ipairs(PLANET_PARTS) do
	if exists(part[1]) then
		table.insert(recipe.ingredients, {type = "item", name = part[1], amount = part[2]})
	else
		missing[#missing + 1] = part[1]
	end
end

local technology = raw.technology[names.technology]
local ingredients = {}
for _, pack in ipairs(PACKS) do
	if exists(pack) then
		ingredients[#ingredients + 1] = {pack, 1}
	else
		missing[#missing + 1] = pack
	end
end
technology.unit.ingredients = ingredients

-- The Ark is a pass, not a material: always of normal quality (registry of ic-more-qualities).
local normal = raw["mod-data"] and raw["mod-data"]["ic-normal-result"]
if normal then normal.data.recipes[names.ark] = true end

if #missing > 0 then log("paranoidal-true-ending: not in the build, skipped: " .. table.concat(missing, ", ")) end
