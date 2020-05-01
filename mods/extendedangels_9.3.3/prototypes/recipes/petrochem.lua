local buildingmulti = angelsmods.marathon.buildingmulti
local buildingtime = angelsmods.marathon.buildingtime

angelsmods.functions.RB.build({
--ADVANCED GAS REFINERY    
    {
    type = "recipe",
    name = "gas-refinery-4",
	normal =
    {
	  energy_required = 50,
	  enabled = false,
      ingredients =
      {
		{"gas-refinery-3", 2},
		{"t5-plate", 100},
		{"t5-circuit", 50},
		{"titanium-concrete-brick", 100},
		{"t5-pipe", 100},
      },
      result= "gas-refinery-4",
    },
    expensive =
    {
	  energy_required = 50 * buildingtime,
	  enabled = false,
      ingredients =
      {
		{"gas-refinery-3", 2},
		{"t5-plate", 100 * buildingmulti},
		{"t5-circuit", 50 * buildingmulti},
		{"titanium-concrete-brick", 100 * buildingmulti},
		{"t5-pipe", 100 * buildingmulti},
      },
      result= "gas-refinery-4",
    },
    },
--ADVANCED CHEMICAL PLANT    
{
    type = "recipe",
    name = "advanced-chemical-plant-3",
	normal =
    {
	  energy_required = 50,
	  enabled = false,
      ingredients =
      {
		{"advanced-chemical-plant-2", 2},
		{"t5-plate", 20},
		{"t5-circuit", 40},
		{"titanium-concrete-brick", 40},
		{"t5-pipe", 120},
      },
      result= "advanced-chemical-plant-3",
    },
    expensive =
    {
	  energy_required = 50 * buildingtime,
	  enabled = false,
      ingredients =
      {
		{"advanced-chemical-plant-2", 2},
		{"t5-plate", 20 * buildingmulti},
		{"t5-circuit", 40 * buildingmulti},
		{"titanium-concrete-brick", 40 * buildingmulti},
		{"t5-pipe", 120 * buildingmulti},
      },
      result= "advanced-chemical-plant-3",
    },
    },
--AIR FILTER
{
    type = "recipe",
    name = "angels-air-filter-3",
	normal =
    {
	  energy_required = 50,
	  enabled = false,
      ingredients =
      {
		{"angels-air-filter-2", 2},
		{"t3-plate", 40},
		{"t3-circuit", 50},
		{"t3-brick", 50},
		{"t3-pipe", 80},
      },
      result= "angels-air-filter-3",
    },
    expensive =
    {
	  energy_required = 50 * buildingtime,
	  enabled = false,
      ingredients =
      {
		{"angels-air-filter-2", 2},
		{"t3-plate", 40 * buildingmulti},
		{"t3-circuit", 50 * buildingmulti},
		{"t3-brick", 50 * buildingmulti},
		{"t3-pipe", 80 * buildingmulti},
      },
      result= "angels-air-filter-3",
    },
    },
    {
        type = "recipe",
        name = "angels-air-filter-4",
        normal =
        {
          energy_required = 50,
          enabled = false,
          ingredients =
          {
            {"angels-air-filter-3", 2},
            {"t4-plate", 40},
            {"t4-circuit", 50},
            {"t4-brick", 50},
            {"t4-pipe", 80},
          },
          result= "angels-air-filter-4",
        },
        expensive =
        {
          energy_required = 50 * buildingtime,
          enabled = false,
          ingredients =
          {
            {"angels-air-filter-3", 2},
            {"t4-plate", 40 * buildingmulti},
            {"t4-circuit", 50 * buildingmulti},
            {"t4-brick", 50 * buildingmulti},
            {"t4-pipe", 80 * buildingmulti},
          },
          result= "angels-air-filter-4",
        },
        },

}
)

data:extend(
{
    {
        type = "recipe",
        name = "solid-sodium-floride-1",
        category = "chemistry",
        subgroup = "petrochem-sodium",
        energy_required = 5,
        enabled = "false",
        ingredients ={
            {type="item", name="solid-sodium-hydroxide", amount=5},
            {type="fluid", name="liquid-hydrofluoric-acid", amount=50},
        },
        results=
        {
            {type="item", name="solid-sodium-floride", amount=5},
            {type="fluid", name="water-purified", amount=50},
        },
        icon = "__extendedangels__/graphics/icons/solid-sodium-floride.png",
        icon_size = 32,
        order = "k",
    },
    
    {
        type = "recipe",
        name = "solid-sodium-floride-2",
        category = "chemistry",
        subgroup = "petrochem-sodium",
        energy_required = 5,
        enabled = "false",
        ingredients ={
            {type="item", name="solid-sodium-carbonate", amount=5},
            {type="fluid", name="liquid-hexafluorosilicic-acid", amount=25},
        },
        results=
        {
            {type="item", name="solid-sodium-floride", amount=5},
            {type="fluid", name="water-purified", amount=25},
        },
        icon = "__extendedangels__/graphics/icons/solid-sodium-floride.png",
        icon_size = 32,
        order = "l",
        },

        {
            type = "recipe",
            name = "gas-argon",
            category = "chemistry",
            subgroup = "petrochem-argon",
            energy_required = 60,
            enabled = "false",
            ingredients ={
                {type="fluid", name="gas-compressed-air", amount=100}
            },
            results=
            {
                {type="fluid", name="gas-argon", amount=5},
            },
            icon = "__extendedangels__/graphics/icons/gas-argon.png",
            icon_size = 32,
            order = "a",
            },
    }
)


if mods["Clowns-Processing"] then 
    data:extend(
        {
            {
                type = "recipe",
                name = "solid-disodium-phosphate",
                category = "chemistry",
                subgroup = "petrochem-sodium",
                energy_required = 5,
                enabled = "false",
                ingredients ={
                    {type="item", name="solid-sodium-carbonate", amount=5},
                    {type="fluid", name="liquid-phosphoric-acid", amount=50},
                },
                results=
                {
                    {type="item", name="solid-disodium-phosphate", amount=5},
                },
                icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
                icon_size = 32,
                order = "m",
                },

                {
                    type = "recipe",
                    name = "solid-tetrasodium-pyrophosphate",
                    category = "smelting",
                    subgroup = "petrochem-sodium",
                    energy_required = 7,
                    ingredients ={
                        {"solid-disodium-phosphate", 1}
                    },
                    result = "solid-tetrasodium-pyrophosphate",
                    order = "n",
                  },
        }
    )
end
