-- Factorio 2.1 (Paranoidal port): MiningDrillPrototype::base_picture (Sprite4Way) and base_render_layer were moved
-- to graphics_set.working_visualisations; the old fields are silently ignored (the drill is drawn without its base).
-- The returned function moves them into an always drawn visualisation with the same picture, on the 2.0 layer
-- (base_render_layer, default "lower-object"), first in every graphics set of the drill.
local DIRECTIONS = { "north", "east", "south", "west" }

local function base_visualisation(picture, render_layer)
  local visualisation = { always_draw = true, secondary_draw_order = -1, render_layer = render_layer or "lower-object" }
  local sheets = picture.sheets or (picture.sheet and { picture.sheet })
  if sheets then
    -- SpriteNWaySheet: `frames` directions (default 4) side by side in one file.
    for index, direction in ipairs(DIRECTIONS) do
      local layers = {}
      for _, sheet in ipairs(sheets) do
        local layer = table.deepcopy(sheet)
        local frames = layer.frames or 4
        local width = layer.width or (type(layer.size) == "table" and layer.size[1]) or layer.size
        layer.frames = nil
        layer.x = (layer.x or 0) + width * ((index - 1) % frames)
        layers[#layers + 1] = layer
      end
      visualisation[direction .. "_animation"] = { layers = layers }
    end
  elseif picture.north then
    for _, direction in ipairs(DIRECTIONS) do
      visualisation[direction .. "_animation"] = table.deepcopy(picture[direction])
    end
  else
    visualisation.animation = table.deepcopy(picture)
  end
  return visualisation
end

return function(drill)
  if not (drill and drill.base_picture) then
    return
  end
  local visualisation = base_visualisation(drill.base_picture, drill.base_render_layer)
  drill.graphics_set = drill.graphics_set or {}
  for _, set in pairs({ drill.graphics_set, drill.wet_mining_graphics_set }) do
    set.working_visualisations = set.working_visualisations or {}
    table.insert(set.working_visualisations, 1, table.deepcopy(visualisation))
  end
  drill.base_picture, drill.base_render_layer = nil, nil
end
