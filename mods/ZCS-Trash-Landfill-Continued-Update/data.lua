require("prototypes.prototypes")

-- Elimina cualquier rastro de Quality Mod relacionado con esta receta
---if mods["quality"] then
---  data.raw.recipe["zcs-trash-quality"] = nil  -- Elimina receta alternativa si existe
---  data.raw.recipe["zcs-trash"].hidden = false -- Fuerza visibilidad
---  data.raw.recipe["zcs-trash"].allow_as_intermediate = false -- Refuerzo
---end