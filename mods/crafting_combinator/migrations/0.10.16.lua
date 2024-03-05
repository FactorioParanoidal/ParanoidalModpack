if not late_migrations then return end

late_migrations['0.10.16'] = function()
	local config = require 'config'
	local cc_control = require 'script.cc'
	local rc_control = require 'script.rc'
	
	cc_control.on_load()
	rc_control.on_load()
	
	log("Fixing moved combinators...")
	for _, combinator in pairs(global.cc.data) do combinator:update_inner_positions(); end
	for _, combinator in pairs(global.rc.data) do combinator:update_inner_positions(); end
	
	log("Removing duplicate and orphan settings entities...")
	for _, surface in pairs(game.surfaces) do
		print("\t- Scanning surface: "..surface.name)
		for _, entity in pairs(surface.find_entities_filtered{name = config.SETTINGS_ENTITY_NAME}) do
			local owners = surface.find_entities_filtered{name = {config.CC_NAME, config.RC_NAME}, position = entity.position}
			local duplicates = surface.find_entities_filtered{name = config.SETTINGS_ENTITY_NAME, position = entity.position}
			if next(owners) == nil then
				print("\t\t- Removing orphan at "..serpent.line(entity.position))
				entity.destroy()
			elseif table_size(duplicates) > 1 then
				for _, duplicate in pairs(duplicates) do
					if duplicate.unit_number > entity.unit_number then
						print("\t\t- Removing duplicate at "..serpent.line(entity.position)..", newer unit number: "..tostring(duplicate.unit_number))
						entity.destroy()
						break
					end
				end
			end
		end
	end
end
