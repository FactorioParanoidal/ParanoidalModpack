
local function on_shortcut_pressed(event)
  if event.prototype_name and event.prototype_name ~= "search-factory" then return end
  local player = game.get_player(event.player_index)

  local player_data = global.players[event.player_index]
  Gui.toggle(player, player_data)
end
event.on_lua_shortcut(on_shortcut_pressed)
script.on_event("search-factory", on_shortcut_pressed)


script.on_event("open-search-prototype",
  function(event)
    local player = game.get_player(event.player_index)
    local player_data = global.players[event.player_index]
    if event.selected_prototype then
      local name = event.selected_prototype.name
      local type

      if name == "entity-ghost" or name == "tile-ghost" then
        -- selected_prototype doesn't specify which ghost it is
        local ghost = player.selected
        if ghost and (ghost.name == "entity-ghost" or ghost.name == "tile-ghost") then
          name = ghost.ghost_name
        end
      end
      if event.selected_prototype.derived_type == "resource" then
        -- If we know it is a resource, then ensure we treat it as one first
        local products = game.entity_prototypes[name].mineable_properties.products
        if products then
          name = products[1].name
          type = products[1].type
        end
      elseif game.item_prototypes[name] then
        type = "item"
      elseif game.fluid_prototypes[name] then
        type = "fluid"
      elseif game.virtual_signal_prototypes[name] then
        type = "virtual"
      elseif game.recipe_prototypes[name] then
        local recipe = game.recipe_prototypes[name]
        local main_product = recipe.main_product
        if main_product then
          name = main_product.name
          type = main_product.type
        elseif #recipe.products == 1 then
          local product = recipe.products[1]
          name = product.name
          type = product.type
        end
      elseif game.entity_prototypes[name] then
        local entity = game.entity_prototypes[name]
        local items_to_place_this = entity.items_to_place_this
        if items_to_place_this and items_to_place_this[1] then
          name = items_to_place_this[1].name
          type = "item"
        end
        local mineable_properties = entity.mineable_properties
        if mineable_properties then
          local products = mineable_properties.products
          if products then
            name = products[1].name
            type = products[1].type
          end
        end
      elseif game.tile_prototypes[name] then
        local tile = game.tile_prototypes[name]
        local items_to_place_this = tile.items_to_place_this
        if items_to_place_this and items_to_place_this[1] then
          name = items_to_place_this[1].name
          type = "item"
        end
      end
      if not type then
        player.play_sound{path = "utility/cannot_build"}
        player.create_local_flying_text{text = { "search-gui.invalid-item" }, create_at_cursor = true}
        return
      end
      Gui.open(player, player_data)
      player_data = global.players[event.player_index]
      local refs = player_data.refs
      refs.item_select.elem_value = {type = type, name = name}
      Gui.start_search(player, player_data)
    end
  end
)