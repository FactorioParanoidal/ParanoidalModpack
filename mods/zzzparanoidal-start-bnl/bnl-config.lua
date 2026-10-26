-- Balance of the "Start with BnL" content (shipwreck-config.lua keeps the start crash supplies).
-- Read by the data stage and by control.lua. Times are in ticks (60 per second) unless named *_s.
-- Item lists may name items of optional mods: missing ones are skipped with a log line.

local MINUTE = 60 * 60
local config = {}

config.ship_position = {-5, -6} -- freeplay crash site
-- Direction the ship came from: west-south-west (0 = east, 0.25 = south, 0.5 = west, in turns).
config.entry_angle = 0.4375

-- Every wreck prototype of the start (vanilla and AAI wrecks) gets x10 health, so the fire and the
-- ammo cook-off take a slow percentage of it; the ship itself only x1.25 (x10 / 8);
-- containers get at least this many slots.
config.wreck_health_multiplier = 10
config.ship_health_multiplier = 10 / 8
config.wreck_min_slots = 4

-- 1. Falling debris: the ship keeps falling apart for the first minutes.
config.falling = {
    count = {14, 20}, -- rolled by sizes, then small ones are added (small_factor)
    small_factor = 2,
    first_tick = 40 * 60,
    last_tick = 9 * MINUTE + 30 * 60,
    warning = 6 * 60, -- shadow and chat warning before the impact; the roar of the low pass starts with the flight
    flight = 2 * 60, -- projectile flight time
    sound_lead = 3 * 60, -- the roar of the low pass starts this long before the launch
    -- Players this close to the impact point hear the incoming shell whistle (it ends at the impact)
    -- instead of the low pass roar; the choice is made per player when the roar would start.
    near_distance = 40,
    incoming_lead = 2 * 60, -- the whistle starts this long before the impact (the clips are 1.6-2.2 s)
    distance = {16, 90}, -- impact distance from the ship
    source_distance = 70, -- the projectile comes from this far west-south-west
    target_building_chance = 0.15, -- the piece falls onto a player building near the crash
    building_radius = 70,
    sizes = {small = 60, medium = 30, big = 10}, -- weights
    recorder_tick = 3 * MINUTE + 20 * 60, -- the big piece closest to this time carries the flight recorder
    ignite_chance = 0.6,
    -- Shadow of the coming piece over the impact point from the warning on: linear size x10-16 and
    -- 1% opacity at first, shrinking to the real shadow at full opacity at the impact (perspective:
    -- size falls linearly with the height, opacity follows 1/size). Updated every shadow_interval ticks.
    shadow_scale = {20, 32},
    shadow_alpha = 0.15,
    shadow_spin = 0.12, -- the tumbling piece turns its shadow by up to this many turns on the way down
    shadow_interval = 2,
    names = {
        small = {"crash-site-spaceship-wreck-small-1", "crash-site-spaceship-wreck-small-2", "crash-site-spaceship-wreck-small-3",
            "crash-site-spaceship-wreck-small-4", "crash-site-spaceship-wreck-small-5", "crash-site-spaceship-wreck-small-6",
            "aai-small-ship-wreck"},
        medium = {"crash-site-spaceship-wreck-medium-1", "crash-site-spaceship-wreck-medium-2", "crash-site-spaceship-wreck-medium-3",
            "aai-medium-ship-wreck-1", "aai-medium-ship-wreck-2"},
        big = {"crash-site-spaceship-wreck-big-1", "crash-site-spaceship-wreck-big-2", "aai-big-ship-wreck-1",
            "aai-big-ship-wreck-2", "aai-big-ship-wreck-3"},
    },
    -- Cargo of falling containers: picks per size, each {item, min, max}.
    picks = {medium = {1, 2}, big = {2, 3}},
    cargo = {
        {"iron-gear-wheel", 10, 30}, {"copper-cable", 20, 60}, {"iron-plate", 20, 60}, {"pipe", 10, 25},
        {"bob-basic-circuit-board", 5, 15}, {"repair-pack", 5, 15}, {"burner-inserter", 3, 8}, {"inserter", 2, 6},
        {"stone-furnace", 1, 2}, {"burner-mining-drill", 1, 2}, {"small-electric-pole", 5, 10}, {"steel-plate", 5, 15},
        {"bob-insulated-cable", 10, 30}, {"electronic-circuit", 2, 6}, {"solid-fuel", 5, 15}, {"wood", 10, 30},
    },
}

