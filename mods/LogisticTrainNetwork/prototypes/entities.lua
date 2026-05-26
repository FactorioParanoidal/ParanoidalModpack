--[[ Copyright (c) 2017 Optera
 * Part of Logistics Train Network
 *
 * See LICENSE.md in the project directory for license information.
--]]

local collision_mask_util = require('collision-mask-util')
local data_util = require('prototypes.data-util')
local meld = require('meld')
local util = require('util')

local train_stop = data.raw['train-stop']['train-stop']

local train_stop_update = {
    fast_replaceable_group = train_stop.fast_replaceable_group or 'train-stop',
    next_upgrade = 'logistic-train-stop'
}

data.raw['train-stop']['train-stop'] = meld(train_stop, train_stop_update)

local ltn_stop = data_util.copy_prototype(train_stop, 'logistic-train-stop')

local ltn_stop_update = {
    icon = '__LogisticTrainNetwork__/graphics/icons/train-stop.png',
    icon_size = 64,
    next_upgrade = meld.delete(),
    selection_box = { { -0.6, -0.6 }, { 0.6, 0.6 } },
    -- collision_box = {{-0.5, -0.1}, {0.5, 0.4}},
}

ltn_stop = meld(ltn_stop, ltn_stop_update)

local ltn_stop_in = data_util.copy_prototype(data.raw['lamp']['small-lamp'], 'logistic-train-stop-input')

local ltn_stop_in_update = {
    icon = '__LogisticTrainNetwork__/graphics/icons/train-stop.png',
    icon_size = 64,
    next_upgrade = meld.delete(),
    minable = meld.delete(),
    selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    selection_priority = (ltn_stop_in.selection_priority or 50) + 10, -- increase priority to default + 10
    collision_box = { { -0.15, -0.15 }, { 0.15, 0.15 } },
    collision_mask = { layers = { rail = true } },                    -- collide only with rail entities
    energy_usage_per_tick = '10W',
    light = { intensity = 1, size = 6 },
    energy_source = meld.overwrite { type = 'void' },
    hidden_in_factoriopedia = true,
    hidden = true,
}

ltn_stop_in = meld(ltn_stop_in, ltn_stop_in_update)

---@type data.ConstantCombinatorPrototype
local ltn_stop_out = data_util.copy_prototype(data.raw['constant-combinator']['constant-combinator'], 'logistic-train-stop-output')

local ltn_stop_out_update = {
    icon = '__LogisticTrainNetwork__/graphics/icons/output.png',
    icon_size = 64,
    next_upgrade = meld.delete(),
    minable = meld.delete(),
    selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    selection_priority = (ltn_stop_out.selection_priority or 50) + 10, -- increase priority to default + 10
    collision_box = { { -0.15, -0.15 }, { 0.15, 0.15 } },
    collision_mask = { layers = { rail = true } },                     -- collide only with rail entities
    hidden_in_factoriopedia = true,
    hidden = true,
    fast_replaceable_group = meld.delete(),
    ---@diagnostic disable-next-line: undefined-global
    sprites = meld.overwrite(make_4way_animation_from_spritesheet {
        layers = {
            {
                scale = 0.5,
                filename = '__LogisticTrainNetwork__/graphics/entity/output.png',
                width = 114,
                height = 102,
                frame_count = 1,
                shift = util.by_pixel(0, 5),
            },
            {
                scale = 0.5,
                filename = '__base__/graphics/entity/combinator/constant-combinator-shadow.png',
                width = 98,
                height = 66,
                frame_count = 1,
                shift = util.by_pixel(8.5, 5.5),
                draw_as_shadow = true,
            },
        },
    }),
}

ltn_stop_out = meld(ltn_stop_out, ltn_stop_out_update)

---@type data.ConstantCombinatorPrototype
local ltn_lamp_control = data_util.copy_prototype(data.raw['constant-combinator']['constant-combinator'], 'logistic-train-stop-lamp-control')

local ltn_lamp_control_update = {
    -- icon = '__LogisticTrainNetwork__/graphics/icons/empty.png',
    -- icon_size = 32,
    icon = '__core__/graphics/empty.png',
    next_upgrade = meld.delete(),
    minable = meld.delete(),
    selection_box = meld.delete(),
    collision_box = meld.delete(),
    collision_mask = collision_mask_util.new_mask(), -- disable collision
    flags = meld.overwrite {
        'placeable-off-grid', 'not-repairable', 'not-on-map', 'not-deconstructable', 'not-blueprintable',
        'hide-alt-info', 'not-flammable', 'not-upgradable', 'not-in-kill-statistics', 'not-in-made-in',
    },
    hidden_in_factoriopedia = true,
    hidden = true,
    sprites = meld.overwrite(util.empty_sprite()),
    activity_led_sprites = meld.overwrite(util.empty_sprite()),
    activity_led_light_offsets = meld.overwrite { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } },
    activity_led_light = meld.delete(),
    draw_circuit_wires = false,
    draw_copper_wires = false,
    allow_copy_paste = false,
    selectable_in_game = false,
    fast_replaceable_group = meld.delete(),
}

ltn_lamp_control = meld(ltn_lamp_control, ltn_lamp_control_update)

data:extend {
    ltn_stop,
    ltn_stop_in,
    ltn_stop_out,
    ltn_lamp_control
}

-- support for cargo ship ports
if mods['cargo-ships'] then
    local port = data.raw['train-stop']['port']

    local port_update = {
        fast_replaceable_group = port.fast_replaceable_group or 'port',
        next_upgrade = 'ltn-port',
    }

    data.raw['train-stop']['port'] = meld(port, port_update)

    ltn_port = data_util.copy_prototype(port, 'ltn-port')

    local ltn_port_update = {
        icon = '__LogisticTrainNetwork__/graphics/icons/port.png',
        icon_size = 64,
        next_upgrade = meld.delete(),
        selection_box = { { -0.01, -0.6 }, { 1.9, 0.6 } },
        -- collision_box = {{-0.01, -0.1}, {1.9, 0.4}},
    }

    ltn_port = meld(ltn_port, ltn_port_update)

    data:extend {
        ltn_port
    }
end
