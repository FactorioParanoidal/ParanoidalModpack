-- Chance ladder of the positive qualities (prototypes/quality-base.lua + full/quality.lua):
-- normal is one dynamic step before uncommon, so next_probability strictly decreases from normal.
-- Run from the mod root: lua ./tests/quality-chance-curve.lua
package.path = "./prototypes/?.lua;./?.lua;" .. package.path

local function run(chance, bonus)
    package.loaded["chance-increment"] = nil
    package.loaded["utils"] = nil
    ic = nil
    settings = {startup = {
        ["ic-more-qualities-chance-to-upgrade"] = {value = chance},
        ["ic-more-qualities-chance-dynamic-bonus"] = {value = bonus},
        ["ic-more-qualities-multiplier"] = {value = 1},
        ["ic-more-qualities-mode"] = {value = "full"},
        ["ic-more-qualities-localization-full"] = {value = ""},
    }}
    data = {raw = {quality = {
        normal = {name = "normal", next = "uncommon", next_probability = 0.1},
        uncommon = {name = "uncommon", next = "rare", color = {}},
        rare = {name = "rare", next = "epic", color = {}},
        epic = {name = "epic", next = "legendary", color = {}},
        legendary = {name = "legendary", color = {}},
    }, technology = {
        ["quality-module"] = {effects = {}},
        ["quality-module-2"] = {effects = {}},
        ["quality-module-3"] = {effects = {}},
    }}}
    function data:extend(list)
        for _, prototype in ipairs(list) do self.raw[prototype.type][prototype.name] = prototype end
    end
    dofile("./prototypes/quality-base.lua")
    dofile("./prototypes/full/quality.lua")
    local chain, quality = {}, data.raw.quality.normal
    while quality do
        chain[#chain + 1] = quality
        quality = quality.next and data.raw.quality[quality.next]
    end
    return chain
end

-- Defaults: 0.204 -> 0.2 -> 0.196 ... strictly decreasing over the whole chain.
local chain = run(0.2, -0.004)
assert(#chain >= 40, "full chain loaded: " .. #chain)
assert(math.abs(chain[1].next_probability - 0.204) < 1e-9, "normal 0.204")
assert(math.abs(chain[2].next_probability - 0.2) < 1e-9, "uncommon 0.2")
for i = 2, #chain do
    assert(chain[i].next_probability < chain[i - 1].next_probability,
        chain[i].name .. " must be below " .. chain[i - 1].name)
end

-- Clamped to the engine range [0, 1] (positive bonus, chance near 1).
chain = run(1, 0.1)
assert(chain[1].next_probability <= 1 and chain[1].next_probability > 0, "normal clamped")
chain = run(0.001, 0.004)
assert(chain[1].next_probability >= 0.001, "normal not below the setting minimum")

print("quality-chance-curve: normal 0.204 > uncommon 0.2 > ... strictly decreasing; clamped to [0.001, 1]. Mocks only.")
