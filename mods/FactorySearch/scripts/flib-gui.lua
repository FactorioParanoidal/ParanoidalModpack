---@diagnostic disable: duplicate-set-field, duplicate-doc-field, duplicate-doc-alias
--- https://github.com/factoriolib/flib/blob/ae2c608f53cbafd29f683703734eea421e6e35fb/gui.lua
-- With `ref` table addition by Xorimuth

--- Utilities for building GUIs and handling GUI events.
--- @class flib_gui
local flib_gui = {}

local handler_tag_key = "__" .. script.mod_name .. "_handler"

--- @type table<GuiElemHandler, string>
local handlers = {}
--- @type table<string, GuiElemHandler>
local handlers_lookup = {}

--- Add a new child or children to the given GUI element.
--- @param parent LuaGuiElement The parent GUI element.
--- @param def GuiElemDef|GuiElemDef[] The element definition, or an array of element definitions.
--- @param elems table<string, LuaGuiElement>? Optional initial `elems` table.
--- @return table<string, LuaGuiElement> elems Elements with names or refs will be collected into this table.
--- @return LuaGuiElement first The element that was created first;  the "top level" element.
function flib_gui.add(parent, def, elems)
  if not parent or not parent.valid then
    error("Parent element is missing or invalid")
  end
  if not elems then
    elems = {}
  end
  -- If a single def was passed, wrap it in an array
  if def.type or (def.tab and def.content) then
    def = { def }
  end
  local first
  for i = 1, #def do
    local def = def[i]
    if def.type then
      -- Remove custom attributes from the def so the game doesn't serialize them
      local children = def.children
      local elem_mods = def.elem_mods
      local handler = def.handler
      local style_mods = def.style_mods
      local drag_target = def.drag_target
      -- If children were defined in the array portion, remove and collect them
      local has_array_children = false
      if def[1] then
        if children then
          error("Cannot define children in array portion and subtable simultaneously")
        end
        has_array_children = true
        children = {}
        for i = 1, #def do
          children[i] = def[i]
          def[i] = nil
        end
      end
      def.children = nil
      def.elem_mods = nil
      def.handler = nil
      def.style_mods = nil
      def.drag_target = nil

      local elem = parent.add(def)

      if not first then
        first = elem
      end
      -- Removed by Xorimuth
      --if def.name then
      --  elems[def.name] = elem
      --end
      -- Added by Xorimuth
      local refs = def.ref
      if refs then
        local ref_length = #refs
        local current_table = elems
        for j, ref in pairs(refs) do
          if j ~= ref_length then
            -- Add table
            if not current_table[ref] then
              ---@diagnostic disable-next-line: missing-fields
              current_table[ref] = {}
            end
            current_table = current_table[ref]
          else
            -- Add element
            current_table[ref] = elem
          end
        end
      end
      -- Endof added by Xorimuth
      if style_mods then
        for key, value in pairs(style_mods) do
          elem.style[key] = value
        end
      end
      if elem_mods then
        for key, value in pairs(elem_mods) do
          elem[key] = value
        end
      end
      if drag_target then
        local target = elems[drag_target]
        if not target then
          error("Drag target '" .. drag_target .. "' not found.")
        end
        elem.drag_target = target
      end
      if handler then
        local out
        if type(handler) == "table" then
          out = {}
          for name, handler in pairs(handler) do
            out[tostring(name)] = handlers[handler]
          end
        else
          out = handlers[handler]
        end
        local tags = elem.tags
        tags[handler_tag_key] = out
        elem.tags = tags
      end
      if children then
        flib_gui.add(elem, children, elems)
      end

      -- Re-add custom attributes
      if children and has_array_children then
        for i = 1, #children do
          def[i] = children[i]
        end
      else
        def.children = children
      end
      def.elem_mods = elem_mods
      def.handler = handler
      def.style_mods = style_mods
      def.drag_target = drag_target
    elseif def.tab and def.content then
      local _, tab = flib_gui.add(parent, def.tab, elems)
      local _, content = flib_gui.add(parent, def.content, elems)
      parent.add_tab(tab, content)
    end
  end
  return elems, first
end

--- Add the given handler functions to the registry for use with `flib_gui.add`. Each handler must have a unique name. If a
--- `wrapper` function is provided, it will be called instead, and will receive the event data and handler. The wrapper
--- can be used to execute logic or gather data common to all handler functions for this GUI.
--- @param new_handlers table<string, fun(e: GuiEventData)>
--- @param wrapper fun(e: GuiEventData, handler: function)?
--- @param prefix string?
function flib_gui.add_handlers(new_handlers, wrapper, prefix)
  for name, handler in pairs(new_handlers) do
    if prefix then
      name = prefix .. "/" .. name
    end
    if type(handler) == "function" then
      if handlers_lookup[name] then
        error("Attempted to register two GUI event handlers with the same name: " .. name)
      end
      handlers[handler] = name
      if wrapper then
        handlers_lookup[name] = function(e)
          wrapper(e, handler)
        end
      else
        handlers_lookup[name] = handler
      end
    end
  end
