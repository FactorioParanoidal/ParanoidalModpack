-- Names and tier numbers shared by the data and control stages.
local S = {}

S.mod = "PickupTower-reforged"
S.base = "pickup-tower"
S.show_setting = "pickup-tower-show-range"

-- radius: half side of the picked square in tiles (scaled by the chest quality's range_multiplier);
-- interval: seconds between pickups; power: watts.
S.tiers = {
  {radius = 32, interval = 30, power = 250000},
  {radius = 64, interval = 60, power = 1000000},
  {radius = 96, interval = 90, power = 2250000},
  {radius = 128, interval = 120, power = 4000000},
}

function S.tower(tier) return S.base .. "-" .. tier end
function S.radar(tier) return S.base .. "-" .. tier .. "-radar" end

return S
