--[[Speed Modules]]--

data.raw["module"]["speed-module"].stack_size = 100
data.raw["module"]["speed-module"].icon = "__bobmodules__/graphics/icons/speed-module-1.png"
data.raw["module"]["speed-module"].effect = (
{
  speed = {bonus = bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus},
  consumption = {bonus = bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty}
})
data.raw["module"]["speed-module"].subgroup = "speed-module"
data.raw["module"]["speed-module"].order = "m-s-1"

data.raw["module"]["speed-module-2"].stack_size = 100
data.raw["module"]["speed-module-2"].icon = "__bobmodules__/graphics/icons/speed-module-2.png"
data.raw["module"]["speed-module-2"].effect = (
{
  speed = {bonus = 2 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus},
  consumption = {bonus = 2 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty}
})
data.raw["module"]["speed-module-2"].subgroup = "speed-module"
data.raw["module"]["speed-module-2"].order = "m-s-2"

data.raw["module"]["speed-module-3"].stack_size = 100
data.raw["module"]["speed-module-3"].icon = "__bobmodules__/graphics/icons/speed-module-3.png"
data.raw["module"]["speed-module-3"].effect = (
{
  speed = {bonus = 3 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus},
  consumption = {bonus = 3 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty}
})
data.raw["module"]["speed-module-3"].subgroup = "speed-module"
data.raw["module"]["speed-module-3"].order = "m-s-3"

data:extend(
{
  {
    type = "module",
    name = "speed-module-4",
    icon = "__bobmodules__/graphics/icons/speed-module-4.png",
    icon_size = 32,
    
    subgroup = "speed-module",
    category = "speed",
    tier = 4,
    order = "m-s-4",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      speed = {bonus = 4 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus},
      consumption = {bonus = 4 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty}
    }
  },

  {
    type = "module",
    name = "speed-module-5",
    icon = "__bobmodules__/graphics/icons/speed-module-5.png",
    icon_size = 32,
    
    subgroup = "speed-module",
    category = "speed",
    tier = 5,
    order = "m-s-5",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      speed = {bonus = 5 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus},
      consumption = {bonus = 5 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty}
    }
  },

  {
    type = "module",
    name = "speed-module-6",
    icon = "__bobmodules__/graphics/icons/speed-module-6.png",
    icon_size = 32,
    
    subgroup = "speed-module",
    category = "speed",
    tier = 6,
    order = "m-s-6",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      speed = {bonus = 6 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus},
      consumption = {bonus = 6 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty}
    }
  },

  {
    type = "module",
    name = "speed-module-7",
    icon = "__bobmodules__/graphics/icons/speed-module-7.png",
    icon_size = 32,
    
    subgroup = "speed-module",
    category = "speed",
    tier = 7,
    order = "m-s-7",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      speed = {bonus = 7 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus},
      consumption = {bonus = 7 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty}
    }
  },

  {
    type = "module",
    name = "speed-module-8",
    icon = "__bobmodules__/graphics/icons/speed-module-8.png",
    icon_size = 32,
    
    subgroup = "speed-module",
    category = "speed",
    tier = 8,
    order = "m-s-8",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      speed = {bonus = 8 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus},
      consumption = {bonus = 8 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty}
    }
  },
}
)


--[[Effectivity Modules]]--

data.raw["module"]["effectivity-module"].stack_size = 100
data.raw["module"]["effectivity-module"].icon = "__bobmodules__/graphics/icons/effectivity-module-1.png"
data.raw["module"]["effectivity-module"].effect = { consumption = {bonus = -1 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}}
data.raw["module"]["effectivity-module"].subgroup = "effectivity-module"
data.raw["module"]["effectivity-module"].order = "m-e-1"

data.raw["module"]["effectivity-module-2"].stack_size = 100
data.raw["module"]["effectivity-module-2"].icon = "__bobmodules__/graphics/icons/effectivity-module-2.png"
data.raw["module"]["effectivity-module-2"].effect = { consumption = {bonus = -2 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}}
data.raw["module"]["effectivity-module-2"].subgroup = "effectivity-module"
data.raw["module"]["effectivity-module-2"].order = "m-e-2"

