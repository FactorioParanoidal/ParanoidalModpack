turret_gun1f12 = {
    filename = "__Yuoki__/graphics/entity/defense/gun_1_place.png",
    priority = "medium",
    width = 128,
    height = 128,
    direction_count = 8,
    frame_count = 1,
    axially_symmetrical = false,
    shift = { 0.0, -0.94 },
}
turret_gun2f12 = {
    filename = "__Yuoki__/graphics/entity/defense/gun2_place.png",
    priority = "medium",
    width = 128,
    height = 128,
    direction_count = 8,
    frame_count = 1,
    axially_symmetrical = false,
    shift = { 0.25, -0.94 },
}

turret_laser22f12 = {
    filename = "__Yuoki__/graphics/entity/defense/laser22b_place.png",
    priority = "medium",
    width = 128,
    height = 128,
    direction_count = 8,
    frame_count = 1,
    axially_symmetrical = false,
    shift = { 0.5, -0.72 },
}

data:extend({
    {
        type = "electric-turret",
        name = "y_turret_laser22f12",
        icon_size = 64,
        icon = "__Yuoki__/graphics/entity/defense/laser22b_icon.png",
        flags = { "placeable-player", "placeable-enemy", "player-creation" },
        minable = { mining_time = 0.5, result = "y_turret_laser22f12" },
        max_health = 1400,
        corpse = "small-remnants",
        collision_box = { { -0.7, -0.7 }, { 0.7, 0.7 } },
        selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
        rotation_speed = 0.01,
        preparing_speed = 0.05,
        dying_explosion = "medium-explosion",
        folding_speed = 0.05,
        resistances = {
            { type = "physical", decrease = 5, percent = 60 },
            { type = "explosion", decrease = 5, percent = 60 },
            { type = "fire", percent = 50 },
        },
        energy_source = {
            type = "electric",
            buffer_capacity = "20MJ",
            input_flow_limit = "3125kW",
            drain = "100kW",
            usage_priority = "primary-input",
        },
        folded_animation = (function()
            local res = util.table.deepcopy(turret_laser22f12)
            res.frame_count = 1
            res.line_length = 1
            return res
        end)(),
        preparing_animation = turret_laser22f12,
        prepared_animation = {
            filename = "__Yuoki__/graphics/entity/defense/laser22b_sheet.png",
            priority = "medium",
            width = 128,
            height = 128,
            shift = { 0.5, -0.72 },
            direction_count = 64,
            frame_count = 1,
            line_length = 16,
            axially_symmetrical = false,
        },
        folding_animation = (function()
            local res = util.table.deepcopy(turret_laser22f12)
            res.run_mode = "backward"
            return res
        end)(),

        graphics_set = blank_sprite,

        attack_parameters = {
            type = "beam",
            cooldown = 12,
            range = 33,
            source_direction_count = 64,
            source_offset = { 0, -3.423489 / 4 },
            damage_modifier = 5,
            ammo_category = "laser",
            ammo_type = {
                --category = "laser",
                energy_consumption = "800kJ",
                action = {
                    type = "direct",
                    action_delivery = {
                        type = "beam",
                        beam = "laser-beam",
                        max_length = 33,
                        duration = 12,
                        source_offset = { 0, -1.31439 },
                    },
                },
            },
        },
        --[[
            attack_parameters =
            {
                type = "projectile",
                damage_modifier = 2,
                ammo_category = "electric",
                cooldown = 12,
                damage = 5,
                projectile_center = {0, 0},
                projectile_creation_distance = 0.2,
                range = 33,
                sound = {{ filename = "__base__/sound/fight/laser-1.ogg", volume = 0.1 }},
                ammo_type =
                {
                    type = "projectile",
                    category = "laser-turret",
                    energy_consumption = "300KJ",
                    action =
                    {
                        {
                            type = "direct",
                            action_delivery =
                            {
                                {
                                    type = "projectile",
                                    projectile = "cyan-laser",
                                    starting_speed = 0.35,
                                },
                            }
                        }
                    }
                },
            },
            ]]
        order = "a",
        call_for_help_radius = 40,
    },
    {
        type = "ammo-turret",
        name = "y_turret_gun1f12",
        icon_size = 64,
        icon = "__Yuoki__/graphics/entity/defense/gun_1_icon.png",
        flags = { "placeable-player", "player-creation" },
        minable = { mining_time = 0.5, result = "y_turret_gun1f12" },
        max_health = 1400,
        resistances = {
            { type = "physical", decrease = 4, percent = 50 },
            { type = "explosion", decrease = 4, percent = 50 },
            { type = "fire", percent = 50 },
        },
        corpse = "small-remnants",
        collision_box = { { -0.7, -0.7 }, { 0.7, 0.7 } },
        selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
        rotation_speed = 0.015, -- 0.015 orginal
        preparing_speed = 0.08,
        folding_speed = 0.08,
        dying_explosion = "medium-explosion",
        inventory_size = 1,
        automated_ammo_count = 20,
        circuit_wire_max_distance = 7.5,
        folded_animation = (function()
            local res = util.table.deepcopy(turret_gun1f12)
            res.frame_count = 1
            res.line_length = 1
            return res
        end)(),
        preparing_animation = turret_gun1f12,
        prepared_animation = {
            filename = "__Yuoki__/graphics/entity/defense/gun_1_sheet.png",
            priority = "medium",
            width = 128,
            height = 128,
            direction_count = 64,
            frame_count = 1,
            line_length = 8,
            axially_symmetrical = false,
            shift = { 0.0, -0.94 },
        },
        folding_animation = (function()
            local res = util.table.deepcopy(turret_gun1f12)
            res.run_mode = "backward"
            return res
        end)(),

        graphics_set = blank_sprite,

        attack_parameters = {
            type = "projectile",
            ammo_category = "cannon-shell",
            cooldown = 15,
            projectile_center = { 0, 0 },
            projectile_creation_distance = 1.4,
            damage_modifier = 2.25,
            shell_particle = {
                name = "shell-particle",
                direction_deviation = 0.1,
                speed = 0.1,
                speed_deviation = 0.03,
                center = { 0, 0.6 },
                creation_distance = 0.6,
                starting_frame_speed = 0.2,
                starting_frame_speed_deviation = 0.1,
            },
            range = 30,
            sound = {
                {
                    filename = "__Yuoki__/sounds/railgun.ogg",
                    volume = 0.3,
                },
            },
        },
        call_for_help_radius = 40,
    },
    {
        type = "ammo-turret",
        name = "y_turret_gun2f12",
        icon_size = 64,
        icon = "__Yuoki__/graphics/entity/defense/gun2_icon.png",
        flags = { "placeable-player", "player-creation" },
        minable = { mining_time = 0.5, result = "y_turret_gun2f12" },
        max_health = 1600,
        resistances = {
            { type = "physical", decrease = 4, percent = 70 },
            { type = "explosion", decrease = 4, percent = 70 },
            { type = "fire", percent = 50 },
        },
        corpse = "small-remnants",
        collision_box = { { -0.7, -0.7 }, { 0.7, 0.7 } },
        selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
        rotation_speed = 0.020, -- 0.015 orginal
        preparing_speed = 0.08,
        folding_speed = 0.08,
        dying_explosion = "medium-explosion",
        inventory_size = 3,
        automated_ammo_count = 30,
        folded_animation = (function()
            local res = util.table.deepcopy(turret_gun2f12)
            res.frame_count = 1
            res.line_length = 1
            return res
        end)(),
        preparing_animation = turret_gun2f12,
        prepared_animation = {
            filename = "__Yuoki__/graphics/entity/defense/gun2_sheet.png",
            priority = "medium",
            width = 128,
            height = 128,
            direction_count = 64,
            frame_count = 1,
            line_length = 8,
            axially_symmetrical = false,
            shift = { 0.25, -0.94 },
        },
        folding_animation = (function()
            local res = util.table.deepcopy(turret_gun2f12)
            res.run_mode = "backward"
            return res
        end)(),

        graphics_set = blank_sprite,

        attack_parameters = {
            type = "projectile",
            ammo_category = "bullet",
            cooldown = 4,
            projectile_center = { 0, 0 },
            projectile_creation_distance = 1.4,
            damage_modifier = 1.8,
            shell_particle = {
                name = "shell-particle",
                direction_deviation = 0.1,
                speed = 0.1,
                speed_deviation = 0.03,
                center = { 0, 0.6 },
                creation_distance = 0.6,
                starting_frame_speed = 0.2,
                starting_frame_speed_deviation = 0.1,
            },
            range = 28,
            sound = {
                {
                    filename = "__Yuoki__/sounds/railgun.ogg",
                    volume = 0.3,
                },
            },
        },
        call_for_help_radius = 40,
    },
})
