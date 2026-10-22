local core_graphics = "__zzzparanoidal__/graphics/ThickerLines"

-- since 2.0 all sprites assumed to be in high resolution
if settings.startup["wire"].value then
	data.raw["utility-sprites"]["default"]["green_wire"].filename = core_graphics .. "/hr-green-wire.png"
	data.raw["utility-sprites"]["default"]["red_wire"].filename = core_graphics .. "/hr-red-wire.png"
	data.raw["utility-sprites"]["default"]["wire_shadow"].filename = core_graphics .. "/hr-wire-shadow.png"
	data.raw["utility-sprites"]["default"]["green_wire_highlight"].filename = core_graphics .. "/hr-wire-highlight.png"
	data.raw["utility-sprites"]["default"]["red_wire_highlight"].filename = core_graphics .. "/hr-wire-highlight.png"
end

if settings.startup["copper_wire"].value then
	data.raw["utility-sprites"]["default"]["copper_wire"].filename = core_graphics .. "/hr-copper-wire.png"
	data.raw["utility-sprites"]["default"]["wire_shadow"].filename = core_graphics .. "/hr-wire-shadow.png"
end

-- Wire transparency (Beta 8: PickerTweaks "Almost Invisible Wires").
-- Sprites are pre-rendered from the 2.0 core and ThickerLines graphics with scaled alpha.
local transparency_graphics = "__zzzparanoidal__/graphics/wire-transparency"
local transparent_wires = {
	{ sprite = "copper_wire", file = "copper-wire", setting = "paranoidal-wire-visibility-copper", thick = "copper_wire" },
	{ sprite = "red_wire", file = "red-wire", setting = "paranoidal-wire-visibility-red", thick = "wire" },
	{ sprite = "green_wire", file = "green-wire", setting = "paranoidal-wire-visibility-green", thick = "wire" },
}
local hide_shadow = false
for _, wire in pairs(transparent_wires) do
	local visibility = settings.startup[wire.setting].value
	if visibility ~= "100" then
		hide_shadow = true
		local filename = transparency_graphics .. "/transparent.png"
		if visibility ~= "0" then
			local variant = settings.startup[wire.thick].value and "thick" or "thin"
			filename = transparency_graphics .. "/" .. wire.file .. "-" .. variant .. "-" .. visibility .. ".png"
		end
		data.raw["utility-sprites"]["default"][wire.sprite].filename = filename
	end
end
-- The shadow is shared by all wires: as in PickerTweaks, any non-default visibility removes it.
if hide_shadow then
	data.raw["utility-sprites"]["default"]["wire_shadow"].filename = transparency_graphics .. "/transparent.png"
end

