local warheads_added = require("__True-Nukes__.prototypes.nukes.data-nukes-building-warheads")
local test_system = require("nuclear-test-system")
local achievement_system = require("achievement-system")

local function nukeBuildingDetonate(building)
  local result = nil
  for _,w in pairs(warheads_added) do
    if(game.item_prototypes[w.warhead] and building.get_output_inventory().get_item_count("detonation" .. w.name .. w.label) ~= 0) then
      result = w.name
      test_system.testDetonation(building.force, w)
      achievement_system.building_detonated(building, w)
      break
    end
  end
  building.surface.create_entity{name="warhead-util-projectile" .. result, position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force, source=building}
  building.get_output_inventory().clear();
end

local function checkBuildings()
  if(#global.nukeBuildings>0) then
    for i,building in ipairs(global.nukeBuildings) do
      if(building.valid) then
        if(not building.get_output_inventory().is_empty()) then
          nukeBuildingDetonate(building)
        elseif (building.crafting_progress > 0 and building.crafting_progress < 0.01) then
          -- Force map loading when a nuke is set up
          if(string.match(building.get_recipe().name, ".*-atomic-2-stage-100kt")) then
            if (not settings.global["optimise-100kt"].value) then
              building.surface.request_to_generate_chunks(building.position, 1500/32)
            else
              building.surface.request_to_generate_chunks(building.position, 200/32)
            end
          elseif(string.match(building.get_recipe().name, ".*-atomic-15kt") or string.match(building.get_recipe().name, ".*-atomic-2-stage-15kt")) then
            building.surface.request_to_generate_chunks(building.position, 1000/32)
          elseif(string.match(building.get_recipe().name, ".*-atomic-1kt")) then
            building.surface.request_to_generate_chunks(building.position, 800/32)
          elseif(string.match(building.get_recipe().name, ".*-atomic-500t")) then
            building.surface.request_to_generate_chunks(building.position, 400/32)
          else
            building.surface.request_to_generate_chunks(building.position, 100/32)
          end
        end
      else
        table.remove(global.nukeBuildings, i)
      end
    end
  end
end

return {checkBuildings = checkBuildings}
