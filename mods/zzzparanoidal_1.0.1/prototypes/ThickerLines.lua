--[[
    "name": "ThickerLines",
    "version": "0.0.4",
    "title": "Thicker Power Wires",
    "author": "Lachlan McDonald",
    "factorio_version": "1.1",
	"dependencies": ["base >= 1.0.0"],
    "description": "Improved visibility of power lines and circuit wires"
]]

local core_graphics = "__zzzparanoidal__/graphics/ThickerLines"

if settings.startup["wire"].value then
data.raw["utility-sprites"]["default"]["green_wire"].filename                       = core_graphics .. "/green-wire.png"
data.raw["utility-sprites"]["default"]["green_wire"].hr_version.filename            = core_graphics .. "/hr-green-wire.png"

data.raw["utility-sprites"]["default"]["red_wire"].filename                         = core_graphics .. "/red-wire.png"
data.raw["utility-sprites"]["default"]["red_wire"].hr_version.filename              = core_graphics .. "/hr-red-wire.png"

data.raw["utility-sprites"]["default"]["wire_shadow"].filename                      = core_graphics .. "/wire-shadow.png"
data.raw["utility-sprites"]["default"]["wire_shadow"].hr_version.filename           = core_graphics .. "/hr-wire-shadow.png"

data.raw["utility-sprites"]["default"]["green_wire_hightlight"].filename            = core_graphics .. "/wire-highlight.png"
data.raw["utility-sprites"]["default"]["green_wire_hightlight"].hr_version.filename = core_graphics .. "/hr-wire-highlight.png"

data.raw["utility-sprites"]["default"]["red_wire_hightlight"].filename              = core_graphics .. "/wire-highlight.png"
data.raw["utility-sprites"]["default"]["red_wire_hightlight"].hr_version.filename   = core_graphics .. "/hr-wire-highlight.png"
end

if settings.startup["copper_wire"].value then
data.raw["utility-sprites"]["default"]["copper_wire"].filename                      = core_graphics .. "/copper-wire.png"
data.raw["utility-sprites"]["default"]["copper_wire"].hr_version.filename           = core_graphics .. "/hr-copper-wire.png"

data.raw["utility-sprites"]["default"]["wire_shadow"].filename                      = core_graphics .. "/wire-shadow.png"
data.raw["utility-sprites"]["default"]["wire_shadow"].hr_version.filename           = core_graphics .. "/hr-wire-shadow.png"
end