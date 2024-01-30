local event = require("__RaiLuaLib__.lualib.event")
local gui = require("__RaiLuaLib__.lualib.gui")
local mod_gui = require("mod-gui")

local debug_print = function(e) game.get_player(e.player_index).print(serpent.block(e)) end

gui.templates:extend{
  pushers = {
    horizontal = {type="empty-widget", name="pusher", style_mods={horizontally_stretchable=true}},
    vertical = {type="empty-widget", name="pusher", style_mods={vertically_stretchable=true}}
  }
}

gui.handlers:extend{
  demo = {
    auto_clear_checkbox = {
      state_changed = {id=defines.events.on_gui_checked_state_changed, handler=debug_print}
    },
    cardinals_checkbox = {
      state_changed = {id=defines.events.on_gui_checked_state_changed, handler=debug_print}
    },
    grid_type_switch = {
      state_changed = {id=defines.events.on_gui_switch_state_changed, handler=debug_print}
    },
    divisor_slider = {
      value_changed = {id=defines.events.on_gui_value_changed, handler=debug_print}
    },
    divisor_textfield = {
      confirmed = {id=defines.events.on_gui_confirmed, handler=debug_print},
      text_changed = {id=defines.events.on_gui_text_changed, handler=debug_print}
    }
  }
}

event.on_player_created(function(e)
  mod_gui.get_button_flow(game.get_player(e.player_index)).add{type="button", name="gui_module_mod_gui_button", style=mod_gui.button_style, caption="Template"}
end)

event.on_gui_click(function(e)
  local player = game.get_player(e.player_index)
  local frame_flow = mod_gui.get_frame_flow(player)
  local window = frame_flow.demo_window
  if window then
    event.disable_group("gui.demo", e.player_index)
    window.destroy()
  else
    local profiler = game.create_profiler()
    profiler.stop()
    for i=1,100 do
      profiler.restart()
      local elems, filters = gui.build(frame_flow, {
        {type="frame", name="demo_window", style="dialog_frame", direction="vertical", save_as="window", children={
          -- checkboxes
          {type="flow", name="checkboxes_flow", direction="horizontal", children={
            {type="checkbox", name="autoclear", caption="Auto-clear", state=true, handlers="demo.auto_clear_checkbox", save_as="checkboxes.auto_clear"},
            {template="pushers.horizontal"},
            {type="checkbox", name="cardinals", caption="Cardinals only", state=true, handlers="demo.cardinals_checkbox",
              save_as="checkboxes.cardinals.cardinals"}
          }},
          -- grid type switch
          {type="flow", name="switch_flow", style_mods={vertical_align="center"}, direction="horizontal", children={
            {type="label", name="label", caption="Grid type:"},
            {template="pushers.horizontal"},
            {type="switch", name="switch", left_label_caption="Increment", right_label_caption="Split", state="left", handlers="demo.grid_type_switch",
              save_as="grid_type_switch"}
          }},
          -- divisor label
          {type="flow", name="divisor_label_flow", style_mods={horizontal_align="center", horizontally_stretchable=true}, children={
            {type="label", name="label", style="caption_label", caption="Number of tiles per subgrid", save_as="grid_type_label"},
          }},
          -- divisor slider and textfield
          {type="flow", name="divisor_flow", style_mods={horizontal_spacing=8, vertical_align="center"}, direction="horizontal", children={
            {type="slider", name="slider", style="notched_slider", style_mods={horizontally_stretchable=true}, minimum_value=4, maximum_value=12,
              value_step=1, value=5, discrete_slider=true, discrete_values=true, handlers="demo.divisor_slider", save_as="divisor_slider"},
            {type="textfield", name="textfield", style_mods={width=50, horizontal_align="center"}, numeric=true, lose_focus_on_confirm=true, text=5,
              handlers="demo.divisor_textfield", save_as="divisor_textfield"}
          }}
        }}
      })
      profiler.stop()
      -- reset
      if i ~= 100 then
        event.disable_group("gui.demo", e.player_index)
        elems.window.destroy()
      end
    end
    profiler.divide(100)
    game.print(profiler)
  end
end, "gui_module_mod_gui_button")