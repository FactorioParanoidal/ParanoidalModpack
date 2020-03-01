--[[
    "name": "naked-rails",
    "title": "Naked Rails",
    "author": "futileohm",
    "description": "Convert standard rails to naked rails, removing the gravel and/or sleepers. Can also change rails to rail remnants for a destroyed look."
--]]
local Data = require('__stdlib__/stdlib/data/data')

local naked_subelements = {'ties', 'stone_path', 'stone_path_background'}
local sleepy_subelements = {'stone_path', 'stone_path_background'}

local straight_picture_ids = {
    {'straight_rail_horizontal', 'straight-rail-horizontal'},
    {'straight_rail_vertical', 'straight-rail-vertical'},
    {'straight_rail_diagonal_left_top', 'straight-rail-diagonal'},
    {'straight_rail_diagonal_right_top', 'straight-rail-diagonal'},
    {'straight_rail_diagonal_right_bottom', 'straight-rail-diagonal'},
    {'straight_rail_diagonal_left_bottom', 'straight-rail-diagonal'}
}

local curved_picture_ids = {
    {'curved_rail_vertical_left_top', 'curved-rail-vertical'},
    {'curved_rail_vertical_right_top', 'curved-rail-vertical'},
    {'curved_rail_vertical_right_bottom', 'curved-rail-vertical'},
    {'curved_rail_vertical_left_bottom', 'curved-rail-vertical'},
    {'curved_rail_horizontal_left_top', 'curved-rail-horizontal'},
    {'curved_rail_horizontal_right_top', 'curved-rail-horizontal'},
    {'curved_rail_horizontal_right_bottom', 'curved-rail-horizontal'},
    {'curved_rail_horizontal_left_bottom', 'curved-rail-horizontal'}
}

--(( Base
if not settings.startup['picker-naked-rails'].value then
    return
end

local PLANNER = Data('rail', 'rail-planner')
local STRAIGHT = Data('straight-rail', 'straight-rail')
local CURVED = Data('curved-rail', 'curved-rail')
local SR = Data('straight-rail-remnants', 'rail-remnants')
SR.time_before_removed = 1073741824
SR.minable = {
    hardness = 0.2,
    mining_time = 1,
    results = nil -- Not using results
}
SR.selectable_in_game = true

local CR = Data('curved-rail-remnants', 'rail-remnants')
CR.time_before_removed = 1073741824
CR.minable = {
    hardness = 0.2,
    mining_time = 1,
    results = nil -- not using results
}
CR.secondary_collision_box = { { -0.65, -2.43 }, { 0.65, 2.43 } }
CR.selectable_in_game = true
--))

do --(( naked-rail
    PLANNER:copy('picker-naked-rail'):set_fields {
        order = 'a[train-system]-a[train]-z',
        icon = '__PickerVehicles__/graphics/nakedrails/naked-rails-icon.png',
        place_result = 'picker-naked-straight-rail',
        straight_rail = 'picker-naked-straight-rail',
        curved_rail = 'picker-naked-curved-rail'
    }:Flags():add('hidden')

    --(( straight-rail
    local straight = STRAIGHT:copy('picker-naked-straight-rail', 'rail')

    straight.corpse = 'picker-naked-straight-rail-remnants'
    straight.pictures['rail_endings'].sheets[1].filename = '__PickerVehicles__/graphics/nakedrails/rail-endings-transparent.png'
    straight.pictures['rail_endings'].sheets[1].hr_version.filename = '__PickerVehicles__/graphics/nakedrails/hr-rail-endings-transparent.png'

    for _, id in ipairs(straight_picture_ids) do
        for _, element in ipairs(naked_subelements) do
            straight.pictures[id[1]][element].filename = string.format('__PickerVehicles__/graphics/nakedrails/%s-transparent.png', id[2])
            straight.pictures[id[1]][element].hr_version.filename = string.format('__PickerVehicles__/graphics/nakedrails/hr-%s-transparent.png', id[2])
        end
    end --))

    --(( curved-rail
    local curved = CURVED:copy('picker-naked-curved-rail', 'rail')
    curved.corpse = 'picker-naked-curved-rail-remnants'
    curved.pictures['rail_endings'].sheets[1].filename = '__PickerVehicles__/graphics/nakedrails/rail-endings-transparent.png'
    curved.pictures['rail_endings'].sheets[1].hr_version.filename = '__PickerVehicles__/graphics/nakedrails/hr-rail-endings-transparent.png'

    for _, id in ipairs(curved_picture_ids) do
        for _, element in ipairs(naked_subelements) do
            curved.pictures[id[1]][element].filename = string.format('__PickerVehicles__/graphics/nakedrails/%s-transparent.png', id[2])
            curved.pictures[id[1]][element].hr_version.filename = string.format('__PickerVehicles__/graphics/nakedrails/hr-%s-transparent.png', id[2])
        end
    end --))
end --))

