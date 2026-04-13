---@meta
------------------------------------------------------------------------
-- Item generation code
------------------------------------------------------------------------

local meld = require('meld')
local util = require('util')
local collision_mask_util = require('collision-mask-util')

require 'circuit-connector-generated-definitions'
require 'circuit-connector-sprites'
require 'sound-util'

local const = require('lib.constants')

local FORMAT_STRING = '%.2fkW'

-- similar to the original miniloader module, this uses an inserter as the "main" entity.
-- unlike the miniloader, it manages all other entities fully. It also uses different inserter entities for
-- primary and hidden inserters which allows for correct power stats and blueprints.

local loader_connector_definitions = circuit_connector_definitions.create_vector(
    universal_connector_template,
    {
        { variation = 26, main_offset = util.by_pixel(1, 11),  shadow_offset = util.by_pixel(1, 12), show_shadow = true },  -- North
        { variation = 24, main_offset = util.by_pixel(-15, 0), shadow_offset = { 0, 0 }, },                                 -- East
        { variation = 24, main_offset = util.by_pixel(-17, 0), shadow_offset = { 0, 0 }, },                                 -- South
        { variation = 31, main_offset = util.by_pixel(15, 0),  shadow_offset = { 0, 0 }, },                                 -- West

        { variation = 31, main_offset = util.by_pixel(17, 0),  shadow_offset = { 0, 0 }, },                                 -- South
        { variation = 31, main_offset = util.by_pixel(15, 0),  shadow_offset = { 0, 0 }, },                                 -- West
        { variation = 30, main_offset = util.by_pixel(0, 11),  shadow_offset = util.by_pixel(0, 12), show_shadow = true, }, -- North
        { variation = 24, main_offset = util.by_pixel(-15, 0), shadow_offset = { 0, 0 }, },                                 -- East
    }
)

local inserter_connector_definitions = circuit_connector_definitions.create_vector(
    universal_connector_template,
    {
        { variation = 31, main_offset = util.by_pixel(17, 0),  shadow_offset = { 0, 0 }, }, -- North
        { variation = 30, main_offset = util.by_pixel(0, 11),  shadow_offset = { 0, 0 }, }, -- West
        { variation = 24, main_offset = util.by_pixel(-17, 0), shadow_offset = { 0, 0 }, }, -- South
        { variation = 26, main_offset = util.by_pixel(1, 11),  shadow_offset = { 0, 0 }, }, -- East
    }
)

--- Either returns '' or '<name>-'
local function compute_dash_prefix(name)
    if not (name and name:len() > 0) then return '' end
    return name .. '-'
end

local function icon_gfx(tint, variant, mask_variant)
    if not mask_variant then mask_variant = '' end

    local name = compute_dash_prefix(variant)
    local mask_name = compute_dash_prefix(mask_variant)

    return {
        {
            icon = const:png('item/' .. name .. 'icon-base'),
            icon_size = 64,
        },
        {
            icon = const:png('item/' .. mask_name .. 'icon-mask'),
            icon_size = 64,
            tint = tint,
        },
    }
end

local function entity_sheets_gfx(tint, variant, offset)
    local name = compute_dash_prefix(variant)

    return {
        -- Base
        {
            filename = const:png('entity/' .. name .. 'miniloader-structure-base'),
            height = 192,
            priority = 'extra-high',
            scale = 0.5,
            width = 192,
            y = offset or 0,
        },
        -- Mask
        {
            filename = const:png('entity/miniloader-structure-mask'),
            height = 192,
            priority = 'extra-high',
            scale = 0.5,
            width = 192,
            y = offset or 0,
            tint = tint,
        },
        -- Shadow
        {
            filename = const:png('entity/miniloader-structure-shadow'),
            draw_as_shadow = true,
            height = 192,
            priority = 'extra-high',
            scale = 0.5,
            width = 192,
            y = offset or 0,
        }
    }
end

