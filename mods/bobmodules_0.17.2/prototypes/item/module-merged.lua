if settings.startup["bobmods-modules-enablerawspeedmodules"].value == true then
--[[Raw Speed Modules]]--

data:extend(
{
  {
    type = "module",
    name = "raw-speed-module-1",
    icon = "__bobmodules__/graphics/icons/cyan-module-1.png",
    icon_size = 32,
    
    subgroup = "raw-speed-module",
    category = "raw-speed",
    tier = 1,
    order = "m-rs-1",
    stack_size = 100,
    default_request_amount = 10,
    effect = { speed = {bonus = bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}}
  },

  {
    type = "module",
    name = "raw-speed-module-2",
    icon = "__bobmodules__/graphics/icons/cyan-module-2.png",
    icon_size = 32,
    
    subgroup = "raw-speed-module",
    category = "raw-speed",
    tier = 2,
    order = "m-rs-2",
    stack_size = 100,
    default_request_amount = 10,
    effect = { speed = {bonus = 2 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}}
  },

  {
    type = "module",
    name = "raw-speed-module-3",
    icon = "__bobmodules__/graphics/icons/cyan-module-3.png",
    icon_size = 32,
    
    subgroup = "raw-speed-module",
    category = "raw-speed",
    tier = 3,
    order = "m-rs-3",
    stack_size = 100,
    default_request_amount = 10,
    effect = { speed = {bonus = 3 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}}
  },

  {
    type = "module",
    name = "raw-speed-module-4",
    icon = "__bobmodules__/graphics/icons/cyan-module-4.png",
    icon_size = 32,
    
    subgroup = "raw-speed-module",
    category = "raw-speed",
    tier = 4,
    order = "m-rs-4",
    stack_size = 100,
    default_request_amount = 10,
    effect = { speed = {bonus = 4 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}}
  },

  {
    type = "module",
    name = "raw-speed-module-5",
    icon = "__bobmodules__/graphics/icons/cyan-module-5.png",
    icon_size = 32,
    
    subgroup = "raw-speed-module",
    category = "raw-speed",
    tier = 5,
    order = "m-rs-5",
    stack_size = 100,
    default_request_amount = 10,
    effect = { speed = {bonus = 5 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}}
  },

  {
    type = "module",
    name = "raw-speed-module-6",
    icon = "__bobmodules__/graphics/icons/cyan-module-6.png",
    icon_size = 32,
    
    subgroup = "raw-speed-module",
    category = "raw-speed",
    tier = 6,
    order = "m-rs-6",
    stack_size = 100,
    default_request_amount = 10,
    effect = { speed = {bonus = 6 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}}
  },

  {
    type = "module",
    name = "raw-speed-module-7",
    icon = "__bobmodules__/graphics/icons/cyan-module-7.png",
    icon_size = 32,
    
    subgroup = "raw-speed-module",
    category = "raw-speed",
    tier = 7,
    order = "m-rs-7",
    stack_size = 100,
    default_request_amount = 10,
    effect = { speed = {bonus = 7 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}}
  },

  {
    type = "module",
    name = "raw-speed-module-8",
    icon = "__bobmodules__/graphics/icons/cyan-module-8.png",
    icon_size = 32,
    
    subgroup = "raw-speed-module",
    category = "raw-speed",
    tier = 8,
    order = "m-rs-8",
    stack_size = 100,
    default_request_amount = 10,
    effect = { speed = {bonus = 8 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}}
  },
}
)


end

if settings.startup["bobmods-modules-enablegreenmodules"].value == true then

