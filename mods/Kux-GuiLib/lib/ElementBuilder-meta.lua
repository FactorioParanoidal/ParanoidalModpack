---@meta

--TODO: ---@field type
--TODO: ---@field style
--TODO: ---@field children


---@class KuxGuiLib.ElementBuilder.base.args : KuxGuiLib.LuaGuiStyle.writable_members
---@field condition nil|boolean|fun(any):boolean Optional condition whether this element should be added. Defaults to true.
---@field type	GuiElementType?	Auto-filled. The kind of element to add, which potentially has its own attributes as listed below.
---@field name	string?	Name of the child element. It must be unique within the parent element.
---@field caption	LocalisedString?	Text displayed on the child element. For frames, this is their title. For other elements, like buttons or labels, this is the content. Whilst this attribute may be used on all elements, it doesn't make sense for tables and flows as they won't display it.
---@field tooltip	LocalisedString?	Tooltip of the child element.
---@field elem_tooltip ElemID?           Elem tooltip of the child element. Will be displayed above tooltip.
---@field enabled	boolean?	Whether the child element is enabled. Defaults to true.
---@field visible	boolean?	Whether the child element is visible. Defaults to true.
---@field ignored_by_interaction	boolean?	Whether the child element is ignored by interaction. Defaults to false.
---@field style	string|LuaStyle|KuxGuiLib.ElementBuilder.style-parameter|nil	The name of the style prototype or a LuaStyle to apply to the new element.
---@field tags	Tags?	Tags associated with the child element.
---@field index	uint?	Location in its parent that the child element should slot into. By default, the child will be appended onto the end.
---@field anchor	GuiAnchor?	Where to position the child element when in the relative element.
---@field game_controller_interaction	uint?	defines.game_controller_interaction?	How the element should interact with game controllers. Defaults to defines.game_controller_interaction.normal.
---@field raise_hover_events	boolean?	Whether this element will raise on_gui_hover and on_gui_leave. Defaults to false.
---@field on_click string|boolean|nil on_gui_click
---@field on_hover string|boolean|nil on_gui_hover
---@field on_leave string|boolean|nil on_gui_leave


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.label.args : KuxGuiLib.ElementBuilder.label-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "label"?	Always "label".


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.button.args : KuxGuiLib.ElementBuilder.button-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "button"?	Always "button".
---@field mouse_button_filter	MouseButtonFlags?	Which mouse buttons the button responds to. Defaults to "left-and-right".
---@field auto_toggle	boolean?	Whether the button will automatically toggle when clicked. Defaults to false.
---@field toggled	boolean?	The initial toggled state of the button. Defaults to false.
---@field style string|KuxGuiLib.ElementBuilder.button-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.flow.args : KuxGuiLib.ElementBuilder.flow-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "flow"?	Always "flow".
---@field direction	string?	The initial direction of the flow's layout. See LuaGuiElement::direction. Defaults to "horizontal".
---@field style string|KuxGuiLib.ElementBuilder.flow-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.frame.args : KuxGuiLib.ElementBuilder.frame-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "frame"?	Always "frame".
---@field direction	string?	The initial direction of the frame's layout. See LuaGuiElement::direction. Defaults to "horizontal".
---@field style string|KuxGuiLib.ElementBuilder.frame-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed​ string|boolean|nil on_gui_location_changed​


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.table.args : KuxGuiLib.ElementBuilder.table-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "table"?	Always "table".
---@field column_count	uint	Number of columns. This can't be changed after the table is created.
---@field draw_vertical_lines	boolean?	Whether the table should draw vertical grid lines. Defaults to false.
---@field draw_horizontal_lines	boolean?	Whether the table should draw horizontal grid lines. Defaults to false.
---@field draw_horizontal_line_after_headers	boolean?	Whether the table should draw a single horizontal grid line after the headers. Defaults to false.
---@field vertical_centering	boolean?	Whether the content of the table should be vertically centered. Defaults to true.
---@field style string|KuxGuiLib.ElementBuilder.table-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.textfield.args : KuxGuiLib.ElementBuilder.textfield-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "textfield"?	Always "textfield".
---@field text	string?	The initial text contained in the textfield.
---@field numeric	boolean?	Defaults to false.
---@field allow_decimal	boolean?	Defaults to false.
---@field allow_negative	boolean?	Defaults to false.
---@field is_password	boolean?	Defaults to false.
---@field lose_focus_on_confirm	boolean?	Defaults to false.
-- @field clear_and_focus_on_right_click	boolean?	Defaults to false. (removed in 2.0.7)
---@field icon_selector boolean? Whether to add the rich text icon selector to the text field. This attribute can't be changed after creating the widget. Defaults to false. (>=2.0.7)
---@field style string|KuxGuiLib.ElementBuilder.textfield-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed string|boolean|nil on_gui_text_changed
---@field on_confirmed string|boolean|nil on_gui_confirmed


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.progressbar.args : KuxGuiLib.ElementBuilder.progressbar-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "progressbar"?	Always "progressbar".
---@field value	double?	The initial value of the progressbar, in the range [0, 1]. Defaults to 0.
---@field style string|KuxGuiLib.ElementBuilder.progressbar-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.checkbox.args : KuxGuiLib.ElementBuilder.checkbox-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "checkbox"?	Always "checkbox".
---@field state	boolean?	The initial checked-state of the checkbox. [mandantory]
---@field style string|KuxGuiLib.ElementBuilder.checkbox-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed string|boolean|nil on_gui_checked_state_changed


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.radiobutton.args : KuxGuiLib.ElementBuilder.radiobutton-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "radiobutton"?	Always "radiobutton".
---@field state	boolean	The initial checked-state of the radiobutton.
---@field style string|KuxGuiLib.ElementBuilder.radiobutton-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed string|boolean|nil on_gui_checked_state_changed


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.spritebutton.args : KuxGuiLib.ElementBuilder.sprite-button-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "sprite-button"?	Always "sprite-button".
---@field sprite	SpritePath?	Path to the image to display on the button.
---@field hovered_sprite	SpritePath?	Path to the image to display on the button when it is hovered.
---@field clicked_sprite	SpritePath?	Path to the image to display on the button when it is clicked.
---@field number	double?	The number shown on the button.
---@field show_percent_for_small_numbers	boolean?	Formats small numbers as percentages. Defaults to false.
---@field mouse_button_filter	MouseButtonFlags?	The mouse buttons that the button responds to. Defaults to "left-and-right".
---@field auto_toggle	boolean?	Whether the button will automatically toggle when clicked. Defaults to false.
---@field toggled	boolean?	The initial toggled state of the button. Defaults to false.
---@field quality QualityID? The quality to be shown in the bottom left corner of this sprite-button, or nil to show nothing. ( R: LuaQualityPrototype | W: QualityID?) (>=2.0.48)
---@field style string|KuxGuiLib.ElementBuilder.sprite-button-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.sprite.args : KuxGuiLib.ElementBuilder.sprite-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "sprite"?	Always "sprite".
---@field sprite	SpritePath?	Path to the image to display.
---@field resize_to_sprite	boolean?	Whether the widget should resize according to the sprite in it. Defaults to true.
---@field style string|KuxGuiLib.ElementBuilder.sprite-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.scrollpane.args : KuxGuiLib.ElementBuilder.scroll-pane-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "scroll-pane"?	Always "scroll-pane".
---@field horizontal_scroll_policy	string?	Policy of the horizontal scroll bar. Possible values are "auto", "never", "always", "auto-and-reserve-space", "dont-show-but-allow-scrolling". Defaults to "auto".
---@field vertical_scroll_policy	string?	Policy of the vertical scroll bar. Possible values are "auto", "never", "always", "auto-and-reserve-space", "dont-show-but-allow-scrolling". Defaults to "auto".
---@field style string|KuxGuiLib.ElementBuilder.scroll-pane-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.dropdown.args : KuxGuiLib.ElementBuilder.drop-down-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "drop-down"?	Always "drop-down".
---@field items	LocalisedString[]?	The initial items in the dropdown.
---@field selected_index	uint?	The index of the initially selected item. Defaults to 0.
---@field style string|KuxGuiLib.ElementBuilder.drop-down-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed string|boolean|nil on_gui_selection_state_changed​


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.line.args : KuxGuiLib.ElementBuilder.line-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "line"?	Always "line".
---@field direction	string?	The initial direction of the line. Defaults to "horizontal".
---@field style string|KuxGuiLib.ElementBuilder.line-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.listbox.args : KuxGuiLib.ElementBuilder.list-box-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "list-box"?	Always "list-box".
---@field items	LocalisedString[]?	The initial items in the listbox.
---@field selected_index	uint?	The index of the initially selected item. Defaults to 0.
---@field style string|KuxGuiLib.ElementBuilder.list-box-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed string|boolean|nil on_gui_selection_state_changed​


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.camera.args : KuxGuiLib.ElementBuilder.camera-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "camera"?	Always "camera".
---@field position	MapPosition	The position the camera centers on.
---@field surface_index	uint?	The surface that the camera will render. Defaults to the player's current surface.
---@field zoom	double?	The initial camera zoom. Defaults to 0.75.
---@field style string|KuxGuiLib.ElementBuilder.camera-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.chooseelembutton.args : KuxGuiLib.ElementBuilder.choose-elem-button-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "choose-elem-button"?	Always "choose-elem-button".
---@field elem_type	string	The type of the button - one of the following values.
---@field item	string?	If type is "item" - the default value for the button.
---@field tile	string?	If type is "tile" - the default value for the button.
---@field entity	string?	If type is "entity" - the default value for the button.
---@field signal	SignalID?	If type is "signal" - the default value for the button.
---@field fluid	string?	If type is "fluid" - the default value for the button.
---@field recipe	string?	If type is "recipe" - the default value for the button.
---@field decorative	string?	If type is "decorative" - the default value for the button.
---@field item-group	string?	If type is "item-group" - the default value for the button.
---@field achievement	string?	If type is "achievement" - the default value for the button.
---@field equipment	string?	If type is "equipment" - the default value for the button.
---@field technology	string?	If type is "technology" - the default value for the button.
---@field elem_filters	PrototypeFilter?	Filters describing what to show in the selection window. The applicable filter depends on the elem_type.
---@field style string|KuxGuiLib.ElementBuilder.choose-elem-button-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed string|boolean|nil on_gui_elem_changed


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.textbox.args : KuxGuiLib.ElementBuilder.text-box-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "text-box"?	Always "text-box".
---@field text	string?	The initial text contained in the text-box.
---@field clear_and_focus_on_right_click	boolean?	Defaults to false.
---@field icon_selector boolean? Whether to add the rich text icon selector to the text field. This attribute can't be changed after creating the widget. Defaults to false.
---@field style string|KuxGuiLib.ElementBuilder.text-box-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed string|boolean|nil on_gui_text_changed
---@field on_confirmed string|boolean|nil on_gui_confirmed


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.slider.args : KuxGuiLib.ElementBuilder.slider-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "slider"?	Always "slider".
---@field minimum_value	double?	The minimum value for the slider. Defaults to 0.
---@field maximum_value	double?	The maximum value for the slider. Defaults to 30.
---@field value	double?	The initial value for the slider. Defaults to minimum_value.
---@field value_step	double?	The minimum value the slider can move. Defaults to 1.
---@field discrete_slider	boolean?	Defaults to false.
---@field discrete_values	boolean?	Defaults to true.
---@field style string|KuxGuiLib.ElementBuilder.slider-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed string|boolean|nil on_gui_value_changed


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.minimap.args : KuxGuiLib.ElementBuilder.minimap-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "minimap"?	Always "minimap".
---@field position	MapPosition?	The position the minimap centers on. Defaults to the player's current position.
---@field surface_index	uint?	The surface the camera will render. Defaults to the player's current surface.
---@field chart_player_index	uint?	The player index the map should use. Defaults to the current player.
---@field force	string?	The force this minimap should use. Defaults to the player's current force.
---@field zoom	double?	The initial camera zoom. Defaults to 0.75.
---@field style string|KuxGuiLib.ElementBuilder.minimap-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.tab.args : KuxGuiLib.ElementBuilder.tab-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "tab"?	Always "tab".
---@field badge_text	LocalisedString?	The text to display after the normal tab text (designed to work with numbers).
---@field style string|KuxGuiLib.ElementBuilder.tab-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.switch.args : KuxGuiLib.ElementBuilder.switch-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "switch"?	Always "switch".
---@field switch_state	string?	Possible values are "left", "right", or "none". If set to "none", allow_none_state must be true. Defaults to "left".
---@field allow_none_state	boolean?	Whether the switch can be set to a middle state. Defaults to false.
---@field left_label_caption	LocalisedString?
---@field left_label_tooltip	LocalisedString?
---@field right_label_caption	LocalisedString?
---@field right_label_tooltip	LocalisedString?
---@field style string|KuxGuiLib.ElementBuilder.switch-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed string|boolean|nil on_gui_switch_state_changed


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.entitypreview.args : KuxGuiLib.ElementBuilder.entity-preview-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "entity-preview"?	Always "entity-preview".
---@field style string|KuxGuiLib.ElementBuilder.entity-preview-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.emptywidget.args : KuxGuiLib.ElementBuilder.empty-widget-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "empty-widget"?	Always "empty-widget".
---@field style string|KuxGuiLib.ElementBuilder.empty-widget-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxGuiLib.ElementBuilder.tabbedpane.args : KuxGuiLib.ElementBuilder.tabbed-pane-style-parameter, KuxGuiLib.ElementBuilder.base.args
---@field type "tabbed-pane"?	Always "tabbed-pane".
---@field style string|KuxGuiLib.ElementBuilder.tabbed-pane-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.
---@field on_changed string|boolean|nil  on_gui_switch_state_changed

