------------------
---- data.lua ----
------------------

if not OSM.lib.setting then OSM.lib.setting = {} end

-- Hide setting
function OSM.lib.setting.hide_setting(setting_type, setting_name)
	if data.raw[setting_type] and data.raw[setting_type][setting_name] then
		data.raw[setting_type][setting_name].hidden = true
	end
end

-- Forcibly enable setting
function OSM.lib.setting.force_enable(setting_type, setting_name)
	if data.raw[setting_type] and data.raw[setting_type][setting_name] then
		data.raw[setting_type][setting_name].forced_value = true
		data.raw[setting_type][setting_name].hidden = true
	end
end

-- Forcibly disable setting
function OSM.lib.setting.force_disable(setting_type, setting_name)
	if data.raw[setting_type] and data.raw[setting_type][setting_name] then
		data.raw[setting_type][setting_name].forced_value = false
		data.raw[setting_type][setting_name].hidden = true
	end
end

-- Void setting [experimental]
function OSM.lib.setting.void_setting(setting_type, setting_name)
	if data.raw[setting_type] and data.raw[setting_type][setting_name] then
		data.raw[setting_type][setting_name] = nil
		data:extend
		({
			{
				type = "string-setting",
				name = setting_name,
				setting_type = "startup",
				default_value = "VOID",
				allowed_values = {"VOID"},
				hidden = true
			}
		})
	end
end