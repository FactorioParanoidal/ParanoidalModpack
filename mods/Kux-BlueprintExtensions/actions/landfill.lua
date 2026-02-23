local Util = require("modules/util")
local Tempprint = require('actions/tempprint')
local Geom2D = require('modules/geom2d')
local Rect = Geom2D.Rect
local actions = require('modules/actions')

-- COMPATIBILITY 1.1.0
local clear_cursor = function(player)
	if player.clear_cursor then -- renamed in 1.1.0 (from clean_cursor)
		return player.clear_cursor()
	end
	return player.clean_cursor()
end

local Landfill = {
    ALIGNMENT_OVERRIDES = require("actions/snap").ALIGNMENT_OVERRIDES,
    prototypes_computed = false
}

local adjust_box = Geom2D.adjust_box
local get_overlapping_tiles = Geom2D.get_overlapping_tiles

local function requires_landfill(prototype)
	if not prototype.collision_mask then return false end
    local m = prototype.collision_mask.layers
	if not m then return false end
    return (m['water_tile'] or m['item']) and true or false
end

function Landfill.compute_prototype_overrides()
    --if Landfill.prototypes_computed then
    --    return
    --end
    --Landfill.prototypes_computed = true

    -- Some entities require special arguments when created.  We skip those; they're unlikely to come up in blueprints
    -- anyways
    local type_blacklist = {
        ['item-entity'] = true,
        ['item-request-proxy'] = true,
        ['fire'] = true,
        ['entity-ghost'] = true,
        ['particle'] = true,
        ['projectile'] = true,
        ['resource'] = true,
    }

    -- Initial args for creating and destroying entities.
    local args = {position={0, 0}, raise_built=false, create_build_effect_smoke=false}
    local destroy_args = {raise_destroy=false}

    -- Results
    local results = {}
    local t, e

    log("Computing collision box overrides...")

    -- Temporary surface.
    local surface = game.create_surface("_BPEX_Temp_Surface")
    local x, y

    for name, proto in pairs(prototypes.entity) do
        if (
                (not type_blacklist[proto.type])
                and proto.flags and proto.flags["building-direction-8-way"]
                and requires_landfill(proto)
        ) then
            t = {}
            results[name] = t
            args.name = name

            for d = 0, 7 do
                args.direction = d
                e = surface.create_entity(args)
                if not e then
                    game.print("[BlueprintExtensions] Failed to create temporary entity: " .. serpent.line(args))
                    log("[BlueprintExtensions] Failed to create temporary entity: " .. serpent.line(args))
                else
                    local data = {}
                    x = e.position.x
                    y = e.position.y

                    if e.bounding_box then data[#data + 1] = e.bounding_box end
                    if e.secondary_bounding_box then data[#data + 1] = e.secondary_bounding_box end

                    for ix, box in pairs(data) do
                        box.left_top.x = box.left_top.x - x
                        box.left_top.y = box.left_top.y - y
                        box.right_bottom.x = box.right_bottom.x - x
                        box.right_bottom.y = box.right_bottom.y - y
                        data[ix] = Rect.from_box(box)
                    end
                    t[d] = data

                    --log("... [" .. name .. "][" .. d .. "] = " .. serpent.line(t[d]))
                end
                e.destroy()
            end
        end
    end

    game.delete_surface(surface)

    log("...done.")

    storage.prototype_overrides = results
    Landfill.prototype_overrides = results
end


function Landfill.get_prototype_overrides()
    if storage.prototype_overrides then
        return storage.prototype_overrides
    end

    -- Some entities require special arguments when created.  We skip those; they're unlikely to come up in blueprints
    -- anyways
    local type_blacklist = {
        ['item-entity'] = true,
        ['item-request-proxy'] = true,
        ['fire'] = true,
        ['entity-ghost'] = true,
        ['particle'] = true,
        ['projectile'] = true,
        ['resource'] = true,
    }

    -- Initial args for creating and destroying entities.
    local args = {position={0, 0}, raise_built=false, create_build_effect_smoke=false}
    local destroy_args = {raise_destroy=false}

    -- Results
    local results = {}
    local t, e

    log("Computing collision box overrides...")

    -- Temporary surface.
    local surface = game.create_surface("_BPEX_Temp_Surface")
    local x, y

    for name, proto in pairs(prototypes.entity) do
        if (
                (not type_blacklist[proto.type])
                        and proto.flags and proto.flags["building-direction-8-way"]
                        and requires_landfill(proto)
        ) then
            t = {}
            results[name] = t
            args.name = name

            for d = 0, 7 do
                args.direction = d
                e = surface.create_entity(args)
                if not e then
                    game.print("[BlueprintExtensions] Failed to create temporary entity: " .. serpent.line(args))
                    log("[BlueprintExtensions] Failed to create temporary entity: " .. serpent.line(args))
                else
                    local data = {}
                    x = e.position.x
                    y = e.position.y

                    if e.bounding_box then data[#data + 1] = e.bounding_box end
                    if e.secondary_bounding_box then data[#data + 1] = e.secondary_bounding_box end

                    for ix, box in pairs(data) do
                        box.left_top.x = box.left_top.x - x
                        box.left_top.y = box.left_top.y - y
                        box.right_bottom.x = box.right_bottom.x - x
                        box.right_bottom.y = box.right_bottom.y - y
                        data[ix] = Rect.from_box(box)
                    end
                    t[d] = data

                    --log("... [" .. name .. "][" .. d .. "] = " .. serpent.line(t[d]))
                end
                e.destroy()
            end
        end
    end

    game.delete_surface(surface)

    log("...done.")

    storage.prototype_overrides = results
    Landfill.prototype_overrides = results
    return results
end

function Landfill.on_load()
    Landfill.prototype_overrides = storage.prototype_overrides
    if Landfill.prototype_overrides then
        for ent, dirs in pairs(Landfill.prototype_overrides) do
            for dir, rects in pairs(dirs) do
                for _, rect in pairs(rects) do
                    setmetatable(rect, Rect.__mt)
                end
            end
        end
    end
end

function Landfill.destroy_prototype_overrides()
    log("Destroying previous cached prototype information")
    storage.prototype_overrides = nil
    Landfill.prototype_overrides = nil
end

Landfill.on_init = Landfill.destroy_prototype_overrides
Landfill.on_configuration_changed = Landfill.destroy_prototype_overrides

--function Landfill.on_configuration_changed(data)
--    if data and data.mod_changes and data.mod_changes.BlueprintExtensions and not data.mod_changes.BlueprintExtensions.old_version then
--    --if not data.mod_changes.BlueprintExtensions.old_version then
--        log("We're being added to a new save, assuming collision box overrides already computed in on_init")
--    else
--        Landfill.compute_prototype_overrides()
--    end
--end

--Landfill.on_configuration_changed = Landfill.compute_prototype_overrides

---
---@param player LuaPlayer
---@param event any
---@param action any
function Landfill.landfill_action(player, event, action)
	log("landfill_action")
    local bp = Util.get_blueprint(player)
    if not bp then return end
    local prototypes = prototypes.entity  -- Save lookups
    local prototype

    -- How many landfilled tiles already existed.  When we convert back to a list of tiles, we subtract the number
    -- of landfilled tiles we process.  If the result is nonzero, we changed something.
    local landfilled_tiles = 0

    -- Collect current blueprint info.
    local entities = bp.get_blueprint_entities()
    if not entities then
        player.print({"bpex.landfill_no_entities_in_bp"})
        return
    end

    -- Map all current tiles.
    local tilemap = {}
    setmetatable(tilemap, { __index = function(t, k) local v = {}; t[k] = v; return v; end })
    local tiles = bp.get_blueprint_tiles()
    if tiles then
        for _, tile in pairs(tiles) do
            tilemap[tile.position.x][tile.position.y] = tile.name
            if tile.name == 'landfill' then landfilled_tiles = landfilled_tiles + 1 end
        end
    end

    -- Offset based on blueprint contents
    -- Normally, this is +0.5 but rails will mess with it.
    local overrides = Landfill.ALIGNMENT_OVERRIDES
    local offset = 0.5
    for _, entity in pairs(entities) do
        prototype = prototypes[entity.name]
        if overrides[prototype.type] then
            offset = 0
            break
        end
    end

    -- Loop through entities
    local name
    overrides = Landfill.get_prototype_overrides()
    local override
    local rect

    for _, entity in pairs(entities) do
        name = entity.name
        prototype = prototypes[entity.name]
        if not prototype then goto next end
        --if not proto.collision_mask['water-tile'] then goto next end
        if not requires_landfill(prototype) then goto next end

        local x = (entity.position.x or 0) + offset
        local y = (entity.position.y or 0) + offset
        local direction = entity.direction or 0

        override = (overrides and overrides[name] and overrides[name][direction]) or nil

        if override then
            for _, source in pairs(override) do
                rect = source:clone(rect):translate(x, y)
                tilemap = rect:tiles(tilemap, 'landfill')
            end
        else
            if prototype.collision_box then
                rect = Rect.from_box(prototype.collision_box):rotate(direction):translate(x, y)
                tilemap = rect:tiles(tilemap, 'landfill')
            end
            if prototype.secondary_collision_box then
                rect = Rect.from_box(prototype.secondary_collision_box):rotate(direction):translate(x, y)
                tilemap = rect:tiles(tilemap, 'landfill')
            end
        end
        ::next::
    end

    -- Reconstruct list of tiles
    tiles = {}
    for x, ys in pairs(tilemap) do
        for y, tile in pairs(ys) do
            if tile == 'landfill' then
                landfilled_tiles = landfilled_tiles - 1
                tiles[#tiles + 1] = {name=tile, position={x=x,y=y}}
            end
        end
    end

    if landfilled_tiles == 0 then
        player.print({"bpex.landfill_bp_unchanged"})
        return
    end

    local mode = player.mod_settings["Kux-BlueprintExtensions_landfill-mode"].value
    if mode == 'update' then    -- Update the existing blueprint.
        bp.set_blueprint_tiles(tiles)
        return
    end

    local blueprint_icons = bp.preview_icons
    local label = bp.label
    local label_color = bp.label_color
    name = bp.name

    if not player.clear_cursor() then
        player.print({"bpex.error_cannot_set_stack"})
        return
	end

    local stack = player.cursor_stack or error("invalid state")
    stack.set_stack(name)
    stack.set_blueprint_entities(entities)
    stack.set_blueprint_tiles(tiles)
    if label then stack.label = label end
    if label_color then stack.label_color = label_color end
    if blueprint_icons then stack.preview_icons = blueprint_icons end

    if mode == 'tempcopy' then
        Tempprint.set_temporary(player)
    end

    return
end


actions['Kux-BlueprintExtensions_landfill'].handler = Landfill.landfill_action

EventDistributor.register("on_init",Landfill.on_init)
EventDistributor.register("on_load",Landfill.on_load)
EventDistributor.register("on_configuration_changed",Landfill.on_configuration_changed)

return Landfill