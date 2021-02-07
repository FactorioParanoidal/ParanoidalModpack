local BioInd = require("__" .. script.mod_name .. "__.common")(script.mod_name)
BioInd.writeDebug("Entered control_bio_cannon.lua")

---Bio Cannon Stuff
local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(true)


----- Bio Cannon Stuff
local function Bio_Cannon_Check(Bio_Cannon)
--~ BioInd.writeDebug("Entered function Bio_Cannon_List")

  local Radar = Bio_Cannon and Bio_Cannon.valid and
                  global.bi_bio_cannon_table[Bio_Cannon.unit_number].radar

  if not Bio_Cannon and Bio_Cannon.valid and Radar and Radar.valid then
    error(string.format("Invalid Bio cannon parts!\nCannon: %s\tRadar: %s", Bio_Cannon, Radar))
  end

  local inventory = Bio_Cannon.get_inventory(1)
  local inventoryContent = inventory.get_contents()
  local AmmoType
  local ammo = 0
  local spawner
  local worms
  local target
  local delay


  for n, a in pairs(inventoryContent or {}) do
    AmmoType = n
    ammo = a
  end

  if ammo > 0 and Radar.energy > 0 then

    local radius = 90 -- Radius it looks for a Spawner / Worm to fire at
    local pos = Bio_Cannon.position

    local area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}

    --- Look for spawners and worms
    spawner = Bio_Cannon.surface.find_entities_filtered({
      area = area,
      type = "unit-spawner",
      force= "enemy"
    })
    worms = Bio_Cannon.surface.find_entities_filtered({
      area = area,
      type = "turret",
      force= "enemy"
    })

    --BioInd.writeDebug("The Number of Spawners is: %g", {#spawner})
    --BioInd.writeDebug("The Number of Worms is: ", {#worms})
    --Find Spawner Target
    if #spawner > 0 and target == nil then
      for _, enemy in pairs(spawner) do
        local distance = math.sqrt(((Bio_Cannon.position.x - enemy.position.x)^2) + ((Bio_Cannon.position.y - enemy.position.y)^2) )
        --BioInd.writeDebug("The Distance is: %s", {distance})
        if (distance > 20) and (distance <= radius) and target == nil then
          target = enemy
          -- Inserted break -- just target the first enemy found (Pi-C)
          break
        end
      end

    -- First attack the Spawners, then worms.
    elseif #worms > 0 and target == nil then
      for _, enemy in pairs(worms) do
        local distance = math.sqrt(((Bio_Cannon.position.x - enemy.position.x)^2) +((Bio_Cannon.position.y - enemy.position.y)^2) )
        --BioInd.writeDebug("The Distance is: %s", {distance})
        if (distance > 20) and (distance <= radius) and target == nil then
          target = enemy
          -- Inserted break -- just target the first enemy found (Pi-C)
          break
        end
      end
    end

    --Fire at Spawner
    if target then
      Bio_Cannon.surface.create_entity({
        name = AmmoType,
        position = {
          x = Bio_Cannon.position.x - 0.5,
          y = Bio_Cannon.position.y - 4.5
        },
        force = Bio_Cannon.force,
        target = target,
        speed= 0.1
      })
      Bio_Cannon.surface.pollute(Bio_Cannon.position, 100) -- The firing of the Hive Buster will cause Pollution
      Bio_Cannon.surface.set_multi_command{
        command = {
          type = defines.command.attack,
          target = Bio_Cannon,
          distraction = defines.distraction.by_enemy
        },
        unit_count = math.floor(100 * game.forces.enemy.evolution_factor),
        unit_search_distance = 500
      }

      --Reduce Ammo
      if ammo > 0 then
        inventory.remove({name = AmmoType, count = 1})
      end

      --Delay between shots
      local delays = {
        ["bi-bio-cannon-proto-ammo"] = 9,
        ["bi-bio-cannon-basic-ammo"] = 10,
        ["bi-bio-cannon-poison-ammo"] = 15
      }
      global.bi_bio_cannon_table[Bio_Cannon.unit_number].delay = delays[AmmoType] or 20
    end
  end
  --~ BioInd.writeDebug("End of function Bio_Cannon_List")
end



Event.register(defines.events.on_tick, function(event)
  if global.bi_bio_cannon_table ~= nil then
    if global.Bio_Cannon_Counter == 0 or global.Bio_Cannon_Counter == nil then
      global.Bio_Cannon_Counter = 60
      for b, bio_cannon in pairs(global.bi_bio_cannon_table) do
--~ BioInd.writeDebug("Checking cannon %s (%g)", {b, bio_cannon.base.unit_number})

        if bio_cannon.base and bio_cannon.base.valid and
            bio_cannon.radar and bio_cannon.radar.valid then

          bio_cannon.delay = bio_cannon.delay - 1

          if bio_cannon.delay <= 0 then
            Bio_Cannon_Check(bio_cannon.base)
          end
        end
      end
    else
      global.Bio_Cannon_Counter = global.Bio_Cannon_Counter - 1
    end
  end
end)



--------------------------------------------------------------------
