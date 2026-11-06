local log = require("scripts.logger").expression
local ssub = string.sub

local expr = {}

local expr_vars = {
  k = 1000,
  K = 1000,
  m = 1000000,
  M = 1000000,
  g = 1000000000,
  G = 1000000000,
  b = 1000000000,
  B = 1000000000
}

--- @param input string?
--- @param fallback number?
--- @return number
function expr.parse(input, fallback)
  fallback = fallback or 0
  log:debug("parsing expression: ", input)
  if not input then return fallback end

  if ssub(input, 1, 1) == "-" then
    input = "0" .. input
  end

  local success, result = pcall(helpers.evaluate_expression, input, expr_vars)

  if not success then
    log:warn("The given input '", input, "' could not be evaluated as a math expression: ", result)
    return fallback
  end

  return result
end

return expr
