-- ПР-045: две обычные брони Beta 8. Остальные поля — текущая heavy-armor, без сетки.
local definitions = {
	["heavy-armor-2"] = {
		resistances = {
			{ type = "physical", decrease = 8, percent = 35 },
			{ type = "acid", decrease = 7, percent = 35 },
			{ type = "explosion", decrease = 15, percent = 40 },
			{ type = "impact", percent = 100 },
			{ type = "poison", percent = 10 },
			{ type = "fire", percent = 10 },
			{ type = "electric", percent = 30 },
			{ type = "bob-pierce", decrease = 10, percent = 25 },
			{ type = "laser", percent = 10 },
			{ type = "bob-plasma", percent = 50 },
			{ type = "toxin", decrease = 0, percent = 35 },
		},
		recipe = {
			type = "recipe",
			name = "heavy-armor-2",
			category = "crafting",
			enabled = false,
			energy_required = 8,
			ingredients = {
				{ type = "item", name = "bob-invar-alloy", amount = 100 },
				{ type = "item", name = "bob-gunmetal-alloy", amount = 50 },
				{ type = "item", name = "heavy-armor", amount = 1 },
			},
			results = {
				{ type = "item", name = "heavy-armor-2", amount = 1 },
			},
		},
		technology = {
			type = "technology",
			name = "bob-armor-making-3",
			icon = "__reskins-angels__/graphics/technology/smelting/armor/bob-armor-making-3.png",
			icon_size = 256,
			localised_name = { "item-name.heavy-armor-2" },
			prerequisites = { "heavy-armor", "angels-invar-smelting-1", "angels-gunmetal-smelting-1" },
			unit = {
				count = 150,
				time = 30,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
				},
			},
			effects = {
				{ type = "unlock-recipe", recipe = "heavy-armor-2" },
			},
		},
		order = "a-c",
	},
	["heavy-armor-3"] = {
		resistances = {
			{ type = "physical", decrease = 12, percent = 45 },
			{ type = "acid", decrease = 12, percent = 45 },
			{ type = "explosion", decrease = 20, percent = 50 },
			{ type = "impact", percent = 100 },
			{ type = "poison", percent = 25 },
			{ type = "fire", percent = 25 },
			{ type = "electric", decrease = 10, percent = 50 },
			{ type = "bob-pierce", decrease = 20, percent = 30 },
			{ type = "laser", decrease = 10, percent = 30 },
			{ type = "bob-plasma", percent = 100 },
			{ type = "toxin", decrease = 0, percent = 43 },
		},
		recipe = {
			type = "recipe",
			name = "heavy-armor-3",
			category = "crafting",
			enabled = false,
			energy_required = 8,
			ingredients = {
				{ type = "item", name = "bob-titanium-plate", amount = 100 },
				{ type = "item", name = "bob-silicon-nitride", amount = 50 },
				{ type = "item", name = "heavy-armor-2", amount = 1 },
			},
			results = {
				{ type = "item", name = "heavy-armor-3", amount = 1 },
			},
		},
		technology = {
			type = "technology",
			name = "bob-armor-making-4",
			icon = "__reskins-angels__/graphics/technology/smelting/armor/bob-armor-making-4.png",
			icon_size = 256,
			localised_name = { "item-name.heavy-armor-3" },
			prerequisites = { "bob-armor-making-3", "bob-titanium-processing", "bob-ceramics" },
			unit = {
				count = 100,
				time = 30,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
				},
			},
			effects = {
				{ type = "unlock-recipe", recipe = "heavy-armor-3" },
			},
		},
		order = "a-d",
	},
}
local template = data.raw.armor["heavy-armor"]
if not template then return end
for name, definition in pairs(definitions) do
	if not data.raw.armor[name] then
		local armor = table.deepcopy(template)
		armor.name = name
		armor.icon = "__reskins-angels__/graphics/icons/smelting/armor/" .. name .. ".png"
		armor.icon_size = 64
		armor.localised_name = { "item-name." .. name }
		armor.order = definition.order
		armor.resistances = definition.resistances
		if armor.factoriopedia_simulation then
			armor.factoriopedia_simulation.init = armor.factoriopedia_simulation.init:gsub('"heavy%-armor"', '"' .. name .. '"')
		end
		data:extend({ armor, definition.recipe, definition.technology })
	end
end
