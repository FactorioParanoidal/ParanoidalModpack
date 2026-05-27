-- 1.1 source: zzzparanoidal/prototypes/micro-final-fix.lua (AKMF block).

if not mods["holographic_signs"] then return end

require("__zzzparanoidal__.paralib")

if data.raw.recipe["hs_holo_sign"] then
	data.raw.recipe["hs_holo_sign"].enabled = false
	paralib.bobmods.lib.tech.add_recipe_unlock("circuit-network", "hs_holo_sign")
end
