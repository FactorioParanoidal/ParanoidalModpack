


local recipe_category = "muluna-vacuum-heating-tower"

Muluna:extend{
    {
        type="recipe-category",
        name=recipe_category,
    },
}

local steam_proxy = table.deepcopy(data.raw["fluid"]["steam"])

steam_proxy.name = "muluna-heat"
steam_proxy.icon = "__core__/graphics/arrows/heat-exchange-indication.png"
steam_proxy.icon_size = 48
-- steam_proxy.icons = {
--     {
--         icon = steam_proxy.icon,
--         icon_size = 48,
--         --tint = {255,120,120},
       
--     }
-- }
steam_proxy.heat_capacity = "0.2kJ"
steam_proxy.custom_tooltip_fields = {
    {
      name = {"tooltip.steam-equivalent"},
      value = {"tooltip-value.steam-equivalent",tostring(util.parse_energy(steam_proxy.heat_capacity)/200)}
      
    }
  }

local effectivity = 3
local energy_usage_MW = 72/effectivity   
local temperature = 500
local temperature_delta = temperature - steam_proxy.default_temperature --15
local temperature_delta_cold = 150
local energy_required = 4
local recipe_heat_content = 4e6 --1 MJ
local heat_capacity = util.parse_energy(steam_proxy.heat_capacity) --200
local heat_amount = recipe_heat_content / (temperature_delta*heat_capacity)
local oxygen_consumed = (1.5/3.0)*(recipe_heat_content / (temperature_delta_cold*heat_capacity))
local recipe = {
        type = "recipe",
        enabled = false,
        name = "muluna-vacuum-heating",
        categories = {recipe_category},
        energy_required = energy_required,
        ingredients = {
            {
                type = "fluid",
                name = "oxygen",
                amount = oxygen_consumed,
            }
        },
        results = {
            {
                type = "fluid",
                name = "muluna-heat",
                amount = heat_amount,
                temperature = temperature,
                ignored_by_stats=heat_amount
            },
            {
                type = "fluid",
                name = "carbon-dioxide",
                amount = oxygen_consumed,
                temperature = temperature,
            }
        },
        main_product = "muluna-heat",
        subgroup = "environmental-protection",
        order = "e[muluna-vacuum-heating]",
        hidden=true,
        hide_from_player_crafting=true
    }

Muluna:extend{steam_proxy,recipe}


local heating_boiler = table.deepcopy(data.raw["assembling-machine"]["muluna-advanced-boiler"])
local heating_tower = data.raw["reactor"]["heating-tower"]


heating_boiler.icons = data.raw["item"]["muluna-vacuum-heating-tower"].icons
--heating_tower.icon = nil
--heating_tower.icon_size = data.raw["item"]["muluna-vacuum-heating-tower"].icon_size

