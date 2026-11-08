-- Поворот стоящих турелей с сектором обстрела (controls/turret-rotate.lua): та же клавиша, что у
-- обычного поворота (R / Shift+R), своих клавиш нет.
data:extend({
	{type = "custom-input", name = "paranoidal-turret-rotate", key_sequence = "", linked_game_control = "rotate"},
	{type = "custom-input", name = "paranoidal-turret-reverse-rotate", key_sequence = "",
		linked_game_control = "reverse-rotate"},
})
