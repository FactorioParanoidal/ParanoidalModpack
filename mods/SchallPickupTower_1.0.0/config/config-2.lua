local config = {}

local PT_rect_color_specs =
{
  ["red"]     = {r=0.10, g=0.05, b=0.05, a=0.05},
  ["yellow"]  = {r=0.10, g=0.10, b=0.05, a=0.05},
  ["green"]   = {r=0.05, g=0.10, b=0.05, a=0.05},
  ["cyan"]    = {r=0.05, g=0.10, b=0.10, a=0.05},
  ["blue"]    = {r=0.05, g=0.05, b=0.10, a=0.05},
  ["magenta"] = {r=0.10, g=0.05, b=0.10, a=0.05},
  ["white"]   = {r=0.10, g=0.10, b=0.10, a=0.05},
}

config.idx_inv_chest      = defines.inventory.chest
config.PT_mod_name        = "SchallPickupTower"
config.PT_ptrn            = "^Schall%-pickup%-tower%-"
config.PT_radius_ptrn     = "%a+%-%a(%d+)"
config.PT_upper_suffix    = "-upper"
config.PT_upper_ptrn      = "%-upper$"
config.PT_upper_radius_ptrn = "%a+%-%a(%d+)%-.+"
config.PT_rect_color      = PT_rect_color_specs[settings.startup["pickuptower-range-color"].value]



return config