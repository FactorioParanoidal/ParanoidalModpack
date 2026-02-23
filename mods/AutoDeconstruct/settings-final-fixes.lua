-- Add se-space-pipe to list of defaults if Space Exploration is loaded
if mods["space-exploration"] then
  local old_value = data.raw["string-setting"]["autodeconstruct-pipe-name"].default_value
  if old_value ~= "" then
    old_value = old_value .. ","
  end
  data.raw["string-setting"]["autodeconstruct-pipe-name"].default_value = old_value .. "se-space-pipe"
end

-- Add tiberium-ore to the list of banned ores if Factorio-Tiberium is installed
if mods["Factorio-Tiberium"] then
  local old_value = data.raw["string-setting"]["autodeconstruct-ore-blacklist"].default_value
  if old_value ~= "" then
    old_value = old_value .. ","
  end
  data.raw["string-setting"]["autodeconstruct-ore-blacklist"].default_value = old_value .. "tiberium-ore"
end
