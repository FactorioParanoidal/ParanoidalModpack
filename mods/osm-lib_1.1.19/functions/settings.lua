----------------------
---- settings.lua ----
----------------------

if not OSM.lib.setting then OSM.lib.setting = {} end

-- Hide setting
function OSM.lib.setting.hide_setting(setting_type, setting_name)
	if not data.raw[setting_type] then return error("\nSetting type: "..setting_type.." does not exist") end
	if data.raw[setting_type][setting_name] then
		data.raw[setting_type][setting_name].hidden = true
	end
end

-- Forcibly enable bool setting
function OSM.lib.setting.force_enable(setting_name)
	if data.raw["bool-setting"][setting_name] then
		data.raw["bool-setting"][setting_name].forced_value = true
		data.raw["bool-setting"][setting_name].hidden = true
	end
end

-- Forcibly disable bool setting
function OSM.lib.setting.force_disable(setting_name)
	if data.raw["bool-setting"][setting_name] then
		data.raw["bool-setting"][setting_name].forced_value = false
		data.raw["bool-setting"][setting_name].hidden = true
	end
end

-- Forcibly assign value to non-boolean setting [value is optional]
function OSM.lib.setting.force_value(setting_type, setting_name, value)
	if not data.raw[setting_type] then return error("\nSetting type: "..setting_type.." does not exist") end
	if data.raw[setting_type][setting_name] then
		if not value then value = data.raw[setting_type][setting_name].default_value end

		data.raw[setting_type][setting_name].forced_value = value
		data.raw[setting_type][setting_name].hidden = true
	end
end