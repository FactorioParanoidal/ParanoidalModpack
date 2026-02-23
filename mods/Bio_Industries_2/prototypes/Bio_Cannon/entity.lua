local BioInd = require('common')('Bio_Industries_2')
local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_W = BioInd.modRoot .. "/graphics/icons/weapons/"
local ENTITYPATH = BioInd.modRoot .. "/graphics/entities/bio_cannon/"
local REMNANTSPATH = BioInd.modRoot .. "/graphics/entities/remnants/"

require "util"

if BI.Settings.Bio_Cannon then

    function preparing_animation()
        return {
            layers = {
                {
                        priority = "high",
                        width = 692,
                        height = 672,
                        direction_count = 1,
                        frame_count = 12,
                        line_length = 6,
                        run_mode = "forward",
                        axially_symmetrical = false,
                        shift = {0, -0.8},
                        filename = ENTITYPATH .. "hr_bio_cannon_anim.png",
                        scale = 0.5
                }

            }

        }
    end

    function prepared_animation() -- OPEN
        return {
            layers = {
                {
                        priority = "high",
                        width = 692,
                        height = 672,
                        direction_count = 1,
                        frame_count = 1,
                        line_length = 1,
                        axially_symmetrical = false,
                        shift = {0, -0.8},
                        filename = ENTITYPATH .. "hr_bio_cannon_open.png",
                        scale = 0.5
                }, {
                        priority = "high",
                        width = 320,
                        height = 672,
                        direction_count = 1,
                        frame_count = 1,
                        line_length = 1,
                        axially_symmetrical = false,
                        shift = {5, -0.95},
                        filename = ENTITYPATH .. "hr_bio_cannon_shadow.png",
                        draw_as_shadow = true,
                        scale = 0.5
                }
            }
        }
    end

    function folding_animation()
        return {
            layers = {

                {
                        priority = "high",
                        width = 692,
                        height = 672,
                        direction_count = 1,
                        frame_count = 12,
                        line_length = 6,
                        run_mode = "backward",
                        axially_symmetrical = false,
                        shift = {0, -0.8},
                        filename = ENTITYPATH .. "hr_bio_cannon_anim.png",
                        scale = 0.5
                }

            }
        }
    end

    function folded_animation() -- CLOSED
        return {
            layers = {
                {
                        priority = "high",
                        width = 692,
                        height = 672,
                        direction_count = 1,
                        frame_count = 1,
                        line_length = 1,
                        axially_symmetrical = false,
                        shift = {0, -0.8},
                        filename = ENTITYPATH .. "hr_bio_cannon_anim.png",
                        scale = 0.5
                }, {
                        priority = "high",
                        width = 692,
                        height = 672,
                        direction_count = 1,
                        frame_count = 1,
                        line_length = 1,
                        axially_symmetrical = false,
                        shift = {0.2, -0.95},
                        filename = ENTITYPATH .. "hr_bio_cannon_shadow.png",
                        draw_as_shadow = true,
                        scale = 0.5
                }
            }
        }
    end

    data:extend({

        -- Bio Cannon Artillery
        {
            type = "ammo-turret",
            name = "bi-bio-cannon",
            icons = {{icon = ICONPATH_W .. "biocannon_icon.png", icon_size = 64}},
            flags = {"placeable-neutral", "placeable-player", "player-creation"},
            -- makes cannon blueprintable
            placeable_by = {item = "bi-bio-cannon", count = 1},
            open_sound = {
                filename = "__base__/sound/machine-open.ogg",
                volume = 0.85
            },
            close_sound = {
                filename = "__base__/sound/machine-close.ogg",
                volume = 0.75
            },
            minable = {mining_time = 10, result = "bi-bio-cannon"},
            max_health = 900,
            corpse = "bi-bio-cannon-remnants",
            dying_explosion = "massive-explosion",
            automated_ammo_count = 10,
            resistances = {
                {type = "fire", percent = 90},
                {type = "explosion", percent = 30},
                {type = "impact", percent = 30}
            },
            collision_box = {{-4.20, -4.20}, {4.20, 4.20}},
            selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
            order = "i[items][Bio_Cannon]",
            inventory_size = 1,
            prepare_range = 120,
            preparing_speed = 0.012,
            attack_parameters = {
                type = "projectile",
                ammo_category = "Bio_Cannon_Ammo",
                cooldown = 600,
                warmup = 600,
                -- ~ range = 0,
                range = 120,
                min_range = 20,
                projectile_creation_distance = 1.8,
                action = {}
            },
            folding_speed = 0.012,
            preparing_animation = preparing_animation(),
            prepared_animation = prepared_animation(),
            -- attacking_animation = attacking_animation(),
            folding_animation = folding_animation(),
            folded_animation = folded_animation(),
            call_for_help_radius = 90,
            attack_target_mask = {"Bio_Cannon_Ammo"},
            graphics_set = {}
        },

        ---- Corpse / Remnants
        {
            type = "corpse",
            name = "bi-bio-cannon-remnants",
            icon_size = 64,
            icons = {{icon = ICONPATH_W .. "biocannon_icon.png", icon_size = 64}},

            flags = {"placeable-neutral", "not-on-map"},
            subgroup = "defensive-structure-remnants",
            order = "a-c-a",
            selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
            tile_width = 3,
            tile_height = 3,
            selectable_in_game = false,
            time_before_removed = 60 * 60 * 15, -- 15 minutes
            final_render_layer = "remnants",
            remove_on_tile_placement = false,
            animation = make_rotated_animation_variations_from_sheet(1, {
                layers = {

                    {
                            width = 692,
                            height = 672,
                            direction_count = 1,
                            frame_count = 1,
                            line_length = 1,
                            axially_symmetrical = false,
                            shift = {0, -0.8},
                            filename = REMNANTSPATH .. "bio_cannon_remnant.png",
                            scale = 0.5
                    }

                }
            })
        }

    })
end
