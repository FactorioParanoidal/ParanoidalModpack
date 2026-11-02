local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

data:extend({
  ----- Bio-Mass
  {
    type = "fluid",
    name = "bi-biomass",
    icon = ICONPATH .. "biomass.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "biomass.png",
        icon_size = 64,
      }
    },
    default_temperature = 25,
    max_temperature = 100,
    heat_capacity = "1kJ",
    base_color = {r = 0, g = 0, b = 0},
    flow_color = {r = 0.1, g = 1.0, b = 0.0},
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    subgroup = "bio-bio-fuel-fluid",
    order = "a[fluid]-b[biomass]"
  },
})

-- Factorio 2.1: moved here from data-updates.lua. The recycler generates recycling recipes in its
-- data-updates, before Bio Industries, and requires every fluid ingredient (bi-fertilizer, bi-biomass) to exist.
-- bi_industries_own_air_fluids tells data-updates.lua that Bio Industries made these fluids itself.
if not data.raw.fluid["nitrogen"] and not data.raw.fluid["kr-nitrogen"] then
    bi_industries_own_air_fluids = true
    data:extend({
        {
            type = "fluid",
            name = "nitrogen",
            icon = ICONPATH .. "nitrogen.png",
            icon_size = 64,
            icons = {
                {
                    icon = ICONPATH .. "nitrogen.png",
                    icon_size = 64,
                    icon_mipmaps = 1,
                }
            },
            default_temperature = 25,
            gas_temperature = -210,
            max_temperature = 100,
            heat_capacity = "1kJ",
            base_color = { r = 0.0, g = 0.0, b = 1.0 },
            flow_color = { r = 0.0, g = 0.0, b = 1.0 },
            pressure_to_speed_ratio = 0.4,
            flow_to_energy_ratio = 0.59,
            subgroup = "bio-bio-farm-intermediate-product",
            order = "ab"
        },
    })
    BioInd.writeDebug("Made recipe for \"nitrogen\".")

    if not data.raw.fluid["liquid-air"] then
        data:extend({
            {
                type = "fluid",
                name = "liquid-air",
                icon = ICONPATH .. "liquid-air.png",
                icon_size = 64,
                icons = {
                    {
                        icon = ICONPATH .. "liquid-air.png",
                        icon_size = 64,
                        icon_mipmaps = 1,
                    }
                },
                default_temperature = 25,
                gas_temperature = -100,
                max_temperature = 100,
                heat_capacity = "1kJ",
                base_color = { r = 0, g = 0, b = 0 },
                flow_color = { r = 0.5, g = 1.0, b = 1.0 },
                pressure_to_speed_ratio = 0.4,
                flow_to_energy_ratio = 0.59,
                subgroup = "bio-bio-farm-intermediate-product",
                order = "aa"
            },
        })
        BioInd.writeDebug("Made recipe for \"liquid-air\".")
    end

end