do --(( naked-remnants
    --(( straight-rail
    local straight = SR:copy('picker-naked-straight-rail-remnants')

    for _, id in ipairs(straight_picture_ids) do
        for _, element in ipairs(naked_subelements) do
            straight.pictures[id[1]][element].filename = string.format('__PickerVehicles__/graphics/nakedrails/%s-transparent.png', id[2])
            straight.pictures[id[1]][element].hr_version.filename = string.format('__PickerVehicles__/graphics/nakedrails/hr-%s-transparent.png', id[2])
        end
    end --))

    --(( curved-rail
    local curved = CR:copy('picker-naked-curved-rail-remnants')

    for _, id in ipairs(curved_picture_ids) do
        for _, element in ipairs(naked_subelements) do
            curved.pictures[id[1]][element].filename = string.format('__PickerVehicles__/graphics/nakedrails/%s-transparent.png', id[2])
            curved.pictures[id[1]][element].hr_version.filename = string.format('__PickerVehicles__/graphics/nakedrails/hr-%s-transparent.png', id[2])
        end
    end --))
end --))

do --(( sleepy-rail
    PLANNER:copy('picker-sleepy-rail'):set_fields {
        order = 'a[train-system]-a[train]-z',
        icon = '__PickerVehicles__/graphics/nakedrails/sleepers-icon.png',
        place_result = 'picker-sleepy-straight-rail',
        straight_rail = 'picker-sleepy-straight-rail',
        curved_rail = 'picker-sleepy-curved-rail'
    }:Flags():add('hidden')

    --(( straight-rail
    local straight = STRAIGHT:copy('picker-sleepy-straight-rail', 'rail')
    straight.corpse = 'picker-sleepy-straight-rail-remnants'
    straight.pictures['rail_endings'].sheets[1].filename = '__PickerVehicles__/graphics/nakedrails/rail-endings-transparent.png'
    straight.pictures['rail_endings'].sheets[1].hr_version.filename = '__PickerVehicles__/graphics/nakedrails/hr-rail-endings-transparent.png'

    for _, id in ipairs(straight_picture_ids) do
        for _, element in ipairs(sleepy_subelements) do
            straight.pictures[id[1]][element].filename = string.format('__PickerVehicles__/graphics/nakedrails/%s-transparent.png', id[2])
            straight.pictures[id[1]][element].hr_version.filename = string.format('__PickerVehicles__/graphics/nakedrails/hr-%s-transparent.png', id[2])
        end
    end --))

    --(( curved-rail
    local curved = CURVED:copy('picker-sleepy-curved-rail', 'rail')
    curved.corpse = 'picker-sleepy-curved-rail-remnants'

    curved.pictures['rail_endings'].sheets[1].filename = '__PickerVehicles__/graphics/nakedrails/rail-endings-transparent.png'
    curved.pictures['rail_endings'].sheets[1].hr_version.filename = '__PickerVehicles__/graphics/nakedrails/hr-rail-endings-transparent.png'

    for _, id in ipairs(curved_picture_ids) do
        for _, element in ipairs(sleepy_subelements) do
            curved.pictures[id[1]][element].filename = string.format('__PickerVehicles__/graphics/nakedrails/%s-transparent.png', id[2])
            curved.pictures[id[1]][element].hr_version.filename = string.format('__PickerVehicles__/graphics/nakedrails/hr-%s-transparent.png', id[2])
        end
    end --))
end --))

do --(( sleepy-remnants
    --(( straight-rail
    local straight = SR:copy('picker-sleepy-straight-rail-remnants')

    for _, id in ipairs(straight_picture_ids) do
        for _, element in ipairs(sleepy_subelements) do
            straight.pictures[id[1]][element].filename = string.format('__PickerVehicles__/graphics/nakedrails/%s-transparent.png', id[2])
            straight.pictures[id[1]][element].hr_version.filename = string.format('__PickerVehicles__/graphics/nakedrails/hr-%s-transparent.png', id[2])
        end
    end --))

    --(( curved-rail
    local curved = CR:copy('picker-sleepy-curved-rail-remnants')

    for _, id in ipairs(curved_picture_ids) do
        for _, element in ipairs(sleepy_subelements) do
            curved.pictures[id[1]][element].filename = string.format('__PickerVehicles__/graphics/nakedrails/%s-transparent.png', id[2])
            curved.pictures[id[1]][element].hr_version.filename = string.format('__PickerVehicles__/graphics/nakedrails/hr-%s-transparent.png', id[2])
        end
    end --))
end --))

