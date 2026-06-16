if (demolisherUtilsG) then
    return demolisherUtilsG
end
local demolisherUtils = {}

local biterSupressors = require("libs/BiterSupressors")
local constants = require("libs/Constants")
local customAlerts = require("CustomAlerts")
local mathUtils = require("libs/MathUtils")

local increaseNextDemolisherAttackTick = biterSupressors.increaseNextDemolisherAttackTick
local showAlert = customAlerts.showAlert

local mMax = math.max
local mRandom = math.random

function demolisherUtils.feedDemolisher(demolisher, cause_entity, surface_index)
	if not demolisher.valid then
		return
	end
	local universe = storage.universe
	
	local demolisherFeeded = false

	
	local surface = game.surfaces[surface_index]
	local map = universe.maps[surface_index]
	local hunger = 0
	if map and map.wildDemolishers then
		for unit_number, wildDemolisherData in pairs(map.wildDemolishers) do
			if wildDemolisherData.entity.valid 
				and (unit_number == demolisher.unit_number) 
				and (wildDemolisherData.hunger > 0)
				then
				wildDemolisherData.hunger = mMax(wildDemolisherData.hunger - 1, 0)
				demolisherFeeded = true	
				hunger = wildDemolisherData.hunger	
				break
			end
		end
	end

	if demolisherFeeded then
		universe.demolisherTriggers[demolisher.unit_number] = nil
	end
		
	local messageSource
	if cause_entity and cause_entity.valid then
		if (cause_entity.type == "character") and cause_entity.player and cause_entity.player.valid then
			messageSource = cause_entity.player
		else
			messageSource = surface	--cause_entity.force
		end
	else
		messageSource = surface
	end

	if not demolisherFeeded then
		messageSource.print({"description.rampantFixed--demolisherNotFeeded", surface.name})		
		return
	else
		local demolisherAttackInterval = 3600*60*2
		-- map.nextDemolisherAttackTick = mMax(map.nextDemolisherAttackTick or game.tick, game.tick) + 3600*60
		increaseNextDemolisherAttackTick(map, demolisherAttackInterval)

		local minutesLeft = math.floor((map.nextDemolisherAttackTick - game.tick) / 3600)

		if hunger > 0 then	
			messageSource.print({"description.rampantFixed--demolisherFeeded_Hunger", surface.name, minutesLeft, hunger})		
		else
			messageSource.print({"description.rampantFixed--demolisherFeeded_noHunger", surface.name, minutesLeft})		
		end	
	end	
end

function demolisherUtils.fearDemolishers(surface_index)
	local universe = storage.universe
	
	local demolisherFeeded = false

	
	local surface = game.surfaces[surface_index]
	local map = universe.maps[surface_index]
	if not map then
		return
	end
	local hunger = 0
	if map.wildDemolishers then
		for unit_number, wildDemolisherData in pairs(map.wildDemolishers) do
			if wildDemolisherData.entity.valid and (wildDemolisherData.hunger > 0) then
				wildDemolisherData.hunger = 0
				universe.demolisherTriggers[unit_number] = nil
			end
		end
	end
		
	messageSource = surface

	local demolisherAttackInterval = 3600*60*8
	biterSupressors.setNextDemolisherAttackTick(map, demolisherAttackInterval)

	local minutesLeft = math.floor((map.nextDemolisherAttackTick - game.tick) / 3600)
	messageSource.print({"description.rampantFixed--demolisherFeared", surface.name, minutesLeft})		
end

local SA_demolishers = {}

SA_demolishers["small-demolisher"]={hunger = 1}
SA_demolishers["medium-demolisher"]={hunger = 2}
SA_demolishers["big-demolisher"]={hunger = 3}

local demolisherAttackInterval_min = 3600*5
local demolisherAttackInterval_max_evo0 = 3600*30
local demolisherAttackInterval_max_evo100 = 3600*15

local demolisherAttack_evo1 = 0.6	-- medium demolisher
local demolisherAttack_evo2 = 0.9	-- large demolisher
local demolisherAttack_evo3 = 0.95	-- only large demolisher

local addWildDemolisherChance = 0.2	-- for 2+ demolishers. To prevent attacks always from 1 side
local wildDemolishersLimit = 10

