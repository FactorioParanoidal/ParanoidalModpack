if (stickersG) then
    return stickersG
end
local stickers = {}

function stickers.makeSpeedStickers()
    data:extend({
	
			{
			type = "sticker",
			name = "2xSpeed-sticker-rampantFixed",
			flags = {"not-on-map"},
			target_movement_modifier = 2,
			force_visibility = "ally",
			duration_in_ticks = 10 * 60,
			}
			,
			{
			type = "sticker",
			name = "3xSpeed-sticker-rampantFixed",
			flags = {"not-on-map"},
			target_movement_modifier = 3,
			force_visibility = "ally",
			duration_in_ticks = 10 * 60,
			}
			,
			{
			type = "sticker",
			name = "4xSpeed-sticker-rampantFixed",
			flags = {"not-on-map"},
			target_movement_modifier = 4,
			force_visibility = "ally",
			duration_in_ticks = 10 * 60,
			}
			,
			{
			type = "sticker",
			name = "5xSpeed-sticker-rampantFixed",
			flags = {"not-on-map"},
			target_movement_modifier = 5,
			force_visibility = "ally",
			duration_in_ticks = 10 * 60,
			}
			,
			{
			type = "sticker",
			name = "6xSpeed-sticker-rampantFixed",
			flags = {"not-on-map"},
			target_movement_modifier = 6,
			force_visibility = "ally",
			duration_in_ticks = 10 * 60,
			}
		})

end

stickersG = stickers
return stickersG