data:extend(
{
  {
    type = "module",
    name = "green-module-1",
    icon = "__bobmodules__/graphics/icons/yellow-module-1.png",
    icon_size = 32,
    
    subgroup = "green-module",
    category = "green",
    tier = 1,
    order = "m-g-1",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      pollution = {bonus = -1 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -1 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}
    }
  },

  {
    type = "module",
    name = "green-module-2",
    icon = "__bobmodules__/graphics/icons/yellow-module-2.png",
    icon_size = 32,
    
    subgroup = "green-module",
    category = "green",
    tier = 2,
    order = "m-g-2",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      pollution = {bonus = -2 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -2 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}
    }
  },

  {
    type = "module",
    name = "green-module-3",
    icon = "__bobmodules__/graphics/icons/yellow-module-3.png",
    icon_size = 32,
    
    subgroup = "green-module",
    category = "green",
    tier = 3,
    order = "m-g-3",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      pollution = {bonus = -3 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -3 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}
    }
  },

  {
    type = "module",
    name = "green-module-4",
    icon = "__bobmodules__/graphics/icons/yellow-module-4.png",
    icon_size = 32,
    
    subgroup = "green-module",
    category = "green",
    tier = 4,
    order = "m-g-4",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      pollution = {bonus = -4 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -4 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}
    }
  },

  {
    type = "module",
    name = "green-module-5",
    icon = "__bobmodules__/graphics/icons/yellow-module-5.png",
    icon_size = 32,
    
    subgroup = "green-module",
    category = "green",
    tier = 5,
    order = "m-g-5",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      pollution = {bonus = -5 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -5 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}
    }
  },

  {
    type = "module",
    name = "green-module-6",
    icon = "__bobmodules__/graphics/icons/yellow-module-6.png",
    icon_size = 32,
    
    subgroup = "green-module",
    category = "green",
    tier = 6,
    order = "m-g-6",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      pollution = {bonus = -6 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -6 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}
    }
  },

  {
    type = "module",
    name = "green-module-7",
    icon = "__bobmodules__/graphics/icons/yellow-module-7.png",
    icon_size = 32,
    
    subgroup = "green-module",
    category = "green",
    tier = 7,
    order = "m-g-7",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      pollution = {bonus = -7 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -7 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}
    }
  },

  {
    type = "module",
    name = "green-module-8",
    icon = "__bobmodules__/graphics/icons/yellow-module-8.png",
    icon_size = 32,
    
    subgroup = "green-module",
    category = "green",
    tier = 8,
    order = "m-g-8",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      pollution = {bonus = -8 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -8 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus}
    }
  },
}
)


end

if settings.startup["bobmods-modules-enablerawproductivitymodules"].value == true then

