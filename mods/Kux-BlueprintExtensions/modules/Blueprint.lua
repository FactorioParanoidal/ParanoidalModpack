local Blueprint = {}

--- Exports a blueprint to a table
--@param bp [LuaItemStack]
Blueprint.exportToTable = function(bp)
	local exportStack = bp.export_stack()
	exportStack = string.sub(exportStack,2)
	local json = helpers.decode_string(exportStack)
	local t = helpers.json_to_table(json)
	return t
end

--- Imports a table to the blueprint
--@param bp [LuaItemStack]
--@param t  the table to import
Blueprint.importFromTable = function(bp, t)
	local json = helpers.table_to_json(t)
	local exportStack = "0"..helpers.encode_string(json)
	local result = bp.import_stack(exportStack)
	-- 0 if the import succeeded with no errors. -1 if the import succeeded with errors. 1 if the import failed.
	return result
end

Blueprint.offset = function (obj, xoff, yoff)
	--[[
    for _, v in pairs(t) do
        if not v.position then
            return nil
        end

        v.position.x = v.position.x + xoff
        v.position.y = v.position.y + yoff

    end
	return t
	]]
	if type(obj) == "table" and obj.blueprint ~= nil then
		if obj.blueprint.entities then
			for _, v in pairs(obj.blueprint.entities) do
				v.position.x = v.position.x + xoff
				v.position.y = v.position.y + yoff
			end
		end
		if obj.blueprint.tiles then
			for _, v in pairs(obj.blueprint.tiles) do
				v.position.x = v.position.x + xoff
				v.position.y = v.position.y + yoff
			end
		end

		--t.blueprint.version = math.random(0,9999999999999) --TODO revise version generation
		obj.blueprint.version = obj.blueprint.version + 1
	else
		error("Type of parameter not supported. Parameter: 'obj'.")
	end
end

--[[
{
	"blueprint": {
		"snap-to-grid": {
			"x": 64,
			"y": 64
		},
		"absolute-snapping": true,
		"icons": [
			{
				"signal": {
					"type": "item",
					"name": "infinity-chest"
				},
				"index": 1
			}
		],
		"entities": [
			{
				"entity_number": 1,
				"name": "infinity-chest",
				"position": {
					"x": 29.5,
					"y": 28.5
				},
				"infinity_settings": {
					"remove_unfiltered_items": false
				}
			}
		],
		"tiles": [
			{
				"position": {
					"x": 6,
					"y": -7
				},
				"name": "refined-concrete"
			},
			{
				"position": {
					"x": 6,
					"y": -6
				},
				"name": "refined-concrete"
			}
		}
		"item": "blueprint",
		"version": 281474976710656
	}
}
]]

return Blueprint