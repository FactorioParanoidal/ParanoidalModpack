data:extend({
  {
        type = "item",
        name = "radiation-absorption-equipment-mk3",
        icon = "__Stuckez12_Radiation__/graphics/icon/absorption-mk3.png",
        icon_size = 128,
        place_as_equipment_result = "radiation-absorption-equipment-mk3",
        subgroup = "equipment",
        order = "b[battery]-e[radiation-absorption-equipment-mk3]",
        stack_size = 8,
        hidden = true
    },
    {
        type = "battery-equipment",
        name = "radiation-absorption-equipment-mk3",
        sprite = {
            filename = "__Stuckez12_Radiation__/graphics/icon/absorption-mk3.png",
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
        name = "radiation-absorption-mk3-recipe",
        enabled = false,
        energy_required = 60,
        ingredients = {
            {type = "item", name = "radiation-absorption-equipment-mk2", amount = 4},
            {type = "item", name = "efficiency-module-3", amount = 4},
            {type = "item", name = "steel-plate", amount = 200},
            {type = "item", name = "copper-plate", amount = 60},
        },
        results = {
            { type = "item", name = "radiation-absorption-equipment-mk3", amount = 1 }
        }
    }
})
