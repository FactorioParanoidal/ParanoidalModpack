local Data = require('__stdlib__/stdlib/data/data')

--(( No Artillery Reveal ))--
-- "name": "NoArtilleryMapReveal",
-- "title": "NoArtilleryMapReveal",
-- "author": "JohnTheCF",
-- "description": "Make artillery projectiles to not reveal map."
if settings.startup['picker-no-artillery-reveal'].value then
    local arty = Data('artillery-projectile', 'artillery-projectile')
    arty.reveal_map = false
    arty.action.action_delivery.target_effects[4] = nil
end
