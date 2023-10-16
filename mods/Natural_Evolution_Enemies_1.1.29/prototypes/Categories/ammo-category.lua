require("__core__/lualib/bonus-gui-ordering")

data:extend({{
    type = "ammo-category",
    name = "ne-flame"
}, {
    type = "ammo-category",
    name = "ne-projectile"
}, {
    type = "ammo-category",
    name = "ne-land-mine"
}})

for k, v in pairs(data.raw["ammo-category"]) do
    if not v.bonus_gui_order then
        v.bonus_gui_order = bonus_gui_ordering[k]
    end
end
