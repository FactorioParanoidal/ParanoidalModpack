local bounding_box = require("__flib__.bounding-box")
local gui = require("__flib__.gui")
local math = require("__flib__.math")
local table = require("__flib__.table")

local constants = require("constants")

local database = require("scripts.database")
local formatter = require("scripts.formatter")

local gui_util = {}

-- The calling GUI will navigate to the context that is returned, if any
-- Actions that do not open a page will not return a context
function gui_util.navigate_to(e)
  local tags = gui.get_tags(e.element)
  local context = tags.context

  local modifiers = {}
  for name, modifier in pairs({ control = e.control, shift = e.shift, alt = e.alt }) do
    if modifier then
      modifiers[#modifiers + 1] = name
    end
  end

  for _, interaction in pairs(constants.interactions[context.class]) do
    if table.deep_compare(interaction.modifiers, modifiers) then
      local action = interaction.action
      local context_data = database[context.class][context.name]
      local player = game.get_player(e.player_index) --[[@as LuaPlayer]]

      if action == "view_details" then
        return context
      elseif action == "view_product_details" and #context_data.products == 1 then
        return context_data.products[1]
      elseif action == "get_blueprint" then
        local blueprint_result = tags.blueprint_result
        if blueprint_result then
          local cursor_stack = player.cursor_stack
          player.clear_cursor()
          if cursor_stack and cursor_stack.valid then
            local collision_box = game.entity_prototypes[blueprint_result.name].collision_box
            local height = bounding_box.height(collision_box)
            local width = bounding_box.width(collision_box)
            cursor_stack.set_stack({ name = "blueprint", count = 1 })
            cursor_stack.set_blueprint_entities({
              {
                entity_number = 1,
                name = blueprint_result.name,
                position = {
                  -- Entities with an even number of tiles to a side need to be set at -0.5 instead of 0
                  math.ceil(width) % 2 == 0 and -0.5 or 0,
                  math.ceil(height) % 2 == 0 and -0.5 or 0,
                },
                recipe = blueprint_result.recipe,
              },
            })
            player.add_to_clipboard(cursor_stack)
            player.activate_paste()
          end
        else
          player.create_local_flying_text({
            text = { "message.rb-cannot-create-blueprint" },
            create_at_cursor = true,
          })
          player.play_sound({ path = "utility/cannot_build" })
        end
      elseif action == "open_in_technology_window" then
        local player_table = global.players[e.player_index]
        player_table.flags.technology_gui_open = true
        player.open_technology_gui(context.name)
      elseif action == "view_source" then
        local source = context_data[interaction.source]
        if source then
          return source
        end
      end
    end
  end
end

function gui_util.update_list_box(pane, source_tbl, player_data, iterator, options)
  local i = 0
  local children = pane.children
  local add = pane.add
  for _, obj_ident in iterator(source_tbl) do
    local obj_data = database[obj_ident.class][obj_ident.name]
    local info = formatter(obj_data, player_data, options)
    if info then
      i = i + 1
      local style = info.researched and "rb_list_box_item" or "rb_unresearched_list_box_item"
      local item = children[i]
      if item then
        item.style = style
        item.caption = info.caption
        item.tooltip = info.tooltip
        item.enabled = info.num_interactions > 0
        gui.update_tags(item, { context = { class = obj_ident.class, name = obj_ident.name } })
      else
        add({
          type = "button",
          style = style,
          caption = info.caption,
          tooltip = info.tooltip,
          enabled = info.num_interactions > 0,
          mouse_button_filter = { "left", "middle" },
          tags = {
            [script.mod_name] = {
              context = { class = obj_ident.class, name = obj_ident.name },
              flib = {
                on_click = { gui = "search", action = "open_object" },
              },
            },
          },
        })
      end
    end
  end
  -- Destroy extraneous items
  for j = i + 1, #children do
    children[j].destroy()
  end
end

return gui_util
