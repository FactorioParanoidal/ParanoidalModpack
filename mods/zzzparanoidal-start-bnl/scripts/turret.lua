-- The ship's own turret survived the crash with a few magazines and a name. If it holds through
-- the first attacks (config.turret.veteran_kills) it becomes a crash veteran: a name plate and a
-- map tag. HeroTurretRedux replaces a turret on every rank; the turret is found again at its
-- position (on_object_destroyed), so the plate follows the ranks without any polling.
local config = require("bnl-config")
local util = require("scripts.util")
local quality = require("scripts.quality")
local scheduler = require("scripts.scheduler")
local journal = require("scripts.journal")
local tags = require("scripts.tags")
local M = {}
local cfg = config.turret

local NAME = "gun-turret"
-- Proper names (plain strings: the plate and the map tag cannot be localised per player).
local NAMES = {
    {ru = "Последний довод", en = "Last Argument"}, {ru = "Тётя Шура", en = "Auntie Shura"},
    {ru = "BnL Страж-3000", en = "BnL Guardian 3000"}, {ru = "Ева", en = "EVE"}, {ru = "Мо", en = "M-O"},
    {ru = "Капитан Маккри", en = "Captain McCrea"}, {ru = "Директива A113", en = "Directive A113"},
    {ru = "Скидка дня", en = "Deal of the Day"}, {ru = "Синий — новый красный", en = "Blue Is the New Red"},
    {ru = "Гарантийный случай", en = "Warranty Claim"}, {ru = "Ворчун", en = "Grumpy"}, {ru = "Петрович", en = "Petrovich"},
    -- appended only (saved turrets keep their index)
    {ru = "Слишком большой, чтобы упасть", en = "Too Big to Fail"}, {ru = "Обед в стакане", en = "Lunch in a Cup"},
    {ru = "Право тратить", en = "The Right to Spend"}, {ru = "Шелби Форсрайт", en = "Shelby Forthright"},
    {ru = "Покупаем вместе", en = "Shop Together"}, {ru = "Операция «Уборка»", en = "Operation Cleanup"},
}

local function title(s, force)
    return NAMES[s.name][util.language(force)]
end

local function state()
    return storage.bnl and storage.bnl.turret
end

local function plate(s)
    if s.label and s.label.valid then s.label.destroy() end
    local entity = s.entity
    s.label = rendering.draw_text({text = {"bnl.turret-plate", title(s, entity.force)}, surface = entity.surface,
        target = {entity = entity, offset = {0, -1.9}}, color = {r = 1, g = 0.82, b = 0.3}, scale = 1.1, alignment = "center"})
end

local function watch(s)
    s.reg = script.register_on_object_destroyed(s.entity)
end

function M.place(surface, state_)
    if not util.entity_exists(NAME) then return end
    local p = util.add(util.ship_position(), util.vector(math.random(), util.float(cfg.distance)))
    local spot = surface.find_non_colliding_position(NAME, p, 10, 1)
    if not spot then return end
    util.clear(surface, util.area(spot, 2))
    local turret = surface.create_entity({name = NAME, position = spot, force = "player", create_build_effect_smoke = false})
    if not turret then return end
    local ammo = cfg.ammo
    if util.item_exists(ammo[1]) then
        turret.insert({name = ammo[1], count = ammo[2], quality = state_ and quality.of(state_, ammo[1]) or "normal"})
    end
    local s = {entity = turret, position = util.pos(spot), surface = surface.index, name = math.random(#NAMES)}
    storage.bnl.turret = s
    watch(s)
    scheduler.after(cfg.check_interval, "turret")
end

local function promote(s)
    s.veteran = true
    plate(s)
    local force = s.entity.force
    tags.set("turret", force, s.entity.surface, s.entity.position, "turret", {type = "item", name = NAME},
        "«" .. title(s, force) .. "»")
    journal.add("turret-veteran", {title(s, force), s.entity.kills})
end

scheduler.handler("turret", function(_, tick)
    local s = state()
    if not s or s.veteran or s.dead then return end
    local turret = s.entity
    if not (turret and turret.valid) then return end -- on_object_destroyed decides
    if turret.kills >= cfg.veteran_kills then
        promote(s)
    elseif util.since_landing() < cfg.max_time then
        scheduler.after(cfg.check_interval, "turret")
    end
end)

-- The turret was destroyed: replaced by a rank (same position) or dead.
function M.on_destroyed(registration)
    local s = state()
    if not (s and s.reg == registration) or s.dead then return end
    local surface = game.get_surface(s.surface)
    local found = surface and surface.find_entities_filtered({position = s.position, radius = 0.6, type = "ammo-turret",
        force = "player", limit = 1})[1]
    if found then
        s.entity = found
        watch(s)
        if s.veteran then plate(s) end
        return
    end
    s.dead = true
    scheduler.cancel("turret")
    if s.label and s.label.valid then s.label.destroy() end
    util.say({"bnl.turret-fallen", title(s, util.player_force()), util.gps(s.position, surface)})
end

return M
