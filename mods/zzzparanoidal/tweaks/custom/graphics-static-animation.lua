-- Accepted building masks: one holed static frame plus the original-size animation overlay.
-- Run after reskins and IC's previews/mode twins. No entity, recipe or runtime behaviour changes.
local sources = require("__zzzparanoidal__/tweaks/custom/graphics-static-animation-data")
local M = {}

local function dimensions(node)
    local size = node.size
    local width, height = node.width, node.height
    if type(size) == "number" then
        width, height = width or size, height or size
    elseif type(size) == "table" then
        width, height = width or size[1], height or size[2]
    end
    return width, height
end

function M.apply(raw, logger)
    local seen, counts = {}, {}
    local function walk(node)
        if type(node) ~= "table" or seen[node] then return end
        seen[node] = true
        local source = sources[node.filename]
        if source then
            local width, height = dimensions(node)
            local filename = node.filename
            local function check(condition, reason)
                assert(condition, "graphics-static-animation: " .. filename .. ": " .. reason)
            end
            check(not node.layers and not node.stripes and not node.filenames, "expected a single sheet")
            check(width == source.width and height == source.height, "frame dimensions changed")
            check((node.x or 0) == 0 and (node.y or 0) == 0 and not node.position, "unexpected sheet offset")
            check((node.direction_count or 1) == 1, "multi-direction sheet is not supported")
            local frames = node.frame_count or 1
            local count = counts[filename] or {animations = 0, pictures = 0}
            counts[filename] = count
            if frames == 1 then
                -- IC defect silhouettes use the intact reference frame, not a holed base by itself.
                check(not node.frame_sequence, "unexpected sequence on a single picture")
                node.filename = source.reference
                count.pictures = count.pictures + 1
            else
                check(frames == source.frames and node.line_length == source.columns, "frame layout changed")
                check(not node.run_mode or node.run_mode == "forward", "unsupported playback mode")
                check(not node.allow_reducing_frames, "frame reduction would desynchronise layers")
                local cycle = frames
                if node.frame_sequence then
                    cycle = #node.frame_sequence
                    check(cycle > 0, "empty sequence")
                    for _, frame in ipairs(node.frame_sequence) do
                        check(frame >= 1 and frame <= frames and frame == math.floor(frame), "sequence frame out of range")
                    end
                end
                local repeats = cycle * (node.repeat_count or 1)
                check(repeats >= 1 and repeats <= 255 and repeats == math.floor(repeats), "static repeat_count exceeds uint8")
                local base, animation = table.deepcopy(node), table.deepcopy(node)
                animation.filename = source.animation
                base.filename = source.static
                base.frame_count, base.repeat_count, base.line_length = 1, repeats, 1
                base.frame_sequence = nil
                -- Nested Animation.layers are native. Parent WorkingVisualisation flags (fadeout,
                -- always_draw, recipe tint) stay outside this node and still apply to both layers.
                -- Both children retain the original tint, scale, shift, speed and draw flags.
                for key in pairs(node) do node[key] = nil end
                node.layers = {base, animation}
                count.animations = count.animations + 1
            end
            return
        end
        for _, child in pairs(node) do
            if type(child) == "table" then walk(child) end
        end
    end
    for _, prototypes in pairs(raw) do
        for _, prototype in pairs(prototypes) do walk(prototype) end
    end
    if logger then
        local parts = {}
        for filename, count in pairs(counts) do
            parts[#parts + 1] = filename .. "=" .. count.animations .. " animations/" .. count.pictures .. " pictures"
        end
        table.sort(parts)
        logger("graphics-static-animation: " .. (#parts > 0 and table.concat(parts, "; ") or "no matching sources"))
    end
    return counts
end

return M
