--[[ Copyright (c) 2018 Optera
 * Part of Re-Stack
 *
 * See LICENSE.md in the project directory for license information.
--]]

-- Get ammo by category and set stack size
local function SetByAmmoCategory(type, stack_size)
	if stack_size > 0 then
		for _, ammo in pairs(data.raw.ammo) do
			if ammo.ammo_type.category == type then
				--   log("[RS] Setting "..tostring(type).."."..tostring(ammo.name)..".stack_size "..ammo.stack_size.." -> "..stack_size)
				ammo.stack_size = stack_size
			end
		end
	end
end

SetByAmmoCategory("bullet", settings.startup["ReStack-ammo-bullet"].value)
SetByAmmoCategory("shotgun-shell", settings.startup["ReStack-ammo-shotgun"].value)
SetByAmmoCategory("flamethrower", settings.startup["ReStack-ammo-flamethrower"].value)
SetByAmmoCategory("rocket", settings.startup["ReStack-ammo-rocket"].value)
SetByAmmoCategory("cannon-shell", settings.startup["ReStack-ammo-cannon"].value)
SetByAmmoCategory("artillery-shell", settings.startup["ReStack-ammo-artillery"].value)
