---@diagnostic disable: inject-field

local tremove = _G.table.remove
local type = _G.type
local min = _G.math.min
local error = _G.error
local strfind = _G.string.find
local pairs = _G.pairs
local setmetatable = _G.setmetatable

---@class Relm.Lib
local lib = {}
_G.__RELM__ = lib

local EMPTY = setmetatable({}, { __newindex = function() end })

--------------------------------------------------------------------------------
-- FACTORIO STUFF
-- If they change something in factorio look here first for what needs updated
--------------------------------------------------------------------------------

---Version number of Relm storage internals. Used to discard roots that
---may not conform to updated formats in the absence of migrations.
local RELM_DATA_VERSION = 1

-- h/t `flib.gui` for the below code which serves much the same function here

--- @alias Relm.PrimitiveDefinition LuaGuiElement.add_param

--- Aggregate type of all possible GUI events.
--- @alias Relm.GuiEventData EventData.on_gui_checked_state_changed|EventData.on_gui_click|EventData.on_gui_closed|EventData.on_gui_confirmed|EventData.on_gui_elem_changed|EventData.on_gui_location_changed|EventData.on_gui_opened|EventData.on_gui_selected_tab_changed|EventData.on_gui_selection_state_changed|EventData.on_gui_switch_state_changed|EventData.on_gui_text_changed|EventData.on_gui_value_changed

-- h/t flib for this code
local gui_events = {}
for name, id in pairs(defines.events) do
	if strfind(name, "on_gui_") then gui_events[id] = true end
end

-- `LuaGuiElement` keys that can safely be applied from `Primitive` props.
local APPLICABLE_KEYS = {
	caption = true,
	value = true,
	visible = true,
	text = true,
	state = true,
	sprite = true,
	resize_to_sprite = true,
	hovered_sprite = true,
	clicked_sprite = true,
	tooltip = true,
	elem_tooltip = true,
	horizontal_scroll_policy = true,
	vertical_scroll_policy = true,
	items = true,
	selected_index = true,
	number = true,
	show_percent_for_small_numbers = true,
	location = true,
	auto_center = true,
	badge_text = true,
	auto_toggle = true,
	toggled = true,
	game_controller_interaction = true,
	position = true,
	surface_index = true,
	zoom = true,
	minimap_player_index = true,
	force = true,
	elem_value = true,
	elem_filters = true,
	selectable = true,
	word_wrap = true,
	read_only = true,
	enabled = true,
	ignored_by_interaction = true,
	locked = true,
	draw_vertical_lines = true,
	draw_horizontal_lines = true,
	draw_vertical_line_after_headers = true,
	vertical_centering = true,
	slider_value = true,
	mouse_button_filter = true,
	numeric = true,
	allow_decimal = true,
	allow_negative = true,
	is_password = true,
	lose_focus_on_confirm = true,
	drag_target = true,
	selected_tab_index = true,
	entity = true,
	anchor = true,
	tags = true,
	raise_hover_events = true,
	switch_state = true,
	allow_none_state = true,
	left_label_caption = true,
	left_label_tooltip = true,
	right_label_caption = true,
	right_label_tooltip = true,
}

-- `LuaGuiElement` keys that can only be applied at creation.
local CREATE_KEYS = {
	index = true,
	type = true,
	name = true,
	direction = true,
	elem_type = true,
	column_count = true,
	style = true,
	icon_selector = true,
}
-- TODO: if an element props change in one of the `CREATE_KEYS` categories, recreate it in `vpaint`.

-- `Primitive` props that will be set on the `LuaStyle` rather than the
-- element itself.
local STYLE_KEYS = {
	minimal_width = true,
	maximal_width = true,
	minimal_height = true,
	maximal_height = true,
	natural_width = true,
	natural_height = true,
	top_padding = true,
	right_padding = true,
	bottom_padding = true,
	left_padding = true,
	top_margin = true,
	right_margin = true,
	bottom_margin = true,
	left_margin = true,
	horizontal_align = true,
	vertical_align = true,
	font_color = true,
	font = true,
	top_cell_padding = true,
	right_cell_padding = true,
	bottom_cell_padding = true,
	left_cell_padding = true,
	horizontally_stretchable = true,
	vertically_stretchable = true,
	horizontally_squashable = true,
	vertically_squashable = true,
	rich_text_setting = true,
	hovered_font_color = true,
	clicked_font_color = true,
	disabled_font_color = true,
	pie_progress_color = true,
	clicked_vertical_offset = true,
	selected_font_color = true,
	selected_hovered_font_color = true,
	selected_clicked_font_color = true,
	strikethrough_color = true,
	horizontal_spacing = true,
	vertical_spacing = true,
	use_header_filler = true,
	color = true,
	-- column_alignments = true,
	single_line = true,
	extra_top_padding_when_activated = true,
	extra_bottom_padding_when_activated = true,
	extra_left_padding_when_activated = true,
	extra_right_padding_when_activated = true,
	extra_top_margin_when_activated = true,
	extra_bottom_margin_when_activated = true,
	extra_left_margin_when_activated = true,
	extra_right_margin_when_activated = true,
	stretch_image_to_widget_size = true,
	badge_font = true,
	badge_horizontal_spacing = true,
	default_badge_font_color = true,
	selected_badge_font_color = true,
	disabled_badge_font_color = true,
	width = true,
	height = true,
	padding = true,
	margin = true,
}

--------------------------------------------------------------------------------
-- CORE PUBLIC TYPES
-- These types, along with the exports defined on `lib`, constitute the public
-- API of Relm and should not be changed.
--------------------------------------------------------------------------------

---@class Relm.EventSink
---@field public raise fun(event_name: string, ...: any): nil

---@type Relm.EventSink
local __EVENT_SINK__

---The primary output of `render` functions, representing nodes in the virtual
---tree.
---@class (exact) Relm.Node
---@field public type string The type of this node.
---@field public props? Relm.Props The properties of this node.

---Opaque reference used to refer to a vtree node. Safe for use in `storage`,
---though after storing a handle long-term you should validate it with
---`is_valid`. DO NOT access internal fields of handles or you WILL crash
---your game. Use only designated Relm APIs with handles.
---@class (exact) Relm.Handle

---Opaque reference to a closure. Safe for use in `storage`. DO NOT use these
---values except through the associated APIs.
---@class (exact) Relm.Closure

---Definition of a reusable element distinguished by its name.
---@class (exact) Relm.ElementDefinition
---@field public name string The name of this element. Must be unique across the Lua state.
---@field public render Relm.Element.RenderDefinition Renders the element. Render MUST be a pure function of state, props, and authorized access to the `children` handle. It MUST NOT cause side effects!
---@field public factory? Relm.NodeFactory If given, this will replace the automatically generated factory function returned by `define_element`.
---@field public message? Relm.Element.MessageHandlerDefinition Defines the message handler for elements of this type. Message handlers may cause side effects.
---@field public state? Relm.Element.StateDefinition If given, determines the initial state from the element's initial props. (This is NOT required to use state, only if you want a non-`nil` initial state)
---@field public query? Relm.Element.QueryHandlerDefinition Defines the query handler for elements of this type. Query handlers MUST be pure functions of state, props, and other queries. They MUST NOT cause side effects!

---@alias Relm.MaybeNode Relm.Node|{}

---@alias Relm.RootId int

---@alias Relm.Value boolean|int|number|string

---@alias Relm.RefFn fun(elem: LuaGuiElement, handle: Relm.Handle)

---@alias Relm.ManualPaintFn fun(elem: LuaGuiElement, props: Relm.Props)

---@alias Relm.Props {children?: Relm.Children, [string|int]:any}

---@alias Relm.StateValue string|number|int|boolean|nil

---@alias Relm.State Relm.StateValue | {[string|int]: Relm.State}

---@alias Relm.Children Relm.Node|Relm.Node[]|nil

---@alias Relm.RenderFn fun(props: Relm.Props): Relm.Children | Relm.Children[]

---@alias Relm.QueryResponse string|number|int|boolean|table|nil

---@alias Relm.QueryTag string|number|nil

---@alias Relm.EffectKey Relm.Value|table<int|string, Relm.EffectKey>

---@alias Relm.SendMessagePayload {key: string, [any]:any}

---@alias Relm.MessagePayload {key: string, propagation_mode: "bubble"|"broadcast"|"unicast", [any]:any}

---@alias Relm.Element.RenderDefinition fun(props: Relm.Props, state?: Relm.State): Relm.Children|Relm.Children[]

---@alias Relm.Element.MessageHandlerDefinition fun(me: Relm.Handle, payload: Relm.MessagePayload, props: Relm.Props, state?: Relm.State): boolean

---@alias Relm.Element.MessageHandlerWrapper fun(me: Relm.Handle, payload: Relm.MessagePayload, props: Relm.Props, state?: Relm.State, base_handler: Relm.Element.MessageHandlerDefinition): boolean

---@alias Relm.Element.StateDefinition fun(initial_props: Relm.Props): Relm.State

