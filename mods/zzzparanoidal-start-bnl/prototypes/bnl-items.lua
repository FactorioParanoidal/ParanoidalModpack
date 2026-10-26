-- Items of the BnL start: flight recorder (a lab input of its decoding research), antenna parts
-- and the distress beacon, the note of the previous expedition and the BnL advertising flyer.
local icons = "__zzzparanoidal-start-bnl__/graphics/icons/"
local item_sounds = require("__base__.prototypes.item_sounds")

local read_action = {
    type = "use-on-self",
    attack_parameters = {
        type = "projectile",
        activation_type = "consume",
        ammo_category = "capsule",
        cooldown = 30,
        range = 0,
        ammo_type = {
            target_type = "position",
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {{type = "script", effect_id = "bnl-read"}},
                },
            },
        },
    },
}

data:extend({
    {
        type = "item-subgroup",
        name = "bnl-start",
        group = "production",
        order = "x-b",
    },
    {
        type = "tool",
        name = "bnl-flight-recorder",
        icon = icons .. "flight-recorder.png",
        icon_size = 64,
        subgroup = "bnl-start",
        order = "a[flight-recorder]",
        stack_size = 1,
        durability = 1,
        auto_recycle = false,
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
    },
    {
        type = "item",
        name = "bnl-antenna-part",
        icon = icons .. "antenna-part.png",
        icon_size = 64,
        subgroup = "bnl-start",
        order = "b[antenna-part]",
        stack_size = 10,
        auto_recycle = false,
        inventory_move_sound = item_sounds.metal_small_inventory_move,
        pick_sound = item_sounds.metal_small_inventory_pickup,
        drop_sound = item_sounds.metal_small_inventory_move,
    },
    {
        type = "item",
        name = "bnl-distress-beacon",
        icon = icons .. "distress-beacon.png",
        icon_size = 64,
        subgroup = "bnl-start",
        order = "c[distress-beacon]",
        place_result = "bnl-distress-beacon",
        stack_size = 1,
    },
    {
        type = "capsule",
        name = "bnl-engineer-note",
        icon = icons .. "engineer-note.png",
        icon_size = 64,
        subgroup = "bnl-start",
        order = "d[engineer-note]",
        stack_size = 1,
        auto_recycle = false,
        capsule_action = read_action,
    },
    {
        -- BnL advertising: useless to read, burns well.
        type = "item",
        name = "bnl-advertising-flyer",
        icon = icons .. "advertising-flyer.png",
        icon_size = 64,
        -- four flyers (sale, Axiom cruise, Life & Crash insurance, a burnt one) on the ground and belts
        pictures = {
            {filename = icons .. "advertising-flyer-1.png", size = 64, scale = 0.5},
            {filename = icons .. "advertising-flyer-2.png", size = 64, scale = 0.5},
            {filename = icons .. "advertising-flyer-3.png", size = 64, scale = 0.5},
            {filename = icons .. "advertising-flyer-4.png", size = 64, scale = 0.5},
        },
        subgroup = "bnl-start",
        order = "e[advertising-flyer]",
        stack_size = 200,
        fuel_category = "chemical",
        fuel_value = "300kJ",
        auto_recycle = false,
    },
    {
        type = "recipe",
        name = "bnl-distress-beacon",
        enabled = true,
        energy_required = 10,
        ingredients = {
            {type = "item", name = "bnl-antenna-part", amount = 3},
            {type = "item", name = "copper-cable", amount = 20},
            {type = "item", name = data.raw.item["bob-basic-circuit-board"] and "bob-basic-circuit-board" or "electronic-circuit", amount = 10},
        },
        results = {{type = "item", name = "bnl-distress-beacon", amount = 1}},
    },
})
