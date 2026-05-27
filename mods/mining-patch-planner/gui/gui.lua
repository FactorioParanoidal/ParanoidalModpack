local algorithm = require("algorithm")
local mpp_util = require("mpp.mpp_util")
local enums = require("mpp.enums")
local blueprint_meta = require("mpp.blueprintmeta")
local compatibility = require("mpp.compatibility")
local belt_planner = require("mpp.belt_planner")
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
---| "miner_quality"
---| "belt"
---| "belt_quality"
---| "space_belt"
---| "space_belt_quality"
---| "logistics"
---| "logistics_quality"
---| "pole"
---| "pole_quality"
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
---@field sort number[]?
---@field default number? For "drop-down" element
---@field refresh boolean? Update selections when clicked?
---@field filterable boolean? Can entity be hidden
---@field disabled boolean? Is button disabled
---@field no_quality boolean? Don't show quality badge

---@class SettingValueEntryPrototype : SettingValueEntry
---@field action "mpp_prototype" Action tag override
---@field elem_type string
---@field elem_filters PrototypeFilter?
---@field elem_value string?|table?

---@class TagsSimpleChoiceButton
---@field value string
---@field default string
---@field mpp_filterable boolean

---@class SettingSectionCreateOptions
---@field direction? GuiDirection
---@field column_count? number

---Creates a setting section (label + table)
---Can be hidden
---@param player_data PlayerData
---@param root any
---@param name MppSettingSections
---@param opts? SettingSectionCreateOptions
---@return LuaGuiElement
---@return LuaGuiElement
---@return LuaGuiElement?
local function create_setting_section(player_data, root, name, opts)
	opts = opts or {}
	local section = root.add{type="flow", direction="vertical", style="mpp_section"}
	player_data.gui.section[name] = section
	section.add{type="label", name="section_label", style="subheader_caption_label", caption={"mpp.settings_"..name.."_label"}}
	local table_root = section.add{
		type="table",
		direction=opts.direction or "horizontal",
		style="filter_slot_table",
		column_count=opts.column_count or 6,
	}
	player_data.gui.tables[name] = table_root
	
	return table_root, section
end

---@param player_data PlayerData
---@param section LuaGuiElement
---@param name string
---@param opts? SettingSectionCreateOptions
---@return unknown
local function append_quality_table(player_data, section, name, opts)
	opts = opts or {}
	quality_root = section.add{
		type="table",
		direction="horizontal",
		style="mpp_quality_table",
		column_count=opts.column_count or 10,
	}
	player_data.gui.tables[name] = quality_root
	quality_root.visible = script.feature_flags.quality
	return quality_root
end

local function style_helper_selection(check)
	if check then return "yellow_slot_button" end
	return "slot_button"
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

local function style_helper_quality(check, filtered)
	return filtered and "mpp_button_quality_hidden" or check and "mpp_button_quality_active" or "mpp_button_quality"
end

---@class SettingSelectorOptions
---@field style_func? fun(bool, bool): string first param to check if is currently selected, second param if is filtered
---@field shown_quality? string Adds quality badge on the icon
---@field alternate_visibility? true Don't show the eye if setting is filtered

---@param player_data PlayerData global player GUI reference object
---@param root LuaGuiElement
---@param action_type string Default action tag
---@param action MppSettingSections
---@param values (SettingValueEntry | SettingValueEntryPrototype)[]
---@param opts? SettingSelectorOptions
local function create_setting_selector(player_data, root, action_type, action, values, opts)
	opts = opts or {}
	local action_class = {}
	player_data.gui.selections[action] = action_class
	root.clear()
	local selected = player_data.choices[action.."_choice"]

	local style_helper = opts.style_func or style_helper_selection
	
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
				style=style_helper(),
				tooltip=mpp_util.wrap_tooltip(value.tooltip),
				elem_type=value.elem_type,
				elem_filters=value.elem_filters,
				tags={[action_type_override]=action, value=value.value, default=value.default},
			}
			button.elem_value = value.elem_value
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
				style=style_helper(style_check, is_filtered),
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
			if is_filtered and not opts.alternate_visibility then
				---@type LuaGuiElement
				local hidden =  button.add{
					type="sprite",
					style="mpp_filtered_entity",
					name="filtered",
					sprite="mpp_entity_filtered_overlay",
					ignored_by_interaction=true,
				}
			end
			if not value.no_quality and opts.shown_quality and script.feature_flags.quality then
				local flow = button.add{
					type="flow",
					direction = "vertical",
				}
				flow.style.size = 40
				local padding = flow.add{
					type="sprite",
					resize_to_sprite = false,
					ignored_by_interaction = true,
				}
				padding.style.height = 14
				local quality_badge = flow.add{
					type = "sprite",
					style = "mpp_quality_badge",
					resize_to_sprite = false,
					name = "quality_badge",
					sprite = "quality/"..opts.shown_quality,
					ignored_by_interaction = true,
					enabled=not value.disabled,
				}
			end
		end
		action_class[value.value] = button

		::continue::
	end