-----------------------------------------------------------------------------------------------------------------------
---#region: syle
-----------------------------------------------------------------------------------------------------------------------

---Style of a GUI element. All of the attributes listed here may be `nil` if not available for a particular GUI element.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html)
---@class KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.bottom_margin)
---@field bottom_margin int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.bottom_padding)
---@field bottom_padding int?
---[W]
---Sets `extra_top/right/bottom/left_margin_when_activated` to this value. An array with two values sets top/bottom margin to the first value and left/right margin to the second value. An array with four values sets top, right, bottom, left margin respectively.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.extra_margin_when_activated)
---@field extra_margin_when_activated int|int[]|nil
---[W]
---Sets `extra_top/right/bottom/left_padding_when_activated` to this value. An array with two values sets top/bottom padding to the first value and left/right padding to the second value. An array with four values sets top, right, bottom, left padding respectively.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.extra_padding_when_activated)
---@field extra_padding_when_activated int|int[]|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.font)
---@field font string?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.font_color)
---@field font_color Color|string|nil
---[R]
---Gui of the [LuaGuiElement](https://lua-api.factorio.com/latest/LuaGuiElement.html) of this style.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.gui)
---@field gui LuaGui?
---[W]
---Sets both minimal and maximal height to the given value.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.height)
---@field height int?
---[RW]
---Horizontal align of the inner content of the widget, if any. Possible values are "left", "center" or "right".
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.horizontal_align)
---@field horizontal_align string?
---[RW]
---Whether the GUI element can be squashed (by maximal width of some parent element) horizontally. `nil` if this element does not support squashing. This is mainly meant to be used for scroll-pane The default value is false.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.horizontally_squashable)
---@field horizontally_squashable boolean?
---[RW]
---Whether the GUI element stretches its size horizontally to other elements. `nil` if this element does not support stretching.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.horizontally_stretchable)
---@field horizontally_stretchable boolean?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.left_margin)
---@field left_margin int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.left_padding)
---@field left_padding int?
---[W]
---Sets top/right/bottom/left margins to this value. An array with two values sets top/bottom margin to the first value and left/right margin to the second value. An array with four values sets top, right, bottom, left margin respectively.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.margin)
---@field margin int|int[]?
---[RW]
---Maximal height ensures, that the widget will never be bigger than than that size. It can't be stretched to be bigger.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.maximal_height)
---@field maximal_height int?
---[RW]
---Maximal width ensures, that the widget will never be bigger than than that size. It can't be stretched to be bigger.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.maximal_width)
---@field maximal_width int?
---[RW]
---Minimal height ensures, that the widget will never be smaller than than that size. It can't be squashed to be smaller.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.minimal_height)
---@field minimal_height int?
---[RW]
---Minimal width ensures, that the widget will never be smaller than than that size. It can't be squashed to be smaller.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.minimal_width)
---@field minimal_width int?
---[R]
---Name of this style.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.name)
---@field name string?
---[RW]
---Natural height specifies the height of the element tries to have, but it can still be squashed/stretched to have a smaller or bigger size.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.natural_height)
---@field natural_height int?
---[RW]
---Natural width specifies the width of the element tries to have, but it can still be squashed/stretched to have a smaller or bigger size.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.natural_width)
---@field natural_width int?
---[R]
---The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.object_name)
---@field object_name string?
---[W]
---Sets top/right/bottom/left paddings to this value. An array with two values sets top/bottom padding to the first value and left/right padding to the second value. An array with four values sets top, right, bottom, left padding respectively.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.padding)
---@field padding int|int[]|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.right_margin)
---@field right_margin int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.right_padding)
---@field right_padding int?
---[W]
---Sets both width and height to the given value. Also accepts an array with two values, setting width to the first and height to the second one.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.size)
---@field size int|int[]|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.top_margin)
---@field top_margin int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.top_padding)
---@field top_padding int?
---[R]
---Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.valid)
---@field valid boolean?
---[RW]
---Vertical align of the inner content of the widget, if any. Possible values are "top", "center" or "bottom".
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.vertical_align)
---@field vertical_align string?
---[RW]
---Whether the GUI element can be squashed (by maximal height of some parent element) vertically. `nil` if this element does not support squashing. This is mainly meant to be used for scroll-pane The default (parent) value for scroll pane is true, false otherwise.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.vertically_squashable)
---@field vertically_squashable boolean?
---[RW]
---Whether the GUI element stretches its size vertically to other elements. `nil` if this element does not support stretching.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.vertically_stretchable)
---@field vertically_stretchable boolean?
---[W]
---Sets both minimal and maximal width to the given value.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.width)
---@field width int?


