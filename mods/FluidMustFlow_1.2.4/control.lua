-- -- -- Libraries
local tooltip      = require("__FluidMustFlow__/linver-lib/tooltip")
local entity_utils = require("__FluidMustFlow__/linver-lib/entity-utils")

-- Globals
global.auto_join      = false
global.duct_invariant = false
-- Names of entity added by the mod
local fmf_entities_prefix               = "duct"
local fmf_duct_part_names               = 
{
	["duct-small"] = true, 
	["duct"] = true, 
	["duct-long"] = true, 
	["non-return-duct"] = true, 
	["duct-t-junction"] = true, 
	["duct-curve"] = true, 
	["duct-cross"] = true, 
	["duct-underground"] = true
}
local fmf_intermediate_point_part_names = 
{
	["non-return-duct"] = true
}
local fmf_end_point_part_names          = 
{
	["duct-end-point-intake-south"] = true, 
	["duct-end-point-intake-west"] = true, 
	["duct-end-point-intake-north"] = true, 
	["duct-end-point-intake-east"] = true, 
	["duct-end-point-outtake-south"] = true, 
	["duct-end-point-outtake-west"] = true, 
	["duct-end-point-outtake-north"] = true, 
	["duct-end-point-outtake-east"] = true
}
local fmf_part_names = 
{
	["duct-small"] = true, 
	["duct"] = true, 
	["duct-long"] = true, 
	["non-return-duct"] = true, 
	["duct-t-junction"] = true, 
	["duct-curve"] = true, 
	["duct-cross"] = true, 
	["duct-underground"] = true,
	-- Intermediate points
	["non-return-duct"] = true,
	-- End points
	["duct-end-point-intake-south"] = true, 
	["duct-end-point-intake-west"] = true, 
	["duct-end-point-intake-north"] = true, 
	["duct-end-point-intake-east"] = true, 
	["duct-end-point-outtake-south"] = true, 
	["duct-end-point-outtake-west"] = true, 
	["duct-end-point-outtake-north"] = true, 
	["duct-end-point-outtake-east"] = true
}
local fmf_joinable = 
({
	{entity = "duct-small", predecessor = nil,          successor = "duct"},
	{entity = "duct",       predecessor = "duct-small", successor = "duct-long"},
	{entity = "duct-long",  predecessor = "duct",       successor = nil}
})
-- Possible fluid box connetions for each ducts part
local possible_connections=
{
	["duct-small"] = {2, 0}, 
	["duct"] = {2, 0}, 
	["duct-long"] = {2, 0}, 
	["non-return-duct"] = {2, 0}, 
	["duct-t-junction"] = {3, 0}, 
	["duct-curve"] = {2, 0}, 
	["duct-cross"] = {4, 0}, 
	["duct-underground"] = {2, 0},
	-- Intermediate points
	["non-return-duct"] = {2, 0},
	-- End points
	["duct-end-point-intake-south"] = {1, 6}, 
	["duct-end-point-intake-west"] = {1, 6}, 
	["duct-end-point-intake-north"] = {1, 6}, 
	["duct-end-point-intake-east"] = {1, 6}, 
	["duct-end-point-outtake-south"] = {1, 6}, 
	["duct-end-point-outtake-west"] = {1, 6}, 
	["duct-end-point-outtake-north"] = {1, 6}, 
	["duct-end-point-outtake-east"] = {1, 6}
}

-- -- -- Duct connections control

-- if an name of entity is one of entities added by this mod
-- in particular, if is a duct part
function isaPartofDucts(entity_name)
	if fmf_duct_part_names[entity_name] then
		return true
	end
	return false
end

-- if an name of entity is one of entities added by this mod
-- in particular, if is a connection point
function isaIntermediatePoint(entity_name)	
	if fmf_intermediate_point_part_names[entity_name] then
		return true
	end
	return false
end

-- if an name of entity is one of entities added by this mod
-- in particular, if is a end point
function isaEndPoint(entity_name)	
	if fmf_end_point_part_names[entity_name] then
		return true	
	end
	return false
end

function isaEntityOfThisMod(entity_name)
	if fmf_part_names[entity_name] then
		return true	
	end
	return false
end

local function ductsConnectionsControlCallback(entity)	
	local result = false
	if entity_utils.isAnEntity(entity) and entity_utils.entityHasFluidbox(entity) then
		local result = false
		
		if isaEntityOfThisMod(entity.name) then
			result = checkFluidboxConnections(entity)
		end
	
		if not result then		
			local connected_neighbours = entity_utils.getConnectedNeighbours(entity)
			local i, connected_neighbour = next(connected_neighbours, nil)
		
			while connected_neighbour do
				if isaEntityOfThisMod(connected_neighbour.entity.name) then
					result = checkFluidboxConnections(connected_neighbour.entity)
					if result then break end
				end
			
				--pull next
				i, connected_neighbour = next(connected_neighbours, i)		
			end	
		end
	end
	return result
