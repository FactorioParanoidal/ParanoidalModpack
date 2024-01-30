--[[function make_composite_icon_rb(icon1, icon2, icon_size1, icon_size2, icon_mipmaps1, icon_mipmaps2, tint1, tint2)
return {
	{icon=icon1,icon_size = icon_size1 or 64, icon_mipmaps = icon_mipmaps1 or 4, tint=tint1},
	{icon=icon2,icon_size = icon_size2 or 64, icon_mipmaps = icon_mipmaps2 or 4, tint=tint2,priority="medium",shift={8,8},scale=0.3}}
end

local rp_ico = "__base__/graphics/icons/repair-pack.png"
icons_rsc    = make_composite_icon_rb("__base__/graphics/icons/rocket-silo.png",rp_ico)
icons_se_crs = rp_ico
icons_se_sp = rp_ico

if data.raw.item['se-rocket-launch-pad'] then
	icons_se_crs = make_composite_icon_rb(data.raw.item['se-rocket-launch-pad'].icon, rp_ico, 
		data.raw.item['se-rocket-launch-pad'].icon_size)
	
	icons_se_sp = make_composite_icon_rb(data.raw.item['se-space-probe-rocket-silo'].icon, rp_ico, 
		data.raw.item['se-space-probe-rocket-silo'].icon_size)
	end
]]-- -- snouz made custom icons





local ICONPATH = "__Rocket-Silo-Construction__/graphics/icon/"

local rp_ico = "__base__/graphics/icons/repair-pack.png"
icons_rsc = {{icon = ICONPATH .. "rocket_silo_construction.png", icon_size = 64, icon_mipmaps = 3}}

icons_se_crs = rp_ico
icons_se_sp = rp_ico
if data.raw.item['se-rocket-launch-pad'] then
	icons_se_crs = {{icon = ICONPATH .. "se-rocket-launch-pad.png", icon_size = 64, icon_mipmaps = 3}}
	icons_se_sp = {{icon = ICONPATH .. "se-space-probe-rocket-silo.png", icon_size = 64, icon_mipmaps = 3}}
end



require ("prototypes.recipe-categories")
require ("prototypes.recipe")
require ("prototypes.item")
require ("prototypes.entities")
