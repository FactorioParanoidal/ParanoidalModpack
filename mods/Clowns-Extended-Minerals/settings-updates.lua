--copied from angels smelting...
local function hide_setting(setting_type, setting_name, setting_default)
  if data.raw[setting_type] and data.raw[setting_type][setting_name] then
    data.raw[setting_type][setting_name].hidden = true
    if setting_default ~= nil then
      data.raw[setting_type][setting_name].default_value = setting_default
    end
  end
end
local sett = {
	"enableinfiniteclownsore1",
	"enableinfiniteclownsore2",
	"enableinfiniteclownsore3",
	"enableinfiniteclownsore4",
	"enableinfiniteclownsore5",
	"enableinfiniteclownsore6",
	"enableinfiniteclownsore7",
	"enableinfiniteclownsore8",
	"enableinfiniteclownsore9",
	"enableinfiniteclownsresource1",
	"enableinfiniteclownsresource2"
}
if mods["angelsinfiniteores"] then
else
	for _,sett in pairs(sett) do
		hide_setting("bool-setting", sett)
	end
end