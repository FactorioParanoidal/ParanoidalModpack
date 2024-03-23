local vanillaBuildings = require("prototypes/buildings/UpdatesVanilla")
local immunityUpdates = require("prototypes/utils/UpdateImmunities")	


-- if settings.startup["rampantFixed--removeBloodParticles"].value then
    -- local explosions = data.raw["explosion"]

    -- for k,v in pairs(explosions) do
        -- if string.find(k, "blood") then
            -- v["created_effect"] = nil
        -- end
    -- end
-- end

--------- assign flying_layer to projectiles
local function table_contains(table, check)
  for k,v in pairs(table) do if v == check then return true end end
  return false
end

if not mods["combat-mechanics-overhaul"] then
	local collision_mask_util_extended = require("collision-mask-util-extended/data/collision-mask-util-extended")		
	flying_layer = collision_mask_util_extended.get_make_named_collision_mask("flying-layer")
	
	for _, prototype in pairs(data.raw.projectile) do	
		if prototype.collision_box then
			if not prototype.hit_collision_mask then
				prototype.hit_collision_mask = collision_mask_util_extended.get_default_hit_mask("projectile")
			else
				if not table_contains(prototype.hit_collision_mask, flying_layer) then
				  table.insert(prototype.hit_collision_mask, flying_layer)
				end		
			end
		end	
	end
else	-- rebuild units (CMO broke stream attacks)
	log("combat-mechanics-overhaul -> rebuild units")
	if settings.startup["rampantFixed--newEnemies"].value then
		local swarmUtils = require("prototypes/SwarmUtils")	
		swarmUtils.processFactions()
	end
end


if settings.startup["rampantFixed--newEnemies"].value then
	if data.raw["damage-type"]["plasma"] then
		immunityUpdates.setPlasmaImmunities()
	end	
	if data.raw["damage-type"]["bob-pierce"] then
		immunityUpdates.setPierceImmunities()
	end	
	immunityUpdates.setArmorLaserElectricImmunities()
	immunityUpdates.setResistanceToUnknownDamageTypes()	
end

if settings.startup["rampantFixed--fireSafety-flamethrower"].value then
    local flamethrowerStream = data.raw["stream"]["handheld-flamethrower-fire-stream"]
	flamethrowerStream.action[1].action_delivery.target_effects[1].sticker = "safe-fire-sticker-rampant"
	local action_delivery = flamethrowerStream.action[1].action_delivery 
	if action_delivery.target_effects[2] and (action_delivery.target_effects[2].type == "damage") and (action_delivery.target_effects[2].damage.type == "fire") then
		action_delivery.target_effects[2].damage.amount = (action_delivery.target_effects[2].damage.amount or 0) + 4
		action_delivery.target_effects[2].apply_damage_to_trees = true
	else	
		action_delivery.target_effects[#action_delivery.target_effects+1] = {
              type = "damage",
              damage = { amount = 6, type = "fire" },
              apply_damage_to_trees = true
	}
	end
	if flamethrowerStream.action[2] then
		table.remove(flamethrowerStream.action, 2)
	end	
	
	-- for i, action in pairs (flamethrowerStream.action)  do
		-- if action.action_delivery and action.action_delivery.target_effects then
			-- for u, target_effect in pairs (action.action_delivery.target_effects) do
				-- if target_effect.entity_name and (target_effect.entity_name == "fire-flame") then
					-- target_effect.type = "damage"
					-- target_effect.damage = { amount = 40, type = "fire" }
					-- target_effect.apply_damage_to_trees = true
					-- target_effect.entity_name = nil	--"safe-fire-flame-rampant"					
				-- end
			-- end
		-- end
	-- end
	
	
    local napalmStream = data.raw["stream"]["napalm-handheld-stream-rampant-arsenal"]
	if napalmStream then
		local flameFound = false
		for i, action in pairs (napalmStream.action)  do
			if action.action_delivery and action.action_delivery.target_effects then
				for u, target_effect in pairs (action.action_delivery.target_effects) do
					if target_effect.entity_name and (target_effect.entity_name == "fire-flame") then
						table.remove(action.action_delivery.target_effects, u)
						flameFound = true
					end	
				end	
			end			
		end
		if flameFound then
			for i, action in pairs (napalmStream.action)  do
				if action.action_delivery and action.action_delivery.target_effects then
					for u, target_effect in pairs (action.action_delivery.target_effects) do
						if (target_effect.type == "damage") and target_effect.damage and (target_effect.damage.type == "fire") then
							target_effect.damage.amount = (target_effect.damage.amount or 0) + 8
							target_effect.apply_damage_to_trees = true
						end
					end
				end			
			end
		end	
		local napalmSticker = data.raw["sticker"]["small-fire-sticker-rampant-arsenal"]
		if napalmSticker and napalmSticker.spread_fire_entity then	
			napalmSticker.spread_fire_entity = "safe-fire-flame-on-tree-rampant"
		end
	end
	
