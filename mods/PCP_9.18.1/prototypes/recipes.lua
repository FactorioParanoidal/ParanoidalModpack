data:extend({
	{
		type = "recipe",
		name = "liquid-plastic-abs",
		category = "advanced-chemistry",
		subgroup = "petrochem-solids",
		energy_required =3 ,
		enabled = "false",
		ingredients ={
			{type="fluid", name="gas-butadiene", amount=20},
			{type="fluid", name="gas-styrene", amount=50},
			{type="fluid", name="liquid-acrylonitrile", amount=30}
		},
		results=
		{
			{type="fluid", name="liquid-plastic", amount=100}
		},
		icons = {
			{
				icon = "__PCP__/graphics/icons/solid-acrylonitrile-butadiene-styrene.png",
				icon_size=32,
			},
			{
				icon = "__angelspetrochem__/graphics/icons/num_4.png",
				tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
				scale = 0.32,
				shift = {-12, -12},
			}
		},
		icon_size = 32,
		order = "b[abs-synthesis]",
	},
	{
		type = "recipe",
		name = "liquid-plastic-pc",
		category = "chemistry",
		subgroup = "petrochem-solids",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="item", name="solid-pc", amount=1},
		},
		results=
		{
			{type="fluid", name="liquid-plastic", amount=20},--10
		},
		order = "eb[pc-plastic]",
		icons = {
			{
				icon = "__angelspetrochem__/graphics/icons/liquid-plastic.png",
			},
			{
				icon = "__angelspetrochem__/graphics/icons/num_1.png",
				tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
				scale = 0.32,
				shift = {-12, -12},
			}
		},
		icon_size = 32,
	},
	{
		type = "recipe",
		name = "liquid-plastic-pvc",
		category = "chemistry",
		subgroup = "petrochem-solids",
		energy_required =2 ,
		enabled = "false",
		ingredients ={
			{type="fluid", name="liquid-naphtha", amount=5},
			{type="fluid", name="gas-vinyl-chloride", amount=30},
		},
		results=
		{
			{type="fluid", name="liquid-plastic", amount=20}
		},
		order = "c[pvc-synthesis]",
		icons = {
			{
				icon = "__PCP__/graphics/icons/solid-polyvinyl-chloride.png",
			},
			{
				icon = "__angelspetrochem__/graphics/icons/num_2.png",
				tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
				scale = 0.32,
				shift = {-12, -12},
			}
		},
		icon_size = 32,
	},
	{
		type = "recipe",
		name = "pmma-synthesis",
		category = "chemistry",
		subgroup = "petrochem-solids",
		energy_required = 1,
		enabled = "false",
		ingredients ={
			{type="fluid", name="liquid-methyl-methacrylate", amount=20},
		},
		results=
		{
			{type="item", name="solid-pmma", amount=1}
		},
		icon = "__PCP__/graphics/icons/solid-polymethyl-methacrylate.png",
		icon_size = 32,
		order = "i[pmma-synthesis]",
	},
	{
		type = "recipe",
		name = "pc-synthesis",
		category = "chemistry",
		subgroup = "petrochem-solids",
		energy_required = 1,
		enabled = "false",
		ingredients ={
			{type="fluid", name="gas-bisphenol-a", amount=10},
			{type="fluid", name="gas-phosgene", amount=10},
		},
		results=
		{
			{type="item", name="solid-pc", amount=1}
		},
		icon = "__PCP__/graphics/icons/solid-polycarbonate.png",
		icon_size = 32,
		order = "j[pc-synthesis]",
	},
	{
		type = "recipe",
		name = "acrylonitrile-synthesis",
		category = "chemistry",
		subgroup = "petrochem-nitrogen",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="fluid", name="gas-propene", amount=100},
			{type="fluid", name="gas-ammonia", amount=100},
			{type="item", name="catalyst-metal-cyan", amount=1}
		},
		results=
		{
			{type="fluid", name="liquid-acrylonitrile", amount=100},
			{type="item", name="catalyst-metal-carrier", amount=1}
		},
		icons =generate_fluid_recipe_icons("acrylonitrile","cnh","liq"),
		order = "j[acryllonitrile-synthesis]",
	},
	{
		type = "recipe",
		name = "vinyl-chloride-synthesis",
		category = "chemistry",
		subgroup = "petrochem-chlorine",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="fluid", name="gas-ethylene", amount=150},
			{type="fluid", name="gas-chlorine", amount=75},
			{type="item", name="catalyst-metal-red", amount=1},
			{type="item", name="catalyst-metal-blue", amount=1}
		},
		results=
		{
			{type="fluid", name="gas-vinyl-chloride", amount=75},
			{type="item", name="catalyst-metal-carrier", amount=2}
		},
		icons =generate_fluid_recipe_icons("vinyl_chloride","clh","gas"),
		order = "j",
	},
	{
		type = "recipe",
		name = "acetone-cyanohydrin-synthesis",
		category = "chemistry",
		subgroup = "petrochem-nitrogen",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="fluid", name="gas-acetone", amount=50},
			{type="fluid", name="gas-hydrogen-cyanide", amount=50},
		},
		results=
		{
			{type="fluid", name="liquid-acetone-cyanohydrin", amount=100}
		},
		icons =generate_fluid_recipe_icons("acetone_cyanohydrin","con","liq"),
		order = "m[acetone-cyanohydrin-synthesis]",
	},
	{
		type = "recipe",
		name = "methyl-methacrylate-synthesis",
		category = "advanced-chemistry",
		subgroup = "petrochem-chemistry",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="fluid", name="liquid-acetone-cyanohydrin", amount=50},
			{type="fluid", name="gas-methanol", amount=100},
			{type="fluid", name="liquid-sulfuric-acid", amount=50}
		},
		results=
		{
			{type="fluid", name="liquid-methyl-methacrylate", amount=50},
			{type="item", name="solid-ammonium-sulphate", amount=5}
		},
		icons =generate_fluid_recipe_icons("methyl_methacrylate","cho","liq"),
		order = "f",
	},
	{
		type = "recipe",
		name = "phosgene-synthesis",
		category = "chemistry",
		subgroup = "petrochem-chlorine",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="fluid", name="gas-carbon-monoxide", amount=50},
			{type="fluid", name="gas-chlorine", amount=50},
		},
		results=
		{
			{type="fluid", name="gas-phosgene", amount=100}
		},
		icons =generate_fluid_recipe_icons("phosgene","clo","gas"),
		order = "k[phosgene-synthesis]",
	},
	{
		type = "recipe",
		name = "nitrous-oxide-synthesis-1",
		category = "advanced-chemistry",
		subgroup = "petrochem-nitrogen",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="fluid", name="gas-urea", amount=50},
			{type="fluid", name="liquid-nitric-acid", amount=20},
			{type="fluid", name="liquid-sulfuric-acid", amount=30}
		},
		results=
		{
			{type="item", name="solid-ammonium-sulphate", amount=4},
			{type="fluid", name="gas-nitrous-oxide", amount=60}
		},
		--[[icon = "__PCP__/graphics/icons/recipe-nitrous-oxide-1.png",
		icon_size = 32,]]
		icons=generate_complex_fluid_recipe_icons("nitrous_oxide","nno","gas","ammonium_sulphate","","",""),--product1,formcode,state,product2,product3,input1,input2
		order = "k[nitrous-oxide-synthesis-1]",
	},
	{
		type = "recipe",
		name = "nitrous-oxide-synthesis-2",
		category = "chemistry",
		subgroup = "petrochem-nitrogen",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="item", name="solid-ammonium-sulphate", amount=5},
			{type="item", name="solid-sodium-nitrate", amount=5},
		},
		results=
		{
			{type="fluid", name="gas-nitrous-oxide", amount=100}
		},
		icons =generate_fluid_recipe_icons("nitrous_oxide","nno","gas"),
		order = "l[nitrous-oxide-synthesis-2]",
	},
	{
		type = "recipe",
		name = "sodium-nitrate-synthesis",
		category = "liquifying",
		subgroup = "petrochem-basics",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="item", name="solid-sodium-hydroxide", amount=5},
			{type="fluid", name="liquid-nitric-acid", amount=50},
		},
		results=
		{
			{type="item", name="solid-sodium-nitrate", amount=10}
		},
		order = "i[sodium-nitrate-synthesis]",
	},
	{
		type = "recipe",
		name = "hydrogen-cyanide-synthesis",
		category = "advanced-chemistry",
		subgroup = "petrochem-nitrogen",
		energy_required = 1,
		enabled = "false",
		ingredients ={
			{type="fluid", name="gas-methane", amount=20},
			{type="fluid", name="gas-ammonia", amount=20},
			{type="fluid", name="gas-oxygen", amount=30},
			{type="item", name="catalyst-metal-green", amount=1}
		},
		results ={
			{type="fluid", name="gas-hydrogen-cyanide", amount=20},
			{type="item", name="catalyst-metal-carrier", amount=1}
		},
		icons =generate_fluid_recipe_icons("hydrogen_cyanide","cnh","gas"),
		order = "l"
	},
	{
		type = "recipe",
		name = "liquid-plastic-pmma",
		category = "chemistry",
		subgroup = "petrochem-solids",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="item", name="solid-pmma", amount=1},
		},
		results=
		{
			{type="fluid", name="liquid-plastic", amount=30},--10
		},
		order = "da[pmma-plastic]",
		icons = {
			{
				icon = "__PCP__/graphics/icons/solid-polymethyl-methacrylate.png",
				icon_size=32,
			},
			{
				icon = "__angelspetrochem__/graphics/icons/num_3.png",
				tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
				scale = 0.32,
				shift = {-12, -12},
			}
		},
		icon_size = 32,
	},
	{
		type = "recipe",
		name = "catalyst-metal-cyan",
		category = "crafting",
		subgroup = "petrochem-catalysts",
		energy_required = 2,
		enabled = "false",
		ingredients ={
			{type="item", name="iron-plate", amount=1},
			{type="item", name="copper-plate", amount=1},
		},
		results=
		{
			{type="item", name="catalyst-metal-cyan", amount=10},
		},
		icon = "__PCP__/graphics/icons/catalyst-metal-cyan.png",
		icon_size = 32,
		order = "e[catalyst-metal-cyan]",
	},
	{
		type = "recipe",
		name = "liquid-fuel-oil-catalyst",
		category = "advanced-chemistry",
		subgroup = "petrochem-carbon-oil-feed",
		energy_required = 6,
		enabled = "false",
		ingredients ={
			{type="fluid", name="gas-nitrous-oxide", amount=20},
			{type="fluid", name="liquid-cupric-chloride-solution", amount=30},
			{type="fluid", name="gas-synthesis", amount=90},
			{type="item", name="catalyst-metal-blue", amount=1},
		},
		results=
		{
			{type="fluid", name="liquid-fuel-oil", amount=80},
			{type="item", name="catalyst-metal-carrier", amount=1},
		},
		icons =generate_fluid_recipe_icons("fuel_oil","ffy","liq"),
		order = "f"
	},
	{
    type = "recipe",
    name = "PF-resin",
    category = "chemistry",
	subgroup = "petrochem-solids",
    energy_required = 3,
	enabled = "false",
    ingredients ={
		{type="fluid", name="gas-formaldehyde", amount=20},
		{type="fluid", name="gas-phenol", amount=20},
	},
	results={{type="fluid", name="liquid-resin", amount=40}},
    icons = {
		{
			icon = "__angelspetrochem__/graphics/icons/liquid-resin.png",
		},
		{
			icon = "__angelspetrochem__/graphics/icons/num_4.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
			scale = 0.32,
			shift = {-12, -12},
		}
	},
	icon_size = 32,
    order = "e",
	},
})
