require "scripts.constants"
_G.maraxsis = {}
_G.maraxsis_constants = prototypes.mod_data["maraxsis-constants"].data
require "lib.lib"

-- migrate storage cleanly between Classic and Modern branches
require "scripts.storage-migration"

require "locale.gui-locale"

require "scripts.map-gen.maraxsis"
require "scripts.map-gen.maraxsis-trench"
require "scripts.submarine"
require "scripts.nightvision"
require "scripts.pressure-dome"
require "scripts.trench-foundation"
require "scripts.nukes"
require "scripts.swimming"
require "scripts.trench-duct"
require "scripts.abyssal-diving-gear"
require "scripts.remote"
require "scripts.fishing-tower"
require "scripts.drowning"
require "scripts.sonar"
require "scripts.supercritical-steam"
require "scripts.hydraulic-science-pack"
require "scripts.legendary-quality"

require "compat.call-plumber"

-- Register the maraxsis-start runtime behaviour only when Any Planet Start is
-- active and Maraxsis was chosen as the starting planet.
if script.active_mods["any-planet-start"] and settings.startup["aps-planet"] and settings.startup["aps-planet"].value == "maraxsis" then
    require "maraxsis-start.control"
end

maraxsis.finalize_events()
if script.active_mods["gvv"] then require("__gvv__.gvv")() end
