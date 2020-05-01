-- constants
local NAME = "alert_tab"
local FRAME_WIDTH = require("script.constants").alert_tab.frame_width
local N_COLS = require("script.constants").alert_tab.n_columns
local COL_WIDTH = require("script.constants").alert_tab.col_width

-- object creation
local GC = require("ui.classes.GuiComposition")
local gcAlertTab= GC(NAME, {
  params = {type = "flow", direction = "vertical", visible = false},
})
gcAlertTab.tab_index = require("script.constants").alert_tab.tab_index

-- header row for table and delete button

gcAlertTab:add{
  name = "header_flow",
  parent_name = "root",
  params = {type = "flow", direction = "horizontal"},
  style = {width = FRAME_WIDTH, vertical_align = "bottom"}
}

gcAlertTab:add{
  name = "header_tb_r",
  parent_name = "header_flow",
  params =  {type = "table", column_count = N_COLS},
}
for i = 1,N_COLS-2 do
  gcAlertTab:add{
    name = "header_r"..i,
    parent_name = "header_tb_r",
    params = {
      type = "label",
      caption={"alert.header-col-r-"..i},
      style="ltnt_column_header"
    },
    style = {width = COL_WIDTH[i]}
  }
end
gcAlertTab:add{
  name = "spacer_flow",
  parent_name = "header_flow",
  params = {type = "flow"},
  style = {horizontally_stretchable = true}
}
gcAlertTab:add{
  name = "delete_bt",
  parent_name = "header_flow",
  params = {
    type = "sprite-button",
    sprite = "ltnt_sprite_delete",
    tooltip = {"alert.delete-all-tt"},
  },
  event = {id = defines.events.on_gui_click, handler = "clear_train_alerts"}
}
gcAlertTab:element_by_name("header_r3").params.tooltip = {"alert.header-col-r-3-tt"}
gcAlertTab:element_by_name("header_r3").style.width = COL_WIDTH[3]+30
gcAlertTab:add{name = "pane_r", parent_name = "root", params = {type = "scroll-pane"}}
gcAlertTab:add{
  name = "table_r",
  parent_name = "pane_r",
  params =  {type = "table", column_count = N_COLS, draw_horizontal_lines = true, cell_padding = 2},
}

-- additional functions
local error_string = require("script.constants").ltn.error_string_lookup
local state_dict = require("script.constants").train_state_dict
local build_item_table = require("ui.util").build_item_table
function gcAlertTab:build_route_labels(parent, index, delivery) -- helper function for gcAlertTab:update
  if delivery.to and delivery.from then
    local inner_tb = parent.add{type = "table", column_count = 1}
    inner_tb.style.horizontal_align = "center"
    inner_tb.style.horizontal_spacing = 0
    inner_tb.style.vertical_spacing = 0

    local elem = inner_tb.add{
      type = "label",
      caption =delivery.from,
      tooltip = delivery.from,
      style = "ltnt_hoverable_label",
      name = self:_create_name(index, "f" .. (delivery.from_id or "0"))
    }
    elem.style.width = COL_WIDTH[1]
    index = index + 1
    elem = inner_tb.add{
      type = "label",
      caption = delivery.to,
      tooltip = delivery.to,
      style = "ltnt_hoverable_label",
      name = self:_create_name(index, "t" ..(delivery.to_id or "0"))
    }
    elem.style.width = COL_WIDTH[1]
    index = index + 1
  else
    local elem = parent.add{
    type = "label",
    caption = "unknown",
    style = "ltnt_label_default",
    }
    elem.style.width = COL_WIDTH[1]
  end
  -- depot name
  local elem = parent.add{
    type = "label",
    caption = delivery.depot,
    tooltip = delivery.depot,
    style = "ltnt_label_default",
  }
  elem.style.vertical_align = "center"
  elem.style.width = COL_WIDTH[2]
  return index
end
function gcAlertTab:build_buttons(parent, index, loco_id, enabled) -- helper function for gcAlertTab:update
  local inner_tb = parent.add{type = "table", column_count = 2, style = "slot_table"}
  local elem = inner_tb.add{
    type = "sprite-button",
    sprite = "ltnt_sprite_enter",
    tooltip = {"alert.select-tt"},
    enabled = enabled,
    name = self:_create_name(index, "s" .. loco_id),
  }
  elem = inner_tb.add{
    type = "sprite-button",
    sprite = "ltnt_sprite_delete",
    tooltip = {"alert.delete-tt"},
    name = self:_create_name(index, "d" .. loco_id),
  }
