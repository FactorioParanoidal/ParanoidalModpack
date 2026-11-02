-- Factorio 2.1 (Paranoidal port, user decision D14 "A", 2026-11-03): EntityPrototype::build_base_evolution_requirement
-- was removed without a replacement (silently ignored; enemy expansion follows the 2.1 rules), together with
-- LuaEntityPrototype::build_base_evolution_requirement and the "build-base-evolution-requirement" prototype filter.
-- The worm attacks of this library (CallWormAttack, enemies.lua) still pick worms by evolution: the values the enemy
-- mods give their worms (all set at the data stage) are kept in mod-data "mferrari-worm-evolution" (a turret without
-- a value had the 2.0 default 0), and the dead field is removed from every prototype.
local registry, removed = {}, 0
for kind, prototypes in pairs(data.raw) do
  for name, prototype in pairs(prototypes) do
    if type(prototype) == "table" and prototype.build_base_evolution_requirement ~= nil then
      if kind == "turret" then registry[name] = prototype.build_base_evolution_requirement end
      prototype.build_base_evolution_requirement = nil
      removed = removed + 1
    end
  end
end
data:extend({{type = "mod-data", name = "mferrari-worm-evolution", data = registry}})
log("mferrari_lib: build_base_evolution_requirement removed from " .. removed .. " prototypes (Factorio 2.1)")
