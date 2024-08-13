-- all globals

-- CONTROL DECLARATION

REMOTE_INTERFACE_NAME = "rr-interface"

-- VARIABLE DECLARATION

TICKS_PER_UPDATE = 15
	-- each reactor and cooling tower gets updated once every 15 ticks (60 ticks = 1 s)
CHANGE_MULTIPLIER = 0.2
	-- used to multiply the temperature change
	-- CHANGE_MULTIPLIER and TICKS_PER_UPDATE work together and are balanced:
	-- 0.2 CHANGE_MULTIPLIER = 15 TICKS_PER_UPDATE
REACTOR_MASS = 6000 --increased from 4000 because of the reactor output nerf
	-- used to calculate temperature changes when emergency cooling is used
	-- the mass is an estimate best guess based on many tries and errors
BONUS_CELL_MULTIPLIER = 0.5
	-- multiplier for breeder bonus cell production.
	-- BONUS_CELL_MULTIPLIER=1 and bonus_cell_Production=100 means 1 additional empty cell per minute
POWER_USAGE_STARTING=3600000 -- 3600 KW
POWER_USAGE_INTERFACE=200000 -- 200 KW
POWER_USAGE_COOLING=1000000 -- 1 MW when when reactor was cooled (static) or 1 MW per 20 MW cooling (non-static)
	-- electric power usage of the reactor
TEMPERATURE = 15 -- standard of factorio
DYING_REACTOR_CORE_TEMPERATURE = 1000

-- entity names
REACTOR_ENTITY_NAME = "realistic-reactor-normal"
BREEDER_ENTITY_NAME = "realistic-reactor-breeder"
REACTOR_POWER_NAME = "realistic-reactor-power-normal"
BREEDER_POWER_NAME = "realistic-reactor-power-breeder"
REACTOR_RUIN_NAME = "reactor-ruin"
BREEDER_RUIN_NAME = "breeder-ruin"
REACTOR_INTERFACE_ENTITY_NAME = "realistic-reactor-interface"
BREEDER_INTERFACE_ENTITY_NAME = "realistic-breeder-interface"
SARCOPHAGUS_ENTITY_NAME="reactor-sarcophagus"
BOILER_ENTITY_NAME = "realistic-reactor-eccs"
TOWER_ENTITY_NAME = "rr-cooling-tower"
STEAM_ENTITY_NAME = "rr-cooling-tower-steam"
RUIN_SMOKE_NAME = "ruin-smoke"
-- signal names
SIGNAL_CORE_TEMP = {type="virtual", name="signal-reactor-core-temp"}
SIGNAL_STATE_STOPPED = {type="virtual", name="signal-state-stopped"}
SIGNAL_STATE_STARTING = {type="virtual", name="signal-state-starting"}
SIGNAL_STATE_RUNNING = {type="virtual", name="signal-state-running"}
SIGNAL_STATE_SCRAMED = {type="virtual", name="signal-state-scramed"}
SIGNAL_CONTROL_START = {type="virtual", name="signal-control-start"}
SIGNAL_CONTROL_SCRAM = {type="virtual", name="signal-control-scram"}
SIGNAL_COOLANT_AMOUNT = {type="virtual", name="signal-coolant-amount"}
--SIGNAL_COOLANT_TEMP = {type="virtual", name="signal-coolant-temperature"}
SIGNAL_URANIUM_FUEL_CELLS = {type="item", name="uranium-fuel-cell"}
SIGNAL_USED_URANIUM_FUEL_CELLS = {type="item", name="used-up-uranium-fuel-cell"}
SIGNAL_REACTOR_POWER_OUTPUT = {type="virtual", name="signal-reactor-power-output"}
SIGNAL_REACTOR_EFFICIENCY = {type="virtual", name="signal-reactor-efficiency"}
SIGNAL_REACTOR_CELL_BONUS = {type="virtual", name="signal-reactor-cell-bonus"}
SIGNAL_REACTOR_ELECTRIC_POWER = {type="virtual", name="signal-reactor-electric-power"}
SIGNAL_NEIGHBOUR_BONUS  = {type="virtual", name="signal-neighbour-bonus"}


-- NAMESPACE DECLARATION

RUIN_NAME = {
	[REACTOR_ENTITY_NAME] = REACTOR_RUIN_NAME,
	[BREEDER_ENTITY_NAME] = BREEDER_RUIN_NAME,
}

POWER_NAME = {
	[REACTOR_ENTITY_NAME] = REACTOR_POWER_NAME,
	[BREEDER_ENTITY_NAME] = BREEDER_POWER_NAME,
}

E2I_NAME = {
	[REACTOR_ENTITY_NAME] = REACTOR_INTERFACE_ENTITY_NAME,
	[BREEDER_ENTITY_NAME] = BREEDER_INTERFACE_ENTITY_NAME,
}

I2E_NAME = {
	[REACTOR_INTERFACE_ENTITY_NAME] = REACTOR_ENTITY_NAME,
	[BREEDER_INTERFACE_ENTITY_NAME] = BREEDER_ENTITY_NAME,
}

R2E_NAME = {
	[REACTOR_RUIN_NAME] = REACTOR_ENTITY_NAME,
	[BREEDER_RUIN_NAME] = BREEDER_ENTITY_NAME,
}




N = defines.direction.north
S = defines.direction.south
E = defines.direction.east
W = defines.direction.west
D = {N,E,S,W} -- like css
R = {[N]=S,[S]=N,[E]=W,[W]=E}
O = {
	[N] = {x= 0, y=-1},
	[S] = {x= 0, y= 1},
	[W] = {x=-1, y= 0},
	[E] = {x= 1, y= 0},
}

V = {x='y',y='x'} -- reverse vector
A = { -- areal lookup
	left_top     = {x=W, y=N},
	right_bottom = {x=E, y=S},
}
M = {
	[W] = {left_top='x'},
	[N] = {left_top='y'},
	[E] = {right_bottom='x'},
	[S] = {right_bottom='y'},
}