local function technology_gfx(tint, variant)
    local name = compute_dash_prefix(variant)

    return {
        {
            icon = const:png('technology/' .. name .. 'technology-base'),
            icon_size = 128,
        },
        {
            icon = const:png('technology/technology-mask'),
            icon_size = 128,
            tint = tint,
        },
    }
end

---@param params miniloader.LoaderTemplate
local function create_item(params)
    local stack_size = params.stack_size or 50

    local item = {
        -- PrototypeBase
        type = 'item',
        name = params.name,
        localised_name = params.localised_name,
        order = params.order,
        subgroup = params.subgroup,

        -- ItemPrototype
        stack_size = stack_size,
        weight = 1000 / stack_size * kg,
        icons = icon_gfx(params.tint, params.entity_gfx),

        place_result = params.name,
    }

    data:extend { item }
end

---@param loader data.LoaderPrototype
---@param name string
local function default_belt_color_selector(loader, name)
    if not (name and name:len() > 0) then return end
    local belt_source = data.raw['underground-belt'][compute_dash_prefix(name) .. 'underground-belt']
    if not belt_source then return end
    loader.belt_animation_set = util.copy(belt_source.belt_animation_set)
end

---@param params miniloader.LoaderTemplate
---@param prototype data.EntityWithOwnerPrototype
local function apply_prototype_processors(params, prototype)
    for _, processor in pairs(params.global_prototype_processors) do
        processor(prototype)
    end

    if params.prototype_processor then params.prototype_processor(prototype) end
end

