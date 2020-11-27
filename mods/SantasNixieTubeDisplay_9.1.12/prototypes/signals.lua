data:extend(
  {{
    type = "item-subgroup",
    name = "virtual-signal-symbol",
    group = "signals",
    order = "e"
  }}
)


local symcount=1
local function create_virtual_signal(name,sort)
  data:extend(
  {
    {
      type = "virtual-signal",
      name = "signal-" .. name,
      icon = "__SantasNixieTubeDisplay__/graphics/signal/signal_" .. name .. ".png",
      icon_size = 32,
      subgroup = "virtual-signal-symbol",
      order = "e[symbols]-" .. sort .. "[" .. name .. "]"
    }
  })
  symcount = symcount + 1
end

--create_virtual_signal("negative")

--extended symbols
create_virtual_signal("sqopen",'a')
create_virtual_signal("sqclose",'a')
create_virtual_signal("curopen",'a')
create_virtual_signal("curclose",'a')
create_virtual_signal("paropen",'a')
create_virtual_signal("parclose",'a')

create_virtual_signal("stop",'b')
create_virtual_signal("qmark",'b')
create_virtual_signal("exmark",'b')
create_virtual_signal("at",'c')

create_virtual_signal("slash",'d')
create_virtual_signal("asterisk",'d')
create_virtual_signal("minus",'d')
create_virtual_signal("plus",'d')
