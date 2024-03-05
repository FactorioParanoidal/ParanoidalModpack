local DLL = require("prototypes.globals")

local function config_refresh(event)
	if event.mod_changes["DeadlockLargerLamp"] then
		for _,force in pairs(game.forces) do
			force.recipes[DLL.name].enabled = force.technologies[DLL.technology].researched
			force.recipes[DLL.floor_name].enabled = force.technologies[DLL.technology].researched
		end
	end
end

script.on_configuration_changed(config_refresh)