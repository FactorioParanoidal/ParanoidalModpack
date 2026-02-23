data:extend({
  --plastics
  --[[{
    type = "item",
    name = "solid-pvc",
    icon = "__PCPRedux__/graphics/icons/solid-polyvinyl-chloride.png",
    icon_size = 32,
    subgroup = "angels-petrochem-solids-fluids",
    order = "d[solid-pvc]",
    stack_size = 1
  },]]
  --[[{
    type = "item",
    name = "solid-abs",
    icon = "__PCPRedux__/graphics/icons/solid-acrylonitrile-butadiene-styrene.png",
    icon_size = 32,
    subgroup = "angels-petrochem-solids-fluids",
    order = "d[solid-abs]",
    stack_size = 1
  },]]
  {
    type = "item",
    name = "solid-pc",
    icon = "__PCPRedux__/graphics/icons/solid-polycarbonate.png",
    icon_size = 32,
    subgroup = "angels-petrochem-solids-fluids",
    order = "d[solid-pc]",
    stack_size = 100
  },
  {
    type = "item",
    name = "solid-pmma",
    icon = "__PCPRedux__/graphics/icons/solid-polymethyl-methacrylate.png",
    icon_size = 32,
    subgroup = "angels-petrochem-solids-fluids",
    order = "d[solid-pmma]",
    stack_size = 100
  },
  --misc
  {
    type = "item",
    name = "solid-ammonium-sulphate",
    icon = "__PCPRedux__/graphics/icons/solid-ammonium-sulphate.png",
    icon_size = 32,
    subgroup = "angels-petrochem-sulfur",
    order = "a[solid-ammonium-sulphate]",
    stack_size = 100
  },
  {
    type = "item",
    name = "solid-sodium-nitrate",
    icon = "__PCPRedux__/graphics/icons/solid-sodium-nitrate.png",
    icon_size = 32,
    subgroup = "angels-petrochem-sodium",
    order = "a[solid-sodium-nitrate]",
    stack_size = 100
  },
  {
    type = "item",
    name = "catalyst-metal-cyan",
    icon = "__PCPRedux__/graphics/icons/catalyst-metal-cyan.png",
    icon_size = 32,
    subgroup = "angels-petrochem-catalysts",
    order = "e[catalyst-metal-cyan]",
    stack_size = 100
  },
})
--rubbers

if mods.bobplates or mods.apm_resource_pack_ldinc and (data.raw.item["angels-solid-rubber"] or data.raw.item["bob-rubber"]) then
  data:extend({
    {
      type = "item",
      name = "solid-rubber-additive",
      icon = "__PCPRedux__/graphics/icons/solid-rubber-additive.png",
      icon_size = 64,
      subgroup = "angels-petrochem-solids",
      order = "f[rubber-additive]",
      stack_size = 100
    },
    {
      type = "item",
      name = "solid-rubber-block",
      icon = "__PCPRedux__/graphics/icons/solid-rubber-block.png",
      icon_size = 64,
      subgroup = "angels-petrochem-solids",
      order = "f[rubber-block]",
      stack_size = 100
    },
    {
      type = "item",
      name = "solid-rubber-slab",
      icon = "__PCPRedux__/graphics/icons/solid-rubber-slab.png",
      icon_size = 64,
      subgroup = "angels-petrochem-solids",
      order = "f[rubber-slab]",
      stack_size = 100
    },
    {
      type = "item",
      name = "solid-rubber-pellet",
      icon = "__PCPRedux__/graphics/icons/solid-rubber-pellet.png",
      icon_size = 64,
      subgroup = "angels-petrochem-solids",
      order = "f[rubber-pellet]",
      stack_size = 100
    },
    {
      type = "item",
      name = "solid-rubber-powder",
      icon = "__PCPRedux__/graphics/icons/solid-rubber-powder.png",
      icon_size = 64,
      subgroup = "angels-petrochem-solids",
      order = "f[rubber-powder]",
      stack_size = 100
    },
    {
      type = "item",
      name = "solid-rubber-vulcanised",
      icon = "__angelspetrochemgraphics__/graphics/icons/solid-rubber.png",
      icon_size = 32,
      subgroup = "angels-petrochem-solids",
      order = "f[rubber-vulcanised]",
      stack_size = 100
    },
    {
      type = "item",
      name = "solid-rubber-waste",
      icon = "__PCPRedux__/graphics/icons/solid-rubber-waste.png",
      icon_size = 64,
      subgroup = "angels-petrochem-solids",
      order = "f[rubber-waste]",
      stack_size = 100
    },
    {
      type = "item",
      name = "angels-roll-rubber",
      icons = { { icon = "__PCPRedux__/graphics/icons/roll-blank.png", tint = { r = 0, g = 0, b = 0 }, icon_size = 32 } },
      subgroup = "angels-petrochem-solids",
      order = "ya",
      stack_size = 200
    },
  })
end
--[[if settings.startup["pcp-enable-experimental"].value then
data:extend({
{
type = "item",
name = "chemical-turret",
icon = "__base__/graphics/icons/flamethrower-turret.png",
icon_size = 32,
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
]]
