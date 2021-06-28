require("init-settings")

function MergingChests.Limits()
	if MergingChests.CheckMod(MergingChests.UnlimitedModName) then
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
for _, data in pairs(MergingChests.MergableChestIdToData) do
	if (
		not data.logistic and
		(
			MergingChests.CheckMod(MergingChests.AllTypesModName) or
			settings.startup["mergable-chest-name"].value == data.name
		)
	) or 
	(
		data.logistic and
		MergingChests.CheckMod(MergingChests.LogisticModName)
	) then
		table.insert(MergingChests.MergableChestIds, data.id)
	end
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

MergingChests.AreaChests = {
	["wooden-chest"] = true,
	["iron-chest"] = true,
	["steel-chest"] = true,
	["brass-chest"] = true,
	["titanium-chest"] = true
}

function MergingChests.CheckWhitelist(id, width, height)
	if chestWhitelist == nil then
		parseWhitelist()
	end

	local limits = MergingChests.Limits()
	return
		(MergingChests.AreaChests[id] or width == 1 or height == 1) and
		width * height <= limits.area and
		width <= limits.width and
		height <= limits.height and
		(
			(chestWhitelist[ANY] and (chestWhitelist[ANY][ANY] or chestWhitelist[ANY][height])) or
			(chestWhitelist[width] and (chestWhitelist[width][ANY] or chestWhitelist[width][height]))
		)
end
