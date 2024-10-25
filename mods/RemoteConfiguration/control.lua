local RecipeChange = require "__RemoteConfiguration__/recipe-change"
local blacklist_groups = {
  -- exotic industries related
  -- maybe add interface to extend this?
  ["gate-user"] = true,
  ["drone-user"] = true
}

-- These entity types can be opened remotely anyway
local entity_type_blacklist = {
  ["train-stop"] = true,
  ["electric-pole"] = true,
}

local function increase_range(player)
  if player.character and player.character_reach_distance_bonus < 200000 then
    player.character_reach_distance_bonus = player.character_reach_distance_bonus + 200000
  end
end

local ranges_reset_this_tick = {}
local function reset_range(player)
  if not player.character then return end
  while player.character_reach_distance_bonus >= 200000 do
    player.character_reach_distance_bonus = player.character_reach_distance_bonus - 200000
    ranges_reset_this_tick[player.index] = game.tick
  end
end
local function reset_player(player)
  -- dont reset the group if its currently a blacklist group
  -- game.print("trying to reset player")
  if blacklist_groups[player.permission_group.name] then return end
  player.permission_group = game.permissions.get_group("Default")
  -- game.print("resetting player")
  reset_range(player)
end

local function can_reach_entity(player, entity, ignore_map_only)
  -- Check if player can reach entity disregarding whatever reach bonus we have given the player
  if not player.character then return true end
  if not ignore_map_only and not player.mod_settings["rc-interact-in-game"].value and player.render_mode == defines.render_mode.game and not (script.active_mods["SpidertronEnhancements"] and entity.type == "spider-vehicle") then return true end
  local reach_distance_bonus = player.character_reach_distance_bonus
  reset_range(player)
  local can_reach = player.can_reach_entity(entity)
  player.character_reach_distance_bonus = reach_distance_bonus
  return can_reach
end

local function is_out_of_range_gui_open(player)
  local opened = player.opened
  if opened and player.opened_gui_type == defines.gui_type.entity and not can_reach_entity(player, opened) then
    return true
  end
  return false
end

local wires = {["red-wire"] = true, ["green-wire"] = true, ["copper-cable"] = true}
local function is_holding_wire(player)
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read then
    return wires[cursor_stack.name]
  end
end

local function open_entity(player, entity, ignore_map_only)
  if entity_type_blacklist[entity.type] then return end
  reset_player(player)  -- Ensures that can_reach_entity is accurate, not needed any more?
  local out_of_reach = not can_reach_entity(player, entity, ignore_map_only)
  local map_mode = player.render_mode == defines.render_mode.chart_zoomed_in or player.render_mode == defines.render_mode.chart
  if out_of_reach or map_mode then
    if player.force.is_enemy(entity.force) then
      if map_mode then
        player.create_local_flying_text{text = {"cant-open-enemy-structures"}, create_at_cursor = true}
      end
      return
    end

    player.opened = nil  -- Triggers on_gui_closed before we open the GUI we care about
    if out_of_reach then
      increase_range(player)
      player.permission_group = game.permissions.get_group("Remote Configuration GUI opened")
    end
    player.opened = entity
    if player.opened_gui_type == defines.gui_type.entity then
      RecipeChange.on_remote_gui_opened(player)
      if not map_mode then
        player.create_local_flying_text{
          text = {"remote-configuration.opened-gui-remotely"},
          create_at_cursor = true,
        }
        player.play_sound{ path = "rc-warning-sound" }
      end
    else
      -- Opening GUI failed
      reset_player(player)
    end
  end
end

script.on_event("rc-open-gui",
  function(event)
    local player = game.get_player(event.player_index)
    if not player.is_cursor_empty() then return end
    local selected = player.selected

    if not selected then
      -- Try from the map for trains (and other vehicles)
      if player.render_mode == defines.render_mode.chart or player.render_mode == defines.render_mode.chart_zoomed_in then
        -- Don't need to check chart_zoomed_in because spidertrons have radars, so would be selectable
        local position = event.cursor_position
        local vehicles = player.surface.find_entities_filtered{type = {"locomotive", "spider-vehicle"}, position = position, radius = 4.5, limit = 1}
        if #vehicles > 0 then
          selected = vehicles[1]
        end
      end
    end
    if selected then
      open_entity(player, selected)
    end
  end
)

remote.add_interface("RemoteConfiguration",
  {
    open_entity = function(player, entity) open_entity(player, entity, true) end,
    reset_this_tick = function(player) if game.tick == ranges_reset_this_tick[player.index] then return true end end,
  }
)

script.on_event(defines.events.on_gui_closed,
  function(event)
    local player = game.get_player(event.player_index)
    RecipeChange.on_gui_closed(player)
    if is_holding_wire(player) then return end
    reset_player(player)
  end
)

