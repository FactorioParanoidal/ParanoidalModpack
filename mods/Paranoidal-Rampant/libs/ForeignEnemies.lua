-- Reforged Paranoidal: enemies of Big Monsters and of the mferrari library (bosses, fake humans, giant worms,
-- volcanoes, invasion spawners, spidertrons, flying saucers). Those scripts own them, so Rampant:
--  * never replaces, mutates or grows them and does not count their spawners as its nests (no squads, flights,
--    growth or AI points from them);
--  * counts their worms as turrets of the chunk;
--  * does not enrage them and does not answer their deaths with vengeance, aggression or learning.
-- Names are recognised by the prefixes of those mods; the answer is cached per name (same on every peer).
-- No requires: also loaded at the data stage through libs/BitersEnrage.lua.

if foreignEnemiesG then
    return foreignEnemiesG
end
local foreignEnemies = {}

local PREFIXES = {"bm-", "bm_", "maf", "mf_", "biterzilla", "cyborg_strafer"}

local sSub = string.sub
local cache = {}

function foreignEnemies.isForeign(name)
    local foreign = cache[name]
    if foreign == nil then
        foreign = false
        for i = 1, #PREFIXES do
            local prefix = PREFIXES[i]
            if sSub(name, 1, #prefix) == prefix then
                foreign = true
                break
            end
        end
        cache[name] = foreign
    end
    return foreign
end

foreignEnemiesG = foreignEnemies
return foreignEnemies
