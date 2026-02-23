---@class KuxGuiLib.ElementSelectorView.designer : KuxGuiLib.Designer
---@field num_results LuaGuiElement
---@field elements_scroll_pane LuaGuiElement
local designer = {}
-----------------------------------------------------------------------------------------------------------------------
local GuiBuilder = KuxGuiLib.require.GuiBuilder
local ElementUtils = KuxCoreLib.require.ElementUtils
-----------------------------------------------------------------------------------------------------------------------
local eb = GuiBuilder.ElementBuilder
local createView, frame, flow, button, label, checkbox, dropdown, spritebutton, emptywidget,scrollpane, choose_elem_button, radiobutton, textfield, table = eb.createView, eb.frame, eb.flow,eb.button, eb.label, eb.checkbox, eb.dropdown, eb.spritebutton, eb.emptywidget, eb.scrollpane, eb.chooseelembutton, eb.radiobutton, eb.textfield, eb.table
local this = {} ---@class ElementSelectorView.designer.private
local styles = {} ---@class ElementSelectorView.designer.styles
local loc = require("__Kux-GuiLib__/lib/ElementSelectorView-localization")
local timer = {}
---
---@param plx KuxGuiLib.PlayerContext
function designer.open(plx, container)
	local data = plx.ElementSelectorView
	assert(#data.elements.idx_row_index_group_name>0, "data.elements.idx_row_index_group_name must not be empty")
	assert(data.elements.rows~=nil, "plx.ElementSelectorView.elements.rows must not be nil")

	container.clear()
	--TODO: cleanup gui.elements

	data.group_name = data.group_name or data.elements.idx_row_index_group_name[1]
	data.filter.show_hidden = data.filter.show_hidden or false
	data.filter.show_disabled = data.filter.show_disabled or false

	local root = createView {
		container =	container,
		mod_name = script.mod_name,
		view_name = "ElementSelectorView",
		creator_name =  "Kux-GuiLib",
		parent_view_name = "MainView",
		localization_section = "Kux-GuiLib-ElementSelectorView", locale = plx.player.locale,

		frame { name = "element_selector_view", direction = "vertical", style = "inside_deep_frame",
			frame { enabled = true, visible = true, direction = "horizontal", style = "subheader_frame", horizontally_stretchable=true,
				textfield { name = "search_textfield",
					on_text_changed = "search_text_changed",
					tooltip = { loc.search_instructions },
					lose_focus_on_confirm = true,
					text = data.filter.search_text or "",
					label { name = "search_textfield_shadow_text", caption = {loc.search_prompt}, ignored_by_interaction = true, visible = not data.filter.search_text or #data.filter.search_text == 0, font_color = {r = 0, g = 0, b = 0, a = 1} }
				},
				label {	name="num_results", caption = { loc.num_results, data.num_results or 0 }, visible = false},
				emptywidget {horizontally_stretchable = true},
				checkbox { name = "show_disabled", state = data.filter.show_disabled, on_click = "option_clicked"},
				emptywidget {width = 3},
				checkbox { name = "show_hidden", state = data.filter.show_hidden, on_click = "option_clicked"},
			},

			frame { name = "filter_warning_frame", direction = "horizontal", horizontally_stretchable=true, visible = false,
				label {	caption = { loc.localised_search_unavailable }}
			},

			-- item groups
			table { name ="item_group_header", column_count = 6, vertical_centering = true, style = "slot_table",
				children = this.create_group_buttons(plx, data.group_name)
			},

			-- items panel
			frame { direction = "horizontal",
				frame { direction = "horizontal", style = "deep_frame_in_shallow_frame", height = 560, minimal_width = 400,
					scrollpane { name = "elements_scroll_pane", style = "fact_elements_scroll_pane",
					--	children = this.items_panel_content(plx)
					}
				}
			}
		}
  	}
	designer.element = eb.createElementAccessor(root)

	this.add_groups(plx)
end

function this.add_groups(plx)
	local data = plx.ElementSelectorView
	assert(data.group_name~=nil, "data.group_name must not be nil")
	local container = designer.elements_scroll_pane
	local group_start_index
	for group_name_group_row, value in pairs(data.elements.rows) do
		local args = { name = "AUTO_group_flow", direction = "vertical", style="packed_vertical_flow"}
		local group_idx = #container.children+1
		local group_name = data.elements.idx_row_index_group_name[group_idx] --.e.g "logistics"
		local group = data.elements.rows[group_name]
		args.name = group_name.."_group_flow"
		eb.patch_tags(args, { group_name = group_name })
		args.visible = group_name==data.group_name
		if group_name==data.group_name then group_start_index = group_idx end
		eb.createPart {
			container=container, part_name="groups", mod_name=script.mod_name, view_name="ElementSelectorView", parent_view_name="MainView",
			flow(args)
		}
	end

	timer.elements{state={ -- start first timer without delay
		player_index = plx.player.index,
		group_index = group_start_index,
		group_end_index = group_start_index-1,
		subgroup_index = 1,
		element_index = 1,
	}}
end

local function add_subgroup_table(plx, container, subgroup_row, subgroup_idx)
	local group_name =  subgroup_row.rows[1].group.name
	local subgroup_name =  subgroup_row.rows[1].subgroup.name
	local args = { column_count = 10, vertical_centering = true, style = "slot_table"}
	eb.patch_tags(args, { group_name = group_name, subgroup_idx = subgroup_idx })
	args.name = subgroup_name.. "_subgroup_table"

	local part = eb.createPart {
		container = container,
		part_name="subgroup_table", mod_name=script.mod_name, view_name="ElementSelectorView", parent_view_name="MainView",
		table(args)
	}
	return part -- variable required to prevent (...tail calls...) in stack trace
end

---@param plx KuxGuiLib.PlayerContext
---@param container LuaGuiElement
---@param element KuxCoreLib.LuaGenericPrototype
---@return LuaGuiElement
local function add_element_button(plx, container, element)
	local elemId = {type = ElementUtils.getPrototypeGroup(element.type), name = element.name}

	local args = { ---@type KuxGuiLib.ElementBuilder.spritebutton.args
		name =  "."..elemId.type.."_"..elemId.name.."_element_button",
		on_click = "element_clicked",
		style = "slot_button",
		tags = { elemId = elemId},
		elem_tooltip = elemId,
		tooltip =  { "Kux-GuiLib-ElementSelectorView-tooltip.control_hint" },
		mouse_button_filter = { "left", "right", "middle" },
		sprite = elemId.type.."/"..elemId.name,
		visible = element.tags.filter_match --[[@as boolean]],
	}
	---[[TEST]] args.sprite="test/invalid"
	local part = eb.createPart {
		container  = container,
		part_name  = "element_button",
		mod_name   = script.mod_name,
		view_name  = "ElementSelectorView",
		parent_view_name="MainView",
		-- children --
		spritebutton(args)
	}
	return part
end

function timer.elements(e)
	--log("timer.elements")
	--local prof = game.create_profiler()
	local plx = getPlayerContextBase(e.state.player_index) --[[@as KuxGuiLib.PlayerContext]]
	restore = _G.player; _G.player=plx.player
	local data = plx.ElementSelectorView
	local group_idx_map = data.elements.idx_row_index_group_name
	local state = e.state

	local max_buttons = 200
	local count = 0
	print(state.group_index, state.subgroup_index, state.element_index)

	while true do --start with active group, go until the last one and then continue with the 1st one
		local group_name = group_idx_map[state.group_index]
		local group = data.elements.rows[group_name]
		local group_flow = designer[group_name.."_group_flow"]

		while state.subgroup_index <= #group.rows do
			local subgroup_row = group.rows[state.subgroup_index]
			local subgroup_flow = state.element_index>1 and group_flow[subgroup_row.rows[state.element_index-1].subgroup.name.. "_subgroup_table"]
			if not subgroup_flow then
				subgroup_flow = add_subgroup_table(plx, group_flow, subgroup_row, state.subgroup_index)
			end

			while state.element_index <= #subgroup_row.rows do
				local element = subgroup_row.rows[state.element_index]
				add_element_button(plx, subgroup_flow, element)
				count = count + 1
				state.element_index = state.element_index+ 1

				if count >= max_buttons then
					--prof.stop() log(prof)
					--log(count.. " buttons processed. continue at next tick")
					Events.on_next_tick(state, timer.elements)
					return
				end
			end

			state.subgroup_index = state.subgroup_index +1
			state.element_index = 1
		end

		state.group_index = state.group_index + 1
		if state.group_index > #data.elements.idx_row_index_group_name then state.group_index = 1 end
		if state.group_index == state.group_end_index+1 then break end
		state.subgroup_index = 1
		state.element_index = 1
	end
	--prof.stop()
	--log(prof)
	_G.player=restore
end

---@param plx KuxGuiLib.PlayerContext
---@param count number
function designer.update_num_results(plx, count)
	plx.ElementSelectorView.num_results = count
	designer.num_results.caption[2] = count or 0
end

---@param plx KuxGuiLib.PlayerContext
---@param group string? Name of the item group
function designer.select_group(plx, group)
	plx.ElementSelectorView.group_name = group

	for key, value in pairs(plx.ElementSelectorView.elements.rows) do
		local name = key.."_group_flow"
		designer[name].visible = key == group
	end
end


---@param plx KuxGuiLib.PlayerContext
function designer.focus_search(plx)
	local search_textfield = designer.search_textfield
	search_textfield.select_all()
	search_textfield.focus()
end

---@param plx KuxGuiLib.PlayerContext
---@param selected_group string
---@return table
function this.create_group_buttons(plx, selected_group)
	local buttons = {}
	for group_name, group in pairs(plx.ElementSelectorView.elements.rows) do
		_G.table.insert(buttons, this.item_group_button(plx, group, selected_group == group_name))
	end
	return buttons
end


---@param plx KuxGuiLib.PlayerContext
---@param group GroupRecord
---@param toggled boolean?
---@return fun(container: LuaGuiElement, parameters: table): LuaGuiElement
function this.item_group_button(plx, group, toggled)
	return spritebutton {
		type = "sprite-button",
		name = group.name.."_group_button",
		style = "filter_group_button_tab_slightly_larger",
		on_click = "item_group_clicked",
		tags = { item_group = group.name },
		sprite = "item-group/"..group.name,
		height = 72,
		width = 72,
		left_padding = -1,
		toggled = toggled,
		enabled = group.count_filtered > 0,
		number = group.count_filtered,
		tooltip = locstring(prototypes.item_group[group.name].localised_name)
	}
end

---@param plx KuxGuiLib.PlayerContext
---@return table
function this.items_panel_content(plx)
	local fc = {}
	local data = plx.ElementSelectorView

	local empty = frame { name = "filter_no_results_label", direction = "horizontal",
		label { caption = { "", "[img=warning-white] ",  loc.nothing_found } },
	}

	function fc.body()
		local flow, table, spritebutton = fc.flow, fc.table, fc.spritebutton

		local function template() return
			flow { name = "AUTO_group_flow", direction = "vertical", style="packed_vertical_flow", children =
				table { name = "AUTO", column_count = 10, vertical_centering = true, style = "slot_table", children =
					spritebutton {
						on_click = "element_clicked",
						style = "slot_button",
						tags = { id = { type = "item", name = "steel-chest" }},    -- AUTO
						--tooltip = { "Kux-GuiLib-ElementSelectorView-tooltip.control_hint" },
						sprite = "item/wooden-chest",                              -- AUTO
					},
				},
			}
		end

		local children = {}
		for i = 1, #data.elements.idx_row_index_group_name, 1 do children[i] = template() end
		return children
	end

	function fc.flow(args) --Lv 1
		local args =_G.table.deepcopy(args)
		--called for each group
		return function(container, parameters)
			local group_idx = #container.children+1
			local group_name = data.elements.idx_row_index_group_name[group_idx] --.e.g "logistics"
			local group = data.elements.rows[group_name]
			args.name = group_name.."_group_flow"
			eb.patch_tags(args, { group_name = group_name })
			args.visible = group_name==data.group_name
			if true or group_name == data.group_name then --TODO: conditional fill
				local children = {}
				for i = 1, #group.rows, 1 do children[i]=args.children end
				args.children = children
			else
				args.children = nil
			end
			return flow(args)
		end
	end

	function fc.table(args)--Lv 2
	local args =_G.table.deepcopy(args)
		return function(container, parameters)
			local is_virtual_root = container.object_name=="LuaGuiElement" and args.virtual==true
			local group_name = container.tags.group_name --[[@as string]] --.e.g "logistics"
			local subgroup_idx = is_virtual_root and #(container.tags.virtual_children or {}) +1 or #container.children +1
			local subgroup = data.elements.rows[group_name].rows[subgroup_idx]
			eb.patch_tags(args, { group_name = group_name, subgroup_idx = subgroup_idx })
			local children = {}
			for i=1, subgroup.count_total, 1 do children[i]=args.children end
			local args =_G.table.deepcopy(args)
			args.children = children
			args.name = subgroup.rows[1].subgroup.name.. "_subgroup_table"
			return table(args)
		end
	end

	--@param args KuxGuiLib.ElementBuilder.chooseelembutton.args
	function fc.spritebutton(args) --Lv 3
		local args =_G.table.deepcopy(args)
		return function(container, parameters)
			local group_name = container.tags.group_name --[[@as string]] --.e.g "logistics"
			assert(group_name~=nil,"tags.group_name must not be nil")
			local subgroup_idx = container.tags.subgroup_idx
			local element_idx = #container.children+1
			local proto = data.elements.rows[group_name].rows[subgroup_idx].rows[element_idx]
			local args =_G.table.deepcopy(args)
			args.tags = { id = { type = proto.type, name = proto.name }}
			--arg.mouse_button_filter = { "left", "right", "middle" }
			--args.sprite = proto.type.."/"..proto.name
			--if not helpers.is_valid_sprite_path(args.sprite) then args.sprite="item/"..proto.name end
			--if not helpers.is_valid_sprite_path(args.sprite) then args.sprite="utility/questionmark" end
			--return spritebutton(args)
			args.elemId = toElemID(proto)
			args.visible = proto.tags.filter_match --[[@as boolean]]
			args.locked = true
			args.name = args.elem_type.."_"..proto.name.."_element_button"
			return choose_elem_button(args)
		end
	end

	return fc.body()
end

---
---@param plx KuxGuiLib.PlayerContext
function designer.update_elements(plx)
	local data = plx.ElementSelectorView
	designer.num_results.caption[2] = data.num_results or 0
	for group_name, group in pairs(data.elements.rows) do
		designer[group_name.."_group_button"].enabled = group.count_filtered > 0
		designer[group_name.."_group_button"].number = group.count_filtered
		--if group_name ~= plx.ElementSelectorView.group_name then goto next end --PERFORMANCE
		--gui[group_name.."_group_flow"].visible = group.count_filtered > 0
		for _, subgroup in ipairs(group.rows) do
			local group_name = subgroup.rows[1].group.name
			local subgroup_name = subgroup.rows[1].subgroup.name
			subgroup_elem_name = subgroup_name.. "_subgroup_table"
			local subgroup_elem = designer[subgroup_elem_name]
			for _, element in ipairs(subgroup.rows) do
				local type = ElementUtils.getPrototypeGroup(element.type)
				local name = type.."_"..element.name.."_element_button"
				--designer[name].visible = element.tags.filter_match --[[@as boolean]]
				subgroup_elem["."..name].visible = element.tags.filter_match --[[@as boolean]]
			end
		end
		::next::
	end
end

designer.element=eb.loadElementAccessor("Kux-GuiLib","ElementSelectorView")
setmetatable(designer,{
	__index = function(t,k) return t.element[k] end,
	__newindex = function () error("Designer is readonly") end
})
-----------------------------------------------------------------------------------------------------------------------
return designer