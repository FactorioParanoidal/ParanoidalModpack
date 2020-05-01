--[[
Layout:

------------ flow -------------
| <label> [textbox][checkbox] |  -- inside a flow
| ------ scroll-pane -------- |
| |<col1>   ......   <col5> | | > 5 column table listing stops
| |                         | | > col1 = name, col2 = networkID;
| |                         | | > col3 = items provided / requested
------------------------------- > col4 = control signals, col5 = current deliveries

--]]
local NAME = "stop_tab"
local N_COLS = 6
local ROW_HEIGHT = 34
local ARROW_STYLE_ON = "ltnt_sort_button_on"
local ARROW_STYLE_OFF = "ltnt_sort_button_off"
local COL_WIDTH = require("script.constants").station_tab.header_col_width
local STATION_WIDTH = require("script.constants").station_tab.station_col_width
local MAX_ROWS = require("script.constants").station_tab.item_table_max_rows
local COL_COUNTS = require("script.constants").station_tab.item_table_col_count
local GC = require("ui.classes.GuiComposition")
local gcStopTab= GC(NAME, {
  params = {type = "flow", direction = "vertical", visible = false},
})
do -- build static part of UI
-- network id selector
gcStopTab:add{
  name = "button_flow",
  parent_name = "root",
  params = {type = "flow", direction = "horizontal"},
  style = {vertical_align = "center", horizontally_stretchable = true},
}
gcStopTab:add{
  name = "idSelector",
  parent_name = "button_flow",
  gui_composition = require("ui.classes.TextFieldWithRange")(
    "IDSstop",
    {
      caption = {"station.id_selector-caption"},
      tooltip = {"station.id_selector-tt"},
    }
  )
}
gcStopTab:add{
  name = "checkbox",
  parent_name = "button_flow",
  params = {
    type = "checkbox",
    state = false,
    caption = {"station.check-box-cap"},
    tooltip = {"station.check-box-tt"},
  },
  event = {id = defines.events.on_gui_checked_state_changed, handler = {"on_checkbox_changed"}},
}
gcStopTab:add{
  name = "filler_flow",
  parent_name = "button_flow",
  params = {type = "flow", direction = "horizontal"},
  style = {horizontally_stretchable = true},
}
gcStopTab:add{
  name = "filter_label",
  parent_name = "button_flow",
  params = {
    type = "label",
    caption = {"station.filter_lb"},
    style = "ltnt_label_default",
  },
}
gcStopTab:add{
  name = "filter",
  parent_name = "button_flow",
  params = {type = "textfield"},
  event = {id = defines.events.on_gui_text_changed, handler = {"on_filter_changed"}},
}
-- header row
gcStopTab:add{
  name = "header_table",
  parent_name = "root",
  params = {type = "table", column_count = N_COLS, style = "slot_table"},
  style = {horizontal_spacing = 0},
}


for i = 1,N_COLS do
  gcStopTab:add{
    name = "header_flow"..i,
    parent_name = "header_table",
    params = {type = "flow", direction = "horizontal"},
    style = {width = COL_WIDTH[i], vertical_align = "center"},
  }
  if i ~= 1 and i ~= N_COLS then
  gcStopTab:add{
    name = "header_sep"..i,
    parent_name = "header_flow"..i,
    params = {
      type = "label",
      caption = "|",
      style = "ltnt_column_header"
    },
  }
  end
  if i == 1 or i == 2 then
    gcStopTab:add{
      name = "arrow"..i,
      parent_name = "header_flow"..i,
      params = {type = "button", style = "ltnt_sort_button_off"},
      event = {id = defines.events.on_gui_click, handler = {"on_header_click"}, data = tostring(i)}
    }
  else
    gcStopTab:add{
      name = "header"..i,
      parent_name = "header_flow"..i,
      params = {
        type = "label",
        caption = {"station.header-col-"..i},
        tooltip = {"station.header-col-"..i.."-tt"},
        style = "ltnt_column_header"
      },
    }
  end
  if i == 1 then
    gcStopTab:add{
      name = "header"..i,
      parent_name = "header_flow"..i,
      params = {
        type = "label",
        caption = {"station.header-col-"..i},
        tooltip = {"station.header-col-"..i.."-tt"},
        style = "ltnt_hover_column_header"
      },
      event = {id = defines.events.on_gui_click, handler = {"on_header_click"}, data = tostring(i)}
    }
  end
