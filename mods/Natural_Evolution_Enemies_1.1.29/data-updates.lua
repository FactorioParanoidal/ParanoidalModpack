if not NE_Enemies then
    NE_Enemies = {}
end
if not NE_Enemies.Settings then
    NE_Enemies.Settings = {}
end

NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value
NE_Enemies.Settings.NE_Challenge_Mode = settings.startup["NE_Challenge_Mode"].value
NE_Enemies.Settings.NE_Remove_Blood_Spatter = settings.startup["NE_Remove_Blood_Spatter"].value
NE_Enemies.Settings.NE_Remove_Vanilla_Spawners = settings.startup["NE_Remove_Vanilla_Spawners"].value
NE_Enemies.Settings.NE_Adjust_Vanilla_Worms = settings.startup["NE_Adjust_Vanilla_Worms"].value

local NEE = require('common')('Natural_Evolution_Enemies')

--- Extra Loot - Small Alient Atrifacts
require("prototypes.Extra_Loot.alien-artifact")
require("prototypes.Extra_Loot.item")
require("prototypes.Extra_Loot.recipe")
require("prototypes.Extra_Loot.extra_loot")

---- Tweak Player Stats
if NE_Enemies.Settings.NE_Challenge_Mode then
    ---- Game Tweaks ---- Player (Changed for 0.18.34/1.1.4!)

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
        loot_pickup_distance        = 5,     -- default 2
        running_speed = 0.25,  -- default 0.15
        healing_per_tick = 0.005,  -- -- default 0.01
        }
    
        local found, ignore
        for char_name, character in pairs(data.raw.character) do
            --~NEE.show("Checking character", char_name)
        found = false
    
        for w, w_pattern in ipairs(whitelist) do
    --~ NEE.show("w_pattern", w_pattern)
            if char_name == w_pattern or char_name:match(w_pattern) then
            ignore = false
           --~ NEE.show("Found whitelisted character name", char_name)
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

--- Remove Blood Spatter
if NE_Enemies.Settings.NE_Remove_Blood_Spatter then

    data.raw["explosion"]["blood-explosion-small"].created_effect = nil
    data.raw["explosion"]["blood-explosion-big"].created_effect = nil
    data.raw["explosion"]["blood-explosion-huge"].created_effect = nil

end

--- Remove Vanilla Spawners 
if NE_Enemies.Settings.NE_Remove_Vanilla_Spawners then

    data.raw["unit-spawner"]["biter-spawner"].autoplace = nil
    data.raw["unit-spawner"]["spitter-spawner"].autoplace = nil

end

--- Bob's Enemies - Remove Bob's recipe for artifacts.
if mods["bobenemies"] and settings.startup["NE_Alien_Artifacts"].value and data.raw.item["alien-artifact-from-small"] and
    data.raw.recipe["alien-artifact-from-small"] then

    data.raw.recipe["alien-artifact-from-small"].enabled = false

end