end

-- enforce the player to connected duct part only with other duct part
function checkFluidboxConnections(entity)			
	-- connected fluidboxes
	local connected_neighbours = entity_utils.getConnectedNeighbours(entity)
	if #connected_neighbours > 0 then
		-- constants
		local max_connections = possible_connections[entity.name]			
		-- counters
		local visited_entities = {}	
		local ducts         = 0
		local non_ducts     = 0
		local connected_to_an_intake  = false
		local connected_to_an_outtake = false
		-- saved redundat checks
		local enable_endpoint_check = isaEndPoint(entity.name)		
		local isa_intake = string.find(entity.name, "intake") ~= nil
		local isaNeighbourIntake = nil
			
		local i, connected_neighbour = next(connected_neighbours, nil)
		while connected_neighbour do
			if visited_entities[connected_neighbour.entity.unit_number] then
				goto continue				
			end
			isaNeighbourIntake = string.find(connected_neighbour.entity.name, "intake")
			if isaEntityOfThisMod(connected_neighbour.entity.name) then
				ducts = ducts + 1
			else
				non_ducts = non_ducts + 1
			end			
			if enable_endpoint_check then
				if ( isa_intake and string.find(connected_neighbour.entity.name, "outtake") ) or
				   ( not isa_intake and string.find(connected_neighbour.entity.name, "intake") )
				then
					ducts = ducts - 1
				end
				if string.find(connected_neighbour.entity.name, "intake") then
					connected_to_an_intake = true
				elseif string.find(connected_neighbour.entity.name, "outtake") then
					connected_to_an_outtake = true
				end
			end
			--pull next
			visited_entities[connected_neighbour.entity.unit_number] = true
			::continue::
			i, connected_neighbour = next(connected_neighbours, i)		
		end
			
		-- If is violate the connection rules
		if ducts > max_connections[1] or non_ducts > max_connections[2] then
			tooltip.showOnSurfaceGreyText
			(
				entity.surface, 
				entity.position, 
				{
					"other.duct-connection-error", 
					max_connections[1], 
					max_connections[2]					
				},
				{r=1.0, g=0.1, b=0.1}
			)		
			for _, product in pairs(entity.prototype.mineable_properties.products) do
				entity.last_user.insert{name=product.name or product[1], count=product.amount or product[2]}
			end
			entity.destroy()
			return true
		elseif enable_endpoint_check and ( (isa_intake and connected_to_an_intake) or (not isa_intake and connected_to_an_outtake) ) then
			tooltip.showOnSurfaceGreyText
			(
				entity.surface, 
				entity.position, 
				{ "other.duct-endpoint-connection-error" },
				{r=1.0, g=0.1, b=0.1}
			)		
			for _, product in pairs(entity.prototype.mineable_properties.products) do
				entity.last_user.insert{name=product.name or product[1], count=product.amount or product[2]}
			end
			entity.destroy()
			return true
		end
	end

	return false
end

-- -- -- Ducts join

function lookingforDuctJoin(entity)
	local join_pattern = nil	
	
	for _, pattern in pairs(fmf_joinable) do
		if pattern.entity == entity.name then
			join_pattern = pattern
			break
		end
	end
	
	-- if there isn't a pattern or successor isn't joinable
	if join_pattern and join_pattern.successor then
		-- check for neighbour to join
		local neighbour_ducts = entity_utils.getConnectedNeighboursOfSamePrototype(entity)
		local _, joinable_candidate = next(neighbour_ducts)	
			
		if joinable_candidate then
			--computing correct position
			local in_direction = entity.direction
			local at_position = entity.position		
			local perimenter = entity_utils.getEntityOrientedSize(joinable_candidate.entity)
					
			if in_direction == 2 or in_direction == 6 then
				if joinable_candidate.horizontal_direction == "west" then
					at_position.x = at_position.x - 1  
				elseif perimenter.width > 1 then
					at_position.x = at_position.x + 1
				end
			end
			if in_direction == 0 or in_direction == 4 then
				if joinable_candidate.vertical_direction == "south" then
					at_position.y = at_position.y - 1
				elseif perimenter.height > 1 then
					at_position.y = at_position.y + 1
				end		
			end

			--copy other old entity stats
			local on_surface   = entity.surface
			local of_force     = entity.force
			local with_damage  = joinable_candidate.entity.prototype.max_health - joinable_candidate.entity.health
			local player_owner = entity.last_user
			local entity_contained_fluid_name, entity_contained_fluid_quantity = next(entity.get_fluid_contents())
			local joinable_candidate_contained_fluid_name, joinable_candidate_contained_fluid_quantity = next(joinable_candidate.entity.get_fluid_contents())
			
			joinable_candidate.entity.destroy()
			entity.destroy()
			
			entity = on_surface.create_entity
			{
				name        = join_pattern.successor, 
				position    = at_position, 
				direction   = in_direction, 
				force       = of_force,
				player      = player_owner,
				raise_built = true
			}
			
			-- Reinsert in the new entity the fluid of the destroyed entity
			if entity_contained_fluid_quantity then
				entity.insert_fluid({name=entity_contained_fluid_name, amount=entity_contained_fluid_quantity})
			end
			if joinable_candidate_contained_fluid_quantity then
				entity.insert_fluid({name=joinable_candidate_contained_fluid_name, amount=joinable_candidate_contained_fluid_quantity})
			end
			-- Set in the new entity the health of the destroyed entity
			if with_damage > 0 then
				entity.damage(with_damage, game.forces.neutral)	--user can use this like free repair otherwise
			end
			
			lookingforDuctJoin(entity) -- recursive check other join
		end
	end
