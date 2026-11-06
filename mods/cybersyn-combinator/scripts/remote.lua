local constants = require "scripts.constants"
local log = require("scripts.logger").remote
local cc_gui = require "scripts.gui"

local cc_remote = {}

--- @param entity LuaEntity
--- @param max_iterations integer
--- @return LuaEntity?
local function find_combinator(entity, max_iterations)
  --- @type { [uint]: boolean }
  local visited = { [entity.unit_number] = true }
  --- @type { [uint]: LuaEntity }
  local queue = { [entity.unit_number] = entity }
  local green_i = 0
  local red_i = 0

  while true do
    local _, current = next(queue)
    if not current then break end

    if current.name == constants.ENTITY_NAME then return current end

    visited[current.unit_number] = true
    queue[current.unit_number] = nil

    local connected = current.circuit_connected_entities
    if not connected then goto continue end

    if green_i <= max_iterations then
      for _, child in pairs(connected.green) do
        local id = child.unit_number
        if id and not visited[id] and not queue[id] then
          queue[id] = child
          green_i = green_i + 1
        end
      end
    end

    if red_i > max_iterations then goto continue end

    for _, child in pairs(connected.red) do
      local id = child.unit_number
      if id and not visited[id] and not queue[id] then
        queue[id] = child
        red_i = red_i + 1
      end
    end

    ::continue::
  end

  return nil
end

--- Opens the GUI for the given Cybersyn (constant) combinator,
--- or attempts to find one near the given entity if it's not a combinator.
--- @param player_index uint?
--- @param entity LuaEntity?
--- @return boolean success `true` if a combinator was successfully found and opened, otherwise `false`.
function cc_remote.open(player_index, entity)
  log:debug("Remote open called with player index ", player_index)

  if not entity or not entity.valid then return false end
  if entity.type == "entity-ghost" then return false end

  local combinator = find_combinator(entity, 20)

  if not combinator then
    log:debug("Could not find entity to open")
    return false
  end

  return cc_gui:open(player_index, combinator)
end

--- @param player_index uint?
function cc_remote.close(player_index)
  log:debug("Remote close called with player index ", player_index)
  cc_gui:close(player_index)
end

--- @param command CustomCommandData
function cc_remote.open_from_command(command)
  local player = game.get_player(command.player_index)
  if not player then return end
  local entity = player.selected
  if not entity or not entity.valid then return end

  remote.call(constants.MOD_NAME, "open", command.player_index, entity)
end

--- @param command CustomCommandData
function cc_remote.close_from_command(command)
  remote.call(constants.MOD_NAME, "close", command.player_index)
end

function cc_remote:register()
  remote.add_interface(constants.MOD_NAME, {
    open = self.open,
    close = self.close
  })

  commands.add_command("cc_open", { "cybersyn-combinator-commands.remote-open" }, cc_remote.open_from_command)
  commands.add_command("cc_close", { "cybersyn-combinator-commands.remote-close" }, cc_remote.close_from_command)
end

return cc_remote