data.raw["module"]["effectivity-module-3"].stack_size = 100
data.raw["module"]["effectivity-module-3"].icon = "__bobmodules__/graphics/icons/effectivity-module-3.png"
data.raw["module"]["effectivity-module-3"].effect = { consumption = {bonus = -3 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}}
data.raw["module"]["effectivity-module-3"].subgroup = "effectivity-module"
data.raw["module"]["effectivity-module-3"].order = "m-e-3"

data:extend(
{
  {
    type = "module",
    name = "effectivity-module-4",
    icon = "__bobmodules__/graphics/icons/effectivity-module-4.png",
    icon_size = 32,
    
    subgroup = "effectivity-module",
    category = "effectivity",
    tier = 4,
    order = "m-e-4",
    stack_size = 100,
    default_request_amount = 10,
    effect = { consumption = {bonus = -4 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}}
  },

  {
    type = "module",
    name = "effectivity-module-5",
    icon = "__bobmodules__/graphics/icons/effectivity-module-5.png",
    icon_size = 32,
    
    subgroup = "effectivity-module",
    category = "effectivity",
    tier = 5,
    order = "m-e-5",
    stack_size = 100,
    default_request_amount = 10,
    effect = { consumption = {bonus = -5 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}}
  },

  {
    type = "module",
    name = "effectivity-module-6",
    icon = "__bobmodules__/graphics/icons/effectivity-module-6.png",
    icon_size = 32,
    
    subgroup = "effectivity-module",
    category = "effectivity",
    tier = 6,
    order = "m-e-6",
    stack_size = 100,
    default_request_amount = 10,
    effect = { consumption = {bonus = -6 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}}
  },

  {
    type = "module",
    name = "effectivity-module-7",
    icon = "__bobmodules__/graphics/icons/effectivity-module-7.png",
    icon_size = 32,
    
    subgroup = "effectivity-module",
    category = "effectivity",
    tier = 7,
    order = "m-e-7",
    stack_size = 100,
    default_request_amount = 10,
    effect = { consumption = {bonus = -7 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}}
  },

  {
    type = "module",
    name = "effectivity-module-8",
    icon = "__bobmodules__/graphics/icons/effectivity-module-8.png",
    icon_size = 32,
    
    subgroup = "effectivity-module",
    category = "effectivity",
    tier = 8,
    order = "m-e-8",
    stack_size = 100,
    default_request_amount = 10,
    effect = { consumption = {bonus = -8 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}}
  },
}
)


--[[Productivity Modules]]--

