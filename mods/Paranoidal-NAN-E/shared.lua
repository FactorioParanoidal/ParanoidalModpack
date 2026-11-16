-- Names and numbers shared by the data stage and the script of Paranoidal-NAN-E (НЯН-Я / NAN-E).
local shared = {}

shared.mod = "__Paranoidal-NAN-E__"

shared.unit = "nan-e"                       -- she herself, a unit of her player's force
shared.husk = "nan-e-offline"               -- switched off: found at the Axiom-6, knocked out, or just unpacked
shared.item = "nan-e"                       -- a new (refurbished) one, placed as the husk; boots up by itself
shared.card = "nan-e-memory-card"           -- a bedtime-story card: one fragment of her memory
shared.drawing = "nan-e-drawing"            -- a keepsake from the colony's last camp
shared.capsule = "nan-e-time-capsule"       -- the colony's last camp: a box with their letter
shared.rod = "nan-e-umbrella-rod"           -- invisible lightning attractor of paranoidal-rain, carried along with her
shared.sticker = "nan-e-stun-sticker"       -- defibrillator: the attacker stands still a while
shared.zap = "nan-e-zap"                    -- the spark of the defibrillator
shared.input = "nan-e-toggle"
shared.shortcut = "nan-e"

shared.settings =
{
  look = "nan-e-look",
  chatter = "nan-e-chatter",
  distance = "nan-e-distance",
  errands = "nan-e-errands",
  spoilers = "nan-e-spoilers",
  voice = "nan-e-voice",
  chat = "nan-e-chat-log",
  button = "nan-e-button",
  decode = "nan-e-decode-seconds"
}

shared.tech =
{
  base = "nan-e",
  lamp = "nan-e-lamp",
  trail = "nan-e-trail",
  vacuum = "nan-e-vacuum",
  umbrella = "nan-e-umbrella",
  defib = "nan-e-defibrillator",
  memory = {"nan-e-memory-1", "nan-e-memory-2", "nan-e-memory-3", "nan-e-memory-4"}
}

shared.emotions = {"neutral", "happy", "worried", "surprised", "stern", "sleepy", "glitch"}

shared.sprite =
{
  portrait = "nan-e-portrait-",    -- .. emotion, the GUI
  face = "nan-e-face-",            -- .. emotion, over her screen in the world (own look)
  umbrella = "nan-e-umbrella"
}

shared.sounds =
{
  chatter = "nan-e-voice-chatter",
  happy = "nan-e-voice-happy",
  worried = "nan-e-voice-worried",
  surprised = "nan-e-voice-question",
  question = "nan-e-voice-question",
  stern = "nan-e-voice-stern",
  glitch = "nan-e-voice-glitch",
  sleepy = "nan-e-voice-sleepy",
  boot = "nan-e-boot",
  shutdown = "nan-e-shutdown",
  lullaby = "nan-e-lullaby",
  card = "nan-e-card",
  decrypted = "nan-e-decrypted",
  solved = "nan-e-solved",
  wrong = "nan-e-wrong",
  vacuum = "nan-e-vacuum",
  sneeze = "nan-e-sneeze",
  spray = "nan-e-spray",
  zap = "nan-e-zap",
  umbrella = "nan-e-umbrella-open"
}

-- Graphics of both looks (startup setting nan-e-look). The frames of the own look are rendered centred
-- frame_z tiles above the floor (tools: mod-development/mods/Paranoidal-NAN-E/blender/nane_model.py);
-- head_top is where her speech bubble starts, in screen tiles above her position.
shared.looks =
{
  own =
  {
    frame = {96, 112},
    shadow = {160, 112},
    directions = 16,
    frames = 4,
    frame_z = 0.55,
    head_top = 1.05,
    umbrella_offset = {0.05, -1.45}
  },
  informatron =
  {
    frame = {120, 104},
    directions = 8,
    frames = 1,
    head_top = 1.0,
    umbrella_offset = {0.1, -1.35}
  }
}

shared.movement_speed = 0.22   -- tiles a tick: a running engineer makes 0.15, she keeps up with exoskeletons
shared.max_health = 250

return shared
