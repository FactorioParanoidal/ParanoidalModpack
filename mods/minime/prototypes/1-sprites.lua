minime.entered_file()

if not minime.character_selector then
  minime.entered_file("leave", "character selector is not active")
  return
end

------------------------------------------------------------------------------------
-- Get the icon scheme from settings
------------------------------------------------------------------------------------
minime.writeDebugNewBlock("Getting icon scheme!")
local scheme = minime.get_startup_setting("minime_icon-scheme")
minime.writeDebug("Will use scheme %s.", {minime.enquote(scheme)})


------------------------------------------------------------------------------------
-- Define sprites
------------------------------------------------------------------------------------
local scheme_data = {
  plexpt_1 = {file = "btn1.png", size = 128 },
  plexpt_2 = {file = "btn2.png", size = 128 },
}


--~ local sprites = {
  --~ -- Toggle button (character selector)
  --~ button = {
    --~ type = "sprite",
    --~ name = minime.sprite_names["button"],
    --~ filename = minime.IMG_PATH.."gui-toggle-button-dark-64.png",
    --~ priority = "extra-high-no-scale",
    --~ flags = { "gui-icon", },
    --~ size = 64,
  --~ },

  --~ -- Shortcut
  --~ shortcut = {
    --~ type = "sprite",
    --~ name = minime.sprite_names["shortcut"],
    --~ filename = minime.IMG_PATH.."gui-toggle-shortcut-dark-32.png",
    --~ priority = "extra-high-no-scale",
    --~ flags = { "icon", },
    --~ size = 32,
  --~ },

  --~ shortcut_small = {
    --~ type = "sprite",
    --~ name = minime.sprite_names["shortcut_small"],
    --~ filename = minime.IMG_PATH.."gui-toggle-shortcut-dark-24.png",
    --~ priority = "extra-high-no-scale",
    --~ flags = { "icon", },
    --~ size = 24,
  --~ },

  --~ shortcut_disabled = {
    --~ type = "sprite",
    --~ name = minime.sprite_names["shortcut_disabled"],
    --~ filename = minime.IMG_PATH.."gui-toggle-shortcut-light-32.png",
    --~ priority = "extra-high-no-scale",
    --~ flags = { "icon", },
    --~ size = 32,
  --~ },

  --~ shortcut_small_disabled = {
    --~ type = "sprite",
    --~ name = minime.sprite_names["shortcut_small_disabled"],
    --~ filename = minime.IMG_PATH.."gui-toggle-shortcut-light-24.png",
    --~ priority = "extra-high-no-scale",
    --~ flags = { "icon", },
    --~ size = 24,
  --~ },
--~ }
local sprites = {
  -- Toggle button (character selector)
  button = {
    type = "sprite",
    name = minime.sprite_names["button"],
    --~ filename = minime.IMG_PATH.."gui-toggle-button-dark-64.png",
    filename = scheme_data[scheme] and
                minime.IMG_PATH..scheme_data[scheme].file or
                minime.IMG_PATH.."gui-toggle-button-dark-64.png",
    priority = "extra-high-no-scale",
    flags = { "gui-icon", },
    --~ size = 64,
    size = scheme_data[scheme] and scheme_data[scheme].size or 64,
  },

  -- Shortcut
  shortcut = {
    type = "sprite",
    name = minime.sprite_names["shortcut"],
    --~ filename = minime.IMG_PATH.."gui-toggle-shortcut-dark-32.png",
    filename = scheme_data[scheme] and
                minime.IMG_PATH..scheme_data[scheme].file or
                minime.IMG_PATH.."gui-toggle-shortcut-dark-32.png",
    priority = "extra-high-no-scale",
    flags = { "icon", },
    --~ size = 32,
    size = scheme_data[scheme] and scheme_data[scheme].size or 32,
  },

  shortcut_small = {
    type = "sprite",
    name = minime.sprite_names["shortcut_small"],
    --~ filename = minime.IMG_PATH.."gui-toggle-shortcut-dark-24.png",
    filename = scheme_data[scheme] and
                minime.IMG_PATH..scheme_data[scheme].file or
                minime.IMG_PATH.."gui-toggle-shortcut-dark-24.png",
    priority = "extra-high-no-scale",
    flags = { "icon", },
    --~ size = 24,
    size = scheme_data[scheme] and scheme_data[scheme].size or 24,
  },

  shortcut_disabled = {
    type = "sprite",
    name = minime.sprite_names["shortcut_disabled"],
    --~ filename = minime.IMG_PATH.."gui-toggle-shortcut-light-32.png",
    filename = scheme_data[scheme] and
                minime.IMG_PATH..scheme_data[scheme].file or
                minime.IMG_PATH.."gui-toggle-shortcut-light-32.png",
    priority = "extra-high-no-scale",
    flags = { "icon", },
    --~ size = 32,
    size = scheme_data[scheme] and scheme_data[scheme].size or 32,
  },

  shortcut_small_disabled = {
    type = "sprite",
    name = minime.sprite_names["shortcut_small_disabled"],
    --~ filename = minime.IMG_PATH.."gui-toggle-shortcut-light-24.png",
    filename = scheme_data[scheme] and
                minime.IMG_PATH..scheme_data[scheme].file or
                minime.IMG_PATH.."gui-toggle-shortcut-light-24.png",
    priority = "extra-high-no-scale",
    flags = { "icon", },
    --~ size = 24,
    size = scheme_data[scheme] and scheme_data[scheme].size or 24,
  },
}

for s_name, sprite in pairs(sprites) do
  data:extend({sprite})
  minime.created_msg(sprite)
end

------------------------------------------------------------------------------------
minime.entered_file("leave")
