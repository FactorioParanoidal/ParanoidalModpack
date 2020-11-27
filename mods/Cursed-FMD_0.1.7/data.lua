
local obj = util.table.deepcopy(data.raw["selection-tool"]["selection-tool"])
obj.name = "filter-drills"
obj.icon = "__Cursed-FMD__/icon_64.png"
obj.icon_size = 64
obj.selection_color = {r=0.66, g=0.93, b=0.30}
obj.alt_selection_color = obj.selection_color
obj.selection_mode = {"any-entity"}
obj.alt_selection_mode = obj.selection_mode
obj.entity_filters = nil
obj.alt_entity_filters = obj.entity_filters
obj.entity_type_filters = {"mining-drill"}
obj.entity_type_filters = obj.entity_type_filters
obj.show_in_library = true
obj.localised_name = {"gui-control-behavior-modes.set-filters"}
data.raw[obj.type][obj.name] = obj

data.raw["sprite"]["Cursed-FMD"] =
{
    type = "sprite",
    name = "Cursed-FMD",
    filename = "__Cursed-FMD__/icon_64.png",
    width = 64,
    height = 64
}

data.raw["shortcut"]["Cursed-FMD"] = {
    type = "shortcut",
    name = "Cursed-FMD",
    action = "spawn-item",
    item_to_spawn = "filter-drills",
    order = "zy",
    localised_name = {"gui-control-behavior-modes.set-filters"},
    icon = {
      filename = "__Cursed-FMD__/icon_64.png",
      size = 64,
      scale = 0.25,
      flags = {"gui-icon"}
    }
  }