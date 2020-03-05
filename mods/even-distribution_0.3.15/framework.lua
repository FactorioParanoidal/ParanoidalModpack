DEBUG = pcall(require, "isdebug") and true or false

scripts = {} -- custom scripts
local funcs = {} -- Functions bound to their respective game event


local function formatLuaObject(v, handler)
	if v.__self and type(v.__self) == "userdata" then
		if v.valid == true then
			if type(v.help) == "function" then
			
				-- Format LuaObjects nicely
				local help = v.help()
				local objType = help:gsub("^Help for (%w+):.*$", "%1")
				if objType == "LuaItemStack" and not v.valid_for_read then return objType.."<EMPTY>" end
				
				local t = help:find("[\r\n]type %[RW?%]") and v.type or nil
				local n = help:find("[\r\n]name %[RW?%]") and v.name or nil
				local l = help:find("[\r\n]label %[RW?%]") and v.label or nil
				local id = l and "'"..l.."'" or ""
				if l and n then id = id.." : " end
				id = id..(n or "")
				if t ~= n then
					if n and t then id = id.." : " end
					id = id..(t or "")
				end
				
				return objType.."<"..id..">"
			else
				-- No help function exists?
				return serpent.line(v)
			end
		else
			return "?<INVALID>"
		end
	else
		return handler(v)
	end
end

local function formatTable(tbl)
	local new = {}
	
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			new[k] = formatLuaObject(v, function(_v) return formatTable(_v) end)
		elseif type(v) == "function" then
			new[k] = tostring(k).."()"
		else
			new[k] = tostring(v)
		end
	end
	
	return new
end

function dlog(...) -- Print debug message
	local tick = 0
	if game then tick = game.tick end
	local msg = tick.." [ED]"
	
	for key,val in pairs({...}) do
		if type(val) == "table" then
			msg = msg.." "..formatLuaObject(val, function(_v) return serpent.line(formatTable(_v)) end)
		elseif type(val) == "function" then
			msg = msg.." "..tostring(key).."()"
		else
			msg = msg.." "..tostring(val)
		end
	end
	
	log(msg)
	if DEBUG and game then game.print(msg) end
end

local function addScript(name) -- Add a custom script
	scripts[name] = require("scripts."..name)
	return scripts[name]
end

local function addGUIScript(name)
	local gui = addScript(name..".gui-templates") -- load templates
	scripts[name..".gui-templates"] = gui[1]
	gui[2](addScript(name..".controller")) -- load controller
	
	gui[1].class = name
	scripts["gui-tools"].registerTemplates(gui[1]) -- register gui event handlers (like button onClick events etc.)
	return gui[1]
end

local function registerFunc(name, id)
	funcs[id or name] = {}
	for __,script in pairs(scripts) do
		if script[name] then table.insert(funcs[id or name], script[name]) end
	end
end

function handleEvent(event) -- Calls all script-functions with the same name as the game event that was just triggered
	for __,func in pairs(funcs[event.input_name or event.name]) do func(event) end
end

local function registerHandler(name, id) -- Register appropriate handler functions for game events if needed
	registerFunc(name, id ~= true and id or nil)
	if id ~= true and #funcs[id or name] > 0 then 
		if id then
			script.on_event(id, handleEvent)
		else
			script[name](function(data) handleEvent{ name = name, data = data } end)
		end
	end
end

local function registerDefaultHandlers() -- Register every script-function with the same name as a game event to be called when it occurs
    dlog("Registering default event handlers...")
    
    registerHandler("on_init")
    registerHandler("on_load")
    registerHandler("on_configuration_changed")

    for name,event in pairs(defines.events) do
        registerHandler(name, event) 
    end

    registerHandler("on_scripts_initialized", true) -- custom
end

local function initDone()
    handleEvent{ name = "on_scripts_initialized" }
    dlog("Successfully initialized")
end

local function addScripts(scripts)
    dlog("Registering custom scripts...")

    for __,script in ipairs(scripts) do
        if type(script) == "table" then
            if (script.type == "GUI") then
                dlog("GUI-Script:", script.name)
                addGUIScript(script.name)
            else
                dlog("WARNING: Unknown script type:", script)
            end
        else
            dlog("Script:", script)
            addScript(script)
        end
    end
end

local function addInputs(inputs)
    dlog("Registering custom inputs...")

    for __,input in ipairs(inputs) do
        local event = "on_"..input:gsub("-", "_")

        dlog("Input:", input, "  event:", event)
        registerHandler(event, input)
    end
end


GUI = function(name)  
    return { name = name, type = "GUI" } 
end

return function(config)
    dlog("Initializing framework...", "DEBUG =",DEBUG)

    if config then
        if (config.scripts) then
            addScripts(config.scripts)
        end

        registerDefaultHandlers()

        if (config.inputs) then
            addInputs(config.inputs)
        end

        initDone()
    else
        dlog("WARNING: No framework config found!")
    end

    GUI = nil
end
