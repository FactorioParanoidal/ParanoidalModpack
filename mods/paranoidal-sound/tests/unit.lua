-- Run with Lua 5.2: lua52 tests/unit.lua <path-to-paranoidal-sound>
-- Pure mocks: proves table selection/dispatch, not engine audio playback.
local root = assert(arg[1], "mod root required")
package.path = root .. "/?.lua;" .. package.path
mods = {}
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = table.deepcopy(child) end
    return copy
end
local cases = 0
local function check(condition, message)
    assert(condition, message)
    cases = cases + 1
end
local function auto()
    return setmetatable({}, {__index = function(t, k) local v = auto(); rawset(t, k, v); return v end})
end
local function extend(self, list)
    for _, prototype in ipairs(list) do self.raw[prototype.type][prototype.name] = prototype end
end
local function configure(override)
    for name in pairs(package.loaded) do if name:match("^prototypes%.") then package.loaded[name] = nil end end
    data = {raw = auto(), extend = extend}
    dofile(root .. "/settings.lua")
    settings = {startup = {}}
    for name, prototype in pairs(data.raw["string-setting"]) do
        settings.startup[name] = {value = override and override[name] or prototype.default_value}
    end
    data.raw.locomotive.locomotive.stop_trigger = {{type = "create-trivial-smoke"}, {type = "create-trivial-smoke"}, {type = "play-sound"}, {type = "play-sound"}}
    data.raw.projectile["atomic-rocket"].action.action_delivery.target_effects = {{type = "damage", damage = 42}, {type = "camera-effect"}, {type = "play-sound"}, {type = "play-sound"}, {type = "play-sound", sound = "keep-third"}}
    data.raw.explosion["grenade-explosion"].sound = data.raw.explosion["medium-explosion"].sound
    if mods.MIRV2 then
        data.raw.explosion["nuke-explosion"].sound = {variations = {{filename = "mirv-owned"}}}
        data.raw.fire["nuke-fire1"].working_sound = {sound = {filename = "before-copy"}}
        data.raw.fire["unrelated-fire"].working_sound = {sound = {filename = "unrelated"}}
    end
    if mods["paranoidal-picker-tools"] then
        data.raw.explosion["drop-planner"].sound = {aggregation = {max_count = 1}, variations = {}}
    end
    dofile(root .. "/data.lua")
    return data.raw
end
local function first(sound) return sound.filename or sound[1].filename end
local function from(sound, prefix) return first(sound):find("/sound/" .. prefix .. "/", 1, true) ~= nil end
local weapons = {
    {"pistol", "gun", "pistol"}, {"smg", "gun", "submachine-gun"}, {"shotgun", "gun", "shotgun"},
    {"gun-turret", "ammo-turret", "gun-turret"}, {"vehicle-machine-gun", "gun", "vehicle-machine-gun"},
}
local function train_targets(raw)
    local loco, cargo = raw.locomotive.locomotive, raw["cargo-wagon"]["cargo-wagon"]
    return {
        ["train-engine"] = loco.working_sound.sound, ["cargo-wheels"] = cargo.working_sound.sound,
        ["train-brakes"] = loco.stop_trigger[3].sound, ["locomotive-ties"] = loco.drive_over_tie_trigger.sound,
        ["cargo-ties"] = cargo.drive_over_tie_trigger.sound,
    }
