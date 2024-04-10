local algorithm = require("algorithm")
local mpp_util = require("mpp.mpp_util")
local enums = require("mpp.enums")
local blueprint_meta = require("mpp.blueprintmeta")
local compatibility = require("mpp.compatibility")
local common = require("layouts.common")

local layouts = algorithm.layouts

local gui = {}

--[[
	tag explanations:
	mpp_action - a choice between several settings for a "*_choice"
	mpp_toggle - a toggle for a boolean "*_choice"
]]

---@alias MppTagAction
---| "mpp_advanced_settings"
---| "mpp_entity_filtering_mode"
---| "mpp_action"
---| "mpp_toggle"
---| "mpp_blueprint_add_mode"
---| "mpp_blueprint_receptacle"
---| "mpp_fake_blueprint_button"
---| "mpp_delete_blueprint_button"
---| "mpp_drop_down"
---| "mpp_undo"

---@alias MppSettingSections
---| "layout"
---| "direction"
---| "miner"
---| "belt"
---| "space_belt"
---| "logistics"
---| "pole"
---| "misc"
---| "debugging"

---@type table<MppSettingSections, true>
local entity_sections = {
	miner = true,
	belt=true,
	space_belt=true,
	logistics=true,
	pole=true
}

---@class SettingValueEntry
---@field type string|nil Button type
---@field value string Value name
---@field tooltip LocalisedString
---@field icon SpritePath
---@field icon_enabled SpritePath?
---@field order string?
---@field default number? For "drop-down" element
---@field refresh boolean? Update selections?
---@field filterable boolean? Can entity be hidden
---@field disabled boolean? Is button disabled

---@class SettingValueEntryPrototype : SettingValueEntry
---@field action "mpp_prototype" Action tag override
---@field elem_type string
---@field elem_filters PrototypeFilter?
---@field elem_value string?

---@class TagsSimpleChoiceButton
---@field value string
---@field default string
---@field mpp_filterable boolean

---Creates a setting section (label + table)
---Can be hidden
---@param player_data PlayerData
---@param root any
---@param name MppSettingSections
---@return LuaGuiElement, LuaGuiElement
local function create_setting_section(player_data, root, name, opts)
	opts = opts or {}
	local section = root.add{type="flow", direction="vertical", style="mpp_section"}
	player_data.gui.section[name] = section
	section.add{type="label", style="subheader_caption_label", caption={"mpp.settings_"..name.."_label"}}
	local table_root = section.add{
		type="table",
		direction=opts.direction or "horizontal",
		style="filter_slot_table",
		column_count=opts.column_count or 6,
	}
	player_data.gui.tables[name] = table_root
	return table_root, section
end

local function style_helper_selection(check)
	if check then return "yellow_slot_button" end
	return "recipe_slot_button"
end

local function style_helper_advanced_toggle(check)
	return check and "mpp_selected_frame_action_button" or "frame_action_button"
end

local function style_helper_blueprint_toggle(check)
	return check and "mpp_blueprint_mode_button_active" or "mpp_blueprint_mode_button"
end

---@param player_data PlayerData
local function helper_undo_available(player_data)
	return player_data.last_state and #player_data.last_state._collected_ghosts > 0
end

---@param player_data PlayerData global player GUI reference object
---@param root LuaGuiElement
---@param action_type string Default action tag
---@param action MppSettingSections
---@param values (SettingValueEntry | SettingValueEntryPrototype)[]
local function create_setting_selector(player_data, root, action_type, action, values)
	local action_class = {}
	player_data.gui.selections[action] = action_class
	root.clear()
	local selected = player_data.choices[action.."_choice"]

	for _, value in ipairs(values) do

		local is_filtered = mpp_util.get_entity_hidden(player_data, action, value.value)
		if not player_data.entity_filtering_mode and is_filtered then
			goto continue
		end

		local action_type_override = value.action or action_type
		local toggle_value = action_type == "mpp_toggle" and player_data.choices[value.value.."_choice"]
		local style_check = value.value == selected or toggle_value
		local button
		if value.type == "choose-elem-button" then
			---@type LuaGuiElement
			button = root.add{
				type="choose-elem-button",
				style=style_helper_selection(),
				tooltip=mpp_util.wrap_tooltip(value.tooltip),
				elem_type=value.elem_type,
				elem_filters=value.elem_filters,
				item=value.elem_value, -- duplicate them all;
				entity=value.elem_value, -- and let Wube sort them out
				tags={[action_type_override]=action, value=value.value, default=value.default},
			}
			local fake_placeholder = button.add{
				type="sprite",
				sprite=value.icon,
				ignored_by_interaction=true,
				style="mpp_fake_item_placeholder",
				visible=not value.elem_value,
			}
		else
			local icon = value.icon
			if style_check and value.icon_enabled then icon = value.icon_enabled end
			---@type LuaGuiElement
			button = root.add{
				type="sprite-button",
				style=style_helper_selection(style_check),
				sprite=icon,
				tags={
					[action_type_override]=action,
					value=value.value,
					default=value.default,
					refresh=value.refresh,
					mpp_icon_default=value.icon,
					mpp_icon_enabled=value.icon_enabled,
					mpp_filterable=value.filterable,
				},
				tooltip=mpp_util.tooltip_entity_not_available(value.disabled, value.tooltip),
				enabled=not value.disabled,
			}
			if is_filtered then
				---@type LuaGuiElement
				local hidden =  button.add{
					type="sprite",
					style="mpp_filtered_entity",
					name="filtered",
					sprite="mpp_entity_filtered_overlay",
					ignored_by_interaction=true,
				}
			end
		end
		action_class[value.value] = button

		::continue::
	end
