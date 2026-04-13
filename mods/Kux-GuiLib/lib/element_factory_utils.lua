-- This file is reqired by ElementBuilder.element_builder only

local TranslationService = KuxCoreLib.require.TranslationService
local Table = KuxCoreLib.require.Table
local Dictionary = KuxCoreLib.require.Dictionary
local Storage = KuxCoreLib.require.Storage
local Colors = KuxCoreLib.require.Colors


--adapted for Factorio 2.0 ( no changes )

local _add_fields = {"achievement", "allow_decimal", "allow_negative", "allow_none_state",
	"anchor", "auto_toggle", "badge_text", "caption", "chart_player_index",
	"clear_and_focus_on_right_click", "clicked_sprite", "column_count", "decorative", "direction",
	"discrete_slider", "discrete_values", "draw_horizontal_line_after_headers",
	"draw_horizontal_lines", "draw_vertical_lines", "elem_filters", "elem_type", "enabled",
	"entity", "equipment", "fluid", "force", "game_controller_interaction",
	"horizontal_scroll_policy", "hovered_sprite", "ignored_by_interaction", "index", "is_password",
	"item", "item-group", "items", "left_label_caption", "left_label_tooltip",
	"lose_focus_on_confirm", "maximum_value", "minimum_value", "mouse_button_filter", "name",
	"number", "numeric", "position", "raise_hover_events", "recipe", "resize_to_sprite",
	"right_label_caption", "right_label_tooltip", "selected_index",
	"show_percent_for_small_numbers", "signal", "sprite", "state", "style", "surface_index",
	"switch_state", "tags", "technology", "text", "tile", "toggled", "tooltip", "type", "value",
	"value_step", "vertical_centering", "vertical_scroll_policy", "visible", "zoom",
	"auto_center", "drag_target", "elem_tooltip", "location",
	}
local _style_writable_fields = {"badge_font", "badge_horizontal_spacing", "bar_width",
	"bottom_cell_padding", "bottom_margin", "bottom_padding", "cell_padding", "clicked_font_color",
	"clicked_vertical_offset", "color", "default_badge_font_color", "disabled_badge_font_color",
	"disabled_font_color", "draw_grayscale_picture", "extra_bottom_margin_when_activated",
	"extra_bottom_padding_when_activated", "extra_left_margin_when_activated",
	"extra_left_padding_when_activated", "extra_margin_when_activated",
	"extra_padding_when_activated", "extra_right_margin_when_activated",
	"extra_right_padding_when_activated", "extra_top_margin_when_activated",
	"extra_top_padding_when_activated", "font", "font_color", "height", "horizontal_align",
	"horizontal_spacing", "horizontally_squashable", "horizontally_stretchable",
	"hovered_font_color", "left_cell_padding", "left_margin", "left_padding", "margin",
	"maximal_height", "maximal_width", "minimal_height", "minimal_width", "natural_height",
	"natural_width", "padding", "pie_progress_color", "rich_text_setting", "right_cell_padding",
	"right_margin", "right_padding", "selected_badge_font_color", "selected_clicked_font_color",
	"selected_font_color", "selected_hovered_font_color", "single_line", "size",
	"stretch_image_to_widget_size", "strikethrough_color", "top_cell_padding", "top_margin",
	"top_padding", "use_header_filler", "vertical_align", "vertical_spacing",
	"vertically_squashable", "vertically_stretchable", "width"}

local alias_to_api= {
	minimum_width = "minimal_width",
	maximum_width = "maximal_width",
	minimum_height = "minimal_height",
	maximum_height = "maximal_height",
	min_width = "minimal_width",
	max_width = "maximal_width",
	min_height = "minimal_height",
	max_height = "maximal_height",
	vertical_stretchable = "vertically_stretchable",
	horizontal_stretchable  = "horizontally_stretchable",
	horizontal_squashable = "horizontally_squashable",
	vertical_squashable = "vertically_squashable"
}


local style_color_fields = Table.toFlagsDictionary{"font_color", "hovered_font_color", "clicked_font_color",
	"disabled_font_color","pie_progress_color","selected_font_color","selected_hovered_font_color",
	"selected_clicked_font_color","strikethrough_color","color","default_badge_font_color",
	"selected_badge_font_color","disabled_badge_font_color"}


