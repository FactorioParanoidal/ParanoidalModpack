local on_tick_n = require("__flib__.on-tick-n")

local database = require("scripts.database")
local global_data = require("scripts.global-data")
local player_data = require("scripts.player-data")

return {
  -- Migrations from before 3.0 are no longer required
  ["3.0.0"] = function()
    -- NUKE EVERYTHING
    global = {}

    global_data.init()
    global_data.build_prototypes()

    database.build()
    database.check_forces()

    on_tick_n.init()
    for i, player in pairs(game.players) do
      -- Destroy all old Recipe Book GUIs
      for _, window in pairs(player.gui.screen.children) do
        if window.get_mod() == "RecipeBook" then
          window.destroy()
        end
      end

      -- Re-init player
      player_data.init(i)
      player_data.refresh(player, global.players[i])
    end
  end,
  ["3.0.2"] = function()
    global.flags = nil
    for _, player_table in pairs(global.players) do
      player_table.flags.gui_open = nil
      player_table.flags.technology_gui_open = nil
    end
  end,
  ["3.2.0"] = function()
    for _, player_table in pairs(global.players) do
      player_table.guis.info._sticky_id = nil
    end
  end,
  ["3.2.2"] = function()
    -- Migrate header names
    local changes = {
      compatible_equipment = "accepted_equipment",
      compatible_fuels = "can_burn",
      compatible_mining_drills = "mined_by",
      compatible_modules = "accepted_modules",
      compatible_recipes = "can_craft",
      compatible_resources = "can_mine",
    }
    for _, player_table in pairs(global.players) do
      local page_settings = player_table.settings.pages
      if page_settings then
        for page_name, components in pairs(page_settings) do
          local new_components = {}
          for name, data in pairs(components) do
            new_components[changes[name] or name] = data
          end
          page_settings[page_name] = new_components
        end
      end
    end
  end,
  ["3.3.0"] = function()
    -- Add player and player_table to all GUIs
    for i, player_table in pairs(global.players) do
      local player = game.get_player(i)
      if player and player.valid then
        local guis = player_table.guis
        if guis.search then
          guis.search.player = player
          guis.search.player_table = player_table
        end
        if guis.settings then
          guis.settings.player = player
          guis.settings.player_table = player_table
        end

        for recipe_name, quick_ref_gui in pairs(guis.quick_ref) do
          quick_ref_gui.player = player
          quick_ref_gui.player_table = player_table
          quick_ref_gui.recipe_name = recipe_name
        end
        for id, info_gui in pairs(guis.info) do
          if type(info_gui) == "table" then
            info_gui.player = player
            info_gui.player_table = player_table
            info_gui.id = id
          end
        end
      end
    end
  end,
}
