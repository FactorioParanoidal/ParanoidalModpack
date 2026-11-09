-- Shared names, per-player state and small helpers of the tester panel.
local M = {}

M.SETTING = "paranoidal-sa-tester-enabled"
M.SHORTCUT = "paranoidal-sa-tester"
M.INPUT = "paranoidal-sa-tester-toggle"
M.WINDOW = "pst_window"

-- Amounts offered in the "how many" list: a number or a count of stacks.
M.COUNTS = {
  {n = 1}, {n = 10}, {n = 50}, {stacks = 1}, {stacks = 5},
}

function M.enabled()
  local s = settings.global[M.SETTING]
  return not s or s.value == true
end

function M.init_storage()
  storage.players = storage.players or {}
  storage.forces = storage.forces or {}
  storage.power = storage.power or {}
end

-- Per-player state; fields are filled lazily, so saves of older versions keep working.
function M.pdata(player)
  M.init_storage()
  local d = storage.players[player.index]
  if not d then
    d = {}
    storage.players[player.index] = d
  end
  d.quality = d.quality or "normal"
  d.count = d.count or 2
  d.modes = d.modes or {}
  d.refs = d.refs or {}
  d.fluid_temperature = d.fluid_temperature or nil
  d.tab = d.tab or 1
  return d
end

function M.fdata(force)
  M.init_storage()
  local d = storage.forces[force.index]
  if not d then
    d = {}
    storage.forces[force.index] = d
  end
  return d
end

-- Message for the player who acted: at the cursor and in the chat (chat keeps a record for bug reports).
function M.say(player, message)
  if not (player and player.valid) then return end
  player.print({"", "[color=255,200,120]", {"pst.prefix"}, "[/color] ", message}, {skip = defines.print_skip.never})
  if player.connected then
    pcall(player.create_local_flying_text, {text = message, create_at_cursor = true})
  end
end

-- Changes everybody notices (research, game speed, enemies): all players read who did it.
function M.announce(player, message)
  game.print({"", "[color=255,200,120]", {"pst.prefix"}, "[/color] ", {"pst.announce", player.name, message}},
    {skip = defines.print_skip.never})
  if player.connected then
    pcall(player.create_local_flying_text, {text = message, create_at_cursor = true})
  end
end

-- The surface the player looks at (remote view included) and the body's surface.
function M.view_surface(player)
  return player.surface
end

function M.view_position(player)
  return player.position
end

function M.quality_name(name)
  if name and prototypes.quality[name] then return name end
  return "normal"
end

-- How many items "the amount" means for one item.
function M.amount_for(player, item_name)
  local d = M.pdata(player)
  local entry = M.COUNTS[d.count] or M.COUNTS[2]
  local item = prototypes.item[item_name]
  if not item then return 0 end
  if entry.stacks then return item.stack_size * entry.stacks end
  return entry.n
end

-- Inventory that receives items: the main inventory of the character (or god/editor body; never the hand), else the
-- hub of the platform the player is on.
function M.receiver(player)
  local inv = player.get_main_inventory()
  if inv then return inv end
  local surface = player.surface
  local platform = surface and surface.platform
  if platform and platform.hub and platform.hub.valid then return platform.hub end
  return nil
end

-- Insert items; returns inserted count.
function M.give(player, name, quality, count)
  if count <= 0 or not prototypes.item[name] then return 0 end
  local target = M.receiver(player)
  if not target then return 0 end
  return target.insert({name = name, quality = M.quality_name(quality), count = count})
end

-- Free spot for an entity near a position on a surface; nil when none within the radius.
function M.free_spot(surface, entity_name, position, radius)
  return surface.find_non_colliding_position(entity_name, position, radius or 20, 1, true)
end

-- Tags of a GUI element that triggers an action.
function M.tags(action, args)
  local t = {pst = action}
  if args then for k, v in pairs(args) do t[k] = v end end
  return t
end

function M.fmt_number(value)
  if value == nil then return "?" end
  if math.abs(value) >= 1000000 then return string.format("%.1fM", value / 1000000) end
  if math.abs(value) >= 10000 then return string.format("%.0fk", value / 1000) end
  if value == math.floor(value) then return string.format("%d", value) end
  return string.format("%.2f", value)
end

-- Rich text icons of a list of names ("[item=a][item=b]..."), at most `limit` of them.
function M.icons(kind, names, limit)
  local parts = {}
  for i, name in ipairs(names) do
    if limit and i > limit then
      parts[#parts + 1] = " …"
      break
    end
    parts[#parts + 1] = "[" .. kind .. "=" .. name .. "]"
  end
  return table.concat(parts)
end

return M