end
-- table for stations inside scroll-pane
gcStopTab:add{
  name = "scrollpane",
  parent_name = "root",
  params = {type = "scroll-pane", horizontal_scroll_policy = "never"},
}
gcStopTab:add{
  name = "table",
  parent_name = "scrollpane",
  params = {type = "table", column_count = N_COLS, draw_horizontal_lines = true},
  style = {vertical_align = "top"}
}
gcStopTab.tab_index = require("script.constants").station_tab.tab_index
end

-- overloaded methods
function gcStopTab:on_init(storage_tb)
  GC.on_init(self, storage_tb)
  self.mystorage.checkbox = self.mystorage.checkbox or {}
  self.mystorage.sort_by = self.mystorage.sort_by or {}
  self.mystorage.filter = self.mystorage.filter or {}
  self.mystorage.last_filter = self.mystorage.last_filter or {}
  self.mystorage.cached_results = self.mystorage.cached_results or {}
end

function gcStopTab:build(parent, pind)
  GC.build(self, parent, pind) -- super method
  self.mystorage.checkbox[pind] = self:get_el(pind, "checkbox")
  self.mystorage.sort_by[pind] = "name"
end

-- additional methods
function gcStopTab:on_checkbox_changed(event)
  self:update(event.player_index, self.tab_index)
end

function gcStopTab:on_header_click(event, index, data_string)
  local name = event.element.name
  if data_string == "1" then
    self.mystorage.sort_by[event.player_index] = "name"
    self:get_el(event.player_index, "arrow1").style = ARROW_STYLE_ON
    self:get_el(event.player_index, "arrow2").style = ARROW_STYLE_OFF
  elseif data_string == "2"  then
    self.mystorage.sort_by[event.player_index] = "state"
    self:get_el(event.player_index, "arrow2").style = ARROW_STYLE_ON
    self:get_el(event.player_index, "arrow1").style = ARROW_STYLE_OFF
  else
    return
  end
  self:update(event.player_index, self.tab_index)
end

local function trim(s)
  local from = s:match("^%s*()")
  return from > #s and "" or s:match(".*%S", from)
end
function gcStopTab:on_filter_changed(event, data_string)
  local elem = event.element
  if elem.text and type(elem.text) == "string" then
    local input = trim(elem.text)
    if input:len() == 0 then
      self.mystorage.filter[event.player_index] = nil
    else
      self.mystorage.filter[event.player_index] = input
    end
  end
  self:update(event.player_index, self.tab_index)
end

local get_stops
do --create closure
  local sort = table.sort
  local lower = string.lower
  local find = string.find
  local insert = table.insert
	-- key: actual station name, value: lowercased name
  -- lowercase names are buffered, so lower needs to be called only once per name
	local name2lowercase = setmetatable({}, {
		__index = function(self, station_name)
			local name = lower(station_name)
			rawset(self, station_name, name)
			return name
		end,
	})
  -- sort function
  local color_order = {["signal-red"] = 0, ["signal-pink"] = 3, ["signal-blue"] = 4, ["signal-yellow"] = 4.1, ["signal-green"] = 10000}

  local get_sort_func = {
    ["name"] = function(a,b) return global.data.stops[a].name < global.data.stops[b].name end,
    ["state"] = function(a,b)
      local rank_a = color_order[global.data.stops[a].signals[1][1]] + global.data.stops[a].signals[1][2]
      local rank_b = color_order[global.data.stops[b].signals[1][1]] + global.data.stops[b].signals[1][2]
      return rank_a < rank_b
    end,
  }

	get_stops = function(self, pind)
    local data = global.data
		if not self.mystorage.filter[pind] then
      sort(data.stop_ids, get_sort_func[self.mystorage.sort_by[pind]])
      return data.stop_ids
		else
      if (not self.mystorage.last_filter[pind]) or self.mystorage.last_filter[pind] ~= self.mystorage.filter[pind] then
				self.mystorage.cached_results[pind] = {}
				local filter_lower = lower(self.mystorage.filter[pind])
				for _, stop_id in pairs(data.stop_ids) do
					local match = true
					for word in filter_lower:gmatch("%S+") do
						if not find(name2lowercase[data.stops[stop_id].name], word, 1, true) then match = false end
					end
					if match then insert(self.mystorage.cached_results[pind], stop_id) end
				end
				self.mystorage.last_filter[pind] = self.mystorage.filter[pind]
			end
      sort(self.mystorage.cached_results[pind], get_sort_func[self.mystorage.sort_by[pind]])
      return self.mystorage.cached_results[pind]
		end
	end
