-- Constants shared by the data and control stages.
local S = {}

S.MOD = "__paranoidal-power-districts__"
S.GFX = S.MOD .. "/graphics/"

-- nominal in W; bonus is the base bonus in the green zone
S.TIERS = {
  { key = "40", name = "ppd-transformer-40", nominal = 40e6, bonus = 0.06, color = { r = 0.96, g = 0.77, b = 0.25 } },
  { key = "80", name = "ppd-transformer-80", nominal = 80e6, bonus = 0.08, color = { r = 0.91, g = 0.33, b = 0.24 } },
  { key = "160", name = "ppd-transformer-160", nominal = 160e6, bonus = 0.10, color = { r = 0.31, g = 0.65, b = 0.93 } },
  { key = "320", name = "ppd-transformer-320", nominal = 320e6, bonus = 0.12, color = { r = 0.44, g = 0.84, b = 0.36 } },
}
S.TIER_BY_NAME = {}
for i, t in ipairs(S.TIERS) do
  t.index = i
  t.eei_in = "ppd-in-" .. t.key
  t.eei_out = "ppd-out-" .. t.key
  S.TIER_BY_NAME[t.name] = t
end

S.LIMIT = 1.25          -- output cap, share of the nominal
S.IDLE = 0.0025         -- idle draw, share of the nominal
S.TAU = 30 * 60         -- averaging time constant, ticks
S.CHARGE_TICKS = 1800   -- empty buffers of a new transformer fill in about 30 s at most (from spare power only)

-- layout (the transformer does not rotate): copper studs of the bushings relative to the centre (0.2.1 art);
-- input = the tall brown bushing on the left, output = the short grey one on the right
S.TIP_IN = { -1.379, -2.214 }
S.TIP_OUT = { 1.126, -1.483 }
S.LAMP = { 1.524, 0.236 }  -- status lamp glass on the right of the front face (0.2.1, tools/make_graphics.py GLASS)
S.LENS_SCALE = 0.10632     -- lens sprite: 1 source pixel of the art in game pixels
S.LOAD_BANK = "ppd-load-bank"
S.LOAD_BANK_EEI = "ppd-load-bank-eei"
S.LOAD_BANK_MAX = 10e6  -- W
S.POLE_IN = "ppd-pole-in"
S.POLE_OUT = "ppd-pole-out"
S.POLE_ALT = "ppd-pole-alt"

-- district colours (index 1..8)
S.COLORS = {
  { r = 0.96, g = 0.77, b = 0.25 }, { r = 0.91, g = 0.33, b = 0.24 }, { r = 0.31, g = 0.65, b = 0.93 },
  { r = 0.44, g = 0.84, b = 0.36 }, { r = 0.69, g = 0.48, b = 0.88 }, { r = 0.88, g = 0.48, b = 0.72 },
  { r = 0.48, g = 0.88, b = 0.85 }, { r = 0.81, g = 0.81, b = 0.81 },
}

S.TECH = {
  t40 = "ppd-transformers", t80 = "ppd-transformers-2", t160 = "ppd-transformers-3", t320 = "ppd-transformers-4",
  load_bank = "ppd-load-banks", automation = "ppd-power-automation",
  efficiency = "ppd-efficiency-", regulation = "ppd-regulation-",
  -- 0.2.0
  taps = "ppd-taps-", auto_taps = "ppd-auto-taps", amorphous = "ppd-amorphous-cores", boost = "ppd-overload",
  metering = "ppd-metering",
}
S.TAP_LEVELS = 2          -- "Отпайки 1-2": +-10 % and +-20 % of the nominal
S.TAP_STEP = 0.10
S.TAP_DELAY = 1800        -- automatic tap changer: one step per 30 s out of the zone at most
S.AMORPHOUS = 0.4         -- idle draw multiplier after "Аморфные сердечники"
S.BOOST = 1.5             -- short overload: output cap 150 % of the nominal ...
S.BOOST_TICKS = 3600      -- ... for 60 s ...
S.BOOST_COOLDOWN = 18000  -- ... then 5 min rest
S.METER = "ppd-power-meter"
S.METER_EEI = "ppd-power-meter-eei"
S.EFFICIENCY_LEVELS = 5
S.REGULATION_LEVELS = 2

return S
