local rpath = (...):match("(.-)[^%.]+$")
local Setting = require(rpath .. "setting")
local migration = require(rpath .. "migration")
local technology = require(rpath .. "technology")
local forces = require(rpath .. "forces")
local network = require(rpath .. "heat.network")
local interface = require(rpath .. "entity.interface")
local reactor = require(rpath .. "entity.reactor")
local fallout = require(rpath .. "entity.fallout")
local tower = require(rpath .. "entity.tower")
local ruin = require(rpath .. "entity.ruin")
local gui = require(rpath .. "gui.init")





local function load()
	network.load()
end


local function init()
	global.random = game.create_random_generator()
	global.lightEffects = {}

	global.sarcophagus = {}
	global.interfaces = {} -- global.interfaces stores the interface ghost circuit connections at x,y,z
	global.reactors = {} -- global.reactors stores the reactor and its parts(core, circuit interface, eccs)
	global.towers = {} -- global.towers stores the cooling tower and the steam maker entity
	global.ruins = {} -- global.ruins stores reactor ruins

	global.geigers = {}
	global.fallout = {}
	global.delayed_fallout = {}

	gui.init()
	forces.init()
	technology.init()
	network.init()

	load()
	--game.write_file("RealisticReactors.log"," ") -- this line cleans the log file on game start
end


local function on_tick(tick)
	--global.dbg = 1
	interface.tick(tick)
	fallout.tick(tick)
	reactor.tick(tick)
	tower.tick(tick)
	ruin.tick(tick)
	gui.tick(tick)
end


return { -- exports
	init = init,
	load = load,
	tick = on_tick,
	migration = migration,
}
