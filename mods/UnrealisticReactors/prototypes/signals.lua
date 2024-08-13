  BLUE_BACKGROUND = "__UnrealisticReactors__/graphics/icons/signal_blue.png"
   RED_BACKGROUND = "__UnrealisticReactors__/graphics/icons/signal_red_background.png"
 GREEN_BACKGROUND = "__UnrealisticReactors__/graphics/icons/signal_green_background.png"
YELLOW_BACKGROUND = "__UnrealisticReactors__/graphics/icons/signal_yellow_background.png"
  GREY_BACKGROUND = "__UnrealisticReactors__/graphics/icons/signal_grey_background.png"
ORANGE_BACKGROUND = "__UnrealisticReactors__/graphics/icons/signal_orange_background.png"

data:extend{

-- SIGNAL SUBGROUP --
--
{
	type = "item-subgroup",
	name = "reactor-signals",
	group = "signals",
	order = "f"
},


-- SIGNALS --
--

-- signal-reactor-core-temp
{
	type = "virtual-signal",
	name = "signal-reactor-core-temp",
	icons =
	{
		{icon = BLUE_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_core_temp.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-a"
},

--signal-reactor-power-output
{
	type = "virtual-signal",
	name = "signal-reactor-power-output",
	icons =
	{
		{icon = BLUE_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_reactor_power_output.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-b"
},

--signal-reactor-electric-power
{
	type = "virtual-signal",
	name = "signal-reactor-electric-power",
	icons =
	{
		{icon = BLUE_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_reactor_electric_power.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-d"
},

-- signal-reactor-efficiency
{
	type = "virtual-signal",
	name = "signal-reactor-efficiency",
	icons =
	{
		{icon = BLUE_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_reactor_efficiency.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-c"
},

-- signal-breeder_cell-bonus
{
	type = "virtual-signal",
	name = "signal-reactor-cell-bonus",
	icons =
	{
		{icon = BLUE_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_cell_bonus.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-d"
},

-- signal-coolant-amount"
{
	type = "virtual-signal",
	name = "signal-coolant-amount",
	icons =
	{
		{icon = BLUE_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_coolant_amount.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-e"
},

-- signal-state-stopped
{
	type = "virtual-signal",
	name = "signal-state-stopped",
	icons =
	{
		{icon = GREY_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_state.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-f"
},

-- signal-state-starting
{
	type = "virtual-signal",
	name = "signal-state-starting",
	icons =
	{
		{icon = YELLOW_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_state.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-g"
},

-- signal-state-running
{
	type = "virtual-signal",
	name = "signal-state-running",
	icons =
	{
		{icon = GREEN_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_state.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-h"
},

-- signal-state-scramed
{
	type = "virtual-signal",
	name = "signal-state-scramed",
	icons =
	{
		{icon = RED_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_state.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-i"
},

-- signal-control-start
{
	type = "virtual-signal",
	name = "signal-control-start",
	icons =
	{
		{icon = ORANGE_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_control_start.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "b-a"
},

-- signal-control-scram
{
	type = "virtual-signal",
	name = "signal-control-scram",
	icons =
	{
		{icon = ORANGE_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/signal_control_scram.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "b-c"
},

-- signal-neighbour-bonus
{
	type = "virtual-signal",
	name = "signal-neighbour-bonus",
	icons =
	{
		{icon = BLUE_BACKGROUND},
		{icon = "__UnrealisticReactors__/graphics/icons/neighbours.png"}
	},
	icon_size = 32,
	subgroup = "reactor-signals",
	order = "a-f"
},

}