data:extend(
{
  {
    type = "module",
    name = "productivity-module",
    icon = "__bobmodules__/graphics/icons/productivity-module-1.png",
    icon_size = 32,
    
    subgroup = "productivity-module",
    category = "productivity",
    tier = 1,
    order = "m-p-1",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      consumption = {bonus = bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty},
      pollution = {bonus = bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "productivity-module-2",
    icon = "__bobmodules__/graphics/icons/productivity-module-2.png",
    icon_size = 32,
    
    subgroup = "productivity-module",
    category = "productivity",
    tier = 2,
    order = "m-p-2",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 2 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      consumption = {bonus = 2 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty},
      pollution = {bonus = 2 * bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "productivity-module-3",
    icon = "__bobmodules__/graphics/icons/productivity-module-3.png",
    icon_size = 32,
    
    subgroup = "productivity-module",
    category = "productivity",
    tier = 3,
    order = "m-p-3",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 3 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      consumption = {bonus = 3 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty},
      pollution = {bonus = 3 * bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "productivity-module-4",
    icon = "__bobmodules__/graphics/icons/productivity-module-4.png",
    icon_size = 32,
    
    subgroup = "productivity-module",
    category = "productivity",
    tier = 4,
    order = "m-p-4",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 4 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      consumption = {bonus = 4 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty},
      pollution = {bonus = 4 * bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "productivity-module-5",
    icon = "__bobmodules__/graphics/icons/productivity-module-5.png",
    icon_size = 32,
    
    subgroup = "productivity-module",
    category = "productivity",
    tier = 5,
    order = "m-p-5",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 5 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      consumption = {bonus = 5 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty},
      pollution = {bonus = 5 * bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "productivity-module-6",
    icon = "__bobmodules__/graphics/icons/productivity-module-6.png",
    icon_size = 32,
    
    subgroup = "productivity-module",
    category = "productivity",
    tier = 6,
    order = "m-p-6",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 6 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      consumption = {bonus = 6 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty},
      pollution = {bonus = 6 * bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "productivity-module-7",
    icon = "__bobmodules__/graphics/icons/productivity-module-7.png",
    icon_size = 32,
    
    subgroup = "productivity-module",
    category = "productivity",
    tier = 7,
    order = "m-p-7",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 7 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      consumption = {bonus = 7 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty},
      pollution = {bonus = 7 * bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "productivity-module-8",
    icon = "__bobmodules__/graphics/icons/productivity-module-8.png",
    icon_size = 32,
    
    subgroup = "productivity-module",
    category = "productivity",
    tier = 8,
    order = "m-p-8",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 8 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      consumption = {bonus = 8 * bobmods.modules.ConsumptionPenaltyPerLevel + bobmods.modules.ConsumptionPenalty},
      pollution = {bonus = 8 * bobmods.modules.PollutionPenaltyPerLevel + bobmods.modules.PollutionPenalty}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },
}
)

if settings.startup["bobmods-modules-productivityhasspeed"].value == true then
  data.raw.module["productivity-module"].effect.speed = {bonus = -1 * bobmods.modules.SpeedPenaltyPerLevel - bobmods.modules.SpeedPenalty}
  data.raw.module["productivity-module-2"].effect.speed = {bonus = -2 * bobmods.modules.SpeedPenaltyPerLevel - bobmods.modules.SpeedPenalty}
  data.raw.module["productivity-module-3"].effect.speed = {bonus = -3 * bobmods.modules.SpeedPenaltyPerLevel - bobmods.modules.SpeedPenalty}
  data.raw.module["productivity-module-4"].effect.speed = {bonus = -4 * bobmods.modules.SpeedPenaltyPerLevel - bobmods.modules.SpeedPenalty}
  data.raw.module["productivity-module-5"].effect.speed = {bonus = -5 * bobmods.modules.SpeedPenaltyPerLevel - bobmods.modules.SpeedPenalty}
  data.raw.module["productivity-module-6"].effect.speed = {bonus = -6 * bobmods.modules.SpeedPenaltyPerLevel - bobmods.modules.SpeedPenalty}
  data.raw.module["productivity-module-7"].effect.speed = {bonus = -7 * bobmods.modules.SpeedPenaltyPerLevel - bobmods.modules.SpeedPenalty}
  data.raw.module["productivity-module-8"].effect.speed = {bonus = -8 * bobmods.modules.SpeedPenaltyPerLevel - bobmods.modules.SpeedPenalty}
end


--[[Pollution Cleaning Modules]]--

data:extend(
{
  {
    type = "module",
    name = "pollution-clean-module-1",
    icon = "__bobmodules__/graphics/icons/pollution-clean-module-1.png",
    icon_size = 32,
    
    subgroup = "pollution-clean-module",
    category = "pollution-clean",
    tier = 1,
    order = "m-p-cl-1",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = -1 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus}}
  },

  {
    type = "module",
    name = "pollution-clean-module-2",
    icon = "__bobmodules__/graphics/icons/pollution-clean-module-2.png",
    icon_size = 32,
    
    subgroup = "pollution-clean-module",
    category = "pollution-clean",
    tier = 2,
    order = "m-p-cl-2",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = -2 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus}}
  },

  {
    type = "module",
    name = "pollution-clean-module-3",
    icon = "__bobmodules__/graphics/icons/pollution-clean-module-3.png",
    icon_size = 32,
    
    subgroup = "pollution-clean-module",
    category = "pollution-clean",
    tier = 3,
    order = "m-p-cl-3",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = -3 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus}}
  },

  {
    type = "module",
    name = "pollution-clean-module-4",
    icon = "__bobmodules__/graphics/icons/pollution-clean-module-4.png",
    icon_size = 32,
    
    subgroup = "pollution-clean-module",
    category = "pollution-clean",
    tier = 4,
    order = "m-p-cl-4",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = -4 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus}}
  },

  {
    type = "module",
    name = "pollution-clean-module-5",
    icon = "__bobmodules__/graphics/icons/pollution-clean-module-5.png",
    icon_size = 32,
    
    subgroup = "pollution-clean-module",
    category = "pollution-clean",
    tier = 5,
    order = "m-p-cl-5",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = -5 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus}}
  },

  {
    type = "module",
    name = "pollution-clean-module-6",
    icon = "__bobmodules__/graphics/icons/pollution-clean-module-6.png",
    icon_size = 32,
    
    subgroup = "pollution-clean-module",
    category = "pollution-clean",
    tier = 6,
    order = "m-p-cl-6",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = -6 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus}}
  },

  {
    type = "module",
    name = "pollution-clean-module-7",
    icon = "__bobmodules__/graphics/icons/pollution-clean-module-7.png",
    icon_size = 32,
    
    subgroup = "pollution-clean-module",
    category = "pollution-clean",
    tier = 7,
    order = "m-p-cl-7",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = -7 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus}}
  },

  {
    type = "module",
    name = "pollution-clean-module-8",
    icon = "__bobmodules__/graphics/icons/pollution-clean-module-8.png",
    icon_size = 32,
    
    subgroup = "pollution-clean-module",
    category = "pollution-clean",
    tier = 8,
    order = "m-p-cl-8",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = -8 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus}}
  },
}
)