end

---@param player_data PlayerData
---@param button LuaGuiElement
local function set_player_blueprint(player_data, button)
	local choices = player_data.choices
	local player_blueprints = player_data.blueprints
	local blueprint_number = button.tags.mpp_fake_blueprint_button
	local blueprint_flow = player_blueprints.flow[button.parent.index]

	local current_blueprint = choices.blueprint_choice
	if current_blueprint == blueprint_number then
		return nil
	end
	
	if current_blueprint and current_blueprint.valid then
		local current_blueprint_button = player_blueprints.button[current_blueprint.item_number]
		current_blueprint_button.style = "mpp_fake_blueprint_button"
	end
	
	local blueprint = player_blueprints.mapping[blueprint_number]
	button.style = "mpp_fake_blueprint_button_selected"
	choices.blueprint_choice = blueprint
end

---@param player_data PlayerData
---@param table_root LuaGuiElement
---@param blueprint_item LuaItemStack
---@param cursor_stack LuaItemStack|nil
local function create_blueprint_entry(player_data, table_root, blueprint_item, cursor_stack)
	local blueprint_line = table_root.add{type="flow"}
	local item_number = blueprint_item.item_number --[[@as number]]
	player_data.blueprints.flow[item_number] = blueprint_line
	player_data.blueprints.mapping[item_number] = blueprint_item
	
	local blueprint_button = blueprint_line.add{
		type="button",
		style=(player_data.choices.blueprint_choice == blueprint_item and "mpp_fake_blueprint_button_selected" or "mpp_fake_blueprint_button"),
		tags={mpp_fake_blueprint_button=item_number},
	}
	player_data.blueprints.button[item_number] = blueprint_button

	if table_size(blueprint_item.blueprint_icons) > 1 then
		local fake_table = blueprint_button.add{
			type="table",
			style="mpp_fake_blueprint_table",
			direction="horizontal",
			column_count=2,
			tags={mpp_fake_blueprint_table=true},
			ignored_by_interaction=true,
		}

		for k, v in pairs(blueprint_item.blueprint_icons) do
			local s = v.signal
			local sprite = s.name or ""
			if s.type == "virtual" then
				sprite = "virtual-signal/"..sprite --wube pls
			else
				sprite = s.type .. "/" .. sprite
			end
			if not fake_table.gui.is_valid_sprite_path(sprite) then sprite = "item/item-unknown" end
			fake_table.add{
				type="sprite",
				sprite=(sprite),
				style="mpp_fake_blueprint_sprite",
				tags={mpp_fake_blueprint_sprite=true},
			}
		end
	else
		local bp_signal = ({next(blueprint_item.blueprint_icons)})[2].signal --[[@as SignalID]]
		local sprite = bp_signal.name
		if bp_signal.type == "virtual" then
			sprite = "virtual-signal/"..sprite --wube pls
		else
			sprite = bp_signal.type .. "/" .. sprite
		end
		blueprint_button.add{
			type="sprite",
			sprite=(sprite),
			ignored_by_interaction=true,
			style="mpp_fake_item_placeholder_blueprint",
			tags={mpp_fake_blueprint_sprite=true},
		}
		local a = false
	end

	local delete_button = blueprint_line.add{
		type="sprite-button",
		sprite="mpp_cross",
		style="mpp_delete_blueprint_button",
		tags={mpp_delete_blueprint_button=item_number},
		tooltip=mpp_util.wrap_tooltip{"gui.delete-blueprint-record"},
	}
	player_data.blueprints.delete[item_number] = delete_button

	local label, tooltip = mpp_util.blueprint_label(blueprint_item)
	blueprint_line.add{
		type="label",
		caption=label,
		tooltip=mpp_util.wrap_tooltip(tooltip),
	}

	local cached = player_data.blueprints.cache[item_number]
	if not cached then
		cached = blueprint_meta:new(blueprint_item)
		player_data.blueprints.cache[item_number] = cached
	else
		if not cached:check_valid() then
			blueprint_button.style = "mpp_fake_blueprint_button_invalid"
			if player_data.choices.blueprint_choice == blueprint_item then
				player_data.choices.blueprint_choice = nil
			end
		end
	end
	if cursor_stack and cursor_stack.valid and cached.valid then
		player_data.blueprints.original_id[item_number] = cursor_stack.item_number
	end

	if not player_data.choices.blueprint_choice and cached.valid then
		set_player_blueprint(player_data, blueprint_button)
	end
end

