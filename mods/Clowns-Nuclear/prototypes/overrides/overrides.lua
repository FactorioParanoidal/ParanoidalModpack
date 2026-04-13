local CF = clowns.functions
data.raw.recipe["atomic-bomb"].icons =
{
	{
		icon = "__base__/graphics/icons/atomic-bomb.png",
		icon_size = 64,
	},
	{
		icon = "__base__/graphics/icons/uranium-235.png",
		icon_size = 64,
		--tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
		scale = 0.2, --0.4
		shift = { -10, 10 },
	},

}
data.raw.recipe["atomic-bomb"].icon_size = 32
data.raw["assembling-machine"]["centrifuge"].ingredient_count = 5

CF.add_to_table("nuclear-fuel-reprocessing",{type="item",name="plutonium-239",amount=5},"res")
CF.replace_ing("nuclear-fuel-reprocessing","uranium-238",{type="item", name = "uranium-238", amount = 3},"res")
if mods["angelspetrochem"] then
CF.add_prereq("angels-nuclear-fuel", "kovarex-enrichment-process")
end

data.raw.recipe["nuclear-fuel-reprocessing"].icons = { { icon = "__Clowns-Nuclear__/graphics/icons/nuclear-fuel-reprocessing.png", icon_size = 32 } }
data.raw.recipe["nuclear-fuel-reprocessing"].icon_size = 32
data.raw.recipe["nuclear-fuel-reprocessing"].icon = nil
data.raw.recipe["nuclear-fuel-reprocessing"].subgroup = "clowns-nuclear-reprocessing"
data.raw.recipe["nuclear-fuel-reprocessing"].order = "a[uranium]-a"

--REBUILD NUCLEAR POWER TECHNOLOGY
CF.add_unlock("nuclear-power","nuclear-reactor")
--CF.add_unlock("nuclear-power","centrifuge")
CF.add_unlock("uranium-processing","clowns-centrifuging-20pc-ore")
CF.add_unlock("uranium-processing","clowns-centrifuging-35pc")
CF.add_unlock("nuclear-power","uranium-fuel-cell")
CF.add_unlock("nuclear-power","heat-exchanger")
CF.add_unlock("nuclear-power","steam-turbine")
CF.remove_unlock("uranium-processing","uranium-fuel-cell")
CF.add_prereq("mixed-oxide-fuel", "nuclear-fuel-reprocessing")

if mods["bobpower"] then
	CF.add_prereq("nuclear-power", "bob-boiler-2")
	CF.add_prereq("nuclear-power", "bob-steam-engine-3")
	CF.add_prereq("nuclear-power", "bob-cobalt-processing")
else
	CF.add_unlock("nuclear-power","heat-pipe")
end

if mods["bobequipment"] then
	CF.add_prereq("thermonuclear-bomb", "bob-fission-reactor-equipment-2")
end

if mods["bobmodules"] then
	CF.add_prereq("thermonuclear-bomb", "bob-speed-module-5")
	CF.add_prereq("thermonuclear-bomb", "bob-productivity-module-5")
	CF.add_prereq("thermonuclear-bomb", "bob-efficiency-module-5")
	bobmods.lib.tech.add_science_pack("thermonuclear-bomb", "space-science-pack", 1)
end
--CHANGE FEATURES OF URANIUM-238 AND URANIUM-235

data.raw.item["uranium-238"].subgroup = "clowns-uranium-centrifuging"
data.raw.item["uranium-235"].subgroup = "clowns-uranium-centrifuging"
data.raw.item["uranium-238"].localised_name = { "override-item-name.uranium-238" }
data.raw.item["uranium-235"].localised_name = { "override-item-name.uranium-235" }
data.raw.item["uranium-238"].order = "a"
data.raw.item["uranium-235"].order = "i"
data.raw.item["uranium-238"].icon = nil
data.raw.item["uranium-235"].icon = nil
data.raw.item["uranium-235"].icon_size = nil
data.raw.item["uranium-238"].icon_size = nil
data.raw.item["uranium-238"].icons =
{
	{
		icon = "__base__/graphics/icons/uranium-238.png",
		icon_size = 64,
		icon_mipmaps = 4,
		scale = 0.9
	},
	{
		icon = "__Clowns-Nuclear__/graphics/icons/0%.png",
		icon_size = 32,
		scale = 1.2,
		shift = { -12, -12 },
	},
}

data.raw.item["uranium-235"].icons =
{
	{
		icon = "__base__/graphics/icons/uranium-235.png",
		icon_size = 64,
		icon_mipmaps = 4,
		scale = 0.9
	},
	{
		icon = "__Clowns-Nuclear__/graphics/icons/80%.png",
		icon_size = 32,
		scale = 1.2,
		shift = { -12, -12 },
	},
}
CF.replace_ing("uranium-fuel-cell", "uranium-235", { type = "item", name = "35pc-uranium", amount = 20 }, "ing")
CF.remove_res("uranium-fuel-cell", "uranium-238", "ing")
--ADD ARTILLERY SHELL RECIPES TO APPROPRIATE TECHS

if settings.startup["artillery-shells"].value == true then
	CF.add_unlock("atomic-bomb", "artillery-shell-nuclear")
	CF.add_unlock("thermonuclear-bomb", "artillery-shell-thermonuclear")
end
CF.add_unlock("atomic-bomb","plutonium-atomic-bomb")
CF.add_prereq("atomic-bomb","nuclear-fuel-reprocessing")

data.raw.item["depleted-uranium-fuel-cell"].subgroup = "clowns-nuclear-cells"
data.raw.item["depleted-uranium-fuel-cell"].order = "b-a"

data.raw.item["uranium-fuel-cell"].subgroup = "clowns-nuclear-cells"
data.raw.item["uranium-fuel-cell"].order = "a-a"

data.raw.recipe["nuclear-fuel-reprocessing"].subgroup = "clowns-nuclear-cells"
data.raw.recipe["nuclear-fuel-reprocessing"].order = "c-a-a"

CF.replace_ing("nuclear-fuel", "uranium-235", { type = "item", name = "55pc-uranium", amount = 1 }, "ing")

data.raw.item["nuclear-fuel"].order = "a-a"
data.raw.item["nuclear-fuel"].subgroup = "clowns-nuclear-fuels"

CF.replace_ing("uranium-processing", "uranium-ore", { type = "item", name = "uranium-ore", amount = 50 }, "ing")
