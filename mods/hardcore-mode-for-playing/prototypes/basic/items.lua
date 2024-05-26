local function copy_item(name, new_name)
	return flib.copy_prototype(data.raw["item"][name], new_name)
end
local function copy_tool(name, new_name)
	return flib.copy_prototype(data.raw["tool"][name], new_name)
end
data:extend(
	{
		copy_item("iron-gear-wheel", "salvaged-iron-gear-wheel"),
		copy_item("burner-mining-drill", "salvaged-mining-drill"),
		copy_tool("automation-science-pack", "salvaged-automation-science-pack")
	}
)
if settings.startup["hardcore-mode-for-playing-use-separated-technologies-for-every-resource"].value then
	data:extend(
		{
			copy_item("radar", "salvaged-radar")
		}
	)
end
