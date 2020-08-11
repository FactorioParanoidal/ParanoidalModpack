local BioInd = require('__Bio_Industries__/common')('Bio_Industries')
------------------------------------------------------------------------------------
-- Remove left over radars and hidden entities left after terraformer (arboretum)
-- has been moved.
------------------------------------------------------------------------------------

-- Function to remove entities
local function remove_entity(surface, data)
  local name = data[1]
  local type = data[2]
  local desc = data[3]
  local name_in_table = data[4] or type -- Needed for "electric-pole", which is stored as "pole" in the table

  local count = 0

  -- Look for entity on surface
  local surface_entities = surface.find_entities_filtered{
    name = name,
    type = type,
  }
  BioInd.writeDebug("Found " .. tostring(#surface_entities) .. " " .. desc .. "s.")

  -- Check against entities in list
  for index, entity in pairs(surface_entities) do
    BioInd.writeDebug(tostring(index) .. ": Looking for " .. desc .. " " .. tostring(entity.unit_number) .. ".")

    local match = false
    for _a, arboretum in pairs(global.Arboretum_Table) do
    --~ BioInd.writeDebug("arboretum: " .. serpent.block(arboretum))
      if entity == arboretum[name_in_table] then
        BioInd.writeDebug("The " .. desc .. " " .. tostring(entity.unit_number) ..
                          " belongs to arboretum/terraformer " .. tostring(_a) .. "!")
        match = true
        break
      end
    end

    -- Remove entity from surface if it has no match in arboretum/terraformer list
    if not match then
      log("Removing " .. desc .. " " .. entity.unit_number .. ".")
      count = count + 1
      entity.destroy()
    end
  end
  log("Removed " .. tostring(count) .. " " .. desc .. "s (terraformer remnants) from " .. surface.name .. ".")
  game.print("[Bio Industries] Removed " .. tostring(count) .. " " .. desc .. "s (terraformer remnants) from " .. surface.name .. ".")
end

-- Clean up global list of arboretums
if global.Arboretum_Table then

  BioInd.writeDebug("Remove invalid arboretums/terraformers from list:")
  local count = 0
  for index, arboretum in pairs(global.Arboretum_Table) do
      local entity = arboretum.inventory

      BioInd.writeDebug("Arboretum " .. tostring(index) .. " is valid: " .. tostring(entity and entity.valid))
      if not entity.valid then
        global.Arboretum_Table[index] = nil
        count = count + 1
        log("Removed arboretum/terraformer " .. tostring(index) .. " from global list.")
      end
  end
  log("Removed " .. tostring(count) .. " non-existing terraformers from global list.")
  game.print("[Bio Industries] Removed " .. tostring(count) .. " non-existing terraformers from global list.")

  ------------------------------------------------------------------------------------
  -- Check for left-over entities from moved/removed arboretums/terraformers
  for index, surface in pairs(game.surfaces) do
    BioInd.writeDebug("Looking for left-over hidden entities from moved/removed terraformers on " ..
                      surface.name .. ".")

    for _, entity in pairs({
      {"bi-arboretum-radar", "radar", "radar"},
      {"bi-hidden-power-pole", "electric-pole", "hidden power pole", "pole"},
      {"bi-bio-farm-light", "lamp", "hidden lamp"}
    }) do

      remove_entity(surface, entity)
    end

  end
  BioInd.writeDebug("Done.")
end
