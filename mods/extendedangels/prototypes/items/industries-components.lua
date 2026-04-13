if not (mods["angelsindustries"] and angelsmods.industries.components) then
  return
end

data:extend({
  {
    type = "item",
    name = "block-construction-0", -- required at start
    icon = "__angelsindustriesgraphics__/graphics/icons/block-construction-1.png",
    icon_size = 32,
    subgroup = "blocks-frames",
    order = "a",
    stack_size = 200,
  },
})
