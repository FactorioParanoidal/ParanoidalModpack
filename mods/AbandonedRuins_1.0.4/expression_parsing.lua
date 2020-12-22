local util = require("utilities")

local parsing = {}

-- extend table 1 with table 2
-- no safety checks, very naive
local function extend(table1, table2)
  for k,v in pairs(table2) do
    table1[k] = v
  end
end

local common_expressions =
{
  ["variable"] = function(t, vars) return vars[t.name] end,
  ["random-variable"] = function(t, vars) return vars[t.variables[math.random(#t.variables)]] end
}

local number_expressions =
{
  ["random"] = function(t) return math.random(t.min, t.max) end
}
extend(number_expressions, common_expressions)

local entity_expressions =
{
  ["random-of-entity-type"] = function(t)
    local entities = {}
    for k in pairs(game.get_filtered_entity_prototypes({{filter = "type", type = t.entity_type}})) do
      entities[#entities+1] = k
    end
    return entities[math.random(#entities)]
  end
}
extend(entity_expressions, common_expressions)


parsing.number = function(t, vars)
  if type(t) == "table" then
    return number_expressions[t.type](t, vars) or error("Unrecognized number-expression type: " .. t.type)
  elseif type(t) == "number" then
    return t
  end
  error("received something that is not a number or table as number-expression")
end

parsing.entity = function(t, vars)
  if type(t) == "table" then
    return entity_expressions[t.type](t, vars) or error("Unrecognized entity-expression type: " .. t.type)
  elseif type(t) == "string" then
    return t
  end
  error("received something that is not a number or table as entity-expression")
end

return parsing