local function mutateDemolisher(demolisherSource, evo)
	local newEntityName
	if not (SA_demolishers[demolisherSource.name] or false) then
		newEntityName = demolisherSource.name
		-- game.print("not SA demolisher "..demolisherSource.name)		-- debug
	elseif mRandom() < 0.2 then
		-- game.print("copy SA demolisher "..demolisherSource.name)	-- debug
		newEntityName = demolisherSource.name
	else
		local SA_demolisherNumber
		if evo < demolisherAttack_evo1 then
			SA_demolisherNumber = 1
		elseif evo < demolisherAttack_evo2 then
			SA_demolisherNumber = mRandom(1, 2)
		elseif evo < demolisherAttack_evo3 then
			SA_demolisherNumber = mRandom(2, 3)
		else	
			SA_demolisherNumber = 3
		end
		local SA_demolisherIndex = 0
		for  SA_demolisherName, _ in pairs(SA_demolishers) do
			SA_demolisherIndex = SA_demolisherIndex + 1
			if SA_demolisherIndex == SA_demolisherNumber then
				newEntityName = SA_demolisherName
			end	
		end	
		-- game.print("randomize SA demolisher "..demolisherSource.name.."-->"..newEntityName)	-- debug
	end
	return newEntityName
end

function demolisherUtils.processDemolishers()
	local planetAISetting
	local universe = storage.universe
	local surface
	local evo
	
	for _, map in pairs(universe.maps) do
		if (not map.suspended) and (game.tick >= map.nextDemolisherAttackTick) and map.surface.valid and not (map.state == constants.AI_STATE_PEACEFUL) then
			surface = map.surface
			evo = game.forces.enemy.get_evolution_factor(surface)
			planetAISetting = (universe.planetAISettings[surface.name] or universe.planetAISettings["others"])
			if (planetAISetting.AI == 3) then
				local demolishers = surface.find_entities_filtered({force = "enemy", type = "segmented-unit"})
				local demolishersCount = #demolishers
				
				local targetEntities
				local targetEntitiesCount
				if (demolishersCount > 0) then
					targetEntities = surface.find_entities_filtered({force = universe.activePlayerForces, type = {"accumulator", "assembling-machine", "furnace", "lab", "mining-drill", "rocket-silo", "solar-panel"}})
					targetEntitiesCount = #targetEntities 
				
					if (targetEntitiesCount > 0) then
						local demolisher
						-----
						local attackCandidates = {}
						if map.wildDemolishers then
							for i, wildDemolisherData in pairs(map.wildDemolishers) do
								if wildDemolisherData.entity.valid then
									attackCandidates[#attackCandidates+1] = wildDemolisherData.entity
								else
									map.wildDemolishers[i] = nil
									-- game.print("wild demolisher killed")	-- debug
								end
							end
						end	
						-------
						if (#attackCandidates >= wildDemolishersLimit) or (not (mRandom() < addWildDemolisherChance)) then	-- if has wildDemolishers, then choose one of them most of times. Or add new sometimes 
							if #attackCandidates > 0 then
								if #attackCandidates == 1 then
									demolisher = attackCandidates[1]
								else
									demolisher = attackCandidates[mRandom(1, #attackCandidates)]
								end
								-- game.print("wild demolisher attack "..demolisher.name)	-- debug
							end
						end	
						local targetEntity
						if not demolisher then
							local demolisherSource = demolishers[mRandom(1, demolishersCount)]
							local newEntityName = mutateDemolisher(demolisherSource, evo)
							if map.nextDemolisherAttack and map.nextDemolisherAttack.demolisher.valid then
								demolisherSource = map.nextDemolisherAttack.demolisher
								newEntityName = map.nextDemolisherAttack.newEntityName
								if map.nextDemolisherAttack.target.valid then
									targetEntity = map.nextDemolisherAttack.target
								end
							else
								demolisherSource = demolishers[mRandom(1, demolishersCount)]
								newEntityName = mutateDemolisher(demolisherSource, evo)
							end

							demolisher = surface.create_entity({
										position= demolisherSource.position,
										name = newEntityName,
										direction=demolisherSource.direction,
										force = demolisherSource.force
								})
							if not map.wildDemolishers then
								map.wildDemolishers = {}
							end 
							local hunger = (SA_demolishers[newEntityName] and SA_demolishers[newEntityName].hunger) or 1
							map.wildDemolishers[demolisher.unit_number] = {entity = demolisher, hunger = hunger}
						end
						
						if not targetEntity then
							targetEntity = targetEntities[mRandom(1, targetEntitiesCount)]
						end
						universe.demolisherTriggers[demolisher.unit_number] = {
							surface = surface, 
							demolisher = demolisher, 
							target = targetEntity,
							nextRevengeTick = nil,
							detected = false
							}							
						-- rendering.draw_line{surface = surface, from = demolisher.position, to = targetEntity.position, color = {0, 0, 1}, width = 2, time_to_live = 6000}	-- debug
						if not universe.demolisherNoteShown	then
							game.print({"description.rampantFixed--demolisherNote1", surface.name})
							game.print({"description.rampantFixed--demolisherNote2"})
							game.print({"description.rampantFixed--demolisherNote3", demolisherAttack_evo1*100, demolisherAttack_evo2*100})
							universe.demolisherNoteShown = true
						end

						map.nextDemolisherAttack = {}	-- used if no wild demolishers or rolled to add new 
						map.nextDemolisherAttack.demolisher = demolishers[mRandom(1, demolishersCount)]
						map.nextDemolisherAttack.newEntityName = mutateDemolisher(map.nextDemolisherAttack.demolisher, evo)
						map.nextDemolisherAttack.target = targetEntities[mRandom(1, targetEntitiesCount)]
						-- game.print("[gps=" .. demolisher.position.x .. "," .. demolisher.position.y .. "," .. surface.name .."]")	-- debug
						-- game.print("next is "..map.nextDemolisherAttack.newEntityName.." [gps=" .. map.nextDemolisherAttack.demolisher.position.x .. "," .. map.nextDemolisherAttack.demolisher.position.y .. "," .. surface.name .."]")	-- debug
					end
				end			
			end
			
			local demolisherAttackInterval_max = demolisherAttackInterval_max_evo0 + (demolisherAttackInterval_max_evo100 - demolisherAttackInterval_max_evo0) * evo
			-- map.nextDemolisherAttackTick = game.tick +  demolisherAttackInterval_min + math.floor(demolisherAttackInterval_max * mRandom())
			local demolisherAttackInterval = demolisherAttackInterval_min + math.floor(demolisherAttackInterval_max * mRandom())
			demolisherAttackInterval = demolisherAttackInterval + universe.demolisherAttack_AdditionalTime * 3600
			increaseNextDemolisherAttackTick(map, demolisherAttackInterval)
		else
			-- game.print(surface.name..":suspended = "..tostring(map.suspended))
		end	
	end

end

function demolisherUtils.processDemolisherTriggers()
	for i, demolisherTrigger in pairs(storage.universe.demolisherTriggers) do
		if demolisherTrigger.surface and demolisherTrigger.surface.valid
		and demolisherTrigger.demolisher and demolisherTrigger.demolisher.valid
		and demolisherTrigger.target and demolisherTrigger.target.valid
		then
			demolisherTrigger.demolisher.damage(1, demolisherTrigger.target.force, "physical", demolisherTrigger.target,  demolisherTrigger.target)
			if not demolisherTrigger.detected then
				demolisherTrigger.detected = showAlert(demolisherTrigger.surface, demolisherTrigger.demolisher, "demolisherAttack-warning-rampant", {"", {"description.rampantFixed--demolisherAttackDetectedWarning"}})	
			end
		else
			storage.universe.demolisherTriggers[i] = nil
		end
	end
end

local demolisherRevengeCooldown = 20	-- ticks
local demolisherRevengeRange = 25
function demolisherUtils.onSegmentedEntityDamaged(event)
		
	if 	(not event.segmented_unit)
		or (not event.segmented_unit.valid)
		or (not event.cause)
		or (not event.cause.valid)
		then
		return
	end
	local demolisherTrigger = storage.universe.demolisherTriggers[event.segmented_unit.unit_number]
	if not demolisherTrigger then
		demolisherTrigger = storage.universe.demolisherTriggers[event.segmented_unit.unit_number - 1]	-- (don't know why, but unit_number greater by 1)
	end
	if not demolisherTrigger then
		local i = 0
		for unit_number, demolisherTrigger in pairs(storage.universe.demolisherTriggers) do
			i = i + 1
		end
		return
	end
	if demolisherTrigger.nextRevengeTick and (demolisherTrigger.nextRevengeTick > game.tick) then
		return
	end	
	local surface = event.segmented_unit.surface
	local evo = game.forces.enemy.get_evolution_factor(surface)
	if evo < 0.4 then
		return
	end
	local incomingRange = mathUtils.euclideanDistancePoints(event.segmented_unit.segments[1].position.x, event.segmented_unit.segments[1].position.y, event.cause.position.x, event.cause.position.y)
	if incomingRange > demolisherRevengeRange then
		return
	end	
	local attackName
	if evo < 0.6 then
		attackName = "small-demolisher-fissure"
	elseif evo < 0.9 then
		attackName = "medium-demolisher-fissure"
	else
		attackName = "big-demolisher-fissure"
	end
	surface.create_entity({name = attackName, force = game.forces.enemy, position = event.cause.position})
	
	demolisherTrigger.nextRevengeTick = game.tick + demolisherRevengeCooldown
end

-- called each 30000 tick. 
-- cant just set evo by time in settings, becouse pollution can be turned on
function demolisherUtils.vulcanusEvolution()
	local universe = storage.universe
	for _, map in pairs(universe.maps) do
		local surface = map.surface
		planetAISetting = (universe.planetAISettings[surface.name] or universe.planetAISettings["others"])
		if (planetAISetting.AI == 3) then
			local demolishersCount = surface.count_entities_filtered({force = "enemy", type = "segmented-unit"})
			if demolishersCount > 0 then
				game.forces.enemy.get_evolution_factor_by_time(map.surface)
				local evo = game.forces.enemy.get_evolution_factor(map.surface)
				local lastEvo = map.lastEvo or 0
				if lastEvo > 1 then
					lastEvo = 0
				end
				local evoK = (1 - lastEvo)^2
				local newEvo = lastEvo + 0.0075*evoK 
				if (evo >= (map.lastEvo or 0)) and (evo < newEvo) then
					game.forces.enemy.set_evolution_factor(newEvo, map.surface)
				end
				map.lastEvo = game.forces.enemy.get_evolution_factor(map.surface)
				-- game.print(" demolisherUtils.vulcanusEvolution() "..game.forces.enemy.get_evolution_factor(surface)..", evo = ".. evo..", newEvo ="..newEvo)	-- debug
			end
		end	
	end
end

--------- prototypes
function demolisherUtils.makeDemolisherFood()
	local item_sounds = require("__base__.prototypes.item_sounds")
	local newAmmo = util.table.deepcopy(data.raw["ammo"]["rocket"])
	newAmmo.name = "demolisher-food-rocket-rampant"
	newAmmo.icons = {
		{icon = "__base__/graphics/icons/rocket.png"},
		{icon = "__base__/graphics/icons/signal/signal-heart.png", scale = 0.25, shift = {10, 10}, size = 32}
		}
	newAmmo.order = "d[rocket-launcher]-a[basic]-[demolisher]"
	newAmmo.stack_size = 1
	newAmmo.ammo_type =
		{
		  action =
		  {
			type = "direct",
			action_delivery =
			{
			  type = "projectile",
			  projectile = "demolisher-food-rocket-rampant",
			  starting_speed = 0.1
			}
		  },		  
		  target_filter = {"small-demolisher", "medium-demolisher", "big-demolisher"}
		}
	data:extend({newAmmo})	

	local newProjectile = 
		  {
			type = "projectile",
			name = "demolisher-food-rocket-rampant",
			flags = {"not-on-map"},
			hidden = true,
			acceleration = 0.01,
			turn_speed = 0.003,
			turning_speed_increases_exponentially_with_projectile_speed = true,
			action =
			{
			  type = "direct",
			  action_delivery =
			  {
				type = "instant",
				target_effects =
				{
				  {
					type = "create-entity",
					entity_name = "explosion"
				  },
				  {
					type = "damage",
					damage = {amount = -200, type = "poison"}
				  },
				  {
					type = "script",
					effect_id = "feed-the-demolisher-rampant"
				  }
				}
			  }
			},
			light = {intensity = 0.8, size = 4},
			animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({0.3, 0.8, 0.3}),
			shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
			smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke
		   }

	data:extend({newProjectile})

	local newRecipe =
		   {
			  type = "recipe",
			  category = "metallurgy",
			  name = "demolisher-food-rocket-rampant",
			  energy_required = 10,
			  ingredients =
			  {
				{type = "item", name = "rocket", amount = 1},
				{type = "item", name = "solar-panel", amount = 10},
				{type = "item", name = "big-mining-drill", amount = 2},
				{type = "item", name = "metallurgic-science-pack", amount = 2},
				{type = "fluid", name = "lava", amount = 50}
			  },
			  results = {{type="item", name="demolisher-food-rocket-rampant", amount=1}
			  },
			  main_product = "demolisher-food-rocket-rampant",
			  allow_as_intermediate = false,
			  auto_recycle = false,
			  enabled = false
			}
	data:extend({newRecipe})

	local newTechnology =
	  {
		type = "technology",
		name = "demolisher-feeding-rampant",
		icons = newAmmo.icons,
		effects =
		{
		  {
			type = "unlock-recipe",
			recipe = "demolisher-food-rocket-rampant"
		  }
		},
		prerequisites = {"big-mining-drill", "foundry", "metallurgic-science-pack"},
		unit =
		{
		  count = 200,
		  ingredients =
		  {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
			{"production-science-pack", 1},
			{"utility-science-pack", 1},
			{"space-science-pack", 1},
			{"metallurgic-science-pack", 1}
		  },
		  time = 60
		}
	  }
	data:extend({newTechnology})

end	

-- copied from space-age\prototypes\entity\explosions
local function atomic_rocket_surface_explosion(explosion_name)
  -- target index 2, otherwise the lava tiles can remove cliffs first and you'd not get the achievement for cliff destruction.
  table.insert(data.raw.projectile["atomic-rocket-rampant"].action.action_delivery.target_effects, 2, {
    type = "create-entity",
    check_buildability = true,
    entity_name = explosion_name
  })
end

local function makeAtomicRocketCopy()
	local sounds = require("__base__.prototypes.entity.sounds")

	local newAtomicRocket =
	  {
		type = "projectile",
		name = "atomic-rocket-rampant",
		flags = {"not-on-map"},
		hidden = true,
		acceleration = 0.005,
		turn_speed = 0.003,
		turning_speed_increases_exponentially_with_projectile_speed = true,
		action =
		{
		  type = "direct",
		  action_delivery =
		  {
			type = "instant",
			target_effects =
			{
			  { -- Destroy cliffs before changing tiles (so the cliff achievement works)
				type = "destroy-cliffs",
				radius = 9,
				explosion_at_trigger = "explosion"
			  },
			  -- Explosion entities for other surface-specific effects are added here
			  {
				type = "create-entity",
				check_buildability = true,
				-- This entity can have surface conditions
				entity_name = "nuke-effects-nauvis"
			  },
			  {
				type = "create-entity",
				entity_name = "nuke-explosion"
			  },
			  {
				type = "camera-effect",
				duration = 60,
				ease_in_duration = 5,
				ease_out_duration = 60,
				delay = 0,
				strength = 6,
				full_strength_max_distance = 200,
				max_distance = 800
			  },
			  {
				type = "play-sound",
				sound = sounds.nuclear_explosion(0.9),
				play_on_target_position = false,
				max_distance = 1000,
			  },
			  {
				type = "play-sound",
				sound = sounds.nuclear_explosion_aftershock(0.4),
				play_on_target_position = false,
				max_distance = 1000,
			  },
			  {
				type = "damage",
				damage = {amount = 400, type = "explosion"}
			  },
			  {
				type = "create-entity",
				entity_name = "huge-scorchmark",
				offsets = {{ 0, -0.5 }},
				check_buildability = true
			  },
			  {
				type = "invoke-tile-trigger",
				repeat_count = 1
			  },
			  {
				type = "destroy-decoratives",
				include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
				include_decals = true,
				invoke_decorative_trigger = true,
				decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
				radius = 14 -- large radius for demostrative purposes
			  },
			  {
				type = "create-decorative",
				decorative = "nuclear-ground-patch",
				spawn_min_radius = 11.5,
				spawn_max_radius = 12.5,
				spawn_min = 30,
				spawn_max = 40,
				apply_projection = true,
				spread_evenly = true
			  },
			  {
				type = "nested-result",
				action =
				{
				  type = "area",
				  target_entities = false,
				  trigger_from_target = true,
				  repeat_count = 1000,
				  radius = 7,
				  action_delivery =
				  {
					type = "projectile",
					projectile = "atomic-bomb-ground-zero-projectile",
					starting_speed = 0.6 * 0.8,
					starting_speed_deviation = nuke_shockwave_starting_speed_deviation
				  }
				}
			  },
			  {
				type = "nested-result",
				action =
				{
				  type = "area",
				  target_entities = false,
				  trigger_from_target = true,
				  repeat_count = 1000,
				  radius = 35,
				  action_delivery =
				  {
					type = "projectile",
					projectile = "atomic-bomb-wave",
					starting_speed = 0.5 * 0.7,
					starting_speed_deviation = nuke_shockwave_starting_speed_deviation
				  }
				}
			  },
			  {
				type = "nested-result",
				action =
				{
				  type = "area",
				  show_in_tooltip = false,
				  target_entities = false,
				  trigger_from_target = true,
				  repeat_count = 1000,
				  radius = 26,
				  action_delivery =
				  {
					type = "projectile",
					projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
					starting_speed = 0.5 * 0.7,
					starting_speed_deviation = nuke_shockwave_starting_speed_deviation
				  }
				}
			  },
			  {
				type = "nested-result",
				action =
				{
				  type = "area",
				  show_in_tooltip = false,
				  target_entities = false,
				  trigger_from_target = true,
				  repeat_count = 700,
				  radius = 4,
				  action_delivery =
				  {
					type = "projectile",
					projectile = "atomic-bomb-wave-spawns-fire-smoke-explosion",
					starting_speed = 0.5 * 0.65,
					starting_speed_deviation = nuke_shockwave_starting_speed_deviation
				  }
				}
			  },
			  {
				type = "nested-result",
				action =
				{
				  type = "area",
				  show_in_tooltip = false,
				  target_entities = false,
				  trigger_from_target = true,
				  repeat_count = 1000,
				  radius = 8,
				  action_delivery =
				  {
					type = "projectile",
					projectile = "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
					starting_speed = 0.5 * 0.65,
					starting_speed_deviation = nuke_shockwave_starting_speed_deviation
				  }
				}
			  },
			  {
				type = "nested-result",
				action =
				{
				  type = "area",
				  show_in_tooltip = false,
				  target_entities = false,
				  trigger_from_target = true,
				  repeat_count = 300,
				  radius = 26,
				  action_delivery =
				  {
					type = "projectile",
					projectile = "atomic-bomb-wave-spawns-nuclear-smoke",
					starting_speed = 0.5 * 0.65,
					starting_speed_deviation = nuke_shockwave_starting_speed_deviation
				  }
				}
			  },
			  {
				type = "nested-result",
				action =
				{
				  type = "area",
				  show_in_tooltip = false,
				  target_entities = false,
				  trigger_from_target = true,
				  repeat_count = 10,
				  radius = 8,
				  action_delivery =
				  {
					type = "instant",
					target_effects =
					{
					  {
						type = "create-entity",
						entity_name = "nuclear-smouldering-smoke-source",
						tile_collision_mask = {layers={water_tile=true}}
					  }
					}
				  }
				}
			  }
			}
		  }
		},
		--light = {intensity = 0.8, size = 15},
		animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({0.3, 1, 0.3}),
		shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
		smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke,
	  }

	data:extend({newAtomicRocket})
	
	atomic_rocket_surface_explosion("nuke-effects-aquilo")
	atomic_rocket_surface_explosion("nuke-effects-vulcanus")
	atomic_rocket_surface_explosion("nuke-effects-space")
	
end

function demolisherUtils.makeUnstableReactor()
	makeAtomicRocketCopy()

	data:extend(
	{
	  {
		type = "reactor",
		name = "unstable-feeding-reactor-rampant",
		icon  = "__base__/graphics/icons/nuclear-reactor.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.5, result = "nuclear-reactor"},
		fast_replaceable_group = "reactor",
		max_health = 500,
		corpse = "nuclear-reactor-remnants",
		dying_explosion = "nuclear-reactor-explosion",
		consumption = "40MW",
		neighbour_bonus = 1,
		energy_source =
		{type = "void"},
		collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
		selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
		picture =
		{
		  layers =
		  {
			{
			  filename = "__base__/graphics/entity/nuclear-reactor/reactor.png",
			  width = 302,
			  height = 318,
			  scale = 0.5,
			  shift = util.by_pixel(-5, -7)
			},
			{
			  filename = "__base__/graphics/entity/nuclear-reactor/reactor-shadow.png",
			  width = 525,
			  height = 323,
			  scale = 0.5,
			  shift = { 1.625, 0 },
			  draw_as_shadow = true
			}
		  }
		},

		working_light_picture =
		{
		  filename = "__base__/graphics/entity/nuclear-reactor/reactor-lights-color.png",
		  blend_mode = "additive",
		  draw_as_glow = true,
		  width = 320,
		  height = 320,
		  scale = 0.5,
		  shift = { -0.03125, -0.1875 },
		},

		heat_buffer =
		{
		  max_temperature = 1000,
		  specific_heat = "10MJ",
		  max_transfer = "10GW",
		  minimum_glow_temperature = 350,
		  connections =
		  {
			{
			  position = {-2, -2},
			  direction = defines.direction.north
			},
			{
			  position = {0, -2},
			  direction = defines.direction.north
			},
			{
			  position = {2, -2},
			  direction = defines.direction.north
			},
			{
			  position = {2, -2},
			  direction = defines.direction.east
			},
			{
			  position = {2, 0},
			  direction = defines.direction.east
			},
			{
			  position = {2, 2},
			  direction = defines.direction.east
			},
			{
			  position = {2, 2},
			  direction = defines.direction.south
			},
			{
			  position = {0, 2},
			  direction = defines.direction.south
			},
			{
			  position = {-2, 2},
			  direction = defines.direction.south
			},
			{
			  position = {-2, 2},
			  direction = defines.direction.west
			},
			{
			  position = {-2, 0},
			  direction = defines.direction.west
			},
			{
			  position = {-2, -2},
			  direction = defines.direction.west
			}
		  },

		  heat_picture = apply_heat_pipe_glow
		  {
			filename = "__base__/graphics/entity/nuclear-reactor/reactor-heated.png",
			width = 216,
			height = 256,
			scale = 0.5,
			shift = util.by_pixel(3, -6.5)
		  },
		},

		connection_patches_connected =
		{
		  sheet =
		  {
			filename = "__base__/graphics/entity/nuclear-reactor/reactor-connect-patches.png",
			width = 64,
			height = 64,
			variation_count = 12,
			scale = 0.5
		  }
		},

		connection_patches_disconnected =
		{
		  sheet =
		  {
			filename = "__base__/graphics/entity/nuclear-reactor/reactor-connect-patches.png",
			width = 64,
			height = 64,
			variation_count = 12,
			y = 64,
			scale = 0.5
		  }
		},

		heat_connection_patches_connected =
		{
		  sheet = apply_heat_pipe_glow
		  {
			filename = "__base__/graphics/entity/nuclear-reactor/reactor-connect-patches-heated.png",
			width = 64,
			height = 64,
			variation_count = 12,
			scale = 0.5
		  }
		},

		heat_connection_patches_disconnected =
		{
		  sheet = apply_heat_pipe_glow
		  {
			filename = "__base__/graphics/entity/nuclear-reactor/reactor-connect-patches-heated.png",
			width = 64,
			height = 64,
			variation_count = 12,
			y = 64,
			scale = 0.5
		  }
		},

		impact_category = "metal-large",
		open_sound = {filename = "__base__/sound/open-close/nuclear-open.ogg", volume = 0.8},
		close_sound = {filename = "__base__/sound/open-close/nuclear-close.ogg", volume = 0.8},
		working_sound =
		{
		  sound = sound_variations("__base__/sound/nuclear-reactor", 2, 0.55, volume_multiplier("main-menu", 0.8)),
		  max_sounds_per_prototype = 3,
		  fade_in_ticks = 4,
		  fade_out_ticks = 20
		},

		meltdown_action =
		{
		  type = "direct",
		  action_delivery =
		  {
			type = "instant",
			target_effects =
			{
			  {
				type = "create-entity",
				entity_name = "atomic-rocket-rampant"
			  }
			}
		  }
		},

		created_effect = 
		  -- {
			-- type = "cluster",
			-- cluster_count = 10,
			-- distance = 40,
			-- distance_deviation = 25,
			-- action_delivery =
			-- {
			  -- type = "projectile",
			  -- projectile = "atomic-rocket",
			  -- direction_deviation = 0.6,
			  -- starting_speed = 0.25,
			  -- starting_speed_deviation = 0.3
			-- }
		  -- },
		{
		  type = "direct",
		  action_delivery =
		  {
			{
				type = "instant",
				target_effects =
				{
				  {
					type = "script",
					effect_id = "fear-demolisher-rampant"
				  }
				}
			},	
			{
				type = "instant",
				target_effects =
				{
				  {
					type = "create-entity",
					entity_name = "atomic-rocket-rampant"
				  }
				}
			},
			{
				type = "instant",
				target_effects =
				{
				  {
					type = "nested-result",
					action = 
						{
							{
								type = "cluster",
								cluster_count = 10,
								distance = 60,
								distance_deviation = 45,
								action_delivery =
								{
								  type = "projectile",
								  projectile = "atomic-rocket-rampant",
								  direction_deviation = 0.6,
								  starting_speed = 0.25,
								  starting_speed_deviation = 0.3
								}
							},	
							{
								type = "cluster",
								cluster_count = 30,
								distance = 100,
								distance_deviation = 65,
								action_delivery =
								{
								  type = "projectile",
								  projectile = "explosive-rocket",
								  direction_deviation = 0.6,
								  starting_speed = 0.25,
								  starting_speed_deviation = 0.3
								}
							}
						}
				  }
				}
			},			
		  }
		},
		-- {
		  -- type = "direct",
		  -- action_delivery =
		  -- {
			-- type = "instant",
			-- target_effects =
			-- {
			  -- {
				-- type = "create-entity",
				-- entity_name = "atomic-rocket"
			  -- }
			-- }
		  -- }
		-- },
		
		default_temperature_signal = {type = "virtual", name = "signal-T"},
		circuit_wire_max_distance = reactor_circuit_wire_max_distance,
		circuit_connector = circuit_connector_definitions["nuclear-reactor"],
	  }
		,
	  {
		type = "item",
		name = "unstable-feeding-reactor-rampant",
		icons = {
			{icon = "__base__/graphics/icons/nuclear-reactor.png"},
			{icon = "__base__/graphics/icons/signal/signal-heart.png", scale = 0.25, shift = {10, 10}, size = 32}
			},
		subgroup = "ammo",
		order = "d[rocket-launcher]-a[basic]-[demolisher]2-[reactor]",
		place_result = "unstable-feeding-reactor-rampant",
		weight = 1 * tons,
		stack_size = 10
	  }
		,
	   {
		  type = "recipe",
		  category = "metallurgy",
		  name = "unstable-feeding-reactor-rampant",
		  energy_required = 10,
		  ingredients =
		  {
			{type = "item", name = "nuclear-reactor", amount = 1},
			{type = "item", name = "uranium-235", amount = 20},
			{type = "item", name = "demolisher-food-rocket-rampant", amount = 50}
		  },
		  results = {{type="item", name="unstable-feeding-reactor-rampant", amount=1}
		  },
		  main_product = "unstable-feeding-reactor-rampant",
		  allow_as_intermediate = false,
		  auto_recycle = false,
		  enabled = false
		}
		,
	  {
		type = "technology",
		name = "unstable-feeding-rampant",
		icons = {
			{icon = "__base__/graphics/icons/nuclear-reactor.png"},
			{icon = "__base__/graphics/icons/signal/signal-heart.png", scale = 0.25, shift = {10, 10}, size = 32}
			},
		effects =
		{
		  {
			type = "unlock-recipe",			
			recipe = "unstable-feeding-reactor-rampant"
		  }
		},
		prerequisites = {"demolisher-feeding-rampant", "nuclear-power"},
		unit =
		{
		  count = 50,
		  ingredients =
		  {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
			{"production-science-pack", 1},
			{"utility-science-pack", 1},
			{"space-science-pack", 1},
			{"metallurgic-science-pack", 1}
		  },
		  time = 60
		}
	  }
		
	  } 		
	)
end

demolisherUtilsG = demolisherUtils
return demolisherUtils