-- 2. Burning wrecks: what burns, cooks off and blows up inside them.
config.fire = {
    watch_until = 30 * MINUTE, -- fires near start wrecks can ignite them until then
    watch_interval = 120,
    tick_interval = 60,
    -- A burning wreck burns down to a random floor of its max health, then the fire goes out.
    burn_floor = {0.02, 0.10},
    -- Time to burn from full health to the floor, seconds, by wreck size (cook-offs make it faster).
    burn_seconds = {small = {150, 240}, medium = {240, 420}, big = {360, 600}},
    flame_interval = 10 * 60, -- a burning wreck shows a crash-site flame on itself this often
    -- Start wrecks set burning at the landing (besides those the crash fires reach) and the delay.
    start_burning = 0.35,
    start_delay = {5 * 60, 90 * 60},
    idle_interval = {4 * 60, 10 * 60}, -- next check for something to cook off when nothing went off
    splash_radius = 3,
    splash_damage = 8, -- per cook-off to characters around
    building_radius = 6, -- big blasts (fuel barrels, explosives, the last blast) also hit player buildings
    step_interval = {10 * 60, 15 * 60}, -- a burning wreck lowers the quality of its cargo this often
    lose_chance = 0.2, -- each 'cargo burnt -1' destroys one whole cargo stack with this chance
    scatter_chance = 0.12, -- a cook-off throws part of a stack out of the wreck (saved from the fire)
    spark_chance = 0.2, -- a cook-off sets the ground around on fire
    -- At most this share of the hazardous cargo goes off while a wreck burns (counted when it catches
    -- fire); when the fire goes out burnout_share of what is left goes off in the last blast. The rest
    -- (about a third) is loot, taken out or mined like the cargo.
    fire_share = 0.5,
    burnout_share = 0.3,
    burnout_radius = 6,
    burnout_damage = 40,
    -- One kind of hazardous cargo per start wreck, by weight ("none": nothing reacts to fire).
    hazard_weights = {ammo = 40, barrel = 20, gas = 10, fuel = 10, explosive = 5, oxygen = 3, battery = 2, none = 10},
    -- Counts of the shared lists below are for a medium wreck; small and big wrecks scale them.
    size_factor = {small = 0.5, medium = 1, big = 1.6},
    hazards = {
        -- Ammo: frequent small cook-offs. Per size: {item, min, max, weight, damage share of max
        -- health per unit, explosion, fire = sets the ground burning}.
        ammo = {
            pop_interval = {4 * 60, 10 * 60},
            pop_units = {1, 2},
            by_size = {
                small = {
                    {"firearm-magazine", 3, 8, 70, 0.012, "explosion-hit"},
                    {"shotgun-shell", 4, 10, 30, 0.010, "explosion-hit"},
                },
                medium = {
                    {"firearm-magazine", 6, 15, 60, 0.012, "explosion-hit"},
                    {"shotgun-shell", 6, 15, 25, 0.010, "explosion-hit"},
                    {"flamethrower-ammo", 2, 5, 15, 0.020, "explosion", fire = true},
                },
                big = {
                    {"firearm-magazine", 10, 25, 55, 0.012, "explosion-hit"},
                    {"shotgun-shell", 10, 20, 20, 0.010, "explosion-hit"},
                    {"flamethrower-ammo", 3, 6, 15, 0.020, "explosion", fire = true},
                    {"rocket", 2, 4, 10, 0.050, "big-explosion"},
                },
            },
        },
        -- Fuel barrels: rare big bursts, burning fuel spills around as a pool of fire that lights
        -- other wrecks and player buildings nearby.
        barrel = {
            pop_interval = {15 * 60, 30 * 60},
            pop_units = 1,
            damage = 0.07,
            explosion = "big-explosion",
            pool_radius = {4, 7},
            pool_flames = {4, 7},
            hurt = {5, 25}, -- radius, damage to characters (and player buildings)
            items = {
                {"crude-oil-barrel", 1, 3, 30}, {"diesel-fuel-barrel", 1, 2, 25},
                {"angels-liquid-fuel-oil-barrel", 1, 3, 20}, {"angels-liquid-naphtha-barrel", 1, 3, 15},
                {"bob-liquid-fuel-barrel", 1, 2, 10},
            },
        },
        -- Gas cylinders: a burst cylinder flies off and falls burning somewhere around.
        gas = {
            pop_interval = {12 * 60, 25 * 60},
            pop_units = 1,
            damage = 0.04,
            explosion = "explosion",
            fly = {15, 30}, -- distance of the flying cylinder
            hurt = {3, 15},
            items = {
                {"angels-gas-hydrogen-barrel", 1, 3, 40}, {"angels-gas-methane-barrel", 1, 3, 35},
                {"angels-gas-butane-barrel", 1, 2, 25},
            },
        },
        -- High-tech fuel: no blasts, it burns as the fire's own fuel and makes it hotter.
        fuel = {
            pop_interval = {6 * 60, 12 * 60},
            pop_units = {1, 2},
            damage = 0.012,
            boost = 1.3, -- burn speed while there is fuel inside
            items = {
                {"solid-fuel", 4, 10, 45}, {"bob-enriched-fuel", 2, 5, 25}, {"high-octane-enriched-fuel", 1, 3, 15},
                {"rocket-fuel", 1, 2, 12}, {"nuclear-fuel", 1, 1, 3},
            },
        },
        -- Explosives: one big blast that throws the cargo far.
        explosive = {
            pop_interval = {20 * 60, 50 * 60},
            pop_units = "all",
            damage = 0.22,
            explosion = "massive-explosion",
            blasts = 3, -- big explosions around it
            hurt = {8, 70},
            scatter = 3,
            items = {{"explosives", 5, 15, 50}, {"grenade", 3, 8, 30}, {"cliff-explosives", 1, 3, 20}},
        },
        -- Oxygen: vents in jets of flame, the wreck burns twice as fast while it has oxygen.
        oxygen = {
            pop_interval = {8 * 60, 16 * 60},
            pop_units = 1,
            damage = 0.02,
            boost = 2,
            items = {{"angels-gas-oxygen-barrel", 1, 3, 100}},
        },
        -- Batteries: thermal runaway, sparks and a poison cloud.
        battery = {
            pop_interval = {5 * 60, 10 * 60},
            pop_units = {1, 3},
            damage = 0.008,
            explosion = "explosion-hit",
            poison_chance = 0.35,
            items = {{"battery", 5, 15, 60}, {"bob-battery-2", 3, 8, 30}, {"bob-battery-3", 2, 5, 10}},
        },
    },
    -- Character of a fire, rolled when a wreck catches fire (weight, burn speed, flames):
    -- steady: as it is; smoulder: slow, thick smoke, keeps smoking after it is out; blaze: fast and
    -- big, throws embers that light the ground around; flaring: flare-ups every so often.
    temperaments = {
        steady = {weight = 40, speed = 1, light = {1, 0.55, 0.2}},
        smoulder = {weight = 20, speed = 0.6, flame_factor = 2.5, smoke = 2, afterglow = 90 * 60, light = {0.8, 0.35, 0.15}},
        blaze = {weight = 25, speed = 1.4, flame_factor = 0.5, embers = {chance = 0.25, radius = {4, 8}}, light = {1, 0.65, 0.25}},
        flaring = {weight = 15, speed = 1, flare = {interval = {20 * 60, 40 * 60}, damage = 0.04, seconds = 3, scale = 1.4},
            light = {1, 0.6, 0.2}},
    },
    -- Torches over a burning wreck that still has fuel inside (animations in prototypes/bnl-falling.lua),
    -- {dx, dy, scale} in tiles for a medium wreck: fuel barrels burn out of three holes, gas as a
    -- flare stack column, high-tech fuel as one refinery torch (taller for hotter fuel), oxygen as a
    -- wild blaze. They shrink as the fuel runs out (down to min_scale) and go with the fire.
    torches = {
        barrel = {animation = "bnl-torch-refinery", points = {{-0.9, 0.1, 0.8}, {0, -0.3, 1.6}, {0.8, 0.2, 1.1}}},
        gas = {animation = "bnl-torch-refinery", points = {{0, -0.2, 2.5}}},
        fuel = {animation = "bnl-torch-refinery", points = {{0, -0.2, 1}},
            item_scale = {["solid-fuel"] = 1, ["bob-enriched-fuel"] = 1.2, ["high-octane-enriched-fuel"] = 1.45,
                ["rocket-fuel"] = 1.7, ["nuclear-fuel"] = 2.2}},
        oxygen = {animation = "bnl-torch-blaze", points = {{0, 0, 1}}},
        -- how far above the anchor the animation centre is, per unit of scale (flame base on the anchor)
        lift = {["bnl-torch-refinery"] = 0.55, ["bnl-torch-blaze"] = 0.8},
        min_scale = 0.35,
        long_from = 1.5, -- torches of this base scale (and more) are stretched vertically
        long_stretch = 2,
    },
    -- Water barrels in a burning wreck (a kit is in the ship; players put them in): the fire burns
    -- slower while there is water, a barrel bursts into steam every interval, after `quench` barrels
    -- by wreck size the fire is out (no last blast, no 4th quality step; it may light again later).
    -- Water barrels: inside a burning wreck one bursts every interval (slows the fire, enough of them
    -- put it out); poured from the hand (scripts/douse.lua) one puts a wreck fire out at once.
    water = {
        items = {"water-barrel", "angels-water-purified-barrel"},
        slow = 0.5,
        interval = {4 * 60, 6 * 60},
        quench = {small = 1, medium = 2, big = 3}, -- barrels inside; one from the hand is enough
        spill_radius = 2.5, -- a barrel poured on the ground puts out ordinary fires this far (also: "burning ground")
        calm = 3 * MINUTE,
        ship_kit = {"water-barrel", 20},
    },
    -- Fuel poured on a fire from the hand (scripts/douse.lua): fuel and gas barrels, oxygen, the
    -- high-tech fuel of the wrecks and every chemical fuel of at least min_fuel_value (solid fuel 12 MJ).
    misuse = {
        min_fuel_value = 12000000,
        fireball_radius = 7,
        blasts = 10,
        building_radius = 10, -- every building and wreck within it catches fire
        max_buildings = 80,
        player_burn_ticks = 10 * 60,
        cursor_ticks = 10 * 60, -- the cursor burns this long
        cursor_interval = 10,
        sound_interval = 200, -- the 3.5 s flamethrower roar repeats
    },
}

