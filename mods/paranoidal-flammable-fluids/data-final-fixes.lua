-- Material warning belongs to the hazard mod, including when Bio Industries is optional.
for _, kind in ipairs { "pipe", "pipe-to-ground" } do
  local name = kind == "pipe" and "bi-wood-pipe" or "bi-wood-pipe-to-ground"
  local pipe = data.raw[kind] and data.raw[kind][name]
  if pipe then pipe.localised_description = { "flo-thermal.pipe-description" } end
end
