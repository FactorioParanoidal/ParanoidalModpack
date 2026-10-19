-- Rebuild only the existing wooden pipe from the ordinary pipe prototype.
-- Runs after Squeak Through; no new entities or runtime handlers are needed.
local wooden = data.raw.pipe["bi-wood-pipe"]
local ordinary = data.raw.pipe.pipe
if not wooden or not ordinary then return end

local pipe = table.deepcopy(ordinary)
-- Keep the wooden item's identity, durability, mining result and menu placement.
for _, field in ipairs({
    "name", "icon", "icons", "icon_size", "localised_name", "localised_description",
    "minable", "max_health", "resistances", "corpse", "subgroup", "order", "friendly_map_color",
}) do
    pipe[field] = table.deepcopy(wooden[field])
end

-- Retain only the wooden body sprites. Fluid/window rendering comes from base.
for key, sprite in pairs(wooden.pictures) do
    if sprite.filename and string.find(sprite.filename, "/wood_products/wood_pipe/", 1, true) then
        local picture = table.deepcopy(sprite)
        -- BI's atlas replacement leaves old base dimensions on the single pipe.
        -- Use one unambiguous rectangle, not size plus stale width/height.
        if picture.size then
            picture.width = nil
            picture.height = nil
        end
        pipe.pictures[key] = picture
    end
end

pipe.fluid_box.hide_connection_info = true
pipe.icon_draw_specification = table.deepcopy(ordinary.icon_draw_specification)
pipe.tile_width = 1
pipe.tile_height = 1
-- Ordinary pipe connections need the 0.1-tile border; ±0.45 breaks placement.
-- ±0.4 blocks the current character without changing other pipes or characters.
pipe.collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } }
data.raw.pipe[pipe.name] = pipe
