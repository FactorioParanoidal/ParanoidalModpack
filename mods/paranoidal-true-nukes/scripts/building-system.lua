local warheads_added = require("__paranoidal-true-nukes__.prototypes.nukes.data-nukes-building-warheads")
local test_system = require("nuclear-test-system")
local achievement_system = require("achievement-system")

-- detonation item name -> its entry in warheads_added
local by_detonation = {}
for _,w in pairs(warheads_added) do
  by_detonation["detonation" .. w.name .. w.label] = w
end

local function nukeBuildingDetonate(building)
  local inventory = building.get_output_inventory()
  local found, found_quality = nil, nil
  -- any quality: get_item_count("name") counts normal quality only, so a detonation crafted from a
  -- defective or higher-quality warhead found nothing and "..result" crashed on_tick every tick (9.0.0)
  for _,stack in pairs(inventory.get_contents()) do
    local w = by_detonation[stack.name]
    if w and prototypes.item[w.warhead] then
      found, found_quality = w, stack.quality
      break
    end
  end
  if found then
    test_system.testDetonation(building.force, "detonation" .. found.name .. found.label)
    achievement_system.building_detonated(building, found)
    -- the projectile carries the quality of the detonation (and so of the warhead) to the blast
    building.surface.create_entity{name="warhead-util-projectile" .. found.name, position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force, source=building, quality=found_quality}
  end
  inventory.clear();
end

local function request_chunks(building)
  -- map loading ahead of a set-up detonation (asynchronous; the blast code no longer forces generation)
  local name = building.get_recipe() and building.get_recipe().name or ""
  local r
  if(string.match(name, ".*-atomic-2-stage-100kt")) then
    r = settings.global["optimise-100kt"].value and 200 or 1500
  elseif(string.match(name, ".*-atomic-15kt") or string.match(name, ".*-atomic-2-stage-15kt")) then
    r = 1000
  elseif(string.match(name, ".*-atomic-1kt")) then
    r = 800
  elseif(string.match(name, ".*-atomic-500t")) then
    r = 400
  else
    r = 100
  end
  building.surface.request_to_generate_chunks(building.position, math.ceil(r/32))
end

local function checkBuildings()
  local list = storage.nukeBuildings
  if(#list>0) then
    -- backwards, so table.remove does not skip the next building (ipairs + remove did)
    for i = #list, 1, -1 do
      local building = list[i]
      if(building.valid) then
        if(not building.get_output_inventory().is_empty()) then
          nukeBuildingDetonate(building)
        elseif (building.crafting_progress > 0 and building.crafting_progress < 0.01) then
          request_chunks(building)
        end
      else
        table.remove(list, i)
      end
    end
  end
end

return {checkBuildings = checkBuildings}