-- 3. Debris trail west-south-west of the crash site with the detached compartments.
config.trail = {
    angle_deviation = 0.02,
    debris_from = 55,
    debris_to = {520, 800},
    debris_step = {12, 28},
    debris_side = {2, 14},
    debris = {
        {"crash-site-spaceship-wreck-small-1", 10}, {"crash-site-spaceship-wreck-small-2", 10},
        {"crash-site-spaceship-wreck-small-3", 10}, {"crash-site-spaceship-wreck-small-4", 10},
        {"crash-site-spaceship-wreck-small-5", 10}, {"crash-site-spaceship-wreck-small-6", 10},
        {"aai-small-ship-wreck", 25}, {"crash-site-spaceship-wreck-medium-1", 5},
        {"crash-site-spaceship-wreck-medium-2", 5}, {"crash-site-spaceship-wreck-medium-3", 5},
        {"aai-medium-ship-wreck-1", 4}, {"aai-medium-ship-wreck-2", 4},
    },
    -- Compartments: distance along the trail, side offset and the contents {item, min, max}.
    compartments = {
        {key = "reactor", name = "bnl-compartment-reactor", distance = {75, 105}, side = {-6, 6}},
        {key = "medbay", name = "bnl-compartment-medbay", distance = {180, 260}, side = {-20, 20}, items = {
            {"raw-fish", 15, 30}, {"repair-pack", 20, 40}, {"hazmat-suit", 1, 1}, {"light-armor", 1, 1},
            {"bnl-antenna-part", 1, 1},
        }},
        {key = "armory", name = "bnl-compartment-armory", distance = {300, 420}, side = {-25, 25}, guard = true, items = {
            {"submachine-gun", 1, 2}, {"shotgun", 1, 1}, {"firearm-magazine", 60, 120}, {"shotgun-shell", 30, 60},
            {"piercing-rounds-magazine", 20, 40}, {"grenade", 10, 20}, {"gun-turret", 2, 3}, {"bnl-antenna-part", 1, 1},
        }},
        {key = "hydroponics", name = "bnl-compartment-hydroponics", distance = {440, 560}, side = {-25, 25}, items = {
            {"bi-seed", 100, 200}, {"seedling", 30, 60}, {"wood", 50, 100}, {"bi-bio-greenhouse", 1, 1},
            {"raw-fish", 5, 10},
        }},
        {key = "engineering", name = "bnl-compartment-engineering", distance = {600, 780}, side = {-30, 30}, water = true, items = {
            {"steel-plate", 60, 120}, {"iron-gear-wheel", 60, 120}, {"electronic-circuit", 20, 40}, {"pipe", 40, 80},
            {"assembling-machine-1", 1, 2}, {"bob-basic-circuit-board", 20, 40}, {"bnl-antenna-part", 1, 1},
        }},
    },
    water_search = 150,
    -- Guard of the armory: an enemy nest and worms around it.
    guard = {spawner = {"biter-spawner", 1, 14, 20}, worms = {"small-worm-turret", 2, 6, 10}},
}

