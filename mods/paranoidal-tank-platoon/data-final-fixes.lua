local shared = require("prototypes.shared")
local specs = require("prototypes.tank-specs")

-- Damage and shooting-speed research also improves the new ammo, mirroring the final bonuses of the
-- 75 mm cannon (autocannon, 88 mm, 128 mm) and of bullets (sniper rounds), as in Beta 8.
local mirrors = {
  ["cannon-shell"] = {"cannon-H1-shell", "cannon-H2-shell", "autocannon-shell"},
  ["bullet"] = {"Schall-sniper-bullet"},
}

for _, technology in pairs(data.raw.technology) do
  local effects = technology.effects
  if effects and (technology.name:match("^physical%-projectile%-damage%-") or technology.name:match("^weapon%-shooting%-speed%-")) then
    local present = {}
    for _, effect in pairs(effects) do
      if effect.ammo_category then present[effect.type .. "/" .. effect.ammo_category] = true end
    end
    local added = {}
    for _, effect in pairs(effects) do
      local targets = (effect.type == "ammo-damage" or effect.type == "gun-speed") and mirrors[effect.ammo_category]
      for _, category in pairs(targets or {}) do
        if not present[effect.type .. "/" .. category] then
          present[effect.type .. "/" .. category] = true
          table.insert(added, {type = effect.type, ammo_category = category, modifier = effect.modifier})
        end
      end
    end
    for _, effect in pairs(added) do
      table.insert(effects, effect)
    end
  end
end

-- Keep the new tanks next to the vanilla tank in whatever crafting-menu row it ended up in.
local tank_item = data.raw["item-with-entity-data"]["tank"]
if tank_item then
  for _, spec in pairs(specs) do
    for _, tier in pairs(shared.tiers) do
      local item = data.raw["item-with-entity-data"][shared.tank_name(spec.class, tier)]
      if item then
        item.subgroup = tank_item.subgroup
        item.order = (tank_item.order or "") .. "-" .. spec.order .. "-" .. tier
      end
    end
  end
end
