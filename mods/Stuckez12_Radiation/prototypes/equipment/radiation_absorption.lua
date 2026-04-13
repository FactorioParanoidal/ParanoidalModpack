data:extend({
  {
        type = "item",
        name = "radiation-absorption-equipment",
        icon = "__Stuckez12_Radiation__/graphics/icon/absorption.png",
        icon_size = 128,
        place_as_equipment_result = "radiation-absorption-equipment",
        subgroup = "equipment",
        order = "b[battery]-c[radiation-absorption-equipment]",
        stack_size = 8,
        hidden = true
    },
    {
        type = "battery-equipment",
        name = "radiation-absorption-equipment",
        sprite = {
            filename = "__Stuckez12_Radiation__/graphics/icon/absorption.png",
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
        name = "radiation-absorption-recipe",
        enabled = false,
        energy_required = 12,
        ingredients = {
            {type = "item", name = "battery", amount = 2},
            {type = "item", name = "steel-plate", amount = 40},
            {type = "item", name = "iron-plate", amount = 20},
            {type = "item", name = "copper-plate", amount = 20},
        },
        results = {
            { type = "item", name = "radiation-absorption-equipment", amount = 1 }
        }
    }
})
