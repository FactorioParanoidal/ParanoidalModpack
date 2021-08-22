if data.raw['item']['engine-unit'] then
	data.raw['item']['engine-unit'].icon = "__aai-industry__/graphics/icons/engine-unit.png"
	data.raw['item']['engine-unit'].icon_size = 64
	data.raw['item']['engine-unit'].icon_mipmaps = 1
	--[[data.raw['item']['engine-unit'].icons = {
    {
      icon = "__aai-industry__/graphics/icons/engine-unit-base.png"
    },
    {
      icon = "__aai-industry__/graphics/icons/engine-unit-mask.png",
      tint = { r = 1, g = 0, b = 0}
    }
  } ]]--
	data.raw['item']['engine-unit'].order = "g[engine-unit]-c[engine-unit]"
end

if data.raw['item']['electric-engine-unit'] then
	data.raw['item']['electric-engine-unit'].icon = "__aai-industry__/graphics/icons/electric-engine-unit.png"
	data.raw['item']['electric-engine-unit'].icon_size = 64
	data.raw['item']['electric-engine-unit'].icon_mipmaps = 1
	--[[data.raw['item']['electric-engine-unit'].icons = {
    {
      icon = "__aai-industry__/graphics/icons/electric-engine-unit-base.png"
    },
    {
      icon = "__aai-industry__/graphics/icons/electric-engine-unit-mask.png",
      tint = { r = 0, g = 1, b = 0.1}
    }
  }]]--
	data.raw['item']['electric-engine-unit'].order = "g[engine-unit]-d[engine-unit]"
end

-- bobs wooden board, now uses stone so call it insulating-board
--[[if data.raw['item']['wooden-board'] then
	data.raw['item']['wooden-board'].localised_name = { "basic-insulating-board"}
end
]]

--data.raw['item']["offshore-pump"].place_result = "offshore-pump"
--data.raw['item']["offshore-pump"].icon = "__aai-industry__/graphics/icons/offshore-pump.png"
--data.raw['item']["offshore-pump"].hidden = true

--data.raw.item["stone-wall"].icon = "__aai-industry__/graphics/icons/stone-wall.png"
--data.raw.item["stone-wall"].icon_size = 64
--data.raw.item["stone-wall"].icon_mipmaps = 1

data.raw.gun.pistol.attack_parameters.damage_modifier = 1.5
