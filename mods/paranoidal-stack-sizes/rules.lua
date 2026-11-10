-- Resolve precedence in a virtual plan; mutate each existing item at most once, at the end.
local C = require("__paranoidal-stack-sizes__/config")
local M = {}

function M.apply(raw, item_types, active_mods, startup, triggers, snapshot, requests)
    local plan, keys = {}, {}
    for kind in pairs(item_types) do
        for name, item in pairs(raw[kind] or {}) do
            local key = kind .. "/" .. name
            plan[key] = {kind = kind, name = name, item = item, size = item.stack_size, source = "declared"}
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    local function setting(name)
        return startup[name] and startup[name].value
    end
    local function set(kind, name, size, source, action)
        local entry = plan[kind .. "/" .. name]
        if not entry then return end -- Optional integrations may refer to absent prototypes.
        assert(type(size) == "number" and size >= 1 and size % 1 == 0, "Invalid stack rule: " .. source)
        if action == "minimum" then size = math.max(entry.size, size)
        elseif action == "maximum" then size = math.min(entry.size, size) end
        entry.size, entry.source = size, source
    end
    local function triggered(spec)
        if not spec then return true end
        local part, material = spec:match("^([^:]+):(.+)$")
        if part == "ore" then return triggers.ores and triggers.ores[material] end
        local products = triggers.smelting_products and triggers.smelting_products[material]
        return products and products[part]
    end
    local function groups(list)
        for _, rule in ipairs(list) do
            if (not rule.mod or active_mods[rule.mod])
                and (not rule.also_mod or active_mods[rule.also_mod])
                and (not rule.setting or setting(rule.setting)) and triggered(rule.trigger) then
                local size = rule.initial and C.initial_size(rule.initial, startup) or rule.size
                for _, name in ipairs(rule.names) do
                    set(rule.kind or "item", name, size, rule.source, rule.action)
                end
            end
        end
    end

    groups(C.pre)
    for _, request in pairs(requests) do
        set(request.kind, request.name, request.size, request.source, "minimum")
    end
    if active_mods.Bio_Industries_2 then
        if setting("BI_Game_Tweaks_Stack_Size") then
            local five_dim = setting("5d-change-stack")
            for name, tweak in pairs(C.bi.tweaks) do
                if five_dim == 1 or not five_dim then
                    set("item", name, tweak.minimum, "bi-minimum", "minimum")
                end
                if active_mods["space-exploration"] then
                    set("item", name, tweak.se_limit, "bi-se-limit", "maximum")
                end
            end
        end
        if active_mods["space-exploration"] then
            for _, name in ipairs(C.bi.se_items) do set("item", name, C.bi.se_size, "bi-se-items") end
            if not active_mods.Natural_Evolution_Buildings then
                for _, name in ipairs(C.bi.se_ammo) do set("ammo", name, C.bi.se_size, "bi-se-ammo") end
            end
        end
    end
    groups(C.early)

    -- Retain the historical selection boundary, including zero = keep the prior rule/default.
    if C.categories["barrel-stack"] > 0 then
        for name in pairs(snapshot.barrels) do
            set("item", name, C.categories["barrel-stack"], "restack-barrel")
        end
    end
    for _, key in ipairs(keys) do
        local entry = plan[key]
        local selected = snapshot.categories[entry.name]
        if selected and selected.stack_size > 0 then
            local not_stackable = false
            for _, flag in pairs(entry.item.flags or {}) do
                if flag == "not-stackable" then not_stackable = true break end
            end
            if not not_stackable then
                set(entry.kind, entry.name, selected.stack_size, "restack-" .. selected.type)
            end
        end
    end
    for name, size in pairs(C.module_items) do
        for _, kind in ipairs({"item", "module", "tool"}) do set(kind, name, size, "modules-beta8") end
    end
    for name, size in pairs(C.created_ammo) do set("ammo", name, size, "created-ammo") end
    for size, names in pairs(C.ammo) do
        for name in pairs(names) do set("ammo", name, size, "ammo-beta8") end
    end
    groups(C.energy)
    for _, rule in ipairs(C.inherited_defaults) do
        local entry = plan[rule.kind .. "/" .. rule.name]
        if entry and entry.source == "declared" then
            local parent = assert(plan[rule.kind .. "/" .. rule.parent], "Missing stack-size parent: " .. rule.parent)
            set(rule.kind, rule.name, parent.size, "inherited-" .. rule.parent)
        end
    end
    groups(C.exceptions)

    local changed, sources, audit = 0, {}, {}
    for _, key in ipairs(keys) do
        local entry = plan[key]
        for _, flag in pairs(entry.item.flags or {}) do
            assert(flag ~= "not-stackable" or entry.size == 1, "Non-stackable item has a stack rule: " .. key)
        end
        assert(entry.size >= 1 and entry.size % 1 == 0, "Invalid declared stack size: " .. key)
        if entry.item.stack_size ~= entry.size then
            entry.item.stack_size = entry.size
            changed = changed + 1
        end
        sources[entry.source] = (sources[entry.source] or 0) + 1
        audit[key] = {stack_size = entry.size, source = entry.source}
        local launch = snapshot.launch_products[entry.name]
        local selected = snapshot.categories[entry.name]
        if launch and selected and selected.stack_size > 0 and launch > entry.size then
            local silo = raw["rocket-silo"] and raw["rocket-silo"]["rocket-silo"]
            if silo and silo.rocket_result_inventory_size then
                silo.rocket_result_inventory_size = math.max(silo.rocket_result_inventory_size, math.ceil(launch / entry.size))
            end
        end
    end
    return {count = #keys, changed = changed, sources = sources, items = audit}
end
return M
