--- @meta _


---@class KuxGuiLib.View
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field __class string
---@field open fun(plx: KuxGuiLib.PlayerContext)
---@field open_subview fun(plx: KuxGuiLib.PlayerContext)
---@field protected designer KuxGuiLib.Designer


---@class KuxGuiLib.View.Data
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field __class string



--- @class KuxGuiLib.LuaGuiStyle.writable_members
--- @field minimal_width int? Minimal width ensures that the widget will never be smaller than that size.
--- @field maximal_width int? Maximal width ensures that the widget will never be bigger than that size.
--- @field minimal_height int? Minimal height ensures that the widget will never be smaller than that size.
--- @field maximal_height int? Maximal height ensures that the widget will never be bigger than that size.
--- @field natural_width int? Natural width specifies the width the element tries to have, but it can still be squashed/stretched.
--- @field natural_height int? Natural height specifies the height the element tries to have, but it can still be squashed/stretched.
--- @field top_padding int? Space between the widget's top edge and the contents.
--- @field right_padding int? Space between the widget's right edge and the contents.
--- @field bottom_padding int? Space between the widget's bottom edge and the contents.
--- @field left_padding int? Space between the widget's left edge and the contents.
--- @field top_margin int? Space between the widget's top edge and its parent container.
--- @field right_margin int? Space between the widget's right edge and its parent container.
--- @field bottom_margin int? Space between the widget's bottom edge and its parent container.
--- @field left_margin int? Space between the widget's left edge and its parent container.
--- @field horizontal_align "left" | "center" | "right"|nil Horizontal alignment of the inner content of the widget.
--- @field vertical_align "top" | "center" | "bottom"|nil Vertical alignment of the inner content of the widget.
--- @field font_color Color? Color of the font.
--- @field font string? The font used for the widget's text.
--- @field top_cell_padding int? Space between the table cell contents and the top border.
--- @field right_cell_padding int? Space between the table cell contents and the right border.
--- @field bottom_cell_padding int? Space between the table cell contents and the bottom border.
--- @field left_cell_padding int? Space between the table cell contents and the left border.
--- @field horizontally_stretchable boolean? Whether the widget stretches horizontally.
--- @field vertically_stretchable boolean? Whether the widget stretches vertically.
--- @field horizontally_squashable boolean? Whether the widget can be squashed horizontally by the parent element.
--- @field vertically_squashable boolean? Whether the widget can be squashed vertically by the parent element.
--- @field rich_text_setting defines.rich_text_setting? How this widget handles rich text.
--- @field hovered_font_color Color? Color of the font when hovered.
--- @field clicked_font_color Color?Color of the font when clicked.
--- @field disabled_font_color Color? Color of the font when disabled.
--- @field pie_progress_color Color? Color of the pie progress.
--- @field clicked_vertical_offset int? Vertical offset when clicked.
--- @field selected_font_color Color? Color of the font when selected.
--- @field selected_hovered_font_color Color? Color of the font when selected and hovered.
--- @field selected_clicked_font_color Color? Color of the font when selected and clicked.
--- @field strikethrough_color Color? Color of the strikethrough line.
--- @field draw_grayscale_picture boolean? Whether to draw a grayscale picture.
--- @field horizontal_spacing int? Horizontal space between individual cells in a table.
--- @field vertical_spacing int? Vertical space between individual cells in a table.
--- @field use_header_filler boolean? Whether to use a header filler in the widget.
--- @field bar_width uint? Width of the bar.
--- @field color Color? The color of the widget.
--- @field column_alignments LuaCustomTable<number, Alignment>? The alignment for every column of this table element.
--- @field single_line boolean? Whether the widget is a single line.
--- @field extra_top_padding_when_activated int? Extra padding at the top when the widget is activated.
--- @field extra_bottom_padding_when_activated int? Extra padding at the bottom when the widget is activated.
--- @field extra_left_padding_when_activated int? Extra padding on the left when the widget is activated.
--- @field extra_right_padding_when_activated int? Extra padding on the right when the widget is activated.
--- @field extra_top_margin_when_activated int? Extra margin at the top when the widget is activated.
--- @field extra_bottom_margin_when_activated int? Extra margin at the bottom when the widget is activated.
--- @field extra_left_margin_when_activated int? Extra margin on the left when the widget is activated.
--- @field extra_right_margin_when_activated int? Extra margin on the right when the widget is activated.
--- @field extra_padding_when_activated int|number[]|nil Extra padding to apply when activated.
--- @field extra_margin_when_activated int|number[]|nil Extra margin to apply when activated.
--- @field stretch_image_to_widget_size boolean? Whether to stretch the image to the widget's size.
--- @field badge_font string? Font used for the badge text.
--- @field badge_horizontal_spacing int? Horizontal spacing between the badge and other elements.
--- @field default_badge_font_color Color? Default color of the badge font.
--- @field selected_badge_font_color Color? Color of the badge font when selected.
--- @field disabled_badge_font_color Color? Color of the badge font when disabled.
--- @field width int? Sets both minimal and maximal width to the given value.
--- @field height int? Sets both minimal and maximal height to the given value.
--- @field size int|number[]|nil Sets both width and height to the given value.
--- @field padding int|number[]|nil Sets top/right/bottom/left paddings to the given value.
--- @field margin int|number[]|nil Sets top/right/bottom/left margins to the given value.
--- @field cell_padding int? Space between the table cell contents and the border.



