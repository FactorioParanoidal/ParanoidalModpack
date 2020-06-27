data:extend(
{
    {
        type = "item",
        name = "solid-sodium-floride",
        icon = "__extendedangels__/graphics/icons/solid-sodium-floride.png",
        icon_size = 32,
        subgroup = "petrochem-sodium",
        order = "j",
        stack_size = 200
      },
      
      {
        type = "fluid",
        name = "gas-argon",
        icon = "__extendedangels__/graphics/icons/gas-argon.png",
        icon_size = 32,
        default_temperature = 100,
        heat_capacity = "0KJ",
        base_color = {r = 0/255, g = 0/255, b = 0/255},
        flow_color = {r = 30/255, g = 143/255, b = 216/255},
        max_temperature = 100,
        pressure_to_speed_ratio = 0.4,
        flow_to_energy_ratio = 0.59,
      },
      
    }
)


if mods["Clowns-Processing"] then 

    data:extend(
        {
            {
                type = "item",
                name = "solid-disodium-phosphate",
                icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
                icon_size = 32,
                subgroup = "petrochem-sodium",
                order = "k",
                stack_size = 200

            },

            {
                type = "item",
                name = "solid-tetrasodium-pyrophosphate",
                icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
                icon_size = 32,
                subgroup = "petrochem-sodium",
                order = "l",
                stack_size = 200
    
            },
        }
    )
end