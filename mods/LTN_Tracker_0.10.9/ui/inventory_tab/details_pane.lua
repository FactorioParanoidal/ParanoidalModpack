--[[
Layout:

------------ frame ------------
| <item name>    [item icon]  |  -- inside a flow
| <provided>        <NUBMER>  |  >
| <requested>       <NUBMER>  |  > inside of a table with two columns
| <transit>         <NUBMER>  |  >
| <table caption>             |
| <col1>   <col2>   <col3>    | > table listing stations
| <col1>   <col2>   <col3>    | > col1 = name col2 = networkID;
| .....                       | > col3 = items provided / requested
-------------------------------
--]]

-- set/get constants
local TOTAL_WIDTH = require("script.constants").inventory_tab.details_width
local COL_COUNT =  require("script.constants").inventory_tab.details_item_tb_col_count
local COL_WIDTH_STN = require("script.constants").inventory_tab.details_tb_col_width_stations
local COL_WIDTH_DEL = require("script.constants").inventory_tab.details_tb_col_width_deliveries
local SUM_LABEL_WIDTH =  TOTAL_WIDTH - 150
local NAME = "inv_details"

local GC = require("ui.classes.GuiComposition")
local gcDetails = GC(NAME, {
  params = {
    type = "frame",
    direction = "vertical",
    caption = {"inventory.detail-caption"},
    style = "tool_bar_frame"
  },
  style = {width = TOTAL_WIDTH, left_padding = 3, right_padding = 3}
})

-- header line with item name and icon
gcDetails:add{
  name = "header_flow",
  parent_name = "root",
  params = {type = "flow", direction = "horizontal"}
}
gcDetails:add{
  name = "item_label",
  parent_name = "header_flow",
  params = {type = "label", caption = "", style = "ltnt_label_default"},
  style = {font = "ltnt_font_subheading", width = TOTAL_WIDTH - 75},
}
gcDetails:add{
  name = "item_icon",
  parent_name = "header_flow",
  params = {type = "sprite-button", sprite = "item-group/intermediate-products", enabled = false},
}
-- summary at the top of the pane
gcDetails:add{
  name = "summary_tb",
  parent_name = "root",
  params = {type = "table", column_count = 2, style = "slot_table"}
}
gcDetails:add{
  name = "tprov_label",
  parent_name = "summary_tb",
  params = {type = "label", caption = {"inventory.detail-prov"}, style = "ltnt_summary_label"},
  style = {width = SUM_LABEL_WIDTH},
}
gcDetails:add{
  name = "tprov_num",
  parent_name = "summary_tb",
  params = {type = "label", caption = "0", style = "ltnt_summary_number"},
}
gcDetails:add{
  name = "treq_label",
  parent_name = "summary_tb",
  params = {type = "label", caption = {"inventory.detail-req"}, style = "ltnt_summary_label"},
  style = {width = SUM_LABEL_WIDTH},
}
gcDetails:add{
  name = "treq_num",
  parent_name = "summary_tb",
  params = {type = "label", caption = "0", style = "ltnt_summary_number"},
}
gcDetails:add{
  name = "ttr_label",
  parent_name = "summary_tb",
  params = {type = "label", caption = {"inventory.detail-tr"}, style = "ltnt_summary_label"},
  style = {width = SUM_LABEL_WIDTH},
}
gcDetails:add{
  name = "ttr_num",
  parent_name = "summary_tb",
  params =  {type = "label", caption = "0", style = "ltnt_summary_number"},
}

-- scrollpane for following tables
gcDetails:add{
  name = "scroll",
  parent_name = "root",
  params = {
    type = "scroll-pane",
    vertical_scroll_policy = "auto-and-reserve-space",
    horizontal_scroll_policy = "never",
  },
}

-- table with label listing stops
gcDetails:add{
  name = "stoptb_label",
  parent_name = "scroll",
  params = {type = "label", style = "ltnt_column_header", caption = {"inventory.stop_header_p"}}
}
gcDetails:add{
  name = "stoptb",
  parent_name = "scroll",
  params = {type = "table", column_count = 1},
  style = {vertical_align = "center", horizontal_spacing = 0},
}
gcDetails:add{
  name = "desc",
  parent_name = "stoptb",
  params = {type = "label", caption = {"inventory.detail_label"}, style = "ltnt_label_default"},
  style = {single_line = false, width = TOTAL_WIDTH - 30},
}

-- table with label listing deliveries
gcDetails:add{
  name = "deltb_label",
  parent_name = "scroll",
  params = {type = "label", style = "ltnt_column_header", caption = {"inventory.del_header"}}
}
gcDetails:add{
  name = "deltb",
  parent_name = "scroll",
  params = {type = "table", column_count = 1},
  style = {vertical_align = "center", horizontal_spacing = 0},
}

