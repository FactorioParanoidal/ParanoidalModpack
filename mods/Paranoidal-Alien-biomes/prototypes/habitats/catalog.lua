-- Additive habitats: fields describe places, components describe their visible layers.
-- No resources, tiles, trees or existing probability expressions are replaced.
local habitats = {
  {
    id = "wetland",
    field = "ab_habitat_wetland",
    tags = {"grass", "dirt"},
    vegetation = true,
    components = {
      -- Broad damp ground reaches the lower edge; plants gather farther inside.
      -- Reuse the accepted textures and leave existing tree placement untouched.
      {id = "wetland-floor", source = "wetland-decal", density = 0.025,
       shape = "1 + 0.5 * ab_habitat_wetland_edge"},
      {id = "wetland-understory", source = "asterisk-mini-turquoise", density = 0.08,
       shape = "0.25 + 0.75 * ab_habitat_wetland_interior"},
      {id = "root-colony", source = "asterisk-mini-blue", density = 0.003,
       shape = "ab_habitat_wetland_interior", entity = true, colony = true},
    },
  },
  {
    id = "crater",
    field = "ab_habitat_crater",
    tags = {"dirt", "sand"},
    components = {
      {id = "crater-centre", source = "crater3-huge", density = 1,
       shape = "ab_habitat_crater_distance < 0.8"},
      {id = "crater-floor", source = "stone-decal-black", density = 0.035,
       shape = "ab_habitat_crater_distance < ab_habitat_crater_radius * 0.65"},
      -- Ground deposits remain visible when the build disables decorative rocks.
      -- Keep the global decorative-rate multiplier and construction cleanup intact.
      {id = "crater-rim", source = "stone-decal-white", density = 0.035,
       shape = "clamp(1 - abs(ab_habitat_crater_distance - ab_habitat_crater_radius) / 5, 0, 1)"},
      {id = "crater-ejecta", source = "stone-decal-tan", density = 0.008,
       shape = "(ab_habitat_crater_distance > ab_habitat_crater_radius) * clamp(1 - (ab_habitat_crater_distance - ab_habitat_crater_radius) / 18, 0, 1)"},
      {id = "impact-breccia", rock = true, density = 0.25,
       shape = "ab_habitat_crater_distance < 2", tint = {0.48, 0.44, 0.40}},
    },
  },
  {
    id = "wetland-margin", field = "ab_habitat_wetland_margin",
    tags = {"grass", "dirt"}, vegetation = true,
    components = {
      {id = "margin-grass", source = "small-grass-green", density = 0.018},
      {id = "margin-rosettes", source = "asterisk-mini-turquoise", density = 0.012,
       shape = "clamp(0.5 + ab_habitat_detail, 0, 1)"},
    },
  },
  {
    id = "dry-margin", field = "ab_habitat_dry_margin",
    tags = {"grass", "dirt", "sand"}, vegetation = true,
    components = {
      {id = "dry-shrubs", source = "bush-mini-olive", density = 0.006},
      {id = "dry-rosettes", source = "pita-mini-red", density = 0.004,
       shape = "clamp(0.5 - ab_habitat_detail, 0, 1)"},
    },
  },
  {
    id = "silt-trace", field = "ab_habitat_silt_trace", tags = {"grass", "dirt"},
    components = {
      {id = "silt-ground", source = "wetland-decal", density = 0.008},
      {id = "silt-grains", source = "stone-decal-tan", density = 0.006,
       shape = "clamp(0.5 + ab_habitat_detail, 0, 1)"},
    },
  },
}

-- The resource IDs are also the existing geology expression suffixes; no new mapping.
local outcrops = {
  {"angels-ore1", {0.50, 0.47, 0.78}},
  {"angels-ore2", {0.80, 0.72, 0.39}},
  {"angels-ore3", {0.40, 0.64, 0.48}},
  {"angels-ore4", {0.72, 0.74, 0.76}},
  {"angels-ore5", {0.74, 0.40, 0.35}},
  {"angels-ore6", {0.62, 0.45, 0.33}},
  {"coal", {0.32, 0.33, 0.35}},
}
for _, entry in ipairs(outcrops) do
  local resource, tint = entry[1], entry[2]
  habitats[#habitats + 1] = {
    id = "outcrop-" .. resource,
    resource = resource,
    field = "ab_habitat_outcrop",
    tags = {"dirt", "sand", "grass"},
    components = {
      {id = "outcrop-" .. resource, rock = true, density = 0.008, tint = tint},
      {id = "outcrop-fragments-" .. resource, source = "stone-decal-tan",
       density = 0.018, tint = tint},
    },
  }
end
return habitats
