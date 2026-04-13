data:extend({
  { -- Gunship
    type = "recipe",
    name = "gunship",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {type = "item", name = "electric-engine-unit", amount = 64},
      {type = "item", name = "steel-plate", amount = 200},
      {type = "item", name = "iron-plate", amount = 400},
      {type = "item", name = "electronic-circuit", amount = 40},
      {type = "item", name = "submachine-gun", amount = 5},
      {type = "item", name = "rocket-launcher", amount = 5},
    },
    results = {{type = "item", name = "gunship", amount = 1}},
  },

  { -- Cargo Plane
    type = "recipe",
    name = "cargo-plane",
    enabled = false,
    energy_required = 5,
    ingredients = {
      {type = "item", name = "electric-engine-unit", amount = 128},
      {type = "item", name = "steel-plate", amount = 400},
      {type = "item", name = "iron-plate", amount = 500},
      {type = "item", name = "advanced-circuit", amount = 20},
      {type = "item", name = "submachine-gun", amount = 1},
    },
    results = {{type = "item", name = "cargo-plane", amount = 1}},
  },

  { -- Jet
    type = "recipe",
    name = "jet",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {type = "item", name = "electric-engine-unit", amount = 256},
      {type = "item", name = "electronic-circuit", amount = 120},
      {type = "item", name = "advanced-circuit", amount = 50},
      {type = "item", name = "low-density-structure", amount = 200},
      {type = "item", name = "submachine-gun", amount = 3},
      {type = "item", name = "rocket-launcher", amount = 3},
    },
    results = {{type = "item", name = "jet", amount = 1}},
  },

  { -- Flying Fortress
    type = "recipe",
    name = "flying-fortress",
    enabled = false,
    energy_required = 20,
    ingredients = {
      {type = "item", name = "electric-engine-unit", amount = 100},
      {type = "item", name = "steel-plate", amount = 2000},
      {type = "item", name = "advanced-circuit", amount = 80},
      {type = "item", name = "processing-unit", amount = 40},
      {type = "item", name = "submachine-gun", amount = 15},
      {type = "item", name = "rocket-launcher", amount = 15},
    },
    results = {{type = "item", name = "flying-fortress", amount = 1}},
  },

  { -- High explosive cannon shell
    type = "recipe",
    name = "high-explosive-cannon-shell",
    enabled = false,
    icon = "__Aircraft-space-age__/graphics/icons/high_explosive_shell_icon.png",
    icon_size = 64,
    
    energy_required = 10,
    ingredients = {
      {type = "item", name = "explosive-cannon-shell", amount = 3},
      {type = "item", name = "explosives", amount = 1},
    },
    results = {{type = "item", name = "high-explosive-cannon-shell", amount = 1}},
  },

  { -- Napalm
    type = "recipe",
    name = "napalm",
    enabled = false,
    icon = "__Aircraft-space-age__/graphics/icons/napalm-ammo.png",
    icon_size = 64,
    
    energy_required = 1,
    ingredients = {
      {type = "item", name = "flamethrower-ammo", amount = 4},
      {type = "item", name = "iron-plate", amount = 10},
    },
    results = {{type = "item", name = "napalm", amount = 1}},
  },

  { -- Aircraft afterburner
    type = "recipe",
    name = "aircraft-afterburner",
    enabled = false,
    icon = "__Aircraft-space-age__/graphics/icons/aircraft_afterburner_icon.png",
    icon_size = 64,
    category = "crafting-with-fluid",
    
    energy_required = 3,
    ingredients = {
      {type = "item", name = "electric-engine-unit", amount = 10},
      {type = "fluid", name = "lubricant", amount = 5},
      {type = "item", name = "solid-fuel", amount = 5},
    },
    results = {{type = "item", name = "aircraft-afterburner", amount = 1}},
  },

  { -- Aircraft energy shield
    type = "recipe",
    name = "aircraft-energy-shield",
    enabled = false,
    icon = "__Aircraft-space-age__/graphics/icons/aircraft_energy_shield_icon.png",
    icon_size = 64,
    
    energy_required = 5,
    ingredients = {
      {type = "item", name = "energy-shield-mk2-equipment", amount = 2},
      {type = "item", name = "battery", amount = 20},
    },
    results = {{type = "item", name = "aircraft-energy-shield", amount = 1}},
  },
})

if mods["space-age"] then
  --table.insert(data.raw["recipe"]["aircraft-afterburner"].ingredients,{type = "item", name = "carbon-fiber", amount = 10})

  -- if settings.startup["carbon-fiber-aircraft"]==false then
  --   data.raw["recipe"]["jet"].ingredients = {
  --     {type = "item", name = "electric-engine-unit", amount = 256},
  --     {type = "item", name = "electronic-circuit", amount = 120},
  --     {type = "item", name = "advanced-circuit", amount = 50},
  --     {type = "item", name = "carbon-fiber", amount = 100},
  --     {type = "item", name = "submachine-gun", amount = 3},
  --     {type = "item", name = "rocket-launcher", amount = 3},
  --   }
  --   data.raw["recipe"]["flying-fortress"].ingredients = {
  --     {type = "item", name = "electric-engine-unit", amount = 100},
  --     {type = "item", name = "steel-plate", amount = 1000},
  --     {type = "item", name = "carbon-fiber", amount = 1000},
  --     --{type = "item", name = "advanced-circuit", amount = 80},
  --     {type = "item", name = "processing-unit", amount = 120},
  --     {type = "item", name = "submachine-gun", amount = 15},
  --     {type = "item", name = "rocket-launcher", amount = 15},
  --   }
  -- end

end
