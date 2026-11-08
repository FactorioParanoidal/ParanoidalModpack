-- Read the data-only subset emitted by serpent.dump, never execute an imported chunk.
-- Supports shared table references (Helmod's blocks/root), but rejects cycles, code,
-- non-finite numbers and excessive size/depth. Export format stays compatible.
local M = {max_bytes = 8 * 1024 * 1024}
local MAX_DEPTH, MAX_NODES = 64, 200000
local escapes = {a = "\a", b = "\b", f = "\f", n = "\n", r = "\r", t = "\t", v = "\v",
  ["\\"] = "\\", ['"'] = '"', ["'"] = "'"}

local function parse(text)
  assert(type(text) == "string" and #text <= M.max_bytes, "import size")
  local pos, nodes = 1, 0
  local function skip()
    local _, last = text:find("^%s*", pos)
    pos = (last or pos - 1) + 1
  end
  local function take(s)
    skip()
    if text:sub(pos, pos + #s - 1) ~= s then return false end
    if s:match("[%w_]$") and text:sub(pos + #s, pos + #s):match("[%w_]") then return false end
    pos = pos + #s
    return true
  end
  local function need(s) assert(take(s), "expected " .. s) end
  local function identifier()
    skip()
    local name = text:match("^[_%a][_%w]*", pos)
    assert(name, "expected key")
    pos = pos + #name
    return name
  end
  local function quoted()
    skip()
    local quote = text:sub(pos, pos)
    assert(quote == '"' or quote == "'", "expected string")
    pos = pos + 1
    local out, start = {}, pos
    while pos <= #text do
      local ch = text:sub(pos, pos)
      if ch == quote then
        out[#out + 1] = text:sub(start, pos - 1)
        pos = pos + 1
        return table.concat(out)
      elseif ch == "\\" then
        out[#out + 1] = text:sub(start, pos - 1)
        pos = pos + 1
        local esc = text:sub(pos, pos)
        if escapes[esc] then
          out[#out + 1] = escapes[esc]
          pos = pos + 1
        elseif esc:match("%d") then
          local digits = text:match("^%d%d?%d?", pos)
          local byte = tonumber(digits)
          assert(byte <= 255, "invalid escape")
          out[#out + 1] = string.char(byte)
          pos = pos + #digits
        elseif esc == "x" then
          local hex = text:sub(pos + 1, pos + 2)
          assert(hex:match("^%x%x$"), "invalid hex escape")
          out[#out + 1] = string.char(tonumber(hex, 16))
          pos = pos + 3
        elseif esc == "z" then
          pos = pos + 1
          skip()
        elseif esc == "\n" or esc == "\r" then
          out[#out + 1] = "\n"
          pos = pos + 1
          if esc == "\r" and text:sub(pos, pos) == "\n" then pos = pos + 1 end
        else
          error("invalid escape")
        end
        start = pos
      else
        assert(ch ~= "\n" and ch ~= "\r", "unescaped newline")
        pos = pos + 1
      end
    end
    error("unterminated string")
  end
  local value
  local function key(depth)
    local k = value(depth)
    assert(type(k) == "string" or type(k) == "number", "invalid key")
    return k
  end
  value = function(depth)
    nodes = nodes + 1
    assert(depth <= MAX_DEPTH and nodes <= MAX_NODES, "import complexity")
    skip()
    local ch = text:sub(pos, pos)
    if ch == '"' or ch == "'" then return quoted() end
    if take("true") then return true end
    if take("false") then return false end
    if take("nil") then return nil end
    if take("{") then
      local result, index = {}, 1
      while not take("}") do
        local k, v
        if take("[") then
          k = key(depth + 1)
          need("]")
          need("=")
          v = value(depth + 1)
        else
          skip()
          local saved = pos
          local name = text:match("^[_%a][_%w]*", pos)
          if name then pos = pos + #name end
          if name and take("=") then
            k, v = name, value(depth + 1)
          else
            pos = saved
            k, v = index, value(depth + 1)
            index = index + 1
          end
        end
        result[k] = v
        if not take(",") and not take(";") then need("}"); break end
      end
      return result
    end
    -- Lua's decimal/exponent and hexadecimal number literals, no arithmetic.
    local literal = text:match("^%-?0[xX][%x%.]+[pP][%+%-]?%d+", pos)
      or text:match("^%-?0[xX][%x%.]+", pos)
      or text:match("^%-?%d*%.?%d+[eE][%+%-]?%d+", pos)
      or text:match("^%-?%d*%.?%d+", pos)
    local n = literal and tonumber(literal)
    assert(n and n == n and n ~= math.huge and n ~= -math.huge, "expected finite number")
    pos = pos + #literal
    return n
  end
  need("do"); need("local"); need("_"); need("=")
  local root = value(1)
  assert(type(root) == "table", "expected table")
  need(";")
  -- Serpent may declare an auxiliary table for references. Table-valued keys are
  -- not Helmod model data and deliberately remain unsupported.
  if take("local") then need("__"); need("="); need("{"); need("}"); need(";") end
  local function path()
    need("_")
    local parent, k, object = nil, nil, root
    local depth = 0
    while true do
      if take(".") then k = identifier()
      elseif take("[") then k = key(1); need("]")
      else break end
      depth = depth + 1
      assert(depth <= MAX_DEPTH and type(object) == "table", "invalid reference")
      parent, object = object, object[k]
    end
    return object, parent, k
  end
  while not take("return") do
    nodes = nodes + 1
    assert(nodes <= MAX_NODES, "too many references")
    local _, parent, k = path()
    assert(parent, "cannot replace root")
    need("=")
    local object = path()
    parent[k] = object
    need(";")
  end
  need("_"); need(";"); need("end")
  skip()
  assert(pos > #text, "trailing code")
  -- Count the expanded graph too: a small DAG can otherwise explode in copyBlock.
  local active, expanded = {}, 0
  local function check(t, depth)
    expanded = expanded + 1
    assert(expanded <= MAX_NODES and depth <= MAX_DEPTH, "expanded import complexity")
    if type(t) ~= "table" then return end
    assert(not active[t], "cyclic import")
    active[t] = true
    for _, v in pairs(t) do check(v, depth + 1) end
    active[t] = nil
  end
  check(root, 1)
  return root
end

function M.read(text)
  local ok, result = pcall(parse, text)
  if ok then return result end
  return nil
end

return M
