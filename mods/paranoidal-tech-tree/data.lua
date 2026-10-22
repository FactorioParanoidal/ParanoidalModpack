data:extend({
  { type = "custom-input", name = "ptt-toggle", key_sequence = "CONTROL + T", action = "lua" },
})
-- Do not intercept the mouse wheel or movement keys. Native scroll panes own scrolling.
-- Evolution icon of the path panel (the same picture as the evolution note of technologies).
if mods["zzzparanoidal"] then
  data:extend({
    { type = "sprite", name = "ptt-evolution", filename = "__zzzparanoidal__/graphics/research-evolution-icon.png",
      size = 64, flags = {"gui-icon"} },
  })
end
