--[[
if bobmods.config.plates.CheaperSteel then
	-- Ignore cheaper steel setting
	data.raw.recipe["steel-plate"].energy_required = 27.5
	data.raw.recipe["steel-plate"].ingredients  = {{"iron-plate", 10}}
end
]]