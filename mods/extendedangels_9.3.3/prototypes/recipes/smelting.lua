local intermediatemulti = angelsmods.marathon.intermediatemulti
data:extend(
{

    {
        type = "recipe",
        name = "solid-tungsten-trioxide-smelting",
        category = "chemical-smelting",
        subgroup = "angels-tungsten",
        energy_required = 4,
        enabled = "false",
        ingredients ={
          {type="item", name="pellet-tungsten", amount=4},
          {type="fluid", name="gas-oxygen", amount=60},
        },
        results=
        {
          {type="item", name="solid-tungsten-trioxide", amount=12},
        },
        icon_size = 32,
        order = "i",
    },


    {
        type = "recipe",
        name = "pellet-tungsten-smelting-2",
        category = "chemical-smelting",
        subgroup = "angels-tungsten",
        energy_required = 8,
        enabled = "false",
        ingredients ={
            {type="item", name="solid-salt", amount=50},
            {type="item", name="solid-tungsten-trioxide", amount=12},
            {type="item", name="solid-sodium-floride", amount=6},                          
        },
        results=
        {
            {type="item", name="solid-sodium-tungstate", amount=12},
        },
            icon_size = 32,
            order = "j",
        },

    {
        type = "recipe",
        name = "solid-sodium-tungstate-smelting",
        category = "blast-smelting",
        subgroup = "angels-tungsten",
        energy_required = 4,
        enabled = "false",
        ingredients ={
          {type="item", name="solid-sodium-tungstate", amount=16},
          {type="item", name="pellet-manganese", amount=4},
        },
        results=
        {
          {type="item", name="powder-tungsten", amount=30},
        },
    },
    
    {
        type = "recipe",
        name = "powder-zinc",
        category = "advanced-crafting",
        subgroup = "angels-zinc-casting",
        energy_required = 0.5,
        enabled = "false",
        ingredients ={
          {type="item", name="ingot-zinc", amount=1},
        },
        results=
        {
          {type="item", name="powder-zinc", amount=1},
        },
        icon_size = 32,
        order = "b",
    },    
    
    {
        type = "recipe",
        name = "casting-powder-tungsten-3",
        category = "powder-mixing",
        subgroup = "angels-tungsten-casting",
        energy_required = 4,
        enabled = "false",
        ingredients ={
          {type="item", name="powder-tungsten", amount=12},
          {type="item", name="powder-zinc", amount=12},
        },
        results=
        {
          {type="item", name="casting-powder-tungsten", amount=24},
        },
        icon_size = 32,
        order = "k",
    },     

    {
        type = "recipe",
        name = "copper-tungsten-smelting-1",
        category = "chemical-smelting",
	    subgroup = "angels-copper-tungsten",
        energy_required = 8,
	    enabled = "false",
        ingredients ={
            {type="item", name="ingot-copper", amount=16},
            {type="item", name="powder-tungsten", amount=12},
            {type="fluid", name="gas-hydrogen", amount=60},
	    },
        results=
        {
            {type="fluid", name="liquid-molten-copper-tungsten", amount=120},
        },
	        icon_size = 32,
            order = "ac",
        },

    {
        type = "recipe",
        name = "molten-copper-tungsten-smelting-1",
        category = "casting",
        subgroup = "angels-copper-tungsten-casting",
        energy_required = 8,
        enabled = "false",
        ingredients ={
          {type="fluid", name="liquid-molten-copper-tungsten", amount=40},                
        },
        results=
        {
          {type="item", name="copper-tungsten-alloy", amount=4},
        },
        icon_size = 32,
        order = "ac",
    },

    {
        type = "recipe",
        name = "copper-tungsten-smelting-2",
        category = "chemical-smelting",
        subgroup = "angels-copper-tungsten",
        energy_required = 8,
        enabled = "false",
        ingredients ={
            {type="item", name="ingot-copper", amount=8},
            {type="item", name="ingot-silver", amount=8},
            {type="item", name="powder-tungsten", amount=12},
            {type="fluid", name="gas-hydrogen", amount=60},
        },
        results=
        {
            {type="fluid", name="liquid-molten-copper-tungsten", amount=120},
        },
            icon_size = 32,
            order = "ad",
        },

            {
                type = "recipe",
                name = "molten-copper-tungsten-smelting-1",
                category = "casting",
                subgroup = "angels-copper-tungsten-casting",
                energy_required = 8,
                enabled = "false",
                ingredients ={
                  {type="fluid", name="liquid-molten-copper-tungsten", amount=40},                
                },
                results=
                {
                  {type="item", name="copper-tungsten-alloy", amount=4},
                },
                icon_size = 32,
                order = "ac",
                },

                {
                    type = "recipe",
                    name = "solid-tungsten-oxide-smelting-2",
                    category = "liquifying",
                    subgroup = "angels-tungsten-carbide",
                    energy_required = 6,
                    enabled = "false",
                    ingredients ={
                      {type="item", name="solid-tungsten-trioxide", amount=12},
                      {type="fluid", name="gas-hydrogen-chloride", amount=30},
                    },
                    results=
                    {
                      {type="fluid", name="gas-tungsten-hexachloride", amount=60},
                    },
                },
            
                {
                    type = "recipe",
                    name = "tungsten-carbide-smelting-1",
                    category = "chemical-smelting",
                    subgroup = "angels-tungsten-carbide",
                    energy_required = 8,
                    enabled = "false",
                    ingredients ={                        
                        {type="item", name="solid-tungsten-oxide", amount=12},
                        {type="fluid", name="gas-hydrogen", amount=60},
                        {type="fluid", name="gas-argon", amount=30},
                    },
                    results=
                    {
                        {type="item", name="powder-tungsten-carbide", amount=12},
                    },
                        icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide.png",
                        icon_size = 32,
                        order = "aa",
                    },

                    {
                        type = "recipe",
                        name = "tungsten-carbide-smelting-2",
                        category = "chemical-smelting",
                        subgroup = "angels-tungsten-carbide",
                        energy_required = 8,
                        enabled = "false",
                        ingredients ={                        
                            {type="fluid", name="gas-tungsten-hexafluoride", amount=80},
                            {type="fluid", name="gas-hydrogen", amount=60},
                            {type="item", name="solid-carbon", amount=5},
                        },
                        results=
                        {
                            {type="item", name="powder-tungsten-carbide", amount=12},
                            {type="fluid", name="liquid-hydrofluoric-acid", amount=60},
                            {type="fluid", name="water-purified", amount=20},
                        },
                            icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide.png",
                            icon_size = 32,
                            order = "ab",
                        },

                        {
                            type = "recipe",
                            name = "tungsten-carbide-smelting-3",
                            category = "chemical-smelting",
                            subgroup = "angels-tungsten-carbide",
                            energy_required = 8,
                            enabled = "false",
                            ingredients ={                        
                                {type="fluid", name="gas-tungsten-hexachloride", amount=60},
                                {type="fluid", name="gas-hydrogen", amount=50},
                                {type="item", name="solid-carbon", amount=5},
                            },
                            results=
                            {
                                {type="item", name="powder-tungsten-carbide", amount=12},
                                {type="fluid", name="gas-hydrogen-chloride", amount=40},
                            },
                            icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide.png",
                                icon_size = 32,
                                order = "ac",
                            },                

                    {
                        type = "recipe",
                        name = "angels-plate-tungsten-carbide",
                        category = "sintering",
                        subgroup = "angels-tungsten-carbide-casting",
                        normal =
                        {
                          enabled = "false",
                          energy_required = 4,
                          ingredients ={{type="item", name="powder-tungsten-carbide", amount=12}},
                          results={{type="item", name="tungsten-carbide", amount=12}},
                        },
                        expensive =
                        {
                    	  enabled = "false",
	                        energy_required = 4,
	                        ingredients ={{type="item", name="powder-tungsten-carbide", amount=15 * intermediatemulti}},
	                        results={{type="item", name="tungsten-carbide", amount=12}},
                        },
                        icon_size = 32,
                        order = "ad",
                        },

                        {
                            type = "recipe",
                            name = "angels-titanium-concrete-brick",
                            category = "crafting-with-fluid",
                            subgroup = "angels-stone-casting",
                            energy_required = 4,
                            enabled = "false",
                            ingredients ={
                              {type="fluid", name="liquid-concrete", amount=40},
                              {type="item", name="angels-plate-titanium", amount=4},
                            },
                            results=
                            {
                              {type="item", name="titanium-concrete-brick", amount=4},
                            },
                            icon_size = 32,
                            order = "j",
                            },
                
            }
)

if mods["Clowns-Processing"] then 
    bobmods.lib.recipe.add_ingredient("pellet-tungsten-smelting-2", {"solid-tetrasodium-pyrophosphate", 1})
end