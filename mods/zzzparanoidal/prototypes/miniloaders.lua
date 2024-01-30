if mods.miniloader and settings.startup["miniloader-energy-usage"].value then  --don't tweak energy usage, if it disabled
  local energy_multiplier = settings.startup["paranoidal-miniloader-energy-multiplier"].value or 4
  local energy_string = 2*energy_multiplier .. "kJ"
  for _,inserter in pairs(data.raw.inserter) do
    if string.find(inserter.name, "miniloader%-inserter$") then
      inserter.energy_per_movement = energy_string
      inserter.energy_per_rotation = energy_string
    end
  end  
end
