---
---Description of the module.
---@class RemoteAPI
local RemoteAPI = {
  ---single-line comment
  classname = "HMRemoteAPI"
}

-------------------------------------------------------------------------------
---Expose
function RemoteAPI.expose()
    remote.add_interface("helmod_interface", {
        get_models = function() return storage.models end,
        get_recipe = function(recipe)
            recipe.products = {}
            recipe.ingredients = {}
            local prototype = RecipePrototype(recipe)
            for _, lua_product in pairs(prototype:getQualityProducts(recipe.factory, recipe.quality)) do
                local product_prototype = Product(lua_product)
                local product = product_prototype:clone()
				product.count = product_prototype:countProduct(recipe)
				product.count_limit = product_prototype:countLimitProduct(recipe)
				product.count_deep = product_prototype:countDeepProduct(recipe)
                table.insert(recipe.products, product)
            end
            for _, lua_ingredient in pairs(prototype:getQualityIngredients(recipe.factory, recipe.quality)) do
                local ingredient_prototype = Product(lua_ingredient)
                local ingredient = ingredient_prototype:clone()
				ingredient.count = ingredient_prototype:countIngredient(recipe)
				ingredient.count_limit = ingredient_prototype:countLimitIngredient(recipe)
				ingredient.count_deep = ingredient_prototype:countDeepIngredient(recipe)
                table.insert(recipe.ingredients, ingredient)
            end
            return recipe
        end
    })
end

RemoteAPI.expose()

-- Available only to the isolated local regression mod, never in a normal game.
if script.active_mods["pd-port21-diag"] then
    local ModelImport = require("data.ModelImport")
    local function import_for_player(index, text, model_id, block_id)
        local previous = Player.native()
        Player.set(game.get_player(index))
        local data, reason = ModelImport.read(text, model_id == nil)
        local model
        if data then
            if model_id then
                local target = storage.models and storage.models[model_id]
                local block = target and (target.blocks[block_id] or target.block_root)
                model, reason = ModelImport.paste(target, block, data)
            else
                model, reason = ModelImport.newModel(data)
            end
        end
        Player.set(previous)
        return model, reason
    end
    local EventController = require("controller.EventController")
    local function find_action(element, action)
        if element.name:find(action, 1, true) then return element end
        for _, child in pairs(element.children) do
            local found = find_action(child, action)
            if found then return found end
        end
    end
    local function gui_for_player(index, model_id, action, text)
        local previous = Player.native()
        Player.set(game.get_player(index))
        local ok, result = pcall(function()
            local event = {player_index = index, item1 = model_id, item2 = "download"}
            local production = action == "paste" or action == "production"
            local classname = production and "HMProductionPanel" or "HMDownload"
            if production then event.item2 = nil end
            if action == "paste" then User.setParameter("copy_past", text) end
            Controller:send("on_gui_open", event, classname)
            local view = Controller:getView(classname)
            local panel = view:getPanel()
            if action == "submit" then
                view:getFramePanel("download")["data-text"].text = text
            end
            if action ~= "open" and action ~= "production" then
                local button = assert(find_action(panel, action == "paste" and "past-block" or "download-model"))
                EventController.onGuiClickButton({player_index = index, element = button,
                    button = defines.mouse_button_type.left, tick = game.tick})
            end
            return panel.valid
        end)
        Player.set(previous)
        assert(ok, result)
        return result
    end
    remote.add_interface("helmod-import-test", {apply = import_for_player, gui = gui_for_player})
end