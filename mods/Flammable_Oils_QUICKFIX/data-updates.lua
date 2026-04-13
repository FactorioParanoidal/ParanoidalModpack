require "util"
local fire = util.table.deepcopy(data.raw.fire["fire-flame"])
fire.initial_lifetime = 3000
fire.name="oil-fire-flame"
fire.damage_per_tick = {amount = 1, type = "fire"}
---@diagnostic disable-next-line: assign-type-mismatch
data:extend({fire})

--note: 
--base pipes have 100 hp and 70% fire resist
--undergrounds have 150 hp and 80% fire resist
--as such we need 150 / (1 - 0.8) = 750 fire amage do guarantee destruction



local fuel_values = {
  ["crude-oil"] = "0.4MJ",
  ["light-oil"] = "0.9MJ",
  ["heavy-oil"] = "0.45MJ",
  ["petroleum-gas"] = "0.45MJ",
  ["diesel-fuel"] = "1.1MJ",
  }
local emissions = {
  ["crude-oil"] = 1.4,
  ["light-oil"] = 1.2,
  ["heavy-oil"] = 1.3,
  ["petroleum-gas"] = 1,
  ["diesel-fuel"] = 0.8,
  ["molten-tiberium"] = 2.1,
  ["tiberium-waste"] = 1.2,
  ["tiberium-sludge"] = 1.7,
  ["tiberium-slurry"] = 1.8,
  ["liquid-tiberium"] = 4,
  ["tiberium-slurry-blue"] = 3,
}

for k, fluid in pairs (data.raw.fluid) do
  if not fluid.fuel_value or fluid.fuel_value == "0J" then --All fluids have 0J fuel value by default
    fluid.fuel_value = fuel_values[fluid.name]
end
if not    
      fluid.emissions_multiplier and fluid.emissions_multiplier ~= 1.0 then --All fluids have 1.0 multiplier by default
    fluid.emissions_multiplier = emissions[fluid.name]
  end
end
