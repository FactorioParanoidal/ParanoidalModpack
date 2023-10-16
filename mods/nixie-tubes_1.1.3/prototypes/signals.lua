data:extend(
  {{
    type = "item-subgroup",
    name = "virtual-signal-symbol",
    group = "signals",
    order = "e"
  }}
)


local symcount=1
local function create_symsignal(name,sort)
  data:extend(
  {
    {
      type = "virtual-signal",
      name = "signal-" .. name,
      icon = "__nixie-tubes__/graphics/signal/signal_" .. name .. ".png",
      icon_size = 32,
      subgroup = "virtual-signal-symbol",
      order = "e[symbols]-" .. sort .. "[" .. name .. "]"
    }
  })
  symcount = symcount + 1
end

--create_symsignal("negative")

--extended symbols
create_symsignal("paropen",'a-aa')
create_symsignal("parclose",'a-ab')
create_symsignal("sqopen",'a-ba')
create_symsignal("sqclose",'a-bb')
create_symsignal("curopen",'a-ca')
create_symsignal("curclose",'a-cb')

create_symsignal("stop",'b')
create_symsignal("qmark",'b')
create_symsignal("exmark",'b')
create_symsignal("at",'c')

create_symsignal("slash",'d')
create_symsignal("asterisk",'d')
create_symsignal("minus",'d')
create_symsignal("plus",'d')
create_symsignal("percent", 'd')

create_symsignal("float",'x')
create_symsignal("hex",'x')
