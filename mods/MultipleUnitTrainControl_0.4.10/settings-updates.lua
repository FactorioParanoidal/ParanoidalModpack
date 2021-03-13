--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: settings-updates.lua
 * Description: Add hidden setting entries to register MU locomotives with LuziferSenpai's Electronic Locomotives
--]]


if mods["Electronic_Locomotives"] then
  
  -- Search for extra Electronic Locomotives added in the settings table, and register their MUs
  local new_settings = {}
  local n=3
  for name,setting in pairs(data.raw["string-setting"]) do
    local m1 = string.find(name, "electronic_loco_register_add_")
    if m1 and m1 == 1 then
      local m2 = string.find(setting.default_value, "more_")
      if m2 and m2 == 1 then
        local v = tonumber(string.sub(setting.default_value, string.len("more_")+1))
        if v and v > 0 then
          v = v*2
          table.insert(new_settings,
            {
              type = "string-setting",
              name = name .. "-mu",
              setting_type = "startup",
              order = "0"..n,
              default_value = "more_"..v,
              hidden = true
            }
          )
          log("Registered Electronic Locomotive "..string.sub(name,string.len("electronic_loco_register_add_")+1).."-mu with "..v.." kW")
          n=n+1
        end
      end
    end
  end
  
  data:extend(new_settings)
  
  -- Register MU Electronic Locomotives from the base mod
  data:extend{
    {
        type = "string-setting",
        name = "electronic_loco_register_add_Electronic-Standard-Locomotive-mu",
        setting_type = "startup",
        order = "01",
        default_value = "more_1200",
        hidden = true
    },
    {
        type = "string-setting",
        name = "electronic_loco_register_add_Electronic-Cargo-Locomotive-mu",
        setting_type = "startup",
        order = "02",
        default_value = "more_6000",
        hidden = true
    }
  }
  log("Registered Electronic Locomotive Electronic-Cargo-Locomotive-mu with 1200 kW")
  log("Registered Electronic Locomotive Electronic-Cargo-Locomotive-mu with 3000 kW")
  
end

