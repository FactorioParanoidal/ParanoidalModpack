local metadata = require("lib.core.metadata")

local lib = {}

local mirroring_possible_types = metadata.mirroring_possible_types

---Determine if a prototype-name uses mirroring bit.
---@param prototype_name string
---@return boolean
function lib.prototype_name_uses_mirroring(prototype_name)
	local prototype = prototypes.entity[prototype_name]
	if not prototype then return false end
	local prototype_type = prototype.type
	if not mirroring_possible_types[prototype_type] then return false end
	if prototype.use_mirroring then
		return true
	else
		return false
	end
end

return lib
