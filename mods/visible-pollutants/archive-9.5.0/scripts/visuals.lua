-- Shared data/runtime geometry. These constants never feed the solar model.
local Visuals = {}

Visuals.TextureSize = 1024
-- HD masks have about half the legacy optical depth. Restore their aggregate
-- weight through overlap, not through player settings or the shared solar curve.
Visuals.WorldSize = 128
Visuals.LegacyWorldSize = 96
Visuals.Jitter = 2
Visuals.MotionRadius = 1.5 -- maximum displacement per axis, also reserved in static mode
Visuals.Animation = "visible-pollutants-veil-drift"
Visuals.AnimationSize = 512
Visuals.FrameCount = 32
Visuals.LineLength = 8
Visuals.AnimationSpeed = 2 / 60 -- native frames per game tick; 16-second cycle
Visuals.LegacySprite = "visible-pollutants-pollution"
Visuals.Variants = { "veil", "haze", "broken", "smog" }
Visuals.FootprintHalfExtent = Visuals.WorldSize / 2 * math.sqrt(2) + Visuals.Jitter + Visuals.MotionRadius
Visuals.LegacyFootprintHalfExtent = Visuals.LegacyWorldSize / 2 * math.sqrt(2) + Visuals.Jitter

function Visuals.sprite_name(variant)
  return "visible-pollutants-pollution-" .. variant
end

-- Jenkins-style 32-bit mixing: additions/shifts stay exact in Lua 5.2 doubles.
-- Hash coordinates separately, not the grid's large packed numeric key.
local function mix(hash, value)
  hash = bit32.band(hash + bit32.band(value, 0xffffffff), 0xffffffff)
  hash = bit32.band(hash + bit32.lshift(hash, 10), 0xffffffff)
  return bit32.bxor(hash, bit32.rshift(hash, 6))
end

local function finish(hash)
  hash = bit32.band(hash + bit32.lshift(hash, 3), 0xffffffff)
  hash = bit32.bxor(hash, bit32.rshift(hash, 11))
  return bit32.band(hash + bit32.lshift(hash, 15), 0xffffffff)
end

-- Fixed variant order and independent mixed outputs keep recreation stable.
-- No map RNG is consumed, and neither pollution nor wind chooses the form.
function Visuals.for_cell(surface_index, cell)
  local hash = finish(mix(mix(mix(0x6d2b79f5, surface_index), cell.x), cell.y))
  local name = Visuals.sprite_name(Visuals.Variants[hash % #Visuals.Variants + 1])
  hash = finish(mix(hash, 1))
  local dx = hash % (2 * Visuals.Jitter + 1) - Visuals.Jitter
  hash = finish(mix(hash, 2))
  local dy = hash % (2 * Visuals.Jitter + 1) - Visuals.Jitter
  hash = finish(mix(hash, 3))
  local orientation = hash / 4294967296
  local phase = finish(mix(hash, 4)) / 4294967296 * Visuals.FrameCount
  return name, { x = cell.center.x + dx, y = cell.center.y + dy }, orientation, phase
end

return Visuals
