--|--------------------------------------------------------------------------------------------------------------------
--| class ElementBuilder
--|
--| part of GuiBuilder
--| usage: KuxGuiLib.require.GuiBuilder.ElementBuilder
--|--------------------------------------------------------------------------------------------------------------------


---@class KuxGuiLib.ElementBuilder
local ElementBuilder = {}
-- automatic handling of style parameters (moved to style and assigned after creation)
-- automatic handling of non add parameters (assigned after creation)

local Dictionary        = KuxCoreLib.require.Dictionary
local Debug             = KuxCoreLib.require.Debug
local ElementStackTrace = require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/ElementStackTrace") or error("Invalid state")
local Gui               = KuxGuiLib.require.Gui
local VGuiElement       = KuxGuiLib.require.VGuiElement
local FunctionUtils     = KuxCoreLib.require.FunctionUtils

local trace = trace or function() end
local add_cache_element = KuxGuiLib.require.GuiElementCache2.add_cache_element
local temp_virtual_elements = {} ---@type {[number]:KuxGuiLib.VGuiElement}

local element_factory_utils = require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/element_factory_utils") --[[@as KuxGuiLib.internal.ElementFactoryUtils]]
local prep = element_factory_utils.prep
local apply = element_factory_utils.apply

---@type table<string, table<string,boolean>> mod_name->view_name->true
local invalid_view_access = Dictionary.create_byStringAndString()

function ElementBuilder.validateChildren(children)
	if(children==nil) then return true end
	local t = type(children)
	if(t~="table") then error("Invalid parameter. 'children' must be a table or nil, but is '"..t.."'") end
	if(#children==0) then return true end
	for i, f in ipairs(children) do
		if(type(f)~="function") then error("Invalid parameter. 'children' must be a table of functions, but element "..i.." is '"..type(f).."'") end
	end
	return true
end

function ElementBuilder.normalizeChildren(args)
	args.children = prep.children(args)
end

---@param args table
---@param name string
---@param value string|number|boolean|table|nil
---<p>a) <code>fun(t, name, value)</code><br/>
---b) <code>fun(t, {name->value})</code></p>
---@overload fun(args:table, name:{[string]: string|number|boolean|table|nil})
function ElementBuilder.patch_tags(args, name, value)
	if args.tags == nil then args.tags = {} end
	if type(name) == "table" then
		for k, v in pairs(name) do args.tags[k] = type(v)=="table" and Table.deepCopy(v) or v end
	else
		args.tags[name] = value
	end
end

function ElementBuilder.patch(args, changes)
	if changes==nil then return end
	for k,v in pairs(changes) do
		if k == "tags" then
			local tags = args.tags or {}                                     --:: RW simple table
			for k,v in pairs(v) do tags[k] = v end
			args.tags = tags
		elseif k == "column_alignments" then                                 --:: R LuaCustomTable[uint → Alignment]
			for k,v in pairs(v) do args.column_alignments[k] = v end
		else
			args[k] = v
		end
	end
end

function ElementBuilder.replace_ui_element(args)
	--{gui.elements.SearchView.elem_type, elem_type = elem_type}
end


---@class KuxGuiLib.ElementBuilder.create.parameters
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field container LuaGuiElement? The container element to add the new element to
---@field mod_name string? The current mod name
---@field view_name string? The current view name (use with createView|addView)
---@field part_name string? The name of the part being added (use with addPart)
---@field creator_name string? The name of the creator, if different from mod_name
---@field localization_section string? The prefix for the localization string
---@field locale string? The users locale
---@field [1] function|nil child
---@field mode "new"|"append"|nil new view or apepend to existing view. defaults to "new" (obsolete)
---@field parent_view_name string? (internal) The parent view name (automatically detected)
---@field clear "auto"|"same"|nil (internal) set by addView or createView
---@field element_stack_trace ElementStackTrace? (internal)
---@field element_index {string: LuaGuiElement|LuaGuiElement[]}? (internal)


---@param container LuaGuiElement
---@param create_children_fnc function|function[]
---@param parameters KuxGuiLib.ElementBuilder.create.parameters
---@return LuaGuiElement
local function create(container, create_children_fnc, parameters)
	--assert(container~=nil, "Invalid Argument. 'container' must not be nil.")
	--assert(type(create_children_fnc)=="function", "Invalid Argument. 'create_children_fnc' must be a function but is '"..type(create_children_fnc).."'.")
	--trace("ElementBuilder.create in "..container.name.." from "..type(create_children_fnc))

	parameters.element_stack_trace = ElementStackTrace.new()
	local list =
		type(create_children_fnc) == "function" and {create_children_fnc} or
		type(create_children_fnc) == "table" and create_children_fnc or
		error("Invalid Argument. 'create_children_fnc' must be a function or a table of functions.")
	local results = {}
	for _, fnc in ipairs(list) do
		assert(type(fnc)=="function", "Invalid Argument. 'create_children_fnc' must be a function or a table of functions. but is "..type(fnc)..": "..serpent.line(fnc).." container: "..container.name)
		local elmt = fnc(container, parameters)
		table.insert(results, elmt)
	end
	return type(create_children_fnc) == "function" and results[1] or results
