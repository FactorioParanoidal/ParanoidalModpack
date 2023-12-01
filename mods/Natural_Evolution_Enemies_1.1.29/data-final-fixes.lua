local NEE = require('common')('Natural_Evolution_Enemies')

if not NE_Enemies then
    NE_Enemies = {}
end
if not NE_Enemies.Settings then
    NE_Enemies.Settings = {}
end

NE_Enemies.Settings.NE_Adjust_Vanilla_Worms = settings.startup["NE_Adjust_Vanilla_Worms"].value
NE_Enemies.Settings.NE_Alien_Artifact_Eggs = settings.startup["NE_Alien_Artifact_Eggs"].value
NE_Enemies.Settings.NE_Blood_Removal = settings.startup["NE_Blood_Removal"].value



--- Update Vanilla Worm Stuff -- Medium worm will become fire worm and big worm will be come unit launcher worm
require("prototypes.NE_Units.Worm_Changes")
require("prototypes.NE_Units.Update_Immunities")


if mods["aai-programmable-vehicles"] then

  require("prototypes.Compatibility.aai_programmable_vehicles")
 
end

--[[
--- Force Larve worm turret range to be 20.
if data.raw.turret["ne-base-larva-worm"] and  data.raw.turret["ne-base-larva-worm"].attack_parameters.range > 18 then

  data.raw.turret["ne-base-larva-worm"].attack_parameters.range = 18

end

]]
local worm_name = {'ne-base-larva-worm','ne-larva-worm-1','ne-larva-worm-2'}


for _, name in pairs(worm_name) do


  --- Force Larve worm turret range to be 20.
  if data.raw.turret[name] and  data.raw.turret[name].attack_parameters.range > 18 then
  
    data.raw.turret[name].attack_parameters.range = 18
  
  end
  

end


--- If Space Exploration Mod is installed.
if mods["space-exploration"] and settings.startup["NE_Alien_Artifacts"].value == true then
    -- Space Exploration Mod likes Stack Sizes to be 200 max.
    -- Changed in 1.1.11

    local function set_item_stack_size(name, size)
        local item = data.raw.item[name]
        if item and item.stack_size then
            item.stack_size = size
        end
    end

    set_item_stack_size("small-alien-artifact", 200)
    set_item_stack_size("alien-artifact", 200)

end


if NE_Enemies.Settings.NE_Blood_Removal then

    local explosions = data.raw["explosion"]

    for k,v in pairs(explosions) do
        if string.find(k, "blood") then
            v["created_effect"] = nil
        end
    end
end


---- Game Tweaks ---- Player (Changed for 0.18.34/1.1.4!)
if NE_Enemies.Settings.NE_Alien_Artifact_Eggs then
    -- There may be more than one character in the game! Here's a list of
    -- the character prototype names or patterns matching character prototype
    -- names we want to ignore.
    local blacklist = {
      ------------------------------------------------------------------------------------
      --                                  Known dummies                                 --
      ------------------------------------------------------------------------------------
      -- Autodrive
      "autodrive-passenger",
      -- AAI Programmable Vehicles
      "^.+%-_%-driver$",
      -- Minime
      "minime_character_dummy",
      -- Water Turret (currently the dummies are not characters -- but things may change!)
      "^WT%-.+%-dummy$",
      ------------------------------------------------------------------------------------
      --                                Other characters                                --
      ------------------------------------------------------------------------------------
      -- Bob's Classes and Multiple characters mod
      "^.*bob%-character%-.+$",
    }
  
    local whitelist = {
      -- Default character
      "^character$",
      -- Characters compatible with Minime
      "^.*skin.*$",
    }
  
    local tweaks = {
      loot_pickup_distance        = 5,    -- default 2
    }
  
    local found, ignore
    for char_name, character in pairs(data.raw.character) do
      --~  NEE.show("Checking character", char_name)
      found = false
  
      for w, w_pattern in ipairs(whitelist) do
  --~ NEE.show("w_pattern", w_pattern)
        if char_name == w_pattern or char_name:match(w_pattern) then
          ignore = false
       --~   NEE.show("Found whitelisted character name", char_name)
          for b, b_pattern in ipairs(blacklist) do
  --~ NEE.show("b_pattern", b_pattern)
  
            if char_name == b_pattern or char_name:match(b_pattern) then
                NEE.writeDebug("%s is on the ignore list!", char_name)
              -- Mark character as found
              ignore = true
              break
            end
          end
          if not ignore then
            found = true
            break
          end
        end
        if found then
          break
        end
      end
  
      -- Apply tweaks
      if found then
        for tweak_name, tweak in pairs(tweaks) do
          if character[tweak_name] < tweak then
            NEE.writeDebug("Changing %s from %s to %s", {tweak_name, character[tweak_name], tweak})
            character[tweak_name] = tweak
          end
        end
      end
    end
  end
  