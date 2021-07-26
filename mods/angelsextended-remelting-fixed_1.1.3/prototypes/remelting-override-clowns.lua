local OV = angelsmods.functions.OV

if settings.startup["remelting-smooth-integration"].value then
	--MAGNESIUM
	OV.add_unlock("advanced-magnesium-smelting", "molten-magnesium-remelting")
else
	--MAGNESIUM
	OV.add_unlock("remelting-tier-2", "molten-magnesium-remelting")
end