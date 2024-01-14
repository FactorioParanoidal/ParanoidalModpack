-- EditorExtensionsCheats related functionality
local EditorExtensionsCheats = {}

EditorExtensionsCheats.name = "ee_cheat_mode"
EditorExtensionsCheats.enabled = not not remote.interfaces[EditorExtensionsCheats.name]

-- Enables EE's Recipes for a Force
function EditorExtensionsCheats.EnableTestingRecipes(force)
    if not EditorExtensionsCheats.enabled then
        return false
    end
    return remote.call(EditorExtensionsCheats.name, "enable_testing_recipes", force)
end

return EditorExtensionsCheats
