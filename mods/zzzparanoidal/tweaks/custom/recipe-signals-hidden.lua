-- Окно выбора сигнала (комбинаторы, Cybersyn и др.) — как фильтр манипулятора: без рецептов.
-- По умолчанию движок 2.0 показывает рецепт сигналом, если его иконка отличается от иконок
-- предметов/жидкостей/виртуальных сигналов; у Angels/Bob это почти все альтернативные рецепты.
-- hide_from_signal_gui прячет рецепт только из окна выбора; сам рецепт и крафт не меняются.
if settings.startup["paranoidal-recipe-signals-visible"].value then return end

for _, recipe in pairs(data.raw.recipe) do
	recipe.hide_from_signal_gui = true
end
