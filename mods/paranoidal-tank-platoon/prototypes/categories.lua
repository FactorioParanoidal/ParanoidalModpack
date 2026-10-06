data:extend({
  {type = "ammo-category", name = "autocannon-shell", bonus_gui_order = "k-a"},
  {type = "ammo-category", name = "cannon-H1-shell", bonus_gui_order = "k-b"},
  {type = "ammo-category", name = "cannon-H2-shell", bonus_gui_order = "k-c"},
  {type = "ammo-category", name = "Schall-sniper-bullet", bonus_gui_order = "a-s"},
})

-- Tank grids accept the same equipment categories as in Beta 8. Bob's Vehicle Equipment
-- normally defines them; keep the mod usable without it.
for _, category in pairs({"vehicle", "armoured-vehicle", "tank"}) do
  if not data.raw["equipment-category"][category] then
    data:extend({{type = "equipment-category", name = category}})
  end
end
