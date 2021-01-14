local SpritesBuilder  = require("__FluidMustFlow__/linver-lib/SpritesBuilder")
local sprites_builder = SpritesBuilder:new()

local _pipes_overlay = {}

function _pipes_overlay.getDuctFixedPipePictures()
  return sprites_builder.getPicture4Parts
  (
    sprites_builder.getEmptySprite(),
    sprites_builder.getEmptySprite(),
    {
		filename = "__FluidMustFlow__/graphics/entity/other/pipe-straight-vertical.png",
		priority = "extra-high",
		width = 23,
		height = 20,
		scale = 1,
		shift = {0, 0.5},
		hr_version = 
		{
			filename = "__FluidMustFlow__/graphics/entity/other/hr_pipe-straight-vertical.png",
			priority = "extra-high",
			width = 45,
			height = 40,
			scale = 0.5,
			shift = {0, 0.5}
		}
    },
    sprites_builder.getEmptySprite()
  )
end
--[[
function _pipes_overlay.getDuctFixedPipeCoversPictures(direction)
	duct_cover = pipecoverspictures()
	if     direction == defines.direction.east then
		duct_cover.west = sprites_builder.getEmptySprite()
	elseif direction == defines.direction.south then
		duct_cover.north = sprites_builder.getEmptySprite()
	elseif direction == defines.direction.north then
		duct_cover.south = sprites_builder.getEmptySprite()
	else 
		duct_cover.east = sprites_builder.getEmptySprite()
	end
	
	return duct_cover
end
--]]
return _pipes_overlay
