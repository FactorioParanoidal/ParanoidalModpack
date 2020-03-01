
if settings.startup["nukes-require-cliff-explosives"].value then
  table.insert(data.raw.technology["atomic-bomb"].prerequisites,"cliff-explosives")
end