end

if settings.startup["rampantFixed--flamethrowerTurretsRebalance"].value then
    local fireFlameShortLife = table.deepcopy(data.raw["fire"]["fire-flame"])
	fireFlameShortLife.name = "fire-flame-shortlife-rampant"
	fireFlameShortLife.maximum_damage_multiplier = 7
	fireFlameShortLife.damage_multiplier_increase_per_added_fuel = 3
	fireFlameShortLife.damage_multiplier_decrease_per_tick = 0.01
	fireFlameShortLife.lifetime_increase_by = 150
	fireFlameShortLife.maximum_lifetime = 300
	fireFlameShortLife.lifetime_increase_cooldown = 12,
	data:extend({fireFlameShortLife})
		
    local flamethrowerStream2 = table.deepcopy(data.raw["stream"]["flamethrower-fire-stream"])
    local flamethrowerTurret = data.raw["fluid-turret"]["flamethrower-turret"]
	
	flamethrowerStream2.name = "flamethrower-fire-stream2"
	flamethrowerStream2.action[1].action_delivery.target_effects[2].damage.amount = 4
	flamethrowerStream2.action[2].action_delivery.target_effects[1].entity_name = "fire-flame-shortlife-rampant"
	data:extend({flamethrowerStream2})
		
	flamethrowerTurret.attack_parameters.cooldown = 12
	flamethrowerTurret.attack_parameters.fluid_consumption = 0.6
	flamethrowerTurret.attack_parameters.ammo_type.action.action_delivery.stream = "flamethrower-fire-stream2"
	flamethrowerTurret.attack_parameters.gun_barrel_length = 0.6	
	
	---------------
	if data.raw["stream"]["suppression-cannon-stream-rampant-arsenal"] then
		local flamethrowerTurretRA_Stream = data.raw["stream"]["suppression-cannon-stream-rampant-arsenal"]
		table.remove(flamethrowerTurretRA_Stream.action[1].action_delivery.target_effects, 2)
		flamethrowerTurretRA_Stream.action[2].action_delivery.target_effects[2].damage.amount = flamethrowerTurretRA_Stream.action[2].action_delivery.target_effects[2].damage.amount * 4
		
		
		local flamethrowerTurretRA = data.raw["fluid-turret"]["suppression-cannon-fluid-turret-rampant-arsenal"]	
		flamethrowerTurretRA.attack_parameters.cooldown = 30
		flamethrowerTurretRA.attack_parameters.fluid_consumption = 15
		data:extend({flamethrowerTurretRA})
	end	
end
	-- -- debug
	
	
    -- local biterTest = table.deepcopy(data.raw["unit"]["small-biter"])
	-- biterTest.max_health = 100000
	-- biterTest.name = "BiterTest"
	-- data:extend({biterTest})	
	-- ---------------

