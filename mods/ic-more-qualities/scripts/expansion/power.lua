-- Hidden electric consumers that follow a host entity: the electricity of the refinement workshop
-- and the extra power of careful/precise production modes. Consumption is native (smooth for the
-- electric network); the buffer level tells how well the consumer is supplied.
local M = {}

function M.create(host, name)
    if not (host and host.valid and prototypes.entity[name]) then return nil end
    local interface = host.surface.create_entity({
        name = name, position = host.position, force = host.force,
        create_build_effect_smoke = false, raise_built = false,
    })
    if not interface then return nil end
    interface.destructible = false
    interface.power_usage = 0
    interface.electric_buffer_size = 1
    return interface
end

-- per_tick: energy in J per tick.
function M.set(interface, per_tick)
    if not (interface and interface.valid) then return end
    per_tick = math.max(0, per_tick or 0)
    if math.abs(interface.power_usage - per_tick) > 1e-6 then
        interface.power_usage = per_tick
        interface.electric_buffer_size = math.max(1, per_tick * 4)
    end
end

-- 1 = fully supplied (buffer at least half full), 0 = no power at all.
function M.satisfaction(interface)
    if not (interface and interface.valid) then return 1 end
    if interface.power_usage <= 0 then return 1 end
    return math.max(0, math.min(1, interface.energy / (interface.electric_buffer_size * 0.5)))
end

function M.destroy(interface)
    if interface and interface.valid then interface.destroy() end
end

return M
