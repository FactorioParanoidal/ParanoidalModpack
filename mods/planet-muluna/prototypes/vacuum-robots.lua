local rro = Muluna.rro
-- for _,robot_name in pairs(Muluna.constants.robot_names) do
--     local replacement_name = "muluna-burner-" .. robot_name
--     local recipe = table.deepcopy(data.raw["recipe"][robot_name])
--     local robot = table.deepcopy(data.raw[robot_name][robot_name])
--     local item = table.deepcopy(data.raw["item"][robot_name])
--     local prototypes = {recipe,robot,item}
--     for _,prototype in pairs(prototypes) do
--         rro.deep_replace(prototype,robot_name,replacement_name,false,{"type"})
--         if prototype.type == "construction-robot" or prototype.type == "logistic-robot" then
--             prototype.surface_conditions = {
--                 {
--                     property = "gravity",
--                     max = 2,
--                     min = 2,
--                 }
--             }
--         end
--         if prototype.type == "recipe" then
--             rro.replace(prototype.ingredients,{type = "item" , name = "flying-robot-frame", amount = "_any"},
--                                                 {type = "item" , name = "muluna-burner-flying-robot-frame", amount = 1})
            
--         end
--     end

--     Muluna:extend(prototypes)
    
-- end

Muluna:extend {
    -- rro.merge(data.raw["item"]["flying-robot-frame"],{
    --     type = "item",
    --     name = "muluna-burner-flying-robot-frame",
        
    -- }),
    rro.merge(data.raw["item"]["roboport"],{
        type = "item",
        name = "muluna-burner-roboport",
        place_result = "muluna-burner-roboport",
        order = data.raw["item"]["roboport"].order .. "a",
        icon = "__muluna-graphics__/graphics/icons/burner-roboport.png",
    }),
    -- rro.merge(data.raw["recipe"]["flying-robot-frame"],{
    --     type = "recipe",
    --     name = "muluna-burner-flying-robot-frame",
    --     ingredients = {
    --         {type = "item", name = "steel-plate",  amount = 1},
    --         {type = "item", name = "pipe",  amount = 2},
    --         {type = "item", name = "electronic-circuit",  amount = 3},
    --         {type = "item", name = "engine-unit",  amount = 1}
        
    --     },
    --     results = {{type = "item", name = "muluna-burner-flying-robot-frame", amount = 1}},
    -- }),
    rro.merge(data.raw["recipe"]["roboport"],{
        type = "recipe",
        name = "muluna-burner-roboport",
        ingredients = {
            {type = "item", name = "electronic-circuit",  amount = 45},
            {type = "item", name = "steel-plate",  amount = 45},
            {type = "item", name = "iron-gear-wheel",  amount = 45},
            {type = "item", name = "pipe",  amount = 45},
            --{type = "item", name = "engine-unit",  amount = 1}
        
        },
        results = {{type = "item", name = "muluna-burner-roboport", amount = 1}},
        
    }),
} 