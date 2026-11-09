--thx to ZarSasha

---@param t table
---@param ... string
---@return boolean
--- address_exists(table, "foo", "bar"...)
function address_exists(t, ...)
  for i = 1, select("#", ...) do
    if t == nil then return false end
    t = t[select(i, ...)]
  end
  return true
end

require("prototypes.entity")
require("prototypes.recipe")
require("prototypes.technology")
require("prototypes.item")

require("prototypes.space-age")