end

-- -- Ducts join control on blueprints
function lookingforReverseJoinOfGhostEntity(entity)	
	--if is a joined piece
	local join_pattern = nil		
	for _, pattern in pairs(fmf_joinable) do
		if pattern.successor == entity.ghost_name then
			join_pattern = pattern
			break
		end
	end
		
	if join_pattern then	
		-- get perimenters
		local entity_perimenter = entity_utils.getPrototypeSize(game.entity_prototypes[entity.ghost_name]) -- entity_utils.getEntityOrientedSize(entity)
		local childs_perimenter = entity_utils.getPrototypeSize(game.entity_prototypes[join_pattern.entity])
		
		--copy other old entity stats and destroy it
		local on_surface   = entity.surface
		local of_force     = entity.force
		local player_owner = entity.last_user
		local at_position  = entity.position
		local in_direction = entity.direction			
		entity.destroy()
		
		--iter params
		local child_entity   = nil
		local residual_space = nil
		local de_increment   = nil
		local on_x           = true
		
		if in_direction == 2 or in_direction == 4 then -- horizontal reverse join
			residual_space  = entity_perimenter.height
			de_increment    = childs_perimenter.height
			at_position.x   = at_position.x + entity_utils.downDifferenceToSizeCenter(entity_perimenter)
		else -- vertical reverse join
			residual_space  = entity_perimenter.height
			de_increment    = childs_perimenter.height
			at_position.y   = at_position.y + entity_utils.downDifferenceToSizeCenter(entity_perimenter)
			on_x            = false
		end			
		
		while residual_space > 0 do
			child_entity   = on_surface.create_entity
			{
				name       = "entity-ghost",
				ghost_name = join_pattern.entity, 
				position   = at_position, 
				direction  = in_direction, 
				force      = of_force,
				player     = player_owner,
				raise_built = true
			}				
		
			lookingforReverseJoinOfGhostEntity(child_entity)
			
			if on_x then
				at_position.x = at_position.x - de_increment
			else
				at_position.y = at_position.y - de_increment
			end
			residual_space = residual_space - de_increment
		end
	end	
end

