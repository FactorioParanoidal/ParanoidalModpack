require "prototypes.constants"

function getShieldValues(size, rate)
	if DEBUG then
		log("debug getShieldValues " .. size .. " " .. rate)
	end
	local energy_consumption_multiplier
	local base_shield_val
	local base_shield_recharge
	local research_size_steps
	local research_speed_steps
	
	if global == nil then
		energy_consumption_multiplier = settings.startup["TS_energy_consumption_multiplier"].value
		base_shield_val = settings.startup["TS_base_shield"].value
		base_shield_recharge = settings.startup["TS_base_charge_rate"].value
		
		research_size_steps = settings.startup["TS_research_size"].value
		research_speed_steps = settings.startup["TS_research_speed"].value
	else
		energy_consumption_multiplier = global.energy_consumption_multiplier
		base_shield_val = global.base_shield_val
		base_shield_recharge = global.base_shield_recharge
		research_size_steps = global.research_size_steps
		research_speed_steps = global.research_speed_steps
	end

	--Assuming step_size is 5, 200 base shield.
	--For size 0: 200 * (10^ceiling((0+1)/5) - 200) / 5 ==> (200 * 10^1 - 200) / 5 ==> (2000 - 200) / 5
	--For size 4: 200 * (10^ceiling((4+1)/5) - 200) / 5 ==> (200 * 10^1 - 200) / 5 ==> (2000 - 200) / 5
	--For size 5: 200 * (10^ceiling((5+1)/5) - 200) / 5 ==> (200 * 10^2 - 200) / 5 ==> (20000 - 200) / 5
	local size_step_size = (base_shield_val * (10^math.ceil((size+1) / research_size_steps)) - base_shield_val) / research_size_steps
	local rate_step_size = (base_shield_recharge * (10^math.ceil((rate+1) / research_speed_steps)) - base_shield_recharge) / research_speed_steps
	
	--200 base shields, 5 steps per order of magnitude
	-- In this instance, size_step_size would be 360, 3960, 39960, etc.
	--For size 0: 200 + 360 * ((0 % 5) + 1) ==> 200 + 360 * 1 ==> 560
	--For size 4: 200 + 360 * ((4 % 5) + 1) ==> 200 + 360 * 5 ==> 2000
	--For size 5: 200 + 3960 * ((5 % 5) + 1) ==> 200 + 3960 * 1 ==> 4160
	local this_step_size_value = base_shield_val + size_step_size * ((size % research_size_steps) + 1)
	local this_step_rate_value = base_shield_recharge + rate_step_size * ((rate % research_speed_steps) + 1)
	
	if size == -1 then
		this_step_size_value = base_shield_val
	end
	if rate == -1 then
		this_step_rate_value = base_shield_recharge
	end
	
	return this_step_size_value * energy_consumption_multiplier, this_step_rate_value * energy_consumption_multiplier
end

function kts_print(str)
	game.print(str)
end

function printShieldStats(force)
	if DEBUG then
		log("debug printShieldStats " .. force.name)
	end
	
	capacity, recharge = getShieldValues(setResearchValues(force))
	local drain = (capacity / global.energy_consumption_multiplier) * global.power_usage
	local total_drain = drain * table_size(global.turrets)
	
	kts_print("Shield HP: " .. capacity / global.energy_consumption_multiplier .. " || Shield Recharge Rate (units/s): " .. recharge / global.energy_consumption_multiplier)
	kts_print("Shield Power Draw: " .. drain .. " kW (each) || " .. total_drain .. "kW (total)")
end