end

--- Dispatch the handler associated with this event and GUI element. The handler must have been added using
--- `flib_gui.add_handlers`.
--- @param e GuiEventData
--- @return boolean handled True if an event handler was called.
function flib_gui.dispatch(e)
  local elem = e.element
  if not elem then
    return false
  end
  local tags = elem.tags --[[@as Tags]]
  local handler_def = tags[handler_tag_key]
  if not handler_def then
    return false
  end
  local handler_type = type(handler_def)
  if handler_type == "table" then
    handler_def = handler_def[tostring(e.name)]
  end
  if handler_def then
    local handler = handlers_lookup[handler_def]
    if handler then
      handler(e)
      return true
    end
  end
  return false
end

--- For use with `__core__/lualib/event_handler`. Pass `flib_gui` into `handler.add_lib` to handle
--- all GUI events automatically.
flib_gui.events = {}
for name, id in pairs(defines.events) do
  if string.find(name, "on_gui_") then
    flib_gui.events[id] = flib_gui.dispatch
  end
end

--- Handle all GUI events with `flib_gui.dispatch`. Will not overwrite any existing event handlers.
function flib_gui.handle_events()
  for id in pairs(flib_gui.events) do
    if not script.get_event_handler(id) then
      script.on_event(id, flib_gui.dispatch)
    end
  end
end

--- Format the given handlers for use in a GUI element's tags. An alternative to using `flib_gui.add` if event handling
--- is the only desired feature.
---
--- ### Example
---
--- ```lua
--- --- @param e EventData.on_gui_click
--- local function on_button_clicked(e)
---   game.print("You clicked it!")
--- end
---
--- player.gui.screen.add({
---   type = "button",
---   caption = "Click me!",
---   tags = flib_gui.format_handlers({ [defines.events.on_gui_click] = on_button_clicked }),
--- })
---
--- flib_gui.handle_events({ on_button_clicked = on_button_clicked })
--- ```
--- @param input GuiElemHandler|table<defines.events, GuiElemHandler?>
--- @param existing Tags?
--- @return Tags
function flib_gui.format_handlers(input, existing)
  local out
  if type(input) == "table" then
    out = {}
    for name, handler in pairs(input) do
      out[tostring(name)] = handlers[handler]
    end
  else
    out = handlers[input]
  end
  if existing then
    existing[handler_tag_key] = out
    return existing
  end
  return { [handler_tag_key] = out }
end

--- A GUI element definition. This extends `LuaGuiElement.add_param` with several new attributes.
--- Children may be defined in the array portion as an alternative to the `children` subtable.
--- @class GuiElemDef: LuaGuiElement.add_param.button|LuaGuiElement.add_param.camera|LuaGuiElement.add_param.checkbox|LuaGuiElement.add_param.choose_elem_button|LuaGuiElement.add_param.drop_down|LuaGuiElement.add_param.flow|LuaGuiElement.add_param.frame|LuaGuiElement.add_param.line|LuaGuiElement.add_param.list_box|LuaGuiElement.add_param.minimap|LuaGuiElement.add_param.progressbar|LuaGuiElement.add_param.radiobutton|LuaGuiElement.add_param.scroll_pane|LuaGuiElement.add_param.slider|LuaGuiElement.add_param.sprite|LuaGuiElement.add_param.sprite_button|LuaGuiElement.add_param.switch|LuaGuiElement.add_param.tab|LuaGuiElement.add_param.table|LuaGuiElement.add_param.text_box|LuaGuiElement.add_param.textfield
--- @field ref string[]? Added by Xorimuth. Adds the element to the returned list of elements, using the specified hierarchy.
--- @field style_mods LuaStyleMods? Modifications to make to the element's style.
--- @field elem_mods LuaGuiElement? Modifications to make to the element itself.
--- @field drag_target string? Set the element's drag target to the element whose name matches this string. The drag target must be present in the `elems` table.
--- @field handler (GuiElemHandler|table<defines.events, GuiElemHandler>)? Handler(s) to assign to this element. If assigned to a function, that function will be called for any GUI event on this element.
--- @field children GuiElemDef[]? Children to add to this element.
--- @field tab GuiElemDef? To add a tab, specify `tab` and `content` and leave all other fields unset.
--- @field content GuiElemDef? To add a tab, specify `tab` and `content` and leave all other fields unset.

--- A handler function to invoke when receiving GUI events for this element.
--- @alias GuiElemHandler fun(e: GuiEventData)