end

local btest = bit32.btest
local function eqtest(a,b) return a==b end
local build_item_table = require("ui.util").build_item_table
function gcStopTab:update(pind, index)
  if index == self.tab_index then
    self:show(pind)
    global.gui.active_tab[pind] = index

    local tb = self:get_el(pind, "table")
    if not tb then return end
    tb.clear()
    local ltnc_active = global.gui.ltnc_is_active
    local signal_col_count = COL_COUNTS[3] + (ltnc_active and 0 or 1)

    -- table main body
    local selected_network_id = tonumber(self.sub_gc.idSelector:get_current_value(pind))
    local testfun
    if self.mystorage.checkbox[pind].state then
      testfun = eqtest
    else
      testfun = btest
    end
    local data = global.data
    local n = #self.elem
    local stops_to_list = get_stops(self, pind)
    for i = 1, #stops_to_list do
      local stop_id = stops_to_list[i]
      if stop_id and data.stops[stop_id] then
        local stopdata = data.stops[stop_id]
        if stopdata.isDepot == false and testfun(selected_network_id, stopdata.network_id) then
          -- stop is in selected network, create table entry
          -- first column: station name
          local label = tb.add{
            type = "label",
            caption = stopdata.name,
            style = "ltnt_lb_inv_station_name",
            name = self:_create_name(i+n, stop_id),
          }
          label.style.width = STATION_WIDTH
          -- second column: status
          tb.add{
            type = "sprite-button",
            sprite = "virtual-signal/"..stopdata.signals[1][1],
            number = stopdata.signals[1][2],
            enabled = false,
            style = "ltnt_empty_button",
          }
          -- third column: provided and requested items
          build_item_table{
            parent = tb,
            provided = data.provided_by_stop[stop_id],
            requested = data.requested_by_stop[stop_id],
            columns = COL_COUNTS[1],
            enabled = false,
            max_rows = MAX_ROWS[1],
          }
          -- fourth column: current deliveries
          build_item_table{
            parent = tb,
            provided = stopdata.incoming,
            requested = stopdata.outgoing,
            columns = COL_COUNTS[2],
            max_rows = MAX_ROWS[2],
            enabled = false,
          }
          -- fifth column: control signals
          build_item_table{
            parent = tb,
            signals = stopdata.signals[2],
            columns = signal_col_count,
            max_rows = MAX_ROWS[3],
            enabled = false,
          }
          -- LTNC button
          if ltnc_active then
            tb.add{
              type = "sprite-button",
              name = self:_create_name(i+n, "cc_"..stop_id),
              sprite = "item/ltn-combinator",
              tooltip = {"station.combinator-tt"},
            }
          else
            tb.add{type = "flow"}
          end
        end
      end
    end
   else
    self:hide(pind)
  end
end
local match = string.match
function gcStopTab:event_handler(event, index, data_string)
  if match(data_string, "cc_") then
    return "on_cc_button_clicked"
  else
    return "on_stop_name_clicked"
  end
end

return gcStopTab
