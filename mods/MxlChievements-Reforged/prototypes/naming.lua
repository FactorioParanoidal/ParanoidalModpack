-- Prototype names of new achievements, shared by the data stage and control.lua.
-- A series with several amounts is "mxlr-<id>-<tier>", a single achievement is "mxlr-<id>".

local naming = {}

naming.PREFIX = "mxlr-"

function naming.tiered(entry)
  return entry.amounts ~= nil and #entry.amounts > 1
end

function naming.name(entry, tier)
  if naming.tiered(entry) then return naming.PREFIX .. entry.id .. "-" .. tier end
  return naming.PREFIX .. entry.id
end

-- Amounts of the series; kinds without an amount get a single tier.
function naming.amounts(entry)
  return entry.amounts or {entry.amount or 1}
end

return naming
