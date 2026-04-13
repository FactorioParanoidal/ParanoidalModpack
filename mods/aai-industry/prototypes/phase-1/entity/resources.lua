local resource_autoplace = require("__core__/lualib/resource-autoplace");

data.raw.resource.stone.autoplace = resource_autoplace.resource_autoplace_settings{
  name = "stone",
  order = "b",
  base_density = 10,
  has_starting_area_placement = true,
  regular_rq_factor_multiplier = 1.1;
  starting_rq_factor_multiplier = 1.5;
}

-- This breaks the early game 1 burner miner to 1 smelter ratio, so it is better to use belts sooner.
data.raw.resource.coal.minable.mining_time = 0.9
data.raw.resource.stone.minable.mining_time = 1
data.raw.resource["copper-ore"].minable.mining_time = 1.1
data.raw.resource["iron-ore"].minable.mining_time = 1.2
-- uranium is 200% already
