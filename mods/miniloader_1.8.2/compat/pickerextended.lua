local util = require("lualib.util")

-- compatibility with PickerExtended mod
local M = {}


local function on_dolly_moved(event)
  local entity = event.moved_entity
  if not util.is_miniloader_inserter(entity) then
    return
  end

  local old_pos = event.start_pos
  local new_pos = entity.position

  -- move inserters
  local partners = entity.surface.find_entities_filtered{
    position = old_pos,
    type = "inserter",
  }
  for _, ent in ipairs(partners) do
    ent.teleport(new_pos)
  end

  local loader = entity.surface.find_entities_filtered{
    position = old_pos,
    type = "loader",
  }[1]

  local new_loader = entity.surface.create_entity{
    name = loader.name,
    position = new_pos,
    direction = loader.direction,
    force = loader.force,
    type = loader.loader_type,
  }

  -- move items on belt
  for i=1,2 do
    local old_tl = loader.get_transport_line(i)
    local new_tl = new_loader.get_transport_line(i)
    for j=1, #old_tl do
      new_tl.insert_at_back(old_tl[j])
    end
    old_tl.clear()
  end

  loader.destroy()
end

function M.on_load()
  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
    local on_dolly_moved_event = remote.call("PickerDollies", "dolly_moved_entity_id")
    script.on_event(on_dolly_moved_event, on_dolly_moved)
  end
end

return M
