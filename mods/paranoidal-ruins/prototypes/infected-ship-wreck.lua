-- An abandoned hull, not mferrari_lib's boss spawner: no units and no nuclear death.
local wreck = table.deepcopy(data.raw.container["crash-site-spaceship"])
wreck.name = "pd-infected-ship-wreck"
wreck.flags = {"placeable-neutral", "placeable-off-grid", "player-creation", "not-rotatable", "not-blueprintable"}
wreck.max_health = 3000
wreck.inventory_size = 16
wreck.minable = {
  mining_time = 16,
  results = {
    {type = "item", name = "iron-plate", amount_min = 20, amount_max = 40},
    {type = "item", name = "steel-plate", amount_min = 5, amount_max = 10},
    {type = "item", name = "pipe", amount_min = 5, amount_max = 10},
  },
}
wreck.dying_explosion = "big-explosion"
wreck.map_color = {r = 0.45, g = 0.55, b = 0.35, a = 1}
-- Keep the vanilla hull as a standalone fallback; the mod need not enable Big-Monsters.
if mods["mferrari_lib"] then
  for _, layer in ipairs(wreck.picture.layers) do
    if not layer.draw_as_shadow then
      layer.filename = "__mferrari_lib__/graphics/entity/spaceship-infection.png"
      layer.tint = nil
    end
  end
end
data:extend({wreck})
