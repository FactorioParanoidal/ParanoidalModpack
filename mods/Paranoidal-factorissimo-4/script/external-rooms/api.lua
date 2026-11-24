local Registry = require("script.external-rooms.registry")
local Visits = require("script.external-rooms.visits")
local Api = {}

function Api.get_api_info()
    return {major = 1, minor = 0, capabilities = {fixed_host = true, named_doors = true, observer_visit = true, approved_cleanup_entities = true}}
end

function Api.register_kind(spec)
    local ok, result = pcall(Registry.register_kind, spec)
    if ok then return result end
    return {ok = false, code = "invalid-kind", state = "rejected", detail = tostring(result)}
end
function Api.bind_host(request)
    local ok, result = pcall(Registry.bind_host, request)
    if ok then return result end
    return {ok = false, code = "invalid-host", state = "rejected", detail = tostring(result)}
end
Api.enter = Visits.request_enter
Api.leave = Visits.request_leave
Api.get_visit = Visits.get_visit
Api.room_at = Visits.room_at
Api.get_host_state = function(request)
    local id = type(request) == "table" and request.binding_id or request
    return Visits.host_state(Registry.binding(id))
end
Api.retire = Visits.retire_request

function Api.surface_kind(request)
    local value = type(request) == "table" and request.surface_index or request
    if type(value) ~= "string" and not (type(value) == "number" and value >= 1 and value <= 4294967295 and value == math.floor(value)) then return nil end
    local surface = game.get_surface(value)
    return surface and Registry.surface_kind(surface) or nil
end

remote.add_interface("factorissimo-external-rooms", Api)
return Api
