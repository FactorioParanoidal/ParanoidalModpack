
if not NE_Enemies then
    NE_Enemies = {}
end
if not NE_Enemies.Settings then
    NE_Enemies.Settings = {}
end


NE_Enemies.Settings.NE_Alien_Artifacts = settings.startup["NE_Alien_Artifacts"].value
NE_Enemies.Settings.NE_Alien_Artifact_Eggs = settings.startup["NE_Alien_Artifact_Eggs"].value
NE_Enemies.Settings.NE_Alternative_Graphics = settings.startup["NE_Alternative_Graphics"].value


local ICONPATH = NE_Common.iconpath

if NE_Enemies.Settings.NE_Alien_Artifact_Eggs == true then
    require ("prototypes.NE_Units.New_Worms_Graphics")
end

if NE_Enemies.Settings.NE_Alien_Artifact_Eggs == true and NE_Enemies.Settings.NE_Alien_Artifacts == true then

    local sounds = require("__base__.prototypes.entity.sounds")
    local biter_die_effects = require("__base__.prototypes.entity.biter-die-effects")


    scale_worm_larva = 0.185
    tint_worm_larva = {r=1, g=0.63, b=0, a=0.5}
    range_worm_larva    = 18
    prepare_range_worm_larva    = 6
    damage_modifier_worm_larva    = 30




    local empty_explosion = function(params)
    return
    {
        type = "explosion",
        name = params.name,
        localised_name = params.localised_name,
        flags = {"not-on-map", "hidden"},
        subgroup = "explosions",
        animations = util.empty_sprite(),
        created_effect = params.created_effect
    }
    end


    local explosions =
    {
    empty_explosion
    {
    name = "ne-larva-worm-die",
    localised_name = {"dying-explosion-name", {"entity-name.small-worm-turret"}},
    created_effect = biter_die_effects.ne_larva_worm
    },
    }

    ----Larva WORM DEATH
    local effects = {}
    
    effects.ne_larva_worm =
    {
    type = "direct",
    action_delivery =
    {
        type = "instant",
        target_effects =
        {
        {
            type = "create-particle",
            repeat_count = 2,
            repeat_count_deviation = 2,
            probability = 1,
            affects_target = false,
            show_in_tooltip = false,
            particle_name = "blood-particle",
            offsets =
            {
            { -0.125, -1.289 },
            { -0.1406, -1.195 }
            },
            offset_deviation = { { -0.1992, -1 }, { 0.1992, 1 } },
            tile_collision_mask = nil,
            initial_height = 0.7,
            initial_height_deviation = 0,
            initial_vertical_speed = 0.029,
            initial_vertical_speed_deviation = 0.07,
            speed_from_center = 0.06,
            speed_from_center_deviation = 0.037,
            frame_speed = 1,
            frame_speed_deviation = 0.02,
            tail_length = 30,
            tail_length_deviation = 16,
            tail_width = 1
        },
        {
            type = "create-particle",
            repeat_count = 24,
            repeat_count_deviation = 0,
            probability = 1,
            affects_target = false,
            show_in_tooltip = false,
            particle_name = "blood-particle-lower-layer",
            offsets =
            {
            { -0.0625, -0.3828 }
            },
            offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
            tile_collision_mask = nil,
            initial_height = 0.2,
            initial_height_deviation = 0.05,
            initial_vertical_speed = 0.071,
            initial_vertical_speed_deviation = 0.05,
            speed_from_center = 0.01,
            speed_from_center_deviation = 0.052,
            frame_speed = 1,
            frame_speed_deviation = 0,
            tail_length = 25,
            tail_length_deviation = 0,
            tail_width = 1
        },
        {
            type = "create-particle",
            repeat_count = 3,
            repeat_count_deviation = 0,
            probability = 1,
            affects_target = false,
            show_in_tooltip = false,
            particle_name = "guts-entrails-particle-small-medium",
            offsets = { { 0, 0 } },
            offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
            tile_collision_mask = nil,
            initial_height = 1,
            initial_height_deviation = 0.5,
            initial_vertical_speed = 0.019,
            initial_vertical_speed_deviation = 0.05,
            speed_from_center = 0.03,
            speed_from_center_deviation = 0.05,
            frame_speed = 1,
            frame_speed_deviation = 0,
            tail_length = 3,
            tail_length_deviation = 0,
            tail_width = 1
        }
        }
    }
    }


    for k, explosion in pairs (explosions) do
    if not explosion.localised_name then
        local name = explosion.name
        if name:find("%-explosion") then
        explosion.localised_name = {"dying-explosion-name", {"entity-name."..name:gsub("%-explosion", "")}}
        elseif name:find("%-die") then
        explosion.localised_name = {"dying-explosion-name", {"entity-name."..name:gsub("%-die", "")}}
        end
    end
    end

    data:extend(explosions)

    -------------------------------------------------------------------------------
    --- BASE Larva Worm 
    -------------------------------------------------------------------------------

    NE_Base_Worm_Larva = table.deepcopy(data.raw.turret["small-worm-turret"])

    NE_Base_Worm_Larva.name = "ne-base-larva-worm"
    NE_Base_Worm_Larva.icon = ICONPATH .. "small-worm.png"
    NE_Base_Worm_Larva.icon_size = 32
    NE_Base_Worm_Larva.order = "b-c-ax"
    NE_Base_Worm_Larva.max_health = 60
    NE_Base_Worm_Larva.healing_per_tick = 0.0025
    NE_Base_Worm_Larva.collision_box = {{-0.15, -0.134 }, {0.15, 0.134}}
    NE_Base_Worm_Larva.selection_box = {{-0.3, -0.267 }, {0.3, 0.267}}
    NE_Base_Worm_Larva.map_generator_bounding_box = {{-0.63, -0.6}, {0.63, 0.6}}
    NE_Base_Worm_Larva.shooting_cursor_size = 1
    NE_Base_Worm_Larva.corpse = "ne-larva-worm-corpse"
    NE_Base_Worm_Larva.dying_explosion = "ne-larva-worm-die"
    NE_Base_Worm_Larva.dying_sound = sounds.worm_dying_small(0.3)
    if NE_Enemies.Settings.NE_Alternative_Graphics == true then      
        NE_Base_Worm_Larva.folded_animation = ne_worm_folded_animation(scale_worm_larva, tint_worm_larva)
        NE_Base_Worm_Larva.preparing_animation = ne_worm_preparing_animation(scale_worm_larva, tint_worm_larva, "forward")
        NE_Base_Worm_Larva.prepared_animation = ne_worm_prepared_animation(scale_worm_larva, tint_worm_larva)
        NE_Base_Worm_Larva.prepared_alternative_animation = ne_worm_prepared_alternative_animation(scale_worm_larva, tint_worm_larva)
        NE_Base_Worm_Larva.starting_attack_animation = ne_worm_start_attack_animation(scale_worm_larva, tint_worm_larva)
        NE_Base_Worm_Larva.ending_attack_animation = ne_worm_end_attack_animation(scale_worm_larva, tint_worm_larva)
        NE_Base_Worm_Larva.folding_animation =  ne_worm_preparing_animation(scale_worm_larva, tint_worm_larva, "backward")
    else 
        NE_Base_Worm_Larva.folded_animation = worm_folded_animation(scale_worm_larva, tint_worm_larva)
        NE_Base_Worm_Larva.preparing_animation = worm_preparing_animation(scale_worm_larva, tint_worm_larva, "forward")
        NE_Base_Worm_Larva.prepared_animation = worm_prepared_animation(scale_worm_larva, tint_worm_larva)
        NE_Base_Worm_Larva.prepared_alternative_animation = worm_prepared_alternative_animation(scale_worm_larva, tint_worm_larva)
        NE_Base_Worm_Larva.starting_attack_animation = worm_start_attack_animation(scale_worm_larva, tint_worm_larva)
        NE_Base_Worm_Larva.ending_attack_animation = worm_end_attack_animation(scale_worm_larva, tint_worm_larva)
        NE_Base_Worm_Larva.folding_animation =  worm_preparing_animation(scale_worm_larva, tint_worm_larva, "backward")
    end    
    NE_Base_Worm_Larva.integration = worm_integration(scale_worm_larva)
    NE_Base_Worm_Larva.prepared_sound = sounds.worm_breath(0.3)
    NE_Base_Worm_Larva.preparing_sound = sounds.worm_standup_small(0.5)
    NE_Base_Worm_Larva.starting_attack_sound = sounds.worm_roars(0.3)
    NE_Base_Worm_Larva.folding_sound = sounds.worm_fold(0.5)
    NE_Base_Worm_Larva.prepared_alternative_sound = sounds.worm_roar_alternative(0.3)
    NE_Base_Worm_Larva.autoplace = nil
    NE_Base_Worm_Larva.alert_when_damaged = false
    NE_Base_Worm_Larva.alert_when_attacking = false
    NE_Base_Worm_Larva.resistances = {{
        type = "ne_fire",
        percent = 100
    }}
    NE_Base_Worm_Larva.loot = {}
    NE_Base_Worm_Larva.prepare_range = range_worm_larva + prepare_range_worm_larva
    NE_Base_Worm_Larva.call_for_help_radius = 30
    NE_Base_Worm_Larva.damaged_trigger_effect = nil
    NE_Base_Worm_Larva.attack_parameters =
    {
    type = "stream",
    cooldown = 4,
    range_mode = "bounding-box-to-bounding-box",
    ammo_category = 'biological',
    range = range_worm_larva,--defined in spitter-projectiles.lua
    damage_modifier = damage_modifier_worm_larva,--defined in spitter-projectiles.lua
    min_range = 0,
    projectile_creation_parameters = worm_shoot_shiftings(scale_worm_larva, scale_worm_larva * scale_worm_stream),
    use_shooter_direction = true,
    lead_target_for_projectile_speed = 0.2* 0.75 * 1.5 *1.5, -- this is same as particle horizontal speed of flamethrower fire stream
    ammo_type = {
        category = "biological",
        target_type = "direction",
        action = {
            type = "direct",
            action_delivery = {
                type = "projectile",
                projectile = "Larva-Worm-Projectile",
                source_offset = {0.15, -0.5},
                starting_speed = 0.15,
                max_range = 18,
            }
        }
    },


    cyclic_sound =
    {
        begin_sound =
        {
        {
            filename = "__base__/sound/creatures/worm-spit-start.ogg",
            volume = 0.0
        },
        {
            filename = "__base__/sound/creatures/worm-spit-start-2.ogg",
            volume = 0.0
        },
        {
            filename = "__base__/sound/creatures/worm-spit-start-3.ogg",
            volume = 0.0
        }
        },
        end_sound =
        {
        {
            filename = "__base__/sound/creatures/worm-spit-end.ogg",
            volume = 0.0
        }
        }
    }
    }

    data:extend{NE_Base_Worm_Larva}



    ------------------------- Worm Variations --------------------

    ---------------------------------------------------------------------------------------------------------------------------------------------------
    --- Worm 1 : Grower
    ---------------------------------------------------------------------------------------------------------------------------------------------------

    
    NE_Base_Worm_Larva1 = table.deepcopy(data.raw.turret["ne-base-larva-worm"])
    NE_Base_Worm_Larva1.name = "ne-larva-worm-1"
    NE_Base_Worm_Larva1.localised_description = {"entity-description.ne-larva-worm-1"}
    data:extend{NE_Base_Worm_Larva1}

    ---------------------------------------------------------------------------------------------------------------------------------------------------
    --- Worm 2 : Shower
    ---------------------------------------------------------------------------------------------------------------------------------------------------

    NE_Base_Worm_Larva2 = table.deepcopy(data.raw.turret["ne-base-larva-worm"])
    NE_Base_Worm_Larva2.name = "ne-larva-worm-2"
    NE_Base_Worm_Larva2.localised_description = {"entity-description.ne-larva-worm-2"}
    NE_Base_Worm_Larva2.max_health = 100
    NE_Base_Worm_Larva2.healing_per_tick = -0.0025
    NE_Base_Worm_Larva2.attack_parameters.ammo_type.action.action_delivery.projectile = "Larva-Worm-Projectile-1"
    data:extend{NE_Base_Worm_Larva2}

    


    ---------------------------------------------------------------------------------------------------------------------------------------------------


    if NE_Enemies.Settings.NE_Alternative_Graphics == true then
        ne_w_animation = ne_worm_die_animation(scale_worm_larva, tint_worm_small)
    else
       ne_w_animation = worm_die_animation(scale_worm_larva, tint_worm_small)
    end

    data:extend(
    {
        {
            type = "corpse",
            name = "ne-larva-worm-corpse",
            icon = ICONPATH .. "small-worm-corpse.png",
            icon_size = 32,
            selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
            selectable_in_game = false,
            dying_speed = 0.01,
            time_before_removed = 5 * 60 * 60,
            subgroup="corpses",
            order = "c[corpse]-c[worm]-a[small]",
            flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-repairable", "not-on-map"},
            final_render_layer = "lower-object-above-shadow",
            ground_patch =
            {
            sheet = worm_integration(scale_worm_larva)
            },
            animation = ne_w_animation
        },
    })

end

