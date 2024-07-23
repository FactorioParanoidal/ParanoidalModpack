local function get_subs(entities, matchers)
	local subs = {}
	for _, entity in pairs(entities) do
		for name, matcher in pairs(matchers) do
			local matches
			if type(matcher) == "string" then
				matches = entity.name == matcher
			else
				matches = matcher(entity.name)
			end
			if matches then
				if subs[name] ~= nil then
					error("Duplicate entity for "..name)
				end
				subs[name] = entity
			end
		end
	end
	for name, _ in pairs(matchers) do
		if subs[name] == nil then
			error("Missing entity for "..name)
		end
	end
	return subs
end

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

local function find_reactors()
	local reactor_max_power, reactor_max_efficiency
	local formula = settings["global"]["realistic-reactors-calculate-stats-function"].value
	if formula == "ingo" then
		reactor_max_power = 123
		reactor_max_efficiency = 200
	elseif formula == "ownly" then
		reactor_max_power = 250
		reactor_max_efficiency = 210
	else
		error("formula missing")
	end

	local reactors = {}
	for name, surface in pairs(game.surfaces) do
		for _, reactor_entity in ipairs(surface.find_entities_filtered{name={REACTOR_ENTITY_NAME, BREEDER_ENTITY_NAME}}) do
			local p = reactor_entity.position
			local subs = get_subs(surface.find_entities({{p.x-1.5, p.y-1.5}, {p.x+1.5, p.y+1.5}}), {
				entity = reactor_entity.name,
				core = function(name) return string.match(name, "realistic%-reactor%-%d+") end,
				interface = E2I_NAME[reactor_entity.name],
				eccs = BOILER_ENTITY_NAME,
				power = POWER_NAME[reactor_entity.name],
				lamp = function(name) return string.match(name, "rr%-%w+%-lamp") end,
				light = function(name) return string.match(name, "rr%-%w+%-light") end,
			})
			local reactor = {
				id = subs.entity.unit_number, -- ID of the reactor (doesn't change)
				core_id = subs.core.unit_number, -- ID of the core (changes when core is replaced)
				core = subs.core, -- core entity
				interface = subs.interface, -- interface entity
				eccs = subs.eccs, -- eccs entity
				power = subs.power, -- power entity
				entity = subs.entity, -- displayer entity
				position = subs.core.position, -- core position = reactor position
				state = 0, -- reactor state
				state_active_since = game.tick - TICKS_PER_UPDATE, -- state begin
				neighbours = 1, -- number of connected reactors and itself
				control = subs.interface.get_or_create_control_behavior(), -- control behaviour for interface signals
				efficiency = 0, -- reactor efficiency
				bonus_cells = {}, -- list of bonus cell amount for breeder
				cooling_history = 0, -- average power loss through cooling in the last TICKS_PER_UPDATE*8 ticks
				lamp = subs.lamp, --reactor lamp dummy
				light = subs.light, --light dummy for the lamp
				interface_warning_tick = 0, --last tick an electricity warning was displayed on the interface (for imitating the game's behaviour)
				interface_warning = nil, --electricity warning dummy (interface)
				cooling_warning_tick = 0, --last tick an electricity warning was displayed on the cooling
				cooling_warning = nil, --electricity warning dummy (cooling)
				power_usage = {starting = 0,cooling = 0, interface = 0}, --portions of the power consumption
				last_states_update = game.tick - TICKS_PER_UPDATE,
				fuel_last_tick = 0, -- fuel value in the core on last tick
				--fluid_amount_last_tick = 0, -- fluid amount in eccs on last tick
				power_output_last_tick = 0, --power output in MW on last tick (only updated in start or running phase)
				last_temp_update = game.tick - TICKS_PER_UPDATE,
				max_power = reactor_max_power, --dynamic maximum value for gui
				max_efficiency = reactor_max_efficiency, --dynamic maximum value for gui
				signals = Signals(),
			}
			for _, saved_signal in pairs(reactor.signals.parameters) do
				local real_signal = reactor.control.parameters[saved_signal.index]
				if (real_signal.signal.type ~= saved_signal.signal.type) or
						(real_signal.signal.name ~= saved_signal.signal.name and saved_signal.index ~= 8) then -- 8 is fuel, it may differ
					error(string.format("Can't migrate signal %d (expected %q:%q, got %q:%q)",
						saved_signal.index, saved_signal.signal.type, saved_signal.signal.name, real_signal.signal.type, real_signal.signal.name))
				end
				saved_signal.count = real_signal.count
			end
			reactor.control.parameters = reactor.signals.parameters
			if reactor.signals.parameters["state_stopped"].count == 1 then
				reactor.state = 0
			elseif reactor.signals.parameters["state_starting"].count == 1 then
				reactor.state = 1
			elseif reactor.signals.parameters["state_running"].count == 1 then
				reactor.state = 2
			elseif reactor.signals.parameters["state_scramed"].count == 1 then
				reactor.state = 3
			end
			reactors[reactor.id] = reactor
		end
	end
	return reactors
end

local function find_towers()
	local towers = {}
	for name, surface in pairs(game.surfaces) do
		for _, entity in ipairs(surface.find_entities_filtered{name=TOWER_ENTITY_NAME}) do
			local p = entity.position
			local subs = get_subs(surface.find_entities({{p.x-1.5, p.y-1.5}, {p.x+1.5, p.y+1.5}}), {
				entity = TOWER_ENTITY_NAME,
				steam = STEAM_ENTITY_NAME,
			})
			local tower = {
				id = entity.unit_number,
				entity = entity,
				steam = subs.steam,
			}
			towers[tower.id] = tower
		end
	end
	return towers
end

global.reactors = find_reactors()
global.towers = find_towers()
