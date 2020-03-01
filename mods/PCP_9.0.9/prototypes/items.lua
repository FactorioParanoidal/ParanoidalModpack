data:extend({
--[[{
    type = "item",
    name = "solid-zinc-oxide",
    icon = "",
    --flags = {},
	subgroup = "",
    order = "",
    stack_size = 
},]]
{
    type = "item",
    name = "solid-pvc",
    icon = "__PCP__/graphics/icons/solid-polyvinyl-chloride.png",
	icon_size = 32,
    --flags = {},
	--subgroup = "",
    --order = "",
    stack_size = 1
},
{
    type = "item",
    name = "solid-abs",
    icon = "__PCP__/graphics/icons/solid-acrylonitrile-butadiene-styrene.png",
	icon_size = 32,
    --flags = {},
	--subgroup = "",
    --order = "",
    stack_size = 1
},
{
    type = "item",
    name = "solid-pmma",
    icon = "__PCP__/graphics/icons/solid-polymethyl-methacrylate.png",
	icon_size = 32,
    --flags = {},
	--subgroup = "",
    --order = "",
    stack_size = 100
},
{
    type = "item",
    name = "solid-pc",
    icon = "__PCP__/graphics/icons/solid-polycarbonate.png",
	icon_size = 32,
    --flags = {},
	--subgroup = "",
    --order = "",
    stack_size = 100
},
{
    type = "item",
    name = "solid-ammonium-sulphate",
    icon = "__PCP__/graphics/icons/solid-ammonium-sulphate.png",
	icon_size = 32,
    --flags = {},
	--subgroup = "",
    --order = "",
    stack_size = 100
},
{
    type = "item",
    name = "solid-sodium-nitrate",
    icon = "__PCP__/graphics/icons/solid-sodium-nitrate.png",
	icon_size = 32,
    --flags = {},
	--subgroup = "",
    --order = "",
    stack_size = 100
},
{
	type = "item",
	name = "solid-bisphenol-a",
	icon = "__PCP__/graphics/icons/solid-bisphenol-a.png",
	icon_size = 32,
	--flags = {},
	--subgroup = "",
	--order = "",
	stack_size =100
},
{
    type = "item",
    name = "catalyst-metal-cyan",
    icon = "__PCP__/graphics/icons/catalyst-metal-cyan.png",
	icon_size = 32,
    --flags = {},
	subgroup = "petrochem-raw",
    order = "e[catalyst-metal-cyan]",
    stack_size = 100
}
})
--[[if settings.startup["pcp-enable-experimental"].value then
 data:extend({
  {
    type = "item",
    name = "chemical-turret",
    icon = "__base__/graphics/icons/flamethrower-turret.png",
	icon_size = 32,
    --flags = {},
    subgroup = "defensive-structure",
    order = "b[turret]-c[chemical-turret]",
    place_result = "chemical-turret",
    stack_size = 50
  },
  {
    type = "armor",
    name = "chemical-suit",
    icon = "__base__/graphics/icons/heavy-armor.png",
	icon_size = 32,
    --flags = {},
    resistances =
    {
      {
        type = "physical",
        decrease = 6,
        percent = 30
      },
      {
        type = "poison",
        decrease = 0,
        percent = 100
      },
      {
        type = "acid",
        decrease = 0,
        percent = 100
      },
      {
        type = "chemical",
        decrease = 0,
        percent = 100
      }
    },
    durability = 5000,
    subgroup = "armor",
    order = "b[heavy-armor]",
    stack_size = 10
  },
  {
    type = "item",
    name = "plastic-flooring",
    icon = "__base__/graphics/icons/concrete.png",
	icon_size = 32,
    --flags = {},
    subgroup = "terrain",
    order = "b[plastic-flooring]-a[plain]",
    stack_size = 100,
    place_as_tile =
    {
      result = "plastic-flooring",
      condition_size = 4,
      condition = { "water-tile" }
    }
  },]]
  --[[{
    type = "item",
    name = "plastic-gate",
    icon = "__base__/graphics/icons/gate.png",
	icon_size = 32,
    --flags = {},
    subgroup = "defensive-structure",
    order = "a[wall]-b[plastic-gate]",
    place_result = "plastic-gate",
    stack_size = 50
  },
 })
end]]