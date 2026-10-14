-- Mods that change technology costs later must call relabel again (see evolution-label.lua).
require("__research_evolution_factor__/evolution-label").relabel_all()