local isAddField = {}; for _,n in ipairs(_add_fields) do isAddField[n]=true end
local isWriteableStyleField = {}; for _,n in ipairs(_style_writable_fields) do isWriteableStyleField[n]=true end
local function isInteger(value) return type(value)=="number" and math.floor(value)==value end

-- check for names which can be used as add field and as style field
for _,name in ipairs(_style_writable_fields) do
	assert(isAddField[name]==nil, "Style field '"..name.."' is also an add field.")
end

local t = {"%self%","%parent%","%parent.parent%"}
local supported_variables = {}; for _,v in ipairs(t) do supported_variables[v]=true end


local elem3 = {
	["tab"]   = "tab",  ["button"]   = "btn",  ["checkbox"]    = "chk",  ["progressbar"]        = "prg",
	["flow"]  = "flo",  ["slider"]   = "sld",  ["textfield"]   = "txt",  ["empty-widget"]       = "emw",
	["line"]  = "lin",  ["camera"]   = "cam",  ["drop-down"]   = "dro",  ["sprite-button"]      = "spb",
	["label"] = "lbl",  ["sprite"]   = "spr",  ["scroll-pane"] = "scp",  ["entity-preview"]     = "pre",
	["frame"] = "fra",  ["minimap"]  = "map",  ["tabbed-pane"] = "tpn",  ["choose-elem-button"] = "cho",
	["table"] = "tbl",  ["text-box"] = "tbx",  ["radiobutton"] = "rad",  ["switch"] = "swi",
	["list-box"] ="lst"
}

---@param elem_type GuiElementType The type of the element to be created
---@param container LuaGuiElement The container in which the element will be created
local function create_element_name(elem_type, container)
	if container.type=="tab" then container = container.parent end
	local n = #container.children+1
	while container["@"..(elem3[elem_type] or "unk")..n] do n = n + 1 end
	return "@"..(elem3[elem_type] or "unk")..n
end

