-- Moves fuel/ammo from a source inventory into a building by a rule.
-- A rule is an ordered list of {name, quality, count}. For every compartment of the
-- building (fuel, each gun group) the first listed item that fits and is in the source
-- is topped up to its count; if the source has less, what there is goes in.

local compat = require("__paranoidal-autofill__/scripts/compat")

local M = {}

local function quality_name(q)
	if type(q) == "table" then return q.name end
	return q or "normal"
end

local function spoils(proto, quality)
	local ok, ticks = pcall(proto.get_spoil_ticks, quality)
	return ok and ticks and ticks > 0
end

-- Moves up to `want` items name/quality from `source` into `dest`, keeping health,
-- spoilage and a partly used magazine with the item it belongs to.
local function move(source, dest, name, quality, want)
	local room = dest.get_insertable_count({ name = name, quality = quality })
	if room < want then want = room end
	if want <= 0 then return 0 end
	local proto = prototypes.item[name]
	local is_ammo = proto.type == "ammo"
	local magazine = is_ammo and proto.magazine_size or nil
	local can_spoil = spoils(proto, quality)
	local moved = 0
	for i = 1, #source do
		if moved >= want then break end
		local stack = source[i]
		if stack.valid_for_read and stack.name == name and stack.quality.name == quality then
			local take = math.min(want - moved, stack.count)
			local def = { name = name, quality = quality, count = take }
			if stack.health < 1 then def.health = stack.health end
			if can_spoil then def.spoil_percent = stack.spoil_percent end
			local partial = magazine and stack.ammo < magazine
			if partial then
				if take == stack.count then
					-- The used magazine leaves together with the whole stack.
					def.ammo = stack.ammo
				end
				-- Otherwise only full magazines leave; the used one stays in the source.
			end
			-- Changing count refills the used magazine (checked on 2.0.77), so the rest of the
			-- stack gets its own values back. If the used magazine itself left, the rest is full.
			local left_ammo = magazine and (def.ammo and magazine or stack.ammo)
			local left_health = stack.health
			local left_spoil = can_spoil and stack.spoil_percent
			local inserted = dest.insert(def)
			if inserted > 0 then
				if inserted >= stack.count then
					stack.clear()
				else
					stack.count = stack.count - inserted
					if left_ammo and stack.ammo ~= left_ammo then stack.ammo = left_ammo end
					if stack.health ~= left_health then stack.health = left_health end
					if left_spoil and stack.spoil_percent ~= left_spoil then stack.spoil_percent = left_spoil end
				end
				moved = moved + inserted
			end
			if inserted < take then break end -- the building is full
		end
	end
	return moved
end

local function compartment_inventory(entity, comp)
	if comp.kind == "fuel" then return entity.get_fuel_inventory() end
	return entity.get_inventory(comp.inventory)
end

-- Returns the list of moved {name, quality, count} and the list of items that were
-- wanted but absent in the source (for a short notice).
function M.fill(entity, items, source)
	local info = compat.entity(entity.name)
	local moved_list, missing = {}, {}
	if not (info and source and source.valid) then return moved_list, missing end
	for _, comp in ipairs(info.compartments) do
		local inv = compartment_inventory(entity, comp)
		if inv and inv.valid then
			local candidates, done, available = {}, false, false
			for _, it in ipairs(items) do
				local name, quality = it.name, quality_name(it.quality)
				if prototypes.item[name] and prototypes.quality[quality] and compat.fits(comp, name) then
					local id = { name = name, quality = quality }
					local have = inv.get_item_count(id)
					if have >= it.count then
						done = true
						break
					end
					candidates[#candidates + 1] = id
					if source.get_item_count(id) > 0 then
						available = true
						local n = move(source, inv, name, quality, it.count - have)
						if n > 0 then
							moved_list[#moved_list + 1] = { name = name, quality = quality, count = n }
							done = true
							break
						end
						-- No room (the slot holds another item): try the next one in the list.
					end
				end
			end
			if not done and not available and candidates[1] then
				missing[#missing + 1] = candidates[1]
			end
		end
	end
	return moved_list, missing
end

return M
