local config = {}

config.mod_prefix         = "Schall-PT-"
config.mod_prefix_ptrn    = "Schall%-PT%-"

config.idx_inv_chest      = defines.inventory.chest
config.PT_mod_name        = "SchallPickupTower"
config.PT_ptrn            = "^Schall%-pickup%-tower%-"
config.PT_radius_ptrn     = "%a+%-%a(%d+)"
config.PT_upper_suffix    = "-upper"
config.PT_upper_ptrn      = "%-upper$"
config.PT_upper_radius_ptrn = "%a+%-%a(%d+)%-.+"
config.PT_rect_color      = settings.startup[config.mod_prefix .. "range-colour"].value
for k, v in pairs(config.PT_rect_color) do
  config.PT_rect_color[k] = v / 4
end
config.PT_rect_color[4] = 0.05  -- These changes are to make two display modes offering similar visualizations.

config.PT_upper_filter = {
  {filter = "name", name = "Schall-pickup-tower-R32-upper"},
  {filter = "name", name = "Schall-pickup-tower-R64-upper"},
  {filter = "name", name = "Schall-pickup-tower-R96-upper"},
  {filter = "name", name = "Schall-pickup-tower-R128-upper"},
}



return config