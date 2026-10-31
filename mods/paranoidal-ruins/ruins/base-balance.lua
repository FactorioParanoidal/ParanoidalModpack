-- Apply Paranoidal salvage limits to the copy returned by get_ruin_set.
-- Coordinates select either the surviving entities (keep) or the new remnants (remove).
local function positions(points)
  local rows = {}
  for _, point in ipairs(points) do
    local x, y = point[1], point[2]
    rows[y] = rows[y] or {}
    rows[y][x] = true
  end
  return rows
end

local rules = {
  large = {
    destroyedEnemyFort = {
      ["fast-inserter"] = { remove = positions({
        {10.5, -12.5}, {12.5, -10.5}, {-4.5, -6.5}, {-4.5, -2.5}, {12.5, 11.5},
      }) },
      ["assembling-machine-2"] = { remove = positions({{-3.5, -8.5}, {-5.5, -4.5}}) },
    },
    eFurnaceRail = {
      ["electric-furnace"] = { clear_dead = true, keep = positions({{1.5, -7.5}, {-4.5, 1.5}}) },
      ["express-transport-belt"] = { clear_dead = true, remove = positions({
        {-1.5, -11.5}, {4.5, -10.5}, {4.5, -9.5}, {-7.5, -6.5}, {4.5, -6.5},
        {-1.5, -5.5}, {4.5, -5.5}, {-7.5, -3.5}, {-1.5, -2.5}, {4.5, -2.5},
        {-1.5, -1.5}, {4.5, -1.5}, {-7.5, 0.5}, {4.5, 1.5}, {-7.5, 3.5},
        {-1.5, 5.5}, {-1.5, 6.5}, {-1.5, 8.5}, {1.5, 10.5}, {3.5, 10.5},
      }) },
      ["fast-inserter"] = { clear_dead = true, remove = positions({
        {-0.5, -10.5}, {-6.5, -6.5}, {-0.5, -6.5}, {-6.5, -5.5}, {-2.5, -2.5},
        {-0.5, -2.5}, {-6.5, -0.5}, {-6.5, 0.5}, {-0.5, 0.5}, {-6.5, 3.5},
        {0.5, 11.5}, {2.5, 11.5}, {1.5, 13.5}, {3.5, 13.5},
      }) },
    },
    nuclearPower = {
      ["steam-turbine"] = { clear_dead = true, keep = positions({
        {5.5, -12.5}, {7.5, 1.5}, {0.5, 6.5},
      }) },
      ["heat-exchanger"] = { clear_dead = true, keep = positions({
        {-6.5, -4}, {4, 1.5}, {0.5, 3},
      }) },
      ["substation"] = { remove = positions({{8, -8}, {-10, 8}}) },
    },
    solarField = {
      ["solar-panel"] = { keep = positions({
        {6.5, -14.5}, {3.5, -8.5}, {-11.5, 0.5}, {3.5, 0.5}, {9.5, 3.5},
      }) },
      ["accumulator"] = { keep = positions({
        {12, -12}, {12, -10}, {12, -8}, {6, -6}, {-6, -4}, {-6, -2}, {8, 8},
      }) },
    },
    trainMining = {
      ["laser-turret"] = { remove = positions({{12, -6.5}}) },
      ["electric-mining-drill"] = { keep = positions({{-0.5, -3}, {-4.5, 3}, {3.5, 6}}) },
      ["fast-transport-belt"] = { remove = positions({
        {-10.5, -5}, {-8.5, -5}, {-6.5, -5}, {1.5, -5}, {-6.5, -3}, {1.5, -3},
        {-6.5, -1}, {1.5, -2}, {-6.5, 1}, {-6.5, 2}, {1.5, 3}, {-6.5, 4},
        {1.5, 4}, {1.5, 7}, {1.5, 9},
      }) },
    },
    trainMining2 = {
      ["electric-mining-drill"] = { keep = positions({
        {-6.5, -13.5}, {5.5, -10.5}, {-2.5, -4.5}, {13.5, -1.5}, {5.5, 1.5},
        {-6.5, 7.5}, {9.5, 7.5},
      }) },
      ["laser-turret"] = { keep = positions({{-13, 9}, {-9, 11}}) },
    },
  },
  medium = {
    carAssembly = {
      ["assembling-machine-2"] = { clear_dead = true, keep = positions({
        {-5.5, -1.5}, {3.5, 1.5}, {1.5, 4.5},
      }) },
      ["inserter"] = { clear_dead = true, remove = positions({{-5.5, 5.5}, {2.5, 6.5}}) },
      ["fast-inserter"] = { clear_dead = true, remove = positions({
        {-1.5, -3.5}, {-0.5, -1.5}, {5.5, 1.5},
      }) },
      ["long-handed-inserter"] = { clear_dead = true, remove = positions({{3.5, -0.5}}) },
    },
    eFurnace = {
      ["electric-furnace"] = { clear_dead = true, keep = positions({
        {-1.5, -3.5}, {-4.5, 2.5}, {1.5, 2.5},
      }) },
    },
  },
}

return function(size, ruin)
  local size_rules = rules[size]
  local ruin_rules = size_rules and size_rules[ruin.name]
  if not ruin_rules then return end
  for _, entity in pairs(ruin.entities or {}) do
    local rule = ruin_rules[entity[1]]
    if rule then
      local selection = rule.keep or rule.remove
      local row = selection[entity[2].y]
      local selected = row and row[entity[2].x]
      local removed = (rule.keep and not selected) or (rule.remove and selected)
      local opts = entity[3]
      if rule.clear_dead and opts then opts.dead = nil end
      if removed then
        entity[1] = entity[1] .. "-remnants"
        if opts then
          opts.dmg = nil
          opts.recipe = nil
        end
      end
    end
  end
end
