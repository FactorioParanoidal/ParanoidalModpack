local buildingmulti = angelsmods.marathon.buildingmulti
local buildingtime = angelsmods.marathon.buildingtime

angelsmods.functions.RB.build(
{
	-- Alloy Mixer
	{
		type = "recipe",
		name = "alloy-mixer",
		normal =
		{
			energy_required = 5,
			enabled = false,
			ingredients =
			{
				{"alloym-1", 1},
				{"t1-plate", 3},
				{"t0-circuit", 3},
				{"t1-pipe", 4},
				{"t1-gears", 2},
				{"t1-brick", 2},
			},
			result="alloy-mixer",
		},
		expensive =
		{
			energy_required = 5 * buildingtime,
			enabled = false,
			ingredients =
			{
				{"alloym-1", 1},
				{"t1-plate", 3 * buildingmulti},
				{"t0-circuit", 3 * buildingmulti},
				{"t1-pipe", 4 * buildingmulti},
				{"t1-gears", 2 * buildingmulti},
				{"t1-brick", 2 * buildingmulti},
			},
			result="alloy-mixer",
		},
	},
	{
		type = "recipe",
		name = "alloy-mixer-2",
		normal =
		{
			energy_required = 5,
			enabled = false,
			ingredients =
			{
				{"alloym-2", 1},
				{"t2-plate", 3},
				{"t2-circuit", 3},
				{"t2-pipe", 4},
				{"t2-gears", 2},
				{"t2-brick", 2},
			},
			result="alloy-mixer-2",
		},
		expensive =
		{
			energy_required = 5 * buildingtime,
			enabled = false,
			ingredients =
			{
				{"alloym-2", 1},
				{"t2-plate", 3 * buildingmulti},
				{"t2-circuit", 3 * buildingmulti},
				{"t2-pipe", 4 * buildingmulti},
				{"t2-gears", 2 * buildingmulti},
				{"t2-brick", 2 * buildingmulti},
			},
			result="alloy-mixer-2",
		},
	},
	{
		type = "recipe",
		name = "alloy-mixer-3",
		normal =
		{
			energy_required = 5,
			enabled = false,
			ingredients =
			{
				{"alloym-3", 1},
				{"t3-plate", 3},
				{"t3-circuit", 3},
				{"t3-pipe", 4},
				{"t3-gears", 2},
				{"t3-brick", 2},
			},
			result="alloy-mixer-3",
		},
		expensive =
		{
			energy_required = 5 * buildingtime,
			enabled = false,
			ingredients =
			{
				{"alloym-3", 1},
				{"t3-plate", 3 * buildingmulti},
				{"t3-circuit", 3 * buildingmulti},
				{"t3-pipe", 4 * buildingmulti},
				{"t3-gears", 2 * buildingmulti},
				{"t3-brick", 2 * buildingmulti},
			},
			result="alloy-mixer-3",
		},
	},
	{
		type = "recipe",
		name = "alloy-mixer-4",
		normal =
		{
			energy_required = 5,
			enabled = false,
			ingredients =
			{
				{"alloym-4", 1},
				{"t4-plate", 3},
				{"t4-circuit", 3},
				{"t4-pipe", 4},
				{"t4-gears", 2},
				{"t4-brick", 2},
			},
			result="alloy-mixer-4",
		},
		expensive =
		{
			energy_required = 5 * buildingtime,
			enabled = false,
			ingredients =
			{
				{"alloym-4", 1},
				{"t4-plate", 3 * buildingmulti},
				{"t4-circuit", 3 * buildingmulti},
				{"t4-pipe", 4 * buildingmulti},
				{"t4-gears", 2 * buildingmulti},
				{"t4-brick", 2 * buildingmulti},
			},
			result="alloy-mixer-4",
		},
	},
}
)