local sprites = require('sprites')
local surface_conditions = require('surface_conditions')
local handle_settings = require("scripts/handle_settings")
local common = require("prototypes/common")

-- Allow disabling the Titanic wind turbine (by not including it at all) for very low-end computers where the large graphics might cause problems
if handle_settings.WindTurbine4() then

    local function insert_surface_conditions()
        local sc = {
            surface_conditions.pressure(),
        }

        return sc
    end

    local powersetting = handle_settings.WindPower()
    local extended_collision_area = handle_settings.useExtendedCollisionArea()
    local scaleWithQualityAndPressure = handle_settings.scaleWithQualityAndPressure()

    local function make_recipe()
        return common.make_recipe({
            type = 'recipe',
            name = 'texugo-wind-turbine4',
            icon = sprites.sprite "titanicicon.png",
            icon_size = 64,
            enabled = false,
            results = {{ type = "item", name = 'texugo-wind-turbine4', amount = 1 }},
        }, {
            energy = 240,
            ingredients = {
                { 'low-density-structure',  400 },
                { 'processing-unit',         70 },
                { 'speed-module',            70 },
                { 'heat-pipe',               50 },
                { 'steam-turbine',           10 },
                { 'steel-plate',           2000 },
                { 'refined-concrete',      1000 }
            }	}, {
            energy = 400,
            ingredients = {
                { 'low-density-structure',  500 },
                { 'processing-unit',        100 },
                { 'speed-module',           100 },
                { 'heat-pipe',              100 },
                { 'steam-turbine',           10 },
                { 'steel-plate',           3000 },
                { 'refined-concrete',      2000 }
            }
        })
    end

    data:extend({
        -- Item, Recipe and Tech
        {
            type = "item",
            name = "texugo-wind-turbine4",
            icon = sprites.sprite "titanicicon.png",
            icon_size = 64,
            group = "logistics",
            subgroup = "energy",
            order = "b[steam-power]-c[texugo-wind-turbine]",
            place_result = "texugo-wind-turbine4",
            stack_size = 1
        },
        make_recipe(),
        {
            type = "technology",
            name = "texugo-wind-turbine4",
            icon = sprites.sprite "titanictech.png",
            icon_size = 128,
            prerequisites = { "nuclear-power", "texugo-wind-turbine3"},
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "texugo-wind-turbine4"
                }
            },
            unit = {
                count = 2000,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"utility-science-pack", 1}
                },
                time = 120
            }
        },
        -- World Entities
        {
            type = 'electric-energy-interface',
            name = 'texugo-wind-turbine4',
            icon = sprites.sprite 'titanicicon.png',
            icon_size = 64,
            flags = {"player-creation", "placeable-neutral", "not-rotatable", "not-flammable"},
            minable = {mining_time = 3, result = 'texugo-wind-turbine4'},
            corpse = 'rocket-silo-remnants',
            dying_explosion = 'massive-explosion',
            max_health = 5000,
            resistances = {
                {type = 'fire', percent = 100},
                {type = 'acid', percent = 25, decrease = 5},
                {type = 'physical', percent = 50, decrease = 10},
                {type = 'impact', percent = 60, decrease = 30}
            },
            fast_replaceable_group = 'texugo-wind-turbine4',
            next_upgrade = 'texugo-wind-turbine4',
            collision_mask = { layers = { item = true, object = true, water_tile = true } },
            collision_box = extended_collision_area and {{ -5.9, -13.9 }, { 5.9, 3.9 }} or {{ -5.9, -3.9 }, { 5.9, 3.9 }} ,
            selection_box = extended_collision_area and {{   -6,   -14 }, {   6,   4 }} or {{   -6,   -4 }, {   6,   4 }} ,

            energy_source = {
                type = 'electric',
                render_no_power_icon = false,
                render_no_network_icon = true,
                usage_priority = 'primary-output',
                buffer_capacity = tostring(powersetting * 67500 * scaleWithQualityAndPressure)..'kW',
                input_flow_limit = '0W',
                output_flow_limit = tostring(powersetting * 67500 * scaleWithQualityAndPressure)..'kW',
            },
            energy_production = tostring(powersetting * 67500)..'kW',
            gui_mode = 'none',
            continuous_animation = false,
            animation = {
                stripes = {
                    sprites.stripe('titanic-lr/tlr_0104.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_0508.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_0912.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_1316.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_1720.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_2124.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_2528.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_2932.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_3336.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_3740.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_4144.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_4548.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_4952.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_5356.png', 2, 2),
                    sprites.stripe('titanic-lr/tlr_5760.png', 2, 2),
                },
                width = 750,
                height = 562,
                scale = 1.88,
                animation_speed = 1.1*0.000001 / math.sqrt(scaleWithQualityAndPressure),
                frame_count = 60,
                shift = {10, -7.1},
                hr_version = {
                    stripes = {
                        sprites.stripe('titanic-hr/titanic01.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic02.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic03.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic04.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic05.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic06.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic07.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic08.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic09.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic10.png', 1, 1),

                        sprites.stripe('titanic-hr/titanic11.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic12.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic13.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic14.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic15.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic16.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic17.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic18.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic19.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic20.png', 1, 1),

                        sprites.stripe('titanic-hr/titanic21.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic22.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic23.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic24.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic25.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic26.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic27.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic28.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic29.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic30.png', 1, 1),

                        sprites.stripe('titanic-hr/titanic31.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic32.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic33.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic34.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic35.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic36.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic37.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic38.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic39.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic40.png', 1, 1),

                        sprites.stripe('titanic-hr/titanic41.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic42.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic43.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic44.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic45.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic46.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic47.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic48.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic49.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic50.png', 1, 1),

                        sprites.stripe('titanic-hr/titanic51.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic52.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic53.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic54.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic55.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic56.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic57.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic58.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic59.png', 1, 1),
                        sprites.stripe('titanic-hr/titanic60.png', 1, 1),
                    },
                    width = 1500,
                    height = 1125,
                    frame_count = 60,
                    animation_speed = 1.1*0.000001,
                    scale = 0.94,
                    shift = {10, -7.1}
                }
            },
            min_perceived_performance = 1,
            surface_conditions = surface_conditions.check_existence_of_SPA(insert_surface_conditions),
        },
        {
            type = 'simple-entity-with-owner',
            name = 'twt-collision-rect4',
            flags = {'not-deconstructable', 'not-on-map', 'placeable-off-grid', 'not-repairable', 'not-blueprintable'},
            selectable_in_game = false,
            collision_box = {{-4, -2.3}, {4, 3.9}},
            picture = {
                filename = "__core__/graphics/empty.png",
                size = 1
            },
            max_health = 5000,
            resistances = {
                {type = 'impact', percent = 60, decrease = 30}
            },
		    hidden_in_factoriopedia = true
        }
    })
end