--- @class KuxGuiLib.LuaGuiElemen.add.base
--- @field gui LuaGui The GUI element associated with this style.
--- @field name string The name of this GUI element.
--- @field caption LocalisedString The caption or text displayed on the element.
--- @field tooltip LocalisedString The tooltip of the element.
--- @field enabled boolean Whether the element is enabled.
--- @field visible boolean Whether the element is visible.
--- @field ignored_by_interaction boolean Whether the element is ignored by interaction.
--- @field style string The style prototype applied to the element.
--- @field tags Tags Tags associated with the element.
--- @field index uint The position of the element in its parent container.
--- @field anchor GuiAnchor The position of the element relative to its parent.
--- @field game_controller_interaction defines.game_controller_interaction How the element interacts with game controllers.
--- @field raise_hover_events boolean Whether the element raises hover events.



--- @class KuxGuiLib.LuaGuiElement.Button : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field mouse_button_filter MouseButtonFlags Which mouse buttons the button responds to.
--- @field auto_toggle boolean Whether the button automatically toggles when clicked.
--- @field toggled boolean The initial toggled state of the button.


--- @class KuxGuiLib.LuaGuiElement.Flow : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field direction GuiDirection The initial direction of the flow's layout (horizontal or vertical).


--- @class KuxGuiLib.LuaGuiElement.Frame : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field direction GuiDirection The initial direction of the frame's layout (horizontal or vertical).
local Frame = {}

--- @class KuxGuiLib.LuaGuiElement.Table : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field column_count uint The number of columns in the table.
--- @field draw_vertical_lines boolean Whether to draw vertical grid lines in the table.
--- @field draw_horizontal_lines boolean Whether to draw horizontal grid lines in the table.
--- @field draw_horizontal_line_after_headers boolean Whether to draw a single horizontal line after headers.
--- @field vertical_centering boolean Whether the content is vertically centered in the table.
local Table = {}

--- @class KuxGuiLib.LuaGuiElement.TextField : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field text string The initial text in the text field.
--- @field numeric boolean Whether the text field accepts only numeric input.
--- @field allow_decimal boolean Whether decimal numbers are allowed.
--- @field allow_negative boolean Whether negative numbers are allowed.
--- @field is_password boolean Whether the text field is a password field.
--- @field lose_focus_on_confirm boolean Whether the text field loses focus when confirmed.
--- @field icon_selector boolean Whether to add the rich text icon selector to the text field.
local TextField = {}

--- @class KuxGuiLib.LuaGuiElement.ProgressBar : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field value double The initial value of the progress bar (range: [0, 1]).
local ProgressBar = {}

--- @class KuxGuiLib.LuaGuiElement.Checkbox : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field state boolean The initial checked state of the checkbox.
local Checkbox = {}

