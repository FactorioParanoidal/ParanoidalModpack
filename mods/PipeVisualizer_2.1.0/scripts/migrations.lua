local flib_migration = require("__flib__/migration")
local mod_gui = require("__core__/lualib/mod-gui")

local version_migrations = {
  ["2.0.0"] = function()
    global = {}
  end,
  ["2.0.1"] = function()
    for _, player in pairs(game.players) do
      local window = mod_gui.get_frame_flow(player).pv_window
      if window then
        window.destroy()
      end
    end
  end,
}

local migrations = {}

migrations.on_configuration_changed = function(e)
  flib_migration.on_config_changed(e, version_migrations)
end

return migrations
