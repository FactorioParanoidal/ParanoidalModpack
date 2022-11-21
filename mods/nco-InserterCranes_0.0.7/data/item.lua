local util = require("util")

local make_layered_icon = require("icon")

local function make_crane_item(itemName, newName, wide)
  local item = util.table.deepcopy(data.raw["item"][itemName])
  make_layered_icon(item,wide)
  item.name = newName
  item.place_result = newName
  item.stack_size = 10
  item.localised_name = nil
  -- ToDo layered icon
  --log("item"..serpent.block(item))
  data:extend({item})
end
return make_crane_item
