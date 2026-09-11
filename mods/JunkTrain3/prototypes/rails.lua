local rail_definitions = {
  {
    type = "straight-rail",
    source = "straight-rail",
    name = "straight-scrap-rail",
    health = 50,
    count = 1,
  },
  {
    type = "half-diagonal-rail",
    source = "half-diagonal-rail",
    name = "half-diagonal-scrap-rail",
    health = 50,
    count = 2,
  },
  {
    type = "curved-rail-a",
    source = "curved-rail-a",
    name = "curved-scrap-rail",
    health = 100,
    count = 3,
  },
  {
    type = "curved-rail-b",
    source = "curved-rail-b",
    name = "curved-scrap-rail-b",
    health = 100,
    count = 3,
  },
}

local palette = {
  metals = {r = 0.72, g = 0.43, b = 0.20, a = 1},
  backplates = {r = 0.62, g = 0.38, b = 0.18, a = 1},
  ties = {r = 0.82, g = 0.52, b = 0.25, a = 1},
  stone_path = {r = 0.62, g = 0.38, b = 0.18, a = 1},
  stone_path_background = {r = 0.55, g = 0.31, b = 0.13, a = 1},
}

local function tint_sprites(node, tint)
  if type(node) ~= "table" then
    return
  end
  if node.filename or node.filenames then
    node.tint = tint
    return
  end
  for _, child in pairs(node) do
    tint_sprites(child, tint)
  end
end

local function apply_primitive_palette(pictures)
  for _, direction in pairs({"north", "northeast", "east", "southeast", "south", "southwest", "west", "northwest"}) do
    local part = pictures[direction]
    if part then
      for layer, tint in pairs(palette) do
        tint_sprites(part[layer], tint)
      end
    end
  end
  if pictures.rail_endings then
    tint_sprites(pictures.rail_endings, palette.backplates)
  end
end

local rails = {}
for _, definition in ipairs(rail_definitions) do
  local target = data.raw[definition.type][definition.source]
  target.fast_replaceable_group = "rail"

  local rail = table.deepcopy(target)
  rail.name = definition.name
  rail.localised_name = {"entity-name.scrap-rail"}
  rail.localised_description = {"entity-description.scrap-rail"}
  rail.icon = definition.type == "straight-rail"
    and "__JunkTrain3__/graphics/rail/rail.png"
    or "__JunkTrain3__/graphics/rail/curved-rail.png"
  rail.icons = nil
  rail.icon_size = 32
  rail.minable = {mining_time = 0.2, result = "scrap-rail", count = definition.count}
  rail.placeable_by = {item = "scrap-rail", count = definition.count}
  rail.max_health = definition.health
  rail.resistances = nil
  rail.next_upgrade = definition.source
  rail.fast_replaceable_group = "rail"
  rail.factoriopedia_alternative = "straight-scrap-rail"
  apply_primitive_palette(rail.pictures)
  rails[#rails + 1] = rail
end

data:extend(rails)

data:extend({
  {
    type = "rail-planner",
    name = "scrap-rail",
    icon = "__JunkTrain3__/graphics/rail/rail.png",
    icon_size = 32,
    subgroup = "transport-rail",
    order = "a",
    place_result = "straight-scrap-rail",
    stack_size = 200,
    rails = {
      "straight-scrap-rail",
      "curved-scrap-rail",
      "curved-scrap-rail-b",
      "half-diagonal-scrap-rail",
    },
    manual_length_limit = 22.5,
    localised_description = {"item-description.scrap-rail"},
  },
})