data:extend(
{
  {
    type = "module",
    name = "raw-productivity-module-1",
    icon = "__bobmodules__/graphics/icons/red-module-1.png",
    icon_size = 32,
    
    subgroup = "raw-productivity-module",
    category = "raw-productivity",
    tier = 1,
    order = "m-rp-1",
    stack_size = 100,
    default_request_amount = 10,
    effect = { productivity = {bonus = bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus}},
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "raw-productivity-module-2",
    icon = "__bobmodules__/graphics/icons/red-module-2.png",
    icon_size = 32,
    
    subgroup = "raw-productivity-module",
    category = "raw-productivity",
    tier = 2,
    order = "m-rp-2",
    stack_size = 100,
    default_request_amount = 10,
    effect = { productivity = {bonus = 2 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus}},
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "raw-productivity-module-3",
    icon = "__bobmodules__/graphics/icons/red-module-3.png",
    icon_size = 32,
    
    subgroup = "raw-productivity-module",
    category = "raw-productivity",
    tier = 3,
    order = "m-rp-3",
    stack_size = 100,
    default_request_amount = 10,
    effect = { productivity = {bonus = 3 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus}},
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "raw-productivity-module-4",
    icon = "__bobmodules__/graphics/icons/red-module-4.png",
    icon_size = 32,
    
    subgroup = "raw-productivity-module",
    category = "raw-productivity",
    tier = 4,
    order = "m-rp-4",
    stack_size = 100,
    default_request_amount = 10,
    effect = { productivity = {bonus = 4 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus}},
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "raw-productivity-module-5",
    icon = "__bobmodules__/graphics/icons/red-module-5.png",
    icon_size = 32,
    
    subgroup = "raw-productivity-module",
    category = "raw-productivity",
    tier = 5,
    order = "m-rp-5",
    stack_size = 100,
    default_request_amount = 10,
    effect = { productivity = {bonus = 5 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus}},
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "raw-productivity-module-6",
    icon = "__bobmodules__/graphics/icons/red-module-6.png",
    icon_size = 32,
    
    subgroup = "raw-productivity-module",
    category = "raw-productivity",
    tier = 6,
    order = "m-rp-6",
    stack_size = 100,
    default_request_amount = 10,
    effect = { productivity = {bonus = 6 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus}},
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "raw-productivity-module-7",
    icon = "__bobmodules__/graphics/icons/red-module-7.png",
    icon_size = 32,
    
    subgroup = "raw-productivity-module",
    category = "raw-productivity",
    tier = 7,
    order = "m-rp-7",
    stack_size = 100,
    default_request_amount = 10,
    effect = { productivity = {bonus = 7 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus}},
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "raw-productivity-module-8",
    icon = "__bobmodules__/graphics/icons/red-module-8.png",
    icon_size = 32,
    
    subgroup = "raw-productivity-module",
    category = "raw-productivity",
    tier = 8,
    order = "m-rp-8",
    stack_size = 100,
    default_request_amount = 10,
    effect = { productivity = {bonus = 8 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus}},
    limitation_message_key = "production-module-usable-only-on-intermediates"
  }
}
)


end

if settings.startup["bobmods-modules-enablegodmodules"].value == true then

data:extend(
{
  {
    type = "module",
    name = "god-module-1",
    icon = "__bobmodules__/graphics/icons/god-module.png",
    icon_size = 32,
    
    subgroup = "god-module",
    category = "god",
    tier = 1,
    order = "m-g-1",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 2 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      pollution = {bonus = -2 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -2 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus},
      speed = {bonus = 2 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "god-module-2",
    icon = "__bobmodules__/graphics/icons/god-module-1.png",
    icon_size = 32,
    
    subgroup = "god-module",
    category = "god",
    tier = 2,
    order = "m-g-2",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 4 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      pollution = {bonus = -4 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -4 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus},
      speed = {bonus = 4 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "god-module-3",
    icon = "__bobmodules__/graphics/icons/god-module-2.png",
    icon_size = 32,
    
    subgroup = "god-module",
    category = "god",
    tier = 3,
    order = "m-g-3",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 6 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      pollution = {bonus = -6 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -6 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus},
      speed = {bonus = 6 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "god-module-4",
    icon = "__bobmodules__/graphics/icons/god-module-3.png",
    icon_size = 32,
    
    subgroup = "god-module",
    category = "god",
    tier = 4,
    order = "m-g-4",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 8 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      pollution = {bonus = -8 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -8 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus},
      speed = {bonus = 8 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },

  {
    type = "module",
    name = "god-module-5",
    icon = "__bobmodules__/graphics/icons/god-module-4.png",
    icon_size = 32,
    
    subgroup = "god-module",
    category = "god",
    tier = 5,
    order = "m-g-5",
    stack_size = 100,
    default_request_amount = 10,
    effect =
    {
      productivity = {bonus = 10 * bobmods.modules.ProductivityPerLevel + bobmods.modules.ProductivityBonus},
      pollution = {bonus = -10 * bobmods.modules.PollutionPerLevel - bobmods.modules.PollutionBonus},
      consumption = {bonus = -10 * bobmods.modules.ConsumptionPerLevel - bobmods.modules.ConsumptionBonus},
      speed = {bonus = 10 * bobmods.modules.SpeedPerLevel + bobmods.modules.SpeedBonus}
    },
    limitation_message_key = "production-module-usable-only-on-intermediates"
  },
}
)


end
