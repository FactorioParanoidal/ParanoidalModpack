-- EditorExtensionsCheats related functionality
local EditorExtensionsCheats = {}

EditorExtensionsCheats.name = "ee_cheat_mode"
function EditorExtensionsCheats.enabled()
    return not not remote.interfaces[EditorExtensionsCheats.name]
end

-- Enables EE's Recipes for a Force
---@param force LuaForce
function EditorExtensionsCheats.EnableTestingRecipes(force)
    if not EditorExtensionsCheats.enabled() then
        return false
    end
    return remote.call(EditorExtensionsCheats.name, "enable_testing_recipes", force)
end

-- Disables EE's Recipes for a Force
---@param force LuaForce
function EditorExtensionsCheats.DisableTestingRecipes(force)
    if not EditorExtensionsCheats.enabled() then
        return false
    end
    return remote.call(EditorExtensionsCheats.name, "disable_testing_recipes", force)
end

return EditorExtensionsCheats
