--control.lua

require("config")
require("logic.overhead_line")
require("logic.remotes")

--[[
Summary of global variables:

`global` table:
  * wire_for_pole: Maps a unit number of a pole to the corresponding wire entity
  * power_for_pole: Maps a pole's unit number to the power consumer entity
  * graphic_for_pole: Maps a pole's unit number to the wire holder entity
  * power_for_rail: Maps a rail's unit number to a power consumer powering it.
      The consumer might not be valid anymore, you need to check that!
  * electric_locos: An array of electric locomotives
  * fuel_for_loco: Maps a modular loco's unit number to a table with values 
      "fuel" (the fuel prototype) and "transfer" (the max transfer rate). May be
      nil and should be regenerated then.

Other global variables:
  * config: A table of static configuration values. Never changed at runtime.
  * ticks_per_update, enable_connect_particles, enable_failure_text,
      enable_zigzag_wire, enable_zigzag_vertical_only, enable_circuit_wire,
      enable_rewire_neighbours, max_pole_search_distance: Cached values of the
      mod settings. Will be automatically updated when the settings change.
--]]


--==============================================================================
-- Setup and settings

-- Initialization
script.on_init(
	function(e)
		-- init lookup tables
		global.wire_for_pole = {}   -- Pole ID -> Wire Entity
		global.power_for_pole = {}  -- Pole ID -> Power Entity
		global.graphic_for_pole = {}-- Pole ID -> Graphic Entity
		global.power_for_rail = {}  -- Rail ID -> Power Entity
		global.electric_locos = {}  -- Array of Loco Entity
		global.fuel_for_loco = {}   -- Loco ID -> Table {fuel, transfer}
		
		global.electric_loco_registry = {}
		global.electric_loco_registry["ret-electric-locomotive"] = "ret-dummy-fuel-1"
		global.electric_loco_registry["ret-electric-locomotive-mk2"] = "ret-dummy-fuel-2"
		global.electric_loco_registry["ret-modular-locomotive"] = "ret-dummy-fuel-modular"

		on_startup()
	end
)

script.on_load(
	function(e)
		on_startup()
	end
)

function on_startup()
	-- Exclude the energy consumer and wire holder from creative mode's instant blueprints
	if remote.interfaces["creative-mode"] then
		remote.call("creative-mode", "exclude_from_instant_blueprint", "ret-pole-energy-straight")
		remote.call("creative-mode", "exclude_from_instant_blueprint", "ret-pole-energy-diagonal")
		remote.call("creative-mode", "exclude_from_instant_blueprint", "ret-pole-holder-straight")
		remote.call("creative-mode", "exclude_from_instant_blueprint", "ret-pole-holder-diagonal")
	end

	-- Exclude electric locomotives from the Automatic Train Fuel Stop
	if remote.interfaces["FuelTrainStop"] then
		remote.call("FuelTrainStop", "exclude_from_fuel_schedule", "ret-electric-locomotive")
		remote.call("FuelTrainStop", "exclude_from_fuel_schedule", "ret-electric-locomotive-mk2")
		remote.call("FuelTrainStop", "exclude_from_fuel_schedule", "ret-modular-locomotive")
	end
end

-- Settings and configuration changes

require("logic.events.on_setup_changed")
on_settings_changed() -- initial caching

script.on_event(defines.events.on_runtime_mod_setting_changed, 
	on_settings_changed
)

script.on_configuration_changed(
	on_configuration_changed
)

--==============================================================================

-- On built events

script.on_event({
		defines.events.on_built_entity,
		defines.events.on_robot_built_entity,
		defines.events.script_raised_built,
		defines.events.script_raised_revive
	},
	require("logic.events.on_built")
)

--==============================================================================

-- On remove events

script.on_event({
		defines.events.on_entity_died,
		defines.events.on_pre_player_mined_item,
		defines.events.on_robot_pre_mined,
		defines.events.script_raised_destroy
	},
	require("logic.events.on_remove")
)

--==============================================================================

-- Module Update events (GUI-Closed and Fast-Transferred)

script.on_event({
		defines.events.on_gui_closed,
		defines.events.on_player_fast_transferred
	},
	require("logic.events.on_gui_closed")
)

--==============================================================================

-- Tick handler

script.on_event(defines.events.on_tick, 
	require("logic.events.on_tick")
)

--==============================================================================

-- Selection script for the debugger

script.on_event(defines.events.on_player_selected_area,
	require("logic.events.on_selected_area")
)

--==============================================================================

-- Commands

commands.add_command("print_electric_train_count", 
	"Prints how many electric trains are currently registered in the Realistic Electric Trains mod.",
	function()
		local count = 0
		for _, _ in pairs(global.electric_locos) do
			count = count + 1
		end
		game.print(string.format("Total Trains: %d", count))
	end
)
