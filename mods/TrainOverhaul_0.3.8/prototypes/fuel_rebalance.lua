--[[ Copyright (c) 2018 Optera
 * Part of Train Overhaul
 *
 * See LICENSE.md in the project directory for license information.
--]]

-- remove top speed bonus from all fuels so trains stick to their rated speeds
-- for _,item in pairs(data.raw.item) do
  -- if item.fuel_top_speed_multiplier then
    -- item.fuel_top_speed_multiplier = 1
  -- end
-- end

local solid_fuel = data.raw.item["solid-fuel"]
solid_fuel.fuel_acceleration_multiplier = 1.05 --base 1.2
solid_fuel.fuel_top_speed_multiplier = 1 -- base 1.05

local rocket_fuel = data.raw.item["rocket-fuel"]
rocket_fuel.fuel_acceleration_multiplier = 1.2 -- base 1.8
rocket_fuel.fuel_top_speed_multiplier = 1 -- base 1.5

local nuclear_fuel = data.raw.item["nuclear-fuel"]
nuclear_fuel.fuel_category = "nuclear"
nuclear_fuel.burnt_result = "used-up-uranium-fuel-cell"
nuclear_fuel.order = "r[uranium-processing]-aa[uranium-fuel-cell]"
nuclear_fuel.fuel_value = "12GJ"
nuclear_fuel.stack_size = 5
nuclear_fuel.fuel_acceleration_multiplier = 1.2 --base 2.5
nuclear_fuel.fuel_top_speed_multiplier = 1 -- base 1.5
