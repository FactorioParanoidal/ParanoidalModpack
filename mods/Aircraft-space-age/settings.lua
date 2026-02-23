data:extend(
{
  {
    type = "bool-setting",
    name = "aircraft-sound-setting",
    setting_type = "startup",
    default_value = true,
    order = "aa",
  },
  {
    type = "bool-setting",
    name = "aircraft-hardmode",
    setting_type = "startup",
    default_value = false,
    order = "ab",
  },
 {
    type = "bool-setting",
    name = "aircraft-belt-immunity",
    setting_type = "startup",
    default_value = true,
    order = "ac",
  },
  -- {
  --   type = "bool-setting",
  --   name = "helicopter-tech",
  --   setting_type = "startup",
  --   default_value = false,
  --   order = "ba",
  -- },
  -- {
  --   type = "bool-setting",
	-- name = "heli-equipment-grid",
	-- setting_type = "startup",
	-- default_value = false,
	-- order = "bb",
  -- },
  -- {
  --   type = "bool-setting",
  --   name = "raven-tech",
  --   setting_type = "startup",
  --   default_value = false,
  --   order = "bc",
  -- },
  -- {
  --   type = "bool-setting",
  --   name = "heli-equipment-grid",
  --   setting_type = "startup",
  --   default_value = false,
  --   order = "bb",
  -- },
  {
    type = "bool-setting",
    name = "non-combat-mode",
    setting_type = "startup",
    default_value = false,
    order = "bd",
  },
  {
    type = "bool-setting",
    name = "inserter-immunity",
    setting_type = "startup",
    default_value = false,
    order = "be",
  },
  -- {
  --   type = "bool-setting",
  --   name = "space-age-easy-mode",
  --   setting_type = "startup",
  --   default_value = false,
  --   order = "bf",
  -- },
  {
    type = "bool-setting",
    name = "lock-surfaces-space-age",
    setting_type = "startup",
    default_value = true,
    order = "bg",
  },
  {
    type = "bool-setting",
    name = "carbon-fiber-aircraft",
    setting_type = "startup",
    default_value = true,
    order = "bh",
  },
  {
    type = "bool-setting",
    name = "use-old-stats",
    setting_type = "startup",
    default_value = true,
    hidden=true,
    order = "bi",
  },
  {
    type = "bool-setting",
    name = "disable-tank-controls",
    setting_type = "startup",
    default_value = true,
    order = "bj",
  },
  {
    type = "double-setting",
    name = "fuel-consumption-multiplier",
    setting_type = "startup",
    default_value = 10,
    order = "bk",
  },
  {
    type = "bool-setting",
    name = "aircraft-change-vanilla-tech-tree",
    setting_type = "startup",
    default_value = true,
    order = "bz",
  },
  
  

})

if mods["AircraftRealism"] then
  
  require("lib.aircraftRealism-util")

  local aircraft_list={"gunship","cargo-plane","jet","flying-fortress"}
  for i,aircraft in ipairs(aircraft_list) do
    
    data:extend{{
      type = "double-setting",
      name = "transition-speed-"..aircraft,
      setting_type = "runtime-global",
      default_value = v_liftoff(aircraft:gsub("-","_"),"steel"),
      minimum_value=v_liftoff(aircraft:gsub("-","_"),"steel")-0.001,
      maximum_value=v_liftoff(aircraft:gsub("-","_"),"steel"),
      order = "c",
    }}
    data:extend{{
      type = "double-setting",
      name = "transition-speed-"..aircraft.."-carbon-fiber",
      setting_type = "runtime-global",
      default_value = v_liftoff(aircraft:gsub("-","_"),"carbon-fiber"),
      minimum_value = v_liftoff(aircraft:gsub("-","_"),"carbon-fiber")-0.001,
      maximum_value = v_liftoff(aircraft:gsub("-","_"),"carbon-fiber"),
      order = "c",
    }}
    data:extend{{
      type = "double-setting",
      name = "shadow-end-animation-speed-"..aircraft,
      setting_type = "startup",
      hidden=true,
      default_value = v_liftoff(aircraft:gsub("-","_"),"steel")*3,
      minimum_value=(v_liftoff(aircraft:gsub("-","_"),"steel")*3-0.001),
      maximum_value=v_liftoff(aircraft:gsub("-","_"),"steel")*3,
      order = "c",
    }}
    data:extend{{
      type = "double-setting",
      name = "shadow-end-animation-speed-"..aircraft.."-carbon-fiber",
      hidden=true,
      setting_type = "startup",
      default_value = v_liftoff(aircraft:gsub("-","_"),"carbon-fiber")*3,
      minimum_value = (v_liftoff(aircraft:gsub("-","_"),"carbon-fiber")*3-0.001),
      maximum_value = v_liftoff(aircraft:gsub("-","_"),"carbon-fiber")*3,
      order = "c",
    }}

  end
  -- data:extend{{
  --   type = "double-setting",
  --   name = "transition-speed-gunship",
  --   setting_type = "runtime-global",
  --   default_value = 100,
  --   order = "ca",
  -- },
  -- {
  --   type = "double-setting",
  --   name = "transition-speed-gunship-carbon-fiber",
  --   setting_type = "runtime-global",
  --   default_value = 100,
  --   order = "cb",
  -- },
  -- {
  --   type = "double-setting",
  --   name = "transition-speed-cargo-plane",
  --   setting_type = "runtime-global",
  --   default_value = 100,
  --   order = "cc",
  -- },
  -- {
  --   type = "double-setting",
  --   name = "transition-speed-cargo-plane-carbon-fiber",
  --   setting_type = "runtime-global",
  --   default_value = 100,
  --   order = "cd",
  -- },
  -- {
  --   type = "double-setting",
  --   name = "transition-speed-jet",
  --   setting_type = "runtime-global",
  --   default_value = 100,
  --   order = "ce",
  -- },
  -- {
  --   type = "double-setting",
  --   name = "transition-speed-jet-carbon-fiber",
  --   setting_type = "runtime-global",
  --   default_value = 100,
  --   order = "cf",
  -- },
  -- {
  --   type = "double-setting",
  --   name = "transition-speed-flying-fortress",
  --   setting_type = "runtime-global",
  --   default_value = 100,
  --   order = "cg",
  -- },
  -- {
  --   type = "double-setting",
  --   name = "transition-speed-flying-fortress-carbon-fiber",
  --   setting_type = "runtime-global",
  --   default_value = 100,
  --   order = "ch",
  -- }

end