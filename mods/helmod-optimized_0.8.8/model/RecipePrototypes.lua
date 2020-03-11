local RecipePrototypes = {classname = "HMRecipePrototypes"}

RecipePrototypes.recipe = {}
RecipePrototypes.resource = {}
RecipePrototypes.fluid = {}
RecipePrototypes.technology = {}

function RecipePrototypes.load(object, object_type)
    local object_name = nil
    is_voider = nil
    if type(object) == "string" then
        object_name = object
        lua_type = object_type
    elseif object.name ~= nil then
        object_name = object.name
        lua_type = object_type or object.type
    end

    if
        lua_type == "recipe" and RecipePrototypes[lua_type][object_name] ~= nil and
            RecipePrototypes[lua_type][object_name].enabled
     then
        return
    elseif RecipePrototypes[lua_type][object_name] ~= nil then
        return
    end

    if lua_type == nil or lua_type == "recipe" then
        RecipePrototypes.recipe[object_name] = Player.getRecipe(object_name)
        lua_type = "recipe"
    elseif lua_type == "resource" then
        RecipePrototypes.resource[object_name] = Player.getEntityPrototype(object_name)
    elseif lua_type == "fluid" then
        RecipePrototypes.fluid[object_name] = Player.getFluidPrototype(object_name)
    elseif lua_type == "technology" then
        RecipePrototypes.technology[object_name] = Player.getTechnology(object_name)
    end
    if RecipePrototypes[type] == nil or RecipePrototypes[type][name] == nil then
        RecipePrototypes.find(object)
    -- if object_name == "acidgas" then
    --     game.print(object_name)
    --     game.print(object_type)
    -- end
    end
end

function RecipePrototypes.find(object)
    local object_name = nil
    if type(object) == "string" then
        object_name = object
    elseif object.name ~= nil then
        object_name = object.name
    end
    local lua_prototype = Player.getRecipe(object_name)
    local lua_type = "recipe"
    if lua_prototype == nil then
        lua_prototype = Player.getTechnology(object_name)
        lua_type = "technology"
    end
    if lua_prototype == nil then
        lua_prototype = Player.getEntityPrototype(object_name)
        lua_type = "resource"
    end
    if lua_prototype == nil then
        lua_prototype = Player.getFluidPrototype(object_name)
        lua_type = "fluid"
    end
    RecipePrototypes[lua_type][object_name] = lua_prototype
end

function RecipePrototypes.native(name, type)
    return RecipePrototypes[type][name]
end

function RecipePrototypes.getEnabled(name, type)
    if RecipePrototypes.recipe[name] ~= nil then
        if type == "recipe" then
            return RecipePrototypes.recipe[name].enabled
        elseif type == "resource" then
            return true
        elseif type == "fluid" then
            return true
        elseif type == "technology" then
            return true
        end
    end
    return true
end

function RecipePrototypes.getHidden(name, type)
    if RecipePrototypes.recipe[name] ~= nil then
        if type == "recipe" then
            return RecipePrototypes.recipe[name].hidden
        elseif type == "resource" then
            return false
        elseif type == "fluid" then
            return false
        elseif type == "technology" then
            return false
        end
    end
    return false
end

function RecipePrototypes.getRawProducts(name, type)
    local lua_prototype = nil
    if RecipePrototypes[type] ~= nil and RecipePrototypes[type][name] ~= nil then
        lua_prototype = RecipePrototypes[type][name]
    end
    if lua_prototype ~= nil then
        if lua_type == "recipe" then
            return lua_prototype.products
        elseif lua_type == "resource" then
            return EntityPrototype.load(lua_prototype).getMineableMiningProducts()
        elseif lua_type == "fluid" then
            return {{name = lua_prototype.name, type = "fluid", amount = 1}}
        elseif lua_type == "technology" then
            return {{name = lua_prototype.name, type = "technology", amount = 1}}
        end
    end
    return {}
