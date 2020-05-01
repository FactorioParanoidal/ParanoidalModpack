--[[
A textfield that rejects invalid inputs. Validation function and parameters for all elements can be provided as input.
Subclass of GuiComposition.

Required args:
  name -- a unique name for the underlying GuiComposition object.
          Has to be a string consisting only of alphanumeric characters and underscores
Optional arguments, provided in a table:
  caption, tooltip, label_style, label_style_params, textfield_style, tf_invalid_style, textfield_style_params, default_text -- should be self-explanatory
  valid_func -- a function that takes a string input and returns true or false

Layout:

---------- flow ----------
|  [label]  [textfield]  |
--------------------------

--]]

---------------------------------
-- class setup and constructor --
---------------------------------
local GuiComposition = require("ui.classes.GuiComposition")
local TFWR = {}

TFWR.__index = TFWR
setmetatable(TFWR, {
	__index = GuiComposition,  -- inherit from GuiComposition
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:_init(...)
		return self
	end,
})

function TFWR:_init(name, args)
  -- optional arguments: caption, tooltip, valid_func, label_style, label_style_params, textfield_style, tf_invalid_style, textfield_style_params, default_text

  -- input parsing
  args = args or {}
  if not(type(args) == "table") then error(log2("Optional input arguments have to be provided in a single table. Arguments provided:", args)) end
  local label_caption = args.caption or ""
  local tooltip = args.tooltip or ""
  local label_style = args.label_style or "ltnt_summary_label"
  local label_style_params = args.label_style_params or {vertical_align = "center"}
  self.tf_style = args.textfield_style or "long_number_textfield"
  self.tf_invalid_style = args.textfield_invalid_style or "ltnt_invalid_value_tf"
  local tf_style_params = args.textfield_style_params or {width = 100}
  local default_text = args.default_text or -1
  self.is_input_valid = args.valid_func or (function(input)
    local n = tonumber(input)
      return n and n == math.floor(n)
    end)
  if not(type(self.is_input_valid) == "function") then error(log2("Optional input argument valid_func has to be a function. Provided valid_func:", args.valid_func)) end
  if not(self.is_input_valid(default_text)) then error(log2("Default text \"", default_text, "\" is not valid according to validation function", self.is_input_valid)) end

  -- call super constructor and add elements
  GuiComposition._init(self, name)
  -- flow holding label and text field
  self:add{
    name = "root",
    params = {type = "flow", direction = "horizontal"},
    style = {vertical_align = "center"}
  }
  -- textfield label
  self:add{
    name = "label",
    parent_name = "root",
    params = {
      type = "label",
      caption = label_caption,
      tooltip = tooltip,
      style = label_style,
    },
    style = label_style_params,
  }
  -- textfield
  self:add{
    name = "textfield",
    parent_name = "root",
    params = {
      type = "textfield",
      text = default_text,
      tooltip = tooltip,
      style = self.tf_style,
    },
    style = tf_style_params,
    event = {id = defines.events.on_gui_text_changed, handler = "on_refresh_bt_click"}
  }
end

-- overload super methods
function TFWR:on_init(storage_tb)
  GuiComposition.on_init(self, storage_tb)
  self.mystorage.textfield = self.mystorage.textfield or {}
  self.mystorage.last_valid_value = self.mystorage.last_valid_value or {}
end

function TFWR:build(parent, pind)
	GuiComposition.build(self, parent, pind)
  self.mystorage.textfield[pind] = self:get_el(pind, "textfield")
  self.mystorage.last_valid_value[pind] = self:get_tf(pind).text
end

function TFWR:destroy(pind)
  self.mystorage.textfield[pind] = nil
  self.mystorage.last_valid_value[pind] = nil
  return GuiComposition.destroy(self, pind)
end

function TFWR:get_event_handler(event, index, data_string)
  local eid = event.name
  local pind = event.player_index
  if index <= #self.elem then
    local handler = self.events[eid][index]
    if handler == "on_refresh_bt_click" then
      local new_text = event.element.text
      if self.is_input_valid(new_text) then
        self:set_valid(pind, new_text)
        return handler --, pind
      else
        self:set_invalid(pind)
      end
    end
  else
    return self:event_handler(event, index, data_string)
  end
end
-- additional methods
function TFWR:set_invalid(pind)
	self:get_tf(pind).style = self.tf_invalid_style
end

function TFWR:set_valid(pind, new_text)
	self:get_tf(pind).style = self.tf_style
  self.mystorage.last_valid_value[pind] = new_text
end

function TFWR:get_tf(pind)
  if not(self.mystorage) then error(log2("GuiComposition object", self.name, "has not been initialized.")) end
  if not(type(pind) == "number") then error(log2("Argument has to be a player index. Argument received:", pind)) end
  return self.mystorage.textfield[pind]
end

function TFWR:get_current_value(pind)
  return self.mystorage.last_valid_value[pind]
end

return TFWR