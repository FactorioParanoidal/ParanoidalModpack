require("init-settings")

function MergingChests.Limits()
	if (mods or script.active_mods)["WideChestsUnlimited"] then
		return {
			width = settings.startup["max-chest-width"].value,
			height = settings.startup["max-chest-height"].value,
			area = settings.startup["max-chest-area"].value
		}
	else
		return {
			width = math.min(settings.startup["max-chest-width"].value, 42),
			height = math.min(settings.startup["max-chest-height"].value, 42),
			area = math.min(settings.startup["max-chest-area"].value, 1600)
		}
	end
end

MergingChests.MergableChestIds = { }
if (mods or script.active_mods)["WideChestsAllTypes"] then
	for _, data in pairs(MergingChests.MergableChestIdToData) do
		table.insert(MergingChests.MergableChestIds, data.id)
	end
else
	local nameToId = { }
	for _, data in pairs(MergingChests.MergableChestIdToData) do
		nameToId[data.name] = data.id
	end
	table.insert(MergingChests.MergableChestIds, nameToId[settings.startup["mergable-chest-name"].value])
end

local ANY = "any-size"
local chestWhitelist = nil
function parseWhitelist()
	chestWhitelist = { }
	local hasItem = false
	for width, height in string.gmatch(settings.startup["whitelist-chest-sizes"].value, "([%dN]+)[×xX$*]([%dN]+)") do
		if (tonumber(width) or width == "N") and (tonumber(height) or height == "N") then
			width = tonumber(width) or ANY
			height = tonumber(height) or ANY
			if not chestWhitelist[width] then
				chestWhitelist[width] = { }
				hasItem = true
			end
			if not chestWhitelist[width][ANY] then
				chestWhitelist[width][height] = true
			end
		end
	end
	if not hasItem then
		chestWhitelist = { [ANY] = { [ANY] = true } }
	end
end

function MergingChests.CheckWhitelist(width, height)
	if chestWhitelist == nil then
		parseWhitelist()
	end

	local limits = MergingChests.Limits()
	return
		width * height <= limits.area and
		width <= limits.width and
		height <= limits.height and
		(
			(chestWhitelist[ANY] and (chestWhitelist[ANY][ANY] or chestWhitelist[ANY][height])) or
			(chestWhitelist[width] and (chestWhitelist[width][ANY] or chestWhitelist[width][height]))
		)
end
