local rro = require("lib.remove-replace-object")
if rro.deep_equals(storage.telescopes, {}) then
       for _,surface in pairs(game.surfaces) do
        print("searching for telescopes on " .. surface.name)
        local telescopes = surface.find_entities_filtered{name = "muluna-telescope"}
            for _,telescope in pairs(telescopes) do
                local position = telescope.position
                if telescope.unit_number and not storage.telescopes[telescope.unit_number] then
                    local combinators = surface.find_entities_filtered{position = {position.x,position.y }, name = "muluna-telescope-combinator"}
                    local combinator = combinators[1]
                    storage.telescopes[telescope.unit_number] = {
                        ["assembling-machine"] = telescope,
                        ["constant-combinator"] = combinator,
                        ["constant-combinator-control-behavior"] = combinator.get_control_behavior()
                    }
                end
            end
        end 
    end