-----------------------------------------------------------------------------------------------------------------------
--- #region: style for each element
-------------------------------------------------------------------------------------------------------------------------

---@class KuxGuiLib.ElementBuilder.button-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.clicked_vertical_offset)
---
---_Can only be used if this is LuaButtonStyle_
---@field clicked_vertical_offset int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.clicked_font_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field clicked_font_color Color|string|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.disabled_font_color)
---
---_Can only be used if this is LuaButtonStyle or LuaTabStyle_
---@field disabled_font_color Color|string|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.hovered_font_color)
---
---_Can only be used if this is LuaButtonStyle_
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.pie_progress_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field pie_progress_color Color|string|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.selected_clicked_font_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field selected_clicked_font_color Color|string|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.selected_font_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field selected_font_color Color|string|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.selected_hovered_font_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field selected_hovered_font_color Color|string|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.strikethrough_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field strikethrough_color Color|string|nil



---@class KuxGuiLib.ElementBuilder.checkbox-style-parameter : KuxGuiLib.ElementBuilder.style-parameter

---@class KuxGuiLib.ElementBuilder.flow-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---Horizontal space between individual cells.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.horizontal_spacing)
---
---_Can only be used if this is LuaTableStyle, LuaFlowStyle or LuaHorizontalFlowStyle_
---@field horizontal_spacing int?
---[RW]
---Vertical space between individual cells.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.vertical_spacing)
---
---_Can only be used if this is LuaTableStyle, LuaFlowStyle, LuaVerticalFlowStyle or LuaTabbedPaneStyle_
---@field vertical_spacing int?


