local flib_table = require("__flib__.table")

local util = require("scripts.util")

--- @type table<string, LuaItemPrototype[]>
local subgroups = {}
for subgroup_name in pairs(prototypes.item_subgroup) do
  local subgroup = {}
  local prototypes = prototypes.get_item_filtered({ { filter = "subgroup", subgroup = subgroup_name } })
  for _, item in pairs(prototypes) do
    if not item.has_flag("spawnable") and not item.hidden then
      subgroup[#subgroup + 1] = item
    end
  end
  subgroups[subgroup_name] = subgroup
end

--- @param e EventData.CustomInputEvent
--- @param delta integer
local function scroll_item(e, delta)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local item = util.get_cursor_item(player)
  if not item then
    return
  end
  local subgroup_name = item.name.subgroup.name
  if not subgroup_name then
    return
  end
  local subgroup = subgroups[subgroup_name]
  local index = flib_table.find(subgroup, item.name)
  if not index then
    return
  end
  local new_item = subgroup[index + delta]
  if not new_item then
    return
  end
  if not util.set_cursor(player, { name = new_item, quality = item.quality }) then
    return
  end
  --- @type LocalisedString
  local text = { "", "[img=item/" .. new_item.name .. "]", new_item.localised_name }
  if item.quality ~= prototypes.quality.normal then
    text[#text + 1] = { "", " (", item.quality.localised_name, ")" }
  end
  player.create_local_flying_text({ text = text, create_at_cursor = true })
end

local scroll_subgroup = {}

scroll_subgroup.events = {
  --- @param e EventData.CustomInputEvent
  ["cen-scroll-next"] = function(e)
    scroll_item(e, 1)
  end,
  --- @param e EventData.CustomInputEvent
  ["cen-scroll-previous"] = function(e)
    scroll_item(e, -1)
  end,
}

return scroll_subgroup
