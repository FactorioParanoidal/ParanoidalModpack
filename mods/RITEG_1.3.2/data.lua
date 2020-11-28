local mod_name = "__RITEG__"
local RTG = "RITEG-1"
local used_up_RTG = "used-up-RITEG-1"

require ("RITEG-prototype")

if mods['PlutoniumEnergy'] then
  require ("mods/PlutoniumEnergy")
end 

if mods['Nuclear Fuel'] then
  require ("mods/Nuclear_Fuel")
end 

data:extend ({
  {
    type = "sprite",
    name = 'riteg_glow',
    filename = "__RITEG__/graphics/riteg-glow.png",
    priority = "extra-high",
    -- flags = {"light"},
    flags = {"no-crop" },
    width = 102, height = 180
  }
})