---@class KuxGuiLib.ElementBuilder.frame-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.use_header_filler)
---
---_Can only be used if this is LuaFrameStyle_
---@field use_header_filler boolean?


---@class KuxGuiLib.ElementBuilder.label-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---How this GUI element handles rich text.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.rich_text_setting)
---
---_Can only be used if this is LuaLabelStyle, LuaTextBoxStyle or LuaTextFieldStyle_
---@field rich_text_setting defines.rich_text_setting?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.single_line)
---
---_Can only be used if this is LabelStyle_
---@field single_line boolean?
---@field hovered_font_color Color|string|nil


---@class KuxGuiLib.ElementBuilder.line-style-parameter : KuxGuiLib.ElementBuilder.style-parameter

---@class KuxGuiLib.ElementBuilder.progressbar-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.bar_width)
---
---_Can only be used if this is LuaProgressBarStyle_
---@field bar_width uint?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.color)
---
---_Can only be used if this is LuaProgressBarStyle_
---@field color Color|string|nil


---@class KuxGuiLib.ElementBuilder.table-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---Space between the table cell contents bottom and border.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.bottom_cell_padding)
---
---_Can only be used if this is LuaTableStyle_
---@field bottom_cell_padding int?
---[W]
---Space between the table cell contents and border. Sets top/right/bottom/left cell paddings to this value.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.cell_padding)
---
---_Can only be used if this is LuaTableStyle_
---@field cell_padding int?
---[RW]
---Horizontal space between individual cells.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.horizontal_spacing)
---
---_Can only be used if this is LuaTableStyle, LuaFlowStyle or LuaHorizontalFlowStyle_
---@field horizontal_spacing int?
---[RW]
---Space between the table cell contents left and border.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.left_cell_padding)
---
---_Can only be used if this is LuaTableStyle_
---@field left_cell_padding int?
---[RW]
---Space between the table cell contents right and border.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.right_cell_padding)
---
---_Can only be used if this is LuaTableStyle_
---@field right_cell_padding int?
---[RW]
---Space between the table cell contents top and border.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.top_cell_padding)
---
---_Can only be used if this is LuaTableStyle_
---@field top_cell_padding int?
---[RW]
---Vertical space between individual cells.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.vertical_spacing)
---
---_Can only be used if this is LuaTableStyle, LuaFlowStyle, LuaVerticalFlowStyle or LuaTabbedPaneStyle_
---@field vertical_spacing int?
---[R]
---Array containing the alignment for every column of this table element. Even though this property is marked as read-only, the alignment can be changed by indexing the LuaCustomTable, like so:
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.column_alignments)
---
---### Example
---```
---table_element.style.column_alignments[1] = "center"
---```
---@field column_alignments LuaCustomTable<uint,Alignment>?


