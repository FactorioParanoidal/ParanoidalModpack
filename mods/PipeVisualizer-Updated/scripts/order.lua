local function get_fluid_ordering()
  --- @type table<string, integer>
  local order = {}
  local i = 0
  for name in pairs(prototypes.fluid) do
    i = i + 1
    order[name] = i
  end
  storage.fluid_order = order
end

local order = {}

order.on_init = get_fluid_ordering
order.on_configuration_changed = get_fluid_ordering

return order
