-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobores"] then
	return
end

local ores = {
	-- Pure Bob's
	"bob-ground-water",
	"bob-lithia-water",
	"bob-gem-ore",
	"bob-lead-ore",
	"bob-rutile-ore",
	"bob-sulfur",
	"bob-thorium-ore",
	"bob-tin-ore",
	"bob-bauxite-ore",
	"bob-cobalt-ore",
	"bob-gold-ore",
	"bob-nickel-ore",
	"bob-quartz",
	"bob-silver-ore",
	"bob-tungsten-ore",
	"bob-zinc-ore",
}

for _, name in pairs(ores) do
	-- Check for autoplace controls, skip if it does not exist
	local control = data.raw["autoplace-control"][name]
	if not control then
		goto continue
	end

	-- Setup rich text localized name
	control.localised_name = { "", "[entity=" .. name .. "] ", { "entity-name." .. name } }

	::continue::
end
