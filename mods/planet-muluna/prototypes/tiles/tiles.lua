Muluna:extend{
  {
    type = "item-subgroup",
    name = "muluna-tiles",
    group = "tiles",
    order = "g",
  }
}

-- Items dropped on Muluna soil burn away with a puff of smoke, like items
-- dropped on Vulcanus lava. Vanilla's "smoke" lasts 600 ticks; this one
-- disperses six times as fast, so it uses the same animation with a sixth
-- of the lifetime.
local smoke_speed = 6
local dropped_item_smoke = table.deepcopy(data.raw["trivial-smoke"]["smoke"])
dropped_item_smoke.name = "muluna-dropped-item-smoke"
dropped_item_smoke.duration = math.floor(dropped_item_smoke.duration / smoke_speed)
dropped_item_smoke.spread_duration = math.floor(dropped_item_smoke.spread_duration / smoke_speed)
dropped_item_smoke.fade_away_duration = math.floor(dropped_item_smoke.fade_away_duration / smoke_speed)
Muluna:extend{dropped_item_smoke}

local destroyed_dropped_item_trigger = {
  type = "direct",
  action_delivery = {
    type = "instant",
    source_effects = {
      type = "create-trivial-smoke",
      smoke_name = dropped_item_smoke.name,
      offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
      starting_frame_deviation = 5
    }
  }
}

local concrete = table.deepcopy(data.raw["tile"]["concrete"])
local refined_concrete = table.deepcopy(data.raw["tile"]["refined-concrete"])

local speed_modifier = 4/5

local muluna_dirt_base=table.deepcopy(data.raw["tile"]["dry-dirt"])
muluna_dirt_base.walking_speed_modifier = speed_modifier
muluna_dirt_base.vehicle_friction_modifier = concrete.vehicle_friction_modifier
muluna_dirt_base.walking_sound = "__space-age__/sound/walking/soft-sand-1.ogg"
muluna_dirt_base.destroys_dropped_items = true
muluna_dirt_base.default_destroyed_dropped_item_trigger = destroyed_dropped_item_trigger
muluna_dirt_base.hidden = false
muluna_dirt_base.hidden_in_factoriopedia = false
muluna_dirt_base.subgroup = "muluna-tiles"
muluna_dirt_base.custom_tooltip_fields = {
  {
    name = {"tooltip.digging-result"},
    value = {"tooltip-value.digging-result","muluna-regolith-digging",{"recipe-name.muluna-regolith-digging"}}
  },
  {
    name = {"tooltip.destroys-dropped-items"},
    value = {"gui.yes"}
  }
}
muluna_dirt_base.absorptions_per_second={
    --radiation = 0.01/60
  }
local color={
    {55,55,65},
    {50,50,60},
    {45,45,55},
    {60,60,70},
    {70,70,80},
    {80,80,90},
}

-- Paranoidal fork: the ground took Alien Biomes textures (mineral-grey-dirt/sand); their licence forbids
-- redistribution in a modpack and Alien-biomes-Reforged excludes alien-biomes-graphics. The grey ground uses the
-- variants of Space Age's own grey tiles instead (Aquilo dust, Vulcanus ash).
local paranoidal_dirt_tiles = {"dust-flat", "dust-crests", "dust-lumpy", "dust-patchy", "dust-flat", "dust-crests"}
local paranoidal_sand_tiles = {"volcanic-ash-light", "volcanic-ash-flats", "volcanic-smooth-stone"}
local function paranoidal_variants(name)
  return table.deepcopy(data.raw["tile"][name].variants)
end
for i = 1,6,1 do
    local muluna_dirt=table.deepcopy(muluna_dirt_base)
    muluna_dirt.name="muluna-dirt-"..tostring(i)
    if i == 1 then
      muluna_dirt.hidden_in_factoriopedia = false
      muluna_dirt.hidden = false
    else
      muluna_dirt.factoriopedia_alternative = "muluna-dirt-1"
    end
    muluna_dirt.autoplace = {probability_expression = 'expression_in_range_base(0.45, -10, 0.55, 0.35) + 0.25*noise_layer_noise('..tostring(i)..')'}
    muluna_dirt.localised_name={"tile-name.muluna-dirt",i > 1 and tostring(i) or ""}
    
    muluna_dirt.variants = paranoidal_variants(paranoidal_dirt_tiles[i])
  
  muluna_dirt.layer=19+i
  muluna_dirt.map_color=color[i]
  --muluna_dirt.effect = "space"
  Muluna:extend{muluna_dirt}
end


local muluna_sand_base=table.deepcopy(data.raw["tile"]["dry-dirt"])
muluna_sand_base.default_destroyed_dropped_item_trigger = destroyed_dropped_item_trigger

local color_sand={
    {85,85,95},
    {90,90,100},
    {87,87,97},
}

for i = 1,3,1 do
    local muluna_dirt=table.deepcopy(muluna_sand_base)
    muluna_dirt.name="muluna-dirt-"..tostring(i+6)
   
    --muluna_dirt.hidden_in_factoriopedia = true
    --muluna_dirt.hidden = true
    muluna_dirt.factoriopedia_alternative = "muluna-dirt-1"
    muluna_dirt.autoplace = {probability_expression = 'expression_in_range_base(0.45, -10, 0.55, 0.35) + 0.25*noise_layer_noise('..tostring(i+6)..')'}
    muluna_dirt.localised_name={"tile-name.muluna-dirt",tostring(i+6)}
    muluna_dirt.walking_speed_modifier = speed_modifier
    muluna_dirt.vehicle_friction_modifier = refined_concrete.vehicle_friction_modifier
    muluna_dirt.walking_sound = "__space-age__/sound/walking/soft-sand-1.ogg"
    muluna_dirt.custom_tooltip_fields = muluna_dirt_base.custom_tooltip_fields
    muluna_dirt.destroys_dropped_items = true
    muluna_dirt.variants = paranoidal_variants(paranoidal_sand_tiles[i])
  --muluna_dirt.effect = "space"
  muluna_dirt.absorptions_per_second={
    --radiation = 0.01/60
  }
  muluna_dirt.layer=25+i
  muluna_dirt.map_color=color_sand[i]
  Muluna:extend{muluna_dirt}
end








