local function create_basic_technology(
    technology_name,
    recipes,
    technology_prerequistes,
    automation_science_pack_ingredient_count,
    icon_name,
    icon_size)
    local technology_effects = {}
    _table.each(
        recipes,
        function(recipe_name)
            table.insert(technology_effects, { type = "unlock-recipe", recipe = recipe_name })
            if not data.raw["recipe"][recipe_name] then
                error("recipe " .. recipe_name .. " not found!")
            end
            data.raw["recipe"][recipe_name].enabled = false
        end
    )
    local technology__unit_ingredients = {}
    local target_automation_science_pack_ingredient_count = 1
    if
        settings.startup["hardcore-mode-for-playing-move-basic-recipe-to-new-basic-technology-hard-start"].value and
        automation_science_pack_ingredient_count > 0
    then
        technology__unit_ingredients = {
            { "salvaged-automation-science-pack", 1 }
        }
        target_automation_science_pack_ingredient_count = automation_science_pack_ingredient_count
    end
    local technology_data = {
        unit = {
            ingredients = technology__unit_ingredients,
            count = target_automation_science_pack_ingredient_count,
            time = math.min(5, math.floor((60 * 2 / automation_science_pack_ingredient_count) + 0.5))
        },
        prerequisites = technology_prerequistes,
        effects = technology_effects,
        energy = 30
    }
    return {
        type = "technology",
        name = technology_name,
        icon_size = icon_size,
        icon = icon_name,
        normal = technology_data,
        expensive = technology_data
    }
end

function create_resource_detected_technology(resource_name, icon_path, icon_size, resource_recipe_name)
    local technology_name = get_resource_detected_technology_name(resource_name)
    log("resource_recipe_name " .. resource_recipe_name)
    return create_basic_technology(
        technology_name,
        { resource_recipe_name, "salvaged-automation-science-pack", "salvaged-assembling-machine" },
        {},
        1,
        icon_path,
        icon_size
    )
end

