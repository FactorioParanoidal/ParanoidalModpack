-- Adapted from base's rail-pictures.lua 14/08/2024  TODO 2.0 check for updates
local util = require("util")

local ground_rail_render_layers =
{
  stone_path_lower = "rail-stone-path-lower",
  stone_path = "rail-stone-path",
  tie = "rail-tie",
  screw = "rail-screw",
  metal = "rail-metal"
}

local rail_segment_visualisation_endings =
{
  filename = "__base__/graphics/entity/rails/rail/rail-segment-visualisations-endings.png",
  priority = "extra-high",
  flags = { "low-object" },
  width = 64,
  height = 64,
  scale = 0.5,
  direction_count = 16,
  frame_count = 6,
}

local function make_legacy_rail_pictures(elems, rail_type)
  local keys
  if rail_type == "straight_rail" then
    keys =
    {
      { "north",     "vertical",              64, 64, 0, 0, true },
      { "northeast", "diagonal-right-top",    64, 64, 0, 0, true },
      { "east",      "horizontal",            64, 64, 0, 0, true },
      { "southeast", "diagonal-right-bottom", 64, 64, 0, 0, true },
      { "south",     "vertical",              64, 64, 0, 0, true },       -- Not used due to direction minimization
      { "southwest", "diagonal-left-bottom",  64, 64, 0, 0, true },
      { "west",      "horizontal",            64, 64, 0, 0, true },       -- Not used due to direction minimization
      { "northwest", "diagonal-left-top",     64, 64, 0, 0, true }
    }
  elseif rail_type == "curved_rail" then
    keys =
    {
      { "north",     "vertical-left-bottom",    128, 256, 0, 0 },       -- 192, 288
      { "northeast", "vertical-right-bottom",   128, 256, 0, 0 },
      { "east",      "horizontal-left-top",     256, 128, 0, 0 },
      { "southeast", "horizontal-left-bottom",  256, 128, 0, 0 },
      { "south",     "vertical-right-top",      128, 256, 0, 0 },
      { "southwest", "vertical-left-top",       128, 256, 0, 0 },
      { "west",      "horizontal-right-bottom", 256, 128, 0, 0 },
      { "northwest", "horizontal-right-top",    256, 128, 0, 0 }
    }
  end
  
  local res = {}
  for _, key in ipairs(keys) do
    local part = {}
    dashkey = rail_type:gsub("_", "-")
    for _, elem in ipairs(elems) do
      local variation_count = (key[7] and elem.variations) or 1
      if (elem[1] == "segment_visualisation_middle") then
        variation_count = nil
      end
      part[elem[1]] =
      {
        filename = string.format("__carriage__/graphics/entity/legacy-%s/%s-%s-%s.png", dashkey,
          dashkey, key[2], elem[2]),
        priority = elem.priority or "extra-high",
        flags = elem.mipmap and { "trilinear-filtering" } or { "low-object" },
        width = key[3] * 2,
        height = key[4] * 2,
        shift = { key[5], key[6] },
        blend_mode = "additive",
        scale = 0.5,
        variation_count = variation_count
      }
    end
    res[key[1]] = part
  end
  res["rail_endings"] =
  {
    sheets =
    {
      -- TODO
    }
  }
  res["render_layers"] = ground_rail_render_layers
  res["segment_visualisation_endings"] = rail_segment_visualisation_endings
  return res
end

function legacy_route_pictures(rail_type, invisible)
  local elems = {
    { "metals",                       "metals",                      mipmap = true },
    --{"backplates", "backplates", mipmap = true},
    --{"ties", "ties", variations = 3},
    --{"stone_path", "stone-path", variations = 3},
    --{"stone_path_background", "stone-path-background", variations = 3},
    { "segment_visualisation_middle", "segment-visualisation-middle" }
  }
  if invisible then elems = {} end
  return make_legacy_rail_pictures(elems, rail_type)
end

local function make_new_rail_pictures(keys, elems, max_variations)
  local function make_sprite_definition(filename, elem, key, variation_count)
    return
    {
      filename = filename,
      priority = elem.priority or "extra-high",
      flags = elem.mipmap and { "trilinear-filtering" } or { "low-object" },
      draw_as_shadow = elem.draw_as_shadow,
      width = key[3][1],
      height = key[3][2],
      x = key[2][1],
      y = key[2][2],
      scale = 0.5,
      shift = util.by_pixel(key[4][1], key[4][2]),
      variation_count = variation_count,
    }
  end

  local res = {}
  for _, key in ipairs(keys) do
    local part = {}
    local variation_count = key[5] or 1
    if max_variations then
      variation_count = math.min(variation_count, max_variations)
    end
    if (variation_count > 0) then
      for _, elem in ipairs(elems) do
        local layers = nil
        local variations = variation_count;
        --if (elem[1] == "segment_visualisation_middle") then
        variations = nil
        --end
        if (type(elem[2]) == "table") then
          layers = { layers = {} }
          for _, subelem in ipairs(elem[2]) do
            table.insert(layers.layers, make_sprite_definition(subelem[1], subelem, key, variations))
          end
        else
          layers = make_sprite_definition(elem[2], elem, key, variations)
        end

        if (elem[1] ~= nil) then
          part[elem[1]] = layers
        else
          part = layers
        end
      end
    end

    res[key[1]] = part
  end
  return res
