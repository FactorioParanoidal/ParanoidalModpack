local sounds = require("__base__/prototypes/entity/sounds.lua")

local allowed_effects = {"speed"} -- {"consumption", "speed", "productivity", "pollution"}
local ENTITYPATH = "__Rocket-Silo-Construction__/graphics/entity/"

local resistances = {
    {
        type = "fire",
        percent = 70
    },
    {
        type = "impact",
        percent = 60
    }
}
local energy_usage = "150MW"
local max_health = 3000

local stages = {}

function entitylayer(num, shadow)
    return {
        filename = ENTITYPATH .. "rs-stage" .. num .. ".png",
        width = 304,
        height = 298,
        --shift = util.by_pixel(-5, 16),
        draw_as_shadow = shadow or false,
        scale = 1,
        hr_version = {
            filename = ENTITYPATH .. "hr-rs-stage" .. num .. ".png",
            width = 608,
            height = 596,
            draw_as_shadow = shadow or false,
            --shift = util.by_pixel(-5, 16),
            scale = 0.5
        }
    }
end

stages[1] = {
    type = "assembling-machine",
    name = "rsc-silo-stage1",
    icons = icons_rsc,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    corpse = "rocket-silo-remnants",
    dying_explosion = "medium-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    animation = {
        layers = {
            entitylayer("1")
        }
    },
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage1"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage1",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = 2000 --drd 200
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}

stages[2] = {
    type = "assembling-machine",
    name = "rsc-silo-stage2",
    order = "r-s",
    icons = icons_rsc,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    corpse = "rocket-silo-remnants",
    dying_explosion = "medium-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    animation = {
        layers = {
            entitylayer("2")
        }
    },
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage2"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage2",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = 200
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}

stages[3] = {
    type = "assembling-machine",
    name = "rsc-silo-stage3",
    order = "r-s",
    icons = icons_rsc,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    corpse = "rocket-silo-remnants",
    dying_explosion = "medium-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    animation = {
        layers = {
            entitylayer("3")
        }
    },
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage3"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage3",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = 2000
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}

stages[4] = {
    type = "assembling-machine",
    name = "rsc-silo-stage4",
    order = "r-s",
    icons = icons_rsc,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    corpse = "rocket-silo-remnants",
    dying_explosion = "medium-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    animation = {
        layers = {
            entitylayer("4")
        }
    },
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage4"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage4",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = 200
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}

stages[5] = {
    type = "assembling-machine",
    name = "rsc-silo-stage5",
    icons = icons_rsc,
    order = "r-s",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    corpse = "rocket-silo-remnants",
    dying_explosion = "medium-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    animation = {
        layers = {
            entitylayer("5"),
            entitylayer("5_shadow", true)
        }
    },
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage5"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage5",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = 200
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}

stages[6] = {
    type = "assembling-machine",
    name = "rsc-silo-stage6",
    icons = icons_rsc,
    order = "r-s",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    corpse = "rocket-silo-remnants",
    dying_explosion = "medium-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    animation = {
        layers = {
            entitylayer("6"),
            entitylayer("6_shadow", true)
        }
    },
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage6"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage6",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = 200
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}

for s = 1, 6 do
    data:extend({stages[s]})
end

local function update_proto_serlp(stage, sufix_name, collision_box, localised_name, icons)
    local new = table.deepcopy(stage)
    new.name = new.name .. sufix_name
    new.icons = icons
    new.localised_name = localised_name
    new.minable.result = "rsc-excavation-site" .. sufix_name
    new.collision_box = collision_box --  {{-4.85, -4.85}, {4.85, 4.85}}
    new.selection_box = collision_box
    return new
end

if data.raw.item["se-rocket-launch-pad"] then
    local enable_se_cargo = settings.startup["rsc-st-enable-se-cargo-silo"].value
    if enable_se_cargo then
        local cb = data.raw.container["se-rocket-launch-pad"].collision_box
        for s = 1, 6 do
            data:extend(
                {
                    update_proto_serlp(
                        stages[s],
                        "-serlp",
                        cb,
                        {"", {"entity-name.se-rocket-launch-pad"}, {"RSC.construction_site", s}},
                        icons_se_crs
                    )
                }
            )
        end
    end
end

if data.raw["rocket-silo"]["se-space-probe-rocket-silo"] then
    local enable_se_probe = settings.startup["rsc-st-enable-se-probe-silo"].value
    if enable_se_probe then
        local cb = data.raw["rocket-silo"]["se-space-probe-rocket-silo"].collision_box
        for s = 1, 6 do
            data:extend(
                {
                    update_proto_serlp(
                        stages[s],
                        "-sesprs",
                        cb,
                        {"", {"entity-name.se-space-probe-rocket-silo"}, {"RSC.construction_site", s}},
                        icons_se_sp
                    )
                }
            )
        end
        data.raw["assembling-machine"]["rsc-silo-stage5-sesprs"].fixed_recipe = "rsc-construction-stage5-sesprs"
        data.raw["assembling-machine"]["rsc-silo-stage6-sesprs"].fixed_recipe = "rsc-construction-stage6-sesprs"
    end
end
