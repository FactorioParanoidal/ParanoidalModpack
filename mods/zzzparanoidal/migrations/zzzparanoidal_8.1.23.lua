-- JSON preserves old nuclear-recipe buffers; Lua returns incompatible ingredients intact.
require("controls.energy-recipe-migration").migrate()