end


---@param parameters KuxGuiLib.ElementBuilder.create.parameters
---@return LuaGuiElement
---<p>-> createView{container=, view_name=, element_index=, children...}</p>
local function createView_core(parameters)
	local func_name = "createView" --entry point
	assert(parameters ~= nil, "parameters must not be nil")
	local container = parameters.container or error ("container must not be nil")
	local factory = parameters[#parameters] or error("Missing factory")

	parameters.mod_name = parameters.mod_name or script.mod_name
	parameters.view_name = parameters.view_name or ""
	parameters.parent_view_name = parameters.parent_view_name or container.tags.parent_view_name --[[@as string?]]
	parameters.element_index = parameters.element_index or {}
	parameters.element_index[parameters.view_name] = parameters.element_index[parameters.view_name] or {__parent_view_name=parameters.parent_view_name}

	local function fbody()
		if parameters.clear=="auto" then
			if Gui.isToplevel(container) then element_factory_utils.destroy_view(parameters.mod_name, parameters.view_name)
			else container.clear() -- createView called
			end
		elseif parameters.clear=="same" then
			element_factory_utils.destroy_view(parameters.mod_name, parameters.view_name)
		end
		local r = create (container, factory, parameters)
		element_factory_utils.set_tag(r,"parent_view_name",parameters.parent_view_name)
		element_factory_utils.set_path_dic(r,parameters.element_index)
		return r -- avoid tail-call
	end

	local function format_exception(ex)
		local err_msg  = ex.message.."\n"
		local ui_trace = parameters.element_stack_trace:toString() or "<no element trace>"
		local view     = "→ while creating view "..((parameters.view_name or "" ~="") and str(parameters.view_name) or "<unnamed>").. ".\n"
		local at       = "  at "..(ex.caller or "<unknown>").."\n"
		local parent   = parameters.parent_view_name and "    → inside view " .. str(parameters.parent_view_name) .. "\n" or ""
		return err_msg..view..at..parent.."\nUI-Stack-Trace:\n" .. ui_trace .. "\n\nInner Error:\n" .. ex.stack_trace .. "\n"
	end

	local result = call(fbody, format_exception) --[[@as LuaGuiElement]]
	return result
end


---@param parameters KuxGuiLib.ElementBuilder.create.parameters
---@return LuaGuiElement
---<p>-> createView{container=, view_name=, element_index=, children...}</p>
function ElementBuilder.createView(parameters)
	parameters.clear = "auto"
	return createView_core(parameters)
end

---@param parameters KuxGuiLib.ElementBuilder.create.parameters
---@return LuaGuiElement
---<p>-> createView{container=, view_name=, element_index=, children...}</p>
function ElementBuilder.addView(parameters)
	parameters.clear = "same"
	return createView_core(parameters)
end



---@param parameters KuxGuiLib.ElementBuilder.create.parameters
---@return LuaGuiElement[]
---<p>-> createPart{container=, part_name=, element_index=, children...}</p>
local function createParts_core(parameters)
	local func_name = "createPart" -- entry point
	assert(parameters ~= nil, "parameters must not be nil")
	local container = parameters.container or error ("container must not be nil")
	local factory = element_factory_utils.prep.children(parameters)

	parameters.mod_name = parameters.mod_name or parameters.container.tags.mod_name --[[@as string]]
	parameters.view_name = parameters.view_name or container.tags.view_name --[[@as string]] or ""
	--parameters.parent_view_name = parameters.parent_view_name or container.tags.parent_view_name --[[@as string]]
	parameters.element_index = parameters.element_index or {}
	parameters.element_index[parameters.view_name] = parameters.element_index[parameters.view_name] or {__parent_view_name=parameters.parent_view_name}

	local function fbody()
		local r = create (container, factory, parameters)
		element_factory_utils.update_path_dic(r, parameters.element_index)
		return r -- avoid tail-call
	end

	local function format_exception(ex)
		local err_msg = (ex.message or "<no message>").."\n"
		local ui_trace = parameters.element_stack_trace and parameters.element_stack_trace:toString() or "<no element trace>"
		local part = "→ while creating part " .. (parameters.part_name and str(parameters.part_name) or "<unknown>") .. "\n"
		local at   = "  at "..ex.caller.."\n"
		local view = "  → inside view " .. ((parameters.view_name or "")~="" and str(parameters.view_name) or "<unnamed>") .. "\n"
		local parent = parameters.parent_view_name and "    → inside view " .. str(parameters.parent_view_name) .. "\n" or ""
		return err_msg..part..at..view..parent.."\nUI-Stack-Trace:\n" .. ui_trace .. "\n\nInner Error:\n" .. ex.stack_trace .. "\n"
	end

	result = call(fbody, format_exception)
	return result
end

---@param parameters KuxGuiLib.ElementBuilder.create.parameters
---@return LuaGuiElement[]
---<p>-> createPart{container=, part_name=, element_index=, children...}</p>
function ElementBuilder.createParts(parameters)
	return createParts_core(parameters)
end

---@param parameters KuxGuiLib.ElementBuilder.create.parameters
---@return LuaGuiElement
---<p>-> createPart{container=, part_name=, element_index=, children...}</p>
function ElementBuilder.createPart(parameters)
	return createParts_core(parameters)[1]
end

---@param container LuaGuiElement
---@param create_children_fnc function[]
---@param parameters KuxGuiLib.ElementBuilder.create.parameters
---@return LuaGuiElement[]
local function create_multi(container, create_children_fnc, parameters)
	assert(container~=nil, "Invalid Argument. 'container' must not be nil.")
	trace("ElementBuilder.create in "..container.name.." from "..type(create_children_fnc))

	local flatten; flatten = function(t1, t2)
		t2 = t2 or {}
		for _, elmt in ipairs(t1) do
			if(type(elmt)=="table") then
				flatten(elmt, t2)
			else
				table.insert(t2, elmt)
			end
		end
		return t2
	end

	local list =
		type(create_children_fnc) == "function" and {create_children_fnc} or
		type(create_children_fnc) == "table" and flatten(create_children_fnc) or
		error("Invalid Argument. 'create_children_fnc' must be a function or a table of functions.")
	local results = {}
	for _, fnc in ipairs(list) do
		assert(type(fnc)=="function", "Invalid Argument. 'create_children_fnc' must be a function or a table of functions. but is "..type(fnc)..": "..serpent.line(fnc).." container: "..container.name)

		local result =  fnc(container, parameters) ---@type LuaGuiElement|fun(container,parameters)
		local elmt = type(result)=="function" and result(container, parameters) or result
		if elmt then results[#results+1] = elmt end
	end
	return results
end

---@param el LuaGuiElement
---@param all_elements {[string]:LuaGuiElement|LuaGuiElement[]}
---@param view_elements {[string]:LuaGuiElement|LuaGuiElement[]}
function ElementBuilder.destroy_element(el, all_elements, view_elements)
	assert(el~=nil, "Invalid Argument. 'el' must not be nil.")
	assert(type(all_elements)=="table", "Invalid Argument. 'all_elements' must be a table but is "..type(all_elements)..": "..serpent.line(all_elements))
	assert(type(view_elements)=="table", "Invalid Argument. 'view_elements' must be a table but is "..type(view_elements)..": "..serpent.line(view_elements))
	local t = all_elements[el.name]
	if type(t) == "table" then
		Table.remove(t, el)
		if     #t == 0 then all_elements[el.name] = nil
		elseif #t == 1 then all_elements[el.name] = t[1]
		end
	else
		all_elements[el.name] = nil
	end

	t = view_elements[el.name]
	if type(t) == "table" then
		Table.remove(t, el)
		if     #t == 0 then view_elements[el.name] = nil
		elseif #t == 1 then view_elements[el.name] = t[1]
		end
	else
		view_elements[el.name] = nil
	end
	local p = el.parent
	el.destroy()
end

---@param container LuaGuiElement
---@param definitions table
---@param parameters KuxGuiLib.ElementBuilder.create.parameters
---@return LuaGuiElement[]
function ElementBuilder.add(container, definitions, parameters)
	if not definitions then return {} end
	if definitions.type then definitions = {definitions} end
	parameters.container = container
	parameters.mod_name = parameters.mod_name or parameters.container.tags.mod_name --[[@as string]]
	parameters.view_name = parameters.view_name or container.tags.view_name --[[@as string]] or ""
	parameters.parent_view_name = parameters.parent_view_name or container.tags.parent_view_name --[[@as string]]
	parameters.element_index = parameters.element_index or {}
	parameters.element_index[parameters.view_name] = parameters.element_index[parameters.view_name] or {__parent_view_name=parameters.parent_view_name}

	parameters.element_stack_trace = ElementStackTrace.new()

	local function add_core(container, definitions, parameters)
		local results = {}
		if #definitions==0 then return results end
		for i, def in ipairs(definitions) do
			local children = element_factory_utils.prep.children(def) or {}
			results[i] = ElementBuilder.factory(def)(container, parameters)
			add_core(results[i], children, parameters)
		end
		return results
	end

	local results = add_core(container, definitions, parameters)
	for _, r in ipairs(results) do
		element_factory_utils.update_path_dic(r,parameters.element_index)
	end
	return results
end


---@type table<integer,table<string,LuaGuiElement>> player_index->ui_name->element_name->element
local getElement_cache = Dictionary.create_byPlayerAndString()


---Gets an element by its name using the path dictionary
---@param player LuaPlayer?
---@param root_name_or_path string root ui name or root path for the element that contains the path_dic.
---@param element_name string?
---@return LuaGuiElement #element
---@return LuaGuiElement #root
---@return string? #error message
---<p>Usage: <br>
---1. <code>getElement(player, ui_name, element_name)</code>
---2. <code>etElement(player, root_path, element_name)</code>
function ElementBuilder.getElement(player, root_name_or_path, element_name)
	if not player then player = _G.player or error("no player") end             --ERROR ❌ no player
	local root
	if root_name_or_path:find("/") then
		root = Gui.getElement(player, root_name_or_path)
	else
		root = player.gui.screen[root_name_or_path]
			or player.gui.top[root_name_or_path]
			or player.gui.left[root_name_or_path]
			or player.gui.center[root_name_or_path]
			or player.gui.relative[root_name_or_path]
			or player.gui.goal[root_name_or_path]
	end
	if not root then return nil,nil,"root not found" end
	if not element_name then return root,nil end
	local el = getElement_cache[player.index][root_name_or_path][element_name]
	if el and el.valid then return el, root end
	local dic_name_path = root.tags.path_dic or error("path_dic not found in root element.")
	local path = dic_name_path[element_name]
	if not path then return nil, root,"no path" end
	el = element_factory_utils.getElement(root, path)
	if not el then return nil, root,"element not found" end
	if not el.valid then return nil, root,"element not valid" end
	getElement_cache[player.index][root_name_or_path][element_name] = el
	return el, root
end

-------------------------------------------------------------------------------
--#region: element_factory
-------------------------------------------------------------------------------


---Base function to create a gui element creation function
---@param args table the arguments for the element as specified in then designer
---@return fun(container:LuaGuiElement, parameters:KuxGuiLib.ElementBuilder.create.parameters) #A function that creates the element in the given container
local function element_factory(args)
	assert(args~=nil, "Invalid Argument. 'args' must not be nil.")

	if args.name and element_factory_utils.reserved_name[args.name] then error("Name is reserved. '"..args.name.."' is member of LuaGuiElement.") end

	---@param container LuaGuiElement
	---@param parameters KuxGuiLib.ElementBuilder.create.parameters
	return function(container, parameters)
		assert(container~=nil, "Invalid Argument. 'container' must not be nil.")
		--TODO Make log configurable if required
		--log("ElementBuilder.element_factory "..tostring(container.name).." "..tostring(args.name))
		parameters.element_stack_trace:push(args)

		if args.condition~=nil then
			if type(args.condition)=="function" then
				if not args.condition(args) then return end
			end
			if not args.condition then return end
		end

		local is_virtual_root = args.virtual and container.object_name == "LuaGuiElement" or false
		local is_virtual = args.virtual or container.object_name == nil

		local element = nil
		local children = nil

		if is_virtual then
			args.virtual = nil
			children = prep.children(args)
			args.children=nil
			if is_virtual_root then
				temp_virtual_elements = {}
				element = VGuiElement.new(args,{parent = container})
				element.vid = #temp_virtual_elements
				table.insert(temp_virtual_elements, element)
				local tags = container.tags
				tags.virtual_children=tags.virtual_children or {}
				table.insert(tags.virtual_children--[[@as table]], element.vid)
				container.tags = tags --> ERROR: value (function) can't be saved in property tree at ROOT.0.children[0]
			else
				element = container.add(args)
			end
		else
			local element_index = parameters.element_index
			                 prep.name(args, container)     --[1]
							 prep.caption(args, parameters) --[2]
							 prep.tooltip(args, parameters)
			local style    = prep.style(args)
			      children = prep.children(args)
			local post     = prep.post(args)
			local extra    = prep.add(args)
			--[[TRACE]]--trace("ElementBuilder.element_base "..tostring(container.name).." "..tostring(args.name))
			--[[TRACE]]--trace.append("  args:  "..serpent.line(args))
			--[[TRACE]]--trace.append("  style: "..serpent.line(style))
			--[[TRACE]]--trace.append("  extra: "..serpent.line(extra))
			if type=="tab" and #children==0 then
				element = container.add(args)
				content = container.add{type="flow"}
				container.add_tab(container, element)
			elseif container.type=="tab" then
				element = container.parent.add(args)
				container.parent.add_tab(container, element)
			else
				element = container.add(args)
			end
			--if element_index then add_cache_element(element_index, element) end
			--if view_names then add_cache_element(view_names, element) end
			local skip = { ["@"] = true, ["."] = true, ["$"] = true }
			if element_index and not skip[(element.name or "."):sub(1,1)] then
				element_index[parameters.view_name][element.name] = element-- add to view index, no duplicates, only last one is saved
			end
			if(style) then apply.style(element, style) end
			if(extra) then apply.extra(element, extra) end
			if(post ) then apply.post (element, post ) end
			if args.type=="textfield" then element.select(1,0)
			elseif args.type=="text-box" then element.scroll_to_left(); element.scroll_to_top()  end
		end

		local tags = element.tags
		tags.mod_name = parameters.mod_name
		tags.view_name = parameters.view_name
		tags.part_name = parameters.part_name
		tags.creator_name = parameters.creator_name
		element.tags = tags
		if(children) then create_multi(element, children, parameters) end

		if is_virtual_root then
			VGuiElement.freeze(element)
			local tags = container.tags
			tags.virtual_children=tags.virtual_children or {}
			tags.virtual_children[#tags.virtual_children] = element
			container.tags = tags
		end
		parameters.element_stack_trace:pop()
		return element
	end
end
ElementBuilder.factory = element_factory


-------------------------------------------------------------------------------
---#region: elements
-------------------------------------------------------------------------------

---@class KuxGuiLib.ElementBuilder.conditional.parameter
---@field [1] boolean? condition
---@field condition boolean?
---@field [integer] function children


---
---@param args KuxGuiLib.ElementBuilder.conditional.parameter
---@return function|function[]|nil
function ElementBuilder.conditional(args)
	if args.condition~=nil then
		if type(args.condition)=="function" then
			if not args.condition(args) then return end
		end
		if not args.condition then return end
	elseif type(args[1])=="boolean" then
		if not args[1] then return end
	end

	local children = {}
	local function f(args)
		for i = 1, 50, 1 do
			if type(args[i] )== "table" then f(args[i])
			elseif type(args[i] == "function") then children[#children+1]=args[i]
			else --[[ignore]] end
		end
	end

	f(args)
	return #children>1 and children or #children==1 and children[1] or nil
end


---A clickable element. Relevant event: on_gui_click
---@param args KuxGuiLib.ElementBuilder.button.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.button(args)
	args["type"]="button"
	return element_factory(args)
end

---A button that displays a sprite rather than text. Relevant event: on_gui_click
---@param args KuxGuiLib.ElementBuilder.spritebutton.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.spritebutton(args)
	args["type"]="sprite-button"
	if not args.caption then args.caption = "" end -- to avoid automatic caption
	return element_factory(args)
end

---@type Decorative

---A clickable element with a check mark that can be turned off or on. Relevant event: on_gui_checked_state_changed
---@param args KuxGuiLib.ElementBuilder.checkbox.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.checkbox(args)
	args["type"]="checkbox"
	return element_factory(args)
end

---An invisible container that lays out its children either horizontally or vertically.
---@param args KuxGuiLib.ElementBuilder.flow.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.flow(args)
	args["type"]="flow"
	return element_factory(args)
end

---A non-transparent box that contains other elements. It can have a title (set via the caption attribute). Just like a flow, it lays out its children either horizontally or vertically. Relevant event: on_gui_location_changed
---@param args KuxGuiLib.ElementBuilder.frame.args
---@return function
function ElementBuilder.frame(args)
	args["type"]="frame"
	if not args.caption then args.caption = "" end -- to avoid automatic caption
	return element_factory(args)
end

---A piece of text.
---@param args KuxGuiLib.ElementBuilder.label.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.label(args)
	args["type"]="label"
	return element_factory(args)
end

---A horizontal or vertical separation line.
---@param args KuxGuiLib.ElementBuilder.line.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.line(args)
	args["type"]="line"
	return element_factory(args)
end

---A partially filled bar that can be used to indicate progress.
---@param args KuxGuiLib.ElementBuilder.progressbar.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.progressbar(args)
	args["type"]="progressbar"
	return element_factory(args)
end

---An invisible container that lays out its children in a specific number of columns. The width of each column is determined by the widest element it contains.
---@param args KuxGuiLib.ElementBuilder.table.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.table(args)
	args["type"]="table"
	return element_factory(args)
end

---A single-line box the user can type into. Relevant events: on_gui_text_changed, on_gui_confirmed
---@param args KuxGuiLib.ElementBuilder.textfield.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.textfield(args)
	args["type"]="textfield"
	return element_factory(args)
end

---An element that is similar to a checkbox, but with a circular appearance. Clicking a selected radio button will not unselect it. Radio buttons are not linked to each other in any way. Relevant event: on_gui_checked_state_changed
---@param args KuxGuiLib.ElementBuilder.radiobutton.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.radiobutton(args)
	args["type"]="radiobutton"
	return element_factory(args)
end

---An element that shows an image.
---@param args KuxGuiLib.ElementBuilder.sprite.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.sprite(args)
	args["type"]="sprite"
	return element_factory(args)
end

---An invisible element that is similar to a flow, but has the ability to show and use scroll bars.
---@param args KuxGuiLib.ElementBuilder.scrollpane.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.scrollpane(args)
	args["type"]="scroll-pane"
	return element_factory(args)
end

---A drop-down containing strings of text. Relevant event: on_gui_selection_state_changed
---@param args KuxGuiLib.ElementBuilder.dropdown.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.dropdown(args)
	args["type"]="drop-down"
	return element_factory(args)
end

---A list of strings, only one of which can be selected at a time. Shows a scroll bar if necessary. Relevant event: on_gui_selection_state_changed
---@param args KuxGuiLib.ElementBuilder.listbox.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.listbox(args)
	args["type"]="list-box"
	return element_factory(args)
end

---A camera that shows the game at the given position on the given surface. It can visually track an entity that is set after the element has been created.
---@param args KuxGuiLib.ElementBuilder.camera.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.camera(args)
	args["type"]="camera"
	return element_factory(args)
end

---A button that lets the player pick from a certain kind of prototype, with optional filtering. Relevant event: on_gui_elem_changed
---@param args KuxGuiLib.ElementBuilder.chooseelembutton.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.chooseelembutton(args)
	args["type"]="choose-elem-button"
	return element_factory(args)
end

---A multi-line textfield. Relevant event: on_gui_text_changed
---@param args KuxGuiLib.ElementBuilder.textbox.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.textbox(args)
	args["type"]="text-box"
	return element_factory(args)
end

---A horizontal number line which can be used to choose a number. Relevant event: on_gui_value_changed
---@param args KuxGuiLib.ElementBuilder.slider.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.slider(args)
	args["type"]="slider"
	return element_factory(args)
end

---A minimap preview, similar to the normal player minimap. It can visually track an entity that is set after the element has been created.
---@param args KuxGuiLib.ElementBuilder.minimap.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.minimap(args)
	args["type"]="minimap"
	return element_factory(args)
end

---A preview of an entity. The entity has to be set after the element has been created.
---@param args KuxGuiLib.ElementBuilder.entitypreview.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.entitypreview(args)
	args["type"]="entity-preview"
	return element_factory(args)
end

---An empty element that just exists. The root GUI elements screen and relative are empty-widgets.
---@param args KuxGuiLib.ElementBuilder.emptywidget.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.emptywidget(args)
	args["type"]="empty-widget"
	return element_factory(args)
end

---A collection of tabs and their contents. Relevant event: on_gui_selected_tab_changed
---@param args KuxGuiLib.ElementBuilder.tabbedpane.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.tabbedpane(args)
	args["type"]="tabbed-pane"
	return element_factory(args)
end

---A tab for use in a tabbed-pane.
---@param args KuxGuiLib.ElementBuilder.tab.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.tab(args)
	args["type"]="tab"
	return element_factory(args)
end

---A switch with three possible states. Can have labels attached to either side. Relevant event: on_gui_switch_state_changed
---@param args KuxGuiLib.ElementBuilder.switch.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.switch(args)
	args["type"]="switch"
	return element_factory(args)
end


---@alias EventIdentifier string A string identifying an event handler (usually `eventof(this.on_handler_clicked)`).


---@class KuxGuiLib.ElementBuilder.window.args : KuxGuiLib.ElementBuilder.frame.args
---@field direction "horizontal"|"vertical"|nil The initial direction of the content flow's layout. See LuaGuiElement::direction. Defaults to "vertical".
---@field on_close EventIdentifier?
---@field [integer] function Children

---@param args KuxGuiLib.ElementBuilder.window.args
---@return function
function ElementBuilder.window(args)
	local eb=ElementBuilder
	local frame,flow,label,emptywidget,spritebutton=eb.frame,eb.flow,eb.label,eb.emptywidget,eb.spritebutton
	local children = prep.children(args)

	if not args.maximal_height and not args.height then args.maximal_height = player.display_resolution.height/player.display_scale*0.85 end
	if not args.maximal_width and not args.width then args.maximal_width = player.display_resolution.width/player.display_scale*0.8 end
	content_direction = args.direction or "vertical"; args.direction=nil
	return -- designer --
	frame { name=args.name, direction="vertical", style = args,
		flow { direction = "horizontal", drag_target="%parent%",
			label { caption = args.caption, style = "frame_title", ignored_by_interaction = true },
			emptywidget { style = "draggable_space_header", horizontally_stretchable = true, height=24,ignored_by_interaction = true },
			spritebutton { name = "close", style = "frame_action_button", sprite = "utility/close" }
		},
		flow {name="content", direction=content_direction,
			children = children
		}
	}
end


---@class KuxGuiLib.ElementBuilder.dialog.args
---@field name string
---@field direction "horizontal"|"vertical"|nil The initial direction of the content flow's layout. See LuaGuiElement::direction. Defaults to "vertical".
---@field caption LocalisedString?
---@field showConfirm boolean defaults to true
---@field on_back EventIdentifier?
---@field on_confirm EventIdentifier?
---@field [integer] function Children


---@param args KuxGuiLib.ElementBuilder.dialog.args
---@return function
function ElementBuilder.dialog(args)
	local eb=ElementBuilder
	local frame,flow,label,emptywidget,spritebutton,button=eb.frame,eb.flow,eb.label,eb.emptywidget,eb.spritebutton,eb.button
	local children = prep.children(args)

	return -- designer --
	frame { name=args.name, direction = "vertical",
		flow { direction = "horizontal", drag_target="%parent%",
			label { caption = args.caption, style = "frame_title", ignored_by_interaction = true },
			emptywidget { style = "draggable_space_header", horizontally_stretchable = true, ignored_by_interaction = true }
		},
		flow {name="content", direction=args.direction or "vertical",
			children = children
		},
		flow { direction = "horizontal", style = "dialog_buttons_horizontal_flow",
			button { name="back", caption={"gui.back"}, style="back_button", on_click=args.on_back },
			emptywidget { style="draggable_space_header", horizontally_stretchable = true },
			button { name="confirm", caption={"gui.confirm"}, style="confirm_button", conditional = args.showConfirm ~= false,on_click=args.on_confirm }
		}
	}
end


---@class KuxGuiLib.ElementBuilder.stack.args : KuxGuiLib.ElementBuilder.flow.args
---@field direction "vertical"?

---An invisible container that lays out its children vertically by default. (alias for `flow direction=vertical`)
---@param args KuxGuiLib.ElementBuilder.stack.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.stack(args)
	args["type"]="flow"; args["direction"]="vertical"
	return element_factory(args)
end

function ElementBuilder.createElementAccessor_core(arg1, arg2)
	local view_name
	local view_path
	if type(arg1)=="string" and type(arg2)=="string" then
		mod_name = arg1 --[[@as string]]
		view_name = arg2 --[[@as string]]
		view_path = element_factory_utils.get_view_path(mod_name, view_name)
		if not view_path then
			error(string.format("No path available for view '%s' (%s)", tostring(view_name), tostring(mod_name)))
			--invalid_view_access[mod_name][view_name]=true
			--TODO: restore accessor if possible
		end
	elseif type(arg1)=="userdata" then
		local el = arg1 --[[@as LuaGuiElement]]
		view_name = el.tags.view_name --[[@as string]]
		local view_root = element_factory_utils.find_view_root(el) or error("invalid state")
		view_path = view_root.tags.path
		element_factory_utils.register_view(view_root)
	else
		error("Argument exception. Expect (string,string) or (LuaGuiElement) but was ("..type(arg1)..", "..type(arg2)..")")
	end

	return setmetatable({
		["/meta"] = {
			__class="ElementAccessor",
			view_name = view_name,
			view_path = view_path,
			view = nil
		}}, {
		__index = function(t, k)
			local meta = t["/meta"]
			if k==nil then error("Key is nil") end
			if k=="window" or k == "root" then k = "/" end
			if not meta.view or not meta.view.valid then
				local root, err = Gui.getElement(_G.player, meta.view_path)
				if not root then error("Root element not found in: ".. meta.view_path) end
				if not root.valid then error("Root element not valid in: ".. meta.view_path) end
				meta.view = root
			end
			local root = meta.view
			if k=="/" then return root end
			local relpath = root.tags.path_dic[k]
			if not relpath then error("Element not found. name: " .. str(k).." in view ".. str(root.tags.view_name)) end
			local el, err = Gui.getElement(root, relpath)
			if not el then error("Element not found. name: " .. k.." in ".. relpath) end
			if not el.valid then error("Element not valid. name: " .. k.." in ".. relpath) end
			return el
		end
	})
end

---Creates an ElementAccessor to access elments of the specfied UI
---@param element LuaGuiElement
---@return KuxGuiLib.ElementAccessor
---<p>Usage:<br>
---1. <code>element = ElementBuilder.createElementAccessor(el)</code> (after createView)<br/>
---<code>el = element[element_name] </code></p>
---<p>The ElementAccessor itself is player unspecific. The usage is it not.</p>
---<p>See also loadElementAccessor</p>
function ElementBuilder.createElementAccessor(element)
	return ElementBuilder.createElementAccessor_core(element)
end

--[[
---Load an ElementAccessor to access elments of the specfied UI
---@param mod_name string
---@param view_name string
---@return KuxGuiLib.ElementAccessor
---<p>Usage:<br>
---<code>element = ElementBuilder.loadElementAccessor(mod_name, view_name)</code> (in on_load)<br/>
---<code>el = element[element_name] </code></p>
---<p>The ElementAccessor itself is player unspecific. The usage is it not.</p>
---<p>See also: createElementAccessor</p>
function ElementBuilder.loadElementAccessor(mod_name, view_name)
	return ElementBuilder.createElementAccessor_core(mod_name, view_name)
end
]]

---Load an ElementAccessor to access elments of the specfied UI
---@param mod_name string
---@param view_name string
---@return KuxGuiLib.ElementAccessor
---<p>Usage:<br>
---<code>element = ElementBuilder.loadElementAccessor(mod_name, view_name)</code><br/>
---<code>el = element[element_name] </code></p>
---<p>The ElementAccessor itself is player unspecific. The usage is it not.</p>
---<p>See also: createElementAccessor</p>
---<p>The element accessor is lazy loaded, so it can be created in main chunk, no need to use on_load</p>
function ElementBuilder.loadElementAccessor(mod_name, view_name)
	local state = {__mod_name=mod_name, __view_name=view_name}
	return setmetatable({}, {
		__index = function(_, k)
			if not state.element then
				state.element = ElementBuilder.createElementAccessor_core(mod_name, view_name)
			end
			return state.element[k]
		end
	})
end


--- ElementAccessor provides dynamic access to GUI elements.
--- <p>Usage: <code>el = element[element_name]</code></p>
--- <p>See also createElementAccessor, loadElementAccessor</p>
---@class KuxGuiLib.ElementAccessor
---@field [string] LuaGuiElement


---
---@param el LuaGuiElement
---@param name string
---@param value AnyBasic
function ElementBuilder.tag(el, name, value)
	local tags = el.tags
	tags[name] = value
	el.tags = tags
end

---Gets the full qualified name of the function.
---@param func function
---@return string #The full qualified name of the function or nil if not found.
---<p>Event handler must be registered with <code>GuiEventDistributor.register_view</code> to be able to get the full name.</p>
function ElementBuilder.eventof(func) return FunctionUtils.nameof(func) end



--[[ do --snippet
	local eb = KuxGuiLib.require.GuiBuilder.ElementBuilder
	local createView, createPart, add, eventof = eb.createView, eb.createPart, eb.add, eb.eventof
	local button, camera, checkbox, chooseelembutton, dropdown, emptywidget, entitypreview, flow
		= eb.button, eb.camera, eb.checkbox, eb.chooseelembutton, eb.dropdown, eb.emptywidget, eb.entitypreview, eb.flow
	local frame, label, line, listbox, minimap, progressbar, radiobutton, scrollpane, slider
		= eb.frame, eb.label, eb.line, eb.listbox, eb.minimap, eb.progressbar, eb.radiobutton, eb.scrollpane, eb.slider
	local sprite, spritebutton, switch, tab, tabbedpane, table, textbox, textfield
		= eb.sprite, eb.spritebutton, eb.switch, eb.tab, eb.tabbedpane, eb.table, eb.textbox, eb.textfield
	local window, dialog, stack = eb.window, eb.dialog, eb.stack
end ]]

--[[
Events.on_loaded(function ()
	-- cleanup invalid views
	for _, player in pairs(game.players) do
		for _, tl_root_name in ipairs( {"screen", "top", "left", "center", "relative", "goal"}) do
			local tl_root_el = player.gui[tl_root_name]
			for _, el in pairs(tl_root_el.children) do
				local tags = el.tags
				if tags and tags.mod_name and tags.view_name then
					if invalid_view_access[tags.mod_name][tags.view_name] then
						el.destroy()
					end
				end
			end
		end
	end
	Dictionary.clear(invalid_view_access)
end)
]]

function ElementBuilder.asGlobal()
	local eb = KuxGuiLib.require.GuiBuilder.ElementBuilder
	_G.ElementBuilder = eb

	  _G.createView, _G.createPart, _G.createParts, _G.add, _G.eventof
	= eb.createView, eb.createPart, eb.createParts, eb.add, eb.eventof
	  _G.button, _G.camera, _G.checkbox, _G.chooseelembutton, _G.dropdown, _G.emptywidget, _G.entitypreview, _G.flow
	= eb.button, eb.camera, eb.checkbox, eb.chooseelembutton, eb.dropdown, eb.emptywidget, eb.entitypreview, eb.flow
	  _G.frame, _G.label, _G.line, _G.listbox, _G.minimap, _G.progressbar, _G.radiobutton, _G.scrollpane, _G.slider
	= eb.frame, eb.label, eb.line, eb.listbox, eb.minimap, eb.progressbar, eb.radiobutton, eb.scrollpane, eb.slider
	  _G.sprite, _G.spritebutton, _G.switch, _G.tab, _G.tabbedpane, _G.grid, _G.textbox, _G.textfield
	= eb.sprite, eb.spritebutton, eb.switch, eb.tab, eb.tabbedpane, eb.table, eb.textbox, eb.textfield
	_G.window, _G.dialog, _G.stack = eb.window, eb.dialog, eb.stack
end

return ElementBuilder


--[[
button				A clickable element. Relevant event: on_gui_click
sprite-button		A button that displays a sprite rather than text. Relevant event: on_gui_click
checkbox			A clickable element with a check mark that can be turned off or on. Relevant event: on_gui_checked_state_changed
flow				An invisible container that lays out its children either horizontally or vertically.
frame				A non-transparent box that contains other elements. It can have a title (set via the caption attribute). Just like a flow, it lays out its children either horizontally or vertically. Relevant event: on_gui_location_changed
label				A piece of text.
line				A horizontal or vertical separation line.
progressbar			A partially filled bar that can be used to indicate progress.
table				An invisible container that lays out its children in a specific number of columns. The width of each column is determined by the widest element it contains.
textfield			A single-line box the user can type into. Relevant events: on_gui_text_changed, on_gui_confirmed
radiobutton			An element that is similar to a checkbox, but with a circular appearance. Clicking a selected radio button will not unselect it. Radio buttons are not linked to each other in any way. Relevant event: on_gui_checked_state_changed
sprite				An element that shows an image.
scroll-pane			An invisible element that is similar to a flow, but has the ability to show and use scroll bars.
drop-down			A drop-down containing strings of text. Relevant event: on_gui_selection_state_changed
list-box			A list of strings, only one of which can be selected at a time. Shows a scroll bar if necessary. Relevant event: on_gui_selection_state_changed
camera				A camera that shows the game at the given position on the given surface. It can visually track an entity that is set after the element has been created.
choose-elem-button	A button that lets the player pick from a certain kind of prototype, with optional filtering. Relevant event: on_gui_elem_changed
text-box			A multi-line textfield. Relevant event: on_gui_text_changed
slider				A horizontal number line which can be used to choose a number. Relevant event: on_gui_value_changed
minimap				A minimap preview, similar to the normal player minimap. It can visually track an entity that is set after the element has been created.
entity-preview		A preview of an entity. The entity has to be set after the element has been created.
empty-widget		An empty element that just exists. The root GUI elements screen and relative are empty-widgets.
tabbed-pane			A collection of tabs and their contents. Relevant event: on_gui_selected_tab_changed
tab					A tab for use in a tabbed-pane.
switch				A switch with three possible states. Can have labels attached to either side. Relevant event: on_gui_switch_state_changed
]]