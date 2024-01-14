--- @param event chest_merged_event
local function raise_on_chest_split(event)
	script.raise_event(MergingChests.on_chest_split_event_name, event)
end

--- @param merged_chest LuaEntity
--- @param split_chest_name string
--- @param width integer
--- @param height integer
--- @param player LuaPlayer
--- @return LuaEntity[]
local function create_split_chest(merged_chest, split_chest_name, width, height, player)
	local left_top = {
		x = merged_chest.position.x - (width - 1) / 2,
		y = merged_chest.position.y - (height - 1) / 2
	}

	local split_chests = { }
	for dX = 0, width - 1 do
		for dY = 0, height - 1 do
			table.insert(split_chests, merged_chest.surface.create_entity({
				name = split_chest_name,
				position = { x = left_top.x + dX, y = left_top.y + dY },
				force = player.force,
				raise_built = true
			}))
		end
	end

	return split_chests
end

local function on_player_alt_selected_area(event)
	if event.item and event.item == MergingChests.merge_selection_tool_name then
		local player = game.players[event.player_index]

		for _, merged_chest in ipairs(event.entities) do
			local split_chest_name, width, height = MergingChests.get_merged_chest_info(merged_chest.name)
			if split_chest_name ~= nil and width ~= nil and height ~= nil then
				if MergingChests.can_move_inventories({ merged_chest }, split_chest_name, width * height) or player.mod_settings[MergingChests.setting_names.allow_delete_items].value then
					local split_chests = create_split_chest(merged_chest, split_chest_name, width, height, player)

					MergingChests.move_inventories({ merged_chest }, split_chests)
					MergingChests.reconnect_circuits({ merged_chest }, split_chests)

					raise_on_chest_split({
						player_index = event.player_index,
						surface = event.surface,
						merged_chest = merged_chest,
						split_chests = split_chests
					})
					merged_chest.destroy({ raise_destroy = true })
				else
					player.create_local_flying_text({
						text = 'flying-text.'..MergingChests.prefix_with_modname('items-would-be-deleted-split'),
						position = merged_chest.position
					})
				end
			end
		end
	end
end

script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)