-- overloaded methods
function gcDetails:on_init(storage_tb)
  GC.on_init(self, storage_tb)
  self.mystorage.selected_item = self.mystorage.selected_item or {}
end

function gcDetails:event_handler(event, index, data_string)
  return "on_stop_name_clicked"
end

-- additional methods
-- cache functions
local btest = bit32.btest
local match = string.match
local get_items_in_network = require("script.util").get_items_in_network
local build_item_table = require("ui.util").build_item_table

function gcDetails:set_item(pind, network_id, ltn_item)
  ltn_item = ltn_item or self.mystorage.selected_item[pind]
  if not ltn_item then return end
  self.mystorage.selected_item[pind] = ltn_item
  local item_type, item_name = match(ltn_item, "([^,]+),(.+)") -- format: "<item_type>,<item_name>"
  local localised_name = item_name
  local get = self.get_el
  local data = global.data
  -- set item name and icon
  local proto
  if item_type == "fluid" then
    proto = game.fluid_prototypes[item_name]
  elseif item_type == "item" then
    proto = game.item_prototypes[item_name]
  end
  local spritepath = proto and item_type .. "/" .. item_name or ""
  get(self, pind, "item_label").caption = proto and proto.localised_name or item_name
  get(self, pind, "item_icon").sprite = spritepath

  -- update totals
	get(self, pind, "tprov_num").caption = get_items_in_network(data.provided, network_id)[ltn_item] or 0
	get(self, pind, "treq_num").caption = get_items_in_network(data.requested, network_id)[ltn_item] or 0
	get(self, pind, "ttr_num").caption = get_items_in_network(data.in_transit, network_id)[ltn_item] or 0


  -- update stop table with relevant stops
  local tb = get(self, pind, "stoptb")
  local create_name = self._create_name
  tb.clear()
  -- all stops providing /requesting the selected item
  local index = #self.elem
  if data.item2stop[ltn_item] then
		for _,stop_id in pairs(data.item2stop[ltn_item]) do
      local stop = data.stops[stop_id]
      if btest(stop.network_id, network_id) then
        index = index + 1
        local outer_flow = tb.add{type = "flow"}
        local label = outer_flow.add{
          type = "label",
          caption = stop.name,
          style = "ltnt_hover_bold_label",
          name = create_name(self, index, stop_id)
        }
        label.style.single_line = false
        index = index + 1
        label.style.width = COL_WIDTH_STN[1]
        --label.style.single_line = false
        label = outer_flow.add{
          type = "label",
          caption = "ID: " ..stop.network_id,
          style = "ltnt_hoverable_label",
          name = create_name(self, index, stop_id),
        }
        label.style.width = COL_WIDTH_STN[2]
        local inner_flow = tb.add{type = "flow"}
        build_item_table{
          parent = inner_flow,
          provided = data.provided_by_stop[stop_id],
          requested = data.requested_by_stop[stop_id],
          columns = COL_COUNT,
          max_rows = 2,
        }
        inner_flow.add{type = "flow", horizontally_stretchable = true}
      end
		end
	end

  -- update delivery table
  tb = get(self, pind, "deltb")
  tb.clear()
  if data.item2delivery[ltn_item] then
		for _,delivery_id in pairs(data.item2delivery[ltn_item]) do
      local delivery = data.deliveries[delivery_id]
      if btest(delivery.networkID or -1, network_id) then
        local flow = tb.add{type = "flow"}
        flow.style.vertical_align = "center"
        index = index + 1
        local label = flow.add{
          type = "label",
          caption = delivery.from,
          style = "ltnt_hover_bold_label",
          name = create_name(self, index, delivery.from_id)
        }
        label.style.width = COL_WIDTH_DEL[1]
        label.style.single_line = false
        label = flow.add{
          type = "label",
          caption = " >> ",
          style = "ltnt_label_default",
        }
        label.style.width = COL_WIDTH_DEL[2]
        index = index + 1
        label = flow.add{
          type = "label",
          caption = delivery.to,
          style = "ltnt_hover_bold_label",
          name = create_name(self, index, delivery.to_id)
        }
        label.style.width = COL_WIDTH_DEL[3]
        label.style.single_line = false
        flow = tb.add{type = "flow"}
        build_item_table{
          parent = flow,
          provided = delivery.shipment,
          columns = COL_COUNT,
          max_rows = 2,
        }
        flow.add{type = "flow", horizontally_stretchable = true}
      end
		end
	end
end

return gcDetails