---
---@param args table
---@param parameters KuxGuiLib.ElementBuilder.create.parameters
local function prep_caption(args, parameters)
	-- https://lua-api.factorio.com/latest/concepts.html#LocalisedString
	-- LocalisedString :: string or number or boolean or LuaObject or nil or array[LocalisedString]
	if(args.caption) then return
	elseif(type(args[2])=="function") then ;
	elseif(type(args[2])=="nil") then ;
	elseif(type(args[2])=="table" and #args[2]>0 and type(args[2][1])=="function") then	;
	else
		args.caption = args[2]
		args[2] = nil
	end
	if not args.caption and args.name and parameters.localization_section and parameters.locale then
		if TranslationService.hasTranslation(parameters.localization_section.."-caption."..args.name,  parameters.locale) then
			args.caption = {parameters.localization_section.."-caption."..args.name}
		elseif TranslationService.hasTranslation(parameters.localization_section.."."..args.name,  parameters.locale) then
			args.caption = {parameters.localization_section.."."..args.name}
		end
	end
end

---
---@param args table
---@param parameters KuxGuiLib.ElementBuilder.create.parameters
local function prep_tooltip(args, parameters)
	if(args.tooltip) then return end
	if not args.tooltip and args.name and parameters.localization_section and parameters.locale then
		local key = {parameters.localization_section.."-tooltip."..args.name}
		if TranslationService.hasTranslation(key,  parameters.locale) then
			--IDEA: local keys = {parameters.localization_section..args.name, parameters.localization_section.."-caption"..args.name,parameters.localization_section..args.name.."-caption"}
			args.tooltip = key
		end
	end
end

---Cleans up args by removing all style parameters and returning them as style table. args.style:string is retained or created
---@param args table
---@return table|nil #The style table or nil
local function prep_style(args)
	local style = {}
	if(not args.style) then
		--do nothing
	elseif(type(args.style)=="string") then
		--keep "style" in args, as add paramter
	elseif(type(args.style)=="table") then
		--style = table.deepcopy(args.style)
		--args.style = style.base or style.parent or args.base_style --set "style" in args, as add paramter
		--style.base = nil; style.parent = nil; style.type = nil
		--args.base_style = nil
		local style_name, base_style
		local function flatten(style) -- Moves all fields to args, considering hierarchical inheritance.
			local style = table.deepcopy(style) or error("invalid state")
			if type(style.style)=="string" then style_name = style_name or style.style; style.style = nil
			else base_style = style.style; style.style=nil end
			for k, v in pairs(args.style) do
				if not args[k] then args[k] = v end
			end
			if base_style then flatten(base_style) end
		end
		flatten(args.style)
		args.style = style_name
	else
		error("Invalid Parameter. 'style' must be a string or a table but is "..type(args.style)..": "..serpent.line(args.style))
	end

	if args.style and not prototypes.style[args.style] then error("Style '"..args.style.."' does not exist.") end

	-- handle style fields
	for k,v in pairs(args) do
		local k0, k = k, alias_to_api[k] or k
		if (not isInteger(k) and isWriteableStyleField[k])
			or k=="column_alignments"  --field is readonly, but we can set the content later
		then
			style = style or {}
			style[k] = v
			args[k0] = nil
			--[[TRACE]]--trace.append("  prep_style '"..k.."' moved to style")
		end
	end

	return style
end

local function prep_children(args)
	local children= {}

	local function flatten(tbl)
		for i = 1, #tbl do
			local v = tbl[i]
			if type(v) == "table" then
				if v.type then children[#children+1] = v
				else flatten(v) end
			elseif type(v) == "function" then
				children[#children+1] = v
			end
		end
	end

	for i = 1, #args, 1 do
		if type(args[i]) == "function" then
			children[#children+1] = args[i]
			args[i] = nil
		elseif type(args[i]) == "table" then
			if args[i].type then children[#children+1] = args[i]
			else flatten(args[i]) end
			args[i] = nil
		end
	end

	if(args.children) then
		if #children > 0 then error("Duplicate definition of children.") end
		flatten{args.children}
		args.children = nil
	end

	return #children > 0 and children or nil
end

---filters args and returns a table with fields that are not supported by LuaGuiElement.add
local function prep_post(args)
	local post_args = {}

	for k,v in pairs(args) do
		-- TODO: make this more generic
		if(supported_variables[v]) then
			post_args[k] = v
			args[k] = nil
		end
	end
	-- trace("ElementBuilder.prep_post "..tostring(args.name))
	-- trace.append(serpent.block(post_args))
	return post_args
end


---Prepares all fields for `LuaGuiElement.add` and returns a table with the remaining fields
---@param args table
---@return table #The extra table
local function prep_add(args)
	local extra = {}
	for k,v in pairs(args) do
		if(not isInteger(k) and not isAddField[k]) then
			extra[k] = v
			args[k] = nil
		end
	end
	return extra
end

---
---@param args table
---@param container LuaGuiElement The container in which the element will be created
local function prep_name(args, container)
	if(args.name) then
		;
	elseif(args[1] and type(args[1])=="string") then
		args.name = args[1]
		args[1] = nil
	end
	if args.name then
		if args.name:find("/") then	error("Name must not contain '/' character") end
		if args.name:sub(1,1)=="@" then	error("Name must not start with '@' character") end
	else
		args.name = create_element_name(args.type, container) -- name is used to create stable paath
	end

	do -- use physical container (for tabs)
		local container = container.type=="tab" and container.parent or container
		if container.tags and container.tags.path and args.name then
			args.tags = args.tags or {}
			args.tags.path = container.tags.path.."/"..args.name
		elseif container.parent == nil and args.name then
			args.tags = args.tags or {}
			args.tags.path = container.name.."/"..args.name
		end
	end

end

---
---@param v string
---@return Color.0
local function toRGBA(v)
	local c = Colors[v]
	if c then return c end

	local r, g, b, a = v:match("#(%x%x)(%x%x)(%x%x)(%x?%x?)")
	if not r then error("Invalid color value. Expect #RRGGBB[AA] or known color name. bas was "..str(v)) end
	return {
		r = tonumber(r,16)/255,
		g = tonumber(g,16)/255,
		b = tonumber(b,16)/255,
		a = (a and a ~= "") and tonumber(a,16)/255 or 1
	}
end



---Applies the style to the element
---@param element LuaGuiElement
---@param style table
local function apply_style(element, style)
	if( not style) then return end
	for k,v in pairs(style) do
		if k == "column_alignments" then
			for i, alignment in pairs(v) do
				element.style.column_alignments[i] = alignment
			end
		elseif style_color_fields[k] and type(v)=="string" then
			element.style[k] = toRGBA(v)
		else
			element.style[k] = v
		end
	end
end

---Applies the extra properties to the element
---@param element LuaGuiElement
---@param extra table
local function apply_extra(element, extra)
	if( not extra) then return end
	for k,v in pairs(extra) do
		if k:find("^on_") then -- on_gui_click = ...
			tags = element.tags
			tags[k] = v
			element.tags = tags
		elseif k=="condition" then ;
		else
			element[k] = v
			-- Given object is not a LuaGuiElement.
			-- on drag_target = "%parent%"
		end
	end
end

local function apply_post(element, post_args)
	for k,v in pairs(post_args) do
		if(v == "%parent%") then -- drag_target = "%parent%"
			element[k] = element.parent
		elseif(v == "%parent.parent%") then
			element[k] = element.parent.parent
		elseif(v == "%self%") then
			element[k] = element
		else
			error("Unsupported variable: "..v)
		end
	end
end

---
---@param element LuaGuiElement
---@param name string
---@param value AnyBasic
function set_tag(element, name, value)
	local tags = element.tags
	tags[name] = value
	element.tags = tags
end

---@param view LuaGuiElement
---@param elements table<string, table<string, LuaGuiElement>> dictionary of view_name->element_name->element
local function set_path_dic(view, elements)
	local path_dic, skip = {}, {["@"]=true,["."]=true,["$"]=true}
	for name, el in pairs(elements[view.tags.view_name]) do
		if not skip[name:sub(1,1)] and type(el)=="userdata" then ---@cast el LuaGuiElement
			if not el.valid then
				elements[view.tags.view_name][name]=nil
			else
				path_dic[name] = el.tags.path:sub(#view.tags.path+2) -- make relative path
			end
		end
	end
	set_tag(view,"path_dic", path_dic)
end

---
---@param playerOrRoot LuaPlayer|LuaGui|LuaGuiElement
---@param path string
---@param level integer
---@return LuaGuiElement
local function getElement(playerOrRoot, path, level)
	local root = playerOrRoot.object_name=="LuaPlayer" and playerOrRoot.gui or playerOrRoot ---@cast root LuaGui|LuaGuiElement
	level = level or 256
    local element = root
    local count = 0
    for part in string.gmatch(path, "[^/]+") do
        if count == level then break end
        local idx = part:match("^#?(%d+)$")
        if idx then element = element.children[tonumber(idx)]
		else
			local element0 = element
			element = element[part]
			if not element and element0.type == "tab" then -- fix wrong path, child of tab is in tabbed-pane
				element = element0.parent[part]
			end
		end
        if not element then break end
        count = count + 1
    end
    return element
end

---@type table<integer, table<string, LuaGuiElement>> player_index->view_name->element
find_view_root_cache = Dictionary.create_byPlayerAndString()

---@param element LuaGuiElement
---@return LuaGuiElement?
local function find_view_root(element)
	local view_name = element.tags.view_name

	if view_name=="mod_gui" then
		return game.players[element].gui.top["mod_gui_top_frame"]
	end

	local el = find_view_root_cache[element.player_index][view_name]
	if el and el.valid then return el end

	el = element
	while el and el.valid do
		local p = el.parent
		if not p or not p.tags then break end
		if p and p.tags and p.tags.view_name ~= view_name then
			find_view_root_cache[el.player_index][view_name] = el
			return el
		end
		el = p
	end
	return nil
end

---
---@param base_path string
---@param path string
---@return string
local function make_relative_path(base_path, path)
	if path:sub(1, #base_path+1) ~= base_path.."/" then return path end
	local rel = path:sub(#base_path + 2)
	return rel
end


---@param parts LuaGuiElement|LuaGuiElement[]|nil
---@param elements table<string, table<string, LuaGuiElement>> dictionary of view_name->element_name->element
local function update_path_dic(parts, elements)
	if not parts then return end
	if type(parts)=="userdata" then parts={parts} end ---@cast parts LuaGuiElement[]

	local w ---@type LuaGuiElement
	for i = 1, #parts, 1 do local part = parts[1]
		if part then
			w = getElement(player, part.tags.path, 2)
			if w.tags.view_name ~= part.tags.view_name then
				w = find_view_root(part) or error("view root not found. view_name: '"..part.tags.view_name.."'")
			end
			break
		end
	end

	local path_dic, skip = w.tags.path_dic or {}, {["@"]=true,["."]=true,["$"]=true}
	for name, el in pairs(elements[w.tags.view_name]) do
		if not skip[name:sub(1,1)] and type(el)=="userdata" then ---@cast el LuaGuiElement
			if not el.valid then
				elements[w.tags.view_name][name] = nil
			else
				path = make_relative_path(w.tags.path, el.tags.path) or error("invalid state") ---@diagnostic disable-line: param-type-mismatch
				path_dic[name] = path
			end
		end
	end

	set_tag(w,"path_dic", path_dic)
end

---
---@param v LuaGuiElement
---<p>see also: get_view_path</p>
--- See also: @{get_view_path}
---@see get_view_path
local function register_view(v)
	local view_name = v.tags.view_name
	local path = v.tags.path
	local mod_name = v.tags.mod_name or v.get_mod()
	Storage.set("Kux-GuiLib", "view_dic", mod_name, view_name, "path", path)
end

local function unregister_view(mod_name, view_name)
	Storage.set("Kux-GuiLib", "view_dic", mod_name, view_name, "path", nil)
end

local function is_view_registered(mod_name, view_name)
	return Storage.get("Kux-GuiLib", "view_dic", mod_name, view_name, "path") ~= nil
end

local function is_view_valid(mod_name, view_name)
	local path = Storage.get("Kux-GuiLib", "view_dic", mod_name, view_name, "path")
	if not path then return false end
	local element = KuxGuiLib.__modules.Gui.getElement(path)
	return element and element.valid
end

---
---@param mod_name string
---@param view_name string
---@return string?
---<p>see also: register_view</p>
local function get_view_path(mod_name, view_name)
	local path = Storage.get("Kux-GuiLib","view_dic", mod_name, view_name, "path")
	return path
end

local function destroy_view(mod_name, view_name)
	path = get_view_path(mod_name, view_name)
	if not path then return end
	local element = KuxGuiLib.__modules.Gui.getElement(path)
	if element and element.valid then element.destroy() end
	unregister_view(mod_name,view_name)
end

---[ EXPORT ] ---------------------------------------------------------------------------------------------------------

---@class KuxGuiLib.internal.ElementFactoryUtils.prep
local prep = {
	style = prep_style,
	add = prep_add,
	children = prep_children,
	name = prep_name,
	caption = prep_caption,
	tooltip = prep_tooltip,
	post = prep_post
}

---@class KuxGuiLib.internal.ElementFactoryUtils.apply
local apply = {
	style = apply_style,
	extra = apply_extra,
	post = apply_post
}

---@class KuxGuiLib.internal.ElementFactoryUtils
local element_factory_utils = {
	prep = prep,
	apply = apply,
	set_tag = set_tag,
	set_path_dic = set_path_dic,
	update_path_dic = update_path_dic,
	getElement = getElement,
	find_view_root = find_view_root,
	register_view = register_view,
	get_view_path = get_view_path;
	destroy_view = destroy_view,
	unregister_view = unregister_view,
	is_view_registered = is_view_registered,
	is_view_valid = is_view_valid,
	reserved_name = Table.toFlagsDictionary(Table.getKeys(require("__Kux-CoreLib__/api/classes/LuaGuiElement")))
}

return element_factory_utils