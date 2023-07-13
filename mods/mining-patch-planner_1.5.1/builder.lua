local mpp_util = require("mpp_util")
local coord_revert = mpp_util.revert
local builder = {}

---@class GhostSpecification : LuaSurface.create_entity_param
---@field grid_x number Grid x coordinate
---@field grid_y number Grid x coordinate
---@field padding_pre number
---@field padding_post number
---@field thing string Enum for the grid

---@class PowerPoleGhostSpecification : GhostSpecification
---@field no_light boolean
---@field ix number Pole x index 
---@field iy number Poly y index

--- Builder for a convenience function that automatically translates
--- internal grid state for a surface.create_entity call
---@param state State
builder.create_entity_builder = function(state)
	local c = state.coords
	local grid = state.grid
	local DIR = state.direction_choice
	local surface = state.surface
	local gx, gy, tw, th = c.gx, c.gy, c.tw, c.th
	local direction_conv = mpp_util.bp_direction[state.direction_choice]
	local collected_ghosts = state._collected_ghosts

	---@param ghost GhostSpecification
	return function(ghost)
		ghost.raise_built = true
		ghost.player = state.player
		ghost.force = state.player.force
		ghost.inner_name=ghost.name
		ghost.name="entity-ghost"
		ghost.position=coord_revert(gx, gy, DIR, ghost.grid_x, ghost.grid_y, tw, th)
		ghost.direction=direction_conv[ghost.direction or defines.direction.north]
		local result = surface.create_entity(ghost)
		if result then
			grid:build_specification(ghost)
			collected_ghosts[#collected_ghosts+1] = result
		end
		return result
	end
end

--- Builder for a convenience function that automatically translates
--- internal grid state for a surface.create_entity call
---@param state State
builder.create_manual_entity_builder = function(state)
	local c = state.coords
	local DIR = state.direction_choice
	local surface = state.surface
	local gx, gy, tw, th = c.gx, c.gy, c.tw, c.th
	local direction_conv = mpp_util.bp_direction[state.direction_choice]

	---@param ghost GhostSpecification
	return function(ghost)
		ghost.raise_built = true
		ghost.player = state.player
		ghost.force = state.player.force
		ghost.inner_name=ghost.name
		ghost.name="entity-ghost"
		ghost.position=coord_revert(gx, gy, DIR, ghost.grid_x, ghost.grid_y, tw, th)
		ghost.direction=direction_conv[ghost.direction or defines.direction.north]
		return surface.create_entity(ghost)
	end
end


return builder