-- 6. Reactor compartment: no power until fully repaired; from the repair 15 MW, 5 MW at 5 minutes,
-- then slowly down to zero at 60 minutes (scripts/reactor.lua).
config.reactor = {
    power_mw = 15,
    knee_mw = 5,
    knee_minutes = 5,
    life_minutes = 60,
    start_health = 0.2,
    interval = 300,
    radiation_radius = 12,
    radiation_damage = 10, -- per interval: full while broken; when repaired scaled with the power and halved
    meltdown = 3 * 60 * MINUTE, -- after the landing, if never repaired: an atomic blast
    meltdown_warning = 3 * MINUTE, -- before it: light radiation over the whole surface and a hint
    meltdown_dps = 0.25,
    meltdown_radius = 100000,
    geiger_radius = 20, -- Radioactive-Damage-Reforged: the Geiger counter clicks this far, damage only within radiation_radius
}

-- 4. Flight recorder: red science reward of the decoding research.
config.recorder = {packs = {20, 30}}

-- Radars a player builds (other radar entities are hidden helpers of other mods: never touched).
config.radars = {"radar", "ore-radar", "bob-radar-2", "bob-radar-3", "bob-radar-4", "bob-radar-5"}

-- 5. BnL insurance: supply pods after the first radar, each an iron chest with one kind of items.
-- The contents are a draft for agreement with the user.
config.pods = {
    first_delay = {2 * MINUTE, 3 * MINUTE},
    intervals = {15 * MINUTE, 18 * MINUTE, 22 * MINUTE, 26 * MINUTE, 30 * MINUTE, 35 * MINUTE, 40 * MINUTE},
    distance = {30, 150},
    far_chance = 0.15,
    far_distance = {200, 320},
    -- researching this ends the insurance early
    end_technology = "logistic-science-pack",
    joke_chance = 0.12,
    joke = {"bnl-advertising-flyer", 200, 400},
    contents = {
        {"repair-pack", 40, 60}, {"iron-gear-wheel", 100, 200}, {"copper-cable", 200, 300}, {"iron-plate", 200, 300},
        {"steel-plate", 50, 100}, {"bob-basic-circuit-board", 50, 100}, {"electronic-circuit", 20, 40},
        {"firearm-magazine", 50, 100}, {"solid-fuel", 30, 60}, {"pipe", 50, 100}, {"stone-brick", 100, 200},
        {"small-electric-pole", 30, 50}, {"burner-mining-drill", 4, 8}, {"stone-furnace", 6, 12},
    },
    biofarm_tick = 10 * MINUTE, -- the biologist gets a big bio farm
    biofarm = {"bi-bio-farm", 1, 1},
}

