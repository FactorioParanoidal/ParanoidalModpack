--[[
error("---<cut>---\n-- v"..mods.base.."-- \n" ..
	serpent.block(data.raw).."\n" ..
	"---<cut>---\n")
--]]
--[[
local result = {}
for type_name, entities in pairs(data.raw) do
  result[type_name] = {}
  for entity_name, _ in pairs(entities) do
    table.insert(result[type_name], entity_name)
  end
end
error("---<cut>---\n-- v"..mods.base.."-- \n" ..
	serpent.block(result).."\n" ..
	"---<cut>---\n")
--]]