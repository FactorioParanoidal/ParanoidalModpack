-- forced_value exists only for bool settings; int/double settings are just hidden
function maf_disable_setting(raw,forced_value)
if raw then
	raw.hidden = true
	if raw.type == "bool-setting" then raw.forced_value = forced_value end
end	
end

if not mods["space-age"] then 
	maf_disable_setting(data.raw["double-setting"]["bm-gleba-invaders-min_evo"])
	maf_disable_setting(data.raw["int-setting"]["bm-gleba-invaders-chance"])
	maf_disable_setting(data.raw["bool-setting"]["bm-spawn_on_sa_planets"],false)
	end