---@param player LuaPlayer
function gui.create_interface(player)
	---@type LuaGuiElement
	local frame = player.gui.screen.add{type="frame", name="mpp_settings_frame", direction="vertical"}
	---@type PlayerData
	local player_data = global.players[player.index]
	local player_gui = player_data.gui

	local titlebar = frame.add{type="flow", name="mpp_titlebar", direction="horizontal"}
	titlebar.add{type="label", style="frame_title", name="mpp_titlebar_label", caption={"mpp.settings_frame"}}
	titlebar.add{type="empty-widget", name="mpp_titlebar_spacer", horizontally_strechable=true}
	player_gui.advanced_settings = titlebar.add{
		type="sprite-button",
		style=style_helper_advanced_toggle(player_data.advanced),
		sprite="mpp_advanced_settings",
		tooltip=mpp_util.wrap_tooltip{"mpp.advanced_settings"},
		tags={mpp_advanced_settings=true},
	}
	player_gui.filtering_settings = titlebar.add{
		type="sprite-button",
		style=style_helper_advanced_toggle(player_data.entity_filtering_mode),
		sprite="mpp_entity_filtering_mode_enabled",
		tooltip=mpp_util.wrap_tooltip{"mpp.entity_filtering_mode"},
		tags={mpp_entity_filtering_mode=true},
	}
	player_gui.undo_button = titlebar.add{
		type="sprite-button",
		style=style_helper_advanced_toggle(),
		sprite="mpp_undo_enabled",
		tooltip=mpp_util.wrap_tooltip{"controls.undo"},
		tags={mpp_undo=true},
		enabled=helper_undo_available(player_data),
	}

	do -- layout selection
		local table_root, section = create_setting_section(player_data, frame, "layout")

		local choices = {}
		local index = 0
		for i, layout in ipairs(layouts) do
			if player_data.choices.layout_choice == layout.name then
				index = i
			end
			choices[#choices+1] = layout.translation
		end

		local flow = table_root.add{type="flow", direction="horizontal"}

		player_gui.layout_dropdown = flow.add{
			type="drop-down",
			items=choices,
			selected_index=index --[[@as uint]],
			tags={mpp_drop_down="layout", default=1},
		}

		player_gui.blueprint_add_button = flow.add{
			type="sprite-button",
			name="blueprint_add_button",
			sprite="mpp_plus",
			style=style_helper_blueprint_toggle(),
			tooltip=mpp_util.wrap_tooltip{"mpp.blueprint_add_mode"},
			tags={mpp_blueprint_add_mode=true},
		}
		player_gui.blueprint_add_button.visible = player_data.choices.layout_choice == "blueprints"
	end

	do -- Direction selection
		local table_root = create_setting_section(player_data, frame, "direction")
		create_setting_selector(player_data, table_root, "mpp_action", "direction", {
			{value="north", icon="mpp_direction_north"},
			{value="south", icon="mpp_direction_south"},
			{value="west", icon="mpp_direction_west"},
			{value="east", icon="mpp_direction_east"},
		})
	end

	do -- Miner selection
		local table_root, section = create_setting_section(player_data, frame, "miner")
	end

	do -- Belt selection
		local table_root, section = create_setting_section(player_data, frame, "belt")
	end

	do -- Space belt selection
		local table_root, section = create_setting_section(player_data, frame, "space_belt")
	end

	do -- Logistics selection
		local table_root, section = create_setting_section(player_data, frame, "logistics")
	end

	do -- Electric pole selection
		local table_root, section = create_setting_section(player_data, frame, "pole")
	end

	do -- Blueprint settings
		---@type LuaGuiElement, LuaGuiElement
		--local table_root, section = create_setting_section(player_data, frame, "blueprints")
		local section = frame.add{type="flow", direction="vertical"}
		player_data.gui.section["blueprints"] = section
		section.add{type="label", style="subheader_caption_label", caption={"mpp.settings_blueprints_label"}}

		local root = section.add{type="flow", direction="vertical"}
		player_data.gui.tables["blueprints"] = root

		player_gui.blueprint_add_section = section.add{
			type="flow",
			direction="horizontal",
		}

		player_gui.blueprint_receptacle = player_gui.blueprint_add_section.add{
			type="sprite-button",
			sprite="mpp_blueprint_add",
			tags={mpp_blueprint_receptacle=true},
		}
		local blueprint_label = player_gui.blueprint_add_section.add{
			type="label",
			caption={"mpp.label_add_blueprint", },
		}
		player_gui.blueprint_add_section.visible = player_data.blueprint_add_mode

		for i = 1, #player_data.blueprint_items do
			---@type LuaItemStack
			local item = player_data.blueprint_items[i]
			if item.valid and item.is_blueprint then
				create_blueprint_entry(player_data, root, item)
			end
		end
	end

	do -- Misc selection
		local table_root, section = create_setting_section(player_data, frame, "misc")
	end

	do -- Debugging rendering options
		local table_root, section = create_setting_section(player_data, frame, "debugging")
	end
end

---@param player_data PlayerData
local function update_miner_selection(player_data)
	local player_choices = player_data.choices
	local layout = layouts[player_choices.layout_choice]
	local restrictions = layout.restrictions

	player_data.gui.section["miner"].visible = restrictions.miner_available
	if not restrictions.miner_available then return end

	local near_radius_min, near_radius_max = restrictions.miner_size[1], restrictions.miner_size[2]
	local far_radius_min, far_radius_max = restrictions.miner_radius[1], restrictions.miner_radius[2]
	---@type SettingValueEntry[]
	local values = {}
	local existing_choice_is_valid = false
	local cached_miners, cached_resources = enums.get_available_miners()
	
	for _, miner_proto in pairs(cached_miners) do
		if mpp_util.check_filtered(miner_proto) then goto skip_miner end
		if mpp_util.check_entity_hidden(player_data, "miner", miner_proto) then goto skip_miner end
		local miner = mpp_util.miner_struct(miner_proto.name)

		local is_restricted = common.is_miner_restricted(miner, restrictions) or not layout:restriction_miner(miner)
		if not player_data.entity_filtering_mode and is_restricted then goto skip_miner end

		local tooltip = List{
			"", miner_proto.localised_name, "\n",
			"[img=mpp_tooltip_category_size] ", {"description.tile-size"}, (": %ix%i\n"):format(miner.size, miner.size),
			"[img=mpp_tooltip_category_mining_area] ", {"description.mining-area"}, (": %ix%i"):format(miner.area, miner.area),
		}
		tooltip
			:contitional_append(miner.power_source_tooltip,"\n", miner.power_source_tooltip)
			:contitional_append(miner.area <= miner.size, "\n[color=yellow]", {"mpp.label_insufficient_area"}, "[/color]")
			:contitional_append(not miner.supports_fluids, "\n[color=yellow]", {"mpp.label_no_fluid_mining"}, "[/color]")
			:contitional_append(miner.skip_outer, "\n[color=yellow]", {"mpp.label_oversized_drill"}, "[/color]")

		values[#values+1] = {
			value=miner.name,
			tooltip=tooltip,
			icon=("entity/"..miner.name),
			order=miner_proto.order,
			filterable=true,
			disabled=is_restricted,
		}
		if miner.name == player_choices.miner_choice then existing_choice_is_valid = true end

		::skip_miner::
	end

	if not existing_choice_is_valid and #values > 0 then
		if mpp_util.table_find(values, function(v) return v.value == layout.defaults.miner end) then
			player_choices.miner_choice = layout.defaults.miner
		else
			player_choices.miner_choice = values[1].value
		end
		existing_choice_is_valid = true
	elseif #values == 0 then
		player_choices.miner_choice = "none"
		values[#values+1] = {
			value="none",
			tooltip={"mpp.msg_miner_err_3"},
			icon="mpp_no_entity",
			order="",
		}
	end

	local table_root = player_data.gui.tables["miner"]
	create_setting_selector(player_data, table_root, "mpp_action", "miner", values)
end

---@param player LuaPlayer
local function update_belt_selection(player)
	local player_data = global.players[player.index]
	local choices = player_data.choices
	local layout = layouts[choices.layout_choice]
	local restrictions = layout.restrictions
	
	local is_space = compatibility.is_space(player.surface.index)
	player_data.gui.section["belt"].visible = restrictions.belt_available and not is_space
	if not restrictions.belt_available or is_space then return end

	local values = {}
	local existing_choice_is_valid = false

	local belts = game.get_filtered_entity_prototypes{{filter="type", type="transport-belt"}}
	for _, belt in pairs(belts) do
		local belt_struct = mpp_util.belt_struct(belt.name)
		if mpp_util.check_entity_hidden(player_data, "belt", belt) then goto skip_belt end

		local is_restricted = common.is_belt_restricted(belt_struct, restrictions)
		if not player_data.entity_filtering_mode and is_restricted then goto skip_belt end

		local belt_speed = belt.belt_speed * 60 * 8
		local specifier = belt_speed % 1 == 0 and ": %.0f " or ": %.1f "

		local tooltip = {
			"", belt.localised_name, "\n",
			{"description.belt-speed"}, specifier:format(belt_speed),
			{"description.belt-items"}, "/s",
		}

		if restrictions.uses_underground_belts and not belt_struct.related_underground_belt then
			table.insert(tooltip, {"", "\n[color=yellow]", {"mpp.label_belt_find_underground"}, "[/color]"})
		end

		values[#values+1] = {
			value=belt.name,
			tooltip=tooltip,
			icon=("entity/"..belt.name),
			order=belt.order,
			filterable=true,
			disabled=is_restricted,
		}
		if belt.name == choices.belt_choice then existing_choice_is_valid = true end

		::skip_belt::
	end

	if not existing_choice_is_valid and #values > 0 then
		if mpp_util.table_find(values, function(v) return v.value == layout.defaults.belt end) then
			choices.belt_choice = layout.defaults.belt
		else
			choices.belt_choice = values[1].value
		end
		existing_choice_is_valid = true
	elseif #values == 0 then
		player_data.choices.belt_choice = "none"
		values[#values+1] = {
			value="none",
			tooltip={"mpp.choice_none"},
			icon="mpp_no_entity",
			order="",
		}
	end

	local table_root = player_data.gui.tables["belt"]
	create_setting_selector(player_data, table_root, "mpp_action", "belt", values)
end

---@param player LuaPlayer
local function update_space_belt_selection(player)
	local player_data = global.players[player.index]
	local choices = player_data.choices
	local layout = layouts[choices.layout_choice]
	local restrictions = layout.restrictions

	local is_space = compatibility.is_space(player.surface.index)
	player_data.gui.section["space_belt"].visible = restrictions.belt_available and is_space
	if not restrictions.belt_available or not is_space then return end

	local values = {}
	local existing_choice_is_valid = false

	local belts = game.get_filtered_entity_prototypes{{filter="type", type="transport-belt"}}
	for _, belt in pairs(belts) do
		--if not compatibility.is_buildable_in_space(belt.name) then goto skip_belt end
		local belt_struct = mpp_util.belt_struct(belt.name)
		if mpp_util.check_entity_hidden(player_data, "space_belt", belt) then goto skip_belt end
		
		local is_restricted = common.is_belt_restricted(belt_struct, restrictions) or not compatibility.is_buildable_in_space(belt.name)
		if not player_data.entity_filtering_mode and is_restricted then goto skip_belt end
		--if is_space and not string.match(belt.name, "^se%-") then goto skip_belt end

		local belt_speed = belt.belt_speed * 60 * 8
		local specifier = belt_speed % 1 == 0 and ": %.0f " or ": %.1f "

		local tooltip = {
			"", belt.localised_name, "\n",
			{"description.belt-speed"}, specifier:format(belt_speed),
			{"description.belt-items"}, "/s",
		}

		values[#values+1] = {
			value=belt.name,
			tooltip=tooltip,
			icon=("entity/"..belt.name),
			order=belt.order,
			filterable=true,
			disabled=is_restricted,
		}
		if belt.name == choices.space_belt_choice then existing_choice_is_valid = true end

		::skip_belt::
	end

	if not existing_choice_is_valid and #values > 0 then
		if mpp_util.table_find(values, function(v) return v.value == layout.defaults.belt end) then
			choices.space_belt_choice = "se-space-transport-belt"
		else
			choices.space_belt_choice = values[1].value
		end
	elseif #values == 0 then
		player_data.choices.belt_choice = "none"
		values[#values+1] = {
			value="none",
			tooltip={"mpp.choice_none"},
			icon="mpp_no_entity",
			order="",
		}
	end

	local table_root = player_data.gui.tables["space_belt"]
	create_setting_selector(player_data, table_root, "mpp_action", "space_belt", values)
end


---@param player_data PlayerData
local function update_logistics_selection(player_data)
	local choices = player_data.choices
	local layout = layouts[choices.layout_choice]
	local restrictions = layout.restrictions
	local values = {}

	player_data.gui.section["logistics"].visible = restrictions.logistics_available
	if not restrictions.logistics_available then return end

	local filter = {
		["passive-provider"]=true,
		["active-provider"]=true,
		["storage"] = true,
	}

	local existing_choice_is_valid = false
	local logistics = game.get_filtered_entity_prototypes{{filter="type", type="logistic-container"}}
	for _, chest in pairs(logistics) do
		if mpp_util.check_entity_hidden(player_data, "logistics", chest) then goto skip_chest end
		local cbox = chest.collision_box
		local size = math.ceil(cbox.right_bottom.x - cbox.left_top.x)
		if size > 1 then goto skip_chest end
		if not filter[chest.logistic_mode] then goto skip_chest end

		values[#values+1] = {
			value=chest.name,
			tooltip=chest.localised_name,
			icon=("entity/"..chest.name),
			order=chest.order,
			filterable=true,
		}
		if chest.name == choices.logistics_choice then existing_choice_is_valid = true end

		::skip_chest::
	end

	if not existing_choice_is_valid and #values > 0 then
		if mpp_util.table_find(values, function(v) return v.value == layout.defaults.logistics end) then
			choices.logistics_choice = layout.defaults.logistics
		else
			choices.logistics_choice = values[1].value
		end
	elseif #values == 0 then
		player_data.choices.belt_choice = "none"
		values[#values+1] = {
			value="none",
			tooltip={"mpp.choice_none"},
			icon="mpp_no_entity",
			order="",
		}
	end

	local table_root = player_data.gui.tables["logistics"]
	create_setting_selector(player_data, table_root, "mpp_action", "logistics", values)
end

---@param player_data PlayerData
local function update_pole_selection(player_data)
	local choices = player_data.choices
	local layout = layouts[choices.layout_choice]
	local restrictions = layout.restrictions

	player_data.gui.section["pole"].visible = restrictions.pole_available
	if not restrictions.pole_available then return end

	local values = {}
	values[1] = {
		value="none",
		tooltip={"mpp.choice_none"},
		icon="mpp_no_entity",
		order="",
	}

	local existing_choice_is_valid = ("none" == choices.pole_choice)
	local poles = game.get_filtered_entity_prototypes{{filter="type", type="electric-pole"}}
	for _, pole_proto in pairs(poles) do
		if mpp_util.check_filtered(pole_proto) then goto skip_pole end
		if mpp_util.check_entity_hidden(player_data, "pole", pole_proto) then goto skip_pole end
		if pole_proto.supply_area_distance < 0.5 then goto skip_pole end
		local pole = mpp_util.pole_struct(pole_proto.name)

		local is_restricted = common.is_pole_restricted(pole, restrictions)

		if not player_data.entity_filtering_mode and is_restricted then goto skip_pole end

		local specifier = (pole.wire % 1 == 0 and ": %.0f ") or (pole.wire * 10 % 1 == 0 and ": %.1f ") or ": %.2f "
		local tooltip = {
			"", pole_proto.localised_name, "\n",
			"[img=mpp_tooltip_category_size] ", {"description.tile-size"}, (": %ix%i\n"):format(pole.size, pole.size),
			"[img=mpp_tooltip_category_supply_area] ", {"description.supply-area"}, (": %ix%i\n"):format(pole.supply_width, pole.supply_width),
			" [img=tooltip-category-electricity] ", {"description.wire-reach"}, specifier:format(pole.wire),
		}

		values[#values+1] = {
			value=pole_proto.name,
			tooltip=tooltip,
			icon=("entity/"..pole_proto.name),
			order=pole_proto.order,
			filterable=true,
			disabled=is_restricted,
		}
		if pole_proto.name == choices.pole_choice then existing_choice_is_valid = true end

		::skip_pole::
	end

	if not existing_choice_is_valid then
		choices.pole_choice = layout.defaults.pole
	end

	local table_root = player_data.gui.tables["pole"]
	create_setting_selector(player_data, table_root, "mpp_action", "pole", values)
end

---@param player LuaPlayer
local function update_misc_selection(player)
	local player_data = global.players[player.index]
	local choices = player_data.choices
	local layout = layouts[choices.layout_choice]
	---@type SettingValueEntry[]
	local values = {}

	if layout.restrictions.module_available then
		---@type string|nil
		local existing_choice = choices.module_choice
		if not game.item_prototypes[existing_choice] then
			existing_choice = nil
			choices.module_choice = "none"
		end

		values[#values+1] = {
			action="mpp_prototype",
			value="module",
			tooltip={"gui.module"},
			icon=("mpp_no_module"),
			elem_type="item",
			elem_filters={{filter="type", type="module"}},
			elem_value = existing_choice,
			type="choose-elem-button",
		}
	end
	
	if layout.restrictions.lamp_available then
		values[#values+1] = {
			value="lamp",
			tooltip={"mpp.choice_lamp"},
			icon=("mpp_no_lamp"),
			icon_enabled=("entity/small-lamp"),
		}
	end
	
	if layout.restrictions.pipe_available then
		---@type string | nil
		local existing_choice = choices.pipe_choice
		if not game.entity_prototypes[existing_choice] then
			existing_choice = nil
			choices.pipe_choice = "none"
		end

		values[#values+1] = {
			action="mpp_prototype",
			value="pipe",
			tooltip={"entity-name.pipe"},
			icon=("mpp_no_pipe"),
			elem_type="entity",
			elem_filters={{filter="type", type="pipe"}},
			elem_value = existing_choice,
			type="choose-elem-button",
		}
	end

	if layout.restrictions.deconstruction_omit_available then
		values[#values+1] = {
			value="deconstruction",
			tooltip={"mpp.choice_deconstruction"},
			icon=("mpp_deconstruct"),
			icon_enabled=("mpp_omit_deconstruct"),
		}
	end

	if compatibility.is_space(player.surface_index) and layout.restrictions.landfill_omit_available then
		local existing_choice = choices.space_landfill_choice
		if not game.entity_prototypes[existing_choice] then
			existing_choice = "se-space-platform-scaffold"
			choices.space_landfill_choice = existing_choice
		end

		values[#values+1] = {
			action="mpp_prototype",
			value="space_landfill",
			icon=("item/"..existing_choice),
			elem_type="item",
			elem_filters={
				{filter="name", name="se-space-platform-scaffold"},
				{filter="name", name="se-space-platform-plating", mode="or"},
				{filter="name", name="se-spaceship-floor", mode="or"},
			},
			elem_value = choices.space_landfill_choice,
			type="choose-elem-button",
		}
	end

	if layout.restrictions.landfill_omit_available then
		values[#values+1] = {
			value="landfill",
			tooltip={"mpp.choice_landfill"},
			icon=("item/landfill"),
			icon_enabled=("mpp_omit_landfill")
		}
	end

	if layout.restrictions.coverage_tuning then
		values[#values+1] = {
			value="coverage",
			tooltip={"mpp.choice_coverage"},
			icon=("mpp_miner_coverage_disabled"),
			icon_enabled=("mpp_miner_coverage"),
		}
	end

	if layout.restrictions.start_alignment_tuning then
		values[#values+1] = {
			value="start",
			tooltip={"mpp.choice_start"},
			icon=("mpp_align_start"),
		}
	end

	if layout.restrictions.placement_info_available then
		values[#values+1] = {
			value="print_placement_info",
			tooltip={"mpp.print_placement_info"},
			icon=("mpp_print_placement_info_disabled"),
			icon_enabled=("mpp_print_placement_info_enabled"),
		}
	end

	if layout.restrictions.lane_filling_info_available then
		values[#values+1] = {
			value="display_lane_filling",
			tooltip={"mpp.display_lane_filling"},
			icon=("mpp_display_lane_filling_disabled"),
			icon_enabled=("mpp_display_lane_filling_enabled"),
		}
	end

	if player_data.advanced and layout.restrictions.pipe_available then
		values[#values+1] = {
			value="force_pipe_placement",
			tooltip={"mpp.force_pipe_placement"},
			icon=("mpp_force_pipe_disabled"),
			icon_enabled=("mpp_force_pipe_enabled"),
		}
	end

	if player_data.advanced and false then
		values[#values+1] = {
			value="dumb_power_connectivity",
			tooltip={"mpp.dumb_power_connectivity"},
			icon=("entity/medium-power-pole"),
		}
	end

	local misc_section = player_data.gui.section["misc"]
	misc_section.visible = #values > 0

	local table_root = player_data.gui.tables["misc"]
	create_setting_selector(player_data, table_root, "mpp_toggle", "misc", values)
end

---@param player_data PlayerData
local function update_blueprint_selection(player_data)
	local choices = player_data.choices
	local player_blueprints = player_data.blueprints
	player_data.gui.section["blueprints"].visible = choices.layout_choice == "blueprints"
	player_data.gui["blueprint_add_section"].visible = player_data.blueprint_add_mode
	player_data.gui["blueprint_add_button"].style = style_helper_blueprint_toggle(player_data.blueprint_add_mode)

	for key, value in pairs(player_blueprints.delete) do
		value.visible = player_data.blueprint_add_mode
	end
end

local function update_debugging_selection(player_data)

	local is_debugging = not not __DebugAdapter
	player_data.gui.section["debugging"].visible = is_debugging
	if not is_debugging then
		return
	end

	---@type SettingValueEntry[]
	local values = {
		{
			value="draw_clear_rendering",
			tooltip="Clear rendering",
			icon=("mpp_no_entity"),
		},
		{
			value="draw_drill_struct",
			tooltip="Draw drill struct overlay",
			icon=("entity/electric-mining-drill"),
		},
		{
			value="draw_pole_layout",
			tooltip="Draw power pole layout",
			icon=("entity/medium-electric-pole"),
		},
		{
			value="draw_pole_layout_compact",
			tooltip="Draw power pole layout compact",
			icon=("entity/medium-electric-pole"),
		},
		{
			value="draw_built_things",
			tooltip="Draw built tile values",
			icon=("mpp_print_placement_info_enabled"),
		},
		{
			value="draw_drill_convolution",
			tooltip="Draw a drill convolution preview",
			icon=("mpp_debugging_grid_convolution"),
		},
		{
			value="draw_power_grid",
			tooltip="Draw power grid connectivity",
			icon=("entity/substation"),
		},
		{
			value="draw_centricity",
			tooltip="Draw layout centricity",
			icon=("mpp_plus"),
		},
		{
			value="draw_blueprint_data",
			tooltip="Draw blueprint entities",
			icon=("item/blueprint"),
		},
		{
			value="draw_deconstruct_preview",
			tooltip="Draw deconstruct preview",
			icon=("item/deconstruction-planner"),
		},
		{
			value="draw_can_place_entity",
			tooltip="Draw entity placement checks",
			icon=("item/blueprint"),
		},
	}

	local debugging_section = player_data.gui.section["debugging"]
	debugging_section.visible = #values > 0

	local table_root = player_data.gui.tables["debugging"]
	create_setting_selector(player_data, table_root, "mpp_action", "debugging", values)
end

---@param player LuaPlayer
local function update_selections(player)
	---@type PlayerData
	local player_data = global.players[player.index]
	player_data.gui.blueprint_add_button.visible = player_data.choices.layout_choice == "blueprints"
	mpp_util.update_undo_button(player_data)
	update_miner_selection(player_data)
	update_belt_selection(player)
	update_space_belt_selection(player)
	update_logistics_selection(player_data)
	update_pole_selection(player_data)
	update_blueprint_selection(player_data)
	update_misc_selection(player)
	update_debugging_selection(player_data)
end

---@param player LuaPlayer
function gui.show_interface(player)
	---@type LuaGuiElement
	local frame = player.gui.screen["mpp_settings_frame"]
	local player_data = global.players[player.index]
	player_data.blueprint_add_mode = false
	if frame then
		frame.visible = true
	else
		gui.create_interface(player)
	end
	update_selections(player)
end

---@param player LuaPlayer
local function abort_blueprint_mode(player)
	local player_data = global.players[player.index]
	if not player_data.blueprint_add_mode then return end
	player_data.blueprint_add_mode = false
	update_blueprint_selection(player_data)
	local cursor_stack = player.cursor_stack
	if cursor_stack == nil then return end
	player.clear_cursor()
	cursor_stack.set_stack("mining-patch-planner")
end

---@param player LuaPlayer
function gui.hide_interface(player)
	---@type LuaGuiElement
	local frame = player.gui.screen["mpp_settings_frame"]
	local player_data = global.players[player.index]
	player_data.blueprint_add_mode = false
	if frame then
		frame.visible = false
	end
end

---@param event EventDataGuiClick
local function on_gui_click(event)
	local player = game.players[event.player_index]
	---@type PlayerData
	local player_data = global.players[event.player_index]
	local evt_ele_tags = event.element.tags
	if evt_ele_tags["mpp_advanced_settings"] then
		abort_blueprint_mode(player)

		if __DebugAdapter and event.alt then
			local setting = player.mod_settings["mpp-dump-heuristics-data"].value

			player.mod_settings["mpp-dump-heuristics-data"] = {value = not setting}

			player.print("Set dumping option to "..tostring(not setting))
			return
		end

		local value = not player_data.advanced
		player_data.advanced = value
		update_selections(player)
		player_data.gui["advanced_settings"].style = style_helper_advanced_toggle(value)

	elseif evt_ele_tags["mpp_entity_filtering_mode"] then
		abort_blueprint_mode(player)

		local value = not player_data.entity_filtering_mode
		player_data.entity_filtering_mode = value
		update_selections(player)
		player_data.gui["filtering_settings"].style = style_helper_advanced_toggle(value)

	elseif evt_ele_tags["mpp_action"] then
		abort_blueprint_mode(player)

		local action = evt_ele_tags["mpp_action"]
		local value = evt_ele_tags["value"]
		local last_value = player_data.choices[action.."_choice"]

		if player_data.gui.selections[action][last_value] then
			player_data.gui.selections[action][last_value].style = style_helper_selection(false)
		end

		if event.shift and event.button == defines.mouse_button_type.right and evt_ele_tags.mpp_filterable then

			local entity = action..":"..value
			local is_filtered = player_data.filtered_entities[entity]
			
			local visible_values = 0
			for _, element in pairs(event.element.parent.children) do
				---@cast element LuaGuiElement
				if not element.filtered and element.enabled then
					visible_values = visible_values + 1
				end
			end

			if #event.element.parent.children < 2 then
				player.print({"mpp.msg_print_cant_hide_last_choice"})
			elseif is_filtered then
				player_data.filtered_entities[entity] = nil
			elseif visible_values > 1 then
				player_data.filtered_entities[entity] = true
			else
				player.print({"mpp.msg_print_cant_hide_last_choice"})
			end

			update_selections(player)
			return
		end
		
		event.element.style = style_helper_selection(true)
		player_data.choices[action.."_choice"] = value
		update_selections(player)
	elseif evt_ele_tags["mpp_toggle"] then
		abort_blueprint_mode(player)

		local action = evt_ele_tags["mpp_toggle"]
		local value = evt_ele_tags["value"]
		local last_value = player_data.choices[value.."_choice"]

		if evt_ele_tags.mpp_icon_enabled then
			if not last_value then
				event.element.sprite = evt_ele_tags.mpp_icon_enabled --[[@as string]]
			else
				event.element.sprite = evt_ele_tags.mpp_icon_default --[[@as string]]
			end
		end

		player_data.choices[value.."_choice"] = not last_value
		event.element.style = style_helper_selection(not last_value)
		if evt_ele_tags.refresh then update_selections(player) end
	elseif evt_ele_tags["mpp_blueprint_add_mode"] then
		player_data.blueprint_add_mode = not player_data.blueprint_add_mode
		player.clear_cursor()
		if not player_data.blueprint_add_mode then
			player.cursor_stack.set_stack("mining-patch-planner")
		end
		player_data.gui["blueprint_add_section"].visible = player_data.blueprint_add_mode
		player_data.gui["blueprint_add_button"].style = style_helper_blueprint_toggle(player_data.blueprint_add_mode)
		update_blueprint_selection(player_data)
	elseif evt_ele_tags["mpp_blueprint_receptacle"] then
		local cursor_stack = player.cursor_stack
		if (
			not cursor_stack or
			not cursor_stack.valid or
			not cursor_stack.valid_for_read or
			not cursor_stack.is_blueprint
		) then
			if cursor_stack and not cursor_stack.is_blueprint then
				player.print({"mpp.msg_blueprint_valid"})
			end
			return nil
		elseif not mpp_util.validate_blueprint(player, cursor_stack) then
			return nil
		end

		local player_blueprints = player_data.blueprint_items
		local pending_slot = player_blueprints.find_empty_stack()
		
		---@param bp LuaItemStack
		local function check_existing(bp)
			for k, v in pairs(player_data.blueprints.original_id) do
				if v == bp.item_number then return true end
			end
		end
		if check_existing(cursor_stack) then
			player.print({"mpp.msg_blueprint_existing"})
			return nil
		end

		if pending_slot == nil then
			player_blueprints.resize(#player_blueprints+1--[[@as uint16]])
			pending_slot = player_blueprints.find_empty_stack()
		end
		
		if pending_slot then
			pending_slot.set_stack(cursor_stack)
			local blueprint_table = player_data.gui.tables["blueprints"]
			create_blueprint_entry(player_data, blueprint_table, pending_slot, cursor_stack)
		else
			player.print({"mpp.msg_blueprint_fatal_error"}, {r=1,g=0,b=0})
		end

	elseif evt_ele_tags["mpp_fake_blueprint_button"] then
		local button = event.element
		if button.style.name ~= "mpp_fake_blueprint_button_invalid" then
			set_player_blueprint(player_data, button)
			abort_blueprint_mode(player)
		end
	elseif evt_ele_tags["mpp_delete_blueprint_button"] then
		local choices = player_data.choices
		local deleted_number = evt_ele_tags["mpp_delete_blueprint_button"]
		local player_blueprints = player_data.blueprints
		if choices.blueprint_choice and choices.blueprint_choice.item_number == deleted_number then
			choices.blueprint_choice = nil
		end
		player_blueprints.mapping[deleted_number].clear()
		player_blueprints.flow[deleted_number].destroy()

		player_blueprints.mapping[deleted_number] = nil
		player_blueprints.flow[deleted_number] = nil
		player_blueprints.button[deleted_number] = nil
		player_blueprints.delete[deleted_number] = nil
		player_blueprints.cache[deleted_number] = nil
		player_blueprints.original_id[deleted_number] = nil
	elseif evt_ele_tags["mpp_undo"] then
		local state = player_data.last_state
		if not state then return end
		algorithm.cleanup_last_state(player_data)
		return
	end
end
script.on_event(defines.events.on_gui_click, on_gui_click)

---@param event EventDataGuiSelectionStateChanged
local function on_gui_selection_state_changed(event)
	local player = game.players[event.player_index]
	if event.element.tags["mpp_drop_down"] then
		abort_blueprint_mode(player)
		---@type PlayerData
		local player_data = global.players[event.player_index]

		local action = event.element.tags["mpp_drop_down"]
		local value = layouts[event.element.selected_index].name
		player_data.choices.layout_choice = value
		update_selections(player)
	end
end
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)

---@param event EventData.on_gui_elem_changed
local function on_gui_elem_changed(event)
	local element = event.element
	local player = game.players[event.player_index]
	---@type PlayerData
	local player_data = global.players[event.player_index]
	local evt_ele_tags = element.tags
	if evt_ele_tags["mpp_prototype"] then
		local action = evt_ele_tags.value
		local old_choice = player_data.choices[action.."_choice"]
		local choice = element.elem_value
		element.children[1].visible = not choice
		player_data.choices[action.."_choice"] = choice or "none"
	end
end

script.on_event(defines.events.on_gui_elem_changed, on_gui_elem_changed)

return gui