--- Aggregate type of all possible GUI events.
--- @alias GuiEventData EventData.on_gui_checked_state_changed|EventData.on_gui_click|EventData.on_gui_closed|EventData.on_gui_confirmed|EventData.on_gui_elem_changed|EventData.on_gui_location_changed|EventData.on_gui_opened|EventData.on_gui_selected_tab_changed|EventData.on_gui_selection_state_changed|EventData.on_gui_switch_state_changed|EventData.on_gui_text_changed|EventData.on_gui_value_changed

---Style of a GUI element for use with `style_mods`. All of the attributes listed here may be `nil` if not available for a particular GUI element.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html)
---@class (exact) LuaStyleMods
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#badge_font)
---
---*Can only be used if this is TabStyle*
---@field badge_font? string
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#badge_horizontal_spacing)
---
---*Can only be used if this is TabStyle*
---@field badge_horizontal_spacing? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#bar_width)
---
---*Can only be used if this is LuaProgressBarStyle*
---@field bar_width? uint
---Space between the table cell contents bottom and border.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#bottom_cell_padding)
---
---*Can only be used if this is LuaTableStyle*
---@field bottom_cell_padding? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#bottom_margin)
---@field bottom_margin? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#bottom_padding)
---@field bottom_padding? int
---Space between the table cell contents and border. Sets top/right/bottom/left cell paddings to this value.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#cell_padding)
---
---*Can only be used if this is LuaTableStyle*
---@field cell_padding? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#clicked_font_color)
---
---*Can only be used if this is LuaButtonStyle*
---@field clicked_font_color? Color
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#clicked_vertical_offset)
---
---*Can only be used if this is LuaButtonStyle*
---@field clicked_vertical_offset? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#color)
---
---*Can only be used if this is LuaProgressBarStyle*
---@field color? Color
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#default_badge_font_color)
---
---*Can only be used if this is TabStyle*
---@field default_badge_font_color? Color
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#disabled_badge_font_color)
---
---*Can only be used if this is TabStyle*
---@field disabled_badge_font_color? Color
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#disabled_font_color)
---
---*Can only be used if this is LuaButtonStyle or LuaTabStyle*
---@field disabled_font_color? Color
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#draw_grayscale_picture)
---
---*Can only be used if this is LuaButtonStyle*
---@field draw_grayscale_picture? boolean
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#extra_bottom_margin_when_activated)
---
---*Can only be used if this is ScrollPaneStyle*
---@field extra_bottom_margin_when_activated? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#extra_bottom_padding_when_activated)
---
---*Can only be used if this is ScrollPaneStyle*
---@field extra_bottom_padding_when_activated? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#extra_left_margin_when_activated)
---
---*Can only be used if this is ScrollPaneStyle*
---@field extra_left_margin_when_activated? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#extra_left_padding_when_activated)
---
---*Can only be used if this is ScrollPaneStyle*
---@field extra_left_padding_when_activated? int
---Sets `extra_top/right/bottom/left_margin_when_activated` to this value.
---
---An array with two values sets top/bottom margin to the first value and left/right margin to the second value. An array with four values sets top, right, bottom, left margin respectively.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#extra_margin_when_activated)
---@field extra_margin_when_activated? (int)|((int)[])
---Sets `extra_top/right/bottom/left_padding_when_activated` to this value.
---
---An array with two values sets top/bottom padding to the first value and left/right padding to the second value. An array with four values sets top, right, bottom, left padding respectively.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#extra_padding_when_activated)
---@field extra_padding_when_activated? (int)|((int)[])
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#extra_right_margin_when_activated)
---
---*Can only be used if this is ScrollPaneStyle*
---@field extra_right_margin_when_activated? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#extra_right_padding_when_activated)
---
---*Can only be used if this is ScrollPaneStyle*
---@field extra_right_padding_when_activated? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#extra_top_margin_when_activated)
---
---*Can only be used if this is ScrollPaneStyle*
---@field extra_top_margin_when_activated? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#extra_top_padding_when_activated)
---
---*Can only be used if this is ScrollPaneStyle*
---@field extra_top_padding_when_activated? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#font)
---@field font? string
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#font_color)
---@field font_color? Color
---Sets both minimal and maximal height to the given value.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#height)
---@field height? int
---Horizontal align of the inner content of the widget, if any.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#horizontal_align)
---@field horizontal_align? ("left")|("center")|("right")
---Horizontal space between individual cells.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#horizontal_spacing)
---
---*Can only be used if this is LuaTableStyle, LuaFlowStyle or LuaHorizontalFlowStyle*
---@field horizontal_spacing? int
---Whether the GUI element can be squashed (by maximal width of some parent element) horizontally. `nil` if this element does not support squashing.
---
---This is mainly meant to be used for scroll-pane. The default value is false.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#horizontally_squashable)
---@field horizontally_squashable? boolean
---Whether the GUI element stretches its size horizontally to other elements. `nil` if this element does not support stretching.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#horizontally_stretchable)
---@field horizontally_stretchable? boolean
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#hovered_font_color)
---
---*Can only be used if this is LuaButtonStyle*
---@field hovered_font_color? Color
---Space between the table cell contents left and border.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#left_cell_padding)
---
---*Can only be used if this is LuaTableStyle*
---@field left_cell_padding? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#left_margin)
---@field left_margin? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#left_padding)
---@field left_padding? int
---Sets top/right/bottom/left margins to this value.
---
---An array with two values sets top/bottom margin to the first value and left/right margin to the second value. An array with four values sets top, right, bottom, left margin respectively.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#margin)
---@field margin? (int)|((int)[])
---Maximal height ensures, that the widget will never be bigger than than that size. It can't be stretched to be bigger.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#maximal_height)
---@field maximal_height? int
---Maximal width ensures, that the widget will never be bigger than than that size. It can't be stretched to be bigger.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#maximal_width)
---@field maximal_width? int
---Minimal height ensures, that the widget will never be smaller than than that size. It can't be squashed to be smaller.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#minimal_height)
---@field minimal_height? int
---Minimal width ensures, that the widget will never be smaller than than that size. It can't be squashed to be smaller.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#minimal_width)
---@field minimal_width? int
---Natural height specifies the height of the element tries to have, but it can still be squashed/stretched to have a smaller or bigger size.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#natural_height)
---@field natural_height? int
---Natural width specifies the width of the element tries to have, but it can still be squashed/stretched to have a smaller or bigger size.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#natural_width)
---@field natural_width? int
---Sets top/right/bottom/left paddings to this value.
---
---An array with two values sets top/bottom padding to the first value and left/right padding to the second value. An array with four values sets top, right, bottom, left padding respectively.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#padding)
---@field padding? (int)|((int)[])
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#pie_progress_color)
---
---*Can only be used if this is LuaButtonStyle*
---@field pie_progress_color? Color
---How this GUI element handles rich text.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#rich_text_setting)
---
---*Can only be used if this is LuaLabelStyle, LuaTextBoxStyle or LuaTextFieldStyle*
---@field rich_text_setting? defines.rich_text_setting
---Space between the table cell contents right and border.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#right_cell_padding)
---
---*Can only be used if this is LuaTableStyle*
---@field right_cell_padding? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#right_margin)
---@field right_margin? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#right_padding)
---@field right_padding? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#selected_badge_font_color)
---
---*Can only be used if this is TabStyle*
---@field selected_badge_font_color? Color
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#selected_clicked_font_color)
---
---*Can only be used if this is LuaButtonStyle*
---@field selected_clicked_font_color? Color
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#selected_font_color)
---
---*Can only be used if this is LuaButtonStyle*
---@field selected_font_color? Color
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#selected_hovered_font_color)
---
---*Can only be used if this is LuaButtonStyle*
---@field selected_hovered_font_color? Color
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#single_line)
---
---*Can only be used if this is LabelStyle*
---@field single_line? boolean
---Sets both width and height to the given value. Also accepts an array with two values, setting width to the first and height to the second one.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#size)
---@field size? (int)|((int)[])
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#stretch_image_to_widget_size)
---
---*Can only be used if this is ImageStyle*
---@field stretch_image_to_widget_size? boolean
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#strikethrough_color)
---
---*Can only be used if this is LuaButtonStyle*
---@field strikethrough_color? Color
---Space between the table cell contents top and border.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#top_cell_padding)
---
---*Can only be used if this is LuaTableStyle*
---@field top_cell_padding? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#top_margin)
---@field top_margin? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#top_padding)
---@field top_padding? int
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#use_header_filler)
---
---*Can only be used if this is LuaFrameStyle*
---@field use_header_filler? boolean
---Vertical align of the inner content of the widget, if any.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#vertical_align)
---@field vertical_align? ("top")|("center")|("bottom")
---Vertical space between individual cells.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#vertical_spacing)
---
---*Can only be used if this is LuaTableStyle, LuaFlowStyle, LuaVerticalFlowStyle or LuaTabbedPaneStyle*
---@field vertical_spacing? int
---Whether the GUI element can be squashed (by maximal height of some parent element) vertically. `nil` if this element does not support squashing.
---
---This is mainly meant to be used for scroll-pane. The default (parent) value for scroll pane is true, false otherwise.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#vertically_squashable)
---@field vertically_squashable? boolean
---Whether the GUI element stretches its size vertically to other elements. `nil` if this element does not support stretching.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#vertically_stretchable)
---@field vertically_stretchable? boolean
---Sets both minimal and maximal width to the given value.
---
---[View Documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#width)
---@field width? int

return flib_gui