end

function new_route_pictures(rail_type, invisible)
  local keys
  local NOT_USED_POSITION = { 0, 0 }
  local NOT_USED_SIZE = { 1, 1 }
  local NOT_USED_SHIFT = { 0, 0 }
  if rail_type == "straight" then
    keys =
    {
      { "north",     { 0, 256 },        { 256, 256 },  { 0, 0 },       8 },
      { "northeast", { 0, 2048 },       { 384, 384 },  { 0, 0 },       3 },
      { "east",      { 0, 0 },          { 256, 256 },  { 0, 0 },       8 },
      { "southeast", { 0, 896 },        { 384, 384 },  { 0, 0 },       3 },
      { "south",     NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0 },
      { "southwest", NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0 },
      { "west",      NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0 },
      { "northwest", NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0 }
    }
  elseif rail_type == "half-diagonal" then
    keys =
    {
      { "north",     { 0, 1280 },       { 384, 384 },  { 0, 0 },       3 },
      { "northeast", { 0, 1664 },       { 384, 384 },  { 0, 0 },       3 },
      { "east",      { 0, 2432 },       { 384, 384 },  { 0, 0 },       3 },
      { "southeast", { 0, 512 },        { 384, 384 },  { 0, 0 },       3 },
      { "south",     NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0 },
      { "southwest", NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0 },
      { "west",      NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0 },
      { "northwest", NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0 }
    }
  elseif rail_type == "curved-a" then
    keys =
    {
      { "north",     { 2048, 3 * 512 },  { 512, 512 }, { 0, 0 }, 4 },       -- piece 04
      { "northeast", { 2048, 12 * 512 }, { 512, 512 }, { 0, 0 }, 4 },       -- piece 13
      { "east",      { 2048, 7 * 512 },  { 512, 512 }, { 0, 0 }, 4 },       -- piece 08
      { "southeast", { 2048, 0 * 512 },  { 512, 512 }, { 0, 0 }, 4 },       -- piece 01
      { "south",     { 2048, 11 * 512 }, { 512, 512 }, { 0, 0 }, 4 },       -- piece 12
      { "southwest", { 2048, 4 * 512 },  { 512, 512 }, { 0, 0 }, 4 },       -- piece 05
      { "west",      { 2048, 15 * 512 }, { 512, 512 }, { 0, 0 }, 4 },       -- piece 16
      { "northwest", { 2048, 8 * 512 },  { 512, 512 }, { 0, 0 }, 4 },       -- piece 09
    }
  elseif rail_type == "curved-b" then
    keys =
    {
      { "north",     { 2048, 2 * 512 },  { 512, 512 }, { 0, 0 }, 4 },       -- piece 03
      { "northeast", { 2048, 13 * 512 }, { 512, 512 }, { 0, 0 }, 4 },       -- piece 14
      { "east",      { 2048, 6 * 512 },  { 512, 512 }, { 0, 0 }, 4 },       -- piece 07
      { "southeast", { 2048, 1 * 512 },  { 512, 512 }, { 0, 0 }, 4 },       -- piece 02
      { "south",     { 2048, 10 * 512 }, { 512, 512 }, { 0, 0 }, 4 },       -- piece 11
      { "southwest", { 2048, 5 * 512 },  { 512, 512 }, { 0, 0 }, 4 },       -- piece 06
      { "west",      { 2048, 14 * 512 }, { 512, 512 }, { 0, 0 }, 4 },       -- piece 15
      { "northwest", { 2048, 9 * 512 },  { 512, 512 }, { 0, 0 }, 4 },       -- piece 10
    }
  end
  local elems =
  {
    { "metals",                       "__carriage__/graphics/entity/route/route.png", },
    --{ "backplates",                   "__base__/graphics/entity/rails/rail/rail-backplates.png",         mipmap = true },
    --{ "ties",                         "__base__/graphics/entity/rails/rail/rail-ties.png"                              },
    --{ "stone_path",                   "__base__/graphics/entity/rails/rail/rail-stone-path-inside.png"                 },
    --{ "stone_path_background",        "__base__/graphics/entity/rails/rail/rail-stone-path.png"                        },
    { "segment_visualisation_middle", "__base__/graphics/entity/rails/rail/rail-segment-visualisations-middle.png" },
  }
  if invisible then elems = {} end

  local res = make_new_rail_pictures(keys, elems)
  --[[res["rail_endings"] =
  {
    sheets =
    {
      {
        filename = "__base__/graphics/entity/rails/rail/rail-endings-background.png",
        priority = "high",
        flags = { "low-object" },
        width = 256,
        height = 256,
        scale = 0.5
      },
      {
        filename = "__base__/graphics/entity/rails/rail/rail-endings-foreground.png",
        priority = "high",
        flags = { "trilinear-filtering" },
        width = 256,
        height = 256,
        scale = 0.5
      }
    }
  }]]
  res["render_layers"] = ground_rail_render_layers
  res["segment_visualisation_endings"] = rail_segment_visualisation_endings
  return res
end
