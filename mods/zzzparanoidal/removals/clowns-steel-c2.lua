require("__zzzparanoidal__.paralib")
-- В 1.1 Clowns-Processing/prototypes/recipes/angels-smelting.lua оборачивал
-- molten-iron-smelting-6 и molten-steel-smelting-c2 в if/else: первый — для
-- bobplates / angelsindustries-overhaul, второй — fallback "magnesium sink"
-- для vanilla. При порте на 2.0 if/else потерян, обе ветки теперь
-- добавляются всегда. В нашей сборке bobplates грузится, поэтому c2
-- избыточен и создаёт коллизию метки "2" с angels-liquid-molten-steel-2.

if
	(mods["bobplates"] or (mods["angelsindustries"] and angelsmods.industries.overhaul))
	and data.raw.recipe["molten-steel-smelting-c2"]
then
	paralib.bobmods.lib.recipe.hide("molten-steel-smelting-c2")
end
