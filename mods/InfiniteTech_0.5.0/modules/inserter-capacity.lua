local name = "inserter-capacity-bonus-8"
local prerequisites = {"inserter-capacity-bonus-7", "space-science-pack"}
local formula = "2^(L-7)*1000"

-- change starting tech for mods
if mods["IndustrialRevolution"] then
  -- for whatever reason deadlock generates hidden levels 4-7
  data.raw["technology"]["inserter-capacity-bonus-4"] = nil
  data.raw["technology"]["inserter-capacity-bonus-5"] = nil
  data.raw["technology"]["inserter-capacity-bonus-6"] = nil
  data.raw["technology"]["inserter-capacity-bonus-7"] = nil
  name = "inserter-capacity-bonus-4"
  prerequisites = {"deadlock-normal-inserter-capacity-bonus-2", "inserter-capacity-bonus-3", "space-science-pack"}
  formula = "2^(L-3)*1000"
end

data:extend
({
  {
    type = "technology",
    name = name,
    icon = "__base__/graphics/technology/inserter-capacity.png",
    icon_size = 128,
    prerequisites = prerequisites,
	effects =
	{
	  {
		type = "inserter-stack-size-bonus",
		modifier = 0.5
	  },
	  {
		type = "stack-inserter-capacity-bonus",
		modifier = 2
	  }
	},
    unit =
    {
      count_formula = formula,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    },
    max_level = "infinite",
    upgrade = true,
    order = "c-k-f-e"
  }
})