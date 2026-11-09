if settings.startup["enable-nav-beacon"].value == true then
    
    
    require("__core__/lualib/util.lua")
    local flib_bounding_box = Muluna.flib_bounding_box


   







    local radarEntity = table.deepcopy(data.raw.radar.radar)
    local radarItem = table.deepcopy(data.raw.item.radar)
    local radarRecipe = table.deepcopy(data.raw.recipe.radar)
    local radarTech = table.deepcopy(data.raw.technology.radar)

    ---@type ItemPrototype
    local navBeaconItem = util.merge({
        radarItem,
        {
            name = "muluna-satellite-radar",
            place_result = "muluna-satellite-radar",
            subgroup = "space-platform",
            order = "q[nav-beacon]",
            icon = mods["space-exploration-graphics"] and "__space-exploration-graphics__/graphics/icons/telescope-radio.png" or data.raw["item"]["radar"].icon, -- Paranoidal fork: radar icon
            localised_description = { "item-description.muluna-satellite-radar"},
            icon_size = 64,
            stack_size = 10,
        }
    })
    navBeaconItem.order = navBeaconItem.order .. "-z"
    navBeaconItem.weight = 2000*kg --One standard rocket on Muluna

    ---@type RadarPrototype
    local navBeaconEntity = util.merge({
        radarEntity,
        {
            name = "muluna-satellite-radar",
            subgroup = "space-platform",
            order = "q[nav-beacon]",
            module_slots=0,
            distribution_effectivity = 0,
            distribution_effectivity_bonus_per_quality_level = 0,
            supply_area_distance = 0,
            collision_box = {{-3.9, -3.9}, {3.9, 3.9}},
            selection_box = {{-4, -4}, {4, 4}},
            --selection_box = flib_bounding_box.resize(radarEntity.selection_box,3),
            --collision_box = flib_bounding_box.resize(radarEntity.collision_box,3),
            minable = { mining_time = 2, result = "muluna-satellite-radar" },
            fast_replaceable_group = "muluna-satellite-radar",
            energy_per_sector = "1TJ",
            
            --max_distance_of_sector_revealed = 1,
            --max_distance_of_nearby_sector_revealed = 15,
            energy_per_nearby_scan = "1kJ",
            --localised_description = { "entity-description.muluna-satellite-radar"},
            localised_description = { "item-description.muluna-satellite-radar"},
            surface_conditions = {
                {
                    property = "gravity",
                    min = 0,
                    max = 0,
                }
            },
            -- The radar has a deliberate 1 MW passive draw to keep the
            -- satellite online. Scans are charged separately by
            -- scripts/nav-beacon.lua from the energy buffer.
            energy_usage = "1MW",
            icon = "__muluna-graphics__/graphics/icons/nav-beacon-icon.png",
            icon_size = 64,
            rotation_speed = 0.005,
            corpse = "medium-remnants",
            
            
            energy_source = {
                type = "electric",
                usage_priority = "secondary-input",
                buffer_capacity = 3*settings.startup["platform-power-consumption"].value .. "MJ",
                output_flow_limit = "0MW",
                -- Keep the input limit above the 1 MW passive draw even at the
                -- lowest platform-power-consumption setting, otherwise the
                -- buffer could never stay charged.
                input_flow_limit = math.max(3*settings.startup["platform-power-consumption"].value, 2) .. "MW",
            },
            custom_tooltip_fields = {
                {},
                {},
            }

        }
    })
    local navBeaconData = {
        type = "mod-data",
        name = "muluna-satellite-radar",
        data = {
            entities = {}, --List of satellite radar entities and associated stats
            energy_per_scan_expression = "base / (1 + 0.3 * quality_level)", --Formula evaluating energy usage per scan.
            scan_size_expression = "base * (1 + 0.3 * quality_level)", -- Formula evaluating tiles scanned per scan.
        }
    }
    navBeaconData.data.entities[navBeaconEntity.name] =
    {
        name = navBeaconEntity.name,
        energy_per_scan = settings.startup["platform-power-consumption"].value,
        scan_area = 100
    }
    navBeaconEntity.graphics_set = nil
    -- Keep the base radar's circuit connector (and its surface/universe circuit
    -- network behaviour) instead of removing it like accumulator-specific
    -- fields. The only field inherited from the radar that is not wanted here
    -- is `next_upgrade`.
    navBeaconEntity.next_upgrade = nil

    -- Radar prototypes have no chargable_graphics, so use the telescope radio
    -- sprite sheet as a rotating radar picture when its graphics mod is
    -- available. Otherwise the vanilla radar pictures are used.
    if mods["space-exploration-graphics-4"] then
        navBeaconEntity.pictures = {
            layers = {
                {
                    filename = "__space-exploration-graphics-4__/graphics/entity/telescope-radio/telescope-radio.png",
                    priority = "high",
                    width = 4688/8,
                    height = 5440/8,
                    direction_count = 64,
                    line_length = 8,
                    shift = util.by_pixel(1*8/9, -26*8/9),
                    scale = 0.5*8/9,
                    apply_projection = false,
                },
                {
                    filename = "__space-exploration-graphics-4__/graphics/entity/telescope-radio/telescope-radio-shadow.png",
                    priority = "high",
                    draw_as_shadow = true,
                    width = 5440/8,
                    height = 4800/8,
                    direction_count = 64,
                    line_length = 8,
                    shift = util.by_pixel(25*8/9, 19*8/9),
                    scale = 0.5*8/9,
                    apply_projection = false,
                }
            }
        }
    end
    local navBeaconEntity_Platform = table.deepcopy(navBeaconEntity)
    navBeaconEntity_Platform.name = navBeaconEntity_Platform.name .. "-platform"
    navBeaconEntity_Platform.localised_name = { "entity-name.muluna-satellite-radar" }
    navBeaconEntity_Platform.energy_usage = settings.startup["platform-power-consumption"].value .. "MW"

    -- local navBeaconEntity_Planet = table.deepcopy(navBeaconEntity)
    -- navBeaconEntity_Planet.name = navBeaconEntity_Planet.name .. "-planet"
    -- --navBeaconEntity_Planet.localised_name = { "", { "entity-name.nav-beacon" }, " - ", { "entity-name.planet-mode" } }
    -- navBeaconEntity_Planet.energy_usage = settings.startup["platform-power-consumption"].value .. "MW"

    --nil it before merge to replace
    radarRecipe.ingredients = nil
    radarRecipe.results = nil

    ---@type RecipePrototype
    local navBeaconRecipe = util.merge({
        radarRecipe,
        {
            name = "muluna-satellite-radar",
            subgroup = "space-platform",
            order = "q[nav-beacon]",
            energy_required = 20,
            ingredients =
            {
                { type = "item", name = "processing-unit", amount = 500 },
                { type = "item", name = "radar",           amount = 250 },
                { type = "item", name = "muluna-telescope",          amount = 50 },
                { type = "item", name = "superconductor",          amount = 500 },
                { type = "item", name = "aluminum-plate",          amount = 500 },
                { type = "item", name = "silicon-cell",          amount = 100 },
            },
            results = { { type = "item", name = "muluna-satellite-radar", amount = 1 } },
        }
    })

    --nil it before merge to replace
    radarTech.effects = nil
    radarTech.prerequisites = nil
    radarTech.unit = nil
    ---@type RecipePrototype
    local navBeaconTech = util.merge({
        radarTech,
        {
            name = "muluna-satellite-radar",
            localised_name = {"entity-name.muluna-satellite-radar"},
            localised_description = { "item-description.muluna-satellite-radar"},
            --localised_description={"entity-description.muluna-satellite-radar"},
            effects =
            {
                {
                    type = "unlock-recipe",
                    recipe = "muluna-satellite-radar"
                }
            },
            prerequisites = { "radar", "interstellar-science-pack", "metallurgic-science-pack", "electromagnetic-science-pack"},
            unit =
            {
                count = 3000,
                ingredients = {
                    { "automation-science-pack", 1 },
                    { "logistic-science-pack",   1 },
                    { "chemical-science-pack",   1 },
                    { "military-science-pack",      1 },
                    { "utility-science-pack",      1 },
                    { "space-science-pack",      1 },
                    { "metallurgic-science-pack",      1 },
                    { "electromagnetic-science-pack",      1 },
                    { "interstellar-science-pack", 1 },
                },
                time = 30
            },
            icons = mods["space-exploration-graphics"] and Muluna.img.blur_technology_icon({{icon = "__space-exploration-graphics__/graphics/technology/telescope-radio.png",icon_size = 128}},32)
                    or {{icon = data.raw["technology"]["radar"].icon, icon_size = data.raw["technology"]["radar"].icon_size}}
        }
    })
    data.raw["mod-data"]["bplib"].data.extract_entity_names[navBeaconEntity.name] = true
    Muluna:extend({
        -- navBeaconEntity_Planet,
        --navBeaconEntity_Platform,
        navBeaconEntity,
        navBeaconItem,
        navBeaconRecipe,
        navBeaconTech,
        navBeaconData,
    })
end