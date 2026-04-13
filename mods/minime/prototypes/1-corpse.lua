minime.entered_file()

------------------------------------------------------------------------------------
-- Define generic character corpse.
-- If a player used a character from a mod that was removed later on, both the
-- character and its corpse will be removed from the game. Thus, players will lose
-- all items they were carrying when they died. We should place a generic corpse in
-- that case, so we can restore removed corpses.
local corpse = table.deepcopy(data.raw["character-corpse"]["character-corpse"])
corpse.name = minime.modName.."_generic_corpse"
corpse.pictures = {
  layers = {
    {
      filename = minime.IMG_PATH.."generic_corpse_variations.png",
      --~ size = 1024,
      size = 256,
      shift = {0, 0},
      --~ scale = 0.0625,
      scale = 0.25,
      frame_count = 4,
      usage = "player",
    },
    {
      filename = minime.IMG_PATH.."generic_corpse_variations_mask.png",
      --~ size = 1024,
      size = 256,
      shift = {0, 0},
      --~ scale = 0.0625,
      scale = 0.25,
      frame_count = 4,
      usage = "player",
      apply_runtime_tint = true,
    },
  }
}
--~ corpse.armor_picture_mapping = {
  --~ ["heavy-armor"] = 1,
  --~ ["light-armor"] = 1,
  --~ ["modular-armor"] = 1,
  --~ ["power-armor"] = 1,
  --~ ["power-armor-mk2"] = 1
--~ }


data:extend({corpse})
minime.created_msg(corpse)
--~ minime.show("corpse", corpse)
minime.show('data.raw["character-corpse"]["character-corpse"].pictures',
            data.raw["character-corpse"]["character-corpse"].pictures)
minime.show("corpse.pictures", data.raw["character-corpse"][corpse.name].pictures)
--~ error("Break!")

------------------------------------------------------------------------------------
minime.entered_file("leave")
