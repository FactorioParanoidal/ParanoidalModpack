local platform = table.deepcopy(data.raw.tile["stone-path"])
platform.name = "micromario-platform"
platform.minable.result = "micromario-platform"
for i = 1, 3 do
	platform.variants.main[i].hr_version.picture = "__platforms__/graphics/terrain/hr-platform-" .. i .. "-" .. string.lower(settings.startup["platform-theme"].value) .. ".png"
	platform.variants.main[i].picture = "__platforms__/graphics/terrain/platform-" .. i .. "-" .. string.lower(settings.startup["platform-theme"].value) .. ".png"
    platform.variants.main[i].count = 1
    platform.variants.main[i].hr_version.count = 1 
end
platform.variants.inner_corner.hr_version.picture = "__platforms__/graphics/terrain/hr-platform-inner-corner-" .. string.lower(settings.startup["platform-theme"].value) .. ".png"
platform.variants.inner_corner.picture = "__platforms__/graphics/terrain/platform-inner-corner-" .. string.lower(settings.startup["platform-theme"].value) .. ".png"
platform.variants.side.hr_version.picture = "__platforms__/graphics/terrain/hr-platform-side-" .. string.lower(settings.startup["platform-theme"].value) .. ".png"
platform.variants.side.picture = "__platforms__/graphics/terrain/platform-side-" .. string.lower(settings.startup["platform-theme"].value) .. ".png"

local immortal_platform = table.deepcopy(data.raw.tile["grass-1"])
immortal_platform.name = "micromario-immortal-platform"
immortal_platform.autoplace = nil
immortal_platform.can_be_part_of_blueprint = true
immortal_platform.transitions = platform.transitions
immortal_platform.transitions_between_transitions = platform.transitions_between_transitions
immortal_platform.variants = platform.variants
immortal_platform.walking_sound = platform.walking_sound
immortal_platform.layer = platform.layer

data:extend({
	{
		type = "recipe",
		name = "micromario-platform",
		enabled = false,
		energy_required = 0.5,
		ingredients = {
			{"iron-stick", 4},
			{"steel-plate", 2},
			{"stone-brick", 6}
		},
		result = "micromario-platform"
	},
	{
		icon = "__platforms__/graphics/icons/platform.png",
		icon_size = 32,
		name = "micromario-platform",
		order = "c[landfill]-a[dirt]",
		place_as_tile = {condition = {"ground-tile"}, condition_size = 1, result = "micromario-platform"},
		stack_size = 1000,
		subgroup = "terrain",
		type = "item"
	},
	{
		name = "micromario-platform",
		type = "technology",
		effects = {{recipe = "micromario-platform", type = "unlock-recipe"}},
		prerequisites = {"landfill", "steel-processing"},
		icon = "__platforms__/graphics/icons/platform-technology.png",
		icon_size = 128,
		unit = 
		{
			time = 30,
			count = 100,
			ingredients = 
			{
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},			
			}
		}
	},
	platform,
	immortal_platform
})

if mods.SeaBlock then
	data.raw.technology["micromario-platform"].unit.ingredients = {{"automation-science-pack", 1}}
end