local TECHPATH = "__Aircraft-space-age__/graphics/technology/"
flib_data_util=require("__flib__.data-util")
--Only runs if Space Age is active
if mods["space-age"] and settings.startup["carbon-fiber-aircraft"].value==true then
  --local drag= {"450kW", "650kW", "2000kW", "850kW" }
  --local consumption= {"450kW", "1250kW", "850kW", "1850kW" }
  for i,entity in ipairs(Aircraft_List) do
    local new_plane = table.deepcopy(data.raw["car"][entity])
    local old_name = new_plane.name
    new_plane.name = new_plane.name .. "-carbon-fiber"
    new_plane.icon = "__Aircraft-space-age__/graphics/icons/" .. old_name .. "_carbon_icon.png"

    local fuel_multiplier = 0.5
    local val,suffix=flib_data_util.get_energy_value(new_plane.consumption)
    new_plane.consumption=val*fuel_multiplier .. suffix
    new_plane.effectivity=new_plane.effectivity/fuel_multiplier
    
    new_plane.weight = new_plane.weight/2
    --new_plane.weight=new_plane.weight/2
    new_plane.max_health = new_plane.max_health/2
    new_plane.minable = {mining_time = 1, result = new_plane.name}
    --new_plane.localised_name = {{"item-name.carbon-fiber"},{"entity-name."..old_name}}
    --new_plane.localised_name = {{"carbon-fiber-aircraft"},{"item-name."..old_name}}
    --data.raw["recipe"][new_plane.name.."-recycling"].localised_name=new_plane.localised_name
    --data.raw["recipe"][""]
    data:extend({new_plane})

    if mods["AircraftRealism"] then 
      local arapi = require("__AircraftRealism__.api")
      local underscored_name = entity:gsub("-","_")
      local spriteNames = {}
      local aircraft_flying = table.deepcopy(data.raw["car"][entity .. "-flying"])
      aircraft_flying.name = entity .. "-carbon-fiber-flying"
      aircraft_flying.weight = new_plane.weight/2
      aircraft_flying.max_health = new_plane.max_health/2
      aircraft_flying.minable = {mining_time = 1, result = new_plane.name}
      data:extend({aircraft_flying})
    for i=0,35 do
        local xPos = i % 6
        local yPos = math.floor(i / 6)

        spriteNames[i + 1] = underscored_name.."-shadow-" .. tostring(i)
        local sprite = {
            type = "sprite",
            name = underscored_name.."-shadow-" .. tostring(i),
            filename = "__Aircraft-space-age__/graphics/entity/" .. underscored_name .. "/hr-" .. underscored_name .. "_spritesheet-shadow.png",
            width = 448,
            height = 448,
            x = xPos * 448,
            y = yPos * 448,
            shift = util.by_pixel(0, 0),
            scale = 0.5,
        }
      end
        arapi.register_plane({
          grounded_name = new_plane.name,
          airborne_name = aircraft_flying.name,
          transition_speed_setting="transition-speed-" .. data.raw["car"][new_plane.name].name,
          shadow_sprite = spriteNames,
          --shadow_offset={4,4},
          shadow_end_speed = settings.startup["shadow-end-animation-speed-".. data.raw["car"][entity].name].value/216
        })
    end
    


  end
  for i,entity in ipairs(Aircraft_List) do
   
    local new_item = table.deepcopy(data.raw["item-with-entity-data"][entity])
    new_item.icon = "__Aircraft-space-age__/graphics/icons/" .. new_item.name .. "_carbon_icon.png"
    new_item.name = new_item.name .. "-carbon-fiber"
    
    new_item.place_result = new_item.name
    data:extend({new_item})
  end
  for i,entity in ipairs(Aircraft_List) do
   
    local new_recipe = table.deepcopy(data.raw["recipe"][entity])
    new_recipe.icon = "__Aircraft-space-age__/graphics/icons/" .. new_recipe.name .. "_carbon_icon.png"
    new_recipe.name = new_recipe.name .. "-carbon-fiber"
    --new_recipe.enabled = true --For testing purposes
    new_recipe.results = {{type = "item", name = new_recipe.name, amount = 1}}
    data:extend({new_recipe})
  end

  data.raw["recipe"]["cargo-plane-carbon-fiber"].ingredients = {
    {type = "item", name = "electric-engine-unit", amount = 128},
    {type = "item", name = "carbon-fiber", amount = 400},
    {type = "item", name = "iron-plate", amount = 500},
    {type = "item", name = "advanced-circuit", amount = 20},
    {type = "item", name = "submachine-gun", amount = 1},
  }
  data.raw["recipe"]["gunship-carbon-fiber"].ingredients = {
    {type = "item", name = "electric-engine-unit", amount = 64},
    {type = "item", name = "carbon-fiber", amount = 200},
    {type = "item", name = "iron-plate", amount = 400},
    {type = "item", name = "electronic-circuit", amount = 40},
    {type = "item", name = "submachine-gun", amount = 5},
    {type = "item", name = "rocket-launcher", amount = 5}
  }
  data.raw["recipe"]["jet-carbon-fiber"].ingredients = {
    {type = "item", name = "electric-engine-unit", amount = 256},
    {type = "item", name = "electronic-circuit", amount = 120},
    {type = "item", name = "advanced-circuit", amount = 50},
    {type = "item", name = "carbon-fiber", amount = 200},
    {type = "item", name = "submachine-gun", amount = 3},
    {type = "item", name = "rocket-launcher", amount = 3},
  }
  data.raw["recipe"]["flying-fortress-carbon-fiber"].ingredients = {
    {type = "item", name = "electric-engine-unit", amount = 100},
    {type = "item", name = "steel-plate", amount = 1000},
    {type = "item", name = "carbon-fiber", amount = 1000},
    --{type = "item", name = "advanced-circuit", amount = 80},
    {type = "item", name = "processing-unit", amount = 120},
    {type = "item", name = "submachine-gun", amount = 15},
    {type = "item", name = "rocket-launcher", amount = 15},
  }
  Aircraft_Tech_List = {"cargo-planes", "jets", "gunships", "flying-fortress"}
  for i,aircraft in ipairs(Aircraft_Tech_List) do
    
    local aircraft_tech
    print(aircraft)
    -- if aircraft == "cargo-plane" then
    --   aircraft_tech="cargo-planes"
    -- elseif aircraft == "jet" then
    --   aircraft_tech="jets"
    -- else
     
    -- end
    aircraft_tech = aircraft
    local tech = table.deepcopy(data.raw["technology"][aircraft_tech])
    tech.icon = TECHPATH .. tech.name .. "-carbon.png"
    tech.name = tech.name .. "-carbon-fiber"
    tech.unit.count = tech.unit.count * 2
    table.insert(tech.unit.ingredients,{"agricultural-science-pack", 1})
    if aircraft ~= "flying-fortress" then 
      table.insert(tech.unit.ingredients,{"space-science-pack", 1})
    end
    tech.prerequisites = {aircraft_tech, "carbon-fiber"}

    tech.effects = {
      {
        type = "unlock-recipe",
        recipe = tech.effects[1].recipe .. "-carbon-fiber"
      }
    }
    data:extend({tech})
  end
end