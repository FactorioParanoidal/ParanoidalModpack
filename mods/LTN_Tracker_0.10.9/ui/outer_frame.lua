local GC = require("ui.classes.GuiComposition")
local N_TABS = require("script.constants").main_frame.n_tabs
local BUTTON_WIDTH = require("script.constants").main_frame.button_width
local HIGHLIGHT_STYLE = require("script.constants").main_frame.button_highlight_style
local DEFAULT_STYLE = require("script.constants").main_frame.button_default_style
local name = "outer_frame"

local gcOuterFrame = GC(name)
do -- for code folding

gcOuterFrame:add{
  name = "root",
  params = {
		type = "frame",
		direction = "vertical",
    name = "ltnt_main_frame"
	},
	style = {height = 500, top_padding = 10},
}

-- flow for title and refresh button
gcOuterFrame:add{
  name = "title_flow",
  parent_name = "root",
  params = {type = "flow", direction = "horizontal"},
}
gcOuterFrame:add{
  name = "title_lb",
  parent_name = "title_flow",
  params = {type = "label", caption = {"ltnt.mod-name"}},
  style = {font = "ltnt_font_frame_caption"},
}
gcOuterFrame:add{
  name = "spacer_flow",
  parent_name = "title_flow",
  params = {type = "flow", direction = "horizontal"},
  style = {horizontally_stretchable = true},
}
gcOuterFrame:add{
  name = "refresh_bt",
  parent_name = "title_flow",
  params = {
    type = "sprite-button",
    sprite = "ltnt_sprite_refresh",
    tooltip = {"ltnt.refresh-bt"},
  },
  event = {id = defines.events.on_gui_click, handler = "on_refresh_bt_click"},
}

-- flow for tab selector buttons
gcOuterFrame:add{
  name = "button_flow",
  parent_name = "root",
  params = {
    type="flow",
    direction="horizontal"
  },
}
for i = 1, N_TABS do
	gcOuterFrame:add{
    name= "tabbutton_" .. i,
    parent_name = "button_flow",
    params = {
      type="button",
      caption={"ltnt.tab"..i.."-caption"},
      style = "ltnt_tab_button"
    },
    --style = {width = BUTTON_WIDTH},
    event = {
      id = defines.events.on_gui_click,
      data = i,
      handler = "on_tab_changed",
    }
  }
end
gcOuterFrame:element_by_name("tabbutton_1").params.enabled = false
end --do

-- overloaded methods
function gcOuterFrame:build(parent, pind)
	GC.build(self, parent, pind)
	self:get(pind).style.height = settings.get_player_settings(game.players[pind])["ltnt-window-height"].value
end

function gcOuterFrame:toggle(pind)
	local new_state = GC.toggle(self, pind)
	if new_state then
		game.players[pind].opened = self:get(pind)
	end
  global.gui.is_gui_open[pind] = new_state
	return new_state
end

function gcOuterFrame:hide(pind)
	GC.hide(self, pind)
  global.gui.is_gui_open[pind] = false
end

function gcOuterFrame:show(pind)
	if self:get(pind) then
		self:get(pind).visible = true
		game.players[pind].opened = self:get(pind)
    global.gui.is_gui_open[pind] = true
	end
end

function gcOuterFrame:set_alert(pind)
  if global.gui.active_tab[pind] ~= 5 then
    local bt = self:get_el(pind, "tabbutton_5")
    if bt then
      bt.style = HIGHLIGHT_STYLE
      --bt.style.width = BUTTON_WIDTH
    end
  end
end

function gcOuterFrame:clear_alert(pind)
  local bt = self:get_el(pind, "tabbutton_5")
  if bt then
    bt.style = DEFAULT_STYLE
    --bt.style.width = BUTTON_WIDTH
  end
end
-- additional methods
function gcOuterFrame:update_buttons(pind, new_tab)
	local tab_buttons = self:get_buttons(pind)
	for i = 1, N_TABS do
    if tab_buttons[i] then
      tab_buttons[i].enabled = (i ~= new_tab)
    end
	end
  global.gui.active_tab[pind] = new_tab
  if new_tab == 5 then
    self:clear_alert(pind)
  end
end

function gcOuterFrame:get_buttons(pind)
	local buttons = {}
	for i = 1, N_TABS do
		buttons[i] = self:get_el(pind, "tabbutton_"..i)
	end
	return buttons
end

return gcOuterFrame