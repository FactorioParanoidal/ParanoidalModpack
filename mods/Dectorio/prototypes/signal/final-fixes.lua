-- signal/final-fixes

if DECT.ENABLED["signals"] then

	-- Get signals and update mappings (in case some new ones are added by other mods)
	local colors = DECT.CONFIG.SIGNALS
	for _, signal in pairs(data.raw["virtual-signal"]) do
		if not (signal.subgroup == "virtual-signal-color") and signal.color then
			table.insert(colors, {type=signal.type, name=signal.name, color=signal.color})
		end
	end

	-- Quick sanity check to filter out any items that might have been removed by other mods
	local mapped_colors = {}
	for _, signal in pairs(colors) do
		if signal.type == "virtual" then
			table.insert(mapped_colors, {type=signal.type, name=signal.name, color=signal.color})
		else
			if signal.name:find("%-science%-pack") and data.raw["tool"][signal.name] then
				table.insert(mapped_colors, {type=signal.type, name=signal.name, color=signal.color})
			elseif data.raw[signal.type][signal.name] then
				table.insert(mapped_colors, {type=signal.type, name=signal.name, color=signal.color})
			end
		end
	end

	-- Map colors to lamp entities
	for _, lamp in pairs(data.raw.lamp) do
		lamp.signal_to_color_mapping = mapped_colors
	end

	-- Reorder some of the base game signals to improve the signal layout
	data:extend({
		{
			type = "item-subgroup",
			name = "last",
			group = "signals",
			order = "zz"
		}
	})
	if data.raw["virtual-signal"]["signal-check"] then
		data.raw["virtual-signal"]["signal-check"].subgroup = "last"
		data.raw["virtual-signal"]["signal-check"].order = "z[misc]-[9checked]"
	end
	if data.raw["virtual-signal"]["signal-info"] then
		data.raw["virtual-signal"]["signal-info"].subgroup = "last"
		data.raw["virtual-signal"]["signal-info"].order = "z[misc]-[9info]"
	end
	if data.raw["virtual-signal"]["signal-dot"] then
		data.raw["virtual-signal"]["signal-dot"].subgroup = "last"
		data.raw["virtual-signal"]["signal-dot"].order = "z[misc]-[9dot]"
	end

end
