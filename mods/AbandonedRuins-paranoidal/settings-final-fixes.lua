-- The "paranoidal" ruin set contains every ruin (its own and the "base" set), so it is the default
-- and the only set offered besides "none". Removing "base" from the list also makes a stored
-- "base" value invalid: Factorio then uses the default "paranoidal" in existing mod settings and
-- in existing saves, without editing mod-settings.dat.
local setting = data.raw["string-setting"]["current-ruin-set"]
if setting then
  local allowed, has_own = {}, false
  for _, value in ipairs(setting.allowed_values or {}) do
    if value ~= "base" then allowed[#allowed + 1] = value end
    if value == "paranoidal" then has_own = true end
  end
  if not has_own then allowed[#allowed + 1] = "paranoidal" end
  setting.allowed_values = allowed
  setting.default_value = "paranoidal"
end
