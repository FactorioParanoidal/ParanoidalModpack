local copy_modules_into = require("functions/copy_modules_into")
local process_blueprint = require("functions/process_blueprint")

--- EVENTS ---

script.on_event({ defines.events.on_entity_settings_pasted },
  function(event)
    local player = game.players[event.player_index]

    -- check if functionality is enabled
    if not player or not player.mod_settings["kajacx_copy-paste-modules_enable"].value then
      return -- do nothing
    end

    local source_inventory = event.source and event.source.get_module_inventory()
    local target = event.destination
    if not source_inventory or not target then
      return
    end

    copy_modules_into(source_inventory, target, player, true, player.mod_settings["kajacx_copy-paste-modules_enable-request"].value)
  end
)

script.on_event({ defines.events.on_pre_build },
  function(event)
    local player = game.players[event.player_index]

    -- check if functionality is enabled
    if not player or not player.mod_settings["kajacx_copy-paste-modules_enable-blueprint"].value then
      return -- do nothing
    end

    local blueprint_item = player.cursor_stack
    while blueprint_item and blueprint_item.is_blueprint_book do
      local items = blueprint_item.get_inventory(defines.inventory.item_main)
      if not blueprint_item.active_index or blueprint_item.active_index > #items then
        return -- this should never happen, but return anyway to be sure that nothing goes wrong
      end
      blueprint_item = items[blueprint_item.active_index]
    end
    if not blueprint_item or not blueprint_item.is_blueprint or not blueprint_item.is_blueprint_setup() then
      -- player doesn't hold blueprint in their hand - nothing to do
      return
    end

    if blueprint_item.blueprint_snap_to_grid ~= nil then
      -- TODO: implement calculations when spanning in the next version
      return
    end

    local original_entities = blueprint_item.get_blueprint_entities()
    if not original_entities then
      -- blueprint has no entities - probably a tiles only blueprint
      return
    end

    local blueprint_entities = process_blueprint(original_entities, event)

    for _,entity in pairs(blueprint_entities) do
      local found_entities = player.surface.find_entities_filtered({
        area = {
          { entity.position.x - 0.01, entity.position.y - 0.01 },
          { entity.position.x + 0.01, entity.position.y + 0.01 }
        },
        name = entity.name,
        force = player.force,
        directon = entity.direction
      })
      if #found_entities > 0 then
        copy_modules_into(entity.modules, found_entities[1], player, false, true)
      end
    end
  end
)
