local infection = require("script.infection")
local arrival = require("script.arrival")
local units = require("script.units")
local train = require("script.train")
local outbreak = require("script.outbreak")
local config = require("script.config")

local the_beast = {}

the_beast.force_name = "the-beast"

-- Only what the scripts care about dying or being hurt: the infection markers (infection.lua), the creatures (units.lua)
-- and the lair's core (outbreak.lua). Without it, every biter that dies or is hit anywhere would be looked at. The event
-- handler registers events without filters, so this goes after it, on every load.
local function filter_events()
  script.set_event_filter(defines.events.on_entity_died,
  {
    {filter = "name", name = "beast-infection"},
    {filter = "type", type = "spider-unit"},
    {filter = "name", name = "beast-lair-core"}
  })
  script.set_event_filter(defines.events.on_entity_damaged,
  {
    {filter = "type", type = "spider-unit"},
    {filter = "name", name = "beast-lair-core"}
  })
end

local function setup()
  storage.the_beast = storage.the_beast or {}
  local force = game.forces[the_beast.force_name] or game.create_force(the_beast.force_name)
  force.set_cease_fire("enemy", true)
  game.forces["enemy"].set_cease_fire(force, true)
end

the_beast.on_init = function()
  setup()
  filter_events()
end
the_beast.on_load = filter_events
the_beast.on_configuration_changed = setup

the_beast.add_remote_interface = function()
  remote.add_interface("the_beast",
  {
    -- On purpose, so wherever it is.
    infect = function(entity) return infection.infect(entity, true) end,
    is_infected = infection.is_infected,
    stats = function()
      local infected, active = infection.stats()
      return {infected = infected, active = active, carriages_arrived = train.arrived_count()}
    end,
    spawn = units.spawn,
    set_pace = units.set_pace,
    arrive = function()
      if not arrival.can_arrive() then return false end
      local drill = arrival.find_outpost(true)
      if drill then arrival.arrive(drill) end
      return drill ~= nil
    end,
    -- The outbreak: what it's up to, and for tests and admins, its research stage and hurrying it along ("landing",
    -- "found", "raid", "analyse", "clone", "rails", "ride", "fire": see outbreak.hurry and the hurry hooks).
    outbreak = outbreak.status,
    configure = config.configure,
    set_tier = outbreak.set_tier,
    hurry = outbreak.hurry,
    -- For admins and tests: a building set down at the lair as if it had been carried home, with its sample.
    lair_place = outbreak.place_at_lair,
    catalogue = function()
      return storage.outbreak and storage.outbreak.catalogue or {}
    end
  })
end

return the_beast
