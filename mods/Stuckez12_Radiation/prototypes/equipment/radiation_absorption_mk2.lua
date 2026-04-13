data:extend({
  {
        type = "item",
        name = "radiation-absorption-equipment-mk2",
        icon = "__Stuckez12_Radiation__/graphics/icon/absorption-mk2.png",
        icon_size = 128,
        place_as_equipment_result = "radiation-absorption-equipment-mk2",
        subgroup = "equipment",
        order = "b[battery]-d[radiation-absorption-equipment-mk2]",
        stack_size = 8,
        hidden = true
    },
    {
        type = "battery-equipment",
        name = "radiation-absorption-equipment-mk2",
        sprite = {
            filename = "__Stuckez12_Radiation__/graphics/icon/absorption-mk2.png",
            width = 128,
            height = 128,
            priority = "medium"
        },
        shape = {
            width = 1,
            height = 1,
            type = "full"
        },
        energy_source = {
            type = "electric",
            buffer_capacity = "1kJ",
            input_flow_limit = "1kW",
            usage_priority = "primary-input"
        },
        categories = {"armor"}
    },
    {
        type = "recipe",
        name = "radiation-absorption-mk2-recipe",
        enabled = false,
        energy_required = 20,
        ingredients = {
            {type = "item", name = "radiation-absorption-equipment", amount = 2},
            {type = "item", name = "efficiency-module-2", amount = 4},
            {type = "item", name = "steel-plate", amount = 80},
            {type = "item", name = "copper-plate", amount = 30},
        },
        results = {
            { type = "item", name = "radiation-absorption-equipment-mk2", amount = 1 }
        }
    }
})