-- 7. Professions. Half researched: saved progress 0.5.
config.professions = {
    order = {"guard", "geologist", "mechanic", "biologist", "passenger"},
    window = 30 * MINUTE, -- players created later start as passengers
    ammo_share_wait = MINUTE, -- multiplayer: the wreck ammo is shared among the guards chosen by then
    list = {
        guard = {
            sprite = "item/submachine-gun",
            researched = {"qol-movement-speed-1-1", "qol-movement-speed-1-2"},
            half = {"military", "gun-turret", "stone-wall"},
            rpg = {{"LV_Health_Bonus", 3, 9}}, -- +10 health per level
            items = {{"submachine-gun", 1}, {"shotgun", 1}, {"light-armor", 1}, {"gun-turret", 1}, {"firearm-magazine", 3}},
            wreck_ammo = true, -- all ammo of the start wrecks and the ship goes into the guard's inventory
        },
        geologist = {
            sprite = "item/ore-radar",
            researched = {"qol-mining-speed-1-1", "qol-mining-speed-1-2"},
            half = {"ore-radar", "angels-ore-crushing", "electric-mining-drill", "radar", "bob-radar-2"},
            rpg = {{"LV_Inv_Bonus", 10}}, -- +10 inventory slots
            ship_items = {{"ore-radar", 1}},
        },
        mechanic = {
            sprite = "item/ic-refine-workshop",
            researched = {"ic-defect-control-1", "ic-defect-control-2", "ic-defect-control-3", "ic-defect-control-4",
                "qol-crafting-speed-1-1", "qol-player-reach-1-1"},
            half = {"automation", "bob-repair-pack-2", "ic-defect-control-5"},
            items = {{"ic-refine-workshop", 1}},
            repair_packs = 2, -- start repair packs x2
        },
        biologist = {
            sprite = "item/bi-seed",
            researched = {"armor-absorb-1", "armor-absorb-2", "armor-absorb-3"},
            half = {"bi-tech-bio-farming", "bi-tech-timber", "lamp"},
            -- the respirator goes into the armor slot
            items = {{"respirator", 1}, {"bi-seed", 100, quality_steps = {1, 4}}, {"bi-bio-greenhouse", 2},
                {"water-barrel", 20}},
            recipes = {"bi-seedling-1", "bi-seed-1"},
            biofarm = true,
        },
        passenger = {sprite = "item/raw-fish"},
    },
}

