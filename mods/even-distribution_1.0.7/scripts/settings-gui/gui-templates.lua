-- GUI templates for the Even Distribution settings

local this = {templates = {}}
local util = scripts.util
local config = require("config")
local gui = scripts["gui-tools"]
local controller

local helpers = scripts.helpers
local _ = helpers.on


this.templates.settingsButton = {
	type = "sprite-button",
	name = "ed_expand_settings",
	tooltip = {"settings-gui.open-settings"},
	sprite = "ed_logo",
	hovered_sprite = "ed_logo",
	clicked_sprite = "ed_logo",
	style = {
		parent = "tool_button_blue",
		width = 40,
		height = 40,
		padding = 5,
	},
	root = function(player) return player.gui.relative end,
	anchor = {
		gui      = defines.relative_gui_type.controller_gui,
		position = defines.relative_gui_position.right,
	},
	onChanged = function(self, event)
		local player = _(self.gui.player)
		controller.destroyButton(player)
		controller.buildGUI(player)
	end,
}


local function updateLimiter(flow, profiles, action) -- switch to next type
	local player  = _(flow.gui.player)

	local oldType = player:setting(profiles.typeSetting)
	local type    = action == "type" and profiles[oldType].next or oldType
	local profile = profiles[type]
	local name    = profiles.name
	local enabled = true
	
	local value = 0
	if action == "slider" then
		value = flow[name.."_slider"].slider_value
	elseif action == "text" then
		value = tonumber(flow[name.."_textfield"].text)
	else
		value = player:setting(profiles.valueSetting)
	end

	if profiles.enableSetting then
		enabled = player:setting(profiles.enableSetting)
		if action == "enable" then enabled = flow[name.."_checkbox"].state end
	end

	-- clamp value to bounds
	local decimal = (profile.step < 1)
	if not decimal then value = math.floor(value) end
	-- if value > profile.max then value = profile.max end
	if value < profile.min then value = profile.min end
	
	-- update GUI
	flow[name.."_textfield"].allow_decimal = decimal
	flow[name.."_slider"].set_slider_minimum_maximum(profile.min, profile.max)
	flow[name.."_slider"].set_slider_value_step(profile.step)
	
	flow[name.."_slider"].slider_value = 0
	flow[name.."_slider"].slider_value = math.max(math.min(value, profile.max), profile.min)
	flow[name.."_type"].caption        = {profiles.typeLocale.."."..type}
	if action ~= "text" then 
		flow[name.."_textfield"].text  = tostring(value) 
	end
	
	if profiles.enableSetting then
		flow[name.."_checkbox"].state    = enabled
		flow[name.."_slider"].enabled    = enabled
		flow[name.."_textfield"].enabled = enabled
		flow[name.."_type"].enabled      = enabled
	end

	flow.tooltip    = {profiles.tooltipLocale.."."..(enabled and type or "disabled"), value, math.floor(value*100)}
	for _,child in pairs(flow.children) do
		child.tooltip = flow.tooltip
	end

	-- save settings
	if profiles.enableSetting then
		player:changeSetting(profiles.enableSetting, enabled)
	end
	player:changeSetting(profiles.typeSetting, type)
	player:changeSetting(profiles.valueSetting, value)
end

local function updateIgnoredEntities(self)
	local player = _(self.gui.player)
	self.clear()
		
	for name in pairs(player:setting("ignoredEntities")) do
		gui.create(player, this.templates.ignoredEntityChooser, { name = name }, self)
	end
	gui.create(player, this.templates.ignoredEntityChooser, {}, self)
end

