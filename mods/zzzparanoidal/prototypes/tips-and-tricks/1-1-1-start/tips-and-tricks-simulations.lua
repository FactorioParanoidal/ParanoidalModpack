--симуляции, очень сложная но веселая вещь, подробнее тут https://wiki.factorio.com/Types/SimulationDefinition
local simulations = {}

simulations.introduction = {
    init = [[
    game.camera_position = { -2.5, 1 }
game.camera_zoom = 2
game.camera_alt_info = true


--recipe
rendering.draw_sprite({
  sprite = "tips-and-tricks-start",
  target = { -5.5, 1.8 },
  surface = game.surfaces[1],
})
  ]]
}

return simulations