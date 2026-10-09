-- Широкий бур AAI отключён по решению пользователя; прототипы оставлены для сохранений.
local NAME = "area-mining-drill"
local function is_disabled(name)
    return name == NAME or name:sub(1, #NAME + 3) == NAME .. "___"
end

for _, kind in ipairs({ "item", "recipe", "technology", "mining-drill" }) do
    for name, prototype in pairs(data.raw[kind] or {}) do
        if is_disabled(name) then
            prototype.hidden = true
            if kind == "recipe" or kind == "technology" then prototype.enabled = false end
        end
    end
end

for _, technology in pairs(data.raw.technology or {}) do
    local effects = technology.effects or {}
    for index = #effects, 1, -1 do
        local effect = effects[index]
        if effect.type == "unlock-recipe" and is_disabled(effect.recipe) then
            table.remove(effects, index)
        end
    end
end