this.templates.settingsWindow = {
	type = "frame",
	name = "ed_settings_window",
	direction = "vertical",
	--caption = "Even Distribution",
	root = function(player) return player.gui.relative end,
	anchor = {
		gui      = defines.relative_gui_type.controller_gui,
		position = defines.relative_gui_position.right,
	},
	children = {
		{
			type = "flow",
			name = "frame_header",
			direction = "horizontal",
			style = {
				vertically_stretchable = false,
			},
			children = 
			{
				{
					type = "label",
					name = "frame_caption",
					style = "frame_title",
					caption = "Even Distribution",
				},
				{
					type = "empty-widget",
					name = "filler",
					style = {
						parent = "draggable_space_header",
						height = 24,
						natural_height = 24,
						right_margin = 8,
						horizontally_stretchable = true,
						vertically_stretchable = true,
					}
				},
				-- {
				-- 	type = "sprite-button",
				-- 	name = "save",
				-- 	visible = false,
				-- 	sprite = "utility/check_mark",
				-- 	style = {
				-- 		parent = "green_button",
				-- 		padding = 0,
				-- 		width = 24,
				-- 		height = 24,
				-- 	},
				-- 	onChanged = function(self, event)
				-- 		local player = _(self.gui.player)
				-- 		controller.destroyGUI(player)
				-- 	end,
				-- },
				{
					type = "sprite-button",
					name = "ed_close",
					sprite = "utility/close_white",
					hovered_sprite = "utility/close_black",
					clicked_sprite = "utility/close_black",
					style = "frame_action_button",
					onChanged = function(self, event)
						local player = _(self.gui.player)
						controller.destroyGUI(player)
						controller.buildButton(player)
					end,
				},
			}
		},
		{
			type = "scroll-pane",
			vertical_scroll_policy = "auto-and-reserve-space",
			style = {
				parent = "control_settings_scroll_pane", --"scroll_pane_with_dark_background_under_subheader",
				minimal_width = 450, --530, -- 350,
				-- minimal_height = 344, -- Inventory GUI height
				-- maximal_height = 600,
				vertically_stretchable = true,
				vertically_squashable = true,
			},
			children = {
				{
					type = "frame",
					direction = "vertical",
					style = {
						parent = "ed_settings_inner_frame",
						top_margin = 3,
						bottom_margin = 3,
					},
					children = 
					{
						{
							type = "flow",
							name = "frame_header",
							direction = "horizontal",
							children = 
							{
								{
									type = "label",
									name = "frame_caption",
									style = "heading_3_label_yellow",
									caption = {"settings-gui.general"},
								},
							}
						},
						{
							type = "flow",
							name = "frame_content",
							direction = "vertical",
							children = 
							{
								{
									type = "flow",
									direction = "vertical",
									style = {
										horizontal_align = "center",
										top_margin = 16, --4,
										bottom_margin = 16, --4
									},
									children = 
									{
										{
											type = "switch",
											name = "mode_switch",
											left_label_caption  = {"", "[font=default-large-semibold]", {"settings-gui.drag-evenly-distribute"}, "[/font]"},
											right_label_caption = {"", "[font=default-large-semibold]", {"settings-gui.drag-balance-inventories"}, "[/font]"},
											style = {
												horizontally_stretchable = true,
											},
											onCreated = function(self)
												if _(self.gui.player):setting("distributionMode") == "distribute" then
													self.switch_state = "left"
												else
													self.switch_state = "right"
												end
											end,
											onChanged = function(self, event)
												if self.switch_state == "left" then
													_(self.gui.player):changeSetting("distributionMode", "distribute")
												else
													_(self.gui.player):changeSetting("distributionMode", "balance")
												end
											end,
										},
									}
								},
								{
									type = "flow",
									direction = "horizontal",
									style = {
										vertical_align = "center",
									},
									onCreated = function(self)
										updateLimiter(self, config.fuelLimitProfiles)
									end,
									children = 
									{
										{
											type = "label",
											caption = {"", {"settings-gui.fuel-limit"}, " [img=info]"},
										},
										{
											type = "empty-widget",
											style = "ed_stretch",
										},
										{
											type = "slider",
											name = "fuel_drag_limit_slider",
											discrete_slider = false,
											discrete_values = true,
											onChanged = function(self, event)
												if type(self.slider_value) == "number" then
													updateLimiter(self.parent, config.fuelLimitProfiles, "slider")
												end
											end,
										},
										{
											type = "textfield",
											name = "fuel_drag_limit_textfield",
											style = {
												parent = "slider_value_textfield",
												width = 60,
											},
											numeric = true,
											allow_negative = false,
											lose_focus_on_confirm = true,
											onChanged = function(self, event)
												if type(tonumber(self.text)) == "number" then
													updateLimiter(self.parent, config.fuelLimitProfiles, "text")
												end
											end,
										},
										{
											type = "button",
											name = "fuel_drag_limit_type",
											style = {
												padding = 0,
												width = 56, -- 38,
											},
											-- caption = "Stacks",
											onChanged = function(self, event)
												updateLimiter(self.parent, config.fuelLimitProfiles, "type")
											end,
										},
									}
								},
								{
									type = "flow",
									direction = "horizontal",
									style = {
										vertical_align = "center",
									},
									onCreated = function(self)
										updateLimiter(self, config.ammoLimitProfiles)
									end,
									children = 
									{
										{
											type = "label",
											caption = {"", {"settings-gui.ammo-limit"}, " [img=info]"},
										},
										{
											type = "empty-widget",
											style = "ed_stretch",
										},
										{
											type = "slider",
											name = "ammo_drag_limit_slider",
											discrete_slider = false,
											discrete_values = true,
											onChanged = function(self, event)
												if type(self.slider_value) == "number" then
													updateLimiter(self.parent, config.ammoLimitProfiles, "slider")
												end
											end,
										},
										{
											type = "textfield",
											name = "ammo_drag_limit_textfield",
											style = {
												parent = "slider_value_textfield",
												width = 60,
											},
											numeric = true,
											allow_negative = false,
											lose_focus_on_confirm = true,
											onChanged = function(self, event)
												if type(tonumber(self.text)) == "number" then
													updateLimiter(self.parent, config.ammoLimitProfiles, "text")
												end
											end,
										},
										{
											type = "button",
											name = "ammo_drag_limit_type",
											style = {
												padding = 0,
												width = 56, -- 38,
											},
											onChanged = function(self, event)
												updateLimiter(self.parent, config.ammoLimitProfiles, "type")
											end,
										},
									}
								},
							}
						},
					}
				},
				{
					type = "frame",
					direction = "vertical",
					style = {
						parent = "ed_settings_inner_frame",
						bottom_margin = 3,
					},
					children = 
					{
						{
							type = "flow",
							name = "frame_header",
							direction = "horizontal",
							children = 
							{
								{
									type = "label",
									name = "frame_caption",
									style = "heading_3_label_yellow",
									caption = {"settings-gui.drag-title"},
								},
								{
									type = "empty-widget",
									style = "ed_stretch",
								},
								{
									type = "checkbox",
									name = "enable_drag_distribute",
									caption = {"settings-gui.enable"},
									state = true,
									onCreated = function(self)
										local player = _(self.gui.player)
										self.state = player:setting("enableDragDistribute")
										self.parent.frame_caption.enabled = self.state
										self.visible = not settings.global["disable-distribute"].value
									end,
									onChanged = function(self, event)
										self.parent.parent.frame_content.visible = self.state
										self.parent.frame_caption.enabled = self.state

										local player = _(self.gui.player)
										player:changeSetting("enableDragDistribute", self.state)
									end,
								},
								{
									type = "label",
									style = "invalid_label",
									caption = {"settings-gui.globally-disabled"},
									onCreated = function(self)
										self.visible = settings.global["disable-distribute"].value
									end,
								},
							}
						},
						{
							type = "flow",
							name = "frame_content",
							direction = "vertical",
							onCreated = function(self)
								self.visible = _(self.gui.player):setting("enableDragDistribute")
							end,
							children = 
							{
								{
									type = "flow",
									direction = "horizontal",
									style = {
										vertical_align = "center",
										-- top_margin = 16, --4,
									},
									children = 
									{
										{
											type = "label",
											-- style = "heading_3_label_yellow",
											caption = {"settings-gui.distribute-from"},
										},
										{
											type = "empty-widget",
											style = "ed_stretch",
										},
										{
											type = "sprite-button",
											name = "button_take_from_hand",
											tooltip = {"settings-gui.hand-tooltip"},
											sprite = "utility/hand_black",
											style = "ed_switch_button_small_selected",
											onChanged = function(self, event)
												local flow = self.parent
												flow.button_take_from_inventory.style = "ed_switch_button_small"
												flow.button_take_from_car.style       = "ed_switch_button_small"
												
												local player = _(flow.gui.player)
												player:changeSetting("takeFromInventory", false)
												player:changeSetting("takeFromCar", false)
											end,
										},
										{
											type = "sprite-button",
											name = "button_take_from_inventory",
											tooltip = {"settings-gui.inventory-tooltip"},
											sprite = "entity/character",
											style = "ed_switch_button_small",
											onCreated = function(self)
												local player = _(self.gui.player)
												self.style = player:setting("takeFromInventory") and "ed_switch_button_small_selected" or "ed_switch_button_small"
											end,
											onChanged = function(self, event)
												local flow = self.parent
												local nowActive = self.style.name == "ed_switch_button_small"
												if flow.button_take_from_car.style.name == "ed_switch_button_small_selected" then nowActive = true end

												flow.button_take_from_inventory.style = nowActive and "ed_switch_button_small_selected" or "ed_switch_button_small"
												flow.button_take_from_car.style       = "ed_switch_button_small"
												
												local player = _(flow.gui.player)
												player:changeSetting("takeFromInventory", nowActive)
												player:changeSetting("takeFromCar", false)
											end,
										},
										{
											type = "sprite-button",
											name = "button_take_from_car",
											tooltip = {"settings-gui.car-tooltip"},
											sprite = "entity/car",
											style = "ed_switch_button_small",
											onCreated = function(self)
												local player = _(self.gui.player)
												self.style = player:setting("takeFromCar") and "ed_switch_button_small_selected" or "ed_switch_button_small"
											end,
											onChanged = function(self, event)
												local flow = self.parent
												local nowActive = self.style.name == "ed_switch_button_small"
												
												flow.button_take_from_inventory.style = "ed_switch_button_small_selected"
												flow.button_take_from_car.style       = nowActive and "ed_switch_button_small_selected" or "ed_switch_button_small"
												
												local player = _(flow.gui.player)
												player:changeSetting("takeFromInventory", true)
												player:changeSetting("takeFromCar", nowActive)
											end,
										},
									}
								},
								{
									type = "checkbox",
									name = "drag_fuel_limit",
									caption = {"settings-gui.use-fuel-limit"},
									state = true,
									onCreated = function(self)
										local player = _(self.gui.player)
										self.state = player:setting("dragUseFuelLimit")
									end,
									onChanged = function(self, event)
										local player = _(self.gui.player)
										player:changeSetting("dragUseFuelLimit", self.state)
									end,
								},
								{
									type = "checkbox",
									name = "drag_ammo_limit",
									caption = {"settings-gui.use-ammo-limit"},
									state = true,
									onCreated = function(self)
										local player = _(self.gui.player)
										self.state = player:setting("dragUseAmmoLimit")
									end,
									onChanged = function(self, event)
										local player = _(self.gui.player)
										player:changeSetting("dragUseAmmoLimit", self.state)
									end,
								},
								{
									type = "checkbox",
									name = "replace_items",
									caption = {"settings-gui.replace-items"},
									state = true,
									onCreated = function(self)
										local player = _(self.gui.player)
										self.state = player:setting("replaceItems")
									end,
									onChanged = function(self, event)
										local player = _(self.gui.player)
										player:changeSetting("replaceItems", self.state)
									end,
								},
							}
						},
					}
				},
				{
					type = "frame",
					direction = "vertical",
					style = {
						parent = "ed_settings_inner_frame",
						bottom_margin = 3,
					},
					children = 
					{
						{
							type = "flow",
							name = "frame_header",
							direction = "horizontal",
							children = 
							{
								{
									type = "label",
									name = "frame_caption",
									style = "heading_3_label_yellow",
									caption = {"settings-gui.inventory-cleanup-title"},
								},
								{
									type = "empty-widget",
									style = "ed_stretch",
								},
								{
									type = "checkbox",
									name = "enable_inventory_cleanup_hotkey",
									caption = {"settings-gui.enable"},
									state = true,
									onCreated = function(self)
										local player = _(self.gui.player)
										self.state = player:setting("enableInventoryCleanupHotkey")
										self.parent.frame_caption.enabled = self.state
										self.visible = not settings.global["disable-inventory-cleanup"].value
									end,
									onChanged = function(self, event)
										self.parent.parent.frame_content.visible = self.state
										self.parent.frame_caption.enabled = self.state

										local player = _(self.gui.player)
										player:changeSetting("enableInventoryCleanupHotkey", self.state)
									end,
								},
								{
									type = "label",
									style = "invalid_label",
									caption = {"settings-gui.globally-disabled"},
									onCreated = function(self)
										self.visible = settings.global["disable-inventory-cleanup"].value
									end,
								},
							}
						},
						{
							type = "flow",
							name = "frame_content",
							direction = "vertical",
							onCreated = function(self)
								self.visible = _(self.gui.player):setting("enableInventoryCleanupHotkey")
							end,
							children = 
							{
								{
									type = "label",
									caption = {"", "[color=gray]", {"settings-gui.inventory-cleanup-description"}, "[/color]"},
									tooltip = {"settings-gui.inventory-cleanup-configure-description"},
								},
								{
									type = "label",
									caption = {"", {"settings-gui.inventory-cleanup-configure"}, " [img=info]"},
									tooltip = {"settings-gui.inventory-cleanup-configure-description"},
									style = {
										-- top_margin = -6,
										bottom_margin = 15,
									}
								},
								{
									type = "checkbox",
									name = "checkbox_request_overflow",
									caption = {"settings-gui.cleanup-request-overflow"},
									state = true,
									onCreated = function(self)
										local player = _(self.gui.player)
										self.state = player:setting("cleanupRequestOverflow")
									end,
									onChanged = function(self, event)
										local player = _(self.gui.player)
										player:changeSetting("cleanupRequestOverflow", self.state)
									end,
								},
								{
									type = "checkbox",
									name = "cleanup_fuel_limit",
									caption = {"settings-gui.use-fuel-limit"},
									state = true,
									onCreated = function(self)
										local player = _(self.gui.player)
										self.state = player:setting("cleanupUseFuelLimit")
									end,
									onChanged = function(self, event)
										local player = _(self.gui.player)
										player:changeSetting("cleanupUseFuelLimit", self.state)
									end,
								},
								{
									type = "checkbox",
									name = "cleanup_ammo_limit",
									caption = {"settings-gui.use-ammo-limit"},
									state = true,
									onCreated = function(self)
										local player = _(self.gui.player)
										self.state = player:setting("cleanupUseAmmoLimit")
									end,
									onChanged = function(self, event)
										local player = _(self.gui.player)
										player:changeSetting("cleanupUseAmmoLimit", self.state)
									end,
								},
								{
									type = "checkbox",
									name = "drop_trash_to_chests",
									caption = {"", {"settings-gui.drop-trash-to-chests"}, " [img=info]"},
									tooltip = {"settings-gui.drop-trash-to-chests-description"},
									state = true,
									onCreated = function(self)
										local player = _(self.gui.player)
										self.state = player:setting("dropTrashToChests")
									end,
									onChanged = function(self, event)
										local player = _(self.gui.player)
										player:changeSetting("dropTrashToChests", self.state)
									end,
								},
								{
									type = "checkbox",
									name = "drop_trash_to_output",
									caption = {"settings-gui.drop-trash-to-output"},
									state = true,
									onCreated = function(self)
										local player = _(self.gui.player)
										self.state = player:setting("dropTrashToOutput")
									end,
									onChanged = function(self, event)
										local player = _(self.gui.player)
										player:changeSetting("dropTrashToOutput", self.state)
									end,
								},
							}
						},
					}
				},
				{
					type = "frame",
					direction = "vertical",
					style = {
						parent = "ed_settings_inner_frame",
						bottom_margin = 3,
					},
					children = 
					{
						{
							type = "flow",
							name = "frame_header",
							direction = "horizontal",
							children = 
							{
								{
									type = "label",
									name = "frame_caption",
									style = "heading_3_label_yellow",
									caption = {"settings-gui.advanced"},
								},
								{
									type = "empty-widget",
									style = "ed_stretch",
								},
								{
									type = "sprite-button",
									name = "expand_advanced",
									sprite = "utility/expand",
									hovered_sprite = "utility/expand_dark",
									clicked_sprite = "utility/expand_dark",
									style = "frame_action_button",
									onChanged = function(self, event)
										if self.sprite == "utility/expand" then
											self.parent.parent.frame_content.visible = true
											self.sprite = "utility/collapse"
											self.hovered_sprite = "utility/collapse_dark"
											self.clicked_sprite = "utility/collapse_dark"
										else
											self.parent.parent.frame_content.visible = false
											self.sprite = "utility/expand"
											self.hovered_sprite = "utility/expand_dark"
											self.clicked_sprite = "utility/expand_dark"
										end
									end,
								},
							}
						},
						{
							type = "flow",
							name = "frame_content",
							direction = "vertical",
							visible = false,
							-- onCreated = function(self)
							-- 	self.visible = _(self.gui.player):setting("enableInventoryCleanupHotkey")
							-- end,
							children = 
							{
								{
									type = "flow",
									direction = "horizontal",
									style = {
										vertical_align = "center",
									},
									children = 
									{
										{
											type = "label",
											caption = {"", {"settings-gui.distribution-delay"}, " [img=info]"},
											tooltip = {"settings-gui.distribution-delay-description"},
										},
										{
											type = "empty-widget",
											style = "ed_stretch",
										},
										{
											type = "slider",
											name = "delay_slider",
											discrete_slider = false,
											discrete_values = true,
											minimum_value = 0,
											maximum_value = 5,
											value_step = 0.1,
											onCreated = function(self)
												local player = _(self.gui.player)
												self.slider_value = player:setting("distributionDelay")
											end,
											onChanged = function(self, event)
												local player = _(self.gui.player)
												local value = self.slider_value

												if type(value) == "number" then
													-- clamp value to bounds
													-- if value > 5 then value = 5 end
													if value < 0 then value = 0 end

													self.slider_value = value
													self.parent.delay_textfield.text = tostring(value)

													player:changeSetting("distributionDelay", value)
												end
											end,
										},
										{
											type = "textfield",
											name = "delay_textfield",
											style = {
												parent = "slider_value_textfield",
												width = 60,
											},
											numeric = true,
											allow_decimal = true,
											allow_negative = false,
											lose_focus_on_confirm = true,
											onCreated = function(self)
												local player = _(self.gui.player)
												self.text = tostring(player:setting("distributionDelay"))
											end,
											onChanged = function(self, event)
												local player = _(self.gui.player)
												local value = tonumber(self.text)

												if type(value) == "number" then
													-- clamp value to bounds
													-- if value > 5 then value = 5 end
													if value < 0 then value = 0 end

													self.text = tostring(value)
													self.parent.delay_slider.slider_value = value

													player:changeSetting("distributionDelay", value)
												end
											end,
										},
										{
											type = "button",
											name = "delay_type",
											enabled = false,
											caption = "s",
											style = {
												padding = 0,
												width = 56, -- 38,
											},
										},
									},
								},
								{
									type = "flow",
									direction = "horizontal",
									style = {
										vertical_align = "center",
									},
									children = 
									{
										{
											type = "label",
											caption = {"", {"settings-gui.max-inventory-cleanup-drop-range"}, " [img=info]"},
											tooltip = {"settings-gui.max-inventory-cleanup-drop-range-description"},
										},
										{
											type = "empty-widget",
											style = "ed_stretch",
										},
										{
											type = "slider",
											name = "range_slider",
											discrete_slider = false,
											discrete_values = true,
											minimum_value = 0,
											maximum_value = 100,
											value_step = 1,
											onCreated = function(self)
												local player = _(self.gui.player)
												self.set_slider_minimum_maximum(0, math.min(100, settings.global["global-max-inventory-cleanup-range"].value))
												self.slider_value = player:setting("cleanupDropRange")
											end,
											onChanged = function(self, event)
												local player = _(self.gui.player)
												local value = self.slider_value
												local max = settings.global["global-max-inventory-cleanup-range"].value
												self.set_slider_minimum_maximum(0, math.min(100, settings.global["global-max-inventory-cleanup-range"].value))
												
												if type(value) == "number" then
													-- clamp value to bounds
													value = math.floor(value)
													if value > max then value = max end
													if value < 0 then value = 0 end

													self.slider_value = value
													self.parent.range_textfield.text = tostring(value)

													player:changeSetting("cleanupDropRange", value)
												end
											end,
										},
										{
											type = "textfield",
											name = "range_textfield",
											style = {
												parent = "slider_value_textfield",
												width = 60,
											},
											numeric = true,
											allow_decimal = false,
											allow_negative = false,
											lose_focus_on_confirm = true,
											onCreated = function(self)
												local player = _(self.gui.player)
												self.text = tostring(player:setting("cleanupDropRange"))
											end,
											onChanged = function(self, event)
												local player = _(self.gui.player)
												local value = tonumber(self.text)
												local max = settings.global["global-max-inventory-cleanup-range"].value
												
												if type(value) == "number" then
													-- clamp value to bounds
													value = math.floor(value)
													if value > max then value = max end
													if value < 0 then value = 0 end

													self.text = tostring(value)
													self.parent.range_slider.slider_value = value

													player:changeSetting("cleanupDropRange", value)
												end
											end,
										},
										{
											type = "button",
											name = "range_type",
											enabled = false,
											caption = "tiles",
											style = {
												padding = 0,
												width = 56, -- 38,
											},
										},
									},
								},
								{
									type = "flow",
									direction = "horizontal",
									children = 
									{
										{
											type = "label",
											caption = {"settings-gui.ignored-entities"},
											style = {
												top_margin = 10,
											},
										},
										{
											type = "empty-widget",
											style = "ed_stretch",
										},
										{
											type = "table",
											column_count = 6,
											draw_vertical_lines = false,
											draw_horizontal_lines = false,
											draw_horizontal_line_after_headers = false,
											vertical_centering = false,
											onCreated = updateIgnoredEntities,
										},
									},
								},
							}
						},
					}
				},
			}
		},
	}
}

this.templates.ignoredEntityChooser = {
	type = "choose-elem-button",
	name = "ignored_entity_chooser",
	unique = false,
	elem_type = "entity",
	onCreated = function(self, data)
		self.elem_value = data.name
		self.elem_filters = {{ filter = "name", name = _(global.allowedEntities):keys():toPlain() }}
	end,
	onChanged = function(self, event)
		local parent = self.parent
		local player = _(parent.gui.player)
		local ignoredEntities = {}

		for __,child in pairs(parent.children) do
			local value = child.elem_value
			if value then ignoredEntities[value] = true end
		end

		player:changeSetting("ignoredEntities", ignoredEntities)
		updateIgnoredEntities(parent)
	end,
}

return {this, function(_controller) controller = _controller end}