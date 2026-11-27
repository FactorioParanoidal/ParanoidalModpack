local constants = require "scripts.constants"
local log = require("scripts.logger").remote
local cc_gui = require "scripts.gui"

local cc_remote = {}

--- @param entity LuaEntity
--- @param max_iterations integer
--- @return LuaEntity?
local function find_combinator(entity, max_iterations)
  if entity.name == constants.ENTITY_NAME then return entity end
  if not entity.unit_number then return nil end
  local visited = { [entity.unit_number] = true }
  local queue, first = { entity }, 1
  local remaining = { [defines.wire_type.green] = max_iterations, [defines.wire_type.red] = max_iterations }
  while first <= #queue do
    local current = queue[first]
    first = first + 1
    for _, connector in pairs(current.get_wire_connectors(false)) do
      local color = connector.wire_type
      if remaining[color] and remaining[color] > 0 then
        for _, connection in ipairs(connector.real_connections) do
          local child = connection.target.owner
          local id = child.unit_number
          if id and not visited[id] then
            if child.name == constants.ENTITY_NAME then return child end
            visited[id] = true
            queue[#queue + 1] = child
            remaining[color] = remaining[color] - 1
            if remaining[color] == 0 then break end
          end
        end
      end
    end
  end

  return nil
end

--- Opens the GUI for the given Cybersyn (constant) combinator,
--- or attempts to find one near the given entity if it's not a combinator.
--- @param player_index uint?
--- @param entity LuaEntity?
--- @return boolean success `true` if a combinator was successfully found and opened, otherwise `false`.
function cc_remote.open(player_index, entity)
  log:debug("Вызов удалённого открытия с индексом игрока ", player_index)

  if not entity or not entity.valid then return false end
  if entity.type == "entity-ghost" then return false end

  local combinator = find_combinator(entity, 20)

  if not combinator then
    log:debug("Не удалось найти сущность для открытия")
    return false
  end

  return cc_gui:open(player_index, combinator)
end

--- @param player_index uint?
function cc_remote.close(player_index)
  log:debug("Вызов удалённого закрытия с индексом игрока ", player_index)
  cc_gui:close(player_index)
end

--- @param command CustomCommandData
function cc_remote.open_from_command(command)
  if not cc_remote.command_has_player(command) then return end
  local player = game.get_player(command.player_index)
  if not player then return end
  local entity = player.selected
  if not entity or not entity.valid then return end

  remote.call(constants.MOD_NAME, "open", command.player_index, entity)
end

--- @param command CustomCommandData
function cc_remote.close_from_command(command)
  if not cc_remote.command_has_player(command) then return end
  remote.call(constants.MOD_NAME, "close", command.player_index)
end

function cc_remote.command_has_player(command)
  if command.player_index then return true end
  local message = '/' .. command.name .. ': запустите команду от имени игрока в игре.'
  localised_print(message)
  rcon.print(message)
  return false
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
