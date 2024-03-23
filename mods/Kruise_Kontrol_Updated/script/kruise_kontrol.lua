local Character = require("script/character_interface/character")

local script_data =
{
  klients = {}
}

Klient = {}
Klient.metatable =
{
  __index = Klient
}

function Klient.new(player)

  local klient =
  {
    player = player,
    index = player.index
  }

  setmetatable(klient, Klient.metatable)
  script_data.klients[player.index] = klient
  return klient
end

function Klient.get_or_make(player_index)
  local klient = script_data.klients[player_index]
  if klient and klient.player.valid then return klient end

  local player = game.get_player(player_index)
  if not player then return end

  klient = Klient.new(player)
  return klient
end

function Klient:get_or_make_character()
  if self.character then
    if self.character.entity.valid then
      return self.character
    end
    self.character = nil
  end

  self:make_character()
  return self.character
end

function Klient:on_player_action_command(event)
  local character = self:get_or_make_character()
  if not character then return end

  character:clear_state()
  local position = event.cursor_position
  self.player.update_selected_entity(position)
  character:determine_job(self.player.selected, position)
end

function Klient:on_player_enqueue_action_command(event)
  local character = self:get_or_make_character()
  if not character then return end

  local position = event.cursor_position
  self.player.update_selected_entity(position)
  local selected = self.player.selected
  character:defer_job(position, selected)
end

function Klient:on_player_cancel_command(event)
  local character = self:get_or_make_character()
  if not character then return end
  if character:is_idle() then return end
  character:remark({"abort-command"})
  character:clear_state()
end

function Klient:make_character()
  if not self.player.character then return end
  self.character = Character.new(self.player.character)
end

local on_player_action_command = function(event)
  local klient = Klient.get_or_make(event.player_index)
  if not klient then return end
  klient:on_player_action_command(event)
end

local on_player_enqueue_action_command = function(event)
  local klient = Klient.get_or_make(event.player_index)
  if not klient then return end
  klient:on_player_enqueue_action_command(event)
end

local on_player_cancel_command = function(event)
  local klient = Klient.get_or_make(event.player_index)
  if not klient then return end
  klient:on_player_cancel_command(event)
end

local lib = {}

lib.events =
{
  ["klient-alt-move-to"] = on_player_action_command,
  --["klient-enqueue-command"] = on_player_enqueue_action_command,
  --["klient-cancel-w"] = on_player_cancel_command,
  --["klient-cancel-a"] = on_player_cancel_command,
  --["klient-cancel-s"] = on_player_cancel_command,
  --["klient-cancel-d"] = on_player_cancel_command,
  ["klient-cancel-enter"] = on_player_cancel_command,

  [defines.events.on_pre_player_toggled_map_editor] = on_player_cancel_command,
  [defines.events.on_pre_player_left_game] = on_player_cancel_command,
  [defines.events.on_pre_player_died] = on_player_cancel_command,
  [defines.events.on_player_changed_surface] = on_player_cancel_command,
  [defines.events.on_player_changed_force] = on_player_cancel_command,
}

lib.on_init = function()
  global.kruise_kontrol = global.kruise_kontrol or script_data
end

lib.on_load = function()
  script_data = global.kruise_kontrol or script_data
  for k, klient in pairs (script_data.klients) do
    setmetatable(klient, Klient.metatable)
  end
end

return lib
