local fish = require "graphics.entity.fish.fish"

local map_colors = table.deepcopy {
    defines.color.goldenrod,
    defines.color.azure,
    defines.color.yellowgreen,
    defines.color.pink,
    defines.color.orangered,
    defines.color.darkblue,
    defines.color.cyan,
    defines.color.blanchedalmond,
    defines.color.yellow,
    defines.color.aqua,
    defines.color.beige,
    defines.color.orange,
    defines.color.rosybrown,
    defines.color.whitesmoke,
    defines.color.darkcyan
}

local color_budget = 150
for _, color in pairs(map_colors) do
    local sum = color.r + color.g + color.b
    color.r = color.r / sum * color_budget
    color.g = color.g / sum * color_budget
    color.b = color.b / sum * color_budget
    color.a = 255
end
for _,fish in pairs(data.raw.fish) do
    fish.resistances = fish.resistances or {}
    table.insert(fish.resistances, 
        {
                type = "drowning",
                percent = 100,
        }
    )
end
for i, v in pairs(fish) do
    local name = "maraxsis-tropical-fish-" .. i

    v.filename = "__maraxsis__/graphics/entity/fish/" .. i .. ".png"
    v.direction_count = 32
    v.frame_count = 10
    v.animation_speed = 0.4
    v.scale = 1.25
    v.apply_projection = true
    v.flags = {"no-scale"}
    v = {
        layers = {
            v,
            table.deepcopy(v),
        }
    }
    v.layers[2].draw_as_shadow = true
    v.layers[2].shift.x = v.layers[2].shift.x + 3
    v.layers[2].shift.y = v.layers[2].shift.y + 3.5
    data:extend {{
        type = "unit",
        name = name,
        render_layer = "air-entity-info-icon",
        icon = "__maraxsis__/graphics/entity/fish/icons/" .. i .. ".png",
        icon_size = 64,
        subgroup = "creatures",
        order = "c-" .. i,
        flags = {"placeable-neutral", "placeable-off-grid", "not-repairable", "breaths-air"},
        max_health = 200,
        map_color = map_colors[tonumber(i)],
        healing_per_tick = data.raw.fish["fish"].healing_per_tick,
        collision_box = {{0, 0}, {0, 0}},
        selection_box = {{-0.5, -1}, {0.5, 1}},
        collision_mask = {layers = {}},
        autoplace = {
            probability_expression = "maraxsis_tropical_fish_" .. i,
            default_enabled = false
        },
        vision_distance = 0,
        movement_speed = data.raw.unit["small-biter"].movement_speed * 2,
        distance_per_frame = data.raw.unit["small-biter"].distance_per_frame,
        run_animation = v,
        attack_parameters = {
            type = "projectile",
            ammo_category = "melee",
            cooldown = 60,
            range = 0,
            ammo_type = {
                category = "melee",
                action = {
                    type = "direct",
                    action_delivery = {
                        type = "instant",
                        target_effects = {
                            {
                                type = "damage",
                                damage = {amount = 0, type = "physical"}
                            }
                        }
                    }
                }
            },
            animation = v,
        },
        resistances = {
            {
                type = "drowning",
                percent = 100,
            },
        },
        water_reflection = data.raw.fish["fish"].water_reflection,
        absorbtions_to_join_attack = {},
        distraction_cooldown = 300,
        rotation_speed = 0.1,
        dying_sound = data.raw.fish["fish"].mining_sound,
        has_belt_immunity = true,
        ai_settings = {
            destroy_when_commands_fail = false,
            allow_try_return_to_spawner = false,
            path_resolution_modifier = -2,
            do_separation = false,
        },
        affected_by_tiles = false,
        minable = {
            mining_time = data.raw.fish["fish"].minable.mining_time,
            results = {
                {type = "item", name = "maraxsis-tropical-fish", amount = 5},
            }
        }
    }}
end

local tropical_fish_variants = {}
for i, v in pairs(fish) do
    tropical_fish_variants[tonumber(i)] = {
        filename = "__maraxsis__/graphics/entity/fish/icons/" .. i .. ".png",
        width = 64,
        height = 64,
        scale = 2 / 3,
        flags = {"icon"},
    }
end
data:extend {{
    type = "capsule",
    name = "maraxsis-tropical-fish",
    icon = "__maraxsis__/graphics/icons/tropical-fish.png",
    icon_size = 64,
    pictures = tropical_fish_variants,
    stack_size = data.raw.capsule["raw-fish"].stack_size,
    capsule_action = table.deepcopy(data.raw.capsule["raw-fish"].capsule_action),
    spoil_result = "spoilage",
    spoil_ticks = data.raw.capsule["raw-fish"].spoil_ticks,
}}
local dmg = data.raw.capsule["maraxsis-tropical-fish"].capsule_action.attack_parameters.ammo_type.action.action_delivery.target_effects[1].damage
dmg.amount = dmg.amount * 1.5
