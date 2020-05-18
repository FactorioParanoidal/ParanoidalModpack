local buildingmulti = angelsmods.marathon.buildingmulti
local buildingtime = angelsmods.marathon.buildingtime

angelsmods.functions.RB.build({
--HYDRO PLANT
	{
    type = "recipe",
    name = "hydro-plant-4",
	normal =
    {
	  energy_required = 5,
	  enabled = "false",
      ingredients =
      {
		{"hydro-plant-3", 2},
		{"t5-plate", 10},
		{"t5-circuit", 12},
		{"t5-pipe", 16},	
		{"titanium-concrete-brick", 12},
      },
      result= "hydro-plant-4",
    },
    expensive =
    {
	  energy_required = 5 * buildingtime,
	  enabled = "false",
      ingredients =
      {
		{"hydro-plant-3", 2},
		{"t5-plate", 4 * buildingmulti},
		{"t5-circuit", 12 * buildingmulti},
		{"t5-pipe", 16 * buildingmulti},	
		{"titanium-concrete-brick", 12 * buildingmulti},
      },
      result= "hydro-plant-4",
    },
    order = "d"
    },
--SALINATION PLANT
	{
    type = "recipe",
    name = "salination-plant-3",
	normal =
    {
	  energy_required = 20,
	  enabled = "false",
      ingredients =
      {
		{"salination-plant-2", 2},
		{"t5-plate", 20},
		{"t5-circuit", 12},
		{"t5-pipe", 20},	
		{"titanium-concrete-brick", 25},
      },
      result= "salination-plant-3",
    },
    expensive =
    {
	  energy_required = 20 * buildingtime,
	  enabled = "false",
      ingredients =
      {
		{"salination-plant-2", 2},
		{"t5-plate", 14 * buildingmulti},
		{"t5-circuit", 12 * buildingmulti},
		{"t5-pipe", 8 * buildingmulti},	
		{"titanium-concrete-brick", 15 * buildingmulti},
      },
      result= "salination-plant-3",
    },
    order = "h"
    },
--WASHING PLANT
    {
    type = "recipe",
    name = "washing-plant-3",
	normal =
    {
	  energy_required = 20,
	  enabled = "false",
      ingredients =
      {
		{"washing-plant-2", 2},
		{"t3-plate", 10},
		{"t3-circuit", 4},
		{"t3-pipe", 20},	
		{"t3-brick", 20},
      },
      result="washing-plant-3",
    },
    expensive =
    {
	  energy_required = 20 * buildingtime,
	  enabled = "false",
      ingredients =
      {
		{"washing-plant-2", 2},
		{"t3-plate", 4 * buildingmulti},
		{"t3-circuit", 4 * buildingmulti},
		{"t3-pipe", 9 * buildingmulti},	
		{"t3-brick", 5 * buildingmulti},
      },
      result="washing-plant-3",
    },
    },
	{
    type = "recipe",
    name = "washing-plant-4",
	normal =
    {
	  energy_required = 20,
	  enabled = "false",
      ingredients =
      {
		{"washing-plant-3", 2},
		{"t4-plate", 20},
		{"t4-circuit", 4},
		{"t4-pipe", 30},	
		{"t4-brick", 30},
      },
      result="washing-plant-4",
    },
    expensive =
    {
	  energy_required = 20 * buildingtime,
	  enabled = "false",
      ingredients =
      {
		{"washing-plant-2", 2},
		{"t4-plate", 4 * buildingmulti},
		{"t4-circuit", 4 * buildingmulti},
		{"t4-pipe", 9 * buildingmulti},	
		{"t4-brick", 5 * buildingmulti},
      },
      result="washing-plant-4",
    },
    },
--ORE CRUSHER
{
    type = "recipe",
    name = "ore-crusher-4",
	normal =
    {
	  energy_required = 20,
	  enabled = "false",
      ingredients =
      {
		{"ore-crusher-3", 2},
		{"t4-plate", 10},
		{"t4-brick", 16},
		{"t4-gears", 10},
      },
      result= "ore-crusher-4",
    },
    expensive =
    {
	  energy_required = 20 * buildingtime,
	  enabled = "false",
      ingredients =
      {
		{"ore-crusher-3", 2},
		{"t4-plate", 3 * buildingmulti},
		{"t4-brick", 3 * buildingmulti},
		{"t4-gears", 2 * buildingmulti},
      },
      result= "ore-crusher-4",
    },
    subgroup = "ore-crusher",
	order = "e[ore-crusher-4]"
    },
--ORE FLOATATION CELL
{
    type = "recipe",
    name = "ore-floatation-cell-4",
	normal =
    {
	  energy_required = 20,
	  enabled = "false",
      ingredients =
      {
		{"ore-floatation-cell-3", 2},
		{"t5-plate", 20},
		{"t5-circuit", 8},
		{"t5-pipe", 20},	
		{"titanium-concrete-brick", 20},
      },
      result= "ore-floatation-cell-4",
    },
    expensive =
    {
	  energy_required = 20 * buildingtime,
	  enabled = "false",
      ingredients =
      {
		{"ore-floatation-cell-3", 2},
		{"t5-plate", 4 * buildingmulti},
		{"t5-circuit", 8 * buildingmulti},
		{"t5-pipe", 4 * buildingmulti},	
		{"titanium-concrete-brick", 8 * buildingmulti},
      },
      result= "ore-floatation-cell-4",
    },
    subgroup = "ore-floatation",
	order = "d[ore-floatation-cell-4]"
    },
--ORE LEACHING PLANT
{
    type = "recipe",
    name = "ore-leaching-plant-4",
	normal =
    {
	  energy_required = 20,
	  enabled = "false",
      ingredients =
      {
		{"ore-leaching-plant-3", 2},
		{"copper-tungsten-alloy", 20},
		{"t5-circuit", 16},
		{"nitinol-bearing", 16},	
		{"titanium-concrete-brick", 40},
      },
      result= "ore-leaching-plant-4",
    },
    expensive =
    {
	  energy_required = 20 * buildingtime,
	  enabled = "false",
      ingredients =
      {
		{"ore-leaching-plant-3", 2},
		{"copper-tungsten-alloy", 8 * buildingmulti},
		{"t5-circuit", 16 * buildingmulti},
		{"nitinol-bearing", 8 * buildingmulti},	
		{"titanium-concrete-brick", 40 * buildingmulti},
      },
      result= "ore-leaching-plant-4",
    },
    subgroup = "ore-leaching",
	order = "d[ore-leaching-plant-43]"
    },   
 --ORE REFINERY
 {
    type = "recipe",
    name = "ore-refinery-3",
	normal =
    {
	  energy_required = 20,
	  enabled = "false",
      ingredients =
      {
		{"ore-refinery-2", 2},
        {"copper-tungsten-alloy", 50},
        {"nitinol-bearing", 12},
		{"t5-circuit", 24},
		{"titanium-concrete-brick", 100},
      },
      result= "ore-refinery-3",
    },
    expensive =
    {
	  energy_required = 20 * buildingtime,
	  enabled = "false",
      ingredients =
      {
		{"ore-refinery-2", 2},
        {"copper-tungsten-alloy", 12 * buildingmulti},
        {"nitinol-bearing", 12 * buildingmulti},
		{"t5-circuit", 24 * buildingmulti},
		{"titanium-concrete-brick", 100 * buildingmulti},
      },
      result= "ore-refinery-3",
    },
    subgroup = "ore-refining",
	order = "c[ore-refinery-3]"
    },
--CRYSTALLIZER
{
    type = "recipe",
    name = "crystallizer-3",
	normal =
    {
	  energy_required = 20,
	  enabled = "false",
      ingredients =
      {
		{"crystallizer-2", 2},
		{"t5-plate", 40},
		{"t5-circuit", 5},
		{"t5-pipe", 40},	
		{"titanium-concrete-brick", 40},
      },
      result="crystallizer-3",
    },
    expensive =
    {
	  energy_required = 20 * buildingtime,
	  enabled = "false",
      ingredients =
      {
		{"crystallizer-2", 2},
		{"t5-plate", 10 * buildingmulti},
		{"t5-circuit", 5 * buildingmulti},
		{"t5-pipe", 5 * buildingmulti},	
		{"titanium-concrete-brick", 10 * buildingmulti},
      },
      result="crystallizer-3",
    },
    },
--FILTRATION UNIT
        {
        type = "recipe",
        name = "filtration-unit-3",
        normal =
        {
          energy_required = 20,
          enabled = "false",
          ingredients =
          {
            {"filtration-unit-2", 2},
            {"t5-plate", 20},
            {"t5-circuit", 5},
            {"t5-pipe", 20},	
            {"titanium-concrete-brick", 20},
          },
          result="filtration-unit-3",
        },
        expensive =
        {
          energy_required = 20 * buildingtime,
          enabled = "false",
          ingredients =
          {
            {"filtration-unit-2", 2},
            {"t5-plate", 2 * buildingmulti},
            {"t5-circuit", 5 * buildingmulti},
            {"t5-pipe", 20 * buildingmulti},	
            {"titanium-concrete-brick", 5 * buildingmulti},
          },
          result="filtration-unit-3",
        },
        },

}
)