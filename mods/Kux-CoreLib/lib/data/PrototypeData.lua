require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.PrototypeData
local PrototypeData = {
	__class  = "PrototypeData",
	__guid   = "{29042CED-24D6-446E-8265-151D08B0A991}",
	__origin = "Kux-CoreLib/lib/data/PrototypeData.lua",
}
if not KuxCoreLib.__classUtils.ctor(PrototypeData) then return self end
---------------------------------------------------------------------------------------------------
function PrototypeData.setIconTint(item, tint)
	if(item.icons) then
		if(item.icons[1] and item.icons[1].tint==nil) then
			item.icons[1].tint = tint
		else
			log("WARNING could not tint the icon! "..item.type ..".".. item.name.."\n"..serpent.block(item))
		end
	elseif(item.icon) then
		item.icons = {{
			icon = item.icon,
			tint = tint
		}}
		item.icon = nil
	end
end

function PrototypeData.energyFactor(value, factor)
	-- DOCU: https://wiki.factorio.com/Types/Energy
	local energy = tonumber(string.match(value, "%d+"))
	local unit = string.match(value, "%a+")
	energy = energy * factor -- TODO round
	return tostring(energy) .. unit
end

function PrototypeData.energyUsageFactor(entity, factor)
	-- DOCU: https://wiki.factorio.com/Prototype/CraftingMachine#energy_usage
	entity.energy_usage = PrototypeData.energyFactor(entity.energy_usage, factor)
end

--Factorio 2.0: Removed hr_version from all graphics definitions. The graphics are now always considered to be in high definition.
local function fix_hr_version(data)
	for key, value in pairs(data) do
		if key == "hr_version" and type(value) == "table" then
			for hr_key, hr_value in pairs(value) do
				data[hr_key] = hr_value
			end
			data.hr_version = nil
		elseif type(value) == "table" then
			fix_hr_version(value)
		end
	end
end

function PrototypeData.finalize(data)
	fix_hr_version(data)
	return data
end


---@type KuxCoreLib.PrototypeData.Extend
PrototypeData.extend = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/data/PrototypeData-extend") --[[@as KuxCoreLib.PrototypeData.Extend]]

---------------------------------------------------------------------------------------------------

function PrototypeData.asGlobal() return KuxCoreLib.__classUtils.asGlobal(PrototypeData) end

return PrototypeData