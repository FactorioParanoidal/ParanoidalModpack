arrow = util.table.deepcopy(data.raw["arrow"]["orange-arrow-with-circle"])
arrow.name = "orphan-arrow"
arrow.circle_picture =
{
  filename = "__Orphan Finder__/graphics/large-orange-circle.png",
  draw_as_glow = true,
  priority = "low",
  width = 64,
  height = 64
}
arrow.arrow_picture.draw_as_glow = true

data:extend({
  arrow,
  {
    type = "custom-input",
    name = "find-orphans",
    key_sequence = "SHIFT + O"
  }
})