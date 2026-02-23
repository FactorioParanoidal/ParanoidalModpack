function maf_disable_setting(raw,forced_value)
if raw then
	raw.hidden = true
	raw.forced_value = forced_value 
end	
end

if not mods["space-age"] then 
	maf_disable_setting(data.raw["double-setting"]["bm-gleba-invaders-min_evo"],1)
	maf_disable_setting(data.raw["double-setting"]["bm-gleba-invaders-chance"],0)
	maf_disable_setting(data.raw["double-setting"]["bm-spawn_on_sa_planets"],true)
	end