---@param params miniloader.LoaderTemplate
local function create_entity(params)
    local entity_name = params.name
    local loader_name = const.loader_name(entity_name)
    local inserter_name = const.inserter_name(entity_name)
    local corpse_gfx = params.corpse_gfx or params.prefix
    local explosion_gfx = params.explosion_gfx or corpse_gfx
    local belt_gfx = params.belt_gfx or params.prefix
    local belt_color_selector = params.belt_color_selector or default_belt_color_selector

    local speed_config = params.speed_config
    -- can not go faster than 0.5 (max half a rotation per tick - see https://wiki.factorio.com/inserters#Rotation_Speed)
    assert(speed_config.rotation_speed <= 0.5, ('Rotation speed: %.2f'):format(speed_config.rotation_speed))

    local description = { '',
        { 'entity-description.' .. entity_name },
        '\n',
        '[font=default-semibold][color=255,230,192]',
        { 'description.belt-speed' },
        ':[/color][/font] ',
        tostring(speed_config.items_per_second),
        ' ',
        { 'description.belt-items' },
        { 'per-second-suffix' }
    }

    local void_energy = { type = 'void', }

    ---@type data.ElectricEnergySource|data.VoidEnergySource|data.BurnerEnergySource
    local primary_energy = {
        type = 'electric',
        usage_priority = 'secondary-input',
        render_no_power_icon = true,
        render_no_network_icon = true,
    }

    local consumption_amount = math.sqrt(math.pow(speed_config.items_per_second, 2) / 8) * (params.bulk and 2 or 1) * 5
    local drain_amount = 0.4 + (speed_config.items_per_second / 150) * speed_config.inserter_pairs

    if Framework.settings:startup_setting(const.settings_names.no_power) then
        primary_energy = void_energy
        consumption_amount = 0
        drain_amount = 0
    elseif params.energy_source then
        primary_energy, consumption_amount, drain_amount = params.energy_source()
    end

    local consumption = FORMAT_STRING:format(consumption_amount)
    local hidden_consumption = FORMAT_STRING:format(consumption_amount / (speed_config.inserter_pairs * 2 - 1))
    local drain = FORMAT_STRING:format(drain_amount)

    if drain_amount > 0 then primary_energy.drain = drain end

    -- This is the entity that is used to represent the miniloader.
    -- - it can be rotated
    -- - it has four different pictures

    local inserter = {
        -- Prototype Base
        type                           = 'inserter',
        name                           = entity_name,
        order                          = params.order,
        localised_name                 = params.localised_name,
        localised_description          = description,
        subgroup                       = params.subgroup,
        hidden                         = false,
        hidden_in_factoriopedia        = false,

        -- InserterPrototype
        extension_speed                = speed_config.rotation_speed * 5,
        rotation_speed                 = speed_config.rotation_speed,
        insert_position                = { 0, 0 },
        pickup_position                = { 0, 0 },

        platform_picture               = {
            sheets = entity_sheets_gfx(params.tint, params.entity_gfx),
        },
        hand_base_picture              = util.empty_sprite(),
        hand_open_picture              = util.empty_sprite(),
        hand_closed_picture            = util.empty_sprite(),
        hand_base_shadow               = util.empty_sprite(),
        hand_open_shadow               = util.empty_sprite(),
        hand_closed_shadow             = util.empty_sprite(),
        energy_source                  = primary_energy,
        energy_per_movement            = consumption,
        energy_per_rotation            = consumption,
        uses_inserter_stack_size_bonus = false, -- otherwise does not match belt speed
        allow_custom_vectors           = true,
        draw_held_item                 = false,
        use_easter_egg                 = false,
        filter_count                   = params.nerf_mode and 0 or 5,

        -- handle stacking
        bulk                           = params.bulk or false,
        wait_for_full_hand             = params.bulk or false,
        grab_less_to_match_belt_stack  = params.bulk or false,
        stack_size_bonus               = params.bulk and 4 or speed_config.stack_size_bonus,
        max_belt_stack_size            = params.bulk and 4 or 1,

        circuit_wire_max_distance      = not params.nerf_mode and default_circuit_wire_max_distance or 0,
        draw_inserter_arrow            = false,
        chases_belt_items              = false,
        circuit_connector              = not params.nerf_mode and inserter_connector_definitions or nil,

        -- EntityWitHealthPrototype
        max_health                     = 170,
        damaged_trigger_effect         = {
            type = 'create-entity',
            entity_name = 'spark-explosion',
            offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
            offsets = { { 0, 1 } },
            damage_type_filters = 'fire'
        },
        dying_explosion                = compute_dash_prefix(explosion_gfx) .. 'underground-belt-explosion',
        resistances                    = {
            {
                type = 'fire',
                percent = 60
            },
            {
                type = 'impact',
                percent = 30
            }
        },
        corpse                         = compute_dash_prefix(corpse_gfx) .. 'underground-belt-remnants',

        -- EntityPrototype
        icons                          = icon_gfx(params.tint, params.entity_gfx),

        collision_box                  = { { -0.4, -0.4 }, { 0.4, 0.4 } },
        collision_mask                 = collision_mask_util.get_default_mask('inserter'),
        selection_box                  = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        flags                          = { 'placeable-neutral', 'placeable-player', 'player-creation' },
        minable                        = { mining_time = 0.1, result = entity_name },
        selection_priority             = 50,
        impact_category                = 'metal',
        open_sound                     = { filename = '__base__/sound/open-close/inserter-open.ogg', volume = 0.6 },
        close_sound                    = { filename = '__base__/sound/open-close/inserter-close.ogg', volume = 0.5 },
        working_sound                  = {
            match_progress_to_activity = true,
            sound = sound_variations('__base__/sound/inserter-basic', 5, 0.5, { volume_multiplier('main-menu', 2), volume_multiplier('tips-and-tricks', 1.8) }),
            audible_distance_modifier = 0.3
        },
        fast_replaceable_group         = 'mini-loader',
    }

    apply_prototype_processors(params, inserter)

    local hidden_inserter = meld(util.copy(inserter), {
        name = inserter_name,
        icons = icon_gfx(params.tint, 'internal', 'internal'),
        localised_name = { 'entity-name.' .. inserter_name },
        description = { 'entity-description.' .. inserter_name },
        localised_description = meld.delete(),

        hidden = true,
        hidden_in_factoriopedia = true,
        energy_per_movement = hidden_consumption,
        energy_per_rotation = hidden_consumption,
        platform_picture = meld.overwrite(util.empty_sprite()),
        collision_mask = meld.overwrite(collision_mask_util.new_mask()),
        selection_box = { { 0, 0 }, { 0, 0 } },
        flags = meld.overwrite {
            'placeable-neutral',
            'placeable-player',
            'not-on-map',
            'not-deconstructable',
            'not-blueprintable',
            'hide-alt-info',
            'not-flammable',
            'not-upgradable',
            'not-in-kill-statistics',
            'not-in-made-in',
        },
        minable = meld.delete(),
        selection_priority = 0,
        allow_copy_paste = false,
        selectable_in_game = false,
        fast_replaceable_group = meld.delete(),
    })

    table.insert(hidden_inserter.flags, 'placeable-off-grid')

    apply_prototype_processors(params, hidden_inserter)

    local loader = {
        -- Prototype Base
        name                        = loader_name,
        localised_name              = { 'entity-name.' .. loader_name },
        description                 = { 'entity-description.' .. loader_name },
        type                        = 'loader-1x1',
        order                       = params.order,
        subgroup                    = params.subgroup,
        hidden                      = true,
        hidden_in_factoriopedia     = true,

        -- LoaderPrototype
        structure                   = {
            direction_in = {
                sheets = entity_sheets_gfx(params.tint, params.entity_gfx)
            },
            direction_out = {
                sheets = entity_sheets_gfx(params.tint, params.entity_gfx, 192),
            },
            back_patch = {
                sheet = {
                    filename = const:png('entity/miniloader-structure-back-patch'),
                    priority = 'extra-high',
                    width = 192,
                    height = 192,
                    scale = 0.5,
                }
            },
            front_patch = {
                sheet = {
                    filename = const:png('entity/miniloader-structure-front-patch'),
                    priority = 'extra-high',
                    width = 192,
                    height = 192,
                    scale = 0.5,
                }
            }
        },
        filter_count                = params.nerf_mode and 0 or 5,
        structure_render_layer      = 'object',
        container_distance          = 0,
        allow_rail_interaction      = false,
        allow_container_interaction = false,
        per_lane_filters            = false,
        energy_source               = void_energy,
        energy_per_item             = '0.0000001W',

        circuit_wire_max_distance   = default_circuit_wire_max_distance,
        circuit_connector           = loader_connector_definitions,

        -- EntityWitHealthPrototype
        max_health                  = 10,

        -- TransportBeltConnectablePrototype
        belt_animation_set          = util.copy(data.raw['underground-belt']['underground-belt'].belt_animation_set),
        animation_speed_coefficient = 32,
        speed                       = params.speed,

        -- EntityPrototype
        icons                       = icon_gfx(params.tint, 'internal', 'internal'),

        collision_box               = { { -0.4, -0.4 }, { 0.4, 0.4 } },
        collision_mask              = { layers = { transport_belt = true, } },
        selection_box               = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        flags                       = {
            'placeable-neutral',
            'placeable-player',
            'not-on-map',
            'not-deconstructable',
            'not-blueprintable',
            'hide-alt-info',
            'not-flammable',
            'not-upgradable',
            'not-in-kill-statistics',
            'not-in-made-in',
        },
        minable                     = nil,
        selection_priority          = 0,
        allow_copy_paste            = false,
        selectable_in_game          = false,
    }

    -- hack to get the belt color right
    belt_color_selector(loader, belt_gfx)

    apply_prototype_processors(params, loader)

    data:extend { inserter, hidden_inserter, loader }
end

local function create_recipe(params)
    local double_recipe = Framework.settings:startup_setting(const.settings_names.double_recipes)

    local ingredients = util.copy(params.ingredients())
    if double_recipe then
        for _, ingredient in pairs(ingredients) do
            ingredient.amount = ingredient.amount * 2
        end
    end

    local recipe = {
        type           = 'recipe',
        name           = params.name,
        localised_name = params.localised_name,
        ingredients    = ingredients,
        enabled        = false,
        results        = {
            {
                type = 'item',
                name = params.name,
                amount = double_recipe and 2 or 1,
            },
        },
    }

    local technology = {
        type                  = 'technology',
        name                  = params.name,
        order                 = params.order,
        icons                 = technology_gfx(params.tint, params.entity_gfx),
        prerequisites         = params.prerequisites(),
        research_trigger      = params.research_trigger,
        visible_when_disabled = false,
        effects               = {
            {
                type = 'unlock-recipe',
                recipe = params.name,
            }
        }
    }

    -- apply tint to copied icon
    technology.icons[2].tint = params.tint

    if not (technology.unit or technology.research_trigger) then
        assert(technology.prerequisites[1])
        local main_prereq = data.raw['technology'][technology.prerequisites[1]]

        if main_prereq.unit then
            technology.unit = util.copy(main_prereq.unit)
        else
            technology.research_trigger = util.copy(main_prereq.research_trigger)
        end
    end

    data:extend { recipe, technology }
end

---@param params miniloader.LoaderTemplate
local function create_debug(params)
    local debug_name = const.debug_name(params.name)
    local subgroup = 'miniloader-debug'

    local src = assert(data.raw['inserter'][params.name])

    -- item
    local debug_item = meld(util.copy(data.raw['item']['inserter']), {
        name           = debug_name,
        localised_name = { 'entity-name.' .. debug_name },
        order          = params.order,
        subgroup       = subgroup,
        place_result   = debug_name,
    })

    debug_item.icons = {
        {
            icon = debug_item.icon,
            tint = params.tint,
        },
    }

    debug_item.icon = nil

    -- entity
    local debug_inserter = meld(util.copy(data.raw['inserter']['inserter']), {
        -- Prototype Base
        name                           = debug_name,
        localised_name                 = { 'entity-name.' .. debug_name },
        subgroup                       = subgroup,
        hidden_in_factoriopedia        = true,

        -- InserterPrototype
        extension_speed                = src.extension_speed,
        rotation_speed                 = src.rotation_speed,
        insert_position                = src.insert_position,
        pickup_position                = src.pickup_position,

        uses_inserter_stack_size_bonus = src.uses_inserter_stack_size_bonus,
        allow_custom_vectors           = src.allow_custom_vectors,
        use_easter_egg                 = src.use_easter_egg,
        filter_count                   = src.filter_count,

        -- handle stacking
        bulk                           = src.bulk,
        wait_for_full_hand             = src.wait_for_full_hand,
        grab_less_to_match_belt_stack  = src.grab_less_to_match_belt_stack,
        stack_size_bonus               = src.stack_size_bonus,
        max_belt_stack_size            = src.max_belt_stack_size,

        circuit_wire_max_distance      = src.circuit_wire_max_distance,
        chases_belt_items              = src.chases_belt_items,
        circuit_connector              = src.circuit_connector,
        collision_mask                 = meld.overwrite(collision_mask_util.new_mask()),
        next_upgrade                   = meld.delete(),
        minable                        = { mining_time = 0.1, result = debug_name },
    })

    table.insert(debug_inserter.flags, 'placeable-off-grid')

    debug_inserter.platform_picture.sheet.tint = params.tint

    local debug_recipe = meld(util.copy(data.raw['recipe']['inserter']), {
        name           = debug_name,
        localised_name = { 'entity-name.' .. debug_name },
        enabled        = true,
        results        = {
            {
                type = 'item',
                name = debug_name,
                amount = 1,
            },
        },
    })

    data:extend { debug_item, debug_inserter, debug_recipe }
end

return {
    create_item = create_item,
    create_entity = create_entity,
    create_recipe = create_recipe,
    create_debug = create_debug,
    compute_dash_prefix = compute_dash_prefix,
}
