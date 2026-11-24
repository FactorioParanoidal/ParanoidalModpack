require "lib.lib"
require "script.legacy-bridge" -- first initialization handler: takes over the state of saves made before the rename

require "script.remote-api"
require "script.external-rooms.init"
require "script.layout"
require "script.factory-buildings"
require "script.connections.connections"
require "script.roboport.roboport"
require "script.blueprint"
require "script.camera"
require "script.travel"
require "script.overlay"
require "script.pollution"
require "script.electricity"
require "script.greenhouse"
require "script.lights"
require "script.port-markers"
require "script.borehole-pump"
require "script.indoor-restrictions"
require "script.names"
require "script.stats"
require "script.specialization"
require "script.hull"
require "script.dispatch"
require "script.migration"

require "compat.factorio-maps"
require "compat.cerys"
require "compat.maraxsis"
require "compat.resource-spawner-overhaul"
require "compat.picker-dollies"
require "compat.space-exploration"

-- Last initialization handler: redraws the render objects after a save transfer (script/legacy-bridge.lua).
factorissimo.on_event(factorissimo.events.on_init(), factorissimo.redraw_after_legacy_transfer)

factorissimo.finalize_events()
