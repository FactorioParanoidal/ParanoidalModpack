local function createBasicTechnology(
	technology_name,
	recipes,
	technology_prerequistes,
	automation_science_pack_ingredient_count,
	icon_name,
	icon_size
)
	local technology_effects = {}
	_table.each(recipes, function(recipe_name)
		table.insert(technology_effects, { type = "unlock-recipe", recipe = recipe_name })
		if not data.raw["recipe"][recipe_name] then
			error("recipe " .. recipe_name .. " not found!")
		end
		data.raw["recipe"][recipe_name].enabled = false
	end)
	return {
		type = "technology",
		name = technology_name,
		icon_size = icon_size,
		icon = icon_name,
		normal = {
			unit = {
				ingredients = {
					{ "salvaged-automation-science-pack", 1 },
				},
				count = automation_science_pack_ingredient_count,
				time = 60,
			},
			prerequisites = technology_prerequistes,
			effects = technology_effects,
			energy = 30,
		},
		expensive = {
			unit = {
				ingredients = {
					{ "salvaged-automation-science-pack", 1 },
				},
				count = automation_science_pack_ingredient_count,
				time = 60,
			},
			prerequisites = technology_prerequistes,
			effects = technology_effects,
			energy = 30,
		},
	}
end

function createResourceDetectedTechnology(resource_name, icon_path, icon_size, resource_recipe_name)
	local technology_name = resource_name .. DETECTED_RESOURCE_TECHNOLOGY_SUFFIX
	log("resource_recipe_name " .. resource_recipe_name)
	local result = createBasicTechnology(
		technology_name,
		{ resource_recipe_name },
		{ "salvaged-automation-tech" },
		1,
		icon_path,
		icon_size
	)
	result.hidden = true
	return result
