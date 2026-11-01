-- Inlaid lamps first: they put the vanilla lamp into the "lamps" replace group that the hidden pole lamps copy.
require("prototypes.inlaid")
require("prototypes.lamps")
require("prototypes.poles")
-- Drill lights in data.lua: copies made later (relic drills, per-resource variants) inherit them.
require("prototypes.status-lights").drills()
