--- @param event chest_merged_event
local function raise_on_chest_split(event)
	script.raise_event(MergingChests.on_chest_split_event_name, event)
end

--- @param merged_chest LuaEntity
--- @param split_chest_name string
--- @param width integer
--- @param height integer
--- @param player LuaPlayer
--- @param is_ghost boolean
--- @param total_bar integer
--- @return LuaEntity[]
local function create_split_chest(merged_chest, split_chest_name, width, height, player, is_ghost, total_bar)
	local left_top = {
		x = merged_chest.position.x - (width - 1) / 2,
		y = merged_chest.position.y - (height - 1) / 2
	}

	local bar_per_chest = math.ceil(total_bar / width / height)
	local split_chests = { }
	for dX = 0, width - 1 do
		for dY = 0, height - 1 do
			local bar = math.min(bar_per_chest, total_bar)
			total_bar = total_bar - bar
			local entity_data = {
				position = { x = left_top.x + dX, y = left_top.y + dY },
				force = player.force,
				raise_built = true,
				bar = bar,
				quality = merged_chest.quality
			}

			if is_ghost then
				entity_data.name = "entity-ghost"
				entity_data.inner_name = split_chest_name
			else
				entity_data.name = split_chest_name
			end
			table.insert(split_chests, merged_chest.surface.create_entity(entity_data))
		end
	end

	return split_chests
end

local function on_player_alt_selected_area(event)
	if event.item and event.item == MergingChests.merge_selection_tool_name then
		local player = game.players[event.player_index]

		for _, merged_chest in ipairs(event.entities) do
			local is_ghost = merged_chest.name == 'entity-ghost'
			local merged_chest_name = is_ghost and merged_chest.ghost_name or merged_chest.name
			local split_chest_name, width, height = MergingChests.get_merged_chest_info(merged_chest_name)
			if split_chest_name ~= nil and width ~= nil and height ~= nil then
				if is_ghost or player.mod_settings[MergingChests.setting_names.allow_delete_items].value or MergingChests.can_move_inventories({ merged_chest }, split_chest_name, width * height) then
					local total_bar = MergingChests.get_total_bar({ merged_chest }, is_ghost)
					local split_chests = create_split_chest(merged_chest, split_chest_name, width, height, player, is_ghost, total_bar)

					if not is_ghost then
						for _, split_chest in ipairs(split_chests) do
							split_chest.last_user = player
						end
						MergingChests.move_inventories({ merged_chest }, split_chests)
					end
					MergingChests.reconnect_circuits({ merged_chest }, split_chests)

					raise_on_chest_split({
						player_index = event.player_index,
						surface = event.surface,
						merged_chest = merged_chest,
						split_chests = split_chests,
						is_ghost = is_ghost,
					})
					merged_chest.destroy({ raise_destroy = true })
				else
					player.create_local_flying_text({
						text = { 'flying-text.'..MergingChests.prefix_with_modname('items-would-be-deleted-split') },
						position = merged_chest.position
					})
				end
			end
		end
	end
end

script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)