
--[[
--from
data.raw.ammo["firearm-magazine"].type = "ammo"
data.raw.ammo["firearm-magazine"].name = "firearm-magazine"
data.raw.ammo["firearm-magazine"].icon = "__base__/graphics/icons/firearm-magazine.png"
data.raw.ammo["firearm-magazine"].icon_size = 64
data.raw.ammo["firearm-magazine"].icon_mipmaps = 4
data.raw.ammo["firearm-magazine"].ammo_type.category = "bullet"
data.raw.ammo["firearm-magazine"].ammo_type.action[1].type = "direct"
data.raw.ammo["firearm-magazine"].ammo_type.action[1].action_delivery[1].type = "instant"
data.raw.ammo["firearm-magazine"].ammo_type.action[1].action_delivery[1].source_effects[1] = {type = "create-explosion", entity_name = "explosion-gunshot"}
data.raw.ammo["firearm-magazine"].ammo_type.action[1].action_delivery[1].target_effects[1].type = "create-entity"
data.raw.ammo["firearm-magazine"].ammo_type.action[1].action_delivery[1].target_effects[1].entity_name = "explosion-hit"
data.raw.ammo["firearm-magazine"].ammo_type.action[1].action_delivery[1].target_effects[1].offsets[1] = {0, 1}
data.raw.ammo["firearm-magazine"].ammo_type.action[1].action_delivery[1].target_effects[1].offset_deviation[1] = {-0.5, -0.5}
data.raw.ammo["firearm-magazine"].ammo_type.action[1].action_delivery[1].target_effects[1].offset_deviation[2] = {0.5, 0.5}
data.raw.ammo["firearm-magazine"].ammo_type.action[1].action_delivery[1].target_effects[2].type = "damage"
data.raw.ammo["firearm-magazine"].ammo_type.action[1].action_delivery[1].target_effects[2].damage = {amount = 5, type = "physical"}
data.raw.ammo["firearm-magazine"].magazine_size = 10
data.raw.ammo["firearm-magazine"].subgroup = "ammo"
data.raw.ammo["firearm-magazine"].order = "a[basic-clips]-a[firearm-magazine]"
data.raw.ammo["firearm-magazine"].stack_size = 200

--to
data.raw.item.stone.type = "item"
data.raw.item.stone.name = "stone"
data.raw.item.stone.icon = "__base__/graphics/icons/stone.png"
data.raw.item.stone.icon_size = 64
data.raw.item.stone.icon_mipmaps = 4
data.raw.item.stone.pictures[1] = {size = 64, filename = "__base__/graphics/icons/stone.png", scale = 0.25, mipmap_count = 4}
data.raw.item.stone.pictures[2] = {size = 64, filename = "__base__/graphics/icons/stone-1.png", scale = 0.25, mipmap_count = 4}
data.raw.item.stone.pictures[3] = {size = 64, filename = "__base__/graphics/icons/stone-2.png", scale = 0.25, mipmap_count = 4}
data.raw.item.stone.pictures[4] = {size = 64, filename = "__base__/graphics/icons/stone-3.png", scale = 0.25, mipmap_count = 4}
data.raw.item.stone.subgroup = "raw-resource"
data.raw.item.stone.order = "d[stone]"
data.raw.item.stone.stack_size = 50

--]]


local stone = data.raw.item.stone
data.raw.item.stone = nil
local ammo_stone = table.deepcopy (data.raw.ammo["firearm-magazine"])


stone.type = ammo_stone.type
stone.ammo_type = ammo_stone.ammo_type
stone.magazine_size = ammo_stone.magazine_size
stone.subgroup = ammo_stone.subgroup
stone.ammo_type.action[1].action_delivery[1].target_effects[2].damage = {amount = 1, type = "physical"}

data:extend({stone})