-- Paranoidal fork (see data.lua). The upstream detection of modded categories to treat like vanilla ones (setting
-- module-category-defaults-dynamic, hidden here) is not used: every module category of the build is a default one.

-- Module categories that machines without their own list do not get: restricted_categories and the categories of the
-- planet mods that no mod put into default_categories.
function ModuleCategoryDefaults.restricted()
    local default, restricted = {}, {}
    for _, name in pairs(ModuleCategoryDefaults.default_categories) do default[name] = true end
    for _, name in pairs(ModuleCategoryDefaults.restricted_categories) do restricted[name] = true end
    local filter = data.paranoidal_space_age_filter
    if filter and filter.is_space_age then
        for name, category in pairs(data.raw["module-category"] or {}) do
            if filter.is_space_age(category) and not default[name] then restricted[name] = true end
        end
    end
    return restricted
end

-- Every module category of the build except the restricted ones (sorted) and the restricted ones present; nil when
-- none of them exists: then a machine without a list already allows exactly the categories it would get.
function ModuleCategoryDefaults.paranoidal_defaults()
    local restricted = ModuleCategoryDefaults.restricted()
    local list, present = {}, {}
    for name in pairs(data.raw["module-category"] or {}) do
        if restricted[name] then present[#present + 1] = name else list[#list + 1] = name end
    end
    if #present == 0 then return nil end
    table.sort(list)
    table.sort(present)
    return list, present
end

function ModuleCategoryDefaults.get_default_categories(type_group)
    local list = ModuleCategoryDefaults.paranoidal_defaults()
    if list then return list end
    list = {}
    for name in pairs(data.raw["module-category"] or {}) do list[#list + 1] = name end
    table.sort(list)
    return list
end

-- Only prototypes without a list get one; explicit lists of other mods stay as they are.
function ModuleCategoryDefaults.process_prototypes(moduled_type)
    local defaults = ModuleCategoryDefaults.paranoidal_defaults()
    if not defaults then return 0 end
    ModuleCategoryDefaults.processed_prototypes[moduled_type] = ModuleCategoryDefaults.processed_prototypes[moduled_type] or {}
    local count = 0
    for name, moduled_prototype in pairs(data.raw[moduled_type] or {}) do
        if not moduled_prototype.allowed_module_categories then
            moduled_prototype.allowed_module_categories = table.deepcopy(defaults)
            count = count + 1
        end
        ModuleCategoryDefaults.processed_prototypes[moduled_type][name] = true
    end
    return count
end

function ModuleCategoryDefaults.process_entity_prototypes()
    local _, restricted = ModuleCategoryDefaults.paranoidal_defaults()
    local count = 0
    for _, moduled_type in pairs(ModuleCategoryDefaults.moduled_types) do
        count = count + ModuleCategoryDefaults.process_prototypes(moduled_type)
    end
    log("module-category-defaults (Paranoidal): restricted categories: "
        .. (restricted and table.concat(restricted, ", ") or "none, nothing changed")
        .. "; machines given the build's other categories: " .. count)
end

function ModuleCategoryDefaults.process_recipe_prototypes()
    return ModuleCategoryDefaults.process_prototypes("recipe")
end
