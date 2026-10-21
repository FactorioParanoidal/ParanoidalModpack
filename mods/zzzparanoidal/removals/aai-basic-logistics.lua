require("__zzzparanoidal__.paralib")

local basic_logistics = data.raw.technology["basic-logistics"]
if basic_logistics and basic_logistics.hidden and data.raw.technology["logistics-0"] then
	-- AAI повторно включает уже скрытую Bob Logistics технологию с активным research_trigger.
	paralib.bobmods.lib.tech.hide("basic-logistics")
end
