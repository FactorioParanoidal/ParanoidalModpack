-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB GUI MODULE
-- GUI templating and event registration.

-- dependencies
local event = require("__RaiLuaLib__.lualib.event")
local util = require("__core__.lualib.util")

-- locals
local string_gmatch = string.gmatch

local handler_data = {}

-- object
local gui = {}
local handlers = {}
local templates = {}
local template_lookup = {}

-- -----------------------------------------------------------------------------
-- TABLE OBJECTS

local function extend_table(self, data, do_return)
  for k, v in pairs(data) do
    if (type(v) == "table") then
      if (type(self[k] or false) == "table") then
        self[k] = extend_table(self[k], v, true)
      else
        self[k] = table.deepcopy(v)
      end
    else
      self[k] = v
    end
  end
  if do_return then return self end
end

handlers.extend = extend_table
templates.extend = extend_table

-- -----------------------------------------------------------------------------
-- HANDLERS AND TEMPLATES

-- generate one-dimensional template lookup table
local function generate_template_lookup(t, template_string)
  for k,v in pairs(t) do
    if k ~= "extend" and type(v) == "table" then
      local new_string = template_string..k
      if v.type then
        template_lookup[new_string] = v
      else
        generate_template_lookup(v, new_string..".")
      end
    end
  end
end

-- recursively navigate the handlers table to create the events
local function generate_handlers(t, event_string, event_groups)
  event_groups[#event_groups+1] = event_string
  for k,v in pairs(t) do
    if k ~= "extend" then
      local new_string = event_string.."."..k
      if type(v) == "function" then
        -- shortcut syntax: key is a defines.events or a custom-input name, value is just the handler
        handler_data[new_string] = {id=defines.events[k] or k, handler=v, group=table.deepcopy(event_groups)}
      elseif v.handler then
        if not v.id then
          v.id = defines.events[k] or k
        end
        v.group = table.deepcopy(event_groups)
        handler_data[new_string] = v
      else
        generate_handlers(v, new_string, event_groups)
      end
    end
  end
  event_groups[#event_groups] = nil
end

-- create template lookup and register conditional GUI handlers
event.register({"on_init_postprocess", "on_load_postprocess"}, function(e)
  -- construct template lookup table
  generate_template_lookup(templates, "")
  -- create and register conditional handlers for the GUI events
  generate_handlers(handlers, "gui", {})
  event.register_conditional(handler_data)
end)

-- -----------------------------------------------------------------------------
-- GUI CONSTRUCTION

-- recursively load a GUI template
local function recursive_build(parent, t, output, filters, player_index)
  -- load template
  if t.template then
    for k,v in pairs(template_lookup[t.template]) do
      t[k] = t[k] or v
    end
  end
  local elem
  -- special logic if this is a tab-and-content
  if t.type == "tab-and-content" then
    local tab, content
    output, filters, tab = recursive_build(parent, t.tab, output, filters, player_index)
    output, filters, content = recursive_build(parent, t.content, output, filters, player_index)
    parent.add_tab(tab, content)
  else
    -- create element
    elem = parent.add(t)
    -- apply style modifications
    if t.style_mods then
      for k,v in pairs(t.style_mods) do
        elem.style[k] = v
      end
    end
    -- apply modifications
    if t.mods then
      for k,v in pairs(t.mods) do
        elem[k] = v
      end
    end
    -- register handlers
    if t.handlers then
      local elem_index = elem.index
      local name = "gui."..t.handlers
      local group = event.conditional_event_groups[name]
      if not group then error("Invalid GUI event group: "..name) end
        -- check if this event group was already enabled
        if event.is_enabled(group[1], player_index) then
          -- append the GUI filters to include this element
          for i=1,#group do
            event.update_gui_filters(group[i], player_index, elem_index, "add")
            if filters[name] then
              filters[name][elem_index] = elem_index
            else
              filters[name] = {[elem_index]=elem_index}
            end
          end
        else
          -- enable the group
          event.enable_group(name, player_index, elem_index)
          filters[name] = {[elem_index]=elem_index}
        end
    end
    -- add to output table
    if t.save_as then
      -- recursively create tables as needed
      local prev = output
      local prev_key
      local nav
      for key in string_gmatch(t.save_as, "([^%.]+)") do
        prev = prev_key and prev[prev_key] or prev
        nav = prev[key]
        if nav then
          prev = nav
        else
          prev[key] = {}
          prev_key = key
        end
      end
      prev[prev_key] = elem
    end
    -- add children
    local children = t.children
    if children then
      for i=1,#children do
        output, filters = recursive_build(elem, children[i], output, filters, player_index)
      end
    end
  end
  return output, filters, elem
end

-- -- updates the GUI based on the template
-- local function recursive_update(parent, t, player_index)
--   local children = parent.children
--   local to_destroy = {}
--   for i=1,#t do
--     local elem = children[i]
--     local elem_t = t[i]
--     if elem_t.delete then
--       to_destroy[#to_destroy+1] = elem
--     else
--       for k,v in pairs(elem_t.mods or {}) do
--         if k ~= "children" then
--           elem[k] = v
--         end
--       end
--       local elem_style = elem.style
--       for k,v in pairs(elem_t.style_mods or {}) do
--         elem_style[k] = v
--       end
--       if elem_t.children then
--         recursive_update(elem, elem_t.children, player_index)
--       end
--     end
--   end
-- end

-- -----------------------------------------------------------------------------
-- OBJECT

function gui.build(parent, templates)
  local output = {}
  local filters = {}
  for i=1,#templates do
    output, filters = recursive_build(parent, templates[i], output, filters, parent.player_index or parent.player.index)
  end
  return output, filters
end

-- function gui.update(parent, templates)
--   recursive_update(parent, templates, parent.player_index or parent.player.index)
-- end

gui.templates = templates
gui.handlers = handlers

return gui