end

---@param player_data PlayerData global player GUI reference object
---@param root LuaGuiElement
---@param action_type string Default action tag
---@param action MppSettingSections
---@param values (SettingValueEntry | SettingValueEntryPrototype)[]
---@param opts? SettingSelectorOptions
local function create_quality_selector(player_data, root, action_type, action, values, opts)
	if #values > 10 then
		root.clear()
		local index = 0
		local value = player_data.choices[action.."_choice"]
		local choices = {}
		for i, qual in pairs(values) do
			---@diagnostic disable-next-line: param-type-mismatch
			table.insert(choices, {"", "[quality="..qual.value.."] ", qual.tooltip})
			if qual.value == value then
				index = i
			end
		end
		
		-- player_gui.layout_dropdown = 
		local dropdown = root.add{
			type="drop-down",
			style="mpp_quality_dropdown",
			items=choices,
			selected_index=index --[[@as uint]],
			tags={mpp_drop_down=action, mpp_value_map="quality", default=0},
		}
		player_data.gui.selections[action.."_choice"] = dropdown
	else
		create_setting_selector(player_data, root, action_type, action, values, opts)
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

	local icons = blueprint_item.preview_icons or blueprint_item.default_icons
	
	local function sprite_path(signal)
		local sprite = signal.name
		if signal.type == "virtual" then
			sprite = "virtual-signal/"..sprite --wube pls
		elseif signal.type then
			sprite = signal.type .. "/" .. sprite
		else
			sprite = "entity/" .. sprite
		end
		if not helpers.is_valid_sprite_path(sprite) then
			return "item/item-unknown"
		end
		return sprite
	end
	
	if table_size(icons) > 1 then
		local fake_table = blueprint_button.add{
			type="table",
			style="mpp_fake_blueprint_table",
			direction="horizontal",
			column_count=2,
			tags={mpp_fake_blueprint_table=true},
			ignored_by_interaction=true,
		}

		for k, v in pairs(icons) do
			local sprite = sprite_path(v.signal)
			fake_table.add{
				type="sprite",
				sprite=(sprite),
				style="mpp_fake_blueprint_sprite",
				tags={mpp_fake_blueprint_sprite=true},
			}
		end
	else
		local bp_signal = ({next(icons)})[2].signal --[[@as SignalID]]
		local sprite = sprite_path(bp_signal)
		blueprint_button.add{
			type="sprite",
			sprite=(sprite),
			ignored_by_interaction=true,
			style="mpp_fake_item_placeholder_blueprint",
			tags={mpp_fake_blueprint_sprite=true},
		}
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
	local player_data = storage.players[player.index]
	local player_gui = player_data.gui

	local titlebar = frame.add{type="flow", name="mpp_titlebar", direction="horizontal"}
	titlebar.add{type="label", style="frame_title", name="mpp_titlebar_label", caption={"mpp.settings_frame"}}
	titlebar.add{type="empty-widget", name="mpp_titlebar_spacer", horizontally_strechable=true}
	player_gui.quality_toggle = titlebar.add{
		type="sprite-button",
		style=style_helper_advanced_toggle(player_data.quality_pickers),
		sprite="utility/any_quality",
		tooltip=mpp_util.wrap_tooltip{"mpp.quality_settings"},
		tags={mpp_quality_pickers=true},
	}
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
	-- TODO: move to Factorio undo
	player_gui.undo_button = titlebar.add{
		type="sprite-button",
		style=style_helper_advanced_toggle(),
		sprite="mpp_undo_enabled",
		tooltip=mpp_util.wrap_tooltip{"controls.undo"},
		tags={mpp_undo=true},
		enabled=helper_undo_available(player_data),
	}

	do -- layout selection
		local table_root, section = create_setting_section(player_data, frame, "layout", {column_count=2})

		local choices = List()
		local index = 0
		for i, layout in ipairs(layouts) do
			if player_data.choices.layout_choice == layout.name then
				index = i
			end
			choices:push(layout.translation)
		end

		local flow = table_root.add{type="flow", direction="horizontal"}

		player_gui.layout_dropdown = flow.add{
			type="drop-down",
			items=choices,
			style="mpp_quality_dropdown",
			selected_index=index --[[@as uint]],
			tags={mpp_drop_down="layout", mpp_value_map="layout", default=1},
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
		local table_root, section = create_setting_section(player_data, frame, "direction")
		section.section_label.caption = {"", section.section_label.caption, " [img=info]"}
		section.section_label.tooltip = mpp_util.wrap_tooltip{"mpp.label_rotate_keybind_tip"}
		create_setting_selector(player_data, table_root, "mpp_action", "direction", {
			{value="north", icon="mpp_direction_north"},
			{value="east", icon="mpp_direction_east"},
			{value="south", icon="mpp_direction_south"},
			{value="west", icon="mpp_direction_west"},
		})
	end

	do -- Miner selection
		local table_root, section = create_setting_section(player_data, frame, "miner")
		local quality_root = append_quality_table(player_data, section, "miner_quality", {column_count=10})
	end

	do -- Belt selection
		local table_root, section = create_setting_section(player_data, frame, "belt")
		local quality_root = append_quality_table(player_data, section, "belt_quality", {column_count=10})
	end

	do -- Space belt selection
		local table_root, section = create_setting_section(player_data, frame, "space_belt")
		local quality_root = append_quality_table(player_data, section, "space_belt_quality", {column_count=10})
	end

	do -- Logistics selection
		local table_root, section = create_setting_section(player_data, frame, "logistics")
		local quality_root = append_quality_table(player_data, section, "logistics_quality", {column_count=10})
	end

	do -- Electric pole selection
		local table_root, section = create_setting_section(player_data, frame, "pole")
		local quality_root = append_quality_table(player_data, section, "pole_quality", {column_count=10})
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
local function update_direction_section(player_data)
	local section = player_data.gui.selections.direction
	local choice = player_data.choices.direction_choice
	
	for key, element in pairs(section) do
		element.style = style_helper_selection(key == choice)
	end
end

gui.update_direction_section = update_direction_section

---@param player_data PlayerData
local function update_miner_selection(player_data)
	local player_choices = player_data.choices
	local layout = layouts[player_choices.layout_choice]
	local restrictions = layout.restrictions

	player_data.gui.section["miner"].visible = restrictions.miner_available
	if not restrictions.miner_available then return end

	local near_radius_min, near_radius_max = restrictions.miner_size[1], restrictions.miner_size[2]
	local far_radius_min, far_radius_max = restrictions.miner_radius[1], restrictions.miner_radius[2]
	local values = List() --[[@as List<SettingValueEntry>]]
	local existing_choice_is_valid = false
	local cached_miners, cached_resources = enums.get_available_miners()
	
	for _, miner_proto in pairs(cached_miners) do
		local miner = mpp_util.miner_struct(miner_proto.name)
		if mpp_util.check_filtered(miner_proto) or miner.filtered then goto skip_miner end
		if mpp_util.check_entity_hidden(player_data, "miner", miner_proto) then goto skip_miner end

		local is_restricted = common.is_miner_restricted(miner, restrictions) or not layout:restriction_miner(miner)
		if not player_data.entity_filtering_mode and is_restricted then goto skip_miner end

		---@type List<LocalisedString>
		local tooltip = List{
			"", mpp_util.entity_name_with_quality(miner_proto.localised_name, player_choices.miner_quality_choice), "\n",
			"[img=mpp_tooltip_category_size] ", {"description.tile-size"}, (": %ix%i\n"):format(miner.size, miner.size),
			"[img=mpp_tooltip_category_mining_area] ", {"description.mining-area"}, (": %ix%i"):format(miner.real_area, miner.real_area),
		}
		tooltip
			:conditional_append(miner.power_source_tooltip ~= nil, "\n", miner.power_source_tooltip)
			:conditional_append(miner.area <= miner.size, "\n[color=yellow]", {"mpp.label_insufficient_area"}, "[/color]")
			:conditional_append(not miner.supports_fluids, "\n[color=yellow]", {"mpp.label_no_fluid_mining"}, "[/color]")
			:conditional_append(miner.oversized, "\n[color=yellow]", {"mpp.label_oversized_drill"}, "[/color]")

		values:push{
			value=miner.name,
			tooltip=tooltip,
			icon=("entity/"..miner.name),
			order=miner_proto.order,
			filterable=true,
			disabled=is_restricted,
			sort={miner.size, miner.area},
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
		values:push{
			value="none",
			tooltip={"mpp.msg_miner_err_3"},
			icon="mpp_no_entity",
			order="",
			sort={1, 1}
		}
	end
	
	table.sort(values, function(a, b)
		local a1, a2, a3, b1, b2, b3 = a.sort[1], a.sort[2], a.order, b.sort[1], b.sort[2], b.order
		return (a1 == b1 and (a2 == b2 and a3 < b3 or a2 < b2)) or a1 < b1
	end)

	local table_root = player_data.gui.tables["miner"]
	create_setting_selector(
		player_data,
		table_root,
		"mpp_action",
		"miner",
		values,
		{shown_quality=player_data.choices.miner_quality_choice}
	)
	
	create_quality_selector(
		player_data,
		player_data.gui.tables["miner_quality"],
		"mpp_action",
		"miner_quality",
		mpp_util.quality_list(),
		{style_func = style_helper_quality, alternate_visibility=true}
	)
end

---@param player LuaPlayer
local function update_belt_selection(player)
	local player_data = storage.players[player.index]
	local choices = player_data.choices
	local layout = layouts[choices.layout_choice]
	local restrictions = layout.restrictions
	
	local is_space = compatibility.is_space(player.surface.index)
	player_data.gui.section["belt"].visible = restrictions.belt_available and not is_space
	if not restrictions.belt_available or is_space then return end

	local values = List() --[[@as List<SettingValueEntry>]]
	local existing_choice_is_valid = false

	local belts = prototypes.get_entity_filtered{{filter="type", type="transport-belt"}}
	for _, belt in pairs(belts) do
		if mpp_util.check_filtered(belt) then goto skip_belt end
		local belt_struct = mpp_util.belt_struct(belt.name)
		if mpp_util.check_entity_hidden(player_data, "belt", belt) then goto skip_belt end

		local is_restricted = common.is_belt_restricted(belt_struct, restrictions)
		if not player_data.entity_filtering_mode and is_restricted then goto skip_belt end

		local belt_speed = belt_struct.speed * 2
		local specifier = belt_speed % 1 == 0 and ": %.0f " or ": %.1f "

		local tooltip = {
			"", mpp_util.entity_name_with_quality(belt.localised_name, choices.belt_quality_choice), "\n",
			{"description.belt-speed"}, specifier:format(belt_speed),
			{"description.belt-items"}, "/s",
		}

		if restrictions.uses_underground_belts and not belt_struct.related_underground_belt then
			table.insert(tooltip, {"", "\n[color=yellow]", {"mpp.label_belt_find_underground"}, "[/color]"})
		end

		values:push{
			value=belt.name,
			tooltip=tooltip,
			icon=("entity/"..belt.name),
			order=belt.order,
			filterable=true,
			disabled=is_restricted,
			sort={belt_struct.speed},
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
		values:push{
			value="none",
			tooltip={"mpp.choice_none"},
			icon="mpp_no_entity",
			order="",
			sort={1},
		}
	end
	
	table.sort(values, function(a, b)
		local a1, a2, b1, b2 = a.sort[1], a.order, b.sort[1], b.order
		return (a1 == b1 and a2 < b2) or a1 < b1
	end)

	local table_root = player_data.gui.tables["belt"]
	create_setting_selector(player_data, table_root, "mpp_action", "belt", values,
		{shown_quality=player_data.choices.belt_quality_choice}
	)
	
	create_quality_selector(
		player_data,
		player_data.gui.tables["belt_quality"],
		"mpp_action",
		"belt_quality",
		mpp_util.quality_list(),
		{style_func = style_helper_quality, alternate_visibility=true}
	)
end

---@param player LuaPlayer
local function update_space_belt_selection(player)
	local player_data = storage.players[player.index]
	local choices = player_data.choices
	local layout = layouts[choices.layout_choice]
	local restrictions = layout.restrictions

	local is_space = compatibility.is_space(player.surface.index)
	player_data.gui.section["space_belt"].visible = restrictions.belt_available and is_space
	if not restrictions.belt_available or not is_space then return end

	local values = List() --[[@as List<SettingValueEntry>]]
	local existing_choice_is_valid = false

	local belts = prototypes.get_entity_filtered{{filter="type", type="transport-belt"}}
	for _, belt in pairs(belts) do
		if mpp_util.check_filtered(belt) then goto skip_belt end
		--if not compatibility.is_buildable_in_space(belt.name) then goto skip_belt end
		local belt_struct = mpp_util.belt_struct(belt.name)
		if mpp_util.check_entity_hidden(player_data, "space_belt", belt) then goto skip_belt end
		
		local is_restricted = common.is_belt_restricted(belt_struct, restrictions) or not compatibility.is_buildable_in_space(belt.name)
		if not player_data.entity_filtering_mode and is_restricted then goto skip_belt end
		--if is_space and not string.match(belt.name, "^se%-") then goto skip_belt end

		local belt_speed = belt.belt_speed * 60 * 8
		local specifier = belt_speed % 1 == 0 and ": %.0f " or ": %.1f "

		local tooltip = {
			"", mpp_util.entity_name_with_quality(belt.localised_name, choices.space_belt_quality_choice), "\n",
			{"description.belt-speed"}, specifier:format(belt_speed),
			{"description.belt-items"}, "/s",
		}

		values:push{
			value=belt.name,
			tooltip=tooltip,
			icon=("entity/"..belt.name),
			order=belt.order,
			filterable=true,
			disabled=is_restricted,
			sort={belt_struct.speed},
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
		values:push{
			value="none",
			tooltip={"mpp.choice_none"},
			icon="mpp_no_entity",
			order="",
		}
	end
	
	table.sort(values, function(a, b)
		local a1, a2, b1, b2 = a.sort[1], a.order, b.sort[1], b.order
		return (a1 == b1 and a2 < b2) or a1 < b1
	end)

	local table_root = player_data.gui.tables["space_belt"]
	create_setting_selector(player_data, table_root, "mpp_action", "space_belt", values,
		{shown_quality=player_data.choices.space_belt_quality_choice}
	)
	
	create_quality_selector(
		player_data,
		player_data.gui.tables["space_belt_quality"],
		"mpp_action",
		"space_belt_quality",
		mpp_util.quality_list(),
		{style_func = style_helper_quality, alternate_visibility=true}
	)
end


---@param player_data PlayerData
local function update_logistics_selection(player_data)
	local choices = player_data.choices
	local layout = layouts[choices.layout_choice]
	local restrictions = layout.restrictions
	local values = List() --[[@as List<SettingValueEntry>]]

	player_data.gui.section["logistics"].visible = restrictions.logistics_available
	if not restrictions.logistics_available then return end

	local filter = {
		["passive-provider"]=true,
		["active-provider"]=true,
		["storage"] = true,
	}

	local existing_choice_is_valid = false
	local logistics = prototypes.get_entity_filtered{{filter="type", type="logistic-container"}}
	for _, chest in pairs(logistics) do
		if mpp_util.check_filtered(chest) then goto skip_chest end
		if mpp_util.check_entity_hidden(player_data, "logistics", chest) then goto skip_chest end
		local cbox = chest.collision_box
		local size = math.ceil(cbox.right_bottom.x - cbox.left_top.x)
		if size > 1 then goto skip_chest end
		if not filter[chest.logistic_mode] then goto skip_chest end

		values:push{
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
		values:push{
			value="none",
			tooltip={"mpp.choice_none"},
			icon="mpp_no_entity",
			order="",
		}
	end

	local table_root = player_data.gui.tables["logistics"]
	create_setting_selector(player_data, table_root, "mpp_action", "logistics", values,
		{shown_quality=player_data.choices.logistics_quality_choice}
	)
	
	create_quality_selector(
		player_data,
		player_data.gui.tables["logistics_quality"],
		"mpp_action",
		"logistics_quality",
		mpp_util.quality_list(),
		{style_func = style_helper_quality, alternate_visibility=true}
	)
end

---@param player_data PlayerData
local function update_pole_selection(player_data)
	local choices = player_data.choices
	local layout = layouts[choices.layout_choice]
	local restrictions = layout.restrictions

	player_data.gui.section["pole"].visible = restrictions.pole_available
	if not restrictions.pole_available then return end

	local values = List() --[[@as List<SettingValueEntry>]]

	if layout.restrictions.pole_zero_gap then
		values:push{
			value="zero_gap",
			tooltip={"mpp.choice_none_zero"},
			icon="mpp_no_entity_zero",
			order="",
			no_quality=true,
		}
	end

	values:push{
		value="none",
		tooltip={"mpp.choice_none"},
		icon="mpp_no_entity",
		order="",
		no_quality=true,
	}

	local existing_choice_is_valid = ("none" == choices.pole_choice or (layout.restrictions.pole_zero_gap and "zero_gap" == choices.pole_choice))
	local poles = prototypes.get_entity_filtered{{filter="type", type="electric-pole"}}
	for _, pole_proto in pairs(poles) do
		if mpp_util.check_filtered(pole_proto) then goto skip_pole end
		if mpp_util.check_entity_hidden(player_data, "pole", pole_proto) then goto skip_pole end
		-- TODO: re-add if pole_proto.supply_area_distance < 0.5 then goto skip_pole end
		local pole = mpp_util.pole_struct(pole_proto.name, choices.pole_quality_choice)
		if pole.filtered then goto skip_pole end
		local is_restricted = common.is_pole_restricted(pole, restrictions)

		if not player_data.entity_filtering_mode and is_restricted then goto skip_pole end

		local specifier = (pole.wire % 1 == 0 and ": %.0f ") or (pole.wire * 10 % 1 == 0 and ": %.1f ") or ": %.2f "
		local tooltip = {
			"", mpp_util.entity_name_with_quality(pole_proto.localised_name, choices.pole_quality_choice), "\n",
			"[img=mpp_tooltip_category_size] ", {"description.tile-size"}, (": %ix%i\n"):format(pole.size, pole.size),
			"[img=mpp_tooltip_category_supply_area] ", {"description.supply-area"}, (": %ix%i\n"):format(pole.supply_width, pole.supply_width),
			" [img=tooltip-category-electricity] ", {"description.wire-reach"}, specifier:format(pole.wire),
		}

		values:push{
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
	create_setting_selector(player_data, table_root, "mpp_action", "pole", values,
		{shown_quality=player_data.choices.pole_quality_choice}
	)
	
	create_quality_selector(
		player_data,
		player_data.gui.tables["pole_quality"],
		"mpp_action",
		"pole_quality",
		mpp_util.quality_list(),
		{style_func = style_helper_quality, alternate_visibility=true}
	)
end

---@param player LuaPlayer
local function update_misc_selection(player)
	local player_data = storage.players[player.index]
	local choices = player_data.choices
	local layout = layouts[choices.layout_choice]
	local values = List() --[[@as List<SettingValueEntry>]]

	values:push{
		value="ore_filtering",
		tooltip={"mpp.choice_ore_filtering"},
		icon=("mpp_ore_filtering_disabled"),
		icon_enabled=("mpp_ore_filtering_enabled"),
	}

	values:push{
		value="avoid_water",
		tooltip={"mpp.choice_avoid_water"},
		icon=("fluid/water"),
		icon_enabled=("mpp_water_avoided")
	}

	values:push{
		value="avoid_cliffs",
		tooltip={"mpp.choice_avoid_cliffs"},
		icon=("entity/cliff"),
		icon_enabled=("mpp_cliff_avoided")
	}

	if layout.restrictions.belt_planner_available then
		values:push{
			value="belt_planner",
			tooltip={"mpp.choice_belt_planner"},
			icon=("mpp_belt_planner"),
			icon_enabled=("mpp_belt_planner")
		}
	end
	
	if layout.restrictions.belt_merging_available then
		values:push{
			value="belt_merge",
			icon_enabled=("mpp_merge_belt_enabled"),
			icon=("mpp_merge_belt_disabled"),
			tooltip={"mpp.choice_merge_belts"},
		}
	end

	if layout.restrictions.module_available then
		---@type string|nil
		local existing_choice = choices.module_choice
		if not prototypes.item[existing_choice] then
			existing_choice = nil
			choices.module_choice = "none"
		end
		local existing_quality_choice = choices.module_quality_choice
		if not prototypes.quality[existing_quality_choice] then
			existing_quality_choice = "normal"
			choices.module_quality_choice = existing_quality_choice
		end

		local elem_value
		if existing_choice then
				elem_value = {
				name = existing_choice,
				quality = existing_quality_choice,
			}
		end
		
		values:push{
			action="mpp_prototype",
			value="module",
			tooltip={"", {"gui.module"}, "\n", {"mpp.label_right_click_to_clear"}},
			icon=("mpp_no_module"),
			elem_type="item-with-quality",
			elem_filters={{filter="type", type="module"}},
			elem_value = elem_value,
			type="choose-elem-button",
		}
	end
	
	if layout.restrictions.lamp_available then
		values:push{
			value="lamp",
			tooltip={"mpp.choice_lamp"},
			icon=("mpp_no_lamp"),
			icon_enabled=("entity/small-lamp"),
		}
	end
	
	if layout.restrictions.pipe_available then
		---@type string | nil
		local existing_choice = choices.pipe_choice
		local existing_quality_choice = choices.pipe_quality_choice
		if not prototypes.entity[existing_choice] then
			existing_choice = nil
			choices.pipe_choice = "none"
		end
		if not prototypes.quality[existing_quality_choice] then
			existing_quality_choice = "normal"
			choices.pipe_quality_choice = existing_quality_choice
		end
		
		local elem_value
		if existing_choice then
				elem_value = {
				name = existing_choice,
				quality = existing_quality_choice,
			}
		end

		values:push{
			action="mpp_prototype",
			value="pipe",
			tooltip={"", {"entity-name.pipe"}, "\n", {"mpp.label_right_click_to_clear"}},
			icon=("mpp_no_pipe"),
			elem_type="entity-with-quality",
			elem_filters={{filter="type", type="pipe"}},
			elem_value = elem_value,
			type="choose-elem-button",
		}
	end

	if layout.restrictions.deconstruction_omit_available then
		values:push{
			value="deconstruction",
			tooltip={"mpp.choice_deconstruction"},
			icon=("mpp_deconstruct"),
			icon_enabled=("mpp_omit_deconstruct"),
		}
	end

	if compatibility.is_space(player.surface_index) and layout.restrictions.landfill_omit_available then
		local existing_choice = choices.space_landfill_choice
		if not prototypes.tile[existing_choice] then
			existing_choice = "se-space-platform-scaffold"
			choices.space_landfill_choice = existing_choice
		end

		values:push{
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
		values:push{
			value="landfill",
			tooltip={"mpp.choice_landfill"},
			icon=("item/landfill"),
			icon_enabled=("mpp_omit_landfill")
		}
	end

	if layout.restrictions.coverage_tuning then
		values:push{
			value="coverage",
			tooltip={"mpp.choice_coverage"},
			icon=("mpp_miner_coverage_disabled"),
			icon_enabled=("mpp_miner_coverage"),
		}
	end

	if layout.restrictions.start_alignment_tuning then
		values:push{
			value="start",
			tooltip={"mpp.choice_start"},
			icon=("mpp_align_start"),
		}
	end

	if layout.restrictions.placement_info_available then
		values:push{
			value="print_placement_info",
			tooltip={"mpp.choice_print_placement_info"},
			icon=("mpp_print_placement_info_disabled"),
			icon_enabled=("mpp_print_placement_info_enabled"),
		}
	end

	if layout.restrictions.lane_filling_info_available then
		values:push{
			value="display_lane_filling",
			tooltip={"mpp.choice_display_lane_filling"},
			icon=("mpp_display_lane_filling_disabled"),
			icon_enabled=("mpp_display_lane_filling_enabled"),
		}
	end

	if player_data.advanced and layout.restrictions.pipe_available then
		values:push{
			value="force_pipe_placement",
			tooltip={"mpp.choice_force_pipe_placement"},
			icon=("mpp_force_pipe_disabled"),
			icon_enabled=("mpp_force_pipe_enabled"),
		}
	end
	
	if script.feature_flags.space_travel and layout.restrictions.lane_filling_info_available then
		values:push{
			value="use_stack_capacity_multiplier",
			tooltip={"mpp.choice_use_stack_capacity_multiplier"},
			icon=("mpp_stack_capacity_disabled"),
			icon_enabled=("mpp_stack_capacity_enabled"),
		}
	end

	if player_data.advanced and false then
		values:push{
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
			value="draw_raw_drill_struct",
			tooltip="Draw drill struct overlay",
			icon=("entity/electric-mining-drill"),
		},
		{
			value="draw_pole_layout_simple",
			tooltip="Draw power pole layout",
			icon=("entity/medium-electric-pole"),
		},
		{
			value="draw_pole_layout_interleaved",
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
			value="draw_pole_joiner",
			tooltip="Draw power pole joiner",
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
		{
			value="draw_inserter_rotation_preview",
			tooltip="Draw inserter rotation preview",
			icon=("item/inserter"),
		},
		{
			value="draw_cliff_collisions",
			tooltip="Draw cliff collisions (area select)",
			icon=("entity/cliff"),
		},
		{
			value="draw_consumed_resources",
			tooltip="Draw consumed resource tiles",
			icon=("entity/copper-ore"),
		},
		{
			value="draw_belt_specification",
			tooltip="Draw belt specification",
			icon=("item/transport-belt"),
		}
	}

	local debugging_section = player_data.gui.section["debugging"]
	debugging_section.visible = #values > 0

	local table_root = player_data.gui.tables["debugging"]
	create_setting_selector(player_data, table_root, "mpp_action", "debugging", values)
end

---@param player_data PlayerData
local function update_quality_sections(player_data)
	local shown = player_data.quality_pickers
	local advanced = player_data.advanced
	local quality_enabled = script.feature_flags.quality
	player_data.gui.tables["miner_quality"].visible = shown and quality_enabled
	player_data.gui.tables["belt_quality"].visible = shown and quality_enabled and advanced
	player_data.gui.tables["space_belt_quality"].visible = shown and quality_enabled and advanced
	player_data.gui.tables["pole_quality"].visible = shown and quality_enabled
	player_data.gui.tables["logistics_quality"].visible = shown and quality_enabled and advanced
end
function gui.update_quality_sections(player_data)
	if table_size(player_data.gui.tables) == 0 then return end
	local ql = mpp_util.quality_list()
	local tables = player_data.gui.tables
	for _, table in pairs(tables) do
		if not table.valid then return end
	end
	
	local opts = {style_func = style_helper_quality, alternate_visibility=true}
	create_quality_selector(
		player_data, tables["miner_quality"], "mpp_action", "miner_quality", ql, opts
	)
	create_quality_selector(
		player_data, tables["belt_quality"], "mpp_action", "belt_quality", ql, opts
	)
	create_quality_selector(
		player_data, tables["space_belt_quality"], "mpp_action", "space_belt_quality", ql, opts
	)
	create_quality_selector(
		player_data, tables["logistics_quality"], "mpp_action", "logistics_quality", ql, opts
	)
	create_quality_selector(
		player_data, tables["pole_quality"], "mpp_action", "pole_quality", ql, opts
	)
	update_quality_sections(player_data)
end

---@param player LuaPlayer
local function update_selections(player)
	---@type PlayerData
	local player_data = storage.players[player.index]
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
	update_quality_sections(player_data)
end


---@param player LuaPlayer
function gui.show_interface(player)
	---@type LuaGuiElement
	local frame = player.gui.screen["mpp_settings_frame"]
	local player_data = storage.players[player.index]
	player_data.blueprint_add_mode = false
	if frame then
		frame.visible = true
	else
		gui.create_interface(player)
	end
	update_selections(player)
	player_data.gui.quality_toggle.visible = script.feature_flags.quality
end

---@param player LuaPlayer
local function abort_blueprint_mode(player)
	local player_data = storage.players[player.index]
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
	local player_data = storage.players[player.index]
	player_data.blueprint_add_mode = false
	if frame then
		frame.visible = false
	end
end

-- TODO: refactor this into handlers

---@param event EventDataGuiClick
local function on_gui_click(event)
	local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
	---@type PlayerData
	local player_data = storage.players[event.player_index]
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
	elseif evt_ele_tags["mpp_quality_pickers"] then
		abort_blueprint_mode(player)
		
		local value = not player_data.quality_pickers
		player_data.quality_pickers = value
		
		update_quality_sections(player_data)
		player_data.gui.quality_toggle.style = style_helper_advanced_toggle(value)
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
		local choice = action.."_choice"
		local last_value = player_data.choices[choice]
		local entity = action..":"..value

		if choice == "miner_choice" or choice == "blueprint_choice" then
			algorithm.clear_selection(player_data)
		end

		if player_data.gui.selections[action][last_value] then
			player_data.gui.selections[action][last_value].style = style_helper_selection(false)
		end

		if event.shift and event.button == defines.mouse_button_type.right and evt_ele_tags.mpp_filterable then

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
			elseif value == last_value then
				player.print({"mpp.msg_print_cant_hide_current_choice"})
			elseif is_filtered then
				player_data.filtered_entities[entity] = false
			elseif visible_values > 1 then
				player_data.filtered_entities[entity] = "user_hidden"
			else
				player.print({"mpp.msg_print_cant_hide_last_choice"})
			end

			update_selections(player)
			return
		end
		
		player_data.filtered_entities[entity] = false
		event.element.style = style_helper_selection(true)
		player_data.choices[choice] = value
		update_selections(player)
	elseif evt_ele_tags["mpp_toggle"] then
		abort_blueprint_mode(player)
		
		local action = evt_ele_tags["mpp_toggle"]
		local value = evt_ele_tags["value"]
		local last_value = player_data.choices[value.."_choice"]

		if value == "belt_planner" and event.button == defines.mouse_button_type.right then
			local last_state = player_data.last_state
			if not last_state then
				player.print({"mpp.msg_belt_planner_err_create_planner_no_previous_state"})
				return
			end
			belt_planner.clear_belt_planner_stack(player_data)
			common.give_belt_blueprint(last_state)
			return
		end
		
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
	local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
	local element = event.element
	local evt_ele_tags = element.tags
	if evt_ele_tags["mpp_drop_down"] == nil then return end
	local action = evt_ele_tags["mpp_drop_down"]
	local value_map = evt_ele_tags["mpp_value_map"]
	
	abort_blueprint_mode(player)
	---@type PlayerData
	local player_data = storage.players[event.player_index]

	local value
	if value_map == "layout" then
		value = layouts[element.selected_index].name
	elseif value_map == "quality" then
		value = mpp_util.quality_list()[element.selected_index].value
	else
		return
	end
	player_data.choices[action.."_choice"] = value

	if action == "layout_choice" then
		algorithm.clear_selection(player_data)
	end
	update_selections(player)
end
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)

---@param event EventData.on_gui_elem_changed
local function on_gui_elem_changed(event)
	local element = event.element
	local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
	---@type PlayerData
	local player_data = storage.players[event.player_index]
	local evt_ele_tags = element.tags
	if evt_ele_tags["mpp_prototype"] then
		local action = evt_ele_tags.value
		local old_choice = player_data.choices[action.."_choice"]
		local old_quality_choice = player_data.choices[action.."_choice"]
		local elem_value = element.elem_value
		if type(elem_value) == "string" then
			element.children[1].visible = false
			player_data.choices[action.."_choice"] = elem_value or "none"
		elseif elem_value then
			local choice = elem_value.name
			local quality_choice = element.elem_value.quality
			element.children[1].visible = false
			player_data.choices[action.."_choice"] = choice or "none"
			player_data.choices[action.."_quality_choice"] = quality_choice or "normal"
		else
			element.children[1].visible = true
			player_data.choices[action.."_choice"] = "none"
			player_data.choices[action.."_quality_choice"] = "normal"
		end
	end
end

script.on_event(defines.events.on_gui_elem_changed, on_gui_elem_changed)

return gui
