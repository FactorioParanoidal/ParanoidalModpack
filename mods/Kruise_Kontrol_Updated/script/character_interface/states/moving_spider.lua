local util = require("script/character_script_util")
local Moving_spider = {}

Moving_spider.metatable = { __index = Moving_spider }

function Moving_spider.new(Character, destination, radius, timeout)
    return setmetatable({
        type = "moving_spider",
        character = Character,
        spider = Character:get_vehicle(),
        destination = assert(destination),
        radius = radius or 0.5,
        tick_to_timeout = game.tick + (timeout or 3600)
    }, Moving_spider.metatable)
end

function Moving_spider:can_drive()
    local spider = self.spider
    return spider and spider.valid and self.character:get_vehicle() == spider
        and not self.native_override and self.destination.valid ~= false
        and (not self.destination.surface or self.destination.surface == spider.surface)
        and (not self.tick_to_timeout or game.tick <= self.tick_to_timeout)
end

function Moving_spider:matches_route(queue)
    local offset = #self.route - #queue
    if offset < (self.route_offset or 0) then return false end
    for i, position in ipairs(queue) do
        local expected = self.route[offset + i]
        if position.x ~= expected.x or position.y ~= expected.y then return false end
    end
    self.route_offset = offset
    return true
end

function Moving_spider:cleanup()
    -- The engine has no author ID for waypoints. A changed queue or native
    -- remote command relinquishes our claim; only a matching suffix is cleared.
    if self.route and not self.native_override and self.spider.valid then
        local queue = self.spider.autopilot_destinations
        if #queue > 0 and self:matches_route(queue) then
            self.spider.autopilot_destination = nil
        end
    end
end

local spider_mask = {
    colliding_with_tiles_only = true,
    consider_tile_transitions = true,
    layers = { water_tile = true, lava_tile = true }
}
local flags = { cache = false, allow_destroy_friendly_entities = false, prefer_straight_paths = true, no_break = true }
function Moving_spider:request_path()
    local spider = self.spider
    self.path_request_index = spider.surface.request_path({
        bounding_box = spider.prototype.collision_box,
        collision_mask = spider_mask,
        start = spider.position,
        goal = self.destination.position or self.destination,
        force = spider.force,
        radius = self.radius + (self.destination.get_radius and self.destination.get_radius() or 0),
        can_open_gates = true,
        path_resolution_modifier = 0,
        pathfind_flags = flags,
        entity_to_ignore = spider
    })
end

function Moving_spider:finish(reached)
    self:cleanup()
    self.character:finish_movement(reached)
end

function Moving_spider:update()
    if not self:can_drive() then
        self:finish(false)
        return
    end
    local queue = self.spider.autopilot_destinations
    if self.route then
        if not self:matches_route(queue) then
            self.native_override = true
            self:finish(false)
        elseif #queue == 0 then
            self:finish(true)
        end
    elseif #queue > 0 then
        self:finish(false)
    elseif not self.path_request_index then
        self:request_path()
    end
end

function Moving_spider:on_script_path_request_finished(event)
    if event.id ~= self.path_request_index then return end
    self.path_request_index = nil
    local path = event.path
    if not self:can_drive() or not path or #self.spider.autopilot_destinations > 0 then
        self:finish(false)
        return
    end

    -- Skip interior points on straight segments; keep the final destination.
    local previous_direction
    for i, node in ipairs(path) do
        local next_node = path[i + 1]
        local direction = next_node and util.get_orientation_to(node.position, next_node.position)
        if direction ~= previous_direction or not next_node then
            self.spider.add_autopilot_destination(node.position)
        end
        previous_direction = direction
    end
    self.route = self.spider.autopilot_destinations
    if #self.route == 0 then self:finish(true) end
end

return setmetatable(Moving_spider, { __call = function(this, ...) return Moving_spider.new(...) end })