heating_boiler.graphics_set = nil
heating_boiler.name = "muluna-vacuum-heating-tower"
heating_boiler.minable.result = "muluna-vacuum-heating-tower"
heating_boiler = Muluna.rro.util_merge{heating_boiler,
    {
        type = "assembling-machine",
        is_heat_assembling_machine = true,
        --heat_buffer = heating_tower.heat_buffer,
        crafting_categories = {recipe_category},
        fixed_recipe = "muluna-vacuum-heating",
        fixed_quality = "normal",
        energy_usage = tostring(energy_usage_MW) .. "MW",
        effectivity = effectivity, --Increase to 300% efficiency to incentivise using these on other planets? A small reward for a more complex power plant.
        crafting_speed = energy_usage_MW*effectivity,
        custom_tooltip_fields = {
            {
            name = {"description.effectivity"},
            value = tostring(effectivity*100) .."%"
            }
        },
        heat_buffer =
        {
            max_temperature = 1000,
            specific_heat = "5MJ",
            max_transfer = "10GW",
            minimum_glow_temperature = 50,
            connections =
            {
                {
                position = {0, -1},
                direction = defines.direction.north
                },
                {
                position = {1, 0},
                direction = defines.direction.east
                },
                {
                position = {0, 1},
                direction = defines.direction.south
                },
                {
                position = {-1, 0},
                direction = defines.direction.west
                },
            },

            heat_picture = apply_heat_pipe_glow(
            util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-glow", {
                scale = 0.65,
                --scale = 0.6,
                blend_mode = "additive"
            }))
        },
        picture =
        {
        layers =
        {
            util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-main", {
            scale = 0.65
            --scale = 0.6
            }),
            util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-shadow", {
            scale = 0.65,
            --scale = 0.6,
            draw_as_shadow = true
            })
        }
        },
        -- graphics_set = {
        --     animation = {
        --         north = {
        --             filenames =
        --                 {
        --                     util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-main", {
        --                     scale = 0.65,
        --                     }),
        --                     util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-shadow", {
        --                     scale = 0.65,
        --                     draw_as_shadow = true,
        --                     })
        --                 }
        --         }
        --     }
            
        -- },

        working_light_picture =
        {
        layers = {
            util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-working-fire", {
            frame_count = 24,
            scale = 0.65,
            --scale = 0.6,
            blend_mode = "additive",
            draw_as_glow = true,
            animation_speed = 0.333
            }),
            util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-working-light", {
            frame_count = 1,
            repeat_count = 24,
            scale = 0.65,
            --scale = 0.6,
            blend_mode = "additive",
            draw_as_glow = true
            })
        }
        },

        connection_patches_connected =
            {
            sheet = util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-pipes", {
                scale = 0.5,
                variation_count = 4
            })
        },

        connection_patches_disconnected =
            {
            sheet = util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-pipes-disconnected", {
                scale = 0.5,
                variation_count = 4
            })
        },

        heat_connection_patches_connected =
            {
            sheet = apply_heat_pipe_glow(
                util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-pipes-heat", {
                scale = 0.5,
                variation_count = 4
            }))
        },

        heat_connection_patches_disconnected =
            {
            sheet = apply_heat_pipe_glow(
                util.sprite_load("__space-age__/graphics/entity/heating-tower/heating-tower-pipes-heat-disconnected", {
                scale = 0.5,
                variation_count = 4
            }))
        },
        neighbour_bonus = 0
        
    }
}
-- The tower deepcopies the vacuum boiler's burner energy source, so it would otherwise
-- inherit its pollution emissions. Keep the vacuum heating tower pollution free.
heating_boiler.energy_source.emissions_per_minute = {}
heating_boiler.fluid_boxes = {
            {
                volume = 200,
                pipe_covers = pipecoverspictures(),
                pipe_picture = Muluna.pipe_pictures.vacuumheatingtowerpipepictures(),
                pipe_connections =
                {
                {flow_direction = "input-output", direction = defines.direction.west, position = {-1.0, 1}},
                {flow_direction = "input-output", direction = defines.direction.east, position = {1.0, 1}},
                },
                production_type = "input",
                --filter = "water"
            },
            {
                volume = 200,
                --pipe_covers = pipecoverspictures(),
                pipe_connections =
                {
                    {flow_direction = "output", direction = defines.direction.north, position = {0, 0.0},connection_type = "linked",linked_connection_id=1},
                },
                production_type = "heat-output",
                --filter = "steam"
                },
            {
                volume = 200,
                pipe_covers = pipecoverspictures(),
                pipe_picture =  Muluna.pipe_pictures.vacuumheatingtowerpipepictures(),
                pipe_connections =
                {
                {flow_direction = "input-output", direction = defines.direction.west, position = {-1.0, -1}},
                {flow_direction = "input-output", direction = defines.direction.east, position = {1.0, -1}}
                },
                production_type = "output",
                --filter = "water"
            },
            -- {
            --     volume = 200,
            --     pipe_covers = pipecoverspictures(),
            --     pipe_picture = vacuumheatingtowerpipepictures(),
            --     pipe_connections =
            --     {
            --         {flow_direction = "input-output", direction = defines.direction.west, position = {-1.0, -1}},
            --         {flow_direction = "input-output", direction = defines.direction.east, position = {1.0, -1}}
            --     },
            --     production_type = "output",
            --     --filter = "steam"
            -- },
    }

-- heating_boiler.type = "heat-assembling-machine"
Muluna:extend{heating_boiler}
defines.prototypes.entity["heat-assembling-machine"] = 0