-- Allows wires to be fast-transfered or placed in chests when close, but not when far away
local function recalculate_wire_permissions(event)
  local player = game.get_player(event.player_index)
  if not is_holding_wire(player) then return end

  local opened = player.opened
  if player.selected and can_reach_entity(player, player.selected) then
    reset_player(player)
  elseif player.opened_self or (opened and player.opened_gui_type == defines.gui_type.entity and can_reach_entity(player, opened)) then
    reset_player(player)
  else
    increase_range(player)
    player.permission_group = game.permissions.get_group("Remote Configuration GUI opened")
  end
end
script.on_event(defines.events.on_player_changed_position, recalculate_wire_permissions)
script.on_event(defines.events.on_selected_entity_changed, recalculate_wire_permissions)
script.on_event(defines.events.on_gui_opened, recalculate_wire_permissions)

script.on_event(defines.events.on_player_cursor_stack_changed,
  function(event)
    local player = game.get_player(event.player_index)
    if is_holding_wire(player) then
      recalculate_wire_permissions(event)
    else
      if not is_out_of_range_gui_open(player) then
        reset_player(player)
      end
    end
  end
)

script.on_event("rc-paste-entity-settings",
  function(event)
    local player = game.get_player(event.player_index)
    if not player.is_cursor_empty() then return end

    local selected = player.selected
    if not selected then return end

    local in_reach = can_reach_entity(player, selected)
    if in_reach then return end  -- Let vanilla handle this

    local entity_copy_source = player.entity_copy_source
    if not entity_copy_source then return end
    if player.force.is_enemy(selected.force) then
      player.create_local_flying_text{text = {"cant-paste-enemy-structure-settings"}, create_at_cursor = true}
      return
    end

    removed_items = selected.copy_settings(entity_copy_source, player)
    local surface = selected.surface
    local position = selected.position
    local force = player.force
    for name, count in pairs(removed_items) do
      surface.spill_item_stack(
        position,
        {name = name, count = count},
        true,  -- enabled_looted
        force,  -- force for deconstruction
        false  -- allow_on_belts
      )
    end
  end
)

function is_cheating(player)
	if
		player.cheat_mode
		and not (player.controller_type == defines.controllers.god and script.active_mods["space-exploration"])
	then
		return true
	end
	return player.controller_type == defines.controllers.editor
end

function set_cursor(player, item)
	local inventory = player.get_main_inventory()
	if not inventory then
		return false
	end
	local cursor_stack = player.cursor_stack
	if not cursor_stack or not player.clear_cursor() then
		return false
	end
	local inventory_stack, stack_index = inventory.find_item_stack(item)
	if not inventory_stack or not stack_index then
		local stack_size = game.item_prototypes[item].stack_size
		if is_cheating(player) and inventory.can_insert({ name = item, count = stack_size }) then
			inventory.insert({ name = item, count = stack_size })
			inventory_stack, stack_index = inventory.find_item_stack(item)
		else
			player.cursor_ghost = item
			return true
		end
	end
	--- @cast inventory_stack LuaItemStack
	--- @cast stack_index uint
	if not cursor_stack.transfer_stack(inventory_stack) then
		return false
	end
	local inventory_def
	if player.controller_type == defines.controllers.character then
		inventory_def = defines.inventory.character_main
	elseif player.controller_type == defines.controllers.editor then
		inventory_def = defines.inventory.editor_main
	elseif player.controller_type == defines.controllers.god then
		inventory_def = defines.inventory.god_main
	end
	player.hand_location = { inventory = inventory_def, slot = stack_index }
	return true
end

local function remote_build(event)
  local player = game.get_player(event.player_index)
  if not player.mod_settings["rc-ghost-build-in-map"].value then return end
  if player.render_mode == defines.render_mode.game then
    -- Try and put the real item back in the cursor
    local cursor_ghost = player.cursor_ghost
    if not cursor_ghost then return end

    local main_inventory = player.get_main_inventory()
    if not main_inventory then
      return
    end

  	local count = main_inventory.get_item_count(cursor_ghost.name)
	  if count == 0 then
		  return
	  end
	  set_cursor(player, cursor_ghost.name)
  else
    local cursor_stack = player.cursor_stack
    if not (cursor_stack and cursor_stack.valid_for_read) then return end
    if not cursor_stack.prototype.place_result then return end
    local cursor_stack_name = cursor_stack.name
    if player.clear_cursor() then
      player.cursor_ghost = cursor_stack_name
    end
  end
end
script.on_event("rc-build", remote_build)

