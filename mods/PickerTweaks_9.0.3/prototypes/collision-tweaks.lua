--------------------------------------------------------------------------------
--[[Squeak-Through]] --
--------------------------------------------------------------------------------

--[[
    "name": "Squeak Through",
    "author": "Nommy, Lupin, & Supercheese",
    "homepage": "http://www.factorioforums.com/forum/viewtopic.php?f=91&t=16476",
    "description": "Allows you "description": "Allows you to walk between what used to be obstacles
					such as directly adjacent solar panels, pipes, steam engines, mining drills, and
					chests. No more frustration when walking about your base!"

    Copyright (C) 2016  Nommy, Lupin, & Supercheese

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
local Area = require('__stdlib__/stdlib/area/area')

local gap_requirements = {
    ['solar-panel'] = 0.25,
    ['accumulator'] = 0.25,
    ['generator'] = 0.25,
    ['pipe'] = 0.42,
    ['pipe-to-ground'] = 0.42,
    ['heat-pipe'] = 0.25,
    ['reactor'] = 0.48,
    ['programmable-speaker'] = 0.25,
    ['container'] = 0.25,
    ['logistic-container'] = 0.25,
    ['assembling-machine'] = 0.25,
    ['arithmetic-combinator'] = 0.25,
    ['decider-combinator'] = 0.25,
    ['constant-combinator'] = 0.25,
    ['boiler'] = 0.42,
    ['electric-pole'] = 0.25,
    ['mining-drill'] = 0.25,
    ['pump'] = 0.42,
    ['radar'] = 0.25,
    ['storage-tank'] = 0.25,
    ['turret'] = 0.25,
    ['beacon'] = 0.25,
    ['furnace'] = 0.25,
    ['lab'] = 0.25
}
if not settings.startup['picker-smaller-tree-box'].value then
    gap_requirements.tree = 0.42
end

--(( Smaller Tree Collision ))--
if settings.startup['picker-smaller-tree-box'].value then
    for _, stupid_tree in pairs(data.raw['tree']) do
        if stupid_tree.collision_box then
            stupid_tree.collision_box = {{-0.05, -0.05}, {0.05, 0.05}}
        end
    end
end

-- Returns a coordinate reduced where required to form the specified gap between it and the tile boundary.
local function adjust_coordinate_to_form_gap(coordinate, required_gap)
    -- Treat all coordinates as positive to simplify calculations.
    local negative
    if coordinate < 0 then
        negative = true
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
    if negative then
        coordinate = coordinate * -1
    end

    return coordinate
end

-- Checks all existing prototypes listed in gap_requirements and
-- reduces their collision box to make a gap large enough to walk though if it is not already.
local function adjust_collision_boxes()
    for prototype_type, required_gap in pairs(gap_requirements) do
        for _, prototype in pairs(data.raw[prototype_type]) do
            if not prototype.ignore_squeak_through and prototype.collision_box and Area(prototype.collision_box):size() > 0 then
                for y = 1, 2 do
                    for x = 1, 2 do
                        prototype.collision_box[x][y] = adjust_coordinate_to_form_gap(prototype.collision_box[x][y], required_gap)
                    end
                end
            end
        end
    end
end

if settings.startup['picker-squeak-through'].value then
    adjust_collision_boxes()
end
