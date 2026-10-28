data:extend({
  { type = "custom-input", name = "ptt-toggle", key_sequence = "CONTROL + T", action = "lua" },
  -- Toolbar button: a flask with layers of science pack colors, 64 px at scale 0.5 like the GUI Unifier icons.
  { type = "sprite", name = "ptt-toolbar-button", filename = "__paranoidal-tech-tree__/graphics/toolbar-flask.png",
    width = 64, height = 64, scale = 0.5, flags = {"gui-icon"}, priority = "extra-high-no-scale" },
})
-- Do not intercept the mouse wheel or movement keys. Native scroll panes own scrolling.
-- Evolution icon of the path panel (the same picture as the evolution note of technologies).
if mods["zzzparanoidal"] then
  data:extend({
    { type = "sprite", name = "ptt-evolution", filename = "__zzzparanoidal__/graphics/research-evolution-icon.png",
      size = 64, flags = {"gui-icon"} },
  })
end
