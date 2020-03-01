--config.lua

local ticks_per_update = settings.startup["ret-ticks-per-update"].value


function store(power)
	return power / 60 * (ticks_per_update + 5)
end

config = {
	pole_max_wire_distance = 17,

	pole_supply_area = 4,

	-- Refills the buffer until the next update
	pole_flow_limit = 4800000,
	-- Pole enable buffer (1kJ)
	pole_enable_buffer = 1000,


	-- Locomotive Mk 1 (600kW, like vanilla)
	locomotive_power = 600000,
	locomotive_storage = store(1200000),
	-- Locomotive Mk 2 (1.2MW, two times vanilla)
	advanced_locomotive_power = 1200000,
	advanced_locomotive_storage = store(2400000),
	-- Modular Locomotive (1.8MW, three times vanilla)
	modular_locomotive_base_power = 1800000,
	modular_locomotive_storage = store(3600000)
}

function toW(value)
	return string.format("%dW", value)
end

function toJ(value)
	return string.format("%dJ", value)
end

-- ### Mod compatibility ###
-- increase flow limit if train overhaul is installed
if settings.startup["train-overhaul-power-multiplicator"] then
	config.pole_flow_limit = 9600000 * settings.startup["train-overhaul-power-multiplicator"].value
end
