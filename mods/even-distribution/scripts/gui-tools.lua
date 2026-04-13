local gui = {}
local util = scripts.util
local templates = scripts["gui-templates"]
-- local mod_gui = require("mod-gui")

local helpers = scripts.helpers
local _ = helpers.on

local MAX_DUPLICATES = 1000

-- GUI events are saved in storage.guiEvents["EVENT NAME"][PLAYER INDEX][GUI ELEMENT INDEX]
local eventHandlers = {} -- FIXME: support multiple events (curently all events saved under same ID in eventHandlers)

local events = {
	on_gui_checked_state_changed   = "onCheckedStateChanged",
	on_gui_click                   = "onClicked", 
	on_gui_elem_changed            = "onElementChanged", 
	on_gui_selection_state_changed = "onSelectionStateChanged", 
	on_gui_text_changed            = "onTextChanged",
	on_gui_value_changed           = "onValueChanged",
	on_gui_confirmed               = "onConfirmed",
	on_gui_selected_tab_changed    = "onSelectedTabChanged",
	on_gui_switch_state_changed    = "onSwitchStateChanged",
	on_gui_location_changed        = "onLocationChanged",
}

local onChangedEvents = {
	["checkbox"]           = "onCheckedStateChanged",
	["radiobutton"]        = "onCheckedStateChanged",
	["choose-elem-button"] = "onElementChanged",
	["button"]             = "onClicked",
	["sprite-button"]      = "onClicked",
	["drop-down"]          = "onSelectionStateChanged",
	["list-box"]           = "onSelectionStateChanged",
	["textfield"]          = "onTextChanged",
	["text-box"]           = "onTextChanged",
	["slider"]             = "onValueChanged",
	["tabbed-pane"]        = "onSelectedTabChanged",
	["switch"]             = "onSwitchStateChanged",
}

local specialParameters = {
	children                = true,
	onCreated               = true,
	onChanged               = true,
	onCheckedStateChanged   = true,
	onClicked               = true,
	onElementChanged        = true,
	onSelectionStateChanged = true,
	onTextChanged           = true,
	onValueChanged          = true,
	onConfirmed             = true,
	onSelectedTabChanged    = true,
	onSwitchStateChanged    = true,
	onLocationChanged       = true,
	ID                      = true,
	root                    = true,
	unique                  = true,
	content                 = true,
}

local function registerHandlers(template, ID)
	ID = ID or template.ID
	local elemName = template.name
	
	for _,event in pairs(events) do -- register event handler functions with generated ID
		if template[event] then
			eventHandlers[ID..";"..elemName] = template[event]
		end
	end
	
	if template.onChanged and onChangedEvents[template.type] then -- register unified onChanged event
		eventHandlers[ID..";"..elemName] = template.onChanged
	end
	
	if template.children then -- recursively register childs event handlers
		for _,child in ipairs(template.children) do
			registerHandlers(child, ID)
		end
	end

	if template.type == "tab" and template.content then -- build tab contents
		registerHandlers(template.content, ID)
	end
end

function gui.registerTemplates(obj) -- called when lua script is loaded initially, assigns unqiue ID to every template
	for name,template in pairs(obj.templates) do
		template.ID = obj.class..";"..name -- unique ID, obj.class is assigned by framework.lua
		registerHandlers(template)
	end
end

local function getParameters(template, name)
	local parameters = { name = name }
	for param,value in pairs(template) do
		if param ~= "name" and not specialParameters[param] then
			if param == "style" and _(value):is("table") then
				parameters.style = value.parent 
			else
				parameters[param] = value 
			end
		end
	end
	return parameters
end

-- local function getDefaultRoot(template, player)
-- 	if template.type == "button" or template.type == "sprite-button" then
-- 		return mod_gui.get_button_flow(player)
-- 	end
	
-- 	return mod_gui.get_frame_flow(player)
-- end

local function getRoot(template, player)
	-- if template.root then
		return template.root(player) --, getDefaultRoot(template, player))
	-- end
	
	-- return getDefaultRoot(template, player)
end

function gui.create(player, template, data, parent, ID) -- recursively builds a gui from a template
	ID = ID or template.ID
	parent = parent or getRoot(template, player)
	
	local elemName = template.name
	local uniqueElemName = elemName
	if template.unique == false then 
	
		-- duplicates are named NAME[i] where i is the index starting at 1 (-> multiple can exist at once)
		for i = 1, MAX_DUPLICATES do
			if not parent[elemName.."#"..i] then
				uniqueElemName = elemName.."#"..i
				break
			end
		end
		
	elseif template.ID then -- destroy any existing instances of this template if it's not unique
		gui.destroy(player, template, parent)
	end
	
	local created = parent.add(getParameters(template, uniqueElemName)) -- create gui element

	-- Apply custom styles
	local style = _(template.style)
	if style:is("table") then
		_(created.style):set(style:unlesskey("parent"))
	end
	
	local index = created.player_index
	for event,list in pairs(storage.guiEvents) do -- register events
		if template[event] then
			list[index] = list[index] or {}
			list[index][created.index] = ID..";"..elemName
		end
	end
	
	if template.onChanged and onChangedEvents[template.type] then -- register unified onChanged event
		local list = storage.guiEvents[onChangedEvents[template.type]]
		list[index] = list[index] or {}
		list[index][created.index] = ID..";"..elemName
	end
	
	if template.children then -- build children
		for _,child in ipairs(template.children) do
			gui.create(player, child, data, created, ID)
		end
	end

	if template.type == "tab" and parent.type == "tabbed-pane" and template.content then -- build tab contents
		parent.add_tab(created, gui.create(player, template.content, data, parent, ID))
	end
	
	if template.onCreated then template.onCreated(created, data) end -- fire onCreated event
	return created
end

function gui.get(player, template, parent) -- get the gui element matching the given template (unique templates only)
	parent = parent or getRoot(template, player)
	return parent[template.name]
end

function gui.getAll(player, template, parent) -- get table of all gui elements matching the given template (unique and non-unique)
	parent = parent or getRoot(template, player)
	local result = {}
	
	if template.unique == false then -- destroy all
		local regex = "^"..util.escape(template.name).."#[0-9]+$"
	
		for _,child in pairs(parent.children) do
			if child.name:find(regex) then
				result[#result + 1] = child
			end
		end
	else
		result[1] = gui.get(player, template, parent)
	end
	
	return result
end

function gui.destroy(player, template, parent) -- destroy all gui elements matching the given template
	for _,child in ipairs(gui.getAll(player, template, parent)) do
		util.destroyIfValid(child)
	end
end

local function handleGuiEvent(event, name)
	if event.element.get_mod() == script.mod_name then
		local handlers = storage.guiEvents[name][event.player_index]
		if handlers then
			local handler = handlers[event.element.index]
			if handler and eventHandlers[handler] then eventHandlers[handler](event.element, event) end
		end
	end
end

-- register game gui events
for gameEvent,translated in pairs(events) do
	gui[gameEvent] = function(event)
		handleGuiEvent(event, translated)
	end
end

return gui