---@diagnostic disable: different-requires

local relm = require("lib.core.relm.relm")
local relm_util = require("lib.core.relm.util")

local strformat = string.format
local type = _G.type
local abs = math.abs
local floor = math.floor

local msg_bubble = relm.msg_bubble
local msg_broadcast = relm.msg_broadcast
local Pr = relm.Primitive

local lib = {}

local noop = function() end
local empty = setmetatable({}, {
	__newindex = noop,
})

local function map(A, f)
	local B = {}
	for i = 1, #A do
		local x = f(A[i], i)
		if x ~= nil then B[#B + 1] = x end
	end
	return B
end

local function run_event_handler(handler, me, value, element, event)
	if type(handler) == "function" then
		handler(me, value, element, event)
	elseif type(handler) == "string" then
		relm.msg_bubble(
			me,
			{ key = handler, value = value, element = element, event = event }
		)
	end
end

local function Boolean(x)
	if x then
		return true
	else
		return false
	end
end

---Return `then_node` if `cond` is true, otherwise return an empty table. Useful for
---conditional Relm rendering.
---@param cond any
---@param then_node Relm.MaybeNode
---@return Relm.MaybeNode
function lib.If(cond, then_node)
	if cond then
		return then_node
	else
		return empty
	end
end

---Return `then_node` if `cond` is true, otherwise return `else_node`.
---@param cond any
---@param then_node Relm.MaybeNode
---@param else_node Relm.MaybeNode?
---@return Relm.MaybeNode
function lib.IfElse(cond, then_node, else_node)
	if cond then
		return then_node
	else
		return else_node or empty
	end
end

---Call `fn` if `cond` is truthy, otherwise return an empty table. Useful for
---conditional Relm rendering.
---@param cond any
---@param fn fun(...): Relm.MaybeNode?
---@return Relm.MaybeNode
function lib.CallIf(cond, fn, ...)
	if cond then
		return fn(...) or empty
	else
		return empty
	end
end

---Gather elements into an array, flattening subarrays and recursively
---gathering return values of functions.
---@param dst Relm.Node[]
local function gather_flat(dst, ...)
	local n = select("#", ...)
	for i = 1, n do
		local x = select(i, ...)
		if type(x) == "function" then
			gather_flat(dst, x())
		elseif type(x) == "table" then
			if x.type then
				dst[#dst + 1] = x
			else
				gather_flat(dst, table.unpack(x))
			end
		end
	end
end

---Generate a transform function for use with a `message_handler` prop. This
---function will transform messages targeting the node and forward them to
---the element's base handler. If the base handler doesn't handle the message
---it will be propagated in the same mode as the original message.
---@param mapper fun(payload: Relm.MessagePayload, props?: Relm.Props, state?: Relm.State): Relm.MessagePayload? Function taking an incoming message payload and transforming it to a new one, or returning `nil` if the message should be absorbed.
---@return Relm.Element.MessageHandlerWrapper
function lib.transform(mapper)
	return function(me, payload, props, state, base_handler)
		-- Transform and delegate to base
		local mapped = mapper(payload, props, state)
		if not mapped or (base_handler or noop)(me, mapped, props, state) then
			return true
		end
		-- If declined, rebroadcast mapped message
		if payload.propagation_mode == "bubble" then
			msg_bubble(me, mapped, true)
		elseif payload.propagation_mode == "broadcast" then
			msg_broadcast(me, mapped, true)
		end
		-- Treat as handled
		return true
	end
end

function lib.handle_gui_events(...)
	local event_map = {}
	for i = 1, select("#", ...), 2 do
		event_map[select(i, ...) or {}] = select(i + 1, ...)
	end
	return function(me, payload, props, state)
		if payload.key == "factorio_event" then
			---@cast payload Relm.MessagePayload.FactorioEvent
			local handler = event_map[payload.name]
			if not handler then return false end
			if type(handler) == "function" then
				handler(me, payload.event, props, state)
			elseif type(handler) == "string" then
				relm.msg_bubble(me, { key = handler, event = payload.event }, true)
			end
			return true
		end
		return false
	end
end

---Shallowly copies `src` into `dest`, returning `dest`.
---@generic K, V
---@param dest {[K]: V}
---@param src {[K]: V}?
---@return {[K]: V}
function lib.assign(dest, src)
	if not src then return dest end
	for k, v in pairs(src) do
		dest[k] = v
	end
	return dest
end
local assign = lib.assign

---Concatenate two arrays
---@generic T
---@param a1 T[]
---@param a2 T[]
---@return T[]
function lib.concat(a1, a2)
	local A = {}
	for i = 1, #a1 do
		A[i] = a1[i]
	end
	for i = 1, #a2 do
		A[#a1 + i] = a2[i]
	end
	return A
end
local concat = lib.concat

local function va_container(...)
	if select("#", ...) == 1 then
		return nil, select(1, ...)
	else
		return select(1, ...), select(2, ...)
	end
end

local function va_primitive(...) return ... end

---@alias Ultros.VarargNodeFactory fun(props_or_children?: Relm.Props | Relm.MaybeNode[], children?: Relm.MaybeNode[]): Relm.Node

---Creates a factory for customized nodes. If only prop changes are
---needed, you can use this rather than wrapping in virtual nodes.
---@param type string Node type to customize.
---@param default_props Relm.Props
---@param prop_transformer fun(props: table)? A function that will be called with the props table before it is passed to the node.
---@param is_container boolean? If true, the first argument to the constructor can be given as children rather than props.
---@return Ultros.VarargNodeFactory
function lib.customize(type, default_props, prop_transformer, is_container)
	local va_parser = is_container and va_container or va_primitive
	return function(...)
		local props, children = va_parser(...)
		local next_props = assign({}, default_props) --[[@as Relm.Props]]
		assign(next_props, props)
		if prop_transformer then prop_transformer(next_props) end
		next_props.children = children
		return {
			type = type,
			props = next_props,
		}
	end
end

lib.customize_primitive = function(
	default_props,
	prop_transformer,
	is_container
)
	return lib.customize(
		"Primitive",
		default_props,
		prop_transformer,
		is_container
	)
end

local function on_click_transformer(props)
	if props.on_click then
		props.listen = true
		props.message_handler =
			lib.handle_gui_events(defines.events.on_gui_click, props.on_click)
	end
end

lib.VFlow = lib.customize_primitive({
	type = "flow",
	direction = "vertical",
}, nil, true)
local VF = lib.VFlow
lib.HFlow = lib.customize_primitive({
	type = "flow",
	direction = "horizontal",
}, nil, true)
local HF = lib.HFlow
lib.Button = lib.customize_primitive({
	type = "button",
	style = "button",
}, on_click_transformer)
lib.SpriteButton = lib.customize_primitive({
	type = "sprite-button",
}, on_click_transformer)
lib.CloseButton = lib.customize_primitive({
	type = "sprite-button",
	style = "frame_action_button",
	sprite = "utility/close",
	hovered_sprite = "utility/close",
	mouse_button_filter = { "left" },
	on_click = "close",
}, on_click_transformer)
lib.Label = function(caption)
	return Pr({
		type = "label",
		caption = caption,
	})
end
lib.BoldLabel = function(caption)
	return Pr({
		type = "label",
		font = "default-bold",
		caption = caption,
	})
end
lib.RtBoldLabel = function(caption)
	return Pr({
		type = "label",
		rich_text_setting = defines.rich_text_setting.enabled,
		font = "default-bold",
		caption = caption,
	})
end
lib.RtLabel = function(caption)
	return Pr({
		type = "label",
		rich_text_setting = defines.rich_text_setting.enabled,
		caption = caption,
	})
end
--- Rich text label with large font size
lib.RtLgLabel = function(caption)
	return Pr({
		type = "label",
		rich_text_setting = defines.rich_text_setting.enabled,
		font = "default-large",
		caption = caption,
	})
end
lib.RtMultilineLabel = function(caption)
	return Pr({
		type = "label",
		rich_text_setting = defines.rich_text_setting.enabled,
		single_line = false,
		caption = caption,
	})
end
lib.Indicator = function(color)
	return Pr({
		type = "sprite",
		style = "relm_indicator",
		sprite = "relm_indicator_" .. color,
	})
end

lib.Titlebar = relm.define_element({
	name = "Titlebar",
	render = function(props)
		local has_close_button = props.closable or props.on_close
		local close_button_props = nil
		if props.on_close then
			close_button_props = { on_click = props.on_close }
		end

		local children = {
			Pr({
				type = "label",
				caption = props.caption,
				style = "frame_title",
				ignored_by_interaction = true,
			}),
			props.draggable and Pr({
				ref = props.drag_handle_ref,
				type = "empty-widget",
				style = "relm_titlebar_drag_handle",
			}),
		}
		if props.decoration then gather_flat(children, props.decoration) end
		if has_close_button then
			children[#children + 1] = lib.CloseButton(close_button_props)
		end

		return Pr({ type = "flow", direction = "horizontal" }, children)
	end,
})

lib.WindowFrame = relm.define_element({
	name = "WindowFrame",
	render = function(props)
		local closable = true
		if props.closable == false then closable = false end
		local window_ref, drag_handle_ref
		local function set_window(ref)
			window_ref = ref
			if window_ref and drag_handle_ref then
				drag_handle_ref.drag_target = window_ref
			end
		end
		local function set_drag_handle(ref)
			drag_handle_ref = ref
			if window_ref and drag_handle_ref then
				drag_handle_ref.drag_target = window_ref
			end
		end
		local children = concat({
			lib.Titlebar({
				draggable = true,
				closable = closable,
				on_close = props.on_close,
				caption = props.caption,
				drag_handle_ref = set_drag_handle,
				decoration = props.decoration,
			}),
		}, props.children)
		return Pr({
			ref = set_window,
			type = "frame",
			direction = "vertical",
			height = props.height,
			width = props.width,
		}, children)
	end,
})

lib.FixedWindowFrame = relm.define_element({
	name = "FixedWindowFrame",
	render = function(props)
		local children = concat({
			lib.Titlebar({
				draggable = false,
				closable = props.closable,
				caption = props.caption,
				decoration = props.decoration,
			}),
		}, props.children)
		return Pr({ type = "frame", direction = "vertical" }, children)
	end,
})

lib.Dropdown = lib.customize_primitive({
	type = "drop-down",
}, function(props)
	if props.on_change then
		props.listen = true
		props.message_handler = lib.handle_gui_events(
			defines.events.on_gui_selection_state_changed,
			function(me, gui_event, props2)
				local my_elt = gui_event.element
				local value = my_elt.selected_index
				if props2.options then value = props2.options[value].key end
				run_event_handler(props2.on_change, me, value, my_elt, gui_event)
			end
		)
	end
	if props.options then
		local items = {}
		local selected_index = nil
		for i, option in ipairs(props.options) do
			table.insert(items, option.caption)
			if option.key == props.value then selected_index = i end
		end
		props.items = items
		props.selected_index = selected_index
	end
	props.value = nil
end)

lib.Listbox = lib.customize_primitive({
	type = "list-box",
}, function(props)
	if props.on_change then
		props.listen = true
		props.message_handler = lib.handle_gui_events(
			defines.events.on_gui_selection_state_changed,
			function(me, gui_event, props2)
				local my_elt = gui_event.element
				local value = my_elt.selected_index
				if props2.options then value = props2.options[value].key end
				run_event_handler(props2.on_change, me, value, my_elt, gui_event)
			end
		)
	end
	if props.options then
		local items = {}
		local selected_index = nil
		for i, option in ipairs(props.options) do
			table.insert(items, option.caption)
			if option.key == props.value then selected_index = i end
		end
		props.items = items
		props.selected_index = selected_index
	end
	props.value = nil
end)

lib.Labeled = relm.define_element({
	name = "Labeled",
	render = function(props)
		local label_props = assign({
			type = "label",
			font_color = { 255, 230, 192 },
			font = "default-bold",
			caption = props.caption,
		}, props.label_props)
		local hf_props = assign({
			vertical_align = "center",
			horizontally_stretchable = true,
		}, props)
		return HF(hf_props, {
			Pr(label_props),
			HF({ horizontally_stretchable = true }, {}),
			-- OK to crash-on-nil here because this is a logical misuse of Labeled
			---@diagnostic disable-next-line: need-check-nil
			props.children[1],
		})
	end,
})

lib.ChooseElemButton = lib.customize_primitive({
	type = "choose-elem-button",
	elem_type = "signal",
}, function(props)
	props.elem_value = props.value
	props.value = nil
	if props.virtual_signal then
		props.elem_value = { type = "virtual", name = props.virtual_signal }
	end

	if props.on_change then
		props.listen = true
		props.message_handler = lib.handle_gui_events(
			defines.events.on_gui_elem_changed,
			function(me, gui_event, props2)
				local my_elt = gui_event.element
				run_event_handler(
					props2.on_change,
					me,
					my_elt.elem_value,
					my_elt,
					gui_event
				)
			end
		)
	end
end)
lib.SignalPicker = lib.ChooseElemButton

local function checkbox_customizer(props)
	if props.value == true or props.value == false then
		props.state = props.value
		props.value = nil
	else
		props.state = false
	end

	if props.on_change then
		props.listen = true
		props.message_handler = lib.handle_gui_events(
			defines.events.on_gui_checked_state_changed,
			function(me, gui_event, props2)
				local my_elt = gui_event.element
				run_event_handler(props2.on_change, me, my_elt.state, my_elt, gui_event)
			end
		)
	end

	props.query_handler = function(me, payload)
		if payload.key == "value" and me.elem then return true, me.elem.state end
		return false
	end
end

lib.Checkbox = lib.customize_primitive({
	type = "checkbox",
}, checkbox_customizer)

lib.RadioButton = lib.customize_primitive({
	type = "radiobutton",
}, checkbox_customizer)

lib.WellHeader = relm.define("WellHeader", function(props)
	local caption_element = props.caption_element
	if props.caption then
		caption_element = Pr({
			type = "label",
			style = "subheader_caption_label",
			caption = props.caption,
		})
	end
	return Pr({
		type = "frame",
		style = "subheader_frame",
		horizontally_stretchable = true,
		bottom_margin = 4,
	}, {
		caption_element,
		lib.If(props.decorate, HF({ horizontally_stretchable = true }, {})),
		lib.CallIf(props.decorate, props.decorate, props),
	})
end)

lib.WellSection = relm.define("WellSection", function(props)
	local collapsed = not not props.collapsed
	local visible = true
	if props.visible == false then visible = false end
	local caption_element = props.caption_element
	if props.caption then
		caption_element = Pr({
			type = "label",
			style = "subheader_caption_label",
			caption = props.caption,
		})
	end

	return VF({
		bottom_margin = 6,
		horizontally_squashable = true,
		visible = visible,
	}, {
		Pr({
			type = "frame",
			style = "subheader_frame",
			horizontally_stretchable = true,
			bottom_margin = 4,
		}, {
			caption_element,
			lib.If(props.decorate, HF({ horizontally_stretchable = true }, {})),
			lib.CallIf(props.decorate, props.decorate, props),
		}),
		VF({
			left_padding = 8,
			right_padding = 8,
			visible = not collapsed,
			horizontally_squashable = true,
		}, props.children),
	})
end)

lib.WellFold = relm.define("WellFold", function(props)
	local collapsed, set_collapsed = relm.use_state(true)
	local next_props = assign({}, props)
	next_props.collapsed = collapsed
	next_props.decorate = function()
		return lib.SpriteButton({
			style = "frame_action_button",
			sprite = "utility/add_white",
			on_click = function() set_collapsed(not collapsed) end,
			toggled = not collapsed,
		})
	end
	return lib.WellSection(next_props)
end)

lib.Switch = lib.customize_primitive({
	type = "switch",
}, function(props)
	if props.value == true or props.value == false then
		props.switch_state = props.value and "right" or "left"
	elseif type(props.value) == "number" then
		props.switch_state = props.value == 0 and "none"
			or (props.value == 1 and "left" or "right")
	end
	props.value = nil

	if props.on_change then
		props.listen = true
		props.message_handler = lib.handle_gui_events(
			defines.events.on_gui_switch_state_changed,
			function(me, gui_event, props2)
				local my_elt = gui_event.element
				local state = my_elt.switch_state
				run_event_handler(
					props2.on_change,
					me,
					state == "none" and 0 or (state == "left" and 1 or 2),
					my_elt,
					gui_event
				)
			end
		)
	end
end)

local function get_text_value(text, is_numeric, is_float)
	if is_numeric then
		local value = tonumber(text)
		if value and not is_float then value = math.floor(value) end
		return value
	else
		return text or ""
	end
end

---@deprecated Use `lib.Input` instead, which has better handling for dirty state and unconfirmed changes.
lib.LegacyInput = lib.customize_primitive({
	type = "textfield",
	lose_focus_on_confirm = true,
}, function(props)
	if props.value then
		props.initial_text = tostring(props.value)
		props.value = nil
	end

	if props.on_confirm or props.on_change then
		props.listen = true
		props.message_handler = lib.handle_gui_events(
			defines.events.on_gui_confirmed,
			function(me, gui_event, props2)
				local my_elt = gui_event.element
				run_event_handler(
					props2.on_confirm,
					me,
					get_text_value(my_elt.text, props2.numeric, props2.allow_decimal),
					my_elt,
					gui_event
				)
			end,
			defines.events.on_gui_text_changed,
			function(me, gui_event, props2)
				local my_elt = gui_event.element
				run_event_handler(
					props2.on_change,
					me,
					get_text_value(gui_event.text, props2.numeric, props2.allow_decimal),
					my_elt,
					gui_event
				)
			end
		)
	end
	props.query_handler = function(me, payload, props2)
		if payload.key == "value" and me.elem then
			return true,
				get_text_value(me.elem.text, props2.numeric, props2.allow_decimal)
		end
		return false
	end
end)

lib.Input = lib.customize_primitive({
	type = "textfield",
	lose_focus_on_confirm = true,
}, function(props)
	if props.value then
		props.initial_text = tostring(props.value)
		props.value = nil
	end

	local on_confirm = props.on_confirm or noop --[[@as function]]
	local on_change = props.on_change or noop --[[@as function]]
	local on_dirty = props.on_dirty or noop --[[@as function]]
	props.on_confirm = nil
	props.on_change = nil
	props.on_dirty = nil

	props.listen = true
	props.message_handler = lib.handle_gui_events(
		defines.events.on_gui_confirmed,
		function(me, gui_event, props2)
			local my_elt = gui_event.element
			on_confirm(
				me,
				get_text_value(my_elt.text, props2.numeric, props2.allow_decimal),
				my_elt,
				gui_event
			)
			on_dirty(false)
		end,
		defines.events.on_gui_text_changed,
		function(me, gui_event, props2)
			on_dirty(true)
			local my_elt = gui_event.element
			on_change(
				me,
				get_text_value(gui_event.text, props2.numeric, props2.allow_decimal),
				my_elt,
				gui_event
			)
		end
	)
end)

lib.UncontrolledInput = relm.define("ultros.UncontrolledInput", function(props)
	local value, set_value = relm.use_state(props.value)
	local dirty, set_dirty = relm.use_state(false)
	local base_on_change = props.on_change or noop
	local next_props = assign({}, props)
	next_props.on_change = function(me, new_value)
		set_value(new_value)
		set_dirty(true)
	end
	next_props.on_confirm = function(me, new_value)
		set_value(new_value)
		set_dirty(false)
		base_on_change(me, new_value)
	end
	next_props.on_cleanup = function()
		if dirty then base_on_change(nil, value) end
	end
	return lib.Input(next_props)
end)

lib.Tag = relm.define_element({
	name = "ultros.Tag",
	render = function(props) return props.children end,
	query = function(me, payload, props)
		if payload.propagation_mode == "broadcast" then
			local handled, res = relm.query_broadcast(me, payload, true)
			if handled then return handled, res, props.query_tag end
		end
		return false
	end,
})

function lib.tag(tag, elt) return lib.Tag({ query_tag = tag }, { elt }) end

function lib.gather(tag_or_children, children)
	if type(tag_or_children) == "string" then
		return relm.Gather({ query_tag = tag_or_children }, children)
	else
		return relm.Gather({}, tag_or_children)
	end
end

lib.RadioButtons = relm.define_element({
	name = "ultros.RadioButtons",
	render = function(props)
		local elems = props.buttons or {}
		return map(elems, function(elem)
			return lib.RadioButton({
				caption = elem.caption,
				value = (elem.key == props.value),
				horizontally_stretchable = true,
				on_change = function(me, value)
					if value then
						relm.msg_bubble(me, { key = "radio_clicked", value = elem.key })
					end
				end,
			})
		end)
	end,
	message = function(me, payload, props)
		if payload.key == "radio_clicked" then
			local value = payload.value
			if value ~= props.value then
				if props.on_change then
					run_event_handler(props.on_change, me, value)
				end
			end
			return true
		end
		return false
	end,
})

local function selected_tab_query_handler(me, payload, props)
	if payload.key == "selected_tab" and me.elem then
		return true, me.elem.selected_tab_index
	end
	return false
end

lib.TabbedPane = relm.define_element({
	name = "ultros.TabbedPane",
	render = function(props, state)
		local selected_tab = (state or empty).selected_tab
		local passed_props = assign({}, props)
		passed_props.type = "tabbed-pane"
		passed_props.listen = true
		passed_props.selected_tab_index = selected_tab
		passed_props.query_handler = selected_tab_query_handler
		passed_props.tabs = nil

		local children = {}
		for i, tab in ipairs(props.tabs) do
			if tab.content then
				children[#children + 1] = Pr({
					type = "tab",
					caption = tab.caption or "(no caption)",
				})
				if i == selected_tab then
					tab.content.props.selected = true
				else
					tab.content.props.selected = false
				end
				children[#children + 1] = tab.content
			end
		end
		return Pr(passed_props, children)
	end,
	message = function(me, payload, props)
		if payload.key == "factorio_event" then
			if payload.name == defines.events.on_gui_selected_tab_changed then
				local _, index =
					relm.query_broadcast(me, { key = "selected_tab" }, true)
				relm.set_state(me, {
					selected_tab = index,
				})
			end
			return true
		end
		return false
	end,
	state = function(props)
		---@diagnostic disable-next-line: return-type-mismatch
		return { selected_tab = props.initial_selected_tab or 1 }
	end,
})

---Ensures that tabs that are not selected have their Relm elements removed
---so that events/timers don't fire when unneeded. Only valid as a `content`
---item in a `TabbedPane`.
lib.HiddenTabRemover = relm.define_element({
	name = "ultros.HiddenTabRemover",
	render = function(props)
		if props.selected then
			return props.content
		else
			return Pr({ type = "empty-widget" })
		end
	end,
})

lib.ShallowSection = relm.define_element({
	name = "ultros.ShallowSection",
	render = function(props)
		return {
			lib.RtBoldLabel(props.caption),
			Pr({
				type = "frame",
				style = "relm_deep_frame_in_shallow_frame_stretchable",
			}, props.children),
		}
	end,
})

lib.TimedRepaintWrapper = relm.define_element({
	name = "ultros.TimedRepaintWrapper",
	render = function(props)
		relm_util.use_timer(props.period or 60, "_repaint")
		local t = game and game.tick or 0
		local render = props.render
		return render and render(t)
	end,
	message = function(me, message, props)
		if message.key == "_repaint" then
			relm.paint(me)
			return true
		else
			return false
		end
	end,
})

--------------------------------------------------------------------------------
-- SIGNAL BUTTON GRIDS
--------------------------------------------------------------------------------

local function si_format(count, divisor, si_symbol)
	if abs(floor(count / divisor)) >= 10 then
		count = floor(count / divisor)
		return strformat("%.0f%s", count, si_symbol)
	else
		count = floor(count / (divisor / 10)) / 10
		return strformat("%.1f%s", count, si_symbol)
	end
end

---@param count number
---@return string
local function format_signal_count(count)
	local absv = abs(count)
	return -- signals are 32bit integers so Giga is enough
		absv >= 1e9 and si_format(count, 1e9, "G") or absv >= 1e6 and si_format(
		count,
		1e6,
		"M"
	) or absv >= 1e3 and si_format(count, 1e3, "k") or tostring(count)
end

---@class Ultros.SignalButtonInfo
---@field public signal SignalID? The signal to display or `nil` for an empty button.
---@field public count number|LocalisedString Lower caption.
---@field public upper (number|LocalisedString)? Upper caption, for an "X/Y" style display.
---@field public button_style string? Style for the button itself, defaults to "relm_slot_button_default".
---@field public lower_color Color? Font color for the lower caption.
---@field public upper_color Color? Font color for the upper caption.
---@field public locked? boolean If true, the button will not open the change dialogue when clicked.

---Manual paint function for signal counts
---@param elem LuaGuiElement
---@param primitive_props table
---@param get_event_tags fun(): Tags
local function paint_buttons(elem, primitive_props, get_event_tags)
	local props = primitive_props.parent_props
	local default_style = props.button_style or "relm_slot_button_default"
	local buttons = props.buttons --[[@as Ultros.SignalButtonInfo[]? ]]
	local buttons_table = props.buttons_table --[[@as { [any]: Ultros.SignalButtonInfo}? ]]
	local uppers = props.uppers
	local enabled = (props.enabled == true)

	---@param style? string
	local function add_button(style)
		-- XXX: TYPES: FMTK LuaGuiElement.add_param bug
		local button = elem.add({
			type = "choose-elem-button",
			elem_type = "signal",
			style = style or default_style,
		})
		button.add({
			type = "label",
			style = "relm_label_signal_count",
			ignored_by_interaction = true,
		})
		if uppers then
			local upper_label = button.add({
				type = "label",
				style = "relm_label_signal_count",
				ignored_by_interaction = true,
			})
			upper_label.style.height = 24
		end
		return button
	end

	---@param button LuaGuiElement
	---@param button_info Ultros.SignalButtonInfo?
	local function apply_button(button, button_info, button_index)
		local is_enabled = enabled
		button.enabled = is_enabled
		button.elem_value = button_info and button_info.signal
		button.style = (button_info and button_info.button_style) or default_style
		local lower = button.children[1] --[[@as LuaGuiElement]]
		local count = button_info and button_info.count or ""
		if type(count) == "number" then count = format_signal_count(count) end
		lower.caption = count
		if button_info and button_info.lower_color then
			lower.style.font_color = button_info.lower_color
		end
		if uppers then
			local upper = button.children[2] --[[@as LuaGuiElement]]
			local upper_count = button_info and button_info.upper or ""
			if type(upper_count) == "number" then
				upper_count = format_signal_count(upper_count)
			end
			upper.caption = upper_count
			if button_info and button_info.upper_color then
				upper.style.font_color = button_info.upper_color
			end
		end
		if is_enabled then
			local tag_base = get_event_tags()
			tag_base.button_index = button_index
			button.tags = tag_base
			button.locked = Boolean(button_info and button_info.locked)
		else
			button.tags = {}
		end
	end

	local child_index = 1
	local children = elem.children
	local iter1, iter2, iter3
	if buttons then
		iter1, iter2, iter3 = ipairs(buttons)
	elseif buttons_table then
		iter1, iter2, iter3 = pairs(buttons_table)
	end

	for button_key, button_info in iter1, iter2, iter3 do
		---@diagnostic disable-next-line: need-check-nil
		local button = children[child_index]
		if not button then button = add_button(button_info.button_style) end
		apply_button(button, button_info, button_key)
		child_index = child_index + 1
	end

	-- Destroy excess buttons
	while #children >= child_index do
		---@diagnostic disable-next-line: need-check-nil
		children[child_index].destroy()
		child_index = child_index + 1
	end
end

lib.SlotButtonTable = relm.define("ultros.SlotButtonTable", function(props)
	local function handler(_me, relm_event, _props)
		local gui_event = relm_event.event
		local elt = gui_event.element
		local tags = elt.tags
		local button_index = tags and tags.button_index
		if not button_index then return end
		if gui_event.name == defines.events.on_gui_elem_changed then
			local hdlr = _props.on_change
			if hdlr then return hdlr(button_index, elt.elem_value, gui_event) end
		elseif gui_event.name == defines.events.on_gui_click then
			local hdlr = _props.on_click
			if hdlr then return hdlr(button_index, elt.elem_value, gui_event) end
		end
	end

	return Pr({
		type = "table",
		column_count = props.column_count,
		manual_paint = paint_buttons,
		style = props.style or "slot_table",
		parent_props = props,
		message_handler = handler,
		on_click = props.on_click,
		on_change = props.on_change,
	})
end)

local RIGHT_CLICK = defines.mouse_button_type.right

lib.SignalCountsInput = relm.define("ultros.SignalCountsInput", function(props)
	local selected_index, set_selected_index = relm.use_state(0)
	local on_change = props.on_change or noop
	local input_signals = props.signals or empty
	local input_counts = props.counts or empty
	local me = relm.use_handle()

	local signals = {}
	local counts = {}
	for i, signal in ipairs(input_signals) do
		if signal then
			signals[#signals + 1] = signal
			local count = input_counts[i]
			counts[#counts + 1] = type(count) == "number" and count or 1
		end
	end

	local n_signals = #signals
	local n_columns = props.column_count or 10
	local n_buttons_base = n_signals + 1 -- Keep one guaranteed empty slot.
	local n_rows = math.max(1, math.ceil(n_buttons_base / n_columns))
	local n_buttons = n_rows * n_columns

	---@param set_index uint?
	---@param set_signal SignalID?
	---@param set_count uint32?
	---@param insert_signal SignalID?
	---@param remove_index uint?
	local function edit_signals(
		set_index,
		set_signal,
		set_count,
		insert_signal,
		remove_index
	)
		local next_signals = {}
		local next_counts = {}
		for i = 1, n_signals do
			next_signals[i] = signals[i]
			next_counts[i] = counts[i]
		end

		if set_index then
			if set_signal then next_signals[set_index] = set_signal end
			if set_count then next_counts[set_index] = set_count end
		elseif insert_signal then
			table.insert(next_signals, insert_signal)
			table.insert(next_counts, 1)
		elseif remove_index then
			table.remove(next_signals, remove_index)
			table.remove(next_counts, remove_index)
			if selected_index > remove_index then
				set_selected_index(selected_index - 1)
			elseif selected_index == remove_index then
				set_selected_index(0)
			end
		end

		on_change(me, next_signals, next_counts)
	end

	local buttons = {}
	for i = 1, n_buttons do
		if i <= n_signals then
			buttons[i] = {
				signal = signals[i],
				count = counts[i],
				button_style = i == selected_index and "flib_slot_button_yellow" or nil,
				locked = true,
			}
		else
			buttons[i] = {
				signal = nil,
				count = "",
				button_style = i == selected_index and "flib_slot_button_yellow" or nil,
				locked = false,
			}
		end
	end

	local selected_count = (selected_index >= 1 and selected_index <= n_signals)
			and counts[selected_index]
		or nil

	return lib.VFlow({
		lib.SlotButtonTable({
			column_count = n_columns,
			buttons = buttons,
			enabled = true,
			on_click = function(button_index, signal, ev)
				if signal then
					if ev.button == RIGHT_CLICK then
						-- Right click clears the signal
						edit_signals(nil, nil, nil, nil, button_index)
					else
						set_selected_index(button_index)
					end
				end
			end,
			on_change = function(button_index, signal)
				if signal then
					if button_index >= 1 and button_index <= n_signals then
						edit_signals(button_index, signal, nil, nil, nil)
						set_selected_index(button_index)
					else
						edit_signals(nil, nil, nil, signal, nil)
						set_selected_index(n_signals + 1)
					end
				else
					if button_index >= 1 and button_index <= n_signals then
						edit_signals(nil, nil, nil, nil, button_index)
					end
				end
			end,
		}),
		lib.Labeled({ caption = props.count_caption or "Count" }, {
			lib.UncontrolledInput({
				value = selected_count,
				numeric = true,
				width = props.count_width or 120,
				enabled = selected_count ~= nil,
				on_change = function(_, next_count)
					next_count = tonumber(next_count)
					if not next_count then return end
					if selected_index < 1 or selected_index > n_signals then return end
					edit_signals(selected_index, nil, next_count, nil)
				end,
			}),
		}),
	})
end)

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT
--------------------------------------------------------------------------------

lib.PinButton = relm.define("ultros.PinButton", function(props)
	local is_pinned = props.pinned
	local set_pinned = props.set_pinned or noop
	return lib.SpriteButton({
		style = "frame_action_button",
		sprite = "relm_pin_white",
		on_click = function() set_pinned(not is_pinned) end,
		toggled = is_pinned,
		tooltip = {
			"",
			"Pin this window. When pinned, it will not be automatically closed.",
		},
	})
end)

local GUI_TYPE_CUSTOM = defines.gui_type.custom

function lib.use_pinnable()
	local pinned, _set_pinned = relm.use_state(false)
	return pinned, _set_pinned
end

---Automatically set and unset `player.opened` for this root, while also
---enabling "pinning" functionality.
---@param player_index int
function lib.use_player_opened_pinnable(player_index)
	local pinned, _set_pinned = relm.use_state(false)

	-- Set player.opened according to the pinned state
	relm.use_effect(pinned, function(handle, is_pinned)
		local elt = relm.get_root_element_from_handle(handle)
		local player = game and player_index and game.get_player(player_index)
		if (not player) or not elt or not elt.valid then return end
		if is_pinned then
			-- If pinned and I am player.opened, unset player.opened
			if player.opened == elt then player.opened = nil end
		else
			if not player.opened then
				-- If unpinned and nothing is player.opened, make me player.opened.
				player.opened = elt
			end
		end
	end)

	-- Initially set player.opened to me regardless
	relm.use_effect(true, function(handle)
		local elt = relm.get_root_element_from_handle(handle)
		local player = game and player_index and game.get_player(player_index)
		if (not player) or not elt or not elt.valid then return end
		player.opened = elt
	end)

	return pinned, _set_pinned
end

function lib.use_player_opened(player_index)
	relm.use_effect(true, function(handle)
		local elt = relm.get_root_element_from_handle(handle)
		local player = game and player_index and game.get_player(player_index)
		if (not player) or not elt or not elt.valid then return end
		player.opened = elt
	end)
end

---Closes this window when a custom gui is `on_gui_closed`. If pinned,
---will not close the window.
---@param player_index int
---@param close_me fun()
---@param is_pinned boolean?
---@param type_filter defines.gui_type|nil If set, only close the window if the closed GUI is of this type. By default, only close on custom GUIs.
function lib.use_close_on_gui_closed(
	player_index,
	close_me,
	is_pinned,
	type_filter
)
	local me = relm.use_handle()
	relm_util.use_event_handler(
		defines.events.on_gui_closed,
		function(_me, _, event)
			---@cast event EventData.on_gui_closed
			if is_pinned or (event.player_index ~= player_index) then return end
			if event.element == me then return close_me() end
			if event.gui_type == (type_filter or GUI_TYPE_CUSTOM) then
				return close_me()
			end
		end
	)
end

---Auto-center the window on the screen when it is first opened.
function lib.use_auto_center_on_open()
	relm.use_effect(true, function(handle)
		local elt = relm.get_root_element_from_handle(handle)
		if elt and elt.valid then elt.force_auto_center() end
	end)
end

---Memoize a position on window close and restore it on open.
---Wraps your close handler and creates a new one. You should use the returned handler in place of your original close handler.
---@param close_me fun()
---@param load_pos fun(): GuiLocation? Function to load a memoized position.
---@param save_pos fun(xy: GuiLocation?) Function to save the current position. The position passed to this function will be the last position of the window before it was closed.
---@param apply_default_pos fun(elt: LuaGuiElement) Apply a default position to the rendered window if no memoized position was found.
function lib.use_memoized_window_position(
	close_me,
	load_pos,
	save_pos,
	apply_default_pos
)
	local me = relm.use_handle()

	local function new_close()
		local elt = relm.get_root_element_from_handle(me)
		if elt and elt.valid then save_pos(elt.location) end
		close_me()
	end

	relm.use_effect(true, function(handle)
		local elt = relm.get_root_element_from_handle(handle)
		if elt and elt.valid then
			local xy = load_pos()
			if xy then
				elt.location = xy
			else
				apply_default_pos(elt)
			end
		end
	end)

	return new_close
end

return lib
