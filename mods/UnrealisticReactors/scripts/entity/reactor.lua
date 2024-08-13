local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local Setting = require(rroot .. "setting")
local ruin = require(rpath .. "ruin")
local fallout = require(rpath .. "fallout")
local network = require(rroot .. "heat.network")
local FORMULA = require(rroot .. "formulas")
local msg = require(rroot .. "util").msg
local util = require(rpath .. "util")
local find_nuclear_ghost  = util.find_nuclear_ghost
local create_warning = util.create_warning


local function Signals() return { parameters = { -- signals for interface
	["core_temperature"  ] = {signal=SIGNAL_CORE_TEMP,    count=TEMPERATURE, index=1},
	["state_stopped"     ] = {signal=SIGNAL_STATE_STOPPED,          count=1, index=2},
	["state_starting"    ] = {signal=SIGNAL_STATE_STARTING,         count=0, index=3},
	["state_running"     ] = {signal=SIGNAL_STATE_RUNNING,          count=0, index=4},
	["state_scramed"     ] = {signal=SIGNAL_STATE_SCRAMED,          count=0, index=5},
	["coolant-amount"    ] = {signal=SIGNAL_COOLANT_AMOUNT,         count=0, index=6},
	["power-output"      ] = {signal=SIGNAL_REACTOR_POWER_OUTPUT,   count=0, index=7},
	["uranium-fuel-cells"] = {signal=SIGNAL_URANIUM_FUEL_CELLS,     count=0, index=8},
	--["used-uranium-fuel-cells"] = {signal=SIGNAL_USED_URANIUM_FUEL_CELLS, count=0, index=9},
	["efficiency"        ] = {signal=SIGNAL_REACTOR_EFFICIENCY,     count=0, index=10},
	["cell-bonus"        ] = {signal=SIGNAL_REACTOR_CELL_BONUS,     count=0, index=11},
	["electric-power"    ] = {signal=SIGNAL_REACTOR_ELECTRIC_POWER, count=0, index=12},
	["neighbour-bonus"   ] = {signal=SIGNAL_NEIGHBOUR_BONUS,        count=0, index=13},
} } end


-- adds core, eccs, lamp, light, electric interface to the reactor core when it is build
local function add_reactor(entity,interface)
	local surface = entity.surface
	local p,f = entity.position,entity.force
	local reactor_core = surface.create_entity{
		name = "realistic-reactor-1",
		position = p,
		force = f,
	}
	--reactor is actually the reactor core
	reactor_core.destructible = false
	--logging("---------------------------------------------------------------")
	--logging("Adding new reactor: "..entity.name)
	--logging("Reactor core ID: " .. reactor_core.unit_number)
	--interface.operable = false
	interface.destructible = false
	interface.minable = false

	--logging("Reactor ID: " .. interface.unit_number)

	--add the eccs
	local eccs = surface.create_entity{
		name = BOILER_ENTITY_NAME,
		position = p,
		force = f,
	}
	eccs.operable = false
	eccs.destructible = false
	eccs.minable = false

	--add power entity
	local power = surface.create_entity{
		name = POWER_NAME[entity.name],
		position = p,
		force = f,
	}
	power.destructible = false