local direction_modifiers = {
  ["legacy-straight-rail"] = 0,       -- 0 means ignore
  ["legacy-curved-rail"] = 0,
  ["rail-signal"] = 0,
  ["rail-chain-signal"] = 0,
  ["generator"] = 0,
  ["burner-generator"] = 0,
  ["assembling-machine"] = -1,  -- -1 means rotate immediately
  ["splitter"] = 4,
  ["underground-belt"] = 4,
  ["pipe-to-ground"] = 4,
  ["pump"] = 4,
}
local function remote_rotate(event, direction)
  local player = game.get_player(event.player_index)
  if not player.is_cursor_empty() then return end

  local selected = player.selected
  if not selected then return end

  if can_reach_entity(player, selected) then return end  -- Let vanilla handle this
  if not selected.supports_direction then return end
  if player.force.is_enemy(selected.force) then
    return
  end

  local current_direction = selected.get_upgrade_direction()

  if not current_direction then current_direction = selected.direction end

  local direction_modifier = direction_modifiers[selected.type] or 2
  if direction_modifier == 0 then return end
  if direction_modifier == -1 then
    local next_direction = (current_direction + 2 * direction) % 8
    selected.direction = next_direction
  else
    local next_direction = (current_direction + direction * direction_modifier) % 8
    if next_direction == selected.direction and selected.get_upgrade_target() and selected.get_upgrade_target().name == selected.name then
      selected.cancel_upgrade(player.force, player)
    else
      selected.order_upgrade{force = player.force, target = selected, player = player, direction = next_direction}
    end
  end
end
script.on_event("rc-rotate", function(event) remote_rotate(event, 1) end)
script.on_event("rc-reverse-rotate", function(event) remote_rotate(event, -1) end)

local function remote_deconstruct(event)
  local player = game.get_player(event.player_index)

  local selected = player.selected
  if not selected then return end

  if player.render_mode == defines.render_mode.game and can_reach_entity(player, selected) then return end  -- Let vanilla handle this
  if player.force ~= selected.force then
    player.create_local_flying_text{text = {"remote-configuration.cant-decon-unowned-structure"}, create_at_cursor = true}
    return
  end
  selected.order_deconstruction(player.force, player)
end
script.on_event("rc-deconstruct", remote_deconstruct)

local function remote_cancel_deconstruct(event)
  local player = game.get_player(event.player_index)

  local selected = player.selected
  if not selected then return end
  if player.force ~= selected.force then
    player.create_local_flying_text{text = {"remote-configuration.cant-cancel-decon-unowned-structure"}, create_at_cursor = true}
    return
  end

  selected.cancel_deconstruction(player.force, player)
end
script.on_event("rc-cancel-deconstruct", remote_cancel_deconstruct)

local function create_permission_group(config_changed_data)
  local permissions = game.permissions

  if config_changed_data then
    -- in on_configuration_changed
    if config_changed_data.mod_changes and config_changed_data.mod_changes["RemoteConfiguration"] then
      for _, player in pairs(game.players) do
        reset_player(player)
        player.opened = nil
      end
    end
    if permissions.get_group("Remote Configuration GUI opened") then
      permissions.get_group("Remote Configuration GUI opened").destroy()
    end
  end
  if permissions.get_group("Remote Configuration GUI opened") then
    return
  end
  local group = permissions.create_group("Remote Configuration GUI opened")
  if not group then
    log("Group not created!!!")
    game.print("[Remote Configuration] Group not created, please report!")
    return
  end
  group.set_allows_action(defines.input_action.begin_mining, false)
  group.set_allows_action(defines.input_action.begin_mining_terrain, false)
  group.set_allows_action(defines.input_action.build, false)
  group.set_allows_action(defines.input_action.build_rail, false)
  group.set_allows_action(defines.input_action.build_terrain, false)
  group.set_allows_action(defines.input_action.cursor_split, false)
  group.set_allows_action(defines.input_action.cursor_transfer, false)
  group.set_allows_action(defines.input_action.fast_entity_split, false)
  group.set_allows_action(defines.input_action.fast_entity_transfer, false)
  group.set_allows_action(defines.input_action.inventory_split, false)
  group.set_allows_action(defines.input_action.inventory_transfer, false)
  group.set_allows_action(defines.input_action.place_equipment, false)
  group.set_allows_action(defines.input_action.stack_split, false)
  group.set_allows_action(defines.input_action.stack_transfer, false)
  group.set_allows_action(defines.input_action.take_equipment, false)
  group.set_allows_action(defines.input_action.paste_entity_settings, false)
end

script.on_init(create_permission_group)
script.on_configuration_changed(create_permission_group)

remote.add_interface("remote-configuration-informatron", {
  informatron_menu = function(data)
    return {}
  end,
  informatron_page_content = function(data)
    -- data.page_name, data.player_index, data.element
    if data.page_name == "remote-configuration-informatron" then
      data.element.add{
        type = "label",
        caption = {"tips-and-tricks-item-description.rc-introduction"},
      }
    end
  end
})
