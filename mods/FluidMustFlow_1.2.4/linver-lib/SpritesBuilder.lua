-- Version 7

local SpritesBuilder         = {}
SpritesBuilder.sprites       = {}
-- -- Pictures
-- Normal
SpritesBuilder.sprites.sprite = 
{
	filename             = "__core__/graphics/empty.png",
	priority             = "high",
	width                = 1,
	height               = 1,
	scale                = 1
}
SpritesBuilder.sprites.shadow    = {}
-- High Resolution
SpritesBuilder.sprites.hr_sprite = {}
SpritesBuilder.sprites.hr_shadow = {}
SpritesBuilder.sprites.empty_sprite =
{
	filename    = "__core__/graphics/empty.png",
	priority    = "extra-high",
	width       = 1,
	height      = 1,
	frame_count = 1
}
SpritesBuilder.metatable = {__index = SpritesBuilder}

-- -- -- Setting methods for builder

-- -- Normal (low resolution or absolute)

function SpritesBuilder:setFilename(filename)
	if type(filename) == "string" then
		self.sprites.sprite.filename = filename
	end
end

function SpritesBuilder:setShadow(filename)
	self.sprites.shadow.filename = filename
end

function SpritesBuilder:setPriority(priority)
	if type(priority) == "string" then
		self.sprites.sprite.priority = priority
	end
end

function SpritesBuilder:setFilenameWithShadow(path, filename)
    self:setFilename(path..filename..'.png')
    self:setShadow(path..filename..'_shadow.png')
    self:setHRShadow(path..'hr_'..filename..'_shadow.png')
    self:setHRFilename(path..'hr_'..filename..'.png')
end


function SpritesBuilder:resetSprite()
    self.sprites.sprite.filename = nil
end

function SpritesBuilder:resetHRSprite()
    self.sprites.hr_sprite.filename = nil
end

function SpritesBuilder:setWidth(width)
	self:resetSprite()
	if type(width) == "number" then
		self.sprites.sprite.width = width
	end
end

function SpritesBuilder:setHeight(height)
	self:resetSprite()
	if type(height) == "number" then
		self.sprites.sprite.height = height

	end
end

function SpritesBuilder:setScale(scale)
	if type(scale) == "number" then
		self.sprites.sprite.scale = scale
	end
end

function SpritesBuilder:setShift(in_shift)
	self.sprites.sprite.shift = in_shift
end

function SpritesBuilder:setShadowShift(in_shadow_shift)
	self.sprites.shadow.shift = in_shadow_shift
end

function SpritesBuilder:setDrawAsShadow(draw_as_shadow)
	if type(draw_as_shadow) == "bool" then
		self.sprites.sprite.draw_as_shadow = draw_as_shadow
	end
end

function SpritesBuilder:setApplyRuntimeTint(apply_runtime_tint)
	if type(apply_runtime_tint) == "bool" then
		self.sprites.sprite.apply_runtime_tint = apply_runtime_tint
	end
end

function SpritesBuilder:setTint(tint)
	if type(tint) == "Color" then
		self.sprites.sprite.tint = tint
	end
end

function SpritesBuilder:setBlendMode(blend_mode)
	if type(blend_mode) == "string" then
		self.sprites.sprite.blend_mode = blend_mode
	end
end

function SpritesBuilder:setLoadInMinimalMode(load_in_minimal_mode)
	if type(load_in_minimal_mode) == "string" then
		self.sprites.sprite.load_in_minimal_mode = load_in_minimal_mode
	end
end

function SpritesBuilder:setPremulAlpha(premul_alpha)
	if type(premul_alpha) == "bool" then
		self.sprites.sprite.premul_alpha = premul_alpha
	end
end

function SpritesBuilder:setFrameCount(frame_count)
	if type(frame_count) == "number" then
		self.sprites.sprite.frame_count = frame_count
	end
end

function SpritesBuilder:setLineLength(line_length)
	if type(line_length) == "number" then
		self.sprites.sprite.line_length = line_length
	end
end

function SpritesBuilder:setAnimationSpeed(animation_speed)
	if type(animation_speed) == "number" then
		self.sprites.sprite.animation_speed = animation_speed
	end
end

-- HIGH RESOLUTION

function SpritesBuilder:setHRFilename(filename)
	self.sprites.hr_sprite.filename = filename
end

function SpritesBuilder:setHRShadow(filename)
	self.sprites.hr_shadow.filename = filename
end

function SpritesBuilder:setHRPriority(priority)
	if type(priority) == "string" then
		self.sprites.hr_sprite.priority = priority
	end
end

function SpritesBuilder:setHRWidth(width)
	self:resetHRSprite()
	if type(width) == "number" then
		self.sprites.hr_sprite.width = width
	end
end

function SpritesBuilder:setHRHeight(height)
	self:resetHRSprite()
	if type(height) == "number" then
		self.sprites.hr_sprite.height = height
	end
end

function SpritesBuilder:setHRScale(scale)
	if type(scale) == "number" then
		self.sprites.hr_sprite.scale = scale
	end
end

function SpritesBuilder:setHRShift(in_shift)
	self.sprites.hr_sprite.shift = in_shift
end

function SpritesBuilder:setHRShadowShift(in_shadow_shift)
	self.sprites.hr_shadow.shift = in_shadow_shift
end

