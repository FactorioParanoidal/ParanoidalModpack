-- How she talks: a text bubble over her head (only her player sees it), a face on her screen (everyone sees it: it is
-- her body), her babble (only her player hears it) and a line in her journal. Everything respects the player's
-- settings; important lines go to the chat when she is switched off.
local shared = require("shared")

local speech = {}

local look = settings.startup[shared.settings.look].value
local L = shared.looks[look] or shared.looks.own
local bubble_offset = {0, -L.head_top - 0.1}
local journal_size = 60

speech.colours =
{
  neutral = {1, 1, 1},
  happy = {1, 0.8, 0.9},
  worried = {1, 0.9, 0.5},
  surprised = {0.85, 0.95, 1},
  stern = {1, 0.62, 0.55},
  sleepy = {0.75, 0.8, 0.95},
  glitch = {0.6, 1, 0.95}
}

-- Called after every line (the window refreshes its journal page); set by script/gui.lua.
speech.on_said = nil

local setting = function(player, name)
  return player.mod_settings[name].value
end

speech.clear = function(data)
  if not data.bubble then return end
  for _, object in pairs(data.bubble) do
    if object.valid then
      object.destroy()
    end
  end
  data.bubble = nil
end

-- A cooldown per key and nanny: true (and the key is marked) when the line may be said now.
speech.ready = function(data, key, ticks)
  data.said = data.said or {}
  local last = data.said[key]
  if last and game.tick - last < ticks then return false end
  data.said[key] = game.tick
  return true
end

-- message: a LocalisedString. opts: mood, ticks (bubble time), sound (instead of the mood's), chat (also to the chat),
-- silent (no voice).
speech.say = function(data, message, opts)
  opts = opts or {}
  local player = game.get_player(data.player_index)
  if not player then return end
  local mood = opts.mood or "neutral"
  local journal = data.journal
  journal[#journal + 1] = {game.tick, message, mood}
  while #journal > journal_size do
    table.remove(journal, 1)
  end
  local unit = data.unit
  local online = unit and unit.valid
  if online then
    speech.clear(data)
    local ttl = opts.ticks or 420
    local objects =
    {
      rendering.draw_text
      {
        text = message,
        surface = unit.surface,
        target = {entity = unit, offset = bubble_offset},
        color = speech.colours[mood] or speech.colours.neutral,
        scale = 1.1,
        font = "default-game",
        alignment = "center",
        vertical_alignment = "bottom",
        time_to_live = ttl,
        players = {player},
        use_rich_text = true
      }
    }
    if look == "own" then
      objects[2] = rendering.draw_sprite
      {
        sprite = shared.sprite.face .. mood,
        surface = unit.surface,
        target = unit,
        time_to_live = ttl,
        render_layer = "higher-object-under"
      }
    end
    data.bubble = objects
    if not opts.silent and setting(player, shared.settings.voice) then
      player.play_sound{path = opts.sound or shared.sounds[mood] or shared.sounds.chatter, position = unit.position}
    end
  end
  if opts.chat or not online or setting(player, shared.settings.chat) then
    player.print({"", "[item=" .. shared.item .. "] ", {"nan-e.name"}, ": ", message},
      {color = {1, 0.82, 0.9}, sound = defines.print_sound.never})
  end
  if speech.on_said then
    speech.on_said(player)
  end
end

-- A sound at her position, for her player only. Her tunes follow the voice setting; machine noises (machine = true)
-- are part of the world and always play.
speech.sound = function(data, path, machine)
  local player = game.get_player(data.player_index)
  local unit = data.unit
  if not (player and unit and unit.valid) then return end
  if machine or setting(player, shared.settings.voice) then
    player.play_sound{path = path, position = unit.position}
  end
end

return speech
