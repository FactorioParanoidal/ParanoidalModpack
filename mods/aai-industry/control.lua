local version = 000312 -- 0.3.12

local enable_tech_list = {"burner-mechanics", "basic-logistics", "radar", "electricity", "basic-fluid-handling", "steam-power", "electric-lab", "electric-mining-drill"}


function enable_techs()
  -- enable any recipes that should be unlocked.
  -- mainly required for entity-update-externals as a migration file won't work
  for _, force in pairs(game.forces) do
    for _, tech_name in pairs(enable_tech_list) do
      if force.technologies[tech_name] then
        force.technologies[tech_name].enabled = true
      end
      if tech_name == "fuel-processing" then
        force.technologies[tech_name].enabled = settings.startup["aai-fuel-processor"].value
      end
    end
  end
end

function default_researched_techs()
  if settings.global["start-with-basic-logistics"].value ~= false then
    for _, force in pairs(game.forces) do
      if force.technologies["burner-mechanics"] then
        force.technologies["burner-mechanics"].researched = true
      end
      if force.technologies["basic-logistics"] then
        force.technologies["basic-logistics"].researched = true
      end
    end
  end
end

local function on_configuration_changed(data)
    storage.version = storage.version or 0

    enable_techs()
    default_researched_techs()

    storage.version = version
end
script.on_configuration_changed(on_configuration_changed)

---@param remote_type "created"|"respawn"|"ship"|"debris"
---@params items_map table<string, int>
local function add_items_to_freeplay_remote(remote_type, items_map)
  if not remote.interfaces["freeplay"]["get_"..remote_type.."_items"] then return end
  local items = remote.call("freeplay", "get_"..remote_type.."_items") --[[@as table<string, int>]] 
  for item_name, item_count in pairs(items_map) do
    items[item_name] = items[item_name] or 0
    items[item_name] = items[item_name] + item_count
  end
  remote.call("freeplay", "set_"..remote_type.."_items", items)
end

local function add_starting_items()
  if not remote.interfaces["freeplay"] then return end

  local starting_items_ship = {
    ["burner-assembling-machine"] = 1,
    ["burner-mining-drill"] = 3,
  }
  local starting_items_debris = {
    ["transport-belt"] = 84,
    ["motor"] = 24,
  }
  -- Vanilla starting items: (from freeplay.lua)
  --[[
    created_items = {
      ["iron-plate"] = 8,
      ["wood"] = 1,
      ["pistol"] = 1,
      ["firearm-magazine"] = 10,
      ["burner-mining-drill"] = 1,
      ["stone-furnace"] = 1
    }
    ship_items = {
      ["firearm-magazine"] = 8
    }
    debris_items = {
      ["iron-plate"] = 8
    }
  ]]--

  -- Note the freeplay script takes from the 1st player's inventory to fill ship_items and debris_items if possible
  -- e.g. in vanilla, 1st player starts with 2 magazines because 8 are put into the ship
  -- Total nb of burner drills will be 3 for solo player, because their starting drill is used for ship_items

  add_items_to_freeplay_remote("ship", starting_items_ship)
  add_items_to_freeplay_remote("debris", starting_items_debris)
end

local function on_init()
  storage.version = version
  storage.tick_tasks = {}
  storage.tick_tasks_next_id = 1

  -- only run at the start
  if game.tick < 2 then
    add_starting_items()
  end

  default_researched_techs()
end
script.on_init(on_init)

function on_force_created(event)
  default_researched_techs()
end
script.on_event(defines.events.on_force_created, on_force_created)

local function on_player_created(event)
    local player = event and game.players[event.player_index]
    if player and player.color.a == 0.5 then
      player.color = {r=math.random()*255, g=math.random()*255, b=math.random()*255, a = 0.6}
    end
end

script.on_event(defines.events.on_player_created, on_player_created)

---@param event EventData.on_tick Event data
function on_tick(event)
  if event.tick == 1 then
    local crashed_ship = game.surfaces.nauvis.find_entities_filtered{name = "crash-site-spaceship"}[1]
    if crashed_ship then
      local inv_size = crashed_ship.prototype.get_inventory_size(defines.inventory.chest)
      local inventory = crashed_ship.get_inventory(defines.inventory.chest)
      if inventory then
        local empty_stacks = inventory.count_empty_stacks()
        local starting_science = settings.global["quick-start-science"].value
        if starting_science > 0 then
          local science_stack_size = prototypes.item["automation-science-pack"].stack_size
          if (starting_science / science_stack_size) > (empty_stacks) then
            crashed_ship.set_inventory_size_override(defines.inventory.chest, (inv_size + (math.ceil(starting_science / science_stack_size) - empty_stacks)))
          end
          inventory.insert{name = "automation-science-pack", count = starting_science}
        end
      end
      --Clear the trees intersecting with the crashed ship
      local trees = game.surfaces.nauvis.find_entities_filtered{area = crashed_ship.bounding_box, type="tree"}
      for _, entity in pairs(trees) do
        entity.destroy()
      end
    end
  end
end
script.on_event(defines.events.on_tick, on_tick)
