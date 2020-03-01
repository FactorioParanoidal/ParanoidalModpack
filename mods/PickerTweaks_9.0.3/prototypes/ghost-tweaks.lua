local Color = require('__stdlib__/stdlib/utils/color')
local ghost_tint = settings.startup['picker-ghost-tint'].value

if  ghost_tint ~= 'vanilla' then
    data.raw["utility-constants"].default.ghost_tint = Color(Color.color[ghost_tint], 0.3)
end
