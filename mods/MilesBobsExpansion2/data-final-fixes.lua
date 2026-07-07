require "util"

-- 2.0: графика electronics-4/5. Своя (assembling-machine-2.png) была со старыми 1.1-размерами
-- → в 2.0 текстура кривая. Наследуем graphics_set рабочей bob-electronics-machine-3 (футпринт
-- совпадает). Делаем в data-final-fixes, чтобы захватить уже перекрашенную reskins-bobs
-- версию (reskins рескинит электронику в data-updates). Маску красим под тир:
-- продолжаем палитру тиров bob (1 красный, 2 фиолет, 3 оранж): 4 зелёный, 5 голубой.
for _, spec in ipairs({
	{ "electronics-machine-4", { r = 0.3,  g = 0.9,  b = 0.35 } },
	{ "electronics-machine-5", { r = 0.25, g = 0.75, b = 1    } },
}) do
	local e = data.raw["assembling-machine"][spec[1]]
	local base = data.raw["assembling-machine"]["bob-electronics-machine-3"]
	if e and base and base.graphics_set then
		e.graphics_set = table.deepcopy(base.graphics_set)
		e.animation = nil
		for _, layer in ipairs(e.graphics_set.animation.layers or {}) do
			if layer.tint then layer.tint = spec[2] end
		end
	end
end
