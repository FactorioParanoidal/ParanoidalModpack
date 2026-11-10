-- Explicit build sizes after ReStack; leave all other item and container properties intact.
local stack_sizes = {
    y_alien_solar2 = 10,
    ["bi-wooden-chest-giga"] = 10,
    y_alien_solar = 20,
    ["y-winding"] = 50,
    ["bi-wooden-chest-huge"] = 25,
    ["bi-wooden-chest-large"] = 50,
    torch = 50,
    y_toolhead = 100,
    y_toolhead_broken = 100,
    ye_package_fish2 = 100,
    y_catalyst_bp = 300,
    y_catalyst_ft = 300,
    ["y-fuel-reactor"] = 300,
    ["y-infused-mud"] = 600,
    ye_rawmeat = 1000,
}

for name, stack_size in pairs(stack_sizes) do
    local item = data.raw.item[name]
    if item then
        item.stack_size = stack_size
    end
end
