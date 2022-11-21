local controlScript = require("control-script")
data.raw["utility-constants"]["default"].main_menu_simulations.nuke_1x1kt =
  {
    checkboard = false,
    save = "__True-Nukes__/menu-simulations/menu-simulation-artillery-nuke.zip",
    length = 60 * 20,
    init =

    [[
    local logo = game.surfaces.nauvis.find_entities_filtered{name = "factorio-logo-11tiles", limit = 1}[1]
    game.camera_position = {logo.position.x, logo.position.y+9.75}
    game.camera_zoom = 1
    game.tick_paused = false
  ]] .. controlScript
  }