end

function gcAlertTab:update(pind, tab_index)
  if tab_index == self.tab_index then
    self:show(pind)
    global.gui.active_tab[pind] = tab_index

    -- right side: table listing trains with residual items or error state
    local tb = self:get_el(pind, "table_r")
    if not tb then return end
    tb.clear()
    local index = 1 + #self.elem
    if next(global.data.trains_error) then
      for error_id, error_data in pairs(global.data.trains_error) do
        index = self:build_route_labels(tb, index, error_data.delivery)
        if error_data.type == "residuals" then
          local elem = tb.add{
            type = "label",
            caption = {"error.train-leftover-cargo"},
            tooltip = {"error.train-leftover-cargo-tt"},
            style = "ltnt_error_label",
          }
          elem.style.width = COL_WIDTH[3]
          -- residual item overview
          elem = tb.add{type = "flow", direction = "vertical"}
          build_item_table{
            parent = elem,
            provided = error_data.delivery.shipment,
            columns = 6,
            no_negate = true,
          }
          build_item_table{
            parent = elem,
            requested = error_data.cargo[2],
            columns = 6,
            type = error_data.cargo[1],
            no_negate = true,
          }
          self:build_buttons(tb, index, error_id, true)
        elseif error_data.type == "incorrect_cargo" then
          -- cargo table
          local elem = tb.add{
            type = "label",
            caption = {"error.train-incorrect-cargo"},
            tooltip = {"error.train-incorrect-cargo-tt"},
            style = "ltnt_error_label",
          }
          elem.style.width = COL_WIDTH[3]
          elem = tb.add{type = "flow", direction = "vertical"}
          build_item_table{
            parent = elem,
            provided = error_data.delivery.shipment,
            columns = 6,
            no_negate = true,
          }
          build_item_table{
            parent = elem,
            requested = error_data.cargo,
            columns = 6,
            no_negate = true,
          }
          self:build_buttons(tb, index, error_id, true)
        elseif error_data.type == "timeout" then
          local elem
          if error_data.delivery.pickupDone then
            elem = tb.add{
              type = "label",
              caption = {"error.train-timeout-post-pickup"},
              tooltip = {"error.train-timeout-post-pickup-tt"},
              style = "ltnt_error_label",
            }
          else
            elem = tb.add{
              type = "label",
              caption = {"error.train-timeout-pre-pickup"},
              tooltip = {"error.train-timeout-pre-pickup-tt"},
              style = "ltnt_error_label",
            }
          end
          elem.style.width = COL_WIDTH[3]
          build_item_table{
            parent = tb,
            provided = error_data.delivery.shipment,
            columns = 6,
            no_negate = true,
          }
          self:build_buttons(tb, index, error_id, true)
        else
          --train invalid
          local elem = tb.add{
            type = "label",
            caption = {"error.train-invalid"},
            caption = {"error.train-invalid-tt"},
            style = "ltnt_error_label",
          }
          elem.style.width = COL_WIDTH[3]
          elem = tb.add{type = "flow"}
          elem.style.width = COL_WIDTH[4]
          self:build_buttons(tb, index, error_id, false)
        end
      end
      index = index + 1
    else
      local elem = tb.add{
        type = "label",
        caption = {"alert.no-error-trains"},
        style = "ltnt_label_default",
      }
    end
  else
    self:hide(pind)
  end
end

local tonumber = tonumber
function gcAlertTab:event_handler(event, index, data_string)
  local tag = data_string:sub(1, 1)
  local entity_id = tonumber(data_string:sub(2))
  if tag == "s" then
    -- select train
    return "on_entity_clicked", global.data.trains_error[entity_id].loco
  elseif tag == "d" then
    -- remove train from error list
    global.data.trains_error[entity_id] = nil
    self:update(event.player_index, self.tab_index)
    return nil
  elseif tag == "t" or tag == "f" then
    return "on_stop_name_clicked", entity_id
  else
    log2("Invalid data string.\nEvent:", event, "\nindex:", index, "\ndata_string:", data_string, "\nalert_tab state:", self)
    return nil
  end
end
--test
return gcAlertTab