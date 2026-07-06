-- signal/signals

local function char(num)
	return string.char(string.byte("a") + num - 1)
end

if DECT.ENABLED["signals"] then
	-- Coloured signals
	-- ----------

	-- Get signals
	local colors = DECT.CONFIG.SIGNALS

	-- Clear out any existing signals that conflict with config
	for name, signal in pairs(data.raw["virtual-signal"]) do
		if signal.subgroup == "virtual-signal-color" then
			for i, color in pairs(colors) do
				if color.type == "virtual" and color.name == name then
					data.raw["virtual-signal"][name] = nil
				end
			end
		end
	end

	-- Create new virtual colour items if they don't already exist
	for i, color in pairs(colors) do
		if color.type == "virtual" then
			local tint = {r = color.color.r, g = color.color.g, b = color.color.b, a = 0.70}
			data:extend(
				{
					{
						type = "virtual-signal",
						name = color.name,
						icons = {
							{icon = "__base__/graphics/icons/signal/signal_grey.png", tint = tint}
						},
						icon_size = 64,
						icon_mipmaps = 4,
						subgroup = "virtual-signal-color",
						order = "d[colors]-0[" .. char(i) .. "-" .. color.name .. "]"
					}
				}
			)
		end
	end

	-- Reset black signal to 'correct' icon
	if data.raw["virtual-signal"]["signal-black"] then
		local black = data.raw["virtual-signal"]["signal-black"]
		black.icons[1].tint = {r = 0.16, g = 0.16, b = 0.16, a = 0.70}
	end

	-- Icon signals
	-- ----------

	local iconsets = {
		["arrow"] = {
			name = "arrow",
			background = {r = 1.00, g = 0.58, b = 0.14, a = 0.2},
			order = "eb",
			icons = {"down", "up", "left", "right", "vertical", "horizontal", "universal", "reset"}
		},
		["misc"] = {
			name = "misc",
			background = {r = 0.65, g = 0.38, b = 0.99, a = 0.2},
			order = "ea",
			icons = {
				"clock",
				"alarm",
				"battery",
				"power",
				"nuclear",
				"rocket",
				"temperature",
				"finish",
				"gears",
				"star",
				"light",
				"mine",
				"oil",
				"gun",
				"tank",
				"train",
				"wall",
				"siren",
				"warning-shield",
				"warning-triangle"
			}
		}
	}

	-- Create new virtual signals with icons
	for i, iconset in pairs(iconsets) do
		data:extend(
			{
				{
					type = "item-subgroup",
					name = iconset.name,
					group = "signals",
					order = iconset.order
				}
			}
		)

		local pos = 1
		for j, icon in pairs(iconset.icons) do
			data:extend(
				{
					{
						type = "virtual-signal",
						name = "dect-signal-" .. iconset.name .. "-" .. icon,
						localised_name = {"dect-signal." .. iconset.name .. "-" .. icon},
						icons = {
							{
								icon = "__base__/graphics/icons/signal/signal_grey.png",
								tint = iconset.background,
								icon_size = 64,
								icon_mipmaps = 4
							},
							{
								icon = "__Dectorio__/graphics/signal/" .. iconset.name .. "-" .. icon .. ".png",
								icon_size = 64,
								icon_mipmaps = 1
							}
						},
						subgroup = iconset.name,
						order = iconset.order .. "[" .. iconset.name .. "]-" .. char(pos) .. "[" .. icon .. "]"
					}
				}
			)
			pos = pos + 1
		end
	end
end