do --(( Selection Tools
    Data {
        type = 'selection-tool',
        name = 'picker-naked-rails-stoneify',
        flags = {'hidden', 'only-in-cursor'},
        subgroup = 'transport',
        stack_size = 1,
        stackable = false,
        show_in_library = true,
        order = 'a[train-system]-y[naked-rails-stoneify]',
        selection_color = {r = 1, g = 1, b = 1, a = 0.2},
        alt_selection_color = {r = 0.5, g = 0.5, b = 0.5, a = 0.2},
        selection_mode = {'buildable-type'},
        alt_selection_mode = {'buildable-type'},
        selection_cursor_box_type = 'entity',
        alt_selection_cursor_box_type = 'copy',
        icons = {
            {icon = '__PickerVehicles__/graphics/nakedrails/naked-replacer-icon.png'},
            {
                icon = '__base__/graphics/icons/rail.png',
                scale = 0.75
            },
            {
                icon = '__base__/graphics/icons/stone.png',
                scale = 0.3,
                shift = {6, -6}
            }
        },
        icon_size = 32
    }

    Data {
        type = 'selection-tool',
        name = 'picker-naked-rails-sleepify',
        flags = {'hidden', 'only-in-cursor'},
        subgroup = 'transport',
        stack_size = 1,
        stackable = false,
        show_in_library = true,
        order = 'a[train-system]-x[naked-rails-sleepify]',
        selection_color = {r = 1, g = 1, b = 1, a = 0.2},
        alt_selection_color = {r = 0.5, g = 0.5, b = 0.5, a = 0.2},
        selection_mode = {'buildable-type'},
        alt_selection_mode = {'buildable-type'},
        selection_cursor_box_type = 'entity',
        alt_selection_cursor_box_type = 'copy',
        icons = {
            {icon = '__PickerVehicles__/graphics/nakedrails/naked-replacer-icon.png'},
            {
                icon = '__base__/graphics/icons/rail.png',
                scale = 0.75
            }
        },
        icon_size = 32
    }

    Data {
        type = 'selection-tool',
        name = 'picker-naked-rails-nakedify',
        flags = {'hidden', 'only-in-cursor'},
        subgroup = 'transport',
        stack_size = 1,
        stackable = false,
        show_in_library = true,
        order = 'a[train-system]-w[naked-rails-nakedify]',
        selection_color = {r = 1, g = 1, b = 1, a = 0.2},
        alt_selection_color = {r = 0.5, g = 0.5, b = 0.5, a = 0.2},
        selection_mode = {'buildable-type'},
        alt_selection_mode = {'buildable-type'},
        selection_cursor_box_type = 'entity',
        alt_selection_cursor_box_type = 'copy',
        icons = {
            {icon = '__PickerVehicles__/graphics/nakedrails/naked-replacer-icon.png'},
            {
                icon = '__PickerVehicles__/graphics/nakedrails/naked-rails-icon.png',
                scale = 0.75,
                tint = {r = 1, g = 1, b = 1, a = 0.5}
            }
        },
        icon_size = 32
    }

    Data {
        type = 'selection-tool',
        name = 'picker-naked-rails-remnantify',
        flags = {'hidden', 'only-in-cursor'},
        subgroup = 'transport',
        stack_size = 1,
        stackable = false,
        show_in_library = true,
        order = 'a[train-system]-z[naked-rails-remnantify]',
        selection_color = {r = 1, g = 1, b = 1, a = 0.2},
        alt_selection_color = {r = 1, g = 0, b = 0},
        selection_mode = {'buildable-type'},
        alt_selection_mode = {'any-entity'},
        selection_cursor_box_type = 'entity',
        alt_selection_cursor_box_type = 'not-allowed',
        icons = {
            {icon = '__PickerVehicles__/graphics/nakedrails/naked-replacer-icon.png'},
            {
                icon = '__base__/graphics/icons/straight-rail-remnants.png',
                scale = 0.7
            }
        },
        icon_size = 32
    }
end --))
