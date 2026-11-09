local Public = {}

--== Shared IconData building helpers ==--
-- Turns a prototype name into a single `icons` array entry (see [[IconData]]). Shared by the
-- composite icon helpers in "lib.dual-item-icon" and "lib.recipe".

local PLACEHOLDER_ICON = "__core__/graphics/filter-blacklist.png"
local PLACEHOLDER_ICON_SIZE = 101

-- Returns the prototype type used to look up `name`, in the same precedence order as the original
-- planet-muluna implementation (later checks override earlier ones):
-- item (default) < planet < fluid < capsule < tool < surface.
function Public.detect_type(name)
	local prototype_type = "item"
	for _, candidate in ipairs({ "planet", "fluid", "capsule", "tool", "surface" }) do
		if data.raw[candidate] and data.raw[candidate][name] then
			prototype_type = candidate
		end
	end
	return prototype_type
end

-- Returns the detected type and prototype of `name`, or ("item", nil) when nothing matches.
function Public.get_prototype(name)
	local prototype_type = Public.detect_type(name)
	return prototype_type, data.raw[prototype_type] and data.raw[prototype_type][name]
end

-- Builds a single composite-icon entry from a prototype's icon fields.
-- `base_scale` is the entry's scale before the singular `icon` form's icon-size correction.
-- `shift` is applied to the singular `icon` form and to the placeholder fallback.
-- `plural_shift` is applied to the plural `icons` form; pass `false` to omit the shift (as the
-- original reversed helper does), or nil to reuse `shift`.
-- `copy_tint` carries over `icons[1].tint` for the plural form.
function Public.build_icon_entry(prototype, prototype_type, name, base_scale, shift, plural_shift, copy_tint)
	if plural_shift == nil then
		plural_shift = shift
	end

	if prototype and prototype.icon then
		local entry = {
			icon = prototype.icon,
			icon_size = prototype.icon_size,
			scale = base_scale,
			draw_background = true,
		}
		if prototype.icon_size then
			entry.scale = entry.scale * 64 / prototype.icon_size
		end
		if shift then
			entry.shift = { shift[1], shift[2] }
		end
		return entry
	elseif prototype and prototype.icons and prototype.icons[1] then
		local entry = {
			icon = prototype.icons[1].icon,
			icon_size = prototype.icons[1].icon_size,
			scale = base_scale,
			draw_background = true,
		}
		if plural_shift then
			entry.shift = { plural_shift[1], plural_shift[2] }
		end
		if copy_tint then
			entry.tint = prototype.icons[1].tint
		end
		return entry
	else
		log(prototype_type .. ' "' .. tostring(name) .. '" icon not found. Using a placeholder in composite icon instead.')
		local entry = {
			icon = PLACEHOLDER_ICON,
			icon_size = PLACEHOLDER_ICON_SIZE,
			scale = base_scale,
			draw_background = true,
		}
		if shift then
			entry.shift = { shift[1], shift[2] }
		end
		return entry
	end
end

return Public
