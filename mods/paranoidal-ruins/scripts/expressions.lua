-- Number and entity expressions of ruin definitions (format of "Abandoned Ruins", see the
-- "variables" and {type = ...} values in ruins/*.lua and ruins/base/*).
local M = {}

local function common(t, vars)
  if t.type == "variable" then
    return vars[t.name]
  elseif t.type == "random-variable" then
    return vars[t.variables[math.random(#t.variables)]]
  elseif t.type == "random-from-list" then
    return t.list[math.random(#t.list)]
  end
  error("Unrecognized expression type: " .. tostring(t.type))
end

---@param t table|number
---@param vars table?
---@return number
function M.number(t, vars)
  if type(t) == "number" then return t end
  if type(t) ~= "table" then error("Number expression expected, got " .. type(t)) end
  local value
  if t.type == "random" then
    value = math.random(t.min, t.max)
  else
    value = common(t, vars or {})
  end
  if type(value) ~= "number" then error("Number expression did not return a number: " .. serpent.line(t)) end
  return value
end

---@param t table|string
---@param vars table?
---@return string
function M.entity(t, vars)
  if type(t) == "string" then return t end
  if type(t) ~= "table" then error("Entity expression expected, got " .. type(t)) end
  local value
  if t.type == "random-of-entity-type" then
    local names = {}
    for name in pairs(prototypes.get_entity_filtered({ { filter = "type", type = t.entity_type } })) do
      names[#names + 1] = name
    end
    value = names[math.random(#names)]
  else
    value = common(t, vars or {})
  end
  if type(value) ~= "string" then error("Entity expression did not return a string: " .. serpent.line(t)) end
  return value
end

---@param variables table[]
---@return table<string, number|string>
function M.variables(variables)
  local parsed = {}
  for _, var in pairs(variables) do
    if var.type == "entity-expression" then
      parsed[var.name] = M.entity(var.value)
    elseif var.type == "number-expression" then
      parsed[var.name] = M.number(var.value)
    else
      error("Unrecognized variable type: " .. tostring(var.type))
    end
  end
  return parsed
end

return M