-- Scheduling of ducts join procedures
function ductsJoin(entity)		
	if entity_utils.isAnEntity(entity) then
		--if entity is a ghost (ignore all entities that isn't duct)
		if entity.name == "entity-ghost" and isaPartofDucts(entity.ghost_name) then 
			lookingforReverseJoinOfGhostEntity(entity)
		elseif isaPartofDucts(entity.name) then
			lookingforDuctJoin(entity)
		end
	end
end

-- -- -- Endpoint rotating entities

-- utils
function getRightPrefix(end_point_name)
	if end_point_name:find("intake") then
		return "duct-end-point-intake"
	else
		return "duct-end-point-outtake"
	end
end

-- -- Callback for entities already placed that are rotating
function endpointOnRotating(event)
	local entity = event.entity or nil
	if entity_utils.isAnEntity(entity) then
		if isaEndPoint(entity.name) then		
			local endpoint_prefix = getRightPrefix(entity.name)	
			local rotated_entity  = nil
			local contained_fluid = entity.fluidbox[1] or false
			local with_damage     = entity.prototype.max_health - entity.health
			local network         = entity.circuit_connection_definitions
			local energy          = entity.energy or false
			local pos             = entity.position
			local force           = entity.force
			local lastuser        = event.player_index
			local direction       = entity.direction
			local surface         = entity.surface
				
			if entity then
				entity.destroy()
			end

			if direction == defines.direction.west then 
				rotated_entity  = surface.create_entity
				{
					name        = endpoint_prefix .. "-west",
					position    = pos,
					direction   = defines.direction.west,
					force       = force,
					player      = lastuser,
					create_build_effect_smoke = false,
					raise_built = true
				}
			elseif direction == defines.direction.north then
				rotated_entity  = surface.create_entity
				{
					name        = endpoint_prefix .. "-north",
					position    = pos,
					direction   = defines.direction.north,
					force       = force,
					player      = lastuser,
					create_build_effect_smoke = false,
					raise_built = true
				}
			elseif direction == defines.direction.east then
				rotated_entity  = surface.create_entity
				{
					name        = endpoint_prefix .. "-east",
					position    = pos,
					direction   = defines.direction.east,
					force       = force,
					player      = lastuser,
					create_build_effect_smoke = false,
					raise_built = true
				}
			else
				rotated_entity  = surface.create_entity
				{
					name        = endpoint_prefix .. "-south",
					position    = pos,
					direction   = defines.direction.south,
					force       = force,
					player      = lastuser,
					create_build_effect_smoke = false,
					raise_built = true
				}
			end	
			-- Reinsert in the new entity the fluid of the destroyed entity
			if contained_fluid then
				rotated_entity.insert_fluid(contained_fluid)
			end
			-- Reinsert in the new entity the energy of the destroyed entity
			if energy then
				rotated_entity.energy = energy
			end
			-- Set in the new entity the health of the destroyed entity
			if with_damage > 0 then
				rotated_entity.damage(with_damage, game.forces.neutral)
			end
			-- Set old circuit network (if connected)
			for c, tbl in pairs(network) do 
				rotated_entity.connect_neighbour
				{
					target_entity     = tbl.target_entity,
					wire              = tbl.wire,
					source_circuit_id = tbl.source_circuit_id,
					target_circuit_id = tbl.target_circuit_id
				} 
			end
			
			return true		
		end
	end
	return false
end

-- -- Callback for entities before be placed
function endpointOnBuildRightFacing(entity)	
	if entity_utils.isAnEntity(entity) then
		if isaEndPoint(entity.name) then
			local endpoint_prefix = getRightPrefix(entity.name)	
			local rotated_entity  = nil
			local with_damage     = entity.prototype.max_health - entity.health
			local pos             = entity.position
			local force           = entity.force
			local lastuser        = entity.last_user
			local direction       = entity.direction
			local surface         = entity.surface

			if entity then
				entity.destroy()
			end

			if direction == defines.direction.south then 
				rotated_entity  = surface.create_entity
				{
					name        = endpoint_prefix .. "-south",
					position    = pos,
					direction   = defines.direction.south,
					force       = force,
					player      = lastuser,
					raise_built = true
				}
			elseif direction == defines.direction.west then
				rotated_entity  = surface.create_entity
				{
					name        = endpoint_prefix .. "-west",
					position    = pos,
					direction   = defines.direction.west,
					force       = force,
					player      = lastuser,
					raise_built = true
				}
			elseif direction == defines.direction.north then
				rotated_entity  = surface.create_entity
				{
					name        = endpoint_prefix .. "-north",
					position    = pos,
					direction   = defines.direction.north,
					force       = force,
					player      = lastuser,
					raise_built = true
				}
			else
				rotated_entity  = surface.create_entity
				{
					name        = endpoint_prefix .. "-east",
					position    = pos,
					direction   = defines.direction.east,
					force       = force,
					player      = lastuser,
					raise_built = true
				}
			end
			-- Set in the new entity the health of the entity in the inventory
			if with_damage > 0 then
				rotated_entity.damage(with_damage, game.forces.neutral)
			end
			
			return true
		end
	end
	return false
end

-- -- -- Adding controls events

function updateSettingVariables()
	global.auto_join      = settings.startup["fmf-enable-duct-invariant"].value
	global.duct_invariant = settings.startup["fmf-enable-duct-auto-join"].value
end

local build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}

function ductControlEvents(event)
	local entity = event.created_entity	
	local removed = false
	
	if global.auto_join then
		removed = ductsConnectionsControlCallback(entity)
	end
	if not removed and entity_utils.isAnEntity(entity) then	
		rotated_an_endpoint = endpointOnBuildRightFacing(entity)
		if global.duct_invariant and not rotated_an_endpoint then
			ductsJoin(entity)
		end
	end
end

-- Add duct join and duct ghost control
script.on_init(updateSettingVariables)
script.on_configuration_changed(updateSettingVariables)
script.on_event(build_events, ductControlEvents)
script.on_event(defines.events.on_player_rotated_entity, endpointOnRotating)
