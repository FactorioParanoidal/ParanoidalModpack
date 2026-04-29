require("__zzzparanoidal__.paralib")
-- Скрываем пустую теху "Средняя опора ЛЭП" (medium-electric-pole) от aai-industry.
-- Теха определена в aai-industry/prototypes/phase-1/technology/technology.lua без effects,
-- а её наполнение (tech_lock_recipes("medium-electric-pole", {"medium-electric-pole"}) и
-- перенос рецепта с vanilla-теха electric-energy-distribution-1) лежит в
-- aai-industry/prototypes/phase-2/technology/technology.lua, который НИГДЕ не require()-ится.
-- При портировании на 2.0 авторы убрали require("phase-2/...") из data*.lua, но саму теху
-- из phase-1 оставили. В итоге теха пустая, рецепт medium-electric-pole штатно открывается
-- через electric-energy-distribution-1, а игрок видит дубль с пустым "Результатом".
--
-- Условный фикс — три кейса для hide:
--   1) tech.effects == nil — исходный баг без research_evolution_factor;
--   2) tech.effects == {} — пустой массив на тот же случай;
--   3) tech.effects == [{type="nothing"}] — research_evolution_factor добавляет
--      такой декоративный модификатор в каждую не-hidden теху для своей механики
--      эволюции (рендерится как красный "+"). К моменту нашей проверки у пустой
--      теха ровно один такой "nothing".
-- Любой реальный эффект (например unlock-recipe) — оставляем теху видимой:
-- если/когда aai-industry починит загрузку phase-2 и эффект появится, hide
-- перестанет срабатывать без ручных правок.

local tech = data.raw.technology["medium-electric-pole"]
if
	tech
	and (
		not tech.effects
		or #tech.effects == 0
		or (#tech.effects == 1 and tech.effects[1].type == "nothing")
	)
then
	paralib.bobmods.lib.tech.hide("medium-electric-pole")
end
