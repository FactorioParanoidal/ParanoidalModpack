-- Run with --test-scenario Paranoidal-Protomolecule-Beast/generator-regression.
script.on_event(defines.events.on_tick, function()
  local count = 0
  for name in pairs(prototypes.entity) do
    local source = name:match("^beast%-dynamo%-(.+)$")
    if source and prototypes.entity[source] and prototypes.entity[source].type == "generator" then
      local entity = assert(game.surfaces.nauvis.create_entity({
        name = name, position = { count * 16, 200 }, force = "enemy",
      }), "Generator creature must be creatable: " .. name)
      assert(entity.valid and entity.type == "spider-unit", name)
      count = count + 1
    end
  end
  assert(prototypes.entity["beast-dynamo-steam-engine"], "Steam engine creature must be retained")
  assert(count >= 1, "Exercise at least the vanilla steam engine")
  log("PASS: Created " .. count .. " generator creatures from Factorio 2.1 pictures")
  script.finish_test()
end)
