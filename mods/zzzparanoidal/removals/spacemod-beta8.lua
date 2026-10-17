-- Beta 8: нет лазерных пушек и четвёртого этапа корабля.
-- Требования runtime исключены отдельным документированным патчем SpaceMod.
-- Прототипы оставляем для ссылок стороннего кода; получение закрыто в новой игре.
if not mods["SpaceModFeorasFork"] then return end

for _, name in ipairs({
	"laser-cannon", "exploration-satellite", "space-ai-robots", "space-fluid-tanks", "space-cartography",
}) do
	local technology = data.raw.technology[name]
	if technology and technology.max_level ~= "infinite" then
		technology.hidden = true
		technology.enabled = false
	end
end

for _, name in ipairs({
	"laser-cannon", "exploration-satellite", "exploration-data-disk", "space-ai-robot",
	"space-ai-robot-frame", "space-water-tank", "space-oxygen-tank", "space-fuel-tank",
	"space-oxygen-barrel", "space-map",
}) do
	local recipe = data.raw.recipe[name]
	if recipe then
		recipe.enabled = false
		recipe.hidden = true
		recipe.hide_from_player_crafting = true
	end
	local item = data.raw.item[name]
	if item then item.hidden = true end
end
