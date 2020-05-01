--[[
A slot table filled with item icons + number.
Subclass of GuiComposition.

Required args:
  name -- a unique name for the underlying GuiComposition object.
          Has to be a string consisting only of alphanumeric characters and underscores
Optional args, provided in a table:
  column_count, caption,
  enabled       -- makes icons clickable [default = false]
  button_style  -- button background color: (nil or false) = grey, 1 = green, 2 = red
  use_placeholders -- A number. Fills table up to that amount with empty icons.

Layout:

--- frame + table -----
|  [icon] ... [icon]   |  -- column_count specifies number of icons per row
|  [icon] ... [icon]   |
|  [icon] ... [icon]   |
|  [icon] ... [icon]   |
------------------------

--]]
-- helper functions
local gsub = string.gsub
local item2sprite = require("ui.util").item2sprite

---------------------------------
-- class setup and constructor --
---------------------------------
local GuiComposition = require("ui.classes.GuiComposition")
local ItemTable = {}

ItemTable.__index = ItemTable
setmetatable(ItemTable, {
	__index = GuiComposition,  -- inherit from GuiComposition
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:_init(...)
		return self
	end,
})

function ItemTable:_init(name, args)
	self.columns = args.column_count or 2
	local enabled = args.enabled or false
	local frame_caption = args.caption or nil
  local height = args.minimal_height or nil
  if not args.button_style then
    self.button_style = "ltnt_empty_button"
  elseif args.button_style == 2 then
    self.button_style = "ltnt_requested_button"
  else
    self.button_style = "ltnt_provided_button"
  end
  self.min_buttons = args.use_placeholders or 0

  -- call super constructor and add elements
  GuiComposition._init(self, name)
  -- frame around the table
	--local width = 34*self.columns+2
  self:add{
    name = "root",
    params = {
      type = "frame",
      style = "frame",
      caption = frame_caption,
		},
		style = {
      horizontal_align = "center",
      minimal_height = height,
      top_padding = 0,
      bottom_padding = 0,
      left_padding = 0,
      right_padding = 0
    },
	}
  self:add{
    name = "table",
    parent_name = "root",
    params = {
			type = "table",
			column_count = self.columns,
			style = "slot_table",
		},
		--style = {width = width},
	}
end

-- overload super methods
function ItemTable:on_init(storage_tb)
  GuiComposition.on_init(self, storage_tb)
  self.mystorage.table = self.mystorage.table or {}
end

function ItemTable:build(parent, pind)
	GuiComposition.build(self, parent, pind)
  self.mystorage.table[pind] = self:get_el(pind, "table")
  self:update_table(pind, {})
end

function ItemTable:destroy(pind)
  self.mystorage.table[pind] = nil
  return GuiComposition.destroy(self, pind)
end

function ItemTable:event_handler(event, index, data_string)
  return "on_item_clicked"
end

--additional methods
function ItemTable:update_table(pind, item_list)
	local tb = self.mystorage.table[pind]
	tb.clear()
  local count = 0
  local offset = #self.elem
	for item, amount in pairs(item_list) do
    count = count + 1
		tb.add{
			type = "sprite-button",
			sprite = item2sprite(item),
			number = amount,
			name = self:_create_name(count + offset, item),
      style = self.button_style,
		}
	end
  while count <= self.min_buttons or count % self.columns > 0  do
    tb.add{type = "sprite-button", sprite = "", style = self.button_style, enabled = false}
    count = count + 1
  end
end

return ItemTable