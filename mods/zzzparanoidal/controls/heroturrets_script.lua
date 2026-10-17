-- Разжалование турелей инструментом hero_downgrade (Beta 8): ранговая турель HeroTurretRedux
-- становится базовой, счёт убийств и урона начинается с нуля. Замену делает сам HeroTurretRedux
-- (интерфейс demote): сохраняются качество, патроны, провода, настройки сети и приоритеты целей.
local function on_selected_area(event)
	if event.item ~= "hero_downgrade" then return end
	local hero = remote.interfaces["HeroTurretRedux"]
	if not (hero and hero.demote) then return end
	local player = game.get_player(event.player_index)
	if not player then return end
	local force = player.force
	for _, entity in pairs(event.entities) do
		if entity.valid and entity.force == force then remote.call("HeroTurretRedux", "demote", entity) end
	end
end

script.on_event(defines.events.on_player_selected_area, on_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_selected_area)
