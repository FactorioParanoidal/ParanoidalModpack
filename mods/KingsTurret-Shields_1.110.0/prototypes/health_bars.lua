local function create_animation(gfx_prefix, bubbles, height, width)
	data:extend({
		{
			type="animation", 
			name=gfx_prefix .. "square-" .. bubbles,
			filename = "__KingsTurret-Shields__/graphics/" .. gfx_prefix .. "square-" .. bubbles .. ".png",
			width = width,
			height = height,
			scale = 0.25,
			shift = {0,0.1}
		}
	})
end

local gfx_height = GFX_NORMAL_HEIGHT
local gfx_width = GFX_NORMAL_WIDTH

for i = 0,9,1 do
	create_animation("", i, gfx_height, gfx_width)
end

gfx_height = GFX_LIQUID_HEIGHT
gfx_width = GFX_LIQUID_WIDTH
for i = 0,13,1 do
	create_animation("liquid-", i, gfx_height, gfx_width)
end