local function create_basic_technology_tree()
    local basic_recipes = {
        "salvaged-iron-gear-wheel",
        "salvaged-lab",
        "salvaged-assembling-machine",
        "salvaged-generator"
    }
    if settings.startup["hardcore-mode-for-playing-move-basic-recipe-to-new-basic-technology-hard-start"].value then
        table.insert(basic_recipes, "salvaged-automation-science-pack")
    end
    if settings.startup["hardcore-mode-for-playing-use-separated-technologies-for-every-resource"].value then
        table.insert(basic_recipes, "salvaged-radar")
    end
    local water_detected_tech =
        create_resource_detected_technology(
            "water",
            "__base__/graphics/icons/fluid/water.png",
            64,
            create_water_recipe().name
        )
    -- исследование воды с помощью радара
    local coal_detected_tech =
        create_resource_detected_technology("coal", "__base__/graphics/icons/coal.png", 64, create_coal_recipe().name)
    -- исследование дерева
    local wood_detected_tech =
        create_resource_detected_technology("wood", "__base__/graphics/icons/wood.png", 64, create_wood_recipe().name)
    local stone_detected_tech =
        create_resource_detected_technology("stone", "__base__/graphics/icons/stone.png", 64, create_stone_recipe().name)
    data:extend(
        {
            -- корень всего дерева технологий
            create_basic_technology(
                "salvaged-automation-tech",
                basic_recipes,
                nil,
                0,
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
            create_basic_technology(
                "coal-wooden-fluid-handling",
                {},
                { "salvaged-automation-tech", water_detected_tech.name, wood_detected_tech.name },
                2,
                "__base__/graphics/icons/offshore-pump.png",
                64
            ),
            -- непосредственная добыча руд, для которых требуется лишь вода, пара не будет, стартовать придётся в относительно жёстких условиях.
            create_basic_technology(
                "coal-ore-mining",
                { "salvaged-mining-drill" },
                { "coal-wooden-fluid-handling", coal_detected_tech.name },
                3,
                "__base__/graphics/icons/burner-mining-drill.png",
                64
            ),
            -- дробление руды
            create_basic_technology(
                "coal-ore-crushing",
                {},
                { "coal-ore-mining" },
                4,
                "__hardcore-mode-for-playing__/graphics/icons/ore-crusher.png",
                64
            ),
            -- переработка щебня в камень(других вариантов получить обычный камень нет, так как валуны и прочие большие камни не выдают ни угля, ни камня). Ибо остальное ЧИТ
            create_basic_technology(
                "coal-stone-processing",
                {},
                { "coal-ore-crushing", stone_detected_tech.name },
                5,
                "__base__/graphics/icons/stone.png",
                64
            ),
            create_basic_technology(
                "coal-ore-smelting",
                { "stone-furnace" },
                { "coal-ore-crushing", "coal-stone-processing" },
                6,
                "__base__/graphics/icons/stone-furnace.png",
                64
            ),
            create_basic_technology(
                "coal-stone-smelting",
                { "stone-brick" },
                { "coal-ore-smelting", "coal-stone-processing", "coal-wooden-fluid-handling" },
                7,
                "__base__/graphics/icons/stone-brick.png",
                64
            ),
            create_basic_technology("coal-lighting", {}, { "coal-ore-smelting" }, 8,
                "__base__/graphics/icons/small-lamp.png", 64),
            -- производство дерево - самое основное.
            create_basic_technology(
                "basic-wood-production",
                {},
                { "coal-stone-smelting", "coal-ore-smelting", "coal-lighting" },
                9,
                "__base__/graphics/icons/wood.png",
                64
            ),
            create_basic_technology(
                "basic-storage-wood",
                { "wooden-chest" },
                { "basic-wood-production" },
                10,
                "__base__/graphics/icons/wooden-chest.png",
                64
            ),
            -- хранение на железных сундуках
            create_basic_technology(
                "iron-storage",
                { "iron-chest" },
                { "basic-storage-wood", "coal-ore-smelting" },
                11,
                "__base__/graphics/icons/iron-chest.png",
                64
            ),
            create_basic_technology(
                "basic-metal-processing",
                { "iron-stick", "copper-cable", "iron-gear-wheel" },
                { "coal-ore-smelting" },
                12,
                "__base__/graphics/icons/iron-gear-wheel.png",
                64
            ),
            create_basic_technology(
                "electricity-0",
                { "small-electric-pole" },
                { "basic-metal-processing", "basic-wood-production" },
                13,
                "__base__/graphics/icons/small-electric-pole.png",
                64
            ),
            create_basic_technology(
                "basic-electronics",
                {},
                { "basic-metal-processing" },
                14,
                "__base__/graphics/icons/electronic-circuit.png",
                64
            ),
            create_basic_technology(
                "military-0",
                {
                    "pistol",
                    "firearm-magazine"
                },
                { "basic-wood-production", "coal-ore-smelting" },
                15,
                "__base__/graphics/icons/pistol.png",
                64
            ),
            create_basic_technology(
                "burner-ore-mining",
                {
                    "burner-mining-drill"
                },
                { "coal-ore-mining", "basic-electronics" },
                16,
                "__base__/graphics/icons/burner-mining-drill.png",
                64
            ),
            create_basic_technology(
                "water-aggregate-states",
                {},
                { "coal-stone-smelting", "coal-ore-smelting" },
                17,
                "__base__/graphics/icons/fluid/steam.png",
                64
            ),
            create_basic_technology(
                "burner-ore-crushing",
                {},
                { "burner-ore-mining", "coal-ore-crushing", "salvaged-automation-tech" },
                18,
                "__hardcore-mode-for-playing__/graphics/icons/ore-crusher.png",
                64
            ),
            create_basic_technology(
                "basic-logistics",
                {},
                { "basic-metal-processing", "basic-electronics" },
                19,
                "__base__/graphics/technology/logistics-1.png",
                256
            ),
            create_basic_technology(
                "automation-science-pack",
                {
                    "automation-science-pack"
                },
                {
                    "basic-electronics",
                    "coal-ore-smelting",
                    "basic-metal-processing",
                    "coal-stone-smelting",
                    "military-0",
                    "burner-ore-mining",
                    "burner-ore-crushing",
                    "basic-logistics"
                },
                20,
                "__base__/graphics/icons/automation-science-pack.png",
                64
            ),
            create_basic_technology(
                "repair-pack",
                {},
                {
                    "automation-science-pack"
                },
                21,
                "__base__/graphics/icons/repair-pack.png",
                64
            )
        }
    )
end
create_basic_technology_tree()