-- Add resistances to entities.
-- Poison
NE_Functions.Add_Damage_Resists("poison", data.raw["wall"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("poison", data.raw["gate"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("poison", data.raw["car"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("poison", data.raw["electric-pole"], 100)
NE_Functions.Add_Damage_Resists("poison", data.raw["turret"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("poison", data.raw["ammo-turret"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("poison", data.raw["electric-turret"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("poison", data.raw["inserter"], (25 / NE_Enemies.Settings.NE_Difficulty))

-- Acid
NE_Functions.Add_Damage_Resists("acid", data.raw["wall"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("acid", data.raw["gate"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("acid", data.raw["car"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("acid", data.raw["electric-pole"], 100)
NE_Functions.Add_Damage_Resists("acid", data.raw["turret"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("acid", data.raw["ammo-turret"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("acid", data.raw["electric-turret"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("acid", data.raw["transport-belt"], (25 / NE_Enemies.Settings.NE_Difficulty))
NE_Functions.Add_Damage_Resists("acid", data.raw["inserter"], (25 / NE_Enemies.Settings.NE_Difficulty))



----------------- Spawner Modifications ---------------------------
-- Biter Spawner Adjustments
if not NE_Enemies.Settings.NE_Remove_Vanilla_Spawners then

    data.raw["unit-spawner"]["biter-spawner"].max_count_of_owned_units = 13 + (2 * NE_Enemies.Settings.NE_Difficulty) -- v 7
    data.raw["unit-spawner"]["biter-spawner"].max_friends_around_to_spawn = 20 + (2 * NE_Enemies.Settings.NE_Difficulty) -- v 5
    data.raw["unit-spawner"]["biter-spawner"].spawning_cooldown =
        {(200 + 100 / NE_Enemies.Settings.NE_Difficulty), (100 + 50 / NE_Enemies.Settings.NE_Difficulty)}
    data.raw["unit-spawner"]["biter-spawner"].max_health = 500 + (500 * NE_Enemies.Settings.NE_Difficulty)
    data.raw["unit-spawner"]["biter-spawner"].resistances = Resistances.Spawner
    data.raw["unit-spawner"]["biter-spawner"].spawning_radius = 20 -- v10
    data.raw["unit-spawner"]["biter-spawner"].spawning_spacing = 2 -- v3
    data.raw["unit-spawner"]["biter-spawner"].healing_per_tick = 0.01 + (0.002 * NE_Enemies.Settings.NE_Difficulty) -- 0.02
    data.raw["unit-spawner"]["biter-spawner"].pollution_absorption_absolute = 15
    data.raw["unit-spawner"]["biter-spawner"].pollution_absorption_proportional = 0.005

    -- Spitter Spawner Adjustments
    data.raw["unit-spawner"]["spitter-spawner"].max_count_of_owned_units = 8 + (2 * NE_Enemies.Settings.NE_Difficulty)
    data.raw["unit-spawner"]["spitter-spawner"].max_friends_around_to_spawn = 13 +
                                                                                  (2 * NE_Enemies.Settings.NE_Difficulty)
    data.raw["unit-spawner"]["spitter-spawner"].spawning_cooldown =
        {(300 + 100 / NE_Enemies.Settings.NE_Difficulty), (100 + 80 / NE_Enemies.Settings.NE_Difficulty)}
    data.raw["unit-spawner"]["spitter-spawner"].max_health = 1000 + (500 * NE_Enemies.Settings.NE_Difficulty)
    data.raw["unit-spawner"]["spitter-spawner"].resistances = Resistances.Spawner
    data.raw["unit-spawner"]["spitter-spawner"].spawning_radius = 20 -- v10
    data.raw["unit-spawner"]["spitter-spawner"].spawning_spacing = 2 -- v3
    data.raw["unit-spawner"]["spitter-spawner"].healing_per_tick = 0.01 + (0.002 * NE_Enemies.Settings.NE_Difficulty) -- 0.02
    data.raw["unit-spawner"]["spitter-spawner"].pollution_absorption_absolute = 15
    data.raw["unit-spawner"]["spitter-spawner"].pollution_absorption_proportional = 0.005

    ------------------ Biter & Spitter Modifications ------------------

    -- Vanilla Biter Unit Adjustments
    data.raw["unit"]["small-biter"].resistances = Resistances.Small_Biter
    data.raw["unit"]["small-biter"].max_health = Health.Small_Biter
    data.raw["unit"]["small-biter"].ammo_type = Damage.Small_Biter
    data.raw["unit"]["medium-biter"].resistances = Resistances.Medium_Biter
    data.raw["unit"]["medium-biter"].max_health = Health.Medium_Biter
    data.raw["unit"]["medium-biter"].ammo_type = Damage.Medium_Biter
    data.raw["unit"]["medium-biter"].pollution_to_join_attack = 800

    data.raw["unit"]["big-biter"].resistances = Resistances.Big_Biter
    data.raw["unit"]["big-biter"].max_health = Health.Big_Biter
    data.raw["unit"]["big-biter"].ammo_type = Damage.Big_Biter
    data.raw["unit"]["big-biter"].pollution_to_join_attack = 2000

    data.raw["unit"]["behemoth-biter"].resistances = Resistances.Behemoth_Biter
    data.raw["unit"]["behemoth-biter"].max_health = Health.Behemoth_Biter
    data.raw["unit"]["behemoth-biter"].ammo_type = Damage.Behemoth_Biter
    data.raw["unit"]["behemoth-biter"].pollution_to_join_attack = 10000

    --- Vanilla Spitter Units Adjustments
    data.raw["unit"]["small-spitter"].resistances = Resistances.Small_Spitter
    data.raw["unit"]["small-spitter"].max_health = Health.Small_Spitter

    data.raw["unit"]["medium-spitter"].resistances = Resistances.Medium_Spitter
    data.raw["unit"]["medium-spitter"].max_health = Health.Medium_Spitter

    data.raw["unit"]["big-spitter"].resistances = Resistances.Big_Spitter
    data.raw["unit"]["big-spitter"].max_health = Health.Big_Spitter
    data.raw["unit"]["big-spitter"].pollution_to_join_attack = 1200

    data.raw["unit"]["behemoth-spitter"].resistances = Resistances.Behemoth_Spitter
    data.raw["unit"]["behemoth-spitter"].max_health = Health.Behemoth_Spitter
    data.raw["unit"]["behemoth-spitter"].pollution_to_join_attack = 8000

end

-- Bob's Enemies Modifications
require("prototypes.Compatibility.Bobs_Changes")

---------------- END Biter & Spitter Modifications --------------------		

--- Adds a Trigger to the Cliff Explosions
if NE_Enemies.Settings.NE_Challenge_Mode == true then

    local proj = data.raw["projectile"]["cliff-explosives"]
    if proj and proj.action then
        local action = proj.action[1].action_delivery.target_effects
        for _, eff in pairs(action) do
            if eff.type == "create-entity" and eff.entity_name == "ground-explosion" then
                eff.trigger_created_entity = true
                break
            end
        end
    end

    local stream = data.raw["stream"]["flamethrower-fire-stream"]
    if stream and stream.action then
        local action = stream.action[1].action_delivery.target_effects
        for _, eff in pairs(action) do
            if eff.type == "create-fire" and eff.entity_name == "fire-flame" then
                eff.trigger_created_entity = true
                break
            end
        end
    end

    local stream2 = data.raw["stream"]["handheld-flamethrower-fire-stream"]
    if stream2 and stream2.action then
        local action = stream2.action[1].action_delivery.target_effects
        for _, eff in pairs(action) do
            if eff.type == "create-fire" and eff.entity_name == "fire-flame" then
                eff.trigger_created_entity = true
                break
            end
        end
    end

end

--- If Space Exploration Mod is installed.
if mods["space-exploration"] and settings.startup["NE_Alien_Artifacts"].value == true then
    -- Space Exploration Mod likes Stack Sizes to be 200 max.
    -- Changed in 1.1.11

    local tweaks = {
        ["small-alien-artifact"] = 200,
        ["alien-artifact"] = 200
    }
    local item

    for tweak_name, tweak in pairs(tweaks) do

          item = data.raw.item[tweak_name]
          if item then
          item.stack_size = 200
          end

    end

end

--- Research-Fix fix for units - Thanks to Quasar_0
for i = 1, 20 do
    local fireSpitter = data.raw["unit"]["ne-spitter-fire-" .. i ]
    fireSpitter.attack_parameters.ammo_category = "ne-flame"
    fireSpitter.attack_parameters.ammo_type.category = "ne-flame"

    local breederSpitter = data.raw["unit"]["ne-spitter-breeder-" .. i ]
    breederSpitter.attack_parameters.ammo_category = "ne-projectile"
    breederSpitter.attack_parameters.ammo_type.category = "ne-projectile"

    local webshooterSpitter = data.raw["unit"]["ne-spitter-webshooter-" .. i ]
    webshooterSpitter.attack_parameters.ammo_category = "ne-projectile"
    webshooterSpitter.attack_parameters.ammo_type.category = "ne-projectile"

    local spitterLandMine = data.raw["land-mine"]["ne-spitter-land-mine-" .. i ]
    spitterLandMine.ammo_category = "ne-land-mine"
  end



---------------------------------------------------------------