end

function RecipePrototypes.getProducts(name, type)
    local raw_products = RecipePrototypes.getRawProducts(name, type)
    -- if recipe is a voider
    if #raw_products == 1 and Product.getElementAmount(raw_products[1]) == 0 then
        is_voider = true
        return {}
    else
        is_voider = false
    end
    local lua_products = {}
    for r, raw_product in pairs(RecipePrototypes.getRawProducts(name, type)) do
        local product_id = raw_product.type .. "/" .. raw_product.name
        if lua_products[product_id] ~= nil then
            -- make a new product table for the combined result
            -- combine product amounts, averaging in variable and probabilistic outputs
            local amount_a = Product.getElementAmount(lua_products[product_id])
            local amount_b = Product.getElementAmount(raw_product)
            lua_products[product_id] = {type = raw_product.type, name = raw_product.name, amount = amount_a + amount_b}
        else
            lua_products[product_id] = raw_product
        end
    end
    -- convert map to array
    local raw_products = {}
    for _, lua_product in pairs(lua_products) do
        table.insert(raw_products, lua_product)
    end

    return raw_products
end

-- arg factory
function RecipePrototypes.getIngredients(name, type)
    local lua_prototype = RecipePrototypes[type][name]
    local lua_type = type
    if lua_prototype ~= nil then
        if lua_type == "recipe" then
            return lua_prototype.ingredients
        elseif lua_type == "resource" then
            local ingredients = {{name = lua_prototype.name, type = "item", amount = 1}}
            -- ajouter le liquide obligatoire, s'il y en a
            if EntityPrototype.load(lua_prototype).getMineableMiningFluidRequired() then
                local fluid_ingredient = {
                    name = EntityPrototype.getMineableMiningFluidRequired(),
                    type = "fluid",
                    amount = EntityPrototype.getMineableMiningFluidAmount()
                }
                table.insert(ingredients, fluid_ingredient)
            end
            -- computing burner
            -- @see https://wiki.factorio.com/Fuel
            -- Burn time (s) = Fuel value (MJ) � Energy consumption (MW)
            -- source energy en kJ
            local energy_coal = 25000000
            local energy_coal = 8000000
            local hardness = EntityPrototype.getMineableHardness()
            local mining_time = EntityPrototype.getMineableMiningTime()

            EntityPrototype.load(factory)
            if factory ~= nil and EntityPrototype.getEnergyType() == "burner" then
                local energy_usage = EntityPrototype.getEnergyUsage()
                local burner_effectivity = EntityPrototype.getBurnerEffectivity()
                local mining_speed = EntityPrototype.getMiningSpeed()
                local mining_power = EntityPrototype.getMiningPower()

                local speed_factory = (mining_power - hardness) * mining_speed / mining_time
                local fuel_value = energy_usage * speed_factory * 12.5
                local burner_count = fuel_value / energy_coal
                local burner_ingredient = {name = "coal", type = "item", amount = burner_count}

                table.insert(ingredients, burner_ingredient)
            end
            return ingredients
        elseif lua_type == "fluid" then
            if lua_prototype.name == "steam" then
                EntityPrototype.load(factory)
                if factory ~= nil and EntityPrototype.getEnergyType() == "burner" then
                    -- source energy en kJ
                    local energy_coal = 8000000
                    local power_extract = EntityPrototype.getPowerExtract()
                    local amount = power_extract / (energy_coal * EntityPrototype.getBurnerEffectivity())
                    return {
                        {name = "water", type = "fluid", amount = 1},
                        {name = "coal", type = "item", amount = amount}
                    }
                else
                    return {{name = "water", type = "fluid", amount = 1}}
                end
            end
            return {{name = lua_prototype.name, type = "fluid", amount = 1}}
        elseif lua_type == "technology" then
            return lua_prototype.research_unit_ingredients
        end
    end
    return {}
end

return RecipePrototypes
