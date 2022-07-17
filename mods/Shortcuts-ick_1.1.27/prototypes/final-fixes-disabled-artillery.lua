--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of final-fixes-disabled-artillery.lua:
	* Generation of disabled artillery
]]

-- Moved here because of mod "heroturrets"

local artillery_toggle = settings.startup["artillery-toggle"].value

if artillery_toggle == "both" or artillery_toggle == "artillery-wagon" or artillery_toggle == "artillery-turret" then

	local disable_turret_types = {}

	if artillery_toggle == "both" then
		disable_turret_types = {"artillery-wagon", "artillery-turret"}
	else
		disable_turret_types = {artillery_toggle}
	end

	for a, type in pairs(disable_turret_types) do
		for b, entity in pairs(data.raw[type]) do
			if string.sub(entity.name,1,9) ~= "disabled-" then

				-- DISABLED TURRET
				local disabled_turret = table.deepcopy(entity)
					disabled_turret.name = "disabled-" .. entity.name
					table.insert(disabled_turret.flags, "hidden")
					if entity.localised_name then
						disabled_turret.localised_name = {"", entity.localised_name, " (", {"gui-constant.off"}, ")"}
					else
						disabled_turret.localised_name = {"", {"entity-name." .. entity.name}, " (", {"gui-constant.off"}, ")"}
					end
					if data.raw.item[entity.name] or data.raw["item-with-entity-data"][entity.name] then
						disabled_turret.placeable_by = {item = entity.name, count = 1}
					end
					if data.raw.recipe[entity.name] then
						if entity.subgroup == nil and data.raw.recipe[entity.name].subgroup then
							disabled_turret.subgroup = data.raw.recipe[entity.name].subgroup
						end
						if entity.order == nil and data.raw.recipe[entity.name].order then
							disabled_turret.order = data.raw.recipe[entity.name].order
						end
					end
					if disabled_turret.icon then
						disabled_turret.icons = {{icon = entity.icon, tint = {0.5, 0.5, 0.5}}}
						disabled_turret.icon = nil
					end

				-- DISABLED GUN
				local disabled_gun = table.deepcopy(data.raw.gun[entity.gun])
					disabled_gun.name = "disabled-" .. entity.gun
					disabled_gun.localised_name = disabled_turret.localised_name
					disabled_gun.flags = {"hidden"}
					disabled_gun.attack_parameters.range = 0
					disabled_gun.attack_parameters.min_range = 0
					if disabled_gun.icon then
						disabled_gun.icons = {{icon = disabled_gun.icon, tint = {0.5, 0.5, 0.5}}}
						disabled_gun.icon = nil
					end

				-- LINKAGE
				disabled_turret.gun = disabled_gun.name

				data:extend({disabled_turret, disabled_gun})
			end
		end
	end

end
