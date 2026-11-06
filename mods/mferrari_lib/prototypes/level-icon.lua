-- Paranoidal: level marks on the icons of the enemies that come in several levels with one picture (fake humans,
-- bosses, flying saucers, the Big Monsters giants), so the entity lists (turret priority targets) tell them apart.
-- The level (1-10, A = 10) is drawn in the upper right corner as on the RampantFixed units; `mark` (a base signal
-- icon name) adds a small sign in the lower left corner. Levels above 10 get no number.
local function level_icons(prototype, level, mark)
  local icons = prototype.icons and table.deepcopy(prototype.icons)
    or {{icon = prototype.icon, icon_size = prototype.icon_size or 64}}
  if level and level >= 1 and level <= 10 then
    icons[#icons + 1] = {icon = "__base__/graphics/icons/signal/signal_" .. (level < 10 and level or "A") .. ".png",
      icon_size = 64, scale = 0.25, shift = {5, -10}}
  end
  if mark then
    icons[#icons + 1] = {icon = "__base__/graphics/icons/signal/" .. mark .. ".png", icon_size = 64, scale = 0.2,
      shift = {-9, 9}}
  end
  prototype.icons = icons
end

return level_icons
