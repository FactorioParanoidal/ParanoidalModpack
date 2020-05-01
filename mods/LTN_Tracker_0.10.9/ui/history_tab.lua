-- localize helper functions
local build_item_table = require("ui.util").build_item_table
local tick2timestring = require("__OpteraLib__.script.misc").ticks_to_timestring

-- set/get constants
local N_COLS = require("script.constants").history_tab.n_columns
local N_COLS_SHIP = require("script.constants").history_tab.n_cols_shipment
local COL_WIDTH = require("script.constants").history_tab.col_width
local H_COL_WIDTH = require("script.constants").history_tab.header_col_width
local HISTORY_LIMIT = require("script.constants").proc.history_limit
local NAME = "hist_tab"

local gcHistTab = require("ui.classes.GuiComposition")(NAME, {
  params = {type = "flow", direction = "vertical", visible = false},
})

-- header row
gcHistTab:add{
  name = "header_table",
  parent_name = "root",
  params = {
    type = "table",
    column_count = N_COLS+1,
    style = "table_with_selection"
  }
}
for i = 1,N_COLS do
  gcHistTab:add{
    name = "header"..i,
    parent_name = "header_table",
    params = {
      type = "label",
      caption = {"history.header-col-"..i},
      tooltip = {"history.header-col-"..i.."-tt"},
      style = "ltnt_column_header"
    },
    style = {width = H_COL_WIDTH[i]}
  }
end
gcHistTab:add{
  name = "delete_bt",
  parent_name = "header_table",
  params = {
    type = "sprite-button",
    sprite = "ltnt_sprite_delete",
    tooltip = {"history.delete-tt"},
  },
  event = {id = defines.events.on_gui_click, handler = "clear_history"}
}


-- main table
gcHistTab:add{name = "pane", parent_name = "root", params = {type = "scroll-pane"}}
gcHistTab:add{
  name = "table",
  parent_name = "pane",
  params = {
    type = "table",
    column_count = N_COLS,
    caption = {"history.table-caption"},
    style = "table_with_selection",
  },
  style = {vertical_align = "center"}
}
gcHistTab.tab_index = require("script.constants").history_tab.tab_index

-- overloaded methods
function gcHistTab:event_handler(event, index, data_string)
  return "on_stop_name_clicked"
end

-- additional methods
function gcHistTab:update(pind, index)
  if index == self.tab_index then
    self:show(pind)
    global.gui.active_tab[pind] = index
    local hist_table = self:get_el(pind, "table")
    if not hist_table then return end
    local history_data = global.data.delivery_hist
    hist_table.clear()

    ---- repopulate table ----
    local offset = global.data.newest_history_index
    local max = global.data.history_limit
    local idx = #self.elem
    for i = offset-1, (offset-max+1), -1 do
      -- start at (offset - 1), counting down
      -- on reaching 0, jump back up to HISTORY_LIMIT
      -- this allows reuse of the array without table inserts or deletions
      local delivery = history_data[(i > 0) and i or (i + max)]
      if delivery then
        -- involved stops and depot
        label = hist_table.add{
          type = "label",
          caption = delivery.depot,
          style = "ltnt_lb_hist_col1"
        }
        idx = idx + 1
        local label = hist_table.add{
          type = "label",
          caption = delivery.from,
          style = "ltnt_hoverable_label",
          name = self:_create_name(idx, delivery.from)
        }
        idx = idx + 1
        label.style.width = COL_WIDTH[2]
        label = hist_table.add{
          type = "label",
          caption = delivery.to,
          style = "ltnt_hoverable_label",
          name = self:_create_name(idx, delivery.to)
        }
        label.style.width = COL_WIDTH[3]
        -- network id
        label = hist_table.add{
          type = "label",
          caption = delivery.networkID,
          style = "ltnt_lb_hist_col4"
        }
        -- runtime, possibly with time-out warning
        if delivery.timed_out then
          label = hist_table.add{
            type = "label",
            caption = tick2timestring(delivery.runtime),
            tooltip = {"error.train-timeout"},
            style = "ltnt_lb_hist_col5_red",
          }
        else
          label = hist_table.add{
            type = "label",
            caption = tick2timestring(delivery.runtime),
            style = "ltnt_lb_hist_col5"
          }
        end
        -- shipement and residual items, if any
        if delivery.residuals then
          local tb = hist_table.add{type = "table", column_count = 1, style = "slot_table"}
          build_item_table{
            parent = tb,
            provided = delivery.shipment,
            columns = N_COLS_SHIP
          }
          build_item_table{
            parent = tb,
            requested = delivery.residuals[2],
            columns = N_COLS_SHIP,
            type = delivery.residuals[1],
            no_negate = true,
          }
        else
          build_item_table{
            parent = hist_table,
            provided = delivery.shipment,
            columns = N_COLS_SHIP
          }
        end -- if delivery.residuals then
      end --if delivery then
    end -- for i = -1, -99, -1 do
  else
    self:hide(pind)
  end -- if index == self.tab_index then
end
local tonumber = tonumber
function gcHistTab:event_handler(event, index, data_string)
  local stop_id = global.data.name2id[data_string]
  if stop_id then
    return "on_stop_name_clicked", stop_id
  end
end

return gcHistTab
