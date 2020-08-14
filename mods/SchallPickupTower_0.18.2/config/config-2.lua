local config = {}

config.idx_inv_chest = defines.inventory.chest
config.PT_mod_name = "SchallPickupTower"
config.PT_ptrn = "^Schall%-pickup%-tower%-"
config.PT_radius_ptrn = "%a+%-%a(%d+)"
config.PT_upper_suffix = "-upper"
config.PT_upper_ptrn = "%-upper$"
config.PT_upper_radius_ptrn = "%a+%-%a(%d+)%-.+"
config.PT_rect_color = {r=0.05, g=0.1, b=0.05, a=0.05}



return config