-- technology/lamp

-- Add coloured lamp to Lamp technology
local base_optics = data.raw["technology"]["lamp"]
table.insert(base_optics.effects, {type="unlock-recipe", recipe="dect-small-lamp-glow"})
