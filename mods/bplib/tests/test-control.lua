local events = require("lib.core.event")

local SERPENT_ARGS = { maxdepth = 5, comment = false, nocode = true }

events.bind("bplib-extract", function(event) log({ "", "bplib-extract" }) end)

events.bind(
	"bplib-positions",
	function(event)
		log({ "", "bplib-positions", serpent.line(event.positions, SERPENT_ARGS) })
	end
)

events.bind(
	"bplib-overlaps",
	function(event)
		log({ "", "bplib-overlaps", serpent.line(event.overlaps, SERPENT_ARGS) })
	end
)
