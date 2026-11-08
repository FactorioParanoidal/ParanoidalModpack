if mods["minimalist-rails"] then

  if data.raw["recipe"]["rail-minimal"] then
    data.raw["recipe"]["rail-minimal"].ingredients = {
      {type = "item", name = "silicon-carbide", amount = 1},
      {type = "item", name = "neodymium", amount = 1},
    }
  end

  if data.raw["rail-planner"]["rail-minimal"] then
    data.raw["rail-planner"]["rail-minimal"].default_import_location = "moshine"
  end

  if data.raw["rail-planner"]["rail-ramp-minimal"] then
    data.raw["rail-planner"]["rail-ramp-minimal"].default_import_location = "moshine"
  end


  if data.raw["technology"]["minimalist-rails"] then
    table.insert(data.raw["technology"]["minimalist-rails"].prerequisites, "moshine-tech-silicon-carbide")
    table.insert(data.raw["technology"]["minimalist-rails"].unit.ingredients, {"utility-science-pack", 1})
    table.insert(data.raw["technology"]["minimalist-rails"].unit.ingredients, {"space-science-pack", 1})
  end

  if data.raw["technology"]["minimalist-elevated-rails"] then
    table.insert(data.raw["technology"]["minimalist-elevated-rails"].unit.ingredients, {"utility-science-pack", 1})
    table.insert(data.raw["technology"]["minimalist-elevated-rails"].unit.ingredients, {"space-science-pack", 1})
  end
end

if mods["Glass"] then
  if data.raw["recipe"]["glass-plate"] then
    data.raw["recipe"]["glass-plate"].categories = {"crafting"}
  end
end




--[[
if mods["se-space-trains"] then
  if data.raw.item["space-train-battery-charging-station"] then data.raw.item["space-train-battery-charging-station"].default_import_location = "moshine" end
  if data.raw.item["space-train-battery-pack"] then data.raw.item["space-train-battery-pack"].default_import_location = "moshine" end
  if data.raw.item["space-train-discharged-battery-pack"] then data.raw.item["space-train-discharged-battery-pack"].default_import_location = "moshine" end
end
]]

if mods["quality-seeds"] then
  if quality_seeds and quality_seeds.ignore_plants then
    table.insert(quality_seeds.ignore_plants, "processing-grid-process-equation")
  end
end


-- is there a need for new ores?
local mods_with_new_ores = {"bzlead", "bztin", "bztitanium", "bzcarbon"}
local new_ores_needed = false

for _, mod_name in pairs(mods_with_new_ores) do
  if mods[mod_name] then
    new_ores_needed = true
    break
  end
end

if new_ores_needed then
  function add_ore_to_mix(new_ore, new_amount, new_probability)
    local multi_ore = data.raw.resource["multi-ore"]
    local already_has = false
    for index,result in pairs(multi_ore.minable.results) do
      if result.name == new_ore then
        already_has = true
      end
      break
    end
    if already_has == false then
      local new_result = {
        type = "item",
        name = new_ore,
        amount = new_amount,
        independent_probability = new_probability,
      }
      table.insert(multi_ore.minable.results, new_result)
    end   
  end
end


if mods["bzlead"] then
  add_ore_to_mix("lead-ore", 1, 2 /100)
  
  -- reduce copper ore output (because it is also a byproduct from lead and for overal balance)
--  local multi_ore = data.raw.resource["multi-ore"]
--  for index,result in pairs(multi_ore.minable.results) do
--    if result.name == "copper-ore" then
--      result.probability = result.probability / 4   
--      break
--    end
--  end 
end

if mods["bztin"] then
  add_ore_to_mix("tin-ore", 1, 3 /100)  
end

if mods["bztitanium"] then
  -- add stone because titanium can be obtained from it
  add_ore_to_mix("stone", 1, 17 /100)
end

if mods["bzcarbon"] then
  add_ore_to_mix("rough-diamond", 1, 8 /1000)
end


--if settings.startup["moshine-long_stack_inserter"].value then
if mods["long_stack_inserter"] then
  if data.raw.technology["long-stack-inserter"] then
  
    table.insert(data.raw.technology["long-stack-inserter"].prerequisites, "moshine-tech-processing-grid")
    data.raw.technology["long-stack-inserter"].unit =
      {
        count = 10,
        ingredients =
        {
          {"datacell-raw-data", 1},
          {"datacell-solved-equation", 1},
        },
        time = 2000
      }
  end
--[[else
  if data.raw.technology["long-stack-inserter"] then data.raw.technology["long-stack-inserter"].enabled = false end
  if data.raw["inserter"]["long-stack-inserter"] then data.raw["inserter"]["long-stack-inserter"].hidden = true end
  if data.raw.recipe["long-stack-inserter"] then data.raw.recipe["long-stack-inserter"].hidden = true end
  if data.raw.item["long-stack-inserter"] then data.raw.item["long-stack-inserter"].hidden = true end
  ]]
end

if mods["canal-excavator"] then
  data:extend({{
    type = "mod-data",
    name = "canex-moshine-config",
    data_type = "canex-surface-config",
    data = {
      surfaceName = "moshine",
      localisation = {"space-location-name.moshine"},
      oreStartingAmount = 50,
      mining_time = 0.5,
      tint = {r = 183, g = 163, b = 135},
      mineResult = "sand"
    }
  }})
end