--- @class KuxGuiLib.LuaGuiElement.RadioButton : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field state boolean The initial checked state of the radio button.
local RadioButton = {}

--- @class KuxGuiLib.LuaGuiElement.SpriteButton : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field sprite SpritePath The path to the image to display on the button.
--- @field hovered_sprite SpritePath The path to the image when the button is hovered.
--- @field clicked_sprite SpritePath The path to the image when the button is clicked.
--- @field number double The number shown on the button.
--- @field show_percent_for_small_numbers boolean Whether to show percentages for small numbers.
--- @field mouse_button_filter MouseButtonFlags The mouse buttons the button responds to.
--- @field auto_toggle boolean Whether the button automatically toggles when clicked.
--- @field toggled boolean The initial toggled state of the button.
local SpriteButton = {}

--- @class KuxGuiLib.LuaGuiElement.ScrollPane : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field horizontal_scroll_policy ScrollPolicy The policy for the horizontal scroll bar.
--- @field vertical_scroll_policy ScrollPolicy The policy for the vertical scroll bar.
local ScrollPane = {}

--- @class KuxGuiLib.LuaGuiElement.DropDown : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field items array[LocalisedString] The initial items in the dropdown.
--- @field selected_index uint The initially selected index.
local DropDown = {}

--- @class KuxGuiLib.LuaGuiElement.TextBox : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field text string The initial text in the text box.
--- @field icon_selector boolean Whether to add the rich text icon selector to the text box.
local TextBox = {}

--- @class KuxGuiLib.LuaGuiElement.Slider : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field minimum_value double The minimum value for the slider.
--- @field maximum_value double The maximum value for the slider.
--- @field value double The initial value for the slider.
--- @field value_step double The step the slider can move.
--- @field discrete_values boolean Whether the slider only allows discrete values.
local Slider = {}

--- @class KuxGuiLib.LuaGuiElement.Minimap : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field position MapPosition The position the minimap centers on.
--- @field surface_index uint The surface index of the minimap.
--- @field zoom double The initial zoom level for the minimap.
local Minimap = {}

--- @class KuxGuiLib.LuaGuiElement.ChooseElemButton : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field elem_type ElemType The type of the button.
--- @field item string If type is "item" - the default value for the button.
--- @field tile string If type is "tile" - the default value for the button.
--- @field entity string If type is "entity" - the default value for the button.
--- @field signal SignalID If type is "signal" - the default value for the button.
--- @field fluid string If type is "fluid" - the default value for the button.
--- @field recipe string If type is "recipe" - the default value for the button.
--- @field decorative string If type is "decorative" - the default value for the button.
--- @field item-group string If type is "item-group" - the default value for the button.
--- @field achievement string If type is "achievement" - the default value for the button.
--- @field equipment string If type is "equipment" - the default value for the button.
--- @field technology string If type is "technology" - the default value for the button.
--- @field item-with-quality PrototypeWithQuality If type is "item-with-quality" - the default value for the button.
--- @field entity-with-quality PrototypeWithQuality If type is "entity-with-quality" - the default value for the button.
--- @field recipe-with-quality PrototypeWithQuality If type is "recipe-with-quality" - the default value for the button.
--- @field equipment-with-quality PrototypeWithQuality If type is "equipment-with-quality" - the default value for the button.
--- @field elem_filters PrototypeFilter Filters describing what to show in the selection window.
local ChooseElemButton = {}

--- @class KuxGuiLib.LuaGuiElement.Tab : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field badge_text LocalisedString The text to display after the normal tab text (designed to work with numbers).
local Tab = {}

--- @class KuxGuiLib.LuaGuiElement.Switch : KuxGuiLib.LuaGuiElemen.add.base, KuxGuiLib.LuaGuiStyle.writable_members
--- @field switch_state SwitchState If set to "none", allow_none_state must be true.
--- @field allow_none_state boolean Whether the switch can be set to a middle state.
--- @field left_label_caption LocalisedString Left label caption.
--- @field left_label_tooltip LocalisedString Left label tooltip.
--- @field right_label_caption LocalisedString Right label caption.
--- @field right_label_tooltip LocalisedString Right label tooltip.
local Switch = {}