--Input is reference to global.turrets[<TURRET_ID>]
function updateShieldGraphics(global_turret, recent_damage, needs_recharge)
	if DEBUG then
		log("debug updateShieldGraphics")
	end
	
	if global_turret[HP_BAR] and rendering.is_valid(global_turret[HP_BAR]) then
		rendering.destroy(global_turret[HP_BAR])
	end
	
	local max_shield = global_turret[ELECTRIC_GRID_INTERFACE].electric_buffer_size
	local shieldHP = global_turret[ELECTRIC_GRID_INTERFACE].energy
	--The number of shield bubbles to display on the graphic
	local shield_bubble_amt
	local gfx_prefix = ""
	--How long should this graphic stick around. 0 = forever.
	local gfx_time_to_live = 0
	
	--Once the shield is charged, we stop showing the charge bar, we already removed it above, so we are done.
	if max_shield == shieldHP then
		gfx_time_to_live = 41
	end
	
	global_turret[ORIENTATION] = global_turret[TURRET_ENTITY].orientation
	
	--Fluid turrets in a certain orientation get a longer graphic...for some reason.
	if global_turret[TURRET_ENTITY].type == "fluid-turret" and  global_turret[ORIENTATION] % 0.5 ~= 0 then
		shield_bubble_amt = max_shield / SHIELD_STEPS_LONG
		gfx_prefix = "liquid-"
	else
		shield_bubble_amt = max_shield / SHIELD_STEPS_NORMAL
	end
	
	local num_shield_bubbles = math.floor(shieldHP / shield_bubble_amt)
	
	--debug
	--log("ShieldHP " .. shieldHP .. " Max shield " .. max_shield .. " num bubbles " .. num_shield_bubbles .. " turretid " .. global_turret[TURRET_ENTITY].unit_number .. " recharge " .. tostring(needs_recharge))
	
	local the_surface = global_turret[TURRET_ENTITY].surface
	local position = global_turret[TURRET_ENTITY].position
	
	global_turret[HP_BAR] = rendering.draw_animation({
		animation = gfx_prefix .. "square-" .. num_shield_bubbles,
		target = position,
		time_to_live = gfx_time_to_live,
		surface = the_surface
	})
	
	if global_turret[TURRET_ENTITY].name == "laser-turret" then
		position.y = position.y -0.16
		position.x = position.x +0.02					
	end
	
	if global_turret[TURRET_ENTITY].type == "fluid-turret" and global_turret[TURRET_ENTITY].orientation % 0.25 == 0 then
		if global_turret[TURRET_ENTITY].shooting_target ~= nil or global_turret[TURRET_ENTITY].orientation % 0.25 ~= 0 then
			table.insert(global.refresh_orientation,global_turret[TURRET_ENTITY])
		end
	
		if global_turret[TURRET_ENTITY].orientation == 0 then
			position.y = position.y+0.5
		elseif global_turret[TURRET_ENTITY].orientation == 0.25 then
			position.x = position.x-0.5
		elseif global_turret[TURRET_ENTITY].orientation == 0.5 then
			position.y = position.y-0.5
		elseif global_turret[TURRET_ENTITY].orientation == 0.75 then
			position.x = position.x+0.5
		end
	end
	
	if needs_recharge then
		--Shield just took a hit, it will need to recharge. This allows us to make that happen.
		global.needsGFXUpdate[global_turret[TURRET_ENTITY].unit_number] = true
	end
	
	local effect = ""
	if recent_damage then	
		if global.alternate_effect then
			if global_turret[SHIELD_VALUE_ON_LAST_TICK] == nil or global_turret[SHIELD_VALUE_ON_LAST_TICK] < game.tick-5 then
				if global_turret[SHIELD_EFFECT_ENTITY] ~= nil and global_turret[SHIELD_EFFECT_ENTITY].valid then
					effect = effect.."2"
					global_turret[SHIELD_EFFECT_ENTITY].destroy()
				end
				global_turret[SHIELD_EFFECT_ENTITY] = the_surface.create_entity{name = "shield-effect-alternate"..effect, position = {position.x-0.06, position.y -0.38}, force = "neutral"}
				global_turret[SHIELD_VALUE_ON_LAST_TICK] = game.tick
			end
		else
			the_surface.create_trivial_smoke{name="shield-effect"..effect, position = {position.x, position.y -0.48}}
		end
	end
end