-- 8. Landing anomalies (one per map).
config.anomalies = {
    list = {"long-night", "magnetic-storm", "rich-vein", "quiet-planet", "dust-storms"},
    long_night = {nights = 3},
    magnetic_storm = {until_technology = "electronics", every = {4 * MINUTE, 7 * MINUTE}, length = {60 * 60, 90 * 60}},
    rich_vein = {ores = {"angels-ore1", "angels-ore2", "angels-ore3", "angels-ore4", "angels-ore5", "angels-ore6"},
        distance = {28, 55}, radius = {6, 9}, amount = {4000, 9000}},
    quiet_planet = {duration = 120 * MINUTE},
    dust_storms = {count = 8, first = 20 * MINUTE, every = {25 * MINUTE, 45 * MINUTE}, warning = 60 * 60,
        pollution = 1000, distance = {48, 160}},
}

-- 9. Scrap deposit along the crash furrow behind the ship.
config.scrap = {
    from = 6, to = 52, width = {5, 8}, amount = {1000, 10000}, noise = 0.35, -- amount: the whole deposit, uniform
    results = {
        {"iron-gear-wheel", 0.18}, {"iron-stick", 0.12}, {"iron-plate", 0.10}, {"copper-cable", 0.08},
        {"stone", 0.06}, {"pipe", 0.05}, {"bob-basic-circuit-board", 0.05}, {"angels-slag", 0.05},
        {"repair-pack", 0.04}, {"steel-plate", 0.03}, {"bob-insulated-cable", 0.02}, {"motor", 0.02},
        {"electronic-circuit", 0.01}, {"battery", 0.01}, {"bob-titanium-bearing-ball", 0.01},
    },
}

