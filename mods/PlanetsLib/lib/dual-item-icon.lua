local icon_entry = require("lib.icon-entry")

local Public = {}

--== Composite "dual item" icon helpers ==--
-- Build an `icons` array (see [[IconData]]) out of the icons of up to three existing prototypes,
-- producing a composite icon similar to the way vanilla recipes display their ingredients.
-- Ported from "Muluna, Moon of Nauvis" (planet-muluna/lib/dual-item-icon.lua).

--- Builds a composite icon from the icons of up to three prototypes.
--- Each argument is a prototype name (string). The prototype type is detected automatically;
--- see the PlanetsLib documentation for the type precedence.
--- The first icon is drawn at full size, with the second and third icons layered over it.
--- @param item_1 string Name of the primary (bottom) prototype.
--- @param item_2 string Name of the secondary prototype.
--- @param item_3 string|nil Optional name of the tertiary prototype.
--- @return table IconData array suitable for a prototype's `icons` field.
function Public.dual_icon(item_1, item_2, item_3)
	local type_1, proto_1 = icon_entry.get_prototype(item_1)
	local type_2, proto_2 = icon_entry.get_prototype(item_2)

	local primary = icon_entry.build_icon_entry(proto_1, type_1, item_1, 0.35, nil, nil, true)
	local secondary = icon_entry.build_icon_entry(proto_2, type_2, item_2, 0.30, { 10, -10 }, nil, true)

	local icons
	local type_3, proto_3 = icon_entry.get_prototype(item_3)
	if proto_3 then
		-- With three icons, the tertiary icon is placed first (top-left) and the original two
		-- icons shift right/down.
		local tertiary = icon_entry.build_icon_entry(proto_3, type_3, item_3, 0.30, { 0, -10 }, nil, true)
		icons = { tertiary, primary, secondary }
	else
		icons = { primary, secondary }
	end

	-- Nudge every entry up and to the left so the composition is centred.
	for _, entry in pairs(icons) do
		if not entry.shift then
			entry.shift = { 0, 0 }
		end
		entry.shift[1] = entry.shift[1] - 5
		entry.shift[2] = entry.shift[2] + 5
	end

	return icons
end

--- Builds a composite icon from the icons of two prototypes, using a layout mirrored relative
--- to `PlanetsLib.dual_icon`.
--- @param item_1 string Name of the primary prototype.
--- @param item_2 string Name of the secondary prototype.
--- @return table IconData array suitable for a prototype's `icons` field.
function Public.dual_icon_reversed(item_1, item_2)
	local type_1, proto_1 = icon_entry.get_prototype(item_1)
	local type_2, proto_2 = icon_entry.get_prototype(item_2)

	return {
		icon_entry.build_icon_entry(proto_1, type_1, item_1, 0.35, { 10, 0 }, false, false),
		icon_entry.build_icon_entry(proto_2, type_2, item_2, 0.30, { 0, -10 }, { 10, -10 }, false),
	}
end

return Public
