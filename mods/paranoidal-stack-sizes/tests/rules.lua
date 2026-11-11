-- Pure rule regression cases; run with Lua 5.2 from the repository root.
package.path = "mods/?.lua;" .. package.path
local prefix = "__paranoidal-stack-sizes__/"
package.preload[prefix .. "config"] = function() return require("paranoidal-stack-sizes.config") end
local rules = require("paranoidal-stack-sizes.rules")
local cases = 0
local function run(raw, mods, settings, snapshot, requests)
    return rules.apply(raw, {item = true, ammo = true, armor = true, ["rail-planner"] = true}, mods or {},
        settings or {}, {}, snapshot or {categories = {}, barrels = {}, launch_products = {}}, requests or {})
end
local function item(size, flags) return {stack_size = size, flags = flags} end

-- Precedence is resolved without any intermediate writes to the item prototype.
do
    local writes, size = 0, 50
    local coal = setmetatable({}, {__index = function(_, key) if key == "stack_size" then return size end end,
        __newindex = function(_, key, value) assert(key == "stack_size"); writes = writes + 1; size = value end})
    local raw = {item = {coal = coal, torch = item(64), ["stone-brick"] = item(100), ordinary = item(17)}}
    local audit = run(raw, {bobores = true, bobplates = true}, {}, {
        categories = {coal = {stack_size = 200, type = "ore"}, ["stone-brick"] = {stack_size = 500, type = "tile"}},
        barrels = {}, launch_products = {}})
    assert(coal.stack_size == 400 and writes == 1)
    assert(raw.item.torch.stack_size == 50 and raw.item["stone-brick"].stack_size == 500)
    assert(raw.item.ordinary.stack_size == 17 and audit.items["item/ordinary"].source == "declared")
    assert(audit.count == 4)
    cases = cases + 1
end

-- All item types, zero-category semantics and not-stackable remain distinct.
do
    local raw = {item = {barrel = item(10)}, ammo = {["artillery-shell"] = item(20)},
        armor = {["light-armor"] = item(1)}, ["rail-planner"] = {planner = item(1, {"not-stackable"})}}
    local audit = run(raw, {["ToxicPollution2-reforged"] = true}, {}, {
        categories = {barrel = {stack_size = 0, type = "container"}, planner = {stack_size = 200, type = "rail"}},
        barrels = {barrel = true}, launch_products = {}})
    assert(raw.item.barrel.stack_size == 5 and raw.ammo["artillery-shell"].stack_size == 10)
    assert(raw.armor["light-armor"].stack_size == 10 and raw["rail-planner"].planner.stack_size == 1)
    assert(audit.count == 4)
    cases = cases + 1
end

-- BI's toggles and optional SE limits stay conditional, including missing optional objects.
do
    local function fixture() return {item = {wood = item(100), stone = item(100), ["bi-seed"] = item(800)}, ammo = {}} end
    local raw = fixture()
    run(raw, {Bio_Industries_2 = true}, {["BI_Game_Tweaks_Stack_Size"] = {value = false}})
    assert(raw.item.wood.stack_size == 100)
    raw = fixture()
    run(raw, {Bio_Industries_2 = true}, {["BI_Game_Tweaks_Stack_Size"] = {value = true}, ["5d-change-stack"] = {value = 2}})
    assert(raw.item.wood.stack_size == 100)
    raw = fixture()
    run(raw, {Bio_Industries_2 = true, ["space-exploration"] = true}, {["BI_Game_Tweaks_Stack_Size"] = {value = true}})
    assert(raw.item.wood.stack_size == 200 and raw.item.stone.stack_size == 50 and raw.item["bi-seed"].stack_size == 200)
    cases = cases + 1
end

-- Derived WideChests area is a lower bound; it is not the number of inventory slots.
do
    local chest = item(50)
    chest.inventory_size = 48
    run({item = {["steel-chest"] = chest}}, {}, {}, nil,
        {chest = {kind = "item", name = "steel-chest", size = 256, source = "wide-chests-area"}})
    assert(chest.stack_size == 256 and chest.inventory_size == 48)
    cases = cases + 1
end
-- Late copies must inherit the effective parent instead of the untuned declaration.
do
    local raw = {armor = {["heavy-armor"] = item(1), ["heavy-armor-2"] = item(1), ["heavy-armor-3"] = item(1)},
        item = {["angels-electro-whinning-cell-2"] = item(10), ["angels-electro-whinning-cell-3"] = item(10)}}
    run(raw, {["ToxicPollution2-reforged"] = true}, {}, {
        categories = {["angels-electro-whinning-cell-2"] = {stack_size = 20, type = "crafting-machine"}},
        barrels = {}, launch_products = {}})
    assert(raw.armor["heavy-armor-2"].stack_size == 10 and raw.armor["heavy-armor-3"].stack_size == 10)
    assert(raw.item["angels-electro-whinning-cell-3"].stack_size == 20)
    cases = cases + 1
end
-- Constructor settings remain live unless the central config explicitly overrides them.
do
    local C = require(prefix .. "config")
    local startup = {["angels-components-stack-size"] = {value = 250}, ["angels-pavement-stack-size"] = {value = 800}}
    assert(C.initial_size("components", startup) == 250 and C.initial_size("pavement", startup) == 800)
    C.initial.components.size = 300
    assert(C.initial_size("components", startup) == 300)
    C.initial.components.size = nil
    local raw = {ammo = {["paranoidal-w93-cannon-shell"] = item(1)}}
    run(raw)
    assert(raw.ammo["paranoidal-w93-cannon-shell"].stack_size == 200)
    cases = cases + 1
end
print("stack-size rules: " .. cases .. " cases passed")
