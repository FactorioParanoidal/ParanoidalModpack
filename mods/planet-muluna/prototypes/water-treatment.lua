local multiply_energy = require("lib.energy-multiply").multiply_energy
--Forked from Maraxsis to ensure cross-compatibility between both mods' molecule fluids.
if not mods["maraxsis"] then
    Muluna:extend {{
        type = "fluid",
        name = "oxygen",
        icon = "__muluna-graphics__/graphics/icons/oxygen.png",
        localised_name = {"fluid-name.oxygen"},
        --group = "fluids",
        subgroup="fluid",
        icon_size = 64,
        base_flow_rate = data.raw.fluid.steam.base_flow_rate,
        default_temperature = data.raw.fluid["water"].default_temperature,
        heat_capacity = data.raw.fluid["water"].heat_capacity,
        base_color = {0.75, 0.40, 0.40},
        flow_color = {0.80, 0.60, 0.60},
        max_temperature = data.raw.fluid["water"].max_temperature,
        pressure_to_speed_ratio = data.raw.fluid["water"].pressure_to_speed_ratio,
        flow_to_energy_ratio = data.raw.fluid["water"].flow_to_energy_ratio,
        
    }}
    

    -- Muluna:extend {{
    --     type = "fluid",
    --     name = "hydrogen",
    --     icon = "__muluna-graphics__/graphics/icons/hydrogen.png",
    --     --group = "fluids",
    --     subgroup="fluid",
    --     icon_size = 64,
    --     base_flow_rate = data.raw.fluid.steam.base_flow_rate,
    --     default_temperature = data.raw.fluid["water"].default_temperature,
    --     heat_capacity = data.raw.fluid["water"].heat_capacity,
    --     base_color = {0.50, 0.50, 0.50},
    --     flow_color = {1, 1, 1},
    --     max_temperature = data.raw.fluid["water"].max_temperature,
    --     pressure_to_speed_ratio = data.raw.fluid["water"].pressure_to_speed_ratio,
    --     flow_to_energy_ratio = data.raw.fluid["water"].flow_to_energy_ratio,
    --     localised_name={"fluid-name.hydrogen"}
    -- }}


end

--Cross-compatibility also desired with Corrundum.
if data.raw["fluid"]["carbon-dioxide"] == nil then
    Muluna:extend {{
        type = "fluid",
        name = "carbon-dioxide",
        --group = "fluids",
        subgroup="fluid",
        icon_size = 64,
        base_flow_rate = data.raw.fluid.steam.base_flow_rate,
        default_temperature = 21,
        heat_capacity = data.raw.fluid["water"].heat_capacity,
        base_color = {0.75, 0.40, 0.40},
        flow_color = {0.80, 0.60, 0.60},
        min_temperature = 21,
        max_temperature = 3000,
        pressure_to_speed_ratio = data.raw.fluid["water"].pressure_to_speed_ratio,
        flow_to_energy_ratio = data.raw.fluid["water"].flow_to_energy_ratio,
    }}  
end
data.raw["fluid"]["carbon-dioxide"].icon = "__muluna-graphics__/graphics/icons/molecule-carbon-dioxide.png"
if data.raw["fluid"]["carbon-dioxide"].heat_capacity == nil then
    data.raw["fluid"]["carbon-dioxide"].heat_capacity = data.raw.fluid["water"].heat_capacity
end
--data.raw["fluid"]["carbon-dioxide"].heat_capacity=multiply_energy(data.raw["fluid"]["carbon-dioxide"].heat_capacity,1/10)
data.raw["fluid"]["carbon-dioxide"].min_temperature = 21
data.raw["fluid"]["carbon-dioxide"].max_temperature = 3000
data.raw["fluid"]["carbon-dioxide"].auto_barrel = true

-- Muluna:extend {{
--     type = "fluid",
--     name = "helium",
--     icon = "__muluna-graphics__/graphics/icons/molecule-noble-gas.png",
--     --group = "fluids",
--     subgroup="fluid",
--     icon_size = 64,
--     base_flow_rate = data.raw.fluid.steam.base_flow_rate,
--     default_temperature = data.raw.fluid["water"].default_temperature,
--     heat_capacity = data.raw.fluid["water"].heat_capacity,
--     base_color = {0.75, 0.40, 0.40},
--     flow_color = {0.80, 0.60, 0.60},
--     max_temperature = data.raw.fluid["water"].max_temperature,
--     pressure_to_speed_ratio = data.raw.fluid["water"].pressure_to_speed_ratio,
--     flow_to_energy_ratio = data.raw.fluid["water"].flow_to_energy_ratio,
--     localised_name={"fluid-name.helium"}
-- }}

-- Muluna:extend {{
--     type = "fluid",
--     name = "helium-4",
--     icons = {
--         {
--             icon = "__muluna-graphics__/graphics/icons/molecule-noble-gas.png",
--             icon_size = 64,
--             tint = {1,0.8,1}
--         },
        
--     },
--     --group = "fluids",
--     subgroup="fluid",
--     base_flow_rate = data.raw.fluid.steam.base_flow_rate,
--     default_temperature = data.raw.fluid["water"].default_temperature,
--     heat_capacity = data.raw.fluid["water"].heat_capacity,
--     base_color = {0.75, 0.40, 0.40},
--     flow_color = {0.80, 0.60, 0.60},
--     max_temperature = data.raw.fluid["water"].max_temperature,
--     pressure_to_speed_ratio = data.raw.fluid["water"].pressure_to_speed_ratio,
--     flow_to_energy_ratio = data.raw.fluid["water"].flow_to_energy_ratio,
--     localised_name={"fluid-name.helium-n","4"}
-- }}

-- Muluna:extend {{
--     type = "fluid",
--     name = "helium-3",
--     icons = {
--         {
--             icon = "__muluna-graphics__/graphics/icons/molecule-noble-gas.png",
--             icon_size = 64,
--             tint = {1,0.6,1}
--         },
        
--     },
--     --group = "fluids",
--     subgroup="fluid",
--     base_flow_rate = data.raw.fluid.steam.base_flow_rate,
--     default_temperature = data.raw.fluid["water"].default_temperature,
--     heat_capacity = data.raw.fluid["water"].heat_capacity,
--     base_color = {0.75, 0.40, 0.40},
--     flow_color = {0.80, 0.60, 0.60},
--     max_temperature = data.raw.fluid["water"].max_temperature,
--     pressure_to_speed_ratio = data.raw.fluid["water"].pressure_to_speed_ratio,
--     flow_to_energy_ratio = data.raw.fluid["water"].flow_to_energy_ratio,
--     localised_name={"fluid-name.helium-n","3"}
-- }}