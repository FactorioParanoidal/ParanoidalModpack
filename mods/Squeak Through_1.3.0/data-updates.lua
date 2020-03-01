require "config"

-- Prototype names and types to not alter.
local excluded_prototype_names = {}
local excluded_prototype_types = {}


-- Helper functions to check if a prototype name or type is excluded.
local function prototype_name_excluded(name)
	return excluded_prototype_names[name]
end
local function prototype_type_excluded(type)
	return excluded_prototype_types[type]
end


-- Returns true when an exclusion should be applied or false otherwise.
local function exclusion_applies(exclusion)

	-- Exclusions always apply if no apply_when_object_exists is specified.
	if not exclusion.apply_when_object_exists then
		return true
	else
		-- Exclusions apply when the apply_when_object_exists object actually exists.
		if data.raw[exclusion.apply_when_object_exists.type][exclusion.apply_when_object_exists.name] then
			return true
		end
	end

	-- The apply_when_object_exists object didn't exist (the mod which the exclusion was for is not active).
	return false
end


-- Update the exclusion arrays by parsing an exclusion (from config.lua).
local function apply_exclusion(exclusion)

	if exclusion.excluded_prototype_names then
		for _,n in pairs(exclusion.excluded_prototype_names) do
			excluded_prototype_names[n] = true
		end
	end

	if exclusion.excluded_prototype_types then
		for _,t in pairs(exclusion.excluded_prototype_types) do
			excluded_prototype_types[t] = true
		end
	end
end


-- Parse the exclusions defined in config.lua only applying those which are applicable.
local function apply_exclusions()
	for _,e in pairs(exclusions) do
		if exclusion_applies(e) then
			apply_exclusion(e)
		end
	end
end


-- Returns a coordinate reduced where required to form the specified gap between it and the tile boundary.
local function adjust_coordinate_to_form_gap(coordinate, required_gap)

	-- Treat all coordinates as positive to simplify calculations.
	local is_negative_coordinate = (coordinate < 0)
	if is_negative_coordinate then
		coordinate = coordinate * -1
	end

	local tile_width = 0.5

	-- Calculate the existing gap (how much space there is to the next tile edge or 0 when the coordinate lies on a tile edge).
	local distance_past_last_tile_edge = coordinate % tile_width -- This is how far the collision box extends over any tile edge, and should be 0 for a perfect fit.
	local existing_gap = 0
	if distance_past_last_tile_edge > 0 then
		existing_gap = (tile_width - distance_past_last_tile_edge)
	end

	-- Reduce the coordinate to make the gap large enough if it is not already.
	if existing_gap < required_gap then
		coordinate = coordinate + existing_gap - required_gap
		if coordinate < 0 then
			coordinate = 0
		end
	end

	-- Make the coordinate negative again if it was originally negative.
	if is_negative_coordinate then
		coordinate = coordinate * -1
	end

	return coordinate
end


-- Checks all existing prototypes listed in prototype_type_gap_requirements and reduces their collision box to make a gap large enough to walk though if it is not already.
local function adjust_collision_boxes()
	for prototype_type, required_gap in pairs(prototype_type_gap_requirements) do

		-- Don't shrink prototypes of this type if they've been excluded.
		if not prototype_type_excluded(prototype_type) then
			for prototype_name, prototype in pairs(data.raw[prototype_type]) do

				-- If the prototype is not excluded and has a collision box then resize it.
				if (not prototype_name_excluded(prototype_name)) and prototype["collision_box"] then

					if prototype.collision_box.lefttop then
							prototype.collision_box.lefttop[1] = adjust_coordinate_to_form_gap(prototype.collision_box.lefttop[1], required_gap)
							prototype.collision_box.rightbottom[1] = adjust_coordinate_to_form_gap(prototype.collision_box.rightbottom[1], required_gap)
							prototype.collision_box.lefttop[2] = adjust_coordinate_to_form_gap(prototype.collision_box.lefttop[2], required_gap)
							prototype.collision_box.rightbottom[2] = adjust_coordinate_to_form_gap(prototype.collision_box.rightbottom[2], required_gap)
					else
						for y=1,2 do
							for x=1,2 do
								prototype.collision_box[x][y] = adjust_coordinate_to_form_gap(prototype.collision_box[x][y], required_gap)
							end
						end
					end

				end
			end
		end
	end
end

-- Exclude prototypes from alteration for mods that have compatibility issues with modified collision boxes.
apply_exclusions()

-- Make the adjustments.
adjust_collision_boxes()
