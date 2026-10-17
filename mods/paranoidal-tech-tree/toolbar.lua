-- Own button in the shared mod-gui panel; no patch to GUI_Unifyer is needed.
local mod_gui = require("mod-gui")
local M = {}
local NAME = "ptt_toolbar_toggle"

function M.sync(player, opened)
  if not (player and player.valid) then return end
  local flow = mod_gui.get_button_flow(player)
  local button = flow[NAME]
  if not button then
    button = flow.add{type="sprite-button", name=NAME, sprite="utility/technology_white",
      tooltip={"ptt.toolbar-toggle"}, tags={ptt=true, action="toolbar_toggle"}}
  end
  local ps = settings.get_player_settings(player)
  local enabled = ps["gu_mod_enabled_perplayer"]
  local style = ps["gu_button_style_setting"]
  local wanted = enabled and enabled.value and style and style.value or "slot_button"
  if button.style.name ~= wanted then button.style = wanted end
  button.toggled = opened and true or false
end

function M.player(event)
  local player = game.get_player(event.player_index)
  if player then M.sync(player, player.gui.screen.ptt_native ~= nil) end
end

function M.all()
  for _, player in pairs(game.players) do
    M.sync(player, player.gui.screen.ptt_native ~= nil)
  end
end

return M
