local tech_archive = require("src.tech-archive")

script.on_event(defines.events.on_player_created, function(event)
  tech_archive:on_player_created()
end)

script.on_event(defines.events.on_pre_player_died, function(event)
  tech_archive:on_pre_player_died(event.player_index)
end)

script.on_event(defines.events.on_player_respawned, function(event)
  tech_archive:on_player_respawned(event.player_index)
end)

-- Include both the archives themselves and every carrier checked by tech_archive.
local archive_death_filters = {
  { filter = "type", type = "container" },
  { filter = "type", type = "logistic-container" },
  { filter = "type", type = "construction-robot" },
  { filter = "type", type = "logistic-robot" },
}
for _, name in pairs(tech_archive.main_lab) do
  archive_death_filters[#archive_death_filters + 1] = { filter = "name", name = name }
end
script.on_event(defines.events.on_entity_died, function(event)
  tech_archive:on_entity_died(event.entity)
end, archive_death_filters)
