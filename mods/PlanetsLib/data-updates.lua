PlanetsLib.check_global_variables()
PlanetsLib.current_stage = "data-updates"
local orbits = require("lib.orbits")

if mods["space-age"] then
	require("prototypes.override.handle-previously-invalid-parents")
	orbits.ensure_all_locations_have_orbits()
	require("prototypes.override.rocket-silos")
end

require("prototypes.override.centrifuge")
