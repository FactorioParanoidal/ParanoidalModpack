minime.entered_file()

if not minime.character_selector then
  minime.entered_file("leave", "character selector is not active")
  return
end


------------------------------------------------------------------------------------
-- Define shortcut for toggling the main GUI

local sprites = data.raw.sprite
local names = minime.sprite_names

minime.show("names.shortcut", names.shortcut)
minime.show("sprites[names.shortcut]", sprites[names.shortcut])

local function get_icon(name)
  local sprite = sprites[name]
  if not sprite then
    minime.arg_err(name, "invalid sprite name")
  end

  local ret = {
    icon = sprite.filename,
    icon_size = sprite.size,
    tint = sprite.tint,
    shift = sprite.shift,
    scale = sprite.scale,
  }
  return {ret}
end

local toggle_selector = {
  type = "shortcut",
  name = minime.toggle_gui_input_shortcut_name,
  localised_name = {"controls.minime-toggle-selector-gui"},
  icons = get_icon(names.shortcut),
  small_icons = get_icon(names.shortcut_small),
  disabled_icons = get_icon(names.shortcut_disabled),
  disabled_small_icons = get_icon(names.shortcut_small_disabled),
  action = "lua",
  associated_control_input = minime.toggle_gui_input_shortcut_name,
  toggleable = true,
}
data:extend({toggle_selector})
minime.created_msg(toggle_selector)

------------------------------------------------------------------------------------
minime.entered_file("leave")
