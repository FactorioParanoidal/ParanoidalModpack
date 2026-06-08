--local mod_gui = require("mod-gui")
--local playercolor = game.players[event.player_index].color

ICONPATH = "__RPGsystem__/graphics/"

local attributesList = {
  "LV_Health_Bonus",
  "LV_Armor_Bonus",
  "LV_Damage_Bonus",
  "LV_Damage_Critical",
  "LV_Run_Speed",
  "LV_Magic",
  "LV_Craft_Speed",
  "LV_Mining_Speed",
  "LV_Inv_Bonus",
  "LV_InvTrash_Bonus",
  "LV_Robot_Bonus",
  "LV_Reach_Dist",  
}

function createSprite(att)
  local p = {}
  p.type = "sprite"
  p.name = att .. "_sprite"
  p.filename = ICONPATH .. att .. "_icon.png"
  --p.priority = "extra-high-no-scale"
  p.width = 128
  p.height = 128
  p.scale = 0.5

  data:extend({p})
end

for a=1,#attributesList do
  createSprite(attributesList[a])
end


data:extend({
    {
    type = "sprite",
    name = "charxpmod_space_suit",
    layers = {
      {
        filename = ICONPATH .. "rpg_portrait_bg.png",
        width = 110,
        height = 110,
      },
      {
        filename = ICONPATH .. "rpg_portrait.png",
        width = 110,
        height = 110,
      },
      {
        filename = ICONPATH .. "rpg_portrait_mask.png",
        apply_runtime_tint = true,
        width = 110,
        height = 110,
      },
    }
  },
})
