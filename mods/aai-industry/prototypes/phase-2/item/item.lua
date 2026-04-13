if data.raw['item']['engine-unit'] then
	data.raw['item']['engine-unit'].icon = "__aai-industry__/graphics/icons/multi-cylinder-engine.png"
	data.raw['item']['engine-unit'].icon_size = 64
	data.raw['item']['engine-unit'].order = "g[engine-unit]-a[engine]-b[big]"
end

if data.raw['item']['electric-engine-unit'] then
	data.raw['item']['electric-engine-unit'].icon = "__aai-industry__/graphics/icons/big-electric-motor.png"
	data.raw['item']['electric-engine-unit'].icon_size = 64
	data.raw['item']['electric-engine-unit'].order = "g[engine-unit]-b[motor]-b[big]"
end

-- bobs wooden board, now uses stone so call it insulating-board
if data.raw['item']['wooden-board'] then
	data.raw['item']['wooden-board'].localised_name = { "basic-insulating-board"}
end

data.raw.item["stone-wall"].icon = "__aai-industry__/graphics/icons/stone-wall.png"
data.raw.item["stone-wall"].icon_size = 64

data.raw.gun.pistol.attack_parameters.damage_modifier = 1.5

if data.raw.item["solid-sand"] then
	data.raw.item["solid-sand"].localised_name = {"item-name.washed-sand"}
end
