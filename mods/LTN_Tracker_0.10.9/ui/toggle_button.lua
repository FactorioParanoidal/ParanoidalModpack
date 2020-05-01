local NAME = "toggle_button"
local GC = require("ui.classes.GuiComposition")

local TB_WITH_ALERT_SPRITE = require("script.constants").main_frame.button_sprite_alert
local TB_WITHOUT_ALERT_SPRITE = require("script.constants").main_frame.button_sprite_bare

local gcTB = GC(NAME, {
  params = {
		type = "sprite-button",
		sprite = TB_WITHOUT_ALERT_SPRITE,
    style = "mod_gui_button",
		tooltip = {"ltnt.main-button-tooltip"},
	},
  event = {id = defines.events.on_gui_click, handler = "on_toggle_button_click"},
})

function gcTB:set_alert(pind)
  if global.gui.is_gui_open[pind] == false then
    local button = self:get(pind)
    button.sprite = TB_WITH_ALERT_SPRITE
    button.style = "ltnt_toggle_button_with_alert"
  end
end
function gcTB:clear_alert(pind)
  local button = self:get(pind)
  button.sprite = TB_WITHOUT_ALERT_SPRITE
  button.style = "mod_gui_button"
end

return gcTB