-- 	power.energy = math.max(0,(1.5-Setting.map("energy-consumption-multiplier"))) * entity.electric_buffer_size
	--add light
	local reactor_lamp = surface.create_entity{
		name = "rr-black-lamp",
		position = {p.x+0.017,p.y+0.88},
		force = f,
	}
	local reactor_light = surface.create_entity{
		name = "rr-black-light",
		position = {p.x+0.017,p.y+0.88},
		force = f,
	}
	reactor_lamp.destructible = false
	reactor_light.destructible = false

	-- reactor is not active when it is build (state=stopped)
	reactor_core.active = false

	--max power for gui
	if Setting.ingos_formula() then
		reactor_max_power = 123
		reactor_max_efficiency = 200
	elseif Setting.ownlys_formula() then
		reactor_max_power = 250
		reactor_max_efficiency = 210
	else
		error("formula missing")
	end
	local reactor = {
		id = entity.unit_number, -- ID of the reactor (doesn't change)
		core_id = reactor_core.unit_number, -- ID of the core (changes when core is replaced)
		core = reactor_core, -- core entity
		interface = interface, -- interface entity
		eccs = eccs, -- eccs entity
		power = power, -- power entity
		entity = entity, -- displayer entity
		position = reactor_core.position, -- core position = reactor position
		state = 0, -- reactor state
		state_active_since = game.tick, -- state begin
		neighbours = 1, -- number of connected reactors and itself
		control = interface.get_or_create_control_behavior(), -- control behaviour for interface signals
		efficiency = 0, -- reactor efficiency
		bonus_cells = {}, -- list of bonus cell amount for breeder
		cooling_history = 0, -- average power loss through cooling in the last TICKS_PER_UPDATE*8 ticks
		lamp = reactor_lamp, --reactor lamp dummy
		light = reactor_light, --light dummy for the lamp
		interface_warning_tick = 0, --last tick an electricity warning was displayed on the interface (for imitating the game's behaviour)
		interface_warning = nil, --electricity warning dummy (interface)
		cooling_warning_tick = 0, --last tick an electricity warning was displayed on the cooling
		cooling_warning = nil, --electricity warning dummy (cooling)
		power_usage = {starting = 0,cooling = 0, interface = 0}, --portions of the power consumption
		last_states_update = game.tick,
		fuel_last_tick = 0, -- fuel value in the core on last tick
		--fluid_amount_last_tick = 0, -- fluid amount in eccs on last tick
		power_output_last_tick = 0, --power output in MW on last tick (only updated in start or running phase)
		last_temp_update = game.tick,
		max_power = reactor_max_power, --dynamic maximum value for gui
		max_efficiency = reactor_max_efficiency, --dynamic maximum value for gui
		signals = Signals(),
	}
	global.reactors[reactor.id] = reactor
	reactor.core.get_fuel_inventory().insert{name="rr-dummy-fuel-cell", count = 50}
	reactor.control.parameters = reactor.signals.parameters
	--logging("-> reactor successfully added")
	--logging("")
	return reactor
end

local function reactor_meltdown(surface, position, tick)
	-- do the meltdown explosion
	surface.create_entity{
		name = "medium-explosion",
		position = position,
	}
	--create radiation and cloud
	fallout.create(surface, position, tick)
end

-- removes other reactor parts when its reactor core is removed
local function remove_reactor(entity, tick, has_died)
	local reactor = global.reactors[entity.unit_number]
	local dead_reactor_name = reactor.entity.name
	local current = {surface=entity.surface,position=entity.position,force=entity.force}
	local meltdown = Setting.meltdown()

	-- cause meltdown?
	if reactor.state ~= 0 then
		current.surface.pollute(current.position, 150000) --0.006 evo @ 0.80
		--if game.forces["enemy"] then
		--	game.forces["enemy"].evolution_factor=math.min(1,game.forces["enemy"].evolution_factor+0.007)
		--end
		-- working reactor destroyed, causing meltdown
		if meltdown then
			reactor_meltdown(current.surface, current.position, tick)
		else
			reactor.entity.destroy() -- to make space for dummy
			local dummy = current.surface.create_entity{
				name = "realistic-reactor",
				position = current.position,
				force = "enemy",
			}
			current.surface.create_entity{
				type = "projectile",
				name = Setting.map("explosion-mode"),
				position = current.position,
				force = current.force,
				target = dummy,
				max_range = 23,
				speed = 0.1,
			}
		end
	end --meltdown

	-- create reactor ruin
	if has_died and reactor.state ~= 0 then
		reactor.interface.destroy() -- remove interface entity
		if meltdown then
			reactor.entity.destroy() --only destroy when there should not remain a ghost
			ruin.add(dead_reactor_name, current)
		end
	else
		reactor.interface.destroy() -- remove interface entity
	end

	--remove other stuff
	if reactor.power.valid then reactor.power.destroy() end -- remove power entity
	if reactor.eccs.valid then reactor.eccs.destroy() end -- remove eccs
	if reactor.core.valid then reactor.core.destroy() end
	if reactor.lamp.valid then reactor.lamp.destroy() end
	if reactor.light.valid then reactor.light.destroy() end
	if reactor.interface_warning and reactor.interface_warning.valid then reactor.interface_warning.destroy() end
	if reactor.cooling_warning and reactor.cooling_warning.valid then reactor.cooling_warning.destroy() end

	--remove global table entry
	global.reactors[reactor.id] = nil
end


-- replaces the reactor core entity with another one
local function replace_reactor_core(reactor, new_reactor_entity_name)
	local temp = reactor.core.temperature
	--logging("Building reactor model: "..new_reactor_entity_name)

	--logging("- old reactor ID: " .. reactor.id)
	--logging("- old reactor core ID: " .. reactor.core_id)

	-- create new reactor core
	local new_reactor_core = reactor.core.surface.create_entity{
		name = new_reactor_entity_name,
		position = reactor.core.position,
		force = reactor.core.force,
		create_build_effect_smoke = false,
	}
	--logging("- new reactor core ID: " .. new_reactor_core.unit_number)

	-- copy everything from old core to new core
	new_reactor_core.copy_settings(reactor.core) --(what is this actually copying???) -- on/off state for example
	new_reactor_core.temperature = temp
	new_reactor_core.destructible = false
	--logging("-> updated temperature: " .. new_reactor_core.temperature)
	-- transfer burner heat and remaining fuel in burner

	--if reactor.state == 0 and not (Setting.behavior("scram") == "stop-half-empty") then
	--	-- do nothing (don't transfer burner heat to a stopped or scramed reactor)
	--	if Setting.behavior("scram") == "consume-additional-cell" and reactor.entity.burner.currently_burning then
	--		reactor.entity.get_burnt_result_inventory().insert({name = reactor.entity.burner.currently_burning.burnt_result.name, count = 1})
	--		reactor.entity.burner.currently_burning = nil
	--	end
    --
	--	--logging("-> burner settings not transferred, state: stopped or scramed")
	--else
	--	-- transfer current burner settings
	--	--if reactor.core.burner.heat > 0 then --not reliable!
	--	if reactor.entity.burner.remaining_burning_fuel > 0 then
			--new_reactor_core.burner.currently_burning = game.item_prototypes["uranium-fuel-cell"]
			--new_reactor_core.burner.currently_burning = reactor.entity.burner.currently_burning
			new_reactor_core.burner.currently_burning = "rr-dummy-fuel-cell"
			new_reactor_core.burner.remaining_burning_fuel = 9223372035000000000
			new_reactor_core.burner.heat = reactor.entity.burner.heat
			--logging("-> updated burner heat: " .. new_reactor_core.burner.heat)
			--new_reactor_core.burner.remaining_burning_fuel = reactor.entity.burner.remaining_burning_fuel
			--logging("-> updated burner remaining_burning_fuel: " .. new_reactor_core.burner.remaining_burning_fuel)
	--	else
	--		--logging("-> burner settings not transferred, empty")
	--	end
	--end

	new_reactor_core.minable = false -- core should be unminable in any case cause its removed via script

	new_reactor_core.get_fuel_inventory().insert{name="rr-dummy-fuel-cell", count = 50}


	-- destroy old core
	reactor.core.destroy()
	-- store new core
	reactor.core = new_reactor_core
	--update reactor core id with new core unit_number
	reactor.core_id = new_reactor_core.unit_number

	--logging("-> reactor replaced")
	--logging("- new reactor ID: " .. reactor.id)
	--logging("- new reactor core ID: " .. reactor.core_id)
end

local function update_reactor_signals(reactor, tick)
	local inventory = reactor.entity.get_fuel_inventory()
	local cells = reactor.signals.parameters["uranium-fuel-cells"]
	if inventory.is_empty() or reactor.entity.status == defines.entity_status.full_output then
		cells.count = 0
		cells.signal = {type="item", name="uranium-fuel-cell"}
	else
		cells.signal = {type="item", name=inventory[1].name}
		cells.count = inventory[1].count
	end
	-- destroy energy warning entity
	if game.tick - reactor.interface_warning_tick >=60  and reactor.interface_warning and reactor.interface_warning.valid then
		reactor.interface_warning.destroy()
	end
	reactor.signals.parameters["core_temperature"].count = reactor.core.temperature

	local fluid = reactor.eccs.fluidbox[1]
	if fluid then
		reactor.signals.parameters["coolant-amount"].count = fluid.amount
	else
		reactor.signals.parameters["coolant-amount"].count = 0
	end
	-- check if interface has enough power
	if reactor.power.energy >= (POWER_USAGE_INTERFACE * TICKS_PER_UPDATE / 60* Setting.map("energy-consumption-multiplier")) then   --- TICKS_PER_UPDATE // TODO: compare with correct power usage (not critical)
		-- show updated signals on interface

		reactor.signals.parameters["electric-power"].count = (reactor.power.energy/reactor.power.electric_buffer_size)*100
		reactor.control.parameters = reactor.signals.parameters

		-- apply power consumption for interface
		reactor.power_usage.interface = math.floor(POWER_USAGE_INTERFACE/60)
	else
		reactor.power_usage.interface = 0
		-- disable interface signals
		--reactor.control.parameters = {parameters={}}
-- 		reactor.control.parameters = {}
		reactor.control.parameters = Signals().parameters

		-- show energy warning entity
		if game.tick - reactor.interface_warning_tick >= 120 then
			reactor.interface_warning = create_warning(reactor.interface, "electricity")
			reactor.interface_warning_tick = game.tick
		end
	end
end

local function update_reactor_temperature(reactor, tick)
	local powerusagecooling = POWER_USAGE_COOLING
	local time_passed = math.max(1,tick - reactor.last_temp_update)
	reactor.last_temp_update = tick
	local change_mult = CHANGE_MULTIPLIER * (time_passed / 15)
	local reactor_core_temperature = reactor.core.temperature
	local reactor_state = reactor.state
	local powersignal = reactor.signals.parameters["power-output"].count
	local reactor_efficiency = reactor.efficiency
	local reactor_power_energy = reactor.power.energy

	--apply efficiency by adding a fuel bonus
	if reactor_efficiency > 0 then
		local fuel_consumption = (powersignal/60*1000000)*(time_passed)*(100/reactor_efficiency)
		local reactor_entity_burner_remaining_burning_fuel = reactor.entity.burner.remaining_burning_fuel

		if reactor_entity_burner_remaining_burning_fuel - fuel_consumption > 0 then
			reactor.entity.burner.remaining_burning_fuel = reactor_entity_burner_remaining_burning_fuel - fuel_consumption
		else
			reactor.entity.burner.remaining_burning_fuel = 0
		end

	else
		--no fuel bonus, efficiency=0 (reactor stopped)
	end

	--apply starting power consumption
	if reactor_state == 1 then
		--apply cooling power consumption
		reactor.power_usage.starting = math.floor(POWER_USAGE_STARTING / 60)
	else
		reactor.power_usage.starting = 0
	end

	-- do environment cooling if state is stopped
	if reactor_state == 0 then
		if reactor_core_temperature > 15 then
			--logging("Reactor state is stopped, apply cooling by the environment")

			--[[
			local Tmix_env = ((reactor_core_temperature * REACTOR_MASS) + (15 * 10000)) / (REACTOR_MASS + 10000)
			--logging("Tmix_env: " .. Tmix_env)
			local Tdelta_reactor_env = reactor_core_temperature - Tmix_env
			--logging("Tdelta_reactor_env: " .. Tdelta_reactor_env)
			local Tchange_reactor_env = (Tdelta_reactor_env * change_mult * 0.1)
			--logging("-> Tchange_reactor_env: " .. Tchange_reactor_env)
			if (reactor_core_temperature - Tchange_reactor_env) > 15 then
				reactor.core.temperature = reactor_core_temperature - Tchange_reactor_env
				reactor_core_temperature = reactor_core_temperature - Tchange_reactor_env
			else
				reactor.core.temperature = 15
				reactor_core_temperature = 15
			end
			]]

			if reactor_core_temperature > 15.125 then
				reactor_core_temperature = reactor_core_temperature - 0.125 * (time_passed / 15)
			else
				reactor_core_temperature = 15
			end

			--logging("Reactor core temperature after environment cooling: " .. reactor_core_temperature)
		end
	end

	-- do decay heat effect if state is scramed
	if reactor_state == 3 and Setting.behavior("scram") == "decay-heat-v1" then
		reactor_core_temperature = reactor_core_temperature + powersignal/20
	end

	reactor.power_usage.cooling = 0 -- supposed to be overwritten
	local cooling_history = reactor.cooling_history
	cooling_history = cooling_history*7/8 --devaluing previous history (only used by graph)

	--remove cooling power alert (gfx)
	if game.tick - reactor.cooling_warning_tick >= 60 and reactor.cooling_warning and reactor.cooling_warning.valid then
		reactor.cooling_warning.destroy()
	end

	-- check fluid level in eccs and calculate temperature changes
	local fluid = reactor.eccs.fluidbox[1]
	local Tchange_reactor = 0
	local Tchange_fluid = 0

	if fluid == nil then
		--do nothing, no coolant
		reactor.signals.parameters["coolant-amount"].count = 0

	else
		--reactor has coolant

		local fluid_temperature = fluid.temperature
		local fluid_amount = fluid.amount

		reactor.signals.parameters["coolant-amount"].count = fluid_amount

		if fluid_amount < 100 then
			--do nothing, not enough coolant

		else

			--calculate the mixing temperature with richmann's mixing rule
			local Tmix = ((reactor_core_temperature * REACTOR_MASS) + (fluid_amount * fluid_temperature)) / (REACTOR_MASS + fluid_amount)

			-- check which is hotter and cool/heat accordingly
			local Tdelta_reactor = reactor_core_temperature - Tmix
			local Tdelta_fluid = fluid_temperature - Tmix

			if Tdelta_reactor > Tdelta_fluid then
				-- reactor is hotter than fluid (that is how it should be)

				Tchange_reactor = (Tdelta_reactor * change_mult)
				Tchange_fluid = (Tdelta_fluid * change_mult)

				if fluid_temperature - Tchange_fluid > 100 then
					-- resulting fluid would be too hot (max 100°, set by game)

					--reduce both temperature changes by the same factor, so that resulting fluid is = 100°
					efficiency_factor = (100 - fluid_temperature) / (Tdelta_fluid * change_mult * -1)
					Tchange_reactor = (Tchange_reactor * efficiency_factor)
					Tchange_fluid = (Tchange_fluid * efficiency_factor)

				end

			else
				-- fluid is hotter than reactor (it's possible to heat the reactor with a hot fluid)

				Tchange_reactor = (Tdelta_reactor * change_mult)
				Tchange_fluid = (Tdelta_fluid * change_mult)

				if reactor_core_temperature - Tchange_reactor > 100 then
					Tchange_reactor = 0
					Tchange_fluid = 0
					--do nothing, reactor is already 100°
					-- this is necessary, because theoretically it would be possible to heat the reactor with steam to 1000°, thus causing the meltdown

				end

			end


			-- --save the fluid back to the eccs
			-- fluid.temperature = fluid_temperature
			-- fluid.amount = fluid_amount
			-- reactor.eccs.fluidbox[1] = fluid

		end -- not enough coolant


		--do the actual cooling
		local cooled = true
		if Tchange_reactor ~= 0 then
			if Setting.map("static-cooling-power-consumption") then
				-- static cooling power consumption

				if reactor_power_energy < (powerusagecooling * time_passed / 60* Setting.map("energy-consumption-multiplier")) then
					-- not enough energy - don't cool
					cooled = false
				else
					-- cool/heat the core and the fluid
					reactor_core_temperature = reactor_core_temperature - Tchange_reactor
					fluid_temperature = fluid_temperature - Tchange_fluid
					-- cooling power consumption
					if Tchange_reactor>0.1 then
						reactor.power_usage.cooling = math.floor(powerusagecooling / 60)
					end
					cooling_history = cooling_history + (Tchange_reactor * 20 / 8/ (time_passed/15))
				end
			else
				local max_cooling = reactor_power_energy / (powerusagecooling * time_passed / 60* Setting.map("energy-consumption-multiplier"))
				local cooling_mult = 1
				if max_cooling < math.abs(Tchange_reactor) then
					cooled = false
					cooling_mult = max_cooling/math.abs(Tchange_reactor)
				end
				cooling_history = cooling_history + (Tchange_reactor * cooling_mult * 20 / 8/ (time_passed/15))
				reactor_core_temperature = reactor_core_temperature - Tchange_reactor * cooling_mult
				--cool the fluid
				fluid_temperature = fluid_temperature - Tchange_fluid * cooling_mult

				--cooling power consumption

				--dynamic cooling power consumption
				reactor.power_usage.cooling = math.floor(Tchange_reactor * cooling_mult * powerusagecooling / 60 / (time_passed/15))
				cooling_history = cooling_history + reactor.power_usage.cooling*60/1000000/8* Setting.map("energy-consumption-multiplier")

			end

		end

		--save the fluid back to the eccs
		fluid.temperature = fluid_temperature
		fluid.amount = fluid_amount
		reactor.eccs.fluidbox[1] = fluid

		if not cooled then
			-- core wasn't cooled - show energy warning signal
			if game.tick - reactor.cooling_warning_tick >= 120 then
				reactor.cooling_warning = create_warning(reactor.entity, "cooling")
				reactor.cooling_warning_tick = game.tick
			end
		end

	end --empty eccs


	reactor.cooling_history = cooling_history

	-- update reactor signals
	reactor.signals.parameters["electric-power"].count = (reactor_power_energy/reactor.power.electric_buffer_size)*100

	-- set power usage value of power entity
	reactor.power.power_usage = (reactor.power_usage.starting + reactor.power_usage.cooling + reactor.power_usage.interface) * Setting.map("energy-consumption-multiplier")

	-- start nuclear meltdown
	if reactor_core_temperature >= DYING_REACTOR_CORE_TEMPERATURE then
		--logging("Core temperature > 1000°, MELTDOWN")
		-- destroy the reactor core (will trigger meltdown)
		reactor.entity.die()
	else
		reactor.core.temperature = reactor_core_temperature
	end

end


-- changes reactor state
local function change_reactor_state(new_state, reactor, tick)
	--logging("-> changing reactor state to: " .. new_state)
	reactor.state = new_state
	reactor.state_active_since = tick
	reactor.lamp.destroy()
	reactor.light.destroy()
	local light_color = "black"
	if new_state == 0 then
		-- set signals
		reactor.signals.parameters["state_stopped"].count = 1
		reactor.signals.parameters["state_starting"].count = 0
		reactor.signals.parameters["state_running"].count = 0
		reactor.signals.parameters["state_scramed"].count = 0
		-- configure reactor
		replace_reactor_core(reactor,"realistic-reactor-1")
		reactor.entity.active = false
		reactor.core.active = false
		reactor.entity.minable = true
	elseif new_state == 1 then
		--set signals
		reactor.signals.parameters["state_stopped"].count = 0
		reactor.signals.parameters["state_starting"].count = 1
		reactor.signals.parameters["state_running"].count = 0
		reactor.signals.parameters["state_scramed"].count = 0
		-- configure reactor
		reactor.entity.active = true
		reactor.core.active = true
		--reactor.debug_start_cell = true
		reactor.entity.minable = false
		light_color = "yellow"
	elseif new_state == 2 then
		-- set signals
		reactor.signals.parameters["state_stopped"].count = 0
		reactor.signals.parameters["state_starting"].count = 0
		reactor.signals.parameters["state_running"].count = 1
		reactor.signals.parameters["state_scramed"].count = 0
		-- configure reactor
		reactor.entity.active = true
		reactor.core.active = true

		reactor.entity.minable = false
		light_color = "green"
	elseif new_state == 3 then
		--set signals
		reactor.signals.parameters["state_stopped"].count = 0
		reactor.signals.parameters["state_starting"].count = 0
		reactor.signals.parameters["state_running"].count = 0
		reactor.signals.parameters["state_scramed"].count = 1
		-- configure reactor
		if Setting.behavior("scram") == "decay-heat-v1" then
			reactor.core.active = false
			reactor.entity.active = false
			if reactor.entity.burner.currently_burning then
				reactor.entity.get_burnt_result_inventory().insert({name = reactor.entity.burner.currently_burning.burnt_result.name, count = 1})
			end
			reactor.entity.burner.currently_burning = nil
			reactor.entity.burner.remaining_burning_fuel = 0
		else
			reactor.core.active = true
			reactor.entity.active = true
		end
		reactor.entity.minable = false
		light_color = "red"
	end
	local p = reactor.core.position
	reactor.lamp = reactor.core.surface.create_entity{
		name = "rr-"..light_color.."-lamp",
		position = {p.x+0.017,p.y+0.88},
		force = reactor.core.force.name,
	}
	reactor.light = reactor.core.surface.create_entity{
		name = "rr-"..light_color.."-light",
		position = {p.x+0.017,p.y+0.88},
		force = reactor.core.force.name,
	}
	reactor.lamp.destructible = false
	reactor.light.destructible = false
end


local function update_reactor_states(reactor, tick)
	--logging("---")
	--logging("Updating reactor ID: " .. reactor.id)
	--logging("Reactor core ID: " .. reactor.core_id)
	--logging("Reactor type: ".. reactor.entity.name)
	--logging("Reactor model: " .. reactor.core.name)
	--logging("Reactor state: " .. reactor.state)
	local running_time = math.ceil((tick - reactor.state_active_since)/60)
	--logging("-> state active for (s): " .. running_time)


	-- get control signals
	--logging("Checking circuit network signals")
	local signal_start = false
	local signal_scram = false
	for _,wire in ipairs{defines.wire_type.green, defines.wire_type.red} do
		local network = reactor.control.get_circuit_network(wire)
		if network then
			--logging("-> Found circuit network. Network ID: " .. network.network_id)
			if network.get_signal(SIGNAL_CONTROL_SCRAM) > 0 then
				signal_scram = true
				--logging("--> found SCRAM signal")
			elseif network.get_signal(SIGNAL_CONTROL_START) > 0 then
				signal_start = true
				--logging("--> found START signal")
			end
		end
	end

	-- check for changed states
	--logging("Checking for changed reactor state")
	local reactor_state = reactor.state
	local state_changed = false
	if reactor_state == 0 then

		if reactor.entity.get_fuel_inventory().is_empty() == false
		  and signal_start == true
		  and reactor.power.energy >= (POWER_USAGE_STARTING * TICKS_PER_UPDATE * 4 / 60* Setting.map("energy-consumption-multiplier"))
		  and signal_scram == false
		  and reactor.entity.get_burnt_result_inventory().can_insert({count = 1, name = game.item_prototypes[next(reactor.entity.get_fuel_inventory().get_contents())].burnt_result.name}) then
			state_changed = true
			change_reactor_state(1, reactor, tick)
		end

	elseif reactor_state == 1 then

		if signal_scram == true or reactor.entity.status ~= defines.entity_status.working then
			state_changed = true
			change_reactor_state(3, reactor, tick)
		elseif running_time >= Setting.duration("starting") then
			state_changed = true
			change_reactor_state(2, reactor, tick)
		elseif reactor.power.energy < (POWER_USAGE_STARTING * TICKS_PER_UPDATE * 4 / 60* Setting.map("energy-consumption-multiplier")) then
			--ToDo: show alarm on map?
			-- FIXME use messaging with localization
-- 			game.players[1].print("The starting phase of a nuclear reactor was aborted, because the reactor core didn't get enough electric energy from the grid. The fuel cell is lost.")
			state_changed = true
			change_reactor_state(0, reactor, tick)
		end

	elseif reactor_state == 2 then

		if signal_scram == true or reactor.entity.status ~= defines.entity_status.working then
			state_changed = true
			change_reactor_state(3, reactor, tick)
		end

	elseif reactor_state == 3 then
		if running_time >= Setting.duration("scram") then
			state_changed = true
			local usedfuel = reactor.entity.burner.currently_burning and reactor.entity.burner.currently_burning.burnt_result.name
			if Setting.behavior("scram") ~= "stop-half-empty" then
				if usedfuel then
					reactor.entity.get_burnt_result_inventory().insert({name = usedfuel, count = 1})
				end
				reactor.entity.burner.currently_burning = nil
			end
			change_reactor_state(0, reactor, tick)
		elseif reactor.entity.get_fuel_inventory().is_empty() and reactor.entity.burner.remaining_burning_fuel == 0 then
			state_changed = true
			change_reactor_state(0, reactor, tick)
		elseif Setting.behavior("scram") == "limit-to-current-cell" and reactor.entity.burner.remaining_burning_fuel < (reactor.signals.parameters["power-output"].count/60*1000000*(300)*(100/reactor.signals.parameters["efficiency"].count)) then --200 ticks at 200 reactors, but lets say 300

			local usedfuel = reactor.entity.burner.currently_burning and reactor.entity.burner.currently_burning.burnt_result.name
			state_changed = true
			if usedfuel then
				reactor.entity.get_burnt_result_inventory().insert({name = usedfuel, count = 1})
			end
			reactor.entity.burner.currently_burning = nil
			change_reactor_state(0, reactor, tick)
		end

	end
	running_time = math.ceil((tick - reactor.state_active_since)/60)

	if state_changed == false then
		--logging("-> reactor state unchanged")
	else
		reactor_state = reactor.state
	end

	--update reactor signals
	if reactor_state  == 1 then
		reactor.signals.parameters["state_starting"].count = Setting.duration("starting") - running_time
		reactor.signals.parameters["neighbour-bonus"].count = 0
	end
	if reactor_state  == 3 then
		reactor.signals.parameters["state_scramed"].count = Setting.duration("scram") - running_time
		reactor.signals.parameters["neighbour-bonus"].count = 0
	end
	if reactor_state  == 0 then
		-- reactor is not running
		reactor.signals.parameters["power-output"].count = 0
		reactor.signals.parameters["efficiency"].count = 0
		reactor.signals.parameters["cell-bonus"].count = 0
		reactor.signals.parameters["neighbour-bonus"].count = 0
	end


	-- check reactor and replace it with the appropriate version depending on temperature and connected reactors
	if reactor_state == 1 or reactor_state == 2 or reactor_state == 3 then

		--logging("---Updating reactor stats---")

		-- check how many running reactors are connected
		local neighbours = 1
		--logging("Checking running reactor neighbours:")

		for id in pairs(network.get_connected_reactors(reactor.entity)) do
			--logging("- checking connected reactor ID: " .. id)

			if reactor.id ~= id then
				-- found another reactor, check if it is running
				local other = global.reactors[id]
				--if other then logging("-> loaded connected reactor ID: " .. other.id) end
				if other and other.state == 2 then
					neighbours = neighbours + 1
					--logging("--> reactor is running, bonus: " .. neighbours)
				end
			end
		end
		--logging("-> Running reactor neighbours: " .. neighbours)
		reactor.neighbours = neighbours

		--load reactor parameters:
		-- power , efficiency, bonus_cells, (max_power, max_efficiency)
		--logging("Calculating reactor stats:")
		local reactor_parameters = FORMULA[Setting.formula()](reactor,running_time)

		-- -> in stats function
		-- if reactor.state  == 1 then
			-- reactor.signals.parameters["state_starting"].count = Setting.duration("starting") - running_time + 1 --ToDo: starting phase should end, when first fuel cell is half empty
			-- reactor_parameters.power = math.floor(reactor_parameters.power * ((running_time)/Setting.duration("starting"))^2)
			-- --reactor_parameters.efficiency = reactor_parameters.efficiency
			-- reactor_parameters.bonus_cells = 0
		-- end
		-- if reactor.state  == 3 then
			-- reactor.signals.parameters["state_scramed"].count = Setting.duration("scram") - running_time + 1
			-- reactor_parameters.power = math.floor(reactor_parameters.power * ((Setting.duration("scram") - (running_time)/3.5)/Setting.duration("scram"))^11+0.45)
			-- --reactor_parameters.efficiency = reactor_parameters.efficiency
			-- reactor_parameters.bonus_cells = 0
		-- end

		--logging("-> Temperature="..reactor.core.temperature.." PowerOutput="..reactor_parameters.power.." Efficiency="..math.floor(reactor_parameters.efficiency).." BonusCellAmount: "..reactor_parameters.bonus_cells)

		--apply material bonus by adding empty fuel cell
		local burnt_result
		--logging("Applying empty fuel cell bonus:")
		if reactor.entity.burner.currently_burning == nil then
			-- burner is empty, can't read fuel type
			-- cell bonus is skipped for now
			-- ToDo: save it in global.reactors and add it during the next update
		else
			--logging("- currently burning: "..reactor.entity.burner.currently_burning.name)
			if reactor_parameters.bonus_cells == 0 then
				-- do nothing
				-- normal reactor or breeder too cold
				--logging("-> adding nothing, too cold or no breeder reactor")
			else
				-- add bonus to current empty fuel cell amount
				burnt_result = reactor.entity.burner.currently_burning.burnt_result
				if burnt_result.name == "apm_fuel_cell_mox_used" then
					burnt_result = game.item_prototypes["apm_nuclear_breeder_uranium_inventory_enriched"]
				end
				local burn_duration = ((reactor.entity.burner.currently_burning.fuel_value/1000000)*(reactor_parameters.efficiency/100))/reactor_parameters.power*15/TICKS_PER_UPDATE -- burn duration in ticks
				local cell_bonus_amount

				if Setting.ingos_formula() then
					--adding bonus cell per time
					cell_bonus_amount = ((reactor_parameters.bonus_cells*TICKS_PER_UPDATE)/900)*BONUS_CELL_MULTIPLIER -- reactor_parameters.bonus_cells=100 means one cell per minute
				elseif Setting.ownlys_formula() then
					--adding bonus per burn duration
					cell_bonus_amount = reactor_parameters.bonus_cells / burn_duration
				else
					error("formula missing")
				end

				reactor.bonus_cells[burnt_result.name] = (reactor.bonus_cells[burnt_result.name] or 0) + cell_bonus_amount * (game.tick-reactor.last_states_update) / 60
				--logging("- bonus cell amount: "..cell_bonus_amount)

				-- msg("reactor.bonus_cells:     "..reactor.bonus_cells[burnt_result.name])
				-- msg("bonus amount (time):     "..((reactor_parameters.bonus_cells*TICKS_PER_UPDATE)/900)*BONUS_CELL_MULTIPLIER)
				-- msg("")
				-- msg("bonus amount (duration): "..reactor_parameters.bonus_cells / burn_duration)
				-- msg("---")

			end
		end


		if burnt_result and reactor.bonus_cells[burnt_result.name] and reactor.bonus_cells[burnt_result.name] > 1 then
			-- add used-up-uranium-fuel-cell
			--logging("Inserting used-up-uranium-fuel-cell:")
			--game.players[1].print("bonuscell")
			if not reactor.entity.get_burnt_result_inventory().is_empty() then
				--burnt fuel inventory not empty
				if reactor.entity.get_burnt_result_inventory().can_insert{name = burnt_result.name, count = 1} then
					-- same cell
					reactor.entity.get_burnt_result_inventory().insert({name=burnt_result.name, count=1})
					reactor.bonus_cells[burnt_result.name] = reactor.bonus_cells[burnt_result.name] -1
					--logging("-> inserted")
				else
					--different cell, wait
					--logging("-> can't insert, different used up cell present. waiting...")
				end
			else
				--burnt fuel inventory empty
				reactor.entity.get_burnt_result_inventory().insert({name=burnt_result.name,count=1})
				reactor.bonus_cells[burnt_result.name] = reactor.bonus_cells[burnt_result.name] -1
				--logging("-> inserted")
			end

		end


		-- update reactor signals
		reactor.signals.parameters["power-output"].count = reactor_parameters.power
		reactor.signals.parameters["efficiency"].count = math.floor(reactor_parameters.efficiency)
		reactor.signals.parameters["cell-bonus"].count = reactor_parameters.bonus_cells*100
		reactor.efficiency = reactor_parameters.efficiency
		if reactor_state == 2 or reactor_state == 1 then
			reactor.power_output_last_tick = reactor_parameters.power
		end


		-- replace reactor with updated level version
		--logging("Replace reactor model:")
		local reactor_to_build = "realistic-reactor-" .. math.max(1,reactor_parameters.power)
		--logging("-Reactor to be: "..reactor_to_build)
		--logging("-Current reactor: "..reactor.core.name)
		if reactor.core.name == reactor_to_build then
			--logging("-> Reactor already build.")
		elseif not (reactor_state == 3 and Setting.behavior("scram") == "decay-heat-v1") then
			replace_reactor_core(reactor,reactor_to_build)
		end

	end


	-- UPDATE DISPLAYER --
	reactor.entity.temperature = reactor.core.temperature

	reactor.last_states_update = game.tick
end


local function is_core(entity)
	return string.sub(entity.name, 1, 18) == "realistic-reactor-"
	   and not E2I_NAME[entity.name]
end

local function is_reactor(entity)
	return entity.type == "reactor"
	   and not is_core(entity)
end

local function reactor_is_empty(entity)
	return entity.get_fuel_inventory().is_empty()
	   and entity.get_burnt_result_inventory().is_empty()
end

local function reactor_is_minable(entity)
	return entity.minable and reactor_is_empty(entity)
end


local function find_reactor_ghost_of_interface(surface, position, name)
	return find_nuclear_ghost(surface, {position.x,position.y-1}, name)
end


local function on_tick(tick)
	-- reactor update events
	if tick % TICKS_PER_UPDATE == 0 then
		for _,reactor in pairs(global.reactors) do
			if reactor.entity and reactor.entity.valid then
				update_reactor_states(reactor,tick)
				update_reactor_signals(reactor,tick)
				update_reactor_temperature(reactor,tick) -- reactor may die here
			end
		end
	end
end


return { -- exports
	is = is_reactor,
	tick = on_tick,
	add    =    add_reactor,
	remove = remove_reactor,
	is_empty = reactor_is_empty,
	is_minable = reactor_is_minable,
	find_ghost = find_reactor_ghost_of_interface,
}

