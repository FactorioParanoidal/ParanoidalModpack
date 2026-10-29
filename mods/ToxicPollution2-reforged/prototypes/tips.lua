-- Tips and tricks: how the smog works. Always available: the mechanic acts from the first minute.
local C = require("shared.config")

local CATEGORY = "tpr-smog"

local function tip(name, order, tag, description)
	return {
		type = "tips-and-tricks-item",
		name = name,
		category = CATEGORY,
		tag = tag,
		order = order,
		indent = name == CATEGORY and 0 or 1,
		is_title = name == CATEGORY,
		starting_status = "unlocked",
		localised_description = description,
	}
end

-- Setting names come from the live keys so the text matches the settings menu.
local settings_text = { "", { "tips-and-tricks-item-description.tpr-smog-settings" } }
for _, name in ipairs({ "tpr-hud", "tpr-auto-equip", "tpr-sounds", "tpr-respawn-respirator" }) do
	settings_text[#settings_text + 1] = { "", "\n• [font=default-bold]", { "mod-setting-name." .. name }, "[/font] — ",
		{ "mod-setting-description." .. name } }
end

local tolerance = tostring(settings.startup["tpr-tolerance"].value)
local M = C.MODEL
local refill = mods["carbon-capture2"]
	and { "tips-and-tricks-item-description.tpr-smog-refill", C.REFILL_ITEM, C.REFILL_RETURN, tostring(C.REFILL_AMOUNT) }
	or ""

data:extend({
	{ type = "tips-and-tricks-item-category", name = CATEGORY, order = "c-[tpr-smog]" },
	tip(CATEGORY, "a", "[img=virtual-signal/" .. C.ALERT.smog .. "]", { "tips-and-tricks-item-description." .. CATEGORY,
		tolerance, tostring(M.damage_from), tostring(math.floor(M.damage_share * 100 + 0.5)) }),
	tip("tpr-smog-protection", "b", "[img=item/" .. C.GAS_MASK .. "]", { "tips-and-tricks-item-description.tpr-smog-protection",
		refill, tostring(M.zone_radius) }),
	tip("tpr-smog-hud", "c", "[img=virtual-signal/" .. C.ALERT.danger .. "]"),
	tip("tpr-smog-sensor", "d", "[img=virtual-signal/" .. C.SIGNAL .. "]"),
	tip("tpr-smog-sos", "e", "[img=item/" .. C.RESPIRATOR .. "]"),
	tip("tpr-smog-settings", "f", "[img=item/iron-gear-wheel]", settings_text),
})
