-- What she says on her own: lessons on technical debt, jokes, glimpses of her memory and, very rarely, a secret.
-- Nothing here when her player chose "silent" or asked her to be quiet.
local shared = require("shared")
local speech = require("script.speech")

local chatter = {}

local minute = 3600
-- Seconds between her own lines, by setting.
local intervals = {often = {120, 240}, rare = {420, 720}}
local spoiler_gap = 45 * minute
local lessons, jokes, glitches = 10, 10, 4

-- Secrets she may let slip: only those of mods in the game.
local spoilers =
{
  {key = "bnl-safe", mod = "zzzparanoidal-start-bnl"},
  {key = "bnl-recorder", mod = "zzzparanoidal-start-bnl"},
  {key = "bnl-trail", mod = "zzzparanoidal-start-bnl"},
  {key = "bnl-code-l", mod = "zzzparanoidal-start-bnl"},
  {key = "distress", mod = "zzzparanoidal-start-bnl"},
  {key = "ruins-legend", mod = "paranoidal-ruins", legend = true},
  {key = "robots", mod = "paranoidal-robot-attrition"},
  {key = "rain", mod = "paranoidal-rain"},
  {key = "dok", mod = "Paranoidal-Droid-M-O"},
  {key = "quality", mod = "ic-more-qualities"},
  {key = "codex", mod = "paranoidal-CodexRPG"},
  {key = "achievements", mod = "paranoidal-achievements"}
}
-- The legendary ruins of paranoidal-ruins whose hint ([pd-legendary-hint]) the kids told as scary stories.
local legends =
{
  "labyrinth", "minesweeper", "pyramid", "searchlight", "dune", "gates", "crypt", "mirrors", "frozen", "bazaar",
  "forge", "colosseum", "hive", "director", "reactor", "oilfield", "quarantine", "hammer", "mothership",
  "observatory", "yggdrasil", "cemetery"
}

chatter.mode = function(player)
  return player.mod_settings[shared.settings.chatter].value
end

-- May she talk by herself now (setting, the quiet hour)?
chatter.allowed = function(data, player)
  if chatter.mode(player) == "silent" then return false end
  return not (data.quiet_until and game.tick < data.quiet_until)
end

chatter.schedule = function(data, player)
  local range = intervals[chatter.mode(player)] or intervals.rare
  data.next_chatter = game.tick + math.random(range[1], range[2]) * 60
end

local pick_spoiler = function(data)
  data.spoiled = data.spoiled or {}
  local candidates = {}
  for _, spoiler in pairs(spoilers) do
    if script.active_mods[spoiler.mod] then
      if spoiler.legend then
        for _, name in pairs(legends) do
          if not data.spoiled["legend-" .. name] then
            candidates[#candidates + 1] = {key = spoiler.key, legend = name}
          end
        end
      elseif not data.spoiled[spoiler.key] then
        candidates[#candidates + 1] = {key = spoiler.key}
      end
    end
  end
  if #candidates == 0 then return nil end
  local choice = candidates[math.random(#candidates)]
  if choice.legend then
    data.spoiled["legend-" .. choice.legend] = true
    return {"nan-e-spoiler." .. choice.key, {"pd-legendary-hint." .. choice.legend}}
  end
  data.spoiled[choice.key] = true
  return {"nan-e-spoiler." .. choice.key}
end

-- One line of hers: a secret (rarely), a glimpse of memory, a lesson or a joke.
local pick = function(data, player)
  local roll = math.random()
  if player.mod_settings[shared.settings.spoilers].value and game.tick - (data.last_spoiler or -spoiler_gap) >= spoiler_gap
    and roll < 0.08 then
    local message = pick_spoiler(data)
    if message then
      data.last_spoiler = game.tick
      speech.say(data, message, {mood = "surprised", ticks = 600})
      return true
    end
  end
  if roll < 0.2 then
    speech.say(data, {"nan-e-glitch." .. math.random(glitches)}, {mood = "glitch"})
  elseif roll < 0.6 then
    data.lesson = (data.lesson or 0) % lessons + 1
    speech.say(data, {"nan-e-lesson." .. data.lesson}, {mood = "stern"})
  else
    local joke = math.random(jokes)
    if joke == data.last_joke then
      joke = joke % jokes + 1
    end
    data.last_joke = joke
    speech.say(data, {"nan-e-joke." .. joke}, {mood = "happy"})
  end
  return true
end

-- Her own line, when it is time. Returns whether she said something.
chatter.think = function(data, player)
  if game.tick < (data.next_chatter or 0) then return false end
  chatter.schedule(data, player)
  if not chatter.allowed(data, player) then return false end
  return pick(data, player)
end

-- "Say something": asked for, she answers whatever her settings.
chatter.talk = function(data, player)
  return pick(data, player)
end

-- A line on an occasion (night, rain, research...): only when she may talk, and not too often per key.
chatter.occasion = function(data, player, key, message, mood, cooldown)
  if not chatter.allowed(data, player) then return false end
  if not speech.ready(data, key, cooldown or 20 * minute) then return false end
  speech.say(data, message, {mood = mood})
  return true
end

return chatter