-- 10. The previous expedition.
config.expedition = {
    distance = {2000, 4000}, -- far: the car must be earned
    min_angle = 0.2, -- turns away from the trail
    items = {
        {"assembling-machine-1", 2, 2, quality = "ic-defect-5"}, {"burner-mining-drill", 3, 3, quality = "ic-defect-4"},
        {"inserter", 10, 10, quality = "ic-defect-5"}, {"stone-furnace", 4, 4, quality = "ic-defect-3"},
        {"bnl-engineer-note", 1, 1},
    },
    car = {name = "car", health = 0.4},
}

-- 11. Salvaged ship turret.
config.turret = {
    distance = {8, 14},
    ammo = {"firearm-magazine", 10},
    veteran_kills = 25,
    check_interval = MINUTE,
    max_time = 180 * MINUTE,
}

-- 12. Captain's safe: code signals B, N, L.
config.safe = {
    distance = {10, 18},
    signals = {"signal-B", "signal-N", "signal-L"},
    code = {1, 999},
    items = {
        {"modular-armor", 1, 1, quality_steps = 3}, {"night-vision-equipment", 1, 1}, {"solar-panel-equipment", 4, 4},
        {"battery-equipment", 2, 2}, {"logistic-science-pack", 25, 25},
    },
}

-- 13. Multiplayer escape pods.
config.capsules = {
    window = 10 * MINUTE,
    distance = {100, 200},
    kits = {
        {{"burner-mining-drill", 3}, {"stone-furnace", 3}, {"wood", 20}},
        {{"salvaged-generator", 1}, {"small-electric-pole", 10}, {"repair-pack", 20}},
        {{"submachine-gun", 1}, {"firearm-magazine", 20}, {"light-armor", 1}},
        {{"burner-inserter", 10}, {"iron-gear-wheel", 30}, {"iron-plate", 50}},
    },
}

-- 14. Distress signal and the BnL letters.
config.distress = {
    transmit_s = 60,
    reply_delay = 2 * MINUTE,
    check_interval = 600,
    letters = {"logistic-science-pack", "chemical-science-pack", "rocket-silo", "space-construction"},
}

-- Weathered BnL logo painted on the crashed starliner (the lower hull panel, as marked by the user):
-- offset from the ship centre in tiles, width in tiles, rotation in turns (counter-clockwise < 1).
-- clear_radius: no start wreck within it (their fire would cover the logo), ship flames avoid flame_radius.
config.ship_decal = {offset = {1.58, 3.05}, clear_radius = 5, flame_radius = 1.6, width = 1.8, orientation = 1 - 25 / 360, tint = {0.88, 0.88, 0.88, 0.92}}

-- 15. Intro flight along the trail.
config.intro = {start_distance = 100, transition = 660, wait = 120, explosions = 6}

return config
