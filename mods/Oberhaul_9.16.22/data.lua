if not settings.startup["angels-ores-only"].value then
    angelsmods.refining.disable_ore_override = true;
end

data.raw["roboport"]["roboport"].close_door_trigger_effect =nil
--[[
 {
  {
    sound = {
      filename = "__base__/sound/roboport-door.ogg",
      volume = 0
    },
    type = "play-sound"
  }
}
]]--
data.raw["roboport"]["roboport"].open_door_trigger_effect =nil
--[[
 {
  {
    sound = {
      filename = "__base__/sound/roboport-door.ogg",
      volume = 0
    },
    type = "play-sound"
  }
}
]]--