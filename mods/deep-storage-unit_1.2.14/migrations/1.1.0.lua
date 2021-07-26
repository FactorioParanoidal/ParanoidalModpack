for _, unit_data in pairs(global.units or {}) do
	if not unit_data.combinator then
		local entity = unit_data.entity
		local position = entity.position
		
		local combinator = entity.surface.create_entity{
			name = 'memory-unit-combinator',
			position = {position.x + 2.25, position.y + 1.75},
			force = entity.force
		}
		combinator.operable = false
		combinator.destructible = false
		
		unit_data.combinator = combinator
		unit_data.powersource.destructible = false
	end
end