-- muluna-graphics works alongside planet-muluna, so make sure a compatible
-- version is installed when planet-muluna is present.
local planet_muluna_version = mods["planet-muluna"]

if planet_muluna_version then
  local required_version = "2.7.38"

  if helpers.compare_versions(planet_muluna_version, required_version) < 0 then
    error("This version of muluna-graphics requires planet-muluna >= " .. required_version .. ".")
  end
end