---@class KuxGuiLib.ElementBuilder.textfield-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---How this GUI element handles rich text.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.rich_text_setting)
---
---_Can only be used if this is LuaLabelStyle, LuaTextBoxStyle or LuaTextFieldStyle_
---@field rich_text_setting defines.rich_text_setting?


---@class KuxGuiLib.ElementBuilder.radiobutton-style-parameter : KuxGuiLib.ElementBuilder.style-parameter


---@class KuxGuiLib.ElementBuilder.sprite-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.stretch_image_to_widget_size)
---
---_Can only be used if this is ImageStyle_
---@field stretch_image_to_widget_size boolean?


---@class KuxGuiLib.ElementBuilder.scroll-pane-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.extra_bottom_margin_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_bottom_margin_when_activated int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.extra_bottom_padding_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_bottom_padding_when_activated int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.extra_left_margin_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_left_margin_when_activated int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.extra_left_padding_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_left_padding_when_activated int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.extra_right_margin_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_right_margin_when_activated int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.extra_right_padding_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_right_padding_when_activated int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.extra_top_margin_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_top_margin_when_activated int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.extra_top_padding_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_top_padding_when_activated int?


---@class KuxGuiLib.ElementBuilder.drop-down-style-parameter : KuxGuiLib.ElementBuilder.style-parameter

