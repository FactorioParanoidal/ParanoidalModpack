--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/17/2020
-- Time: 1:04 AM
-- To change this template use File | Settings | File Templates.
--
local ZergSound = {}
local SOUNDPATH = NE_Common.zsoundpath



function ZergSound.enemy_death(name, volume)
    return {

        filename = SOUNDPATH .. name .. "/death.ogg",
        volume = volume
    }
end

--[[
function ZergSound.meele_attack(volume)
    return
    {

        variations = {
            {
                filename = SOUNDPATH .. "zergling/attack.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "broodling/attack.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "ultralisk/attack.ogg",
                volume = volume
            }
        }
    }
end
]]

function ZergSound.meele_attack(name, volume)
    return
    {

        variations = {
            {
                filename = SOUNDPATH .. name .. "/attack.ogg",
                volume = volume
            }
        }
    }
end





function ZergSound.mutalisk_attack(volume)
    return
    {

        filename = SOUNDPATH .. "mutalisk/attack.ogg",
        volume = volume
    }
end

function ZergSound.guardian_attack(volume)
    return
    {

        filename = SOUNDPATH .. "guardian/attack.ogg",
        volume = volume
    }
end

function ZergSound.hydralisk_attack(volume)
    return
    {

        filename = SOUNDPATH .. "hydralisk/attack.ogg",
        volume = volume
    }
end

function ZergSound.devourer_attack(volume)
    return
    {

        filename = SOUNDPATH .. "devourer/attack.ogg",
        volume = volume
    }
end



function ZergSound.devourer_hit(volume)
    return
    {

        filename = SOUNDPATH .. "devourer/goohit.ogg",
        volume = volume
    }
end

function ZergSound.overlord_drop(volume)
    return
    {

        filename = SOUNDPATH .. "overlord/attack.ogg",
        volume = volume
    }
end

function ZergSound.lurker_hit(volume)
    return
    {

        variations = {
            {
                filename = SOUNDPATH .. "lurker/hit-1.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "lurker/hit-2.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "lurker/hit-3.ogg",
                volume = volume
            }
        }
    }
end

function ZergSound.lurker_attack(volume)
    return
    {

        variations = {
            {
                filename = SOUNDPATH .. "lurker/attack-1.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "lurker/attack-2.ogg",
                volume = volume
            }
        }
    }
end



function ZergSound.infested_attack(volume)
    return {

        variations = {
            {
                filename = SOUNDPATH .. "infested/attack.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "infested/attack-2.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "infested/attack-3.ogg",
                volume = volume
            },
        }
    }
end

function ZergSound.infested_death(volume)
    return {

        variations = {
            {
                filename = SOUNDPATH .. "infested/death.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "infested/death-1.ogg",
                volume = volume
            }
        }
    }
end

function ZergSound.scourge_attack(volume)
    return {

        variations = {
            {
                filename = SOUNDPATH .. "scourge/attack.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "scourge/attack-2.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "scourge/attack-3.ogg",
                volume = volume
            },
        }
    }
end

function ZergSound.scourge_death(volume)
    return {

        variations = {
            {
                filename = SOUNDPATH .. "scourge/death.ogg",
                volume = volume
            },
            {
                filename = SOUNDPATH .. "scourge/death-1.ogg",
                volume = volume
            }
        }
    }
end

function ZergSound.defiler_attack(volume)
    return
    {

        filename = SOUNDPATH .. "defiler/attack.ogg",
        volume = volume
    }
end

function ZergSound.queen_snare(volume)
    return
    {

        filename = SOUNDPATH .. "queen/snare.ogg",
        volume = volume
    }
end

return ZergSound