--[[Pollution Producing Modules]]--

data:extend(
{
  {
    type = "module",
    name = "pollution-create-module-1",
    icon = "__bobmodules__/graphics/icons/pollution-create-module-1.png",
    icon_size = 32,
    
    subgroup = "pollution-create-module",
    category = "pollution-create",
    tier = 1,
    order = "m-p-cr-1",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = bobmods.modules.PollutionCreatePerLevel + bobmods.modules.PollutionCreateBonus}}
  },

  {
    type = "module",
    name = "pollution-create-module-2",
    icon = "__bobmodules__/graphics/icons/pollution-create-module-2.png",
    icon_size = 32,
    
    subgroup = "pollution-create-module",
    category = "pollution-create",
    tier = 2,
    order = "m-p-cr-2",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = 2 * bobmods.modules.PollutionCreatePerLevel + bobmods.modules.PollutionCreateBonus}}
  },

  {
    type = "module",
    name = "pollution-create-module-3",
    icon = "__bobmodules__/graphics/icons/pollution-create-module-3.png",
    icon_size = 32,
    
    subgroup = "pollution-create-module",
    category = "pollution-create",
    tier = 3,
    order = "m-p-cr-3",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = 3 * bobmods.modules.PollutionCreatePerLevel + bobmods.modules.PollutionCreateBonus}}
  },

  {
    type = "module",
    name = "pollution-create-module-4",
    icon = "__bobmodules__/graphics/icons/pollution-create-module-4.png",
    icon_size = 32,
    
    subgroup = "pollution-create-module",
    category = "pollution-create",
    tier = 4,
    order = "m-p-cr-4",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = 4 * bobmods.modules.PollutionCreatePerLevel + bobmods.modules.PollutionCreateBonus}}
  },

  {
    type = "module",
    name = "pollution-create-module-5",
    icon = "__bobmodules__/graphics/icons/pollution-create-module-5.png",
    icon_size = 32,
    
    subgroup = "pollution-create-module",
    category = "pollution-create",
    tier = 5,
    order = "m-p-cr-5",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = 5 * bobmods.modules.PollutionCreatePerLevel + bobmods.modules.PollutionCreateBonus}}
  },

  {
    type = "module",
    name = "pollution-create-module-6",
    icon = "__bobmodules__/graphics/icons/pollution-create-module-6.png",
    icon_size = 32,
    
    subgroup = "pollution-create-module",
    category = "pollution-create",
    tier = 6,
    order = "m-p-cr-6",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = 6 * bobmods.modules.PollutionCreatePerLevel + bobmods.modules.PollutionCreateBonus}}
  },

  {
    type = "module",
    name = "pollution-create-module-7",
    icon = "__bobmodules__/graphics/icons/pollution-create-module-7.png",
    icon_size = 32,
    
    subgroup = "pollution-create-module",
    category = "pollution-create",
    tier = 7,
    order = "m-p-cr-7",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = 7 * bobmods.modules.PollutionCreatePerLevel + bobmods.modules.PollutionCreateBonus}}
  },

  {
    type = "module",
    name = "pollution-create-module-8",
    icon = "__bobmodules__/graphics/icons/pollution-create-module-8.png",
    icon_size = 32,
    
    subgroup = "pollution-create-module",
    category = "pollution-create",
    tier = 8,
    order = "m-p-cr-8",
    stack_size = 100,
    default_request_amount = 10,
    effect = {pollution = {bonus = 8 * bobmods.modules.PollutionCreatePerLevel + bobmods.modules.PollutionCreateBonus}}
  }
}
)