end
local baseline = configure()
local keys = {}
for name in pairs(settings.startup) do keys[#keys + 1] = name end
check(#keys == 11, "11 startup selectors")
for _, changed in ipairs(keys) do
    local default = settings.startup[changed].value
    local alternate = default == "immersive-sounds2" and "EpicWeaponSounds" or "immersive-sounds2"
    local raw = configure({[changed] = alternate})
    for _, row in ipairs(weapons) do
        check(from(raw[row[2]][row[3]].attack_parameters.sound, changed == "paranoidal-sound-" .. row[1] and "epic" or "immersive"), "isolated weapon choice: " .. changed .. "/" .. row[1])
    end
    check(from(raw.explosion["grenade-explosion"].sound.variations, changed == "paranoidal-sound-grenade" and "epic" or "immersive"), "grenade selection")
    check(from(raw.explosion["medium-explosion"].sound.variations, "immersive"), "grenade must not mutate other medium explosions")
    check(from(raw.gun["tank-machine-gun"].attack_parameters.sound, "immersive"), "car must not mutate tank gun")
    check(from(raw["electric-turret"]["laser-turret"].attack_parameters.sound, "epic") and from(raw.beam["laser-beam"].working_sound.sound, "immersive"), "laser fields coexist")
    for name, sound in pairs(train_targets(raw)) do
        check(from(sound, changed == "paranoidal-sound-" .. name and "immersive" or "trains"), "isolated train choice: " .. changed .. "/" .. name)
    end
    check(from(raw.locomotive.locomotive.stop_trigger[4].sound, "immersive"), "brake squeal retained")
    check(from(raw.locomotive.locomotive.open_sound, "immersive"), "door retained")
    check(from(raw["fluid-wagon"]["fluid-wagon"].working_sound.sound, "trains"), "fluid wagon unique sound retained")
    local effects = raw.projectile["atomic-rocket"].action.action_delivery.target_effects
    check(effects[1].damage == 42 and effects[2].type == "camera-effect" and effects[5].sound == "keep-third", "nuclear non-audio and third sound untouched")
    configure() -- restore default setting values for the next independent toggle
end
mods = {MIRV2 = true, ["paranoidal-picker-tools"] = true}
local compatible = configure()
check(compatible.explosion["nuke-explosion"].sound.variations[1].filename == "mirv-owned", "MIRV keeps its own nuke explosion")
check(#compatible.fire["nuke-fire1"].working_sound.sound == 2, "MIRV early copies inherit corrected fire audio")
check(compatible.fire["unrelated-fire"].working_sound.sound.filename == "unrelated", "unrelated fire not patched")
check(#compatible.explosion["drop-planner"].sound.variations == 5 and compatible.explosion["drop-planner"].sound.variations[1].filename == "__base__/sound/fight/laser-1.ogg", "Picker keeps its original five laser variants")
check(compatible.explosion["drop-planner"].sound.aggregation.max_count == 1, "Picker wrapper retained")
mods = {}
local raw = configure()
for _, row in ipairs(weapons) do check(from(raw[row[2]][row[3]].attack_parameters.sound, "immersive"), "default weapon") end
for name, sound in pairs(train_targets(raw)) do check(from(sound, "trains"), "default train: " .. name) end
local library = require("prototypes.library")
check(#library.tank_engine_working_sound.sound == 3, "three tank loops")
check(#library.car_engine_working_sound.activate_sound == 2, "two car starts")
check(#library.fire_flame_sound.sound == 2, "two fire loops")
check(#library.flamethrower_cyclic_sound.begin_sound == 2 and #library.flamethrower_cyclic_sound.end_sound == 2, "flamethrower variation structure")
local seen, filenames = {}, {}
local function files(t)
    if type(t) ~= "table" or seen[t] then return end
    seen[t] = true
    for key, value in pairs(t) do
        if key == "filename" and type(value) == "string" then
            local path = value:match("^__paranoidal%-sound__/(.+)")
            if path then
                local file = assert(io.open(root .. "/" .. path, "rb"), path)
                file:close(); filenames[path] = true
            end
        elseif type(value) == "table" then files(value) end
    end
end
files(raw); files(library)
-- Cover the Epic alternatives' files as well, not just the default laser.
local all_epic = {}
for _, row in ipairs(weapons) do all_epic["paranoidal-sound-" .. row[1]] = "EpicWeaponSounds" end
all_epic["paranoidal-sound-grenade"] = "EpicWeaponSounds"
files(configure(all_epic))
raw = configure()
local inputs, runtime_sounds = 0, 0
for _ in pairs(raw["custom-input"]) do inputs = inputs + 1 end
for _ in pairs(raw.sound) do runtime_sounds = runtime_sounds + 1 end
check(inputs == 12 and runtime_sounds == 9, "legacy input and runtime sound IDs")

-- Execute the production control.lua, capture its registered handlers, and send each real input ID.
defines = {inventory = {character_ammo = 1, character_guns = 2, car_ammo = 3, spider_ammo = 4}}
local handlers, player, played = {}, nil, {}
script = {on_event = function(name, handler) handlers[name] = handler end}
game = {get_player = function() return player end}
dofile(root .. "/control.lua")
local surface = {play_sound = function(spec) played[#played + 1] = spec end}
local function entity(name, contents, fuel)
    return {name = name, valid = true, position = {x = 1, y = 2}, surface = surface,
        burner = fuel and {currently_burning = true} or nil,
        get_inventory = function(id)
            if contents and contents[id] ~= nil then return {is_empty = function() return not contents[id] end} end
        end}
end
local function press(control)
    played = {}
    for name, prototype in pairs(raw["custom-input"]) do
        check(handlers[name] ~= nil, "handler for " .. name)
        if prototype.linked_game_control == control then handlers[name]{input_name = name, player_index = 1} end
    end
    return played
end
check(#press("next-weapon") == 0, "missing player")
player = {valid = true}
check(#press("next-weapon") == 0, "no character")
player.character = entity("character")
check(#press("next-weapon") == 0, "missing inventories / remote view safety")
player.character = entity("character", {[1] = true, [2] = false})
check(#press("next-weapon") == 0, "ammo but no weapon")
player.character = entity("character", {[1] = false, [2] = true})
check(#press("next-weapon") == 0, "weapon but no ammo")
player.character = entity("character", {[1] = true, [2] = true})
check(#press("next-weapon") == 1 and played[1].path == "select-smg", "character weapon selection once")
player.character.valid = false
check(#press("next-weapon") == 0, "invalid character")
player.driving = true
for _, row in ipairs{{"tank", 3, "select-cannon"}, {"car", 3, "select-machine-gun"}, {"spidertron", 4, "select-machine-gun"}} do
    player.vehicle = entity(row[1], {[row[2]] = true}, true)
    check(#press("next-weapon") == 1 and played[1].path == row[3], "vehicle selection once: " .. row[1])
    player.vehicle = entity(row[1], {[row[2]] = false}, true)
    check(#press("next-weapon") == 0, "empty vehicle ammo: " .. row[1])
end
for name, prefixes in pairs{car = {"car-engine-loads", "car-engine-loads-reverse", "car-steering", "car-steering"}, tank = {"tank-engine-loads", "tank-engine-loads-reverse", "tank-engine-loads-rotation", "tank-engine-loads-rotation"}} do
    for i, control in ipairs{"move-up", "move-down", "move-left", "move-right"} do
        player.vehicle = entity(name, {}, true)
        check(#press(control) == 1 and played[1].path == prefixes[i], "movement once: " .. name .. "/" .. control)
        check(played[1].position == player.vehicle.position, "spatial sound position")
        player.vehicle.burner.currently_burning = nil
        check(#press(control) == 0, "unlit burner")
        player.vehicle.burner = nil
        check(#press(control) == 0, "absent burner")
    end
end
player.vehicle = entity("locomotive", {[3] = true}, true)
check(#press("next-weapon") == 0 and #press("move-up") == 0, "unrelated vehicle ignored")
player.vehicle.valid = false
check(#press("move-up") == 0, "invalid vehicle")
for name in pairs(handlers) do check(rawget(raw["custom-input"], name) ~= nil, "no tick or unrelated handler") end
local count = 0; for _ in pairs(filenames) do count = count + 1 end
print("PASS: " .. cases .. " assertions; " .. count .. " referenced assets exist; 11 independent toggles; 12 input handlers")