if settings.startup["rampantFixed--rampantArsenalRebalance"].value then
	local damage_interval = 15
	for i, sticker in pairs(data.raw["sticker"]) do
		if string.find(sticker.name, "arsenal") and string.find(sticker.name, "rampant") then
			if (sticker.duration_in_ticks >= 60) and sticker.damage_per_tick and (sticker.damage_per_tick.amount > 0) and ((not sticker.damage_interval) or (sticker.damage_interval < 10)) then
				local kf = damage_interval/(sticker.damage_interval or 1)
				sticker.damage_interval = damage_interval
				sticker.damage_per_tick.amount = sticker.damage_per_tick.amount * kf
			end
		end	
	end
end

if settings.startup["rampantFixed--unitSpawnerBreath"].value then
    for _, unitSpawner in pairs(data.raw["unit-spawner"]) do
        if (string.find(unitSpawner.name, "hive") or string.find(unitSpawner.name, "biter") or
            string.find(unitSpawner.name, "spitter")) then
            if not unitSpawner.flags then
                unitSpawner.flags = {}
            end
            unitSpawner.flags[#unitSpawner.flags+1] = "breaths-air"
        end
    end
end


for k, unit in pairs(data.raw["unit"]) do
    if (string.find(k, "biter") or string.find(k, "spitter")) and unit.collision_box then
        if settings.startup["rampantFixed--enableSwarm"].value then
            unit.collision_box = {
                {unit.collision_box[1][1] * 0.20, unit.collision_box[1][2] * 0.20},
                {unit.collision_box[2][1] * 0.20, unit.collision_box[2][2] * 0.20}
            }
        end

		-- if string.find(k, "-rampant") and (string.find(k, "nuclear-biter") or string.find(k, "suicide-biter") or string.find(k, "fast-biter")) then
			-- unit.affected_by_tiles = false
		-- else	
			-- unit.affected_by_tiles = settings.startup["rampantFixed--unitsAffectedByTiles"].value
		-- end	

        unit.ai_settings = {
            destroy_when_commands_fail = false,
            allow_try_return_to_spawner = true
        }
    end
end

if settings.startup["rampantFixed--enableShrinkNestsAndWorms"].value then
    for k, unit in pairs(data.raw["unit-spawner"]) do
        if (string.find(k, "biter") or string.find(k, "spitter") or string.find(k, "hive")) and unit.collision_box then
			local minDxDy = math.min(unit.collision_box[2][1] - unit.collision_box[1][1], unit.collision_box[2][2] - unit.collision_box[1][2]) 
			if minDxDy >= 3 then
				unit.collision_box = {
					{unit.collision_box[1][1] * 0.50, unit.collision_box[1][2] * 0.50},
					{unit.collision_box[2][1] * 0.50, unit.collision_box[2][2] * 0.50}
				}
			else
				local k = 1 - (0.5 * minDxDy / 3)
				unit.collision_box = {
					{unit.collision_box[1][1] * k, unit.collision_box[1][2] * k},
					{unit.collision_box[2][1] * k, unit.collision_box[2][2] * k}
				}				
			end
        end
    end

    for k, unit in pairs(data.raw["turret"]) do
        if string.find(k, "worm") and unit.collision_box then
            unit.collision_box = {
                {unit.collision_box[1][1] * 0.70, unit.collision_box[1][2] * 0.70},
                {unit.collision_box[2][1] * 0.70, unit.collision_box[2][2] * 0.70}
            }
        end
    end
end

if settings.startup["rampantFixed--enableFadeTime"].value then
    for k, corpse in pairs(data.raw["corpse"]) do
        if (string.find(k, "biter") or string.find(k, "spitter") or string.find(k, "hive") or
            string.find(k, "worm") or string.find(k, "spawner")) then
			if string.sub(k, 1, 13) == "spawner-spawn" then 
				corpse.time_before_removed = 60
			else
				corpse.time_before_removed = settings.startup["rampantFixed--unitAndSpawnerFadeTime"].value * 60
			end
		end	
    end
end

if settings.startup["rampantFixed--addWallResistanceAcid"].value then
    vanillaBuildings.addWallResistance()
end



