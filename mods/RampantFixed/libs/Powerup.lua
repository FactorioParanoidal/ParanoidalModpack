if (powerupG) then
    return powerupG
end
local powerup = {}

local mathUtils = require("libs/MathUtils")

function powerup.savePlayerAmmo(player, powerupSettings)
	powerupSettings["ammo"] = {}
	local ammoData = powerupSettings["ammo"]
	local character_ammo = player.get_inventory(defines.inventory.character_ammo)
	if not character_ammo then
		return
	end	
	for i = 1, #character_ammo do
		ammoData[i] = {name = "", count = 0}
		if character_ammo[i].valid_for_read then
			ammoData[i].name = character_ammo[i].name	
			ammoData[i].count = character_ammo[i].count	
		end
	end
end

function powerup.restoreAmmo(player, powerupSettings)
	local ammoData = powerupSettings["ammo"]
	if not ammoData then
		return false
	end
	local character_ammo = player.get_inventory(defines.inventory.character_ammo)
	if not character_ammo then
		return false
	end

	local ammoRestored = false
	local maxIndex = math.min(#character_ammo, #ammoData)

	for i = 1, maxIndex do
		if character_ammo[i].valid_for_read then
			if ammoData[i] and ammoData[i].name == character_ammo[i].name then
				if (character_ammo[i].count+1) == ammoData[i].count then
					character_ammo[i].count = ammoData[i].count
					ammoRestored = true
					break
				end
			end
		end
	end
	return ammoRestored
end

function powerup.setEndlessAmmo(player, powerupSettings, endlessAmmo, addTicks)
	powerupSettings.endlessAmmo = endlessAmmo
	if endlessAmmo then
		if addTicks then
			powerupSettings.endlessAmmoTick = (powerupSettings.endlessAmmoTick or game.tick) + addTicks
		else	
			powerupSettings.endlessAmmoTick = nil	-- forever
		end	
		powerup.savePlayerAmmo(player, powerupSettings)
	else
		powerupSettings.ammo = nil
		powerupSettings.endlessAmmoTick = nil
	end
end

function powerup.on_player_cursor_stack_changed(player, powerupSettings)
	if powerupSettings.endlessAmmoTick and (powerupSettings.endlessAmmoTick < game.tick) then
		powerupSettings.endlessAmmoTick = nil
		powerupSettings.endlessAmmo = nil		
		return
	end	
	powerup.savePlayerAmmo(player, powerupSettings)	
end

function powerup.endlessAmmo_onInventoryChanged(player, powerupSettings)
	local ammoRestored
	if powerupSettings.endlessAmmoTick and (powerupSettings.endlessAmmoTick < game.tick) then
		powerupSettings.endlessAmmoTick = nil
		powerupSettings.endlessAmmo = nil
		return
	end	
	local ammoRestored = powerup.restoreAmmo(player, powerupSettings)
	if not ammoRestored then
		powerup.savePlayerAmmo(player, powerupSettings)
	end

end

function powerup.setOneshotBiters(player, universepowerupSettings, oneshotBiters, addTicks)

	local powerupSettings = universepowerupSettings[player.name]
	powerupSettings.oneshotBiters = oneshotBiters
	if oneshotBiters then
		------		
		if addTicks then
			local tick = math.max(game.tick, (powerupSettings.oneshotBitersTick or 0))
			powerupSettings.oneshotBitersTick = (tick or game.tick) + addTicks
		else	
			powerupSettings.oneshotBitersTick = nil	-- forever
		end	
	else
		powerupSettings.oneshotBitersTick = nil		
	end
end


function powerup.setBonusHP(player, powerupSettings, health_bonus)
	if not player.character then
		return
	end	
	player.character.character_health_bonus = health_bonus 
	if health_bonus > 0 then
		powerupSettings.bonusHP = health_bonus			
	else	
		powerupSettings.bonusHP = nil
	end
end

function powerup.drawPowerups(player, powerupSettings, powerupType)
	if not player.character then
		return
	end
	
	if (not powerupType) or (powerupType == "combat") then
		if powerupSettings.endlessAmmoTick then		
			local draw_circle_timeToLive = powerupSettings.endlessAmmoTick - game.tick
			if draw_circle_timeToLive > 0 then
				-- game.print(draw_circle_timeToLive)	-- debug
				rendering.draw_circle{color = {r = 0.5, b = 0.5}, radius = 0.5, width = 2, target = player.character, surface = player.surface, time_to_live = draw_circle_timeToLive, draw_on_ground  = true, only_in_alt_mode = true}
				if draw_circle_timeToLive > 600 then				
					rendering.draw_circle{color = {r = 1}, radius = 0.5, width = 5, target = player.character, surface = player.surface, time_to_live = (draw_circle_timeToLive - 600), draw_on_ground  = true, only_in_alt_mode = true}
				end	
			end	
		end	
	end
end

function powerup.applyCombatPowerup(player, universepowerupSettings, powerupDuration)
	if not player.character then
		return
	end	
	if not universepowerupSettings[player.name] then
		universepowerupSettings[player.name] = {}
	end
	local powerupSettings = universepowerupSettings[player.name]
	powerup.setEndlessAmmo(player, powerupSettings, true, powerupDuration)
	powerup.setOneshotBiters(player, universepowerupSettings, true, powerupDuration)	
	
	powerup.drawPowerups(player, powerupSettings, "combat")
	if powerupDuration then
		player.create_local_flying_text({text = "+++++", color = {1, 0, 0}, surface = player.surface, position = player.character.position, speed  = 3, time_to_live = 60})	
	end	
	
end

local oneshotCauseTypes = {character = true, drone = true}
local oneshotDamageTypes = {physical = true, explosion = true}

local entitisToKillQuery = {force = "enemy", type={"unit", "spider-unit", "segmented-unit"}, position = {}, radius = 3}
function powerup.onUnitDamaged_oneshot(event, universe)
	local universepowerupSettings = universe.powerupSettings
	if (not event.cause.valid) or (not oneshotCauseTypes[event.cause.type]) then
		return false
	end
	if not event.cause.player then
		return false
	end	
	local powerupSettings = universepowerupSettings[event.cause.player.name]
	if (not powerupSettings) or (not powerupSettings.oneshotBiters) then
		return false
	end
	if powerupSettings.oneshotBitersTick and (powerupSettings.oneshotBitersTick < game.tick) then
		powerup.setOneshotBiters(event.cause.player, universepowerupSettings, false)
		return false		
	end
	if not oneshotDamageTypes[event.damage_type.name] then
		return false				
	end
			
	if event.entity.max_health > 4000 then
		event.final_damage_amount = event.final_damage_amount*10
		event.entity.health = event.entity.health - event.final_damage_amount
		event.final_health = event.entity.health
		return false
	end
	event.entity.health = 0
	event.final_health = event.entity.health
	universe.unitProtectionData.unitCurrentHP[event.entity.unit_number] = nil
	
	entitisToKillQuery.position = event.entity.position
	entitisToKill = event.entity.surface.find_entities_filtered(entitisToKillQuery)
	for i=1,#entitisToKill do
		local entity = entitisToKill[i]
		if entity.valid then
			if entity.max_health <= 4000 then
				universe.unitProtectionData.unitCurrentHP[entity.unit_number] = nil
				entity.die(event.cause.player.force, event.cause)
			end	
		end
	end	
	return true
end

function powerup.onPlayerRespawned(player, universepowerupSettings)
	local powerupSettings = universepowerupSettings[player.name]
	if powerupSettings and powerupSettings.bonusHP and (powerupSettings.bonusHP > 0) then
		powerup.setBonusHP(player, powerupSettings, powerupSettings.bonusHP)
	end
end


local dropChanceByRange = {}
dropChanceByRange[#dropChanceByRange+1] = {range = 15, rate = 0.1}
dropChanceByRange[#dropChanceByRange+1] = {range = 20, rate = 0.07}
dropChanceByRange[#dropChanceByRange+1] = {range = 40, rate = 0.05}
dropChanceByRange[#dropChanceByRange+1] = {range = 70, rate = 0.03}
dropChanceByRange[#dropChanceByRange+1] = {range = 90, rate = 0.01}

local regenerationCrystalChance = 0.01

function powerup.checkAndDropPowerup(entity, cause, universe, evo)
	if entity.max_health < 400 then
		return
	end	
	if not (entity.type == "unit-spawner") then
		return
	end	
	local evoK
	if evo then
		if evo < 0.5 then
			evoK = 1
		elseif evo < 0.8 then
			evoK = 1.2
		elseif evo < 0.9 then
			evoK = 1.4
		else
			evoK = 1.6
		end
	end
	local roll = universe.dropRandomizer()
	-- if roll >= dropChanceByRange[1].rate then		-- temporarily, Let's assume that this is the biggest chance
		-- return
	-- end	
	local distance = mathUtils.euclideanDistancePoints(entity.position.x, entity.position.y, cause.position.x, cause.position.y)
	for _, dropChance in pairs(dropChanceByRange) do
		if distance <= dropChance.range then
			if roll < dropChance.rate * evoK then
				lootEntity = entity.surface.create_entity({name = "lootStone_Combat5-rampantFixed", position = entity.position})
				if lootEntity then
					lootEntity.health = 1
				end
			end
			break
		end
	end
	if (distance <= 20) and (universe.dropRandomizer() < regenerationCrystalChance) then
		regenerationCrystal = entity.surface.create_entity({name = "regenerationCrystal-rampantFixed", force = "neutral", position = entity.position})
		regenerationCrystal.destructible = false
		regenerationCrystal.active = false		
	end
	-- if universe.dropRandomizer() < 0.5 then
		-- lootEntity = entity.surface.create_entity({name = "lootStone_Combat5", position = entity.position})
		-- if lootEntity then
			-- lootEntity.health = 1
		-- end
	-- end
end

local charatersToHealQuery = {force = nil, type={"character"}, position = {}, radius = 10}

function powerup.onRegenerationCrystalTick(sourceEntity, evo)
	charatersToHealQuery.force = sourceEntity.force
	charatersToHealQuery.position = sourceEntity.position
	local entitisToHeal = sourceEntity.surface.find_entities_filtered(charatersToHealQuery)
	
	for i=1,#entitisToHeal do
		local entity = entitisToHeal[i]
		if entity.valid then
			if (not evo) or (evo < 0.5) then
				entity.surface.create_entity({name= "regenerationCrystal-sticker-rampantFixed", force = sourceEntity.force, position = entity.position, target = entity})
			elseif evo < 0.7 then
				entity.surface.create_entity({name= "regenerationCrystal-sticker2-rampantFixed", force = sourceEntity.force, position = entity.position, target = entity})
			else
				entity.surface.create_entity({name= "regenerationCrystal-sticker3-rampantFixed", force = sourceEntity.force, position = entity.position, target = entity})
			end
		end
	end	
	
	if (#entitisToHeal > 0) and (math.random() <= 0.01) then
		sourceEntity.destructible = true
		sourceEntity.die()
	else	
		sourceEntity.destructible = false
		rendering.draw_circle{color = {g = 1, r = 0.5}, radius = 10, width = 2, target = sourceEntity, surface = sourceEntity.surface, time_to_live = 300, draw_on_ground  = true, only_in_alt_mode = true}
	end	
	
	
end

---- prototype

function powerup.makePowerup_capsule()
    data:extend({
            {
                type = "capsule",
                name = "powerup-Combat5min-Capsule-rampantFixed",
				localised_description = {"item-description.powerup-Combat5min-Capsule-rampantFixed"},
                icons = {{icon = "__RampantFixed__/graphics/icons/powerup.png", tint = {r=1, g=0.7, b=0, a=1}, icon_size = 32}},
                flags = {},
                capsule_action = 
				{
					type = "use-on-self",
					attack_parameters =
						{
							type = "projectile",
							activation_type = "consume",
							ammo_category = "grenade",
							cooldown = 60,
							range = 0,
							ammo_type =
								{
									category = "capsule",
									target_type = "entity",
									action =
										{
											type = "direct",
											action_delivery =
												{
													type = "instant",
													target_effects =
														{
															type = "script",
															effect_id = "powerup-combat5min-rampantFixed"
														}
												}
										}
								}
						}
					},
                subgroup = "capsule",
                order = "a[grenade]-a[normal]",
                stack_size = 100
            }
	})

	local lootStone_Combat5 = util.table.deepcopy(data.raw["simple-entity"]["big-sand-rock"])
	lootStone_Combat5.name = "lootStone_Combat5-rampantFixed"
	lootStone_Combat5.flags[#lootStone_Combat5.flags+1] = "not-in-kill-statistics"
    -- lootStone_Combat5.autoplace.max_probability = 0.001
    lootStone_Combat5.autoplace = nil
	
    lootStone_Combat5.minable =
    {
      mining_particle = "stone-particle",
      mining_time = 0.1,
      results = {{type = "item", name = "powerup-Combat5min-Capsule-rampantFixed", amount_min = 1, amount_max = 1}}
    }
	lootStone_Combat5.loot = 
    {
      {item = "powerup-Combat5min-Capsule-rampantFixed"}
    }
	data:extend({lootStone_Combat5})

end

function powerup.make_RegenerationCrystal()
    data:extend({
		   
            {
                type = "radar",
                name = "regenerationCrystal-rampantFixed",
                icons = {{icon = "__RampantFixed__/graphics/icons/thief/crystal-drain.png", tint = {r=0.1, g=0.7, b=0, a=0.5}, icon_size = 32}},
				flags = {"placeable-player", "player-creation"},
				minable = {mining_time = 5, result = "regenerationCrystal-rampantFixed"},
                max_health = 3000,
				create_ghost_on_death  = false,
				is_military_target = false,
				alert_when_damaged = false,
                corpse = "small-remnants",
                collision_box = {{-0.8, -0.8 }, {0.8, 0.8}},
                selection_box = {{-1, -1}, {1, 1}},
                energy_per_nearby_scan = "6MJ",
                energy_per_sector = "6MJ",
				emissions_per_second = {pollution = 1},
                max_distance_of_sector_revealed = 0,
				max_distance_of_nearby_sector_revealed = 1,
                resistances = {{type = "physical", decrease = -10, percent = -100}},
				call_for_help_radius = 1,
                energy_source =  {type = "void"},
                energy_usage = "20kJ",
                pictures =
                    {
                        filename = "__RampantFixed__/graphics/entities/thief/crystal-drain.png",
						tint = {r=0.1, g=0.7, b=0, a=0.5},
                        priority = "low",
                        width = 128,
                        height = 128,
                        scale = 1,
                        apply_projection = false,
                        direction_count = 32,
                        animation_speed = 0.5,
                        line_length = 8,
                        shift = {0.65, 0}
                    },
                vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
                radius_minimap_visualisation_color = { r = 0.059, g = 0.092, b = 0.8, a = 0.275 }
			}		   
			,
			{
			type = "item",
			name = "regenerationCrystal-rampantFixed",
            icons = {{icon = "__RampantFixed__/graphics/icons/thief/crystal-drain.png", tint = {r=0.1, g=0.7, b=0, a=0.5}, icon_size = 32}},
			subgroup = "defensive-structure",
			order = "a[powerup]-a[regenerationCrystal]",
			place_result = "regenerationCrystal-rampantFixed",
			stack_size = 10
			}
			,
			{
			type = "sticker",
			name = "regenerationCrystal-sticker-rampantFixed",
			flags = {"not-on-map"},
			damage_interval = 6,
			damage_per_tick = {amount = -2, type = "poison"},
			animation =
			{
			  filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
			  line_length = 8,
			  width = 60,
			  height = 118,
			  frame_count = 25,
			  blend_mode = "normal",
			  animation_speed = 0.5,
			  scale = 0.3,
			  tint = {r=0.1, g=0.7, b=0, a=0.5},
			  --shift = math3d.vector2.mul({-0.078125, -1.8125}, 0.1),
			  draw_as_glow = true
			},
			force_visibility = "ally",
			duration_in_ticks = 60 * 60,
			}
			,
			{
			type = "sticker",
			name = "regenerationCrystal-sticker2-rampantFixed",
			flags = {"not-on-map"},
			damage_interval = 6,
			damage_per_tick = {amount = -6, type = "poison"},
			animation =
			{
			  filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
			  line_length = 8,
			  width = 60,
			  height = 118,
			  frame_count = 25,
			  blend_mode = "normal",
			  animation_speed = 0.5,
			  scale = 0.3,
			  tint = {r=0.1, g=0.7, b=0, a=0.5},
			  --shift = math3d.vector2.mul({-0.078125, -1.8125}, 0.1),
			  draw_as_glow = true
			},
			force_visibility = "ally",
			duration_in_ticks = 60 * 60,
			}
			,
			{
			type = "sticker",
			name = "regenerationCrystal-sticker3-rampantFixed",
			flags = {"not-on-map"},
			damage_interval = 6,
			damage_per_tick = {amount = -18, type = "poison"},
			animation =
			{
			  filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
			  line_length = 8,
			  width = 60,
			  height = 118,
			  frame_count = 25,
			  blend_mode = "normal",
			  animation_speed = 0.5,
			  scale = 0.3,
			  tint = {r=0.1, g=0.7, b=0, a=0.5},
			  --shift = math3d.vector2.mul({-0.078125, -1.8125}, 0.1),
			  draw_as_glow = true
			},
			force_visibility = "ally",
			duration_in_ticks = 60 * 60,
			}
		})
	
end
--------
powerupG = powerup
return powerup
