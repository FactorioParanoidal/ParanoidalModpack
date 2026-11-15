-- paranoidal-true-nukes в дереве сборки (решение пользователя 2026-11-15, испытания по варианту «А»):
-- «Атомная бомба» остаётся обычным исследованием сборки (цена и предшественники Beta 8 из rcu-consumers-beta8),
-- «Простое атомное оружие» становится её предшественником: без этого оно было тупиковой веткой.
if not mods["paranoidal-true-nukes"] then return end
require("__zzzparanoidal__.paralib")
paralib.bobmods.lib.tech.add_prerequisite("atomic-bomb", "basic-atomic-weapons")
