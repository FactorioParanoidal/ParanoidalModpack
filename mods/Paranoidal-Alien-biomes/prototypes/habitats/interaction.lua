-- Optional fieldwork: no item, technology, recipe, reward or global ambience override.
local sounds = require("__base__/prototypes/entity/sounds")
local definitions = {{
  type = "shortcut", name = "ab-habitat-fieldbook", action = "lua",
  icon = "__core__/graphics/icons/mip/map.png", icon_size = 32,
  small_icon = "__core__/graphics/icons/mip/map.png", small_icon_size = 32,
  order = "z[alien-biomes]-a[fieldbook]",
}}
for _, entry in ipairs({
  {"spring", sounds.tree_ambient}, {"summer", sounds.tree_insects_night},
  {"fall", sounds.tree_ambient_leaves}, {"winter", sounds.tree_ambient_leaves},
}) do
  definitions[#definitions + 1] = {
    type = "sound", name = "ab-habitat-season-" .. entry[1],
    -- Retain native daytime gating. Winter leaves are deliberately quieter.
    variations = table.deepcopy(entry[2].sound.variations),
    advanced_volume_control = table.deepcopy(entry[2].sound.advanced_volume_control),
  }
end
data:extend(definitions)
