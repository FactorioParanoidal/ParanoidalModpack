-- Legendary ruins: constants, settings and difficulty ("ferocity").
local C = {}

C.FORCE = "pd-legend"            -- guardians, traps and the untouchable structure of legendary ruins
C.RUINS_FORCE = "AbandonedRuins:enemy"
C.WALL = "pd-legend-wall"         -- untouchable wall with a full-tile collision box
C.SURFACES = { nauvis = true }   -- legendary ruins are hand-made for the home planet
C.SCAN_INTERVAL = 60             -- players near sites: awake / discovery
C.TICK_INTERVAL = 6              -- logic of awake sites
C.WAIT_INTERVAL = 60             -- waiting sites: are all chunks generated?
C.AWAKE_MARGIN = 64              -- tiles around a site where its logic runs
C.DISCOVERY_MARGIN = 24          -- tiles around a site where it counts as found
C.AWAKE_TICKS = 240
C.SETTLE_TICKS = 90              -- after the last chunk: the core's ruin queue has been flushed
C.CLEAR_ROWS = 16                -- rows of the site cleared per tick
C.TILE_BUDGET = 4096             -- tiles set per tick while building
C.ENTITY_BUDGET = 350            -- entities created per tick while building
C.SPACING_CHUNKS_MIN = 24

-- Positive quality tiers counted from "normal": 1 = uncommon ... 4 = legendary (Отличное),
-- 5 = uncommon-t5 (Необычное), 6..10 = rare-t1..rare-t5 (blue group of ic-more-qualities).
C.TRIAL_QUALITY = { 4, 7 }
C.CITADEL_QUALITY = { 6, 10 }

function C.setting(name)
  local s = settings.global[name]
  if s == nil then return nil end
  return s.value
end

function C.enabled()
  return C.setting("pd-legendary-ruins") ~= false
end

local FEROCITY = {
  -- damage: scripted damage multiplier; hp: boss quality steps; time: timers multiplier
  legendary = { damage = 1, hp = 0, time = 1, truce = false, bolt = "pd-legend-bolt" },
  harsh = { damage = 0.55, hp = -3, time = 1.5, truce = false, bolt = "pd-legend-bolt-light" },
  truce = { damage = 0, hp = -6, time = 2, truce = true, bolt = nil },
}

function C.ferocity()
  return FEROCITY[C.setting("pd-legendary-ferocity") or "legendary"] or FEROCITY.legendary
end

-- Starting zone in chunks: the larger of the ruin-free zone of the core, the vanilla starting area
-- and the RSO starting region. Legendary ruins start this many chunks further out (setting, 100).
function C.start_chunks(surface)
  local zone = C.setting("ruins-min-distance-from-spawn") or 400
  local chunks = math.ceil(zone / 32)
  local mgs = surface.map_gen_settings
  local starting_area = (mgs and type(mgs.starting_area) == "number") and mgs.starting_area or 1
  chunks = math.max(chunks, math.ceil(150 * starting_area / 32))
  local region = settings.startup["rso-region-size"]
  if script.active_mods["RSO-reforged"] and region then
    chunks = math.max(chunks, math.ceil(region.value * starting_area))
  end
  return chunks
end

function C.min_distance(surface)
  return (C.start_chunks(surface) + (C.setting("pd-legendary-distance-chunks") or 100)) * 32
end

function C.spacing()
  return math.max(C.SPACING_CHUNKS_MIN, C.setting("pd-legendary-spacing-chunks") or 32) * 32
end

-- Quality ladder: positive qualities ordered by level (no defects, no hidden ones).
local ladder
function C.ladder()
  if ladder then return ladder end
  ladder = {}
  for name, q in pairs(prototypes.quality) do
    if name ~= "normal" and not q.hidden and q.level > 0 and not name:find("^ic%-defect") then
      ladder[#ladder + 1] = q
    end
  end
  table.sort(ladder, function(a, b)
    if a.level ~= b.level then return a.level < b.level end
    return a.order < b.order
  end)
  for i, q in ipairs(ladder) do ladder[i] = q.name end
  return ladder
end

---Quality name of positive tier `tier` (1 = first above normal). Clamped to existing qualities;
---"normal" when the quality mod is off.
function C.tier(tier)
  local list = C.ladder()
  if #list == 0 or tier <= 0 then return "normal" end
  return list[math.min(tier, #list)]
end

---Boss quality: tier shifted by the ferocity (harsh/truce bosses are weaker).
function C.boss_tier(tier)
  return C.tier(math.max(0, tier + C.ferocity().hp))
end

function C.reset_cache()
  ladder = nil
end

return C