end
local function createBasicTechnologyTree()
	local basic_recipes = {
		"salvaged-iron-gear-wheel",
		"salvaged-lab",
		"salvaged-assembling-machine",
		"salvaged-automation-science-pack",
		"salvaged-generator",
	}
	local water_detected_tech = createResourceDetectedTechnology(
		"water",
		"__base__/graphics/icons/fluid/water.png",
		64,
		createWaterRecipe().name
	)
	-- исследование воды с помощью радара
	local coal_detected_tech =
		createResourceDetectedTechnology("coal", "__base__/graphics/icons/coal.png", 64, createCoalRecipe().name)
	-- исследование дерева
	local wood_detected_tech =
		createResourceDetectedTechnology("wood", "__base__/graphics/icons/wood.png", 64, createWoodRecipe().name)
	local stone_detected_tech =
		createResourceDetectedTechnology("stone", "__base__/graphics/icons/stone.png", 64, createStoneRecipe().name)
	data:extend({
		-- корень всего дерева технологий, даёт возможность добывать уголь.
		createBasicTechnology(
			"salvaged-automation-tech",
			basic_recipes,
			nil,
			1,
			"__base__/graphics/icons/assembling-machine-1.png",
			64
		),
		water_detected_tech,
		coal_detected_tech,
		wood_detected_tech,
		stone_detected_tech,
		-- исследование воды с помощью радара
		--[[ для добычи руды нужна вода, правда ты не сможешь ничего собрать, трубы у тебя будут, но не будет ресурсов для постройки труб.
		На самом деле  деревянные трубы очень пригодятся, ведь железо на ранних этапах будет КРАЙНЕ ДОРОГИМ УДОВОЛЬСТВИЕМ, а разводку труб как-то делать придётся.
		Так что технология только с виду бесполезная, да и медь будет уходить вовсе не на трубы, месторождения будут не такие богатые, чтобы не было перевода сразу всего на медь.]]
		createBasicTechnology(
			"coal-wooden-fluid-handling",
			{},
			{ "salvaged-automation-tech", water_detected_tech.name, wood_detected_tech.name },
			2,
			"__base__/graphics/icons/offshore-pump.png",
			64
		),
		-- непосредственная добыча руд, для которых требуется лишь вода, пара не будет, стартовать придётся в относительно жёстких условиях.
		createBasicTechnology(
			"coal-ore-mining",
			{ "salvaged-mining-drill" },
			{ "coal-wooden-fluid-handling", coal_detected_tech.name },
			3,
			"__base__/graphics/icons/burner-mining-drill.png",
			64
		),
		-- дробление руды
		createBasicTechnology(
			"coal-ore-crushing",
			{},
			{ "coal-ore-mining", stone_detected_tech.name },
			4,
			"__hardcore-mode-for-playing__/graphics/icons/ore-crusher.png",
			64
		),
		-- переработка щебня в камень(других вариантов получить обычный камень нет, так как валуны и прочие большие камни не выдают ни угля, ни камня). Ибо остальное ЧИТ
		createBasicTechnology(
			"coal-stone-processing",
			{},
			{ "coal-ore-crushing" },
			5,
			"__base__/graphics/icons/stone.png",
			64
		),
		createBasicTechnology(
			"coal-ore-smelting",
			{ "stone-furnace" },
			{ "coal-ore-crushing", "coal-stone-processing" },
			6,
			"__base__/graphics/icons/stone-furnace.png",
			64
		),
		createBasicTechnology(
			"coal-stone-smelting",
			{ "stone-brick" },
			{ "coal-ore-smelting", "coal-stone-processing" },
			7,
			"__base__/graphics/icons/stone-brick.png",
			64
		),
		createBasicTechnology(
			"coal-lighting",
			{},
			{ "coal-ore-smelting" },
			8,
			"__base__/graphics/icons/small-lamp.png",
			64
		),
		-- производство дерево - самое основное.
		createBasicTechnology(
			"basic-wood-production",
			{},
			{ "coal-stone-smelting", "coal-ore-smelting", "coal-lighting" },
			9,
			"__base__/graphics/icons/wood.png",
			64
		),
		createBasicTechnology(
			"basic-storage-wood",
			{ "wooden-chest" },
			{ "basic-wood-production" },
			10,
			"__base__/graphics/icons/wooden-chest.png",
			64
		),
		-- хранение на железных сундуках
		createBasicTechnology(
			"iron-storage",
			{ "iron-chest" },
			{ "basic-storage-wood", "coal-ore-smelting" },
			11,
			"__base__/graphics/icons/iron-chest.png",
			64
		),
		createBasicTechnology(
			"basic-metal-processing",
			{ "iron-stick", "copper-cable", "iron-gear-wheel" },
			{ "coal-ore-smelting" },
			12,
			"__base__/graphics/icons/iron-gear-wheel.png",
			64
		),
		createBasicTechnology(
			"electricity-0",
			{
				"small-electric-pole",
			},
			{ "basic-metal-processing", "basic-wood-production" },
			13,
			"__base__/graphics/icons/small-electric-pole.png",
			64
		),
		createBasicTechnology(
			"basic-electronics",
			{},
			{ "basic-metal-processing" },
			14,
			"__base__/graphics/icons/electronic-circuit.png",
			64
		),
		createBasicTechnology("military-0", {
			"pistol",
			"firearm-magazine",
		}, { "basic-wood-production", "coal-ore-smelting" }, 15, "__base__/graphics/icons/pistol.png", 64),
		createBasicTechnology("burner-ore-mining", {
			"burner-mining-drill",
		}, { "coal-ore-mining", "basic-electronics" }, 16, "__base__/graphics/icons/burner-mining-drill.png", 64),
		createBasicTechnology(
			"burner-ore-crushing",
			{},
			{ "burner-ore-mining", "coal-ore-crushing", "salvaged-automation-tech" },
			17,
			"__hardcore-mode-for-playing__/graphics/icons/ore-crusher.png",
			64
		),
		createBasicTechnology(
			"basic-logistics",
			{},
			{ "basic-metal-processing", "basic-electronics" },
			18,
			"__base__/graphics/technology/logistics-1.png",
			256
		),
		createBasicTechnology("automation-science-pack", {
			"automation-science-pack",
		}, {
			"basic-electronics",
			"coal-ore-smelting",
			"basic-metal-processing",
			"coal-stone-smelting",
			"military-0",
			"burner-ore-mining",
			"burner-ore-crushing",
			"basic-logistics",
		}, 19, "__base__/graphics/icons/automation-science-pack.png", 64),
		createBasicTechnology("repair-pack", {}, {
			"automation-science-pack",
		}, 20, "__base__/graphics/icons/repair-pack.png", 64),
	})
end

createBasicTechnologyTree()
