-- Reserve the default Ctrl+T for this browser without patching third-party mods.
-- Personal bindings remain under the player's control in Settings > Controls.
for _, name in ipairs({"toggle_view_research", "helmod-richtext-open", "cybersyn-toggle-gui"}) do
  local input = data.raw["custom-input"][name]
  if input then
    if input.key_sequence == "CONTROL + T" then input.key_sequence = "" end
    if input.alternative_key_sequence == "CONTROL + T" then input.alternative_key_sequence = "" end
  end
end
