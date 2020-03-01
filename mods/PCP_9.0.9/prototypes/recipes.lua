data:extend({
	{
     type = "recipe",
     name = "cumene-process",
     category = "advanced-chemistry",
	 subgroup = "petrochem-chemistry",
     energy_required =3 ,
	 enabled = "false",
     ingredients ={
		{type="fluid", name="gas-benzene", amount=50},
		{type="fluid", name="gas-propene", amount=50},
		{type="fluid", name="gas-oxygen", amount=50}
	 },
     results=
     {
	  	{type="fluid", name="gas-phenol", amount=60},
		{type="fluid", name="liquid-acetone", amount=40}
     },
     icon = "__PCP__/graphics/icons/recipe-cumene.png",
	 icon_size = 32,
     order = "e[cumene-process]",
	},
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
     icon = "__PCP__/graphics/icons/solid-acrylonitrile-butadiene-styrene.png",
	 icon_size = 32,
     order = "b[abs-synthesis]",
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
     icon = "__PCP__/graphics/icons/solid-polyvinyl-chloride.png",
	 icon_size = 32,
     order = "c[pvc-synthesis]",
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
		{type="item", name="solid-bisphenol-a", amount=1},
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
     icon = "__PCP__/graphics/icons/recipe-acrylonitrile.png",
	 icon_size = 32,
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
     icon = "__PCP__/graphics/icons/recipe-vinyl-chloride.png",
	 icon_size = 32,
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
		{type="fluid", name="liquid-acetone", amount=50},
		{type="fluid", name="gas-hydrogen-cyanide", amount=50},
	 },
     results=
     {
	  	{type="fluid", name="liquid-acetone-cyanohydrin", amount=100}
     },
     icon = "__PCP__/graphics/icons/recipe-acetone-cyanohydrin.png",
	 icon_size = 32,
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
     icon = "__PCP__/graphics/icons/recipe-methyl-methacrylate.png",
	 icon_size = 32,
     order = "f",
	},
	{
     type = "recipe",
     name = "bisphenol-a-synthesis",
     category = "chemistry",
	 subgroup = "petrochem-basics",
     energy_required = 2,
	 enabled = "false",
     ingredients ={
		{type="fluid", name="gas-phenol", amount=50},
		{type="fluid", name="liquid-acetone", amount=50},
	 },
     results=
     {
	  	{type="item", name="solid-bisphenol-a", amount=10}
     },
     --icon = "",
     order = "h[bisphenol-a-synthesis]",
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
     icon = "__PCP__/graphics/icons/recipe-phosgene.png",
	 icon_size = 32,
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
     icon = "__PCP__/graphics/icons/recipe-nitrous-oxide-1.png",
	 icon_size = 32,
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
     icon = "__PCP__/graphics/icons/recipe-nitrous-oxide-2.png",
	 icon_size = 32,
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
     --icon = "",
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
	 icon = "__PCP__/graphics/icons/recipe-hydrogen-cyanide.png",
	 icon_size = 32,
	 order = "l"
	},
	--[[ already exist in angelpetrochem (DrD)
	{
     type = "recipe",
     name = "water-gas-shift-reaction",
     category = "chemistry",
	 subgroup = "petrochem-basics",
     energy_required = 2,
	 enabled = "false",
     ingredients ={
		{type="fluid", name="gas-carbon-monoxide", amount=50},
		{type="fluid", name="steam", amount=50},
	 },
     results=
     {
	  	{type="fluid", name="gas-carbon-dioxide", amount=50},
		{type="fluid", name="gas-hydrogen", amount=50}
     },
     icon = "__PCP__/graphics/icons/recipe-water-gas-shift-reaction.png",
	 icon_size = 32,
     order = "f[water-gas-shift-reaction]",
	},
	{
     type = "recipe",
     name = "reverse-water-gas-shift-reaction",
     category = "chemistry",
	 subgroup = "petrochem-basics",
     energy_required = 2,
	 enabled = "false",
     ingredients ={
		{type="fluid", name="gas-hydrogen", amount=50},
		{type="fluid", name="gas-carbon-dioxide", amount=50},
	 },
     results=
     {
	  	{type="fluid", name="water-purified", amount=50},
		{type="fluid", name="gas-carbon-monoxide", amount=50}
     },
     icon = "__PCP__/graphics/icons/recipe-reverse-water-gas-shift-reaction.png",
	 icon_size = 32,
     order = "g[reverse-water-gas-shift-reaction]",
	},
	]]
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
	  	{type="fluid", name="liquid-plastic", amount=10},
     },
     --icon = "",
     order = "da[pmma-plastic]",
	},
	{
     type = "recipe",
     name = "pmma-glass",
     category = "chemistry",
	 subgroup = "petrochem-solids",
     energy_required = 2,
	 enabled = "false",
     ingredients ={
		{type="item", name="solid-pmma", amount=1},
	 },
     results=
     {
	  	{type="item", name="glass", amount=1},
     },
     --icon = "",
     order = "ea[pmma-glass]",
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
	  	{type="fluid", name="liquid-plastic", amount=10},
     },
     --icon = "",
     order = "eb[pc-plastic]",
	},
	{
     type = "recipe",
     name = "pc-glass",
     category = "chemistry",
	 subgroup = "petrochem-solids",
     energy_required = 2,
	 enabled = "false",
     ingredients ={
		{type="item", name="solid-pc", amount=1},
	 },
     results=
     {
	  	{type="item", name="glass", amount=1},
     },
     --icon = "",
     order = "fb[pc-glass]",
	},
	{
    type = "recipe",
    name = "catalyst-metal-cyan",
    category = "crafting",
	subgroup = "petrochem-catalysts",
    energy_required = 2,
	enabled = "false",
    ingredients ={
		{type="item", name="catalyst-metal-carrier", amount=10},
        {type="item", name="zinc-ore", amount=1},
        {type="item", name="gold-ore", amount=1},
	},
    results=
    {
		{type="item", name="catalyst-metal-cyan", amount=10},
    },
    icon = "__PCP__/graphics/icons/catalyst-metal-cyan.png",
	 icon_size = 32,
    order = "e[catalyst-metal-cyan]",
	},
	--[[{
	 type = "recipe",
	 name = "zinc-oxide-processing",
	 category = "",
	 subgroup = "",
	 energy_required =1 ,
	 enabled = "false",
	 ingredients ={
	  {type="item", name="iron-plate", amount=1},
	  {type="fluid", name="gas-oxygen", amount=1},
	 },
	 results ={
	  {type="item", name="solid-zinc-oxide", amount=1},
	 },
	 icon = "",
	 order = ""
	}]]
})
--[[if settings.startup["pcp-enable-experimental"].value then
 data:extend({
  {
    type = "recipe",
    name = "chemical-turret",
    enabled = true,
    energy_required = 5,
    ingredients =
    {
      {"flamethrower-turret", 1},
      {"plastic-bar", 15},
      {"solid-rubber", 10}
    },
    result = "chemical-turret"
  },
  {
    type = "recipe",
    name = "plastic-wall",
    enabled = true,
    energy_required = 1,
    ingredients =
    {
      {"stone-wall", 1},
      {"steel-plate", 1},
      {"plastic-bar", 2}
    },
    result = "plastic-wall"
  },
  {
    type = "recipe",
    name = "plastic-flooring",
    energy_required = 1,
    enabled = true,
    ingredients =
    {
      {"concrete", 1},
      {"steel-plate", 1},
	  {"plastic-bar", 1}
    },
    result= "plastic-flooring"
  },
  {
    type = "recipe",
    name = "chemical-suit",
    enabled = true,
    energy_required = 8,
    ingredients = {{ "heavy-armor", 1}, {"plastic-bar", 50}, {"glass", 20}, {"solid-carbon", 10}},
    result = "chemical-suit"
  },
  --[[{
    type = "recipe",
    name = "plastic-gate",
    enabled = true,
    ingredients = {{"gate", 1}, {"steel-plate", 2}, {"plastic-bar", 4}},
    result = "plastic-gate"
  },
 })
end]]