---@class KuxGuiLib.ElementBuilder.list-box-style-parameter : KuxGuiLib.ElementBuilder.style-parameter

---@class KuxGuiLib.ElementBuilder.camera-style-parameter : KuxGuiLib.ElementBuilder.style-parameter

---@class KuxGuiLib.ElementBuilder.choose-elem-button-style-parameter : KuxGuiLib.ElementBuilder.style-parameter


---@class KuxGuiLib.ElementBuilder.text-box-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---How this GUI element handles rich text.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.rich_text_setting)
---
---_Can only be used if this is LuaLabelStyle, LuaTextBoxStyle or LuaTextFieldStyle_
---@field rich_text_setting defines.rich_text_setting?


---@class KuxGuiLib.ElementBuilder.slider-style-parameter : KuxGuiLib.ElementBuilder.style-parameter

---@class KuxGuiLib.ElementBuilder.minimap-style-parameter : KuxGuiLib.ElementBuilder.style-parameter

---@class KuxGuiLib.ElementBuilder.entity-preview-style-parameter : KuxGuiLib.ElementBuilder.style-parameter

---@class KuxGuiLib.ElementBuilder.empty-widget-style-parameter : KuxGuiLib.ElementBuilder.style-parameter

---@class KuxGuiLib.ElementBuilder.tabbed-pane-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---Vertical space between individual cells.
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.vertical_spacing)
---
---_Can only be used if this is LuaTableStyle, LuaFlowStyle, LuaVerticalFlowStyle or LuaTabbedPaneStyle_
---@field vertical_spacing int?


---@class KuxGuiLib.ElementBuilder.tab-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.badge_font)
---
---_Can only be used if this is TabStyle_
---@field badge_font string?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.badge_horizontal_spacing)
---
---_Can only be used if this is TabStyle_
---@field badge_horizontal_spacing int?
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.default_badge_font_color)
---
---_Can only be used if this is TabStyle_
---@field default_badge_font_color Color|string|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.disabled_badge_font_color)
---
---_Can only be used if this is TabStyle_
---@field disabled_badge_font_color Color|string|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.disabled_font_color)
---
---_Can only be used if this is LuaButtonStyle or LuaTabStyle_
---@field disabled_font_color Color|string|nil
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaStyle.html#LuaStyle.selected_badge_font_color)
---
---_Can only be used if this is TabStyle_
---@field selected_badge_font_color Color|string|nil


---@class KuxGuiLib.ElementBuilder.switch-style-parameter : KuxGuiLib.ElementBuilder.style-parameter