--At the point this function is called, the entity has *already* taken damage to the hull. So if you had a 1000 HP turret that got hit for 120, it's HP, right now, is 880. 
function handleDamageEvent(event)
	if DEBUG then
		log("debug handleDamageEvent")
	end

	--Damage is a positive number (IE: 35 incoming dmg is '35' rather than '-35'.
	--We use original_damage_amount  instead of final_damage_amount because shields have no resists and the resists of the base entity (turret) already factored in to final_damage_amount.
	--Reminder: 1 unit of damage takes 1kj * modifier to disspiate, so multiply all dmg by 1000.
	local damage = event.original_damage_amount * global.energy_consumption_multiplier * 1000
	local issue_hull_damage = false
	
	--If some mod has an effect that heals with damage, we ignore that.
	if damage < 0 then return end
	
	--Ensure the turret still exists
	if not global.turrets[event.entity.unit_number] then
		return
	end
	
	--Now we figure out if we should apply hull damage due to the shield having been broken.
	if global.turrets[event.entity.unit_number].disabled_until and event.tick <= global.turrets[event.entity.unit_number].disabled_until then
		-- kts_print("Turret took Hull dmg " .. event.final_damage_amount .. " Current HP " .. event.entity.health .. " to " .. event.entity.unit_number)
		
		if event.entity.health <= 0 then
			destroy_turret(event.entity.unit_number)
		end
		
		--Important to prevent a single hull hit from destroying the entity! Prevents infinite loop.
		return
	end
		
	--The first thing we do is heal the turret back up past whatever damage it just took. If we need to do hull damage, we'll do that later.
	event.entity.health = event.entity.health + event.final_damage_amount
	
	--Assuming the damage didn't instantly hit the hull due to a broken shield, we now figure out if we can fully absorb the damage, or only partially absorb it.
	if global.turrets[event.entity.unit_number] then
		local shieldHP = global.turrets[event.entity.unit_number][ELECTRIC_GRID_INTERFACE].energy
		
		--We can only absorb a part of the damage.
		if damage >= shieldHP then
			damage = damage - shieldHP
			-- kts_print("Partial Shiled absorb. " .. shieldHP / (global.energy_consumption_multiplier * 1000))
			shieldHP = 0
			global.turrets[event.entity.unit_number].disabled_until = event.tick+SHIELD_BROKEN_REGEN_TIME
			issue_hull_damage = true
		else
			-- kts_print("Turret taking Shiled dmg " .. damage / (global.energy_consumption_multiplier * 1000) .. " Shield at " .. shieldHP / 2000 )
			shieldHP = shieldHP - damage
		end
		
		--Update the electric-energy-interface with the energy left (if any) after the damage was absorbed.
		global.turrets[event.entity.unit_number][ELECTRIC_GRID_INTERFACE].energy = shieldHP
		
		updateShieldGraphics(global.turrets[event.entity.unit_number], true, true)
	else
		init_turret(event.entity)
		return
	end
	
	if issue_hull_damage then
		--Remove the 1 dmg pt = 1kj and energy_consumption_multiplier factors
		damage = damage / (global.energy_consumption_multiplier * 1000)
	
		-- kts_print("Issuing rollover dmg " .. damage)
		--We use the API function to damage because that re-factors in the resists for us!
		--note: event.entity is the thing *being* hit, event.cause is the thing doing the hitting
		--note: This could create an infinite loop; it is important to have the shield briefly stop absorbing damage once broken so this actually hits the turret rather than the shield.
		if event.cause then
			event.entity.damage(damage, event.force, event.damage_type.name, event.cause)
		else
			--The bug that shot at us may be dead, thus, cause may be nil.
			event.entity.damage(damage, event.force, event.damage_type.name)
		end
	end
end

function setResearchValues(force)
	if DEBUG then
		log("debug setResearchValues " .. force.name)
	end

	local size_lvl
	local regen_lvl
	
	if not force.technologies["turret-shields-size"].enabled or force.technologies["turret-shields-size"].level == 1 then
		size_lvl = -1
	else
		size_lvl = force.technologies["turret-shields-size"].level - 2
	end
	if not force.technologies["turret-shields-speed"].enabled or force.technologies["turret-shields-speed"].level == 1 then
		regen_lvl = -1
	else
		regen_lvl = force.technologies["turret-shields-speed"].level - 2
	end

	return size_lvl, regen_lvl
end

function update_electricity(turretID)
	if DEBUG then
		log("debug update_electricity " .. turretID)
	end
	
	local old_energy
	local turret = global.turrets[turretID][TURRET_ENTITY]
	local position = global.turrets[turretID][TURRET_ENTITY].position
	local size_lvl
	local regen_lvl
	
	size_lvl, regen_lvl = setResearchValues(global.turrets[turretID][TURRET_ENTITY].force)

	if global.turrets[turretID][ELECTRIC_GRID_INTERFACE] and global.turrets[turretID][ELECTRIC_GRID_INTERFACE].valid then
		old_energy = global.turrets[turretID][ELECTRIC_GRID_INTERFACE].energy --energy currently in the buffer
		global.turrets[turretID][ELECTRIC_GRID_INTERFACE].destroy()
	else
		old_energy = 0
	end
	
	global.turrets[turretID][ELECTRIC_GRID_INTERFACE] = turret.surface.create_entity{name = "ts-electric-interface-"..size_lvl.."-"..regen_lvl, position = {position.x, position.y }, force = "neutral"}
	global.turrets[turretID][ELECTRIC_GRID_INTERFACE].destructible = false
	global.turrets[turretID][ELECTRIC_GRID_INTERFACE].energy = old_energy
end

function rescan_for_turrets(force)
	if not force.technologies["turret-shields-base"].researched then
		return
	end

	for key, surface in pairs(game.surfaces) do
		for i, turret in pairs(surface.find_entities_filtered{type= "ammo-turret", force}) do
			init_turret(turret)
		end
		for i, turret in pairs(surface.find_entities_filtered{type= "fluid-turret", force}) do
			init_turret(turret)
		end
		for i, turret in pairs(surface.find_entities_filtered{type= "electric-turret", force}) do
			init_turret(turret)
		end
	end
end

function init_turret(turret)
	if DEBUG then
		log("debug init_turret " .. turret.unit_number)
	end
	
	if ignored_entities[turret.name] then return end

	global.turrets[turret.unit_number]={game.tick,0}
	global.turrets[turret.unit_number].disabled_until = 0
	global.turrets[turret.unit_number][TURRET_ENTITY]=turret
		
	update_electricity(turret.unit_number)
	
	global.turrets[turret.unit_number][1] = game.tick
	global.turrets[turret.unit_number][SHIELD_VALUE_ON_PREVIOUS_TICK] = global.turrets[turret.unit_number][ELECTRIC_GRID_INTERFACE].energy
	global.turrets[turret.unit_number][DMG_SINCE_LAST_TICK] = 0
	
	global.electric_updater[turret.unit_number] = 0
	global.e_updater_size = table_size(global.electric_updater)
	global.e_updater_disconnected_size = table_size(global.electric_updater_disconnected)

	updateShieldGraphics(global.turrets[turret.unit_number], false, true)
end

function refresh_hpbars()
	if DEBUG then
		log("debug refresh_hpbars")
	end
	
	global.needsGFXUpdate = {}
	for key, tbl in pairs(global.turrets) do
		if tbl[TURRET_ENTITY] and tbl[TURRET_ENTITY].valid then
			global.needsGFXUpdate[tbl[TURRET_ENTITY].unit_number] = true
		end
	end
end

function remove_hpbars()
	if DEBUG then
		log("debug remove_hpbars")
	end
	
	for key, surface in pairs(game.surfaces) do
		for i=0,9 do
			for key, entity in pairs(surface.find_entities_filtered{name= "square-"..i}) do
				entity.destroy()
			end
		end
		for i=0,13 do
			for key, entity in pairs(surface.find_entities_filtered{name= "liquid-square-"..i}) do
				entity.destroy()
			end
		end
	end
end

function remove_energy(force)
	if DEBUG then
		log("debug remove_energy")
	end
	
	for key, surface in pairs(game.surfaces) do
		for key, entity in pairs(surface.find_entities_filtered{type= "electric-energy-interface", force}) do
			if string.sub(entity.name,1,22) == "ts-electric-interface-" then
				entity.destroy()
			end
		end
	end
end

function more_shields_than_turrets_fix()
	local num_shields = 0
	local num_turrets = 0
	
	for k, force in pairs (game.forces) do	
		for key, surface in pairs(game.surfaces) do
			for key, entity in pairs(surface.find_entities_filtered{type= "electric-energy-interface", force}) do
				if string.sub(entity.name,1,22) == "ts-electric-interface-" then
					num_shields = num_shields + 1
				end
			end
			for i, turret in pairs(surface.find_entities_filtered{type= "ammo-turret", force}) do
				num_turrets = num_turrets + 1
			end
			for i, turret in pairs(surface.find_entities_filtered{type= "fluid-turret", force}) do
				num_turrets = num_turrets + 1
			end
			for i, turret in pairs(surface.find_entities_filtered{type= "electric-turret", force}) do
				num_turrets = num_turrets + 1
			end
		end
		if num_shields > num_turrets then
			kts_print("Fixing duplicate shields problem for " .. force.name .. ". Found " .. num_shields .. " shields for " .. num_turrets .. " turrets. Sorry about the recharge.")
			remove_energy(force)
			rescan_for_turrets(force)
		else
			kts_print("Shield and turret counts match for " .. force.name .. ". Nothing to fix.")
		end
		num_shields = 0
		num_turrets = 0
	end
end

function refresh_everything()
	game.print("refreshing all turret shields")
	global.iterate_turrets = nil
	global.iterate_e_updater = nil
	global.iterate_e_updater_disconnected = nil
	
	global.turrets= {}
	global.updater = {}
	global.electric_updater = {}
	global.electric_updater_disconnected = {}
	global.refresh_orientation = {}
	global.forces = {}
	global.needsGFXUpdate = {}
	for k, force in pairs (game.forces) do
		global.forces[force.name] = {}
		remove_energy(force)
	end
	refresh_hpbars()
	
	global.base_shield_val = settings.startup["TS_base_shield"].value
	global.base_shield_recharge = settings.startup["TS_base_charge_rate"].value
	global.research_size_steps = settings.startup["TS_research_size"].value
	global.research_speed_steps = settings.startup["TS_research_speed"].value
	global.energy_consumption_multiplier = settings.startup["TS_energy_consumption_multiplier"].value
	global.power_drain_pct = settings.startup["TS_power_drain"].value/100
	
	global.research_enabled = settings.global["TS_research_enabled"].value
	global.alternate_effect = settings.global["TS_alternate_effect"].value
	
	for _, force in pairs (game.forces) do
		update_force(force)
	end
end

function setTechAndRecipes(force)
	if DEBUG then
		log("debug setTechAndRecipes " .. force.name)
	end
	
	if not global.research_enabled then
		force.technologies["turret-shields-base"].researched = true
		force.technologies["turret-shields-base"].enabled = false
		force.recipes["ts-shield-disabler"].enabled = true
		force.recipes["turret-shield-combinator"].enabled = true
		force.technologies["turret-shields-size"].enabled = false
		force.technologies["turret-shields-speed"].enabled = false
		global.forces[force.name].research_speed_lvl = -1
		global.forces[force.name].research_size_lvl = -1
	else
		force.technologies["turret-shields-base"].enabled = true
		force.technologies["turret-shields-size"].enabled = true
		force.technologies["turret-shields-speed"].enabled = true
		global.forces[force.name].research_speed_lvl = force.technologies["turret-shields-speed"].level - 2
		global.forces[force.name].research_size_lvl = force.technologies["turret-shields-size"].level - 2
		
		if force.technologies["turret-shields-base"].researched then
			force.recipes["ts-shield-disabler"].enabled = true
			force.recipes["turret-shield-combinator"].enabled = true
		end
	end
end

function update_force(force)
	if DEBUG then
		log("debug update_force " .. force.name)
	end

	if global.forces[force.name] == nil then
		global.forces[force.name] = {}
	end
	
	setTechAndRecipes(force)
end

function update_electricity_force(force)
	if DEBUG then
		log("debug update_electricity_force " .. force.name)
	end

	if global.forces[force.name] == nil then
		global.forces[force.name] = {}
	end
	
	if global.research_enabled and force.technologies["turret-shields-base"].researched then
		global.forces[force.name].enabled = true
	elseif global.research_enabled and not force.technologies["turret-shields-base"].researched then
		global.forces[force.name].enabled = false
	else
		global.forces[force.name].enabled = true
	end
	
	update_force(force)
	
	for key, tbl in pairs(global.turrets) do
		if tbl[TURRET_ENTITY] and tbl[TURRET_ENTITY].valid and tbl[TURRET_ENTITY].force.name == force.name then
			update_electricity(tbl[TURRET_ENTITY].unit_number)
			updateShieldGraphics(tbl, false, true)
		end
	end
end

function destroy_turret(key)
	if DEBUG then
		log("debug destroy_turret " .. key)
	end
	
	if global.turrets[key] then
		--if global.turrets[key].fx then global.turrets[key].fx.destroy() end
		if global.turrets[key][HP_BAR] then rendering.destroy(global.turrets[key][HP_BAR]) end
		if global.turrets[key][ELECTRIC_GRID_INTERFACE] then global.turrets[key][ELECTRIC_GRID_INTERFACE].destroy() end
		--if global.turrets[key].disabled then global.turrets[key].disabled.destroy() end
		if global.iterate_turrets == key then
			global.iterate_turrets = next(global.turrets, key)
		end
		global.turrets[key] = nil
	end
	if key == global.iterate_e_updater then
		global.iterate_e_updater = next(global.electric_updater, key)
	end
	global.iterate_e_updater = nil
	if key == global.iterate_e_updater_disconnected then
		global.iterate_e_updater_disconnected = next(global.electric_updater_disconnected, key)
	end
	
	global.electric_updater_disconnected[key] = nil
	global.electric_updater[key] = nil
	global.needsGFXUpdate[key] = nil

	global.e_updater_size = table_size(global.electric_updater)
	global.e_updater_disconnected_size = table_size(global.electric_updater_disconnected)
end

function b2s(bool)
if bool then return "true" else return "false" end
end

function toggle_shield(turret,onoff)
	if DEBUG then
		log("debug toggle_shield " .. turret.unit_number .. " " .. onoff)
	end

	if not onoff and not global.disabled_turrets[turret.unit_number] then
		global.disabled_turrets[turret.unit_number] = {}
		global.disabled_turrets[turret.unit_number][1] = turret.surface.create_entity{name = "ts-unplugged", position = {turret.position.x, turret.position.y}, force = "neutral"}
		global.disabled_turrets[turret.unit_number][SHIELD_VALUE_ON_PREVIOUS_TICK] = turret
		if global.turrets[turret.unit_number] and global.turrets[turret.unit_number][HP_BAR] and is_valid(global.turrets[turret.unit_number][HP_BAR]) then
			rendering.destroy(global.turrets[turret.unit_number][HP_BAR])
			global.needsGFXUpdate[turret.unit_number] = nil
		end
		if global.turrets[turret.unit_number] and global.turrets[turret.unit_number][ELECTRIC_GRID_INTERFACE] and global.turrets[turret.unit_number][ELECTRIC_GRID_INTERFACE].valid then
			global.turrets[turret.unit_number][ELECTRIC_GRID_INTERFACE].destroy()
		end
		global.turrets[turret.unit_number]=nil
	elseif onoff and global.disabled_turrets[turret.unit_number] then
		global.disabled_turrets[turret.unit_number][1].destroy()
		global.disabled_turrets[turret.unit_number] = nil
		global.needsGFXUpdate[turret.unit_number] = nil
		init_turret(turret)
	end
end