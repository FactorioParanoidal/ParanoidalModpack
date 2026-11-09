local rro = Muluna.rro

local Public = {}

local spawn_distance = 128

local cargo_drop_radius = settings.startup["muluna-balance-fulgoran-cargo-drop-radius"].value
local item_multiplier = settings.startup["muluna-balance-fulgoran-cargo-drop-item-multiplier"].value


local modded_cargo_drop_spawns_imports = Muluna.constants.cargo_drop_spawn_imports
local modded_cargo_drop_spawns = {}
 
for _,import in pairs(modded_cargo_drop_spawns_imports) do
    local imported = require(import)
    if type(imported[1]) == "table" then
        for _,entry in pairs(imported) do
            table.insert(modded_cargo_drop_spawns,entry)
        end
    else
        table.insert(modded_cargo_drop_spawns,imported)
    end
    
end

local function random_place(surface,item_name,item_count)
    -- FIXED FOR FACTORIO 2.0: Check for item existence via prototypes.item
    if not prototypes.item[item_name] then return end
    
    local item_count_adjusted = item_count * item_multiplier
    local x = math.random(-cargo_drop_radius,cargo_drop_radius)+math.random(-cargo_drop_radius,cargo_drop_radius)
    local y = math.random(-cargo_drop_radius,cargo_drop_radius)+math.random(-cargo_drop_radius,cargo_drop_radius)
    local entity = {name = "fulgoran-cargo-pod-container", position = {x,y}, force = "player"}
    if surface.can_place_entity(entity) == false then
        entity.position[1] = entity.position[1] + math.random(-8,8)
        entity.position[2] = entity.position[2] + math.random(-8,8) 
    end
    local chest = surface.create_entity(entity)
    local amount = math.floor(item_count_adjusted) or 1
    if amount <= 0 then amount = 1 end
    chest.get_output_inventory().insert({name = item_name,count = amount})
end

local function random_place_entity(surface,entity_name)

    local x = math.random(-cargo_drop_radius,cargo_drop_radius)+math.random(-cargo_drop_radius,cargo_drop_radius)
    local y = math.random(-cargo_drop_radius,cargo_drop_radius)+math.random(-cargo_drop_radius,cargo_drop_radius)
    local entity = {name = entity_name, position = {x,y}, force = "player"}
    if surface.can_place_entity(entity) == false then
        entity.position[1] = entity.position[1] + math.random(-8,8)
        entity.position[2] = entity.position[2] + math.random(-8,8)
    end
    surface.create_entity(entity)
    --chest.get_output_inventory().insert({name = entity,count = 1})
end

local function place_muluna_cargo_pods() 

    -- game.print("Muluna created")
    local muluna = game.planets["muluna"].surface
        
    
    for _,spawn in pairs(modded_cargo_drop_spawns) do
        for i = 1,spawn.pod_count() do
            -- FIXED FOR FACTORIO 2.0: Safe validation via prototypes.item
            if prototypes.item[spawn.item] then
                random_place(muluna,spawn.item,spawn.item_quantity())
            else
                -- FIXED: Replaced non-existent item with spawn.item to prevent print from crashing
                print("Warning: Muluna tried to spawn item ".. tostring(spawn.item) ..", but it was removed by another mod.")
            end
        end
    end
    local mods = script.active_mods
    local mod_list = Muluna.constants.cargo_drop_rare_drops --A bunch of items from various mods to make it seem like many years ago, an ancient Fulgoran ship dropped a bunch of cargo in this area.
        
    
    for mod,item in pairs(mod_list) do
        if mods[mod] and math.random(1,10)>3 then
            if prototypes.get_item_filtered{{filter = "name",name = item}} then
                random_place(muluna,item,math.random(2,5)+math.random(2,5))
            else
                print("Warning: Muluna tried to spawn item ".. item ..", but it was removed by another mod. Check prototypes.mod_data.cargo_drop_rare_drops")
            end
            -- for i = 1,1 do
            --     random_place(muluna,item,math.random(2,5)+math.random(2,5))
            -- end
        end
    end
    if mods["moshine"] then
        
    end


    
    local random_chance_table = {
        {"foundry",2,1},
        {"electromagnetic-plant",4,1},
        {"big-mining-drill",6,math.random(1,3)+math.random(1,3)},
        {"cryogenic-plant",7,1},

    }
    if prototypes.space_location["maraxsis"] then
        table.insert(random_chance_table,{"maraxsis-hydro-plant",8,1})
    end
    for i = 1,2 do 
        local dice_roll = math.random(1,200)
        for _,item in pairs(random_chance_table) do
            if dice_roll<= item[2] then
                random_place(muluna,item[1],item[3])
                break
            end
        end
    end
    -- for i = 1,10 do
        --     random_place(muluna,"accumulator")
        -- end

        -- local chests = muluna.find_entities_filtered{name = "cargo-pod-container"}

        -- --if spaceship[1] then spaceship = spaceship[1] else spaceship = nil end

        -- for _,chest in pairs(chests) do
        --     chest.get_output_inventory().insert({name = "wood",count = 25})
        -- end


end

function Public.on_new_surface(muluna_index)
-- 3 crushers
-- 10 solar panels
-- 10 medium poles
-- 10 accumulators
-- game.print(muluna_index)
-- if game.planets["muluna"].surface then
--     game.print(game.planets["muluna"].surface.index)
-- end

    if game.planets["muluna"].surface and game.planets["muluna"].surface.index == muluna_index then
        local surface = game.planets["muluna"].surface
        surface.wind_speed = 0
        surface.wind_orientation = 0
        surface.wind_orientation_change = 0
        if settings.startup["muluna-hardcore-remove-starting-cargo-pods"].value == true then 
            if settings.startup["aps-planet"] and settings.startup["aps-planet"].value == "muluna" then
                game.print({"console.muluna-incompatible-aps-setting"})
            end
        end
        
        if settings.startup["muluna-hardcore-remove-starting-cargo-pods"].value == false then
            place_muluna_cargo_pods()  
        end
        local muluna = game.planets["muluna"].surface
        for i = 1,10 do
            random_place_entity(muluna,"lunar-rock")
        end


        
        
        
    end




end

return Public
