local globals = require("globals")

local upgrade_planner_converter = {}

upgrade_planner_converter.to_upgrade_planner =
    function(stack, config, player)
      local entities = game.entity_prototypes
      local items = game.item_prototypes
      stack.set_stack{name = "upgrade-planner"}
      local idx = 1
      for _, entry in pairs(config) do
        local entity_from = entities[entry.from]
        local entity_to = entities[entry.to]
        local item_from = items[entry.from]
        local item_to = items[entry.to]
        if entity_from and entity_from.fast_replaceable_group then
          stack.set_mapper(idx, "from",
                           {type = "entity", name = entity_from.name})
        elseif item_from and item_from.type == "module" then
          stack.set_mapper(idx, "from", {type = "item", name = item_from.name})
        end

        if entity_to and entity_to.fast_replaceable_group then
          if entity_from then
            if entity_from.fast_replaceable_group ==
                entity_to.fast_replaceable_group then
              stack.set_mapper(idx, "to",
                               {type = "entity", name = entity_to.name})
            else
              player.print({
                "upgrade-planner.partial-upgrade-planner-export",
                entity_from.localised_name, entity_to.localised_name,
              })
              stack.set_mapper(idx, "from", nil)
            end
          else
            stack.set_mapper(idx, "to", {type = "entity", name = entity_to.name})
          end
        elseif item_to and item_to.type == "module" then
          stack.set_mapper(idx, "to", {type = "item", name = item_to.name})
        end
        idx = idx + 1
      end
    end

upgrade_planner_converter.from_upgrade_planner =
    function(stack)
      local config = {}
      for i = 1, globals.MAX_CONFIG_SIZE, 1 do
        local from = stack.get_mapper(i, "from").name or ""
        local to = stack.get_mapper(i, "to").name or ""

        config[i] = {from = from, to = to}
      end

      return config
    end

return upgrade_planner_converter
