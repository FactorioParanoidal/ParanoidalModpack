--- CoPIED FROM THE COPY AND PASTE MODULES 0.15 MOD ---

-- Makes all entities of this given type copy-and-pastable.
local function make_entity_type_pastable(entity_type)
	local entities = data.raw[entity_type]
	if not entities then
		-- No such entity type.
		return
	end
	
	-- Record all entity names of this type.
	local entity_names = {}
	for _, entity in pairs(entities) do
		table.insert(entity_names, entity.name)
	end
	
	-- Make them copy-and-pastable.
	for _, entity in pairs(entities) do
		entity.additional_pastable_entities = entity_names
	end
end


-- Make all furnaces, labs and beacons copy-and-paste-able.
make_entity_type_pastable("furnace")
make_entity_type_pastable("lab")
make_entity_type_pastable("beacon")
--make_entity_type_pastable("mining-drill") already copiable in 0.17