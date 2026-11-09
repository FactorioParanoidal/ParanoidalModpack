local function lock_bool_setting(name, value)
    if not data.raw["bool-setting"][name] then return end -- Paranoidal fork: Spidertron Enhancements is not in the build
    data.raw["bool-setting"][name].hidden = true
    data.raw["bool-setting"][name].forced_value = value
    data.raw["bool-setting"][name].default_value = value
end

-- Paranoidal fork: locked off: with the spiderling Spidertron Patrols changes the home spidertron technology.
lock_bool_setting("sp-enable-spiderling", false)
lock_bool_setting("sp-enable-dock", true)
lock_bool_setting("sp-remove-military-requirement", false)
lock_bool_setting("spidertron-enhancements-increase-size", false)
