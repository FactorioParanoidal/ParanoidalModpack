-- Item subgroup, recipe category, droid items, buildings, the drop pod and the squad command tool.
local shared = require("lib.shared")

local ICONS = shared.mod_path .. "/graphics/icons/"
local B = shared.buildings
local loot_chest = settings.startup[shared.setting.loot_chest].value

local prototypes = {
  {type = "item-subgroup", name = "robotarmy-droids", group = "combat", order = "c-2"},
  {type = "item-subgroup", name = "robotarmy-deploy", group = "combat", order = "c-3"},
  {type = "recipe-category", name = "droids"},
}

local function add(p)
  prototypes[#prototypes + 1] = p
end

local own_units = {} -- droid units of this mod (Bob's drones keep their own items)
for i, d in pairs(shared.droids) do
  if not d.external then
    own_units[#own_units + 1] = d.unit
    add({
      type = "item",
      name = d.unit,
      icons = shared.droid_icons(d.unit),
      place_result = d.unit,
      stack_size = 25,
      subgroup = "robotarmy-droids",
      order = string.format("z[droid]-%02d", i),
    })
  end
end

-- Drop pod: carries a squad (tags written by the control script); placed, it opens and lands it.
add({
  type = "item-with-tags",
  name = shared.pod.item,
  icons = {{icon = ICONS .. "loot-chest.png", icon_size = 64, tint = {r = 0.6, g = 0.75, b = 0.45}}},
  place_result = shared.pod.entity,
  stack_size = 1,
  subgroup = "robotarmy-droids",
  order = "z[droid]-99",
})

local function building_item(name, subgroup, order)
  add({
    type = "item",
    name = name,
    icon = ICONS .. name .. ".png",
    icon_size = 64,
    subgroup = subgroup,
    order = order,
    place_result = name,
    stack_size = 50,
  })
end

building_item(B.assembler, "production-machine", "b[droid-assembling-machine]")
building_item(B.station, "production-machine", "b[droid-guard-station]")
building_item(B.counter, "circuit-network", "b[combinators]-e[droid-counter]")
if loot_chest then
  building_item(B.loot, "storage", "a[items]-c[loot-chest]")
end

-- Squad command tool.
-- select (drag / click):        pick the squad of the selected droids
-- alt-select (Shift + drag):    the picked squad attack-moves to the middle of the box
-- reverse-select (right drag):  pick up the selected droids
-- alt-reverse-select (Shift + right drag): merge the squads of the selected droids
-- The entity filters get the rank prototypes and Bob's drones in data-updates (prototypes/ranks.lua).
local droid_mode = {
  border_color = {r = 0, g = 1, b = 0},
  mode = {"same-force", "any-entity"},
  cursor_box_type = "copy",
  entity_type_filters = {"unit"},
  entity_filters = own_units,
}
local pickup_mode = {
  border_color = {r = 1, g = 0.2, b = 0.2},
  mode = {"same-force", "any-entity"},
  cursor_box_type = "not-allowed",
  entity_type_filters = {"unit"},
  entity_filters = own_units,
}
add({
  type = "selection-tool",
  name = shared.tool,
  icon = ICONS .. "selection_tool.png",
  icon_size = 64,
  flags = {"only-in-cursor", "spawnable", "not-stackable"},
  subgroup = "tool",
  order = "d[droid-control]-s[command]",
  stack_size = 1,
  select = droid_mode,
  alt_select = {border_color = {r = 1, g = 0.6, b = 0}, mode = {"nothing"}, cursor_box_type = "entity"},
  reverse_select = pickup_mode,
  alt_reverse_select = {
    border_color = {r = 0.2, g = 0.7, b = 1},
    mode = {"same-force", "any-entity"},
    cursor_box_type = "pair",
    entity_type_filters = {"unit"},
    entity_filters = own_units,
  },
})

data:extend(prototypes)
