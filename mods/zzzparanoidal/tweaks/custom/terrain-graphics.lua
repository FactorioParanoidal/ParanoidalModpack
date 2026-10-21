-- Графика покрытий и облаков (Beta 8: мод SingleColorTerrain и блок micro-final-fix zzzparanoidal).
-- hr-картинки совпадают по раскладке с текстурами base 2.0: подменяются только картинки,
-- маски и переходы остаются базовыми.

local path = "__zzzparanoidal__/graphics/terrain/"
local transition_files =
{
  inner_corner = "inner-corner",
  outer_corner = "outer-corner",
  side = "side",
  u_transition = "u",
  o_transition = "o"
}

local function set_overlay(tile, prefix)
  local layout = tile.variants.transition and tile.variants.transition.overlay_layout
  if not layout then
    log("zzzparanoidal: tile " .. tile.name .. " has no transition.overlay_layout, overlay left unchanged")
    return
  end
  for kind, file in pairs(transition_files) do
    if layout[kind] then
      layout[kind].spritesheet = prefix .. file .. ".png"
    end
  end
end

-- Без облаков: 1×1 пиксель вместо спрайта облаков.
if settings.startup["no-clouds"].value then
  data.raw["utility-sprites"]["default"].clouds =
  {
    filename = "__core__/graphics/clouds.png",
    priority = "low",
    flags = {"linear-minification", "linear-magnification"},
    width = 1,
    height = 1,
    frame_count = 1
  }
end

-- Белый бетон.
local concrete = data.raw.tile["concrete"]
if settings.startup["white-concrete"].value and concrete then
  set_overlay(concrete, path .. "concrete/hr-concrete-")
  if concrete.variants.material_background then
    concrete.variants.material_background.picture = path .. "concrete/hr-concrete.png"
  end
end

-- Каменная дорожка: «Новое покрытие для кирпича» важнее белой дорожки, как в Beta 8
-- (там micro-final-fix перекрывал SingleColorTerrain).
local stone_path = data.raw.tile["stone-path"]
local refined_concrete = data.raw.tile["refined-concrete"]
if stone_path and settings.startup["stone-path-concrete"].value and refined_concrete then
  local variants = table.deepcopy(refined_concrete.variants)
  variants.material_background =
  {
    picture = "__zzzparanoidal__/graphics/patches/hr-concrete.png",
    count = 8,
    scale = 0.5
  }
  stone_path.variants = variants
elseif stone_path and settings.startup["white-stone"].value then
  local prefix = path .. "stone-path/hr-stone-path-"
  for _, variant in pairs(stone_path.variants.main or {}) do
    variant.picture = prefix .. variant.size .. ".png"
  end
  set_overlay(stone_path, prefix)
end
