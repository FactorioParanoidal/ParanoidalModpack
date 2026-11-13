-- Keep reductions in the final atlas walk: inherited graphics, modes and later clones share the corrected layout.
local D = require("tweaks.custom.graphics-atlas-reductions-data")
local M = {}

function M.icon(t, key, size_key)
    local spec = D.icons[t[key]]
    if not spec then return false end
    local size = t[size_key] or 64
    assert(size == 256, "Сокращение атласа: неожиданный размер значка для " .. t[key])
    t[key], t[size_key] = spec.file, spec.size
    if key == "icon" and t.scale then t.scale = t.scale * size / spec.size end
    return true
end

function M.sprite(t)
    local file = t.filename or (type(t.filenames) == "table" and t.filenames[1])
    local spec = D.sprites[file]
    if not spec then return false end
    local size = t.size
    local width = t.width or (type(size) == "table" and size[1] or size)
    local height = t.height or (type(size) == "table" and size[2] or size)
    assert(width == spec.width and height == spec.height, "Сокращение атласа: неожиданный размер кадра для " .. file)
    if spec.sequence then
        assert((t.x or 0) == 0 and (t.y or 0) == 0 and not t.position, "Сокращение атласа: у уплотнённого спрайта есть смещение")
        assert((t.direction_count or 1) == 1, "Сокращение атласа: уплотнённый спрайт повёрнут")
        local count = t.frame_count or 1
        if count > 1 then
            assert(count == #spec.sequence, "Сокращение атласа: неожиданное число кадров уплотнённого спрайта")
            local sequence = {}
            for i, frame in ipairs(t.frame_sequence or spec.sequence) do
                -- The generated map is already the natural playback order; existing sequences name source frames.
                sequence[i] = t.frame_sequence and assert(spec.sequence[frame], "Сокращение атласа: отсутствует исходный кадр") or frame
            end
            t.frame_count, t.frame_sequence = spec.frames, sequence
        end
        t.line_length = spec.columns
    else
        local factor, scale = spec.factor, t.scale or 1
        local px = (spec.new_width * factor - width) / 2
        local py = (spec.new_height * factor - height) / 2
        if px ~= 0 or py ~= 0 then
            local shift = t.shift or {0, 0}
            t.shift = {(shift[1] or shift.x or 0) + px * scale / 32,
                       (shift[2] or shift.y or 0) + py * scale / 32}
        end
        t.size, t.width, t.height = nil, spec.new_width, spec.new_height
        t.scale = scale * factor
        if t.x then t.x = t.x / factor end
        if t.y then t.y = t.y / factor end
        if t.position then t.position = {t.position[1] / factor, t.position[2] / factor} end
    end
    if t.filename then
        t.filename = spec.file
    else
        local files = {}
        for i, source in ipairs(t.filenames) do
            local entry = assert(D.sprites[source], "Сокращение атласа: смешанные листы спрайтов")
            assert(entry.width == width and entry.height == height, "Сокращение атласа: смешанная геометрия кадров")
            files[i] = entry.file
        end
        t.filenames = files
    end
    return true
end

return M
