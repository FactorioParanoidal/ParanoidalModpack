local mpp_util = require("mpp.mpp_util")
local coord_revert_world = mpp_util.revert_world
local builder = {}

---@class GhostSpecification : LuaSurface.create_entity_param.entity_ghost
---@field grid_x number Grid x coordinate
---@field grid_y number Grid x coordinate
---@field radius number? Object radius or default to 0.5 if nil
---@field extent_w number? Object extent from origin, converted from radius if nil
---@field extent_h number? Object extent from origin, converted from radius if nil
---@field thing GridBuilding Enum for the grid
---@field items table<string, number>? Item requests

---@class PowerPoleGhostSpecification : GhostSpecification
---@field no_light boolean
---@field ix number
---@field iy number

--- Builder for a convenience function that automatically translates
--- internal grid state for a surface.create_entity call
---@param state State
---@return fun(ghost: GhostSpecification, check_allowed: boolean?): LuaEntity?
function builder.create_entity_builder(state)
	local c = state.coords
	local grid = state.grid
	local DIR = state.direction_choice
	local surface = state.surface
	local gx, gy, tw, th = c.gx, c.gy, c.tw, c.th
	local direction_conv = mpp_util.bp_direction[state.direction_choice]
	local collected_ghosts = state._collected_ghosts
	local is_space = state.is_space

	return function(ghost, check_allowed)
		ghost.raise_built = true
		ghost.player = state.player
		ghost.force = state.player.force
		ghost.inner_name=ghost.name
		ghost.name="entity-ghost"
		ghost.position=coord_revert_world(gx, gy, DIR, ghost.grid_x, ghost.grid_y, tw, th)
		ghost.direction=direction_conv[ghost.direction or defines.direction.north]

		--local can_place = surface.can_place_entity(ghost)
		if check_allowed and not surface.can_place_entity{
			name = ghost.inner_name,
			-- name = "entity-ghost",
			-- inner_name = ghost.inner_name,
			force = state.player.force,
			position = ghost.position,
			direction = ghost.direction,
			build_check_type = defines.build_check_type.blueprint_ghost,
			forced = true,
		} then
			return
		end

		local result = surface.create_entity(ghost)
		if result then
			grid:build_specification(ghost)
			collected_ghosts[#collected_ghosts+1] = result
		end
		return result
	end
end

return builder
