data.raw["autoplace-control"]["grass"] = nil
data.raw["autoplace-control"]["dirt"] = nil
data.raw["autoplace-control"]["sand"] = nil
data.raw["autoplace-control"]["desert"] = nil


-- disable base rocks
data.raw['simple-entity']['huge-rock'].autoplace = nil
data.raw['simple-entity']['big-rock'].autoplace = nil
data.raw['simple-entity']['big-sand-rock'].autoplace = nil
data.raw['optimized-decorative']['medium-rock'].autoplace = nil
data.raw['optimized-decorative']['small-rock'] .autoplace= nil
data.raw['optimized-decorative']['tiny-rock'].autoplace = nil
data.raw['optimized-decorative']['medium-sand-rock'].autoplace = nil
data.raw['optimized-decorative']['small-sand-rock'].autoplace = nil
data.raw['optimized-decorative']['sand-decal'].autoplace = nil
data.raw['optimized-decorative']['sand-dune-decal'].autoplace = nil
-- data.raw['optimized-decorative']['light-mud-decal'].autoplace = nil
data.raw['optimized-decorative']['red-desert-decal'].autoplace = nil

-- Get the nauvis planet entity specification
local nauvis = data.raw.planet.nauvis
local nauvis_entity_settings
local nauvis_deco_settings
if    nauvis
  and nauvis.map_gen_settings
  and nauvis.map_gen_settings.autoplace_settings
then
  if nauvis.map_gen_settings.autoplace_settings.entity then
    nauvis_entity_settings = nauvis.map_gen_settings.autoplace_settings.entity.settings
  end
  if nauvis.map_gen_settings.autoplace_settings.decorative then
    nauvis_deco_settings = nauvis.map_gen_settings.autoplace_settings.decorative.settings
  end
end
if nauvis_entity_settings then
  nauvis_entity_settings['huge-rock'] = nil
  nauvis_entity_settings['big-rock'] = nil
  nauvis_entity_settings['big-sand-rock'] = nil
end
if nauvis_deco_settings then
  nauvis_deco_settings['medium-rock'] = nil
  nauvis_deco_settings['small-rock'] = nil
  nauvis_deco_settings['tiny-rock'] = nil
  nauvis_deco_settings['medium-sand-rock'] = nil
  nauvis_deco_settings['small-sand-rock'] = nil
  nauvis_deco_settings['sand-decal'] = nil
  nauvis_deco_settings['sand-dune-decal'] = nil
  nauvis_deco_settings['light-mud-decal'] = nil
  nauvis_deco_settings['red-desert-decal'] = nil
end