function SpritesBuilder.setHRDrawAsShadow(draw_as_shadow)
	if type(draw_as_shadow) == "bool" then
		self.sprites.hr_sprite.draw_as_shadow = draw_as_shadow
	end
end

function SpritesBuilder:setHRApplyRuntimeTint(apply_runtime_tint)
	if type(apply_runtime_tint) == "bool" then
		self.sprites.hr_sprite.apply_runtime_tint = apply_runtime_tint
	end
end

function SpritesBuilder:setHRTint(tint)
	if type(tint) == "Color" then
		self.sprites.hr_sprite.tint = tint
	end
end

function SpritesBuilder:setHRBlendMode(blend_mode)
	if type(blend_mode) == "string" then
		self.sprites.hr_sprite.blend_mode = blend_mode
	end
end

function SpritesBuilder:setHRLoadInMinimalMode(load_in_minimal_mode)
	if type(load_in_minimal_mode) == "string" then
		self.sprites.hr_sprite.load_in_minimal_mode = load_in_minimal_mode
	end
end

function SpritesBuilder:setHRPremulAlpha(premul_alpha)
	if type(premul_alpha) == "bool" then
		self.sprites.hr_sprite.premul_alpha = premul_alpha
	end
end

function SpritesBuilder:setHRFrameCount(frame_count)
	if type(frame_count) == "number" then
		self.sprites.hr_sprite.frame_count = frame_count
	end
end

function SpritesBuilder:setHRLineLength(line_length)
	if type(line_length) == "number" then
		self.sprites.hr_sprite.line_length = line_length
	end
end

function SpritesBuilder:setHRAnimationSpeed(animation_speed)
	if type(animation_speed) == "number" then
		self.sprites.hr_sprite.animation_speed = animation_speed
	end
end

-- Initialization and reset

function SpritesBuilder:new(sprites_builder)

	local object = nil
	if sprites_builder then
		object = util.table.deepcopy(sprites_builder)
	else
		object = util.table.deepcopy(self)
	end
	setmetatable(object, util.table.deepcopy(SpritesBuilder.metatable))
	return object
end

-- -- -- Setting methods for builder

-- -- -- Build methods

-- build and return an image with the setted parameters
function SpritesBuilder:buildImage()
    local copy = util.table.deepcopy(self)
	-- create normal sprites
	local sprite = copy.sprites.sprite
	-- add hr version
	if copy.sprites.hr_sprite.filename then
		local hr_sprite = copy.sprites.hr_sprite
		for attribute_name, attribute in pairs(sprite) do
			if attribute_name ~= "hr_version" and not hr_sprite[attribute_name] then
				hr_sprite[attribute_name] = attribute
			end
		end
		sprite.hr_version = hr_sprite
	end
	-- add shadow
	local shadow = nil
	if copy.sprites.shadow.filename then
		local shadow = copy.sprites.shadow
		-- add to the shadow the attribute of base sprite
		for attribute_name, attribute in pairs(sprite) do
			if attribute_name ~= "hr_version" and not shadow[attribute_name] then
				shadow[attribute_name] = attribute
			end
			shadow.draw_as_shadow = true
		end
		if copy.sprites.hr_shadow then
			local hr_shadow = copy.sprites.hr_shadow
			if sprite.hr_version then
				for attribute_name, attribute in pairs(sprite.hr_version) do
					if attribute_name ~= "hr_version" and not hr_shadow[attribute_name] then
						hr_shadow[attribute_name] = attribute
					end
				end
			end
			hr_shadow.draw_as_shadow = true
			shadow.hr_version = hr_shadow
		end
	if shadow ~= nil then
		return		
		{
			layers =
			{
				sprite,
				shadow
			}
		}
	end
		return sprite
	end
end 

-- -- -- Secondary build methods

-- return a picture with 4 images(sprites) like factorio standard
function SpritesBuilder.getPicture4Parts
	(
		in_north,
		in_east,
		in_south,
		in_west
	)
	return
	{
		north = in_north,
		east = in_east,
		south = in_south,
		west = in_west
	}
end


-- return a picture with 16 images(sprites) like factorio standard
function SpritesBuilder.getPicture16Parts
	(
		in_straight_vertical,
		in_straight_horizontal,
		in_corner_right_down,
		in_corner_left_down,
		in_corner_right_up,
		in_corner_left_up,
		in_t_up,
		in_t_right,
		in_t_down,
		in_t_left,
		in_ending_up,
		in_ending_right,
		in_ending_down,
		in_ending_left,
		in_cross,
		in_single	
	)
	return 
	{
		straight_vertical = in_straight_vertical,
		straight_horizontal = in_straight_horizontal,
		corner_right_down = in_corner_right_down,
		corner_left_down = in_corner_left_down,
		corner_right_up = in_corner_right_up,
		corner_left_up = in_corner_left_up,
		t_up = sprite,
		t_right = in_t_right,
		t_down = in_t_down,
		t_left = in_t_left,
		ending_up = in_ending_up,
		ending_right = in_ending_right,
		ending_down = in_ending_down,
		ending_left = in_ending_left,
		cross = in_cross,
		single = in_single		
	}
end

-- return an empty sprite
function SpritesBuilder.getEmptySprite()
	return util.table.deepcopy(SpritesBuilder.sprites.empty_sprite)
end

return SpritesBuilder
