local constants = require("__AbandonedRuins_updated_fork__/lua/constants")
local utils = require("__AbandonedRuins_updated_fork__/lua/utilities")
local spawning = require("__AbandonedRuins_updated_fork__/lua/spawning")

-- Enable debug log by default
settings.global[constants.ENABLE_DEBUG_LOG_KEY].value = true
debug_log = true

---@param center MapPosition
---@param half_size number
---@param surface LuaSurface
local function draw_dimensions(center, half_size, surface)
  rendering.draw_line(
  {
    from = {center.x + 0.5, center.y},
    to = {center.x - 0.5, center.y},
    width = 2,
    color = {b = 0.5, a = 0.5},
    surface = surface
  })
  rendering.draw_line(
  {
    from = {center.x, center.y + 0.5},
    to = {center.x, center.y - 0.5},
    width = 2,
    color = {b = 0.5, a = 0.5},
    surface = surface
  })
  rendering.draw_rectangle(
  {
    left_top = {center.x - half_size, center.y - half_size},
    right_bottom  = {center.x + half_size, center.y + half_size},
    filled = false,
    width = 2,
    color = {g = 0.3, a = 0.3},
    surface = surface
  })
end

script.on_init(function()
  -- Disable normal spawning
  remote.call("AbandonedRuins", "set_spawn_ruins", false)
end)


script.on_event(defines.events.on_player_created, function(event)
  -- This stuff is all here instead of on_init because this relies on other mods' on_init,
  --  which run after the scenario on_init, but before scenario on_player_created

  -- Set up the debug surface
  log(string.format("[on_player_created]: Loading %s='%s' ...", constants.CURRENT_RUIN_SET_KEY, settings.global[constants.CURRENT_RUIN_SET_KEY].value))
  local ruin_set = remote.call("AbandonedRuins", "get_current_ruin_set")
  log(string.format("[on_player_created]: ruin_set[]='%s'", type(ruin_set)))
  if ruin_set == nil then
    -- Issue notice
    utils.output_message("Abandoned Ruins: No ruins loaded! Will not create debug world.")
    return
  end

  local total_ruins_amount = #ruin_set.small + #ruin_set.medium + #ruin_set.large
  local chunk_radius = math.ceil(math.sqrt(total_ruins_amount) / 2)

  log(string.format("[on_player_created]: total_ruins_amount=%d,chunk_radius=%.2f", total_ruins_amount, chunk_radius))

  local surface = game.create_surface(constants.DEBUG_SURFACE_NAME, {
    width  = chunk_radius * 2 * 32,
    height = chunk_radius * 2 * 32,
    default_enable_all_autoplace_controls = false,
    property_expression_names = {
      elevation = 10
    }
  })

  -- skip invalid surfaces
  if not surface.valid then
    utils.output_message(string.format("Abandoned Ruins: Invalid surface created: '%s'", constants.DEBUG_SURFACE_NAME))
    log(string.format("WARNING: surface[]='%s',name='%s' is not valid - EXIT!", type(surface), constants.DEBUG_SURFACE_NAME))
    return
  end

  surface.request_to_generate_chunks({0, 0}, chunk_radius)
  surface.force_generate_chunk_requests()

  -- Spawn all ruins at once, small to big, top left to bottom right
  local x = -chunk_radius
  local y = -chunk_radius

  for size, ruin_list in pairs(ruin_set) do
    for _, ruin in pairs(ruin_list) do
      local center = utils.get_center_of_chunk({x = x, y = y})

      spawning.spawn_ruin(ruin, utils.ruin_half_sizes[size], center, surface)
      draw_dimensions(center, utils.ruin_half_sizes[size], surface)

      x = x + 1
      if (x >= chunk_radius) then
        x = -chunk_radius
        y = y + 1
      end
    end
  end

  -- Enable map editor for the player
  local player = game.get_player(event.player_index)
  player.toggle_map_editor()
  game.tick_paused = false
  player.teleport({0, 0}, constants.DEBUG_SURFACE_NAME)
  player.force = "neutral"
  player.game_view_settings.show_entity_info = true
end)
