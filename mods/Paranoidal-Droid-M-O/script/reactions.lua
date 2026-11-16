-- How Д-ОК shows what he's doing: his voice, his scanner's labels and his siren. Voice and labels respect each
-- player's settings; the siren is part of him and everyone sees it.
local shared = require("shared")

local reactions = {}

local geometry = shared.graphics[settings.startup[shared.settings.graphics].value] or shared.graphics.own
-- Screen offset of the top of his head (45 degree projection), where the siren rises.
local siren_offset = {0, -geometry.head_top * 0.7071 - 0.02}
local label_offset = {0, -geometry.head_top * 0.7071 - 0.35}

reactions.colours =
{
  alarm = {1, 0.28, 0.22},
  clean = {0.45, 1, 0.5},
  note = {1, 1, 1},
  warn = {1, 0.85, 0.25}
}

-- Per player: {voice = bool, texts = bool}, read from the settings when first wanted.
local player_settings = {}

local get_player_settings = function(player)
  local cached = player_settings[player.index]
  if cached then return cached end
  local mod_settings = player.mod_settings
  cached =
  {
    voice = mod_settings[shared.settings.voice].value,
    texts = mod_settings[shared.settings.texts].value
  }
  player_settings[player.index] = cached
  return cached
end

reactions.forget_player = function(player_index)
  player_settings[player_index] = nil
end

-- Players on a surface who want a thing (voice or texts).
local listeners = function(surface_index, what)
  local list
  for _, player in pairs(game.connected_players) do
    if player.surface_index == surface_index and get_player_settings(player)[what] then
      list = list or {}
      list[#list + 1] = player
    end
  end
  return list
end

-- Cooldowns per bot and sound, so a busy bot doesn't chatter: ticks.
local cooldowns =
{
  [shared.sounds.grumble] = 60 * 5,
  [shared.sounds.huh] = 60 * 4,
  [shared.sounds.yelp] = 60 * 2,
  [shared.sounds.scan] = 60,
  [shared.sounds.warble] = 60 * 6,
  [shared.sounds.pickup] = 20,
  [shared.sounds.clank] = 20
}

-- data: the dock's record (its bot is the speaker). Returns whether it spoke.
reactions.say = function(data, sound, position)
  local bot = data.bot
  if not (bot and bot.valid) then return false end
  local wait = cooldowns[sound]
  if wait then
    data.said = data.said or {}
    local last = data.said[sound]
    if last and game.tick - last < wait then return false end
    data.said[sound] = game.tick
  end
  local players = listeners(bot.surface_index, "voice")
  if not players then return true end
  position = position or bot.position
  for _, player in pairs(players) do
    player.play_sound{path = sound, position = position}
  end
  return true
end

-- A label from his scanner: over an entity (with an offset) or at a position. Short-lived.
reactions.label = function(surface, target, text, colour, ticks, offset)
  local players = listeners(surface.index, "texts")
  if not players then return end
  local render_target = target
  if type(target) == "userdata" then
    render_target = {entity = target, offset = offset or label_offset}
  elseif offset then
    render_target = {x = target.x + offset[1], y = target.y + offset[2]}
  end
  rendering.draw_text
  {
    text = text,
    surface = surface,
    target = render_target,
    color = colour,
    scale = 0.85,
    font = "default-game",
    alignment = "center",
    vertical_alignment = "bottom",
    time_to_live = ticks or 120,
    players = players,
    use_rich_text = true
  }
end

-- Over his head.
reactions.label_bot = function(data, text, colour, ticks)
  local bot = data.bot
  if not (bot and bot.valid) then return end
  reactions.label(bot.surface, bot, text, colour, ticks)
end

-- The siren rises for a while (or until lowered), turning and flashing red.
reactions.siren_up = function(data, ticks)
  local bot = data.bot
  if not (bot and bot.valid) then return end
  reactions.siren_down(data)
  data.siren =
  {
    rendering.draw_animation
    {
      animation = shared.siren,
      target = {entity = bot, offset = siren_offset},
      surface = bot.surface,
      render_layer = "object",
      animation_speed = 0.4,
      time_to_live = ticks
    },
    rendering.draw_light
    {
      sprite = "utility/light_small",
      target = {entity = bot, offset = siren_offset},
      surface = bot.surface,
      color = {1, 0.15, 0.1},
      intensity = 0.7,
      scale = 0.9,
      minimum_darkness = 0,
      blink_interval = 12,
      time_to_live = ticks
    }
  }
end

reactions.siren_down = function(data)
  if not data.siren then return end
  for _, object in pairs(data.siren) do
    if object.valid then
      object.destroy()
    end
  end
  data.siren = nil
end

reactions.on_setting_changed = function(event)
  if event.setting == shared.settings.voice or event.setting == shared.settings.texts then
    if event.player_index then
      player_settings[event.player_index] = nil
    else
      player_settings = {}
    end
  end
end

return reactions