---@alias Relm.NodeFactory fun(props?: Relm.Props, children?: Relm.MaybeNode[]): Relm.Node

---@alias Relm.Element.QueryHandlerDefinition fun(me: Relm.Handle, payload: Relm.MessagePayload, props: Relm.Props, state?: Relm.State): boolean, Relm.QueryResponse?, Relm.QueryTag?

--------------------------------------------------------------------------------
-- INTERNAL TYPES AND GLOBALS
--------------------------------------------------------------------------------

---Registry of all elt types defined in this Relm instance.
---MP SAFETY: safe if populated before on_load (no cond. registration)
---@type table<string, Relm.ElementDefinition>
local registry = {}

---@class (exact) Relm.Internal.Root
---@field public id uint The id of the root.
---@field public data_version int The data version this root was created with. Used to detect when a root was created with an incompatible version of Relm and should be destroyed.
---@field public container_element LuaGuiElement The element the root was rendered into.
---@field public name_in_container? string `root_element` name within the `container_element` children set.
---@field public root_element LuaGuiElement The rendered root element.
---@field public reg_num uint64 The registration number returned by `script.register_on_object_destroyed` for the root element, used to detect when the root element is destroyed.
---@field public player_index int The player index of the owning player of the root element.
---@field public vtree_root Relm.Internal.VNode The root of the virtual tree.
---@field public root_element_type string Relm element type used to render the root
---@field public root_props Relm.Props The properties used to render the root
---@field public index_to_vnode table<int, Relm.Internal.VNode> Map from elem indices to the vnodes that own them.

---@class (exact) Relm.Internal.Storage
---@field public roots table<int, Relm.Internal.Root> Map from root ids to root data.
---@field public root_counter int Counter for generating new root ids.
---@field public reg_num_map table<uint64, int> Map from `script.register_on_object_destroyed` registration numbers to root ids, used to detect when a root element is destroyed.

---Internal representation of a vtree node. This is stored in state.
---@class (exact) Relm.Internal.VNode
---@field public type string The type of this node.
---@field public state? Relm.State
---@field public children? Relm.Internal.VNode[]
---@field public elem? LuaGuiElement The Lua element this node maps to, if a real element.
---@field public index? uint Index in parent node
---@field public parent? Relm.Internal.VNode Parent of this node.
---@field public root_id Relm.RootId Contains the root id of the vtree containing this node.
---@field [uint] any Hook state vectors.

---@class (exact) Relm.Internal.PaintContext
---@field index uint? Current real child being examined. `nil` if rendering a root.
---@field elem LuaGuiElement Gui element we're rendering into (PARENT)
---@field rendered_elem? LuaGuiElement If the target child element was already rendered and we have a reference to it, that reference.
---@field root_id Relm.RootId
---@field structure_changed boolean? `true` if something was create or destroyed in this context during the paint op.
---@field ref? fun(elem: LuaGuiElement|nil) Ref callback from vpaint to notify of the created element in this context.
---@field assign_name? string If given, the name to assign to the created element in this context.

---Map from vnodes to last rendered props
---MP SAFETY: repopulated `on_load` by full hydration
---@type table<Relm.Internal.VNode, Relm.Props>
local vprops = setmetatable({}, { __mode = "k" })

---Map from vnodes to hook transient data
---MP SAFETY: repopulated `on_load` by full hydration
---@type table<Relm.Internal.VNode, table<uint, any>>
local vhooks_transient = setmetatable({}, { __mode = "k" })

---Map from vnodes to hook cleanup functions
---MP SAFETY: repopulated `on_load` by full hydration
---@type table<Relm.Internal.VNode, table<uint, fun(state: table?, transient: any?)>>
local vhooks_cleanup = setmetatable({}, { __mode = "k" })

---Map from vnodes to transient data
---MP SAFETY: repopulated `on_load` by full hydration
---@type table<Relm.Internal.VNode, any>
local vnode_transient = setmetatable({}, { __mode = "k" })

local function noop() end

---Structured tracing handler
---MP SAFETY: created on_load, changed only by synced events
---@type fun(level: int, ...)|nil
local strace = nil
local TRACE = 10
local DEBUG = 20
local INFO = 30
local STATS = 40
local WARN = 50
local ERROR = 60

---Unique per-mod key for event listening
local LISTEN_KEY = "__relm_listen_" .. script.mod_name

---Shallowly compare two values for equality. If tables, they are compared
---by key shallowly with `==`.
---@param lhs any
---@param rhs any
---@return boolean
local function shallow_eq(lhs, rhs)
	if type(lhs) ~= "table" or type(rhs) ~= "table" then return lhs == rhs end

	for key, value in pairs(lhs) do
		if rhs[key] ~= value then return false end
	end

	for key in pairs(rhs) do
		if lhs[key] == nil then return false end
	end

	return true
end

-- Forward declarations for mutually recursive functions.
local vmsg
local vapply
local vhydrate

--------------------------------------------------------------------------------
-- INTERNAL TRANSIENT STATE
--------------------------------------------------------------------------------

-- State of hooks during render
-- MP SAFETY: these are all reset in `normalized_render` and are restricted
-- to the context of a Lua callstack.
---Currently hooking node.
---@type Relm.Internal.VNode?
local hook_node = nil
---Current hook number within the node's rendering
local hook_num = 0

---Whether we are in a hydrating render.
local render_is_hydrating = false

---Removed keys on primitive nodes. We must set these to `nil` when
---painting if we reuse the node.
---TODO: this must be reset with render state or it will become MP-unsafe
local removed_keys = setmetatable({}, { __mode = "k" })

-- Render stats
-- MP SAFETY: These are all reset and recounted on a paint cycle, which should
-- be one frame.
local optimae = 0
local pessimae = 0
local elements = 0

-- Side effect and deferred rendering states
-- MULTIPLAYER SAFETY: `enter_barrier` and `exit_barrier` must ALWAYS be
-- called on the same frame, otherwise there will be desyncs.

---Depth to which side effect barriers have been entered. If >0, side effects ---are banned until the outermost barrier is exited.
local barrier_count = 0
---Set of dirty roots that need to be visited on deferred rendering pass.
---Values are further sets of dirty vnodes within that root.
---@type table< Relm.Internal.Root, table<Relm.Internal.VNode, true> >
local dirty_roots = {}
---Set of dead roots to be killed on deferred rendering pass.
---@type table<Relm.Internal.Root, true>
local dead_roots = {}
---`true` if a deferred render is pending.
local pending_render = false
---Side-effects lifted out of render operation
local post_render_effects = {}

