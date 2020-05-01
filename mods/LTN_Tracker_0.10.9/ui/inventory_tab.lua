-- localize helper functions
local get_items_in_network = require("script.util").get_items_in_network

-- set/get constants
local NAME = "inv_tab"
local N_SUBPANES = 4
local IT_COL_COUNT = require("script.constants").inventory_tab.item_table_column_count

local gcInvTab= require("ui.classes.GuiComposition")(NAME, {
  params = {type = "flow", direction = "vertical", visible = false}
})

-- add ID selector
gcInvTab:add{
  name = "idSelector",
  parent_name = "root",
  gui_composition = require("ui.classes.TextFieldWithRange")(
    "IDSinv",
    {
      caption = {"inventory.id_selector-caption"},
      tooltip = {"inventory.id_selector-tt"},
    }
  )
}

-- flow for tab main body
gcInvTab:add{
  name = "flow",
  parent_name = "root",
  params = {type = "flow", direction = "horizontal"},
}

gcInvTab:add{
  name = "spane",
  parent_name = "flow",
  params = {
    type = "scroll-pane",
    horizontal_scroll_policy = "never",
    vertical_scroll_policy = "auto-and-reserve-space",
  },
}

-- add item tables
local IT = require("ui.classes.ItemTable")
gcInvTab:add{
  name = "provided",
  parent_name = "spane",
  gui_composition = IT("inv_provided", {
    column_count = IT_COL_COUNT,
    enabled = true,
    caption = {"inventory.provide-caption"},
    button_style = 1, --green background
    use_placeholders = IT_COL_COUNT*2-1,
  })
}
gcInvTab:add{
  name = "requested",
  parent_name = "spane",
  gui_composition = IT("inv_requested", {
    column_count = IT_COL_COUNT,
    enabled = true,
    caption = {"inventory.request-caption"},
    button_style = 2, --red background
    use_placeholders = IT_COL_COUNT*2-1,
  })
}
gcInvTab:add{
  name = "transit",
  parent_name = "spane",
  gui_composition = IT("inv_transit", {
    column_count = IT_COL_COUNT,
    enabled = true,
    caption = {"inventory.transit-caption"},
    use_placeholders = IT_COL_COUNT*2-1,
  })
}

gcInvTab.tab_index = require("script.constants").inventory_tab.tab_index
-- details pane on the right side
gcInvTab:add{
  name = "details",
  parent_name = "flow",
  gui_composition = require("ui.inventory_tab.details_pane"),
}

-- additional methods
function gcInvTab:update(pind, index)
  if index == self.tab_index then
    self:show(pind)
    global.gui.active_tab[pind] = index
    local selected_network_id = self.sub_gc.idSelector:get_current_value(pind)
    local data = global.data
    local itemTables = self.sub_gc
    itemTables.provided:update_table(pind, get_items_in_network(data.provided, selected_network_id))
    itemTables.requested:update_table(pind, get_items_in_network(data.requested, selected_network_id))
    itemTables.transit:update_table(pind, get_items_in_network(data.in_transit, selected_network_id))
    itemTables.details:set_item(pind, selected_network_id)
  else
    self:hide(pind)
  end
end

function gcInvTab:on_item_clicked(pind, data_string)
  self.sub_gc.details:set_item(pind, self.sub_gc.idSelector:get_current_value(pind), data_string)
end


return gcInvTab