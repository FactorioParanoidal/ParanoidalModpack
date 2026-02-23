local constants = require("constants")

local parsing = {}

-- extend table 1 with table 2
-- no safety checks, very naive
---@param table1 table table to extend
---@param table2 table
local function extend(table1, table2)
  if debug_log then log(string.format("[extend]: table1()=%d,table2()=%d - CALLED!", table_size(table1), table_size(table2))) end
  for key, value in pairs(table2) do
    if debug_log then log(string.format("[extend]: key='%s',value[]='%s'", key, type(value))) end
    table1[key] = value
  end
  if debug_log then log(string.format("[extend]: table1()=%d,table2()=%d - EXIT!", table_size(table1), table_size(table2))) end
end

local common_expressions =
{
  ---@param t NumberExpression|EntityExpression
  ---@param vars VariableValues
  ---@return number|string
  ["variable"] = function(t, vars)
    if debug_log then log(string.format("[variable]: t[]='%s',vars[]='%s' - CALLED!", type(t), type(vars))) end
    if type(t.name) ~= "string" then
      error(string.format("t.name[]='%s' is not expected type 'string'", type(t.name)))
    elseif type(vars) ~= "table" then
       error(string.format("vars[]='%s' is not expected type 'table'", type(vars)))
    end

    if debug_log then log(string.format("[variable]: Returning vars[%s][]='%s' - EXIT!", t.name, type(vars[t.name]))) end
    return vars[t.name]
  end,

  ---@param t NumberExpression|EntityExpression
  ---@param vars VariableValues
  ---@return number|string
  ["random-variable"] = function(t, vars)
    if type(t.variables) ~= "table" then
       error(string.format("t.variables[]='%s' is not expected type 'table'", type(t.variables)))
    elseif type(vars) ~= "table" then
       error(string.format("vars[]='%s' is not expected type 'table'", type(vars)))
    end

    return vars[t.variables[math.random(table_size(t.variables))]]
  end,

  ---@param t NumberExpression|EntityExpression
  ---@return number|string
  ["random-from-list"] = function(t)
    if type(t.list) ~= "table" then
      error("Expression random-from-list: list expected a table, got " .. type(t.list))
    end
    return t.list[math.random(table_size(t.list))]
  end
}

local number_expressions =
{
  ---@param t NumberExpression
  ---@return number
  ["random"] = function(t)
    if debug_log then log(string.format("[random]: t.min=%d,t.max=%d - CALLED!", t.min, t.max)) end
    if t.min < 0 then
      error(string.format("t.min=%d Cannot be below zero", t.min))
    elseif t.max < t.min then
      error(string.format("t.max=%d is smaller than t.min=%d", t.max, t.min))
    end
    return math.random(t.min, t.max)
  end
}
extend(number_expressions, common_expressions)

local entity_expressions =
{
  ---@param t EntityExpression
  ---@return string
  ["random-of-entity-type"] = function(t)
    if debug_log then log(string.format("[random-of-entity-type]: t.entity_type='%s' - CALLED!", t.entity_type)) end
    if type(t.entity_type) ~= "string" then
      error("Expression random-of-entity-type: entity_type expected a string, got " .. type(t.entity_type))
    end
    ---@type string[]
    local entities = {}
    local count = 0

    for entity in pairs(prototypes.get_entity_filtered({{filter = "type", type = t.entity_type}})) do
      if debug_log then log(string.format("[random-of-entity-type]: entity='%s'", entity)) end
      count = count + 1
      entities[count] = entity
    end
    if debug_log then log(string.format("[random-of-entity-type]: count=%d", count)) end
    return entities[math.random(count)]
  end
}
extend(entity_expressions, common_expressions)

---@param t NumberExpression|number
---@param vars VariableValues
---@return number
parsing.number = function(t, vars)
  if debug_log then log(string.format("[number]: t[]='%s',vars[]='%s' - CALLED!", type(t), type(vars))) end
  if type(t) == "table" then
    if debug_log then log(string.format("[number]: Parsing t.type='%s',t.name='%s' ...", t.type, t.name)) end
    if number_expressions[t.type] == "nil" then
      error("Unrecognized number-expression type: " .. t.type)
    end

    local ret = number_expressions[t.type](t, vars)

    if debug_log then log(string.format("[number]: ret[]='%s'", type(ret))) end
    if type(ret) ~= "number" then
      error("String expression did not return a number. Expression was " .. serpent.line(t))
    end

    if debug_log then log(string.format("[number]: ret=%.2f - EXIT!", ret)) end
    return ret
  elseif type(t) == "number" then
    if debug_log then log(string.format("[number]: t=%.2f - EXIT!", t)) end
    return t
  end
  error(string.format("t[]='%s' is not expected type 'number' or 'table'", type(t)))
end

---@param t EntityExpression|string
---@param vars VariableValues
---@return string
parsing.entity = function(t, vars)
  if debug_log then log(string.format("[entity]: t[]='%s',vars[]='%s' - CALLED!", type(t), type(vars))) end
  if type(t) == "table" then
    if debug_log then log(string.format("[entity]: Parsing t.type='%s',t.name='%s' ...", t.type, t.name)) end
    if entity_expressions[t.type] == "nil" then
      error("Unrecognized entity-expression type: " .. t.type)
    end

    local ret = entity_expressions[t.type](t, vars)

    if debug_log then log(string.format("[entity]: ret[]='%s'", type(ret))) end
    if type(ret) ~= "string" then
      error("Entity expression did not return a string. Expression was " .. serpent.line(t))
    end

    if debug_log then log(string.format("[entity]: ret='%s' - EXIT!", ret)) end
    return ret
  elseif type(t) == "string" then
    if debug_log then log(string.format("[entity]: t='%s' - EXIT!", t)) end
    return t
  end
  error(string.format("t[]='%s' is not expected type 'string' or 'table'", type(t)))
end

return parsing