---@param effect fun()
local function enqueue_post_render_effect(effect)
	post_render_effects[#post_render_effects + 1] = effect
end

--------------------------------------------------------------------------------
-- VNODES
--------------------------------------------------------------------------------

---Tree search from root to find vnode with given elt.
---@param root Relm.Internal.VNode
---@param elem LuaGuiElement
local function find_vnode(root, elem)
	if not root then return nil end

	if root.elem and (root.elem.index == elem.index) then return root end

	if root.children then
		for i = 1, #root.children do
			local child = root.children[i]
			local result = find_vnode(child, elem)
			if result then return result end
		end
	end

	return nil
end

---Find vnode with given element, using cache if possible.
---@param elt? LuaGuiElement
---@param index? int If given, search for this index in the cache rather than the elt's own index.
local function get_vnode(elt, index)
	if not elt or not elt.valid then return nil end
	local root_id = elt.tags["__relm_root"]
	if not root_id then
		if strace then
			strace(
				ERROR,
				"relm",
				"nonfatal_error",
				"message",
				"get_vnode: ive got no roots (but my home was never on the ground)"
			)
		end
		return nil
	end
	---@type Relm.Internal.Root?
	local root = storage._relm.roots[root_id]
	if not root then
		if strace then
			strace(
				ERROR,
				"relm",
				"nonfatal_error",
				"message",
				"get_vnode: bad root id",
				root_id
			)
		end
		return nil
	end
	---@type Relm.Internal.VNode?
	local vnode = root.index_to_vnode[index or elt.index]
	if vnode then return vnode end
	if index then
		return nil
	else
		error("LOGIC ERROR: relm: Interactive element did not have a cached index.")
	end
end

---@param node? Relm.Node|Relm.Internal.VNode
local function is_primitive(node) return node and node.type == "Primitive" end

--------------------------------------------------------------------------------
-- VTREE RENDERING
--------------------------------------------------------------------------------

---Normalize calls and results of `element.render`
---@param def? Relm.ElementDefinition
---@param element_type? string
---@param props? Relm.Props
---@param state? Relm.State
---@param hook_node_? Relm.Internal.VNode
---@param is_hydrating_? boolean
---@return Relm.Node[]
local function normalized_render(
	def,
	element_type,
	props,
	state,
	hook_node_,
	is_hydrating_
)
	if not def then def = registry[element_type or ""] end
	if not def then
		error("Element type " .. (element_type or "") .. " not found.")
	end
	hook_num = 0
	hook_node = hook_node_
	render_is_hydrating = not not is_hydrating_
	-- TODO: support rendering parameter packs ...
	-- trick: we have to clear render state with a tailcall...
	local rendered_children = def.render(props or {}, state)
	hook_node = nil
	render_is_hydrating = false
	-- Normalize to array
	if not rendered_children then
		rendered_children = {}
	elseif rendered_children.type then
		-- single node, promote to array
		rendered_children = { rendered_children }
	end
	return rendered_children
end

---@param vnode Relm.Internal.VNode
local function vprune(vnode)
	if vnode.children then
		for i = 1, #vnode.children do
			vprune(vnode.children[i])
		end
		vnode.children = nil
	end

	-- Cleanup effects
	local cleanups = vhooks_cleanup[vnode]
	if cleanups then
		local transients = vhooks_transient[vnode]
		for index, cleanup in pairs(cleanups) do
			local hook_state = vnode[index]
			local hook_transient = transients and transients[index]
			enqueue_post_render_effect(
				function() cleanup(hook_state, hook_transient) end
			)
		end
		vhooks_cleanup[vnode] = nil
	end
	if is_primitive(vnode) then
		local props = vprops[vnode]
		if props then
			local on_cleanup = props.on_cleanup
			if on_cleanup then
				enqueue_post_render_effect(function() on_cleanup(vnode, props) end)
			end
		end
	end

	-- Cleanup node data.
	-- NOTE: we may not clear `parent` here because this node may be
	-- reused at the same place in the vtree.
	vprops[vnode] = nil
	vhooks_transient[vnode] = nil
	vnode_transient[vnode] = nil
	vnode.type = nil
	vnode.elem = nil
	vnode.index = nil
	vnode.state = nil
end

---@param vnode Relm.Internal.VNode
---@param render_children Relm.Node[]
local function vapply_children(vnode, render_children)
	-- TODO: when switching to parameter pack, must cleanup and normalize
	-- render result here.
	if not vnode.children then vnode.children = {} end
	local vchildren = vnode.children --[[@as Relm.Internal.VNode[] ]]
	local vindex = 1
	for i = 1, #render_children do
		local rchild = render_children[i]
		if rchild and rchild.type then
			---@type Relm.Internal.VNode?
			local vchild = vchildren[vindex]
			if not vchild then
				---@diagnostic disable-next-line: missing-fields
				vchildren[vindex] = {} --[[@as Relm.Internal.VNode]]
				vchild = vchildren[vindex]
			end
			---@cast vchild Relm.Internal.VNode
			vchild.parent = vnode
			vchild.root_id = vnode.root_id
			vchild.index = vindex
			---@diagnostic disable-next-line: need-check-nil
			vapply(vchild, rchild)
			vindex = vindex + 1
		end
	end
	for i = vindex, #vchildren do
		vprune(vchildren[i])
		vchildren[i] = nil
	end
end

---@param vnode Relm.Internal.VNode
---@param node? Relm.Node
vapply = function(vnode, node)
	if not node then
		if vnode.type then return vprune(vnode) end
		return
	end
	local target_type = node.type
	local target_def = registry[target_type]
	-- If type changing, prune the old node.
	if (not target_def) or target_type ~= vnode.type then vprune(vnode) end
	if not target_def then
		if strace then
			strace(
				WARN,
				"relm",
				"vtree",
				"message",
				"vapply: undefined element type, pruned subtree",
				target_type
			)
		end
		return
	end
	local is_creating = not vnode.type

	-- Compute props and state
	vnode.type = target_type
	local prev_props = vprops[vnode]
	local next_props = node.props
	-- Special handling for primitives
	if prev_props and is_primitive(vnode) then
		local rk = removed_keys[vnode]
		-- We need to know what fields were set to `nil` since last render so
		-- we can poke the factorio fields as well.
		for key, _ in pairs(prev_props) do
			if (not next_props) or (next_props[key] == nil) then
				if not rk then
					removed_keys[vnode] = {}
					rk = removed_keys[vnode]
				end
				rk[#rk + 1] = key
			end
		end
		-- There are issues with modifying string `style`. If attempt to do so
		-- we will pessimize and just rebuild. As a hack, we flag this as if
		-- the `style` was removed.
		if (not next_props) or prev_props.style ~= next_props.style then
			if not rk then
				removed_keys[vnode] = {}
				rk = removed_keys[vnode]
			end
			rk[#rk + 1] = "style"
		end
	else
		removed_keys[vnode] = nil
	end
	vprops[vnode] = next_props
	if is_creating then
		if target_def.state then
			vnode.state = target_def.state(next_props or {})
		end
	end

	-- Render children
	-- TODO: support vchildren parameter pack ...
	return vapply_children(
		vnode,
		normalized_render(
			target_def,
			target_type,
			node.props,
			vnode.state,
			vnode,
			false
		)
	)
end

---Force a vnode to rerender
---@param vnode Relm.Internal.VNode
local function vrender(vnode)
	local props = vprops[vnode]
	if not props then
		if strace then
			strace(
				ERROR,
				"relm",
				"vtree",
				"vnode",
				vnode,
				"message",
				"vrender: no props cached, fallback render with no props (this will almost certainly break things)"
			)
		end
	end
	local target_def = registry[vnode.type]

	return vapply_children(
		vnode,
		normalized_render(target_def, nil, props, vnode.state, vnode, false)
	)
end

local function vhydrate_children(vnode, render_children)
	-- TODO: support rendering via ... parameter packs
	local vchildren = vnode.children --[[@as Relm.Internal.VNode[] ]]
	local nrchildren = #render_children
	if #vchildren ~= nrchildren then
		if strace then
			strace(
				ERROR,
				"relm",
				"hydrate",
				"message",
				"vhydrate: child count mismatch",
				vnode.type,
				#vchildren,
				nrchildren
			)
		end
	end
	local vindex = 1
	for i = 1, nrchildren do
		local rchild = render_children[i]
		local vchild = vchildren[vindex]
		if rchild and next(rchild) and vchild then
			---@diagnostic disable-next-line: need-check-nil
			vhydrate(vchild, render_children[i])
			vindex = vindex + 1
		end
	end
end

---Special rendering mode that only hydrates prop cache.
---@param vnode Relm.Internal.VNode
---@param node? Relm.Node
vhydrate = function(vnode, node)
	-- TODO: any of these conditions will break all relm guis after a save/rl
	-- how to best notify user?
	-- TODO: we should probably panic by destroying the associated root altogether which is most likely the correct behavior.
	if not node or not vnode or not node.props or node.type ~= vnode.type then
		if strace then
			strace(
				ERROR,
				"relm",
				"hydrate",
				"vnode",
				vnode,
				"node",
				node,
				"message",
				"mismatch between vnode and node while hydrating"
			)
		end
		return
	end
	local def = registry[vnode.type]
	if not def then
		if strace then
			strace(
				WARN,
				"relm",
				"hydrate",
				"vnode",
				vnode,
				"undefined node type, probably an uninstalled mod, skipping hydration",
				node.type
			)
		end
		return
	end
	-- Restore props
	vprops[vnode] = node.props
	return vhydrate_children(
		vnode,
		normalized_render(def, nil, node.props, vnode.state, vnode, true)
	)
end

---@param vnode Relm.Internal.VNode
local function vget_props(vnode) return vprops[vnode] end

--------------------------------------------------------------------------------
-- PAINTING
--------------------------------------------------------------------------------

---Destroy target element in this context (not necessarily the
---current element.)
---@param context Relm.Internal.PaintContext
---@param elem LuaGuiElement
local function vpaint_element_destroy(context, elem)
	local root = storage._relm.roots[context.root_id] --[[@as Relm.Internal.Root]]
	root.index_to_vnode[elem.index] = nil
	elem.destroy()
	context.structure_changed = true
end

---@param context Relm.Internal.PaintContext
local function vpaint_context_destroy(context)
	local elem = context.elem
	if elem and elem.valid then
		if context.rendered_elem then
			vpaint_element_destroy(context, context.rendered_elem)
			if context.ref then context.ref(nil) end
		elseif context.index then
			local child = elem.children[context.index]
			if child then return vpaint_element_destroy(context, child) end
		end
	end
end

---@param context Relm.Internal.PaintContext
---@param props Relm.Props
local function vpaint_context_create(context, props)
	local elem = context.elem
	if elem and elem.valid then
		-- Assemble props valid for `add`ing.
		local addable_props = {}
		for k, v in pairs(props) do
			if APPLICABLE_KEYS[k] or CREATE_KEYS[k] then addable_props[k] = v end
		end
		-- Special handling for textboxes; treat them like React "uncontrolled"
		-- components and allow initial text to be specified but then let
		-- Factorio do the rest.
		if
			props["initial_text"]
			and (
				addable_props.type == "text-box" or addable_props.type == "textfield"
			)
		then
			addable_props.text = props["initial_text"]
		end

		-- Create
		local new_elem
		if context.assign_name then
			addable_props.name = context.assign_name
		else
			addable_props.index = context.index
		end

		-- XXX: TYPES: FMTK LuaGuiElement add_param bug
		new_elem = elem.add(addable_props)
		-- Entities for entity-preview can only be set after creation.
		if props.entity and props.entity.valid then
			new_elem.entity = props.entity
		end
		-- Inherit __relm_root
		local tags = new_elem.tags
		tags["__relm_root"] = context.root_id
		new_elem.tags = tags

		if context.ref then context.ref(new_elem) end

		context.structure_changed = true
		if context.index then context.index = context.index + 1 end
		return new_elem
	end
end

---@param context Relm.Internal.PaintContext
---@param props Relm.Props
---@param vnode Relm.Internal.VNode
local function vpaint_context_diff(context, props, vnode)
	local elem
	if context.rendered_elem then
		elem = context.rendered_elem
	elseif context.index then
		elem = context.elem.children[context.index]
	end
	if not elem then
		if props and props.type then
			return vpaint_context_create(context, props), true
		end
		return nil, false
	end
	if not props or not vnode or not props.type then
		return vpaint_context_destroy(context), true
	end

	-- Rebuild node if needed.
	local needs_rebuild = false
	local rk = removed_keys[vnode]
	if elem.type ~= props.type then
		needs_rebuild = true
	elseif vnode.elem ~= elem then
		-- Pessimize if new vnode
		-- selene: allow(if_same_then_else)
		needs_rebuild = true
	elseif rk then
		-- Factorio doesn't support deleting style keys; if any style key
		-- was deleted, just rebuild
		for i = 1, #rk do
			local key = rk[i]
			if (key == "style") or STYLE_KEYS[key] then
				needs_rebuild = true
				removed_keys[vnode] = nil
				break
			end
		end
	end
	if needs_rebuild then
		vpaint_context_destroy(context)
		return vpaint_context_create(context, props), true
	end

	-- No diff needed, increment context index
	if context.index then context.index = context.index + 1 end
	return elem, false
end

---@param elem LuaGuiElement
local function vpaint_fix_tabs(elem)
	-- Tabbed panes, or T-PAINs as I call them, are extremely annoying.
	-- Algorithm here is to collect the first `n` children who are tabs
	-- and match them in order with the first `m` non-tab children.
	-- `min(m,n)` tabs will be created and the rest of the children
	-- will be left alone.
	local children = elem.children
	local tabs = {}
	local non_tabs = {}
	for i = 1, #children do
		local child = children[i]
		if child.type == "tab" then
			tabs[#tabs + 1] = child
		else
			non_tabs[#non_tabs + 1] = child
		end
	end
	elem.remove_tab()
	local ntabs = min(#tabs, #non_tabs)
	for i = 1, ntabs do
		elem.add_tab(tabs[i], non_tabs[i])
	end
end

---@param vnode Relm.Internal.VNode? Node tree to paint
---@param context Relm.Internal.PaintContext Context within parent primitive node
---@param same boolean? If true, the vnode type is known to be the same as the last paint. Used in repainting.
local function vpaint(vnode, context, same)
	-- Iterate through virtual parents
	while vnode and not is_primitive(vnode) do
		local vchildren = vnode.children
		local nvchildren = #vchildren
		if not vchildren or nvchildren == 0 then
			break
		elseif nvchildren == 1 then
			vnode = vchildren[1]
		else
			-- Use tail recursion
			for i = 1, nvchildren - 1 do
				vpaint(vchildren[i], context)
			end
			return vpaint(vchildren[nvchildren], context)
		end
	end
	-- If we haven't reached a primitive node, don't paint.
	if not is_primitive(vnode) then return end
	---@cast vnode Relm.Internal.VNode

	local props = vprops[vnode]
	if not props then
		if strace then
			strace(
				ERROR,
				"relm",
				"paint",
				"vnode",
				vnode,
				"message",
				"primitive has no props, skipping paint"
			)
		end
		return
	end

	local elem_changed = false
	if not same then
		vnode.elem, elem_changed = vpaint_context_diff(context, props, vnode)
	else
		if not vnode.elem then
			if strace then
				strace(
					ERROR,
					"relm",
					"paint",
					"message",
					"vpaint: repainting a vnode that was never painted",
					props.type
				)
			end
			return
		end
	end

	-- Stats
	elements = elements + 1
	if elem_changed then
		pessimae = pessimae + 1
	else
		optimae = optimae + 1
	end

	local elem = vnode.elem --[[@as LuaGuiElement]]
	if not elem then
		-- elem destroyed by diff
		return
	end
	if not elem.valid then
		if strace then
			strace(
				ERROR,
				"relm",
				"paint",
				"vnode",
				vnode,
				"props",
				props,
				"message",
				"vnode.elem was invalid, perhaps destroyed by external forces"
			)
		end
		vnode.elem = nil
		return
	end

	-- Apply props
	for key, value in pairs(props) do
		-- TODO: `style.column_alignments`
		if STYLE_KEYS[key] then
			elem.style[key] = value
		elseif APPLICABLE_KEYS[key] then
			if key == "entity" then
				-- Entities for entity-preview have to be validated due to
				-- asynchrony.
				if value.valid then elem.entity = value end
			else
				-- Proper typing is too complex here. We know it's an applicable key
				-- so just assume the type is right.
				---@diagnostic disable-next-line: assign-type-mismatch
				elem[key] = value
			end
		end
	end
	-- Remove nil'd keys if the elem didn't change
	local rk = removed_keys[vnode]
	if rk then
		if not elem_changed then
			for i = 1, #rk do
				local key = rk[i]
				if APPLICABLE_KEYS[key] then elem[key] = nil end
			end
		end
		removed_keys[vnode] = nil
	end

	local has_ref = (type(props.ref) == "function")
	local has_manual_paint = (type(props.manual_paint) == "function")
	local has_listen = not not props.listen
	local should_index = has_listen or has_manual_paint

	-- Index node if needed
	if should_index then
		-- TODO: this is a bit ugly...
		local root = storage._relm.roots[context.root_id] --[[@as Relm.Internal.Root]]
		root.index_to_vnode[elem.index] = vnode
	else
		local root = storage._relm.roots[context.root_id] --[[@as Relm.Internal.Root]]
		root.index_to_vnode[elem.index] = nil
	end

	-- Apply tags
	local tags = elem.tags
	if has_listen then
		tags[LISTEN_KEY] = elem.index
	elseif tags[LISTEN_KEY] then
		tags[LISTEN_KEY] = nil
	end
	elem.tags = tags

	-- Handle `ref`s
	if has_ref then props.ref(vnode.elem, vnode) end

	if has_manual_paint then
		-- Manual painted nodes are responsible for painting their children, so we don't recurse.
		local root_id = context.root_id
		local index = vnode.elem.index
		local function get_event_tags()
			return {
				__relm_root = root_id,
				[LISTEN_KEY] = index,
			}
		end
		return props.manual_paint(vnode.elem, props, get_event_tags)
	else
		-- Handle children
		local vchildren = vnode.children or EMPTY
		if #vchildren > 0 then
			---@type Relm.Internal.PaintContext
			local child_context = {
				elem = elem,
				index = 1,
				root_id = context.root_id,
			}
			for i = 1, #vchildren do
				vpaint(vchildren[i], child_context)
			end
			-- Prune children beyond those rendered.
			local echildren = elem.children
			for i = child_context.index, #echildren do
				vpaint_element_destroy(context, echildren[i])
			end
			if
				elem.type == "tabbed-pane"
				and child_context
				and child_context.structure_changed
			then
				vpaint_fix_tabs(elem)
			end
		else
			local echildren = elem.children
			for i = 1, #echildren do
				vpaint_element_destroy(context, echildren[i])
			end
			if elem.type == "tabbed-pane" then elem.remove_tab() end
		end
	end
end

---@param vnode Relm.Internal.VNode? Node tree to paint
---@param context Relm.Internal.PaintContext Context within parent primitive node
---@param same boolean? If true, the vnode type is known to be the same as the last paint. Used in repainting.
local function vpaint_stats(vnode, context, same)
	optimae = 0
	pessimae = 0
	elements = 0
	vpaint(vnode, context, same)
	if strace then
		strace(
			STATS,
			"relm",
			"paint_stats",
			"elements",
			elements,
			"reused",
			optimae,
			"rebuilt",
			pessimae
		)
	end
end

---Determine if a node is part of a tree with a valid rendered root.
---If not, destroy the whole root.
---@param vnode Relm.Internal.VNode
---@return Relm.Internal.Root? root The validated root for this vnode, or `nil` if there's a structure problem.
local function vcheckroot(vnode)
	while vnode and vnode.parent do
		vnode = vnode.parent
	end
	if (not vnode) or not vnode.root_id then
		if strace then
			strace(
				ERROR,
				"relm",
				"vtree",
				"vnode",
				vnode,
				"message",
				"vnode was traced to an improper root"
			)
		end
		return nil
	end
	local root = storage._relm.roots[vnode.root_id] --[[@as Relm.Internal.Root]]
	if (not root) or (root.vtree_root ~= vnode) then
		if strace then
			strace(
				ERROR,
				"relm",
				"vtree",
				"vnode",
				vnode,
				"stored_root",
				root,
				"message",
				"root vnode does not match equivalent root in storage"
			)
		end
		return nil
	end
	if root.root_element and root.root_element.valid then
		return root
	else
		if strace then
			strace(
				ERROR,
				"relm",
				"vtree",
				"vnode",
				vnode,
				"message",
				"root vnode doesn't have a rendered element and is being aggressively pruned"
			)
		end
		lib.root_destroy(vnode.root_id)
		return nil
	end
end

---Repaint a node. Type of `vnode` MUST be the same as its previous paint.
---This does not apply to its children.
---@param vnode Relm.Internal.VNode
local function vrepaint(vnode)
	vrender(vnode)
	-- Must paint from primitive ancestor
	while vnode and vnode.parent and not is_primitive(vnode) do
		vnode = vnode.parent
	end
	if vnode then
		-- Repainting something without an elem is suspicious.
		-- Check for dead roots.
		local elem = vnode.elem
		local is_root = not vnode.parent
		local root = nil
		if not elem or is_root then
			root = vcheckroot(vnode)
			if not root then return end
		end
		if is_root and root then
			vpaint_stats(vnode, {
				elem = root.container_element,
				root_id = root.id,
				rendered_elem = root.root_element,
				ref = function(elt)
					if elt then root.root_element = elt end
				end,
				assign_name = root.name_in_container,
			})
		elseif elem and elem.valid then
			vpaint_stats(vnode, {
				elem = elem,
				index = 1,
				root_id = elem.tags["__relm_root"] --[[@as integer]],
			}, true)
		elseif strace then
			strace(
				ERROR,
				"relm",
				"paint",
				"vnode",
				vnode,
				"message",
				"request to repaint a node that was never painted"
			)
		end
	else
		if strace then
			strace(
				ERROR,
				"relm",
				"paint",
				"message",
				"repaint found no repaintable parent"
			)
		end
	end
end

--------------------------------------------------------------------------------
-- SIDE EFFECTS AND DEFERRED RENDERING
--------------------------------------------------------------------------------

local function enter_side_effect_barrier() barrier_count = barrier_count + 1 end

local function exit_side_effect_barrier() barrier_count = barrier_count - 1 end

local function is_in_side_effect_barrier() return (barrier_count > 0) end

local function run_post_render_effects()
	for i = #post_render_effects, 1, -1 do
		post_render_effects[i]()
		post_render_effects[i] = nil
	end
end

local INVISIBLE_LINE = {
	color = { 0, 0, 0, 0 },
	width = 0,
	from = { 0, 0 },
	to = { 0, 0 },
	surface = 1,
}

local function defer_render()
	if pending_render then return end
	pending_render = true
	local obj = rendering.draw_line(INVISIBLE_LINE)
	local rn = script.register_on_object_destroyed(obj)
	local relm_state = storage._relm
	relm_state.deferred_rn = rn
	obj.destroy()
end

---@param dirty_nodes table<Relm.Internal.VNode, true>
---@param node Relm.Internal.VNode
local function recursive_clean(dirty_nodes, node)
	dirty_nodes[node] = nil

	for _, child in pairs(node.children or EMPTY) do
		recursive_clean(dirty_nodes, child)
	end
end

---@param node Relm.Internal.VNode
local function defer_render_for_node(node)
	local relm_state = storage._relm
	local root = relm_state.roots[node.root_id] --[[@as Relm.Internal.Root? ]]
	if not root then return end
	local dirty_nodes = dirty_roots[root]
	if not dirty_nodes then
		dirty_nodes = {}
		dirty_roots[root] = dirty_nodes
	end

	-- If I or one of my parents is already dirty, no need to do anything.
	local parent = node
	while parent do
		if dirty_nodes[parent] then return end
		parent = parent.parent
	end

	-- Mark me as dirty
	dirty_nodes[node] = true

	-- Remove any children from dirty as they will be painted with me.
	for _, child in pairs(node.children or EMPTY) do
		recursive_clean(dirty_nodes, child)
	end

	defer_render()
end

local function deferred_render()
	local relm_state = storage._relm

	enter_side_effect_barrier()

	-- Kill dead roots
	for root, _ in pairs(dead_roots) do
		-- Don't try to repaint dead roots
		dirty_roots[root] = nil
		-- Kill the virtual root
		vprune(root.vtree_root)
		-- Destroy the rendered root element and all children
		local root_element = root.root_element
		if root_element and root_element.valid then root_element.destroy() end
		-- Quash the state
		relm_state.roots[root.id] = nil
		if relm_state.reg_num_map and root.reg_num then
			relm_state.reg_num_map[root.reg_num] = nil
		end
		dead_roots[root] = nil
	end

	-- Rerender dirty roots
	for root, dirty_nodes in pairs(dirty_roots) do
		for node in pairs(dirty_nodes) do
			vrepaint(node)
		end
		dirty_roots[root] = nil
	end

	exit_side_effect_barrier()
	pending_render = false
	run_post_render_effects()
end

---@param vnode Relm.Internal.VNode
---@param state Relm.State?
local function vstate(vnode, state)
	if is_in_side_effect_barrier() then
		error("relm: Side effects are not allowed during rendering.")
	end
	vnode.state = state
	return defer_render_for_node(vnode)
end

local function vimpl_msg_or_query(vnode, payload, base_key, prop_key)
	if not vnode then return end
	local ty = vnode.type
	if not ty then return end
	local target_def = registry[ty]
	local base_handler = target_def and target_def[base_key]
	local props = vprops[vnode]
	local wrapper = props and props[prop_key]
	if wrapper then
		return wrapper(
			vnode --[[@as Relm.Handle]],
			payload,
			props,
			vnode.state,
			base_handler
		)
	elseif base_handler then
		return base_handler(
			vnode --[[@as Relm.Handle]],
			payload,
			props,
			vnode.state
		)
	end
	return false
end

---@param vnode Relm.Internal.VNode
---@param payload Relm.SendMessagePayload
vmsg = function(vnode, payload)
	payload.propagation_mode = "unicast"
	return vimpl_msg_or_query(vnode, payload, "message", "message_handler")
end

---@param vnode Relm.Internal.VNode
---@param	payload Relm.SendMessagePayload
---@param resent boolean?
local function vmsg_bubble(vnode, payload, resent)
	payload.propagation_mode = "bubble"
	---@diagnostic disable-next-line: assign-type-mismatch
	if resent == true then vnode = vnode.parent end
	while vnode and vnode.type do
		local result =
			vimpl_msg_or_query(vnode, payload, "message", "message_handler")
		if result then return end
		---@diagnostic disable-next-line: assign-type-mismatch
		vnode = vnode.parent
	end
end

local function vmsg_broadcast_impl(vnode, payload, resent)
	if vnode and vnode.type then
		if not resent then
			if vimpl_msg_or_query(vnode, payload, "message", "message_handler") then
				return
			end
		end
		local children = vnode.children
		if children then
			for i = 1, #children do
				vmsg_broadcast_impl(children[i], payload)
			end
		end
	end
end

---@param vnode Relm.Internal.VNode
---@param payload Relm.SendMessagePayload
---@param resent boolean?
local function vmsg_broadcast(vnode, payload, resent)
	payload.propagation_mode = "broadcast"
	return vmsg_broadcast_impl(vnode, payload, resent)
end

--------------------------------------------------------------------------------
-- HOOK PRIMITIVES
--------------------------------------------------------------------------------

---@return Relm.Internal.VNode hook_node The current hook node. Should be passed to hook primitives to associate them with the correct node.
---@return int hook_id The id of this hook in the current render. Can be used to associate this hook to external data.
---@return table? state The hook state object, or `nil` if `wants_state` is falsy
local function setup_hook()
	if not hook_node then
		error("relm: hook called outside of render function")
	end
	hook_num = hook_num + 1
	local node = hook_node --[[@as Relm.Internal.VNode]]
	return node, hook_num, node[hook_num]
end

---@param node Relm.Internal.VNode
---@param hook_id integer
local function set_hook_state(node, hook_id, state)
	if render_is_hydrating then
		error(
			"relm: attempt to set hook state during hydration was detected. This is not allowed because hydration may run during `on_load` where state manipulation is forbidden."
		)
	end
	node[hook_id] = state
end

local function get_hook_state(node, hook_id) return node[hook_id] end

---@param node Relm.Internal.VNode
---@param hook_id integer
---@param fn? fun(state: table?, transient: any?)
local function set_hook_cleanup(node, hook_id, fn)
	local cleanup = vhooks_cleanup[node]
	if (not cleanup) and fn then
		cleanup = {}
		vhooks_cleanup[node] = cleanup
	end
	if cleanup then cleanup[hook_id] = fn end
end

---@param node Relm.Internal.VNode
---@param hook_id integer
---@return fun(state: table?, transient: any?)? cleanup Cleanup function for this hook, or `nil` if no cleanup was registered
local function get_hook_cleanup(node, hook_id)
	local cleanup = vhooks_cleanup[node]
	if cleanup then return cleanup[hook_id] end
end

---@param node Relm.Internal.VNode
---@param hook_id integer
---@param transient_value any
local function set_hook_transient(node, hook_id, transient_value)
	local hooks = vhooks_transient[node]
	if not hooks then
		hooks = {}
		vhooks_transient[node] = hooks
	end
	hooks[hook_id] = transient_value
end

local function get_hook_transient(node, hook_id)
	local hooks = vhooks_transient[node]
	if hooks then return hooks[hook_id] end
end

---@param node Relm.Internal.VNode
---@param transient_value any
local function set_node_transient(node, transient_value)
	vnode_transient[node] = transient_value
end

---@param node Relm.Internal.VNode
local function get_node_transient(node) return vnode_transient[node] end

--------------------------------------------------------------------------------
-- QUERIES
--------------------------------------------------------------------------------

local function vquery(vnode, payload)
	payload.propagation_mode = "unicast"
	return vimpl_msg_or_query(vnode, payload, "query", "query_handler")
end

local function vquery_bubble(node, payload, resent)
	payload.propagation_mode = "bubble"
	if resent then node = node.parent end
	while node and node.type do
		local handled, result, tag =
			vimpl_msg_or_query(node, payload, "query", "query_handler")
		if handled then return handled, result, tag end
		node = node.parent
	end
	return false
end

---@param node Relm.Internal.VNode
local function vquery_broadcast(node, payload, resent)
	payload.propagation_mode = "broadcast"
	local handled, result, tag
	if not resent then
		handled, result, tag =
			vimpl_msg_or_query(node, payload, "query", "query_handler")
		if handled then return true, result, tag end
	end
	local children = node.children
	if not children or #children == 0 then return false end
	for i = 1, #children do
		local child = children[i]
		handled, result, tag = vquery_broadcast(child, payload)
		if handled then return true, result, tag end
	end
	return false
end

--------------------------------------------------------------------------------
-- FACTORIO EVENT BINDING
--------------------------------------------------------------------------------

---Handle a Factorio gui event.
---@param ev Relm.GuiEventData
local function dispatch(ev)
	local element = ev.element
	if not element then return end
	local tags = element.tags
	local listen_tag = tags[LISTEN_KEY]
	if not listen_tag then return end
	---@cast listen_tag int

	if listen_tag == element.index then
		-- Event targeting a primitive owned by Relm.
		local vnode = get_vnode(element)
		if vnode and vnode.type then
			vmsg_bubble(vnode, { key = "factorio_event", event = ev, name = ev.name })
		end
	else
		-- Event arising from a manual_painted child element
		local vnode = get_vnode(element, listen_tag)
		if vnode and vnode.type then
			vmsg(vnode, {
				key = "manual_child_event",
				event = ev,
				name = ev.name,
				element = element,
				tags = tags,
			})
		end
	end
end
lib.handle_on_gui_event = dispatch

---Utility function to bind all Factorio GUI events to Relm dispatch. Note:
---this will conflict with your own manual GUI event bindings if you
---have any.
function lib.bind_all_gui_events()
	for id in pairs(gui_events) do
		script.on_event(id, dispatch)
	end
end

---Set Relm's event sink. Relm calls this function in the event it needs
---to propagate a Relm event to your mod code.
---@param sink Relm.EventSink
function lib.set_event_sink(sink) __EVENT_SINK__ = sink end

---Restore transient component states.
---This MUST be called by consuming mods during `on_load`
function lib.handle_on_load()
	local relm_storage = storage._relm
	if not relm_storage then return end
	local roots = relm_storage.roots
	for _, root in pairs(roots) do
		vhydrate(
			root.vtree_root,
			{ type = root.root_element_type, props = root.root_props }
		)
	end
end

---Initialize Relm's storage if it doesn't already exist.
function lib.init_storage()
	if not storage._relm then
		-- Lint diagnostic here is ok. We can't disable it because of luals bug.
		storage._relm = { roots = {}, root_counter = 0, reg_num_map = {} } --[[@as Relm.Internal.Storage]]
	end
end

---Consuming mods MUST call this in `on_init` unless using the Core Events
---bindings.
lib.handle_on_init = function() return lib.init_storage() end

local GUI_ELEMENT_TARGET_TYPE = defines.target_type.gui_element
local RENDER_OBJECT_TARGET_TYPE = defines.target_type.render_object

---Consuming mods MUST call this in `on_object_destroyed`.
---@param ev EventData.on_object_destroyed
function lib.handle_on_object_destroyed(ev)
	local ev_type = ev.type
	if ev_type == RENDER_OBJECT_TARGET_TYPE then
		local rn = ev.registration_number
		local relm_state = storage._relm
		if not relm_state then return end
		if relm_state.deferred_rn == rn then
			relm_state.deferred_rn = nil
			deferred_render()
		end
	elseif ev_type == GUI_ELEMENT_TARGET_TYPE then
		local rn = ev.registration_number
		local relm_state = storage._relm
		if not relm_state then return end
		local reg_num_map = relm_state.reg_num_map
		-- Migration may cause reg_num_map to be missing.
		if not reg_num_map then return end
		local id = reg_num_map[rn]
		reg_num_map[rn] = nil
		if id then lib.root_destroy(id) end
	end
end

---Initialize Relm with the Core Events system. Must pass in the top level
---`event` library.
---@param event Core.Lib.Event
function lib.bootstrap_with_core_events(event)
	__EVENT_SINK__ = event --[[@as Relm.EventSink]]

	-- Create storage on startup
	event.bind("on_startup", function()
		-- Lint diagnostic here is ok. We can't disable it because of luals bug.
		storage._relm = { roots = {}, root_counter = 0, reg_num_map = {} } --[[@as Relm.Internal.Storage]]
	end)

	-- Destroy all roots on shutdown.
	event.bind("on_shutdown", function()
		local relm_storage = storage._relm
		if not relm_storage then return end
		local roots = relm_storage.roots
		for id, _ in pairs(roots) do
			lib.root_destroy(id)
		end
	end)

	event.bind("on_load", lib.handle_on_load)

	event.bind(defines.events.on_object_destroyed, lib.handle_on_object_destroyed)

	-- Connect Relm to all Factorio GUI events.
	for id in pairs(gui_events) do
		event.bind(id, dispatch)
	end
end

--------------------------------------------------------------------------------
-- API: FACTORIO GUI EVENTS
--------------------------------------------------------------------------------

---@alias Relm.MessagePayload.FactorioEvent { key: "factorio_event", event: Relm.GuiEventData, name: defines.events }

--------------------------------------------------------------------------------
-- API: ROOTS
--------------------------------------------------------------------------------

---@param start Relm.Internal.VNode?
local function find_first_elem(start)
	while start and not start.elem do
		start = start.children and start.children[1]
	end
	return start and start.elem
end

---Renders a new Relm root element by adding it to the given base element. The
---element will be rendered with the given props, along with an additional
---`root_id` prop reflecting the ID of the newly created Relm root.
---
---@param container_element LuaGuiElement The render result will be `.add`ed to this element. e.g. `player.gui.screen`. MUST NOT be within another Relm tree.
---@param name string? The rendered root will be given this `name` within the `container_element` children.
---@param element_type string Type of Relm element to render at the root. Must have previously been defined with `relm.define_element`.
---@param props Relm.Props Props to pass to the newly created root. Unlike other props in Relm, these MUST be serializable (no functions!) and may not contain `children`.
---@return Relm.RootId? root_id ID of the newly created root.
---@return LuaGuiElement? root_element The root Factorio element.
function lib.root_create(container_element, name, element_type, props)
	if not container_element or not container_element.valid then
		error(
			"relm.root_create: `container_element` must be a valid LuaGuiElement."
		)
	end
	if not element_type or not registry[element_type] then
		error(
			"relm.root_create: Element type " .. (element_type or "") .. " not found."
		)
	end
	if props.children then
		error("relm.root_create: Root props may not contain children.")
	end

	-- Don't allow duplicate root names within the same container.
	if name and container_element[name] then return nil end

	local player_index = container_element.player_index
	local relm_state = storage._relm

	local id = storage._relm.root_counter + 1
	storage._relm.root_counter = id
	props.root_id = id
	props.player_index = player_index

	-- Diagnostics disabled below because of partial-structure assembly.
	---@diagnostic disable-next-line: missing-fields
	local root = {
		id = id,
		data_version = RELM_DATA_VERSION,
		player_index = player_index,
		container_element = container_element,
		name_in_container = name,
		---@diagnostic disable-next-line: missing-fields
		vtree_root = {
			root_id = id,
		},
		root_element_type = element_type,
		root_props = props,
		index_to_vnode = {},
	}
	relm_state.roots[id] = root
	local vtree_root = relm_state.roots[id].vtree_root

	-- Render the entire tree from the root
	enter_side_effect_barrier()
	vapply(vtree_root, { type = element_type, props = props })
	vpaint_stats(vtree_root, {
		elem = container_element,
		root_id = id,
		ref = function(elt) root.root_element = elt end,
		assign_name = name,
	})
	exit_side_effect_barrier()
	run_post_render_effects()

	-- Find the Factorio element that was painted
	local created_elt = root.root_element
	if not created_elt then
		if strace then
			strace(
				ERROR,
				"relm",
				"paint",
				"message",
				"attempt to paint created root resulted in no rendered elements; destroying the root"
			)
		end
		lib.root_destroy(id, true)
		return nil
	end

	local reg_num = script.register_on_object_destroyed(created_elt)
	relm_state.roots[id].reg_num = reg_num
	-- Migration
	if not relm_state.reg_num_map then relm_state.reg_num_map = {} end
	relm_state.reg_num_map[reg_num] = id

	if __EVENT_SINK__ then
		__EVENT_SINK__.raise("relm.root_created", {
			root_id = id,
			element = created_elt,
			player_index = player_index,
		})
	end

	return id, created_elt
end

---Destoys a root and all associated child elements.
---@param id Relm.RootId? The ID of the root.
---@param silent boolean? If `true`, the root will be destroyed without raising the `relm.root_destroyed` event.
---@return boolean success `true` if the root was successfully destroyed, `false` if the root was not destroyed (did not exist or was already destroyed)
function lib.root_destroy(id, silent)
	if not id then return false end
	local relm_state = storage._relm
	if not relm_state then return false end
	local root = relm_state.roots[id]
	if not root then return false end
	if dead_roots[root] then return false end
	dead_roots[root] = true
	if not silent then
		local ev = {
			root_id = id,
			player_index = root.player_index,
			last_props = root.root_props,
		}
		if root.root_element and root.root_element.valid then
			ev.element = root.root_element
		end
		if __EVENT_SINK__ then __EVENT_SINK__.raise("relm.root_destroyed", ev) end
	end
	defer_render()
	return true
end

---Returns a handle to the root element with the given ID.
---@param id Relm.RootId?
---@return Relm.Handle? handle A handle to the root element.
function lib.root_handle(id)
	if not id then return nil end
	local root = storage._relm.roots[id]
	if root then
		return root.vtree_root --[[@as Relm.Handle]]
	end
end

---Given a `LuaGuiElement`, attempt to find a Relm handle to its associated
---Relm element.
---@param element? LuaGuiElement The element to search for.
---@return Relm.Handle? handle A handle to the node associated with the element.
function lib.get_handle(element)
	return get_vnode(element) --[[@as Relm.Handle]]
end

---Given a `LuaGuiElement`, get the Relm root it is owned by if any.
---@param element LuaGuiElement?
---@return Relm.RootId?
function lib.get_root_id(element)
	if element and element.valid then
		return element.tags.__relm_root --[[@as Relm.RootId?]]
	end
end

---Given a Relm root ID, get the root `LuaGuiElement` if it exists.
---@param id Relm.RootId?
---@return LuaGuiElement? root_element
function lib.get_root_element(id)
	local root = storage._relm.roots[id or ""] --[[@as Relm.Internal.Root? ]]
	if root then return root.root_element end
end

---Given a handle to a Relm element, get the `LuaGuiElement` associated with
---its root.
---@param handle Relm.Handle
---@return LuaGuiElement? root_element
function lib.get_root_element_from_handle(handle)
	local vnode = handle --[[@as Relm.Internal.VNode]]
	local root = storage._relm.roots[vnode.root_id or -1]
	if root then return root.root_element end
end

---Iterate all Relm roots. This is an "escape valve" for debugging and
---dealing with edge cases and you should carefully evaluate why you are
---using it. Do not use this to paint windows.
---@param handler fun(handle: Relm.Handle, root_id: Relm.RootId, element: LuaGuiElement?, player_index: uint)
function lib.root_foreach(handler)
	local relm_storage = storage._relm
	if not relm_storage then return end
	local roots = relm_storage.roots
	for _, root in pairs(roots) do
		handler(
			root.vtree_root --[[@as Relm.Handle]],
			root.id,
			root.root_element,
			root.player_index
		)
	end
end

---Destroy all Relm roots. This is primarily useful in migrations where stored
---Relm state may be invalid due to other data changes.
function lib.destroy_all_roots()
	local relm_storage = storage._relm
	if not relm_storage then return end
	local roots = relm_storage.roots
	for id, _ in pairs(roots) do
		lib.root_destroy(id)
	end
end

--------------------------------------------------------------------------------
-- API: ELEMENTS
--------------------------------------------------------------------------------

---Determine if a `Relm.Handle` refers to a valid element of the vtree.
---@param handle Relm.Handle?
function lib.is_valid(handle)
	if type(handle) ~= "table" then
		return false
	else
		return not not (handle --[[@as Relm.Internal.VNode]]).type
	end
end

---Define a new re-usable Relm element type.
---@param definition Relm.ElementDefinition
---@return Relm.NodeFactory #A factory function that creates a node of this type.
function lib.define_element(definition)
	if not definition.name then error("Element definition must have a name.") end
	if registry[definition.name] then
		error("Element " .. definition.name .. " already defined.")
	end
	if not definition.render then
		error("Element " .. definition.name .. " must have a render function.")
	end

	registry[definition.name] = definition
	local name = definition.name
	if definition.factory then
		-- If a factory is provided, use it.
		return definition.factory
	else
		return function(props, children)
			props = props or {}
			if children then props.children = children end
			return {
				type = name,
				props = props,
			}
		end
	end
end

---Define a new Relm element.
---@param name string The name of the element. Must be unique across all Relm element definitions.
---@param render Relm.RenderFn The render function for this element.
---@return Relm.NodeFactory #A factory function that creates a node of this type.
function lib.define(name, render)
	return lib.define_element({
		name = name,
		render = render,
	})
end

---Generate a node for an element of the given named type with the given
---props. Returns `nil` if the type was invalid.
---@param element_type string The type of element to create.
---@param props Relm.Props The properties to pass to the element.
---@return Relm.Node? node The generated node, or `nil` if the type was invalid.
function lib.element(element_type, props)
	if not element_type or not registry[element_type] then return nil end
	props = props or {}
	return {
		type = element_type,
		props = props,
	}
end

---A primitive element whose props are passed directly to Factorio GUI
---for rendering.
lib.Primitive = lib.define(
	"Primitive",
	function(props) return props.children end
)

--------------------------------------------------------------------------------
-- API: SIDE EFFECTS
--------------------------------------------------------------------------------

---Repaint the Relm element with the given `handle`.
---@param handle Relm.Handle
function lib.paint(handle)
	if is_in_side_effect_barrier() then
		error("relm: Side effects are not allowed during rendering.")
	end

	---@diagnostic disable-next-line: cast-type-mismatch
	---@cast handle Relm.Internal.VNode
	if handle and handle.type then return defer_render_for_node(handle) end
end

---Change the state of the Relm element with the given `handle`.
---@param handle Relm.Handle
---@param state? table|number|string|int|boolean|fun(current_state: Relm.State): Relm.State The new state, or an update function of the current state.
---@return nil
function lib.set_state(handle, state)
	---@diagnostic disable-next-line: cast-type-mismatch
	---@cast handle Relm.Internal.VNode
	if handle and handle.type then
		if type(state) == "function" then state = state(handle.state) end
		return vstate(handle, state)
	end
end

---Send a message directly to the Relm element with the given `handle`.
---If the target element does not handle the message, it will not propagate.
---@param handle Relm.Handle?
---@param msg Relm.SendMessagePayload
function lib.msg(handle, msg)
	if handle then
		return vmsg(handle --[[@as Relm.Internal.VNode]], msg)
	end
end

---Send a message to the Relm element with the given `handle`, which if not
---handled will bubble up the vtree to the root.
---@param handle Relm.Handle?
---@param msg Relm.SendMessagePayload
---@param resent boolean? If `true`, resends ignoring the current node. Useful for nodes that transform messages going through them.
function lib.msg_bubble(handle, msg, resent)
	if handle then
		return vmsg_bubble(handle --[[@as Relm.Internal.VNode]], msg, resent)
	end
end

---Send a message to the Relm element with the given `handle`, which if not
---handled will be broadcast to all children.
---@param handle Relm.Handle?
---@param msg Relm.SendMessagePayload
---@param resent boolean? If `true`, resends ignoring the current node. Useful for nodes that transform messages going through them.
function lib.msg_broadcast(handle, msg, resent)
	if handle then
		return vmsg_broadcast(handle --[[@as Relm.Internal.VNode]], msg, resent)
	end
end

---Create a reactive state that will persist across renders and cause the
---element to re-render when state changes. The value of the state will be
---written to `storage` and must be serializable.
---
---@generic T
---@param initial_state T|fun(props: Relm.Props): T The initial state, or a function that generates the initial state from the props. Note that this value is only evaluated when the state is created. To change the state later, you must use the `set_state` function.
---@return T state The current state value.
---@return fun(new_state: T|fun(current_state: T): T) set_state A function that updates the state. This accepts either a new state value or an update function that takes the current state and returns the new state.
function lib.use_state(initial_state)
	local node, index, state = setup_hook()

	-- Set initial state if absent. We can't do this on a hydrating render as
	-- it would cause writes to `storage`.
	if (not render_is_hydrating) and (state == nil) then
		if type(initial_state) == "function" then
			initial_state = initial_state(vget_props(node))
		end
		state = { initial_state }
		set_hook_state(node, index, state)
	end

	-- Create setter. This needs to be done on rehydration as it is a
	-- closure.
	local setter = get_hook_transient(node, index)
	if not setter then
		setter = function(new_state)
			local _hook_state = get_hook_state(node, index)
			local _state_value = _hook_state and _hook_state[1]
			if type(new_state) == "function" then
				new_state = new_state(_state_value)
			end
			_hook_state[1] = new_state
			if node and node.type then return defer_render_for_node(node) end
		end
		set_hook_transient(node, index, setter)
	end

	return state and state[1], setter
end

---Lift a side effect out of the rendering algorithm. Similar to React's
---`useEffect` hook, this will run the given `callback` and `cleanup` functions
---in the following way:
---
---  - When the element is first created, `callback` will be called with `nil`
---    as the previous effect key, and `cleanup` will be stored.
---  - When the effect key changes as defined by shallow comparison, the
---    previous `cleanup` will be run, `callback` will be run with the previous
---    effect key provided, and the new `cleanup` will be stored.
---  - When the element is destroyed, the last stored `cleanup` will be run.
---
---This function may **only** be called during `render` and **may not** be
---called conditionally.
---@param effect_key Relm.EffectKey The effect key, compared shallowly against the previous to determine if the effect should run. `nil` is NOT a valid effect key.
---@param callback fun(me: Relm.Handle, current_key: Relm.EffectKey, previous_key: Relm.EffectKey?): any Callback that runs on creation or whenever the effect key changes as defined by shallow comparison. Return value will be passed to the next `cleanup` when it runs.
---@param cleanup? fun(previous_callback_return: any) Cleanup that runs on destruction; the previous cleanup will be run when the effect key changes as well.
function lib.use_effect(effect_key, callback, cleanup)
	if effect_key == nil then
		error("relm.use_effect: effect key may not be `nil`")
	end
	local node, index, state = setup_hook()
	local last_effect_key = state and state[1]
	local last_callback_return = state and state[2]
	local last_hook_node = node
	local last_cleanup = get_hook_cleanup(node, index)
	if render_is_hydrating then
		-- Hydrating render, restore cleanup function but do nothing else
		if cleanup then
			set_hook_cleanup(
				node,
				index,
				function() cleanup(last_callback_return) end
			)
		end
	else
		if not state then
			state = {}
			set_hook_state(node, index, state)
		end
		if not shallow_eq(effect_key, last_effect_key) then
			enqueue_post_render_effect(function()
				state[1] = effect_key
				if last_cleanup then last_cleanup() end
				local current_callback_return = callback(
					last_hook_node --[[@as Relm.Handle]],
					effect_key,
					last_effect_key
				)
				state[2] = current_callback_return
				if cleanup then
					set_hook_cleanup(
						last_hook_node,
						index,
						function() cleanup(current_callback_return) end
					)
				else
					set_hook_cleanup(last_hook_node, index, nil)
				end
			end)
		end
	end
end

---Use the result of calling a function. This can be used to lift gamestate
---queries out of the render loop. Hydrating renders will return a memoized
---value from the previous render, and will not call the `calculate` function.
---@param calculate fun(): any A function that calculates an arbitrary value. (The return value of this function is placed in `storage` and must be serializable.)
function lib.use_result(calculate)
	local node, index, last_value = setup_hook()
	if render_is_hydrating then
		return last_value
	else
		last_value = calculate()
		set_hook_state(node, index, last_value)
		return last_value
	end
end

---Returns a handle to the currently-rendering Relm element. This can be used
---to correctly wire up event handlers as closures. NOTE: You MUST NOT cause
---side effects during `render` using this handle.
---@return Relm.Handle handle A handle to the currently-rendering element.
function lib.use_handle()
	if not hook_node then
		error("relm.use_handle: must be called during `render` of a Relm element.")
	end
	return hook_node --[[@as Relm.Handle]]
end

---Hook that creates a persistent serializable reference to a closure.
---@param closure function The closure to reference.
---@return Relm.Handle handle Handle to this element for later use with `invoke_closure`
---@return Relm.Closure closure_ref A reference to the closure that can be stored and used in event handlers.
function lib.use_closure(closure)
	if type(closure) ~= "function" then
		error("relm.use_closure: closure must be a function.")
	end
	local node, index = setup_hook()
	set_hook_transient(node, index, closure)

	-- This is needed due to a stylua bug
	local handle = node --[[@as Relm.Handle]]
	return handle, index --[[@as Relm.Closure]]
end

---Execute a closure previously stored with `use_closure` on the given node.
---@param handle Relm.Handle The node on which the closure was created.
---@param closure_ref Relm.Closure The reference to the closure returned by `use_closure`.
---@param ... any Arguments to pass to the closure.
---@return any result The return value of the closure, if it exists.
function lib.invoke_closure(handle, closure_ref, ...)
	local hooks = vhooks_transient[
		handle --[[@as Relm.Internal.VNode]]
	]
	if not hooks then return end
	local closure = hooks[closure_ref]
	if type(closure) == "function" then return closure(...) end
end

---Hook that associates transient data with the currently rendering node.
---@param data any Arbitrary transient data.
function lib.use_transient(data)
	if not hook_node then
		error("use_transient: Hook must be called during render")
	end
	set_node_transient(hook_node, data)
end

---Get transient data associated with a node.
---@param handle Relm.Handle The node to get transient data from.
---@return any data The transient data associated with the node, or `nil` if no transient data is associated.
function lib.get_transient(handle)
	return get_node_transient(handle --[[@as Relm.Internal.VNode]])
end

--------------------------------------------------------------------------------
-- API: QUERIES
--------------------------------------------------------------------------------

---Send a query to the Relm element with the given `handle`, which if not
---handled, will not propagate.
---@param handle Relm.Handle
---@param payload Relm.MessagePayload
---@return boolean handled Whether the query was handled.
---@return Relm.QueryResponse? result The result of the query, if handled.
function lib.query(handle, payload)
	---@diagnostic disable-next-line: return-type-mismatch
	return vquery(handle --[[@as Relm.Internal.VNode]], payload)
end

---Send a query to the Relm element with the given `handle`, which will
---propagate upward to parents if not handled.
---@param handle Relm.Handle
---@param payload Relm.MessagePayload
---@param resent boolean?
---@return boolean handled Whether the query was handled.
---@return Relm.QueryResponse? result The result of the query, if handled.
function lib.query_bubble(handle, payload, resent)
	return vquery_bubble(handle --[[@as Relm.Internal.VNode]], payload, resent)
end

---Send a query to the Relm element with the given `handle`, which will
---propagate to all children if not handled. Responses from children past
---a split in the vtree will be gathered into a table indexed by either
---child number or `query_tag` if present. `handled` will be true if *any*
---child reached by the propagation reported that it handled the query.
---@param handle Relm.Handle
---@param payload Relm.MessagePayload
---@param resent boolean?
---@return boolean handled Whether the query was handled.
---@return Relm.QueryResponse? result The result of the query, if handled.
function lib.query_broadcast(handle, payload, resent)
	return vquery_broadcast(handle --[[@as Relm.Internal.VNode]], payload, resent)
end

---This element gathers query results from all of its children into a single
---table keyed by either the query tag or the child's numerical index.
lib.Gather = lib.define_element({
	name = "relm.Gather",
	render = function(props) return props.children end,
	---@param me Relm.Internal.VNode
	query = function(me, payload, props)
		if payload.propagation_mode == "broadcast" then
			local children = me.children
			if not children then return true, {}, props.query_tag end
			local nchildren = #children
			if nchildren > 0 then
				local gathered = {}
				for i = 1, nchildren do
					local handled, res, tag = vquery_broadcast(children[i], payload)
					if handled then gathered[tag or i] = res end
				end
				if table_size(gathered) > 0 then
					return true, gathered, props.query_tag
				end
			end
			return true, {}, props.query_tag
		end
		return false
	end,
})

--------------------------------------------------------------------------------
-- API: MISC
--------------------------------------------------------------------------------

function lib.configure(options)
	if type(options) ~= "table" then return end
	if options.strace ~= nil then
		if type(options.strace) == "function" then
			strace = options.strace
		else
			strace = nil
		end
	end
end

---Piggyback on Relm's strace handler. For use only by mods like component
---libraries that would appropriately log into Relm's context.
---@param level int
---@param ... any #An strace message.
function lib.strace(level, ...)
	if strace then return strace(level, ...) end
end

return lib
