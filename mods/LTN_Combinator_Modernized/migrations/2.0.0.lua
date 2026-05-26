local old_storage = storage or {}

storage = {}
storage.players = {}
storage.network_descriptions = {}
storage.combinators = {}

for _, player in pairs(game.players) do
  for _, gui in pairs({ player.gui.top, player.gui.left, player.gui.center, player.gui.screen, player.gui.relative }) do
    for _, child in pairs(gui.children) do
      if child.get_mod() == "LTN_Combinator_Modernized" then
        child.destroy()
      end
    end
  end

  local player_table = {
    uis = {},
    settings = {},
  }

  player_table.settings["ltnc-use-stacks"] = player.mod_settings["ltnc-use-stacks"].value
  player_table.settings["ltnc-negative-signals"] = player.mod_settings["ltnc-negative-signals"].value
  storage.players[player.index] = player_table
end

-- Migrate any network descriptions and icons
if old_storage.network_description then
  for net, details in pairs(old_storage.network_description) do
    if not details.tip and not details.icon then
      goto continue
    end
    storage.network_descriptions[net] = {}
    storage.network_descriptions[net].tip = details.tip
    if details.icon then
      storage.network_descriptions[net].icon = details.icon.type .. "/" .. details.icon.name
    end
    ::continue::
  end
end