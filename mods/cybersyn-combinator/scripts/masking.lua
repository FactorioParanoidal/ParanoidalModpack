local constants = require "scripts.constants"
local util = require "__core__.lualib.util"

local supper = string.upper
local sformat = string.format
local ssub = string.sub
local smatch = string.match
local gsub = string.gsub
local band = bit32.band
local bextract = bit32.extract

local INT32_MASK = 0xFFFFFFFF
local INT32_MSB = 0x80000000

--- @enum Mode
local Mode = {
  DECIMAL = 1,
  HEX = 2,
  BINARY = 3,
  OCTAL = 4
}

--- @type { [Mode]: string }
local PREFIXES = {
  [Mode.DECIMAL] = "0d",
  [Mode.HEX] = "0x",
  [Mode.BINARY] = "0b",
  [Mode.OCTAL] = "0o"
}

local PREFIX_PATTERN = "^[^0-9A-Fa-f]*0[%s%-]*[dDxXbBoO]"

--- @type { [string]: Mode }
local PREFIX_TO_MODE = {
  ["0D"] = Mode.DECIMAL,
  ["0X"] = Mode.HEX,
  ["0B"] = Mode.BINARY,
  ["0O"] = Mode.OCTAL
}

--- @param input string
--- @return string, boolean
local function extract_sign(input)
  local stripped = (gsub(input, "^[^0-9A-Fa-f%-]*", ""))
  local has_sign = ssub(stripped, 1, 1) == "-"
  if has_sign then stripped = ssub(stripped, 2) end
  return stripped, has_sign
end

--- Strips non-numbers and non-hexadecimal letters from the input string.
--- @param input string
--- @return string
local function strip(input)
  return (gsub(input, "[^0-9A-Fa-f]", ""))
end

-- We need custom helper functions to handle negative integers

--- Formats a 32-bit signed integer to hexadecimal,
--- bits after the 32nd are discarded.
--- @param int integer
--- @return string
local function int32_to_hex(int)
  local result = ""
  for o = 0, 7 do
    local byte = bextract(int, o * 4, 4)
    local hex = sformat("%X", byte)
    result = hex .. result
  end

  return result
end

--- Formats a 32-bit signed integer to binary,
--- bits after the 32nd are discarded.
--- @param int integer
--- @return string
local function int32_to_bin(int)
  local result = ""
  for o = 0, 31 do
    local bit = bextract(int, o, 1)
    result = tostring(bit) .. result
  end

  return result
end

--- Formats a 32-bit signed integer to octal,
--- bits after the 32nd are discarded.
--- @param int integer
--- @return string
local function int32_to_oct(int)
  local result = ""
  for o = 0, 10 do
    local octal = bextract(int, o * 3, o == 10 and 2 or 3)
    local oct = sformat("%o", octal)
    result = oct .. result
  end

  return result
end

--- @param uint uint|integer
--- @return integer
local function uint_to_int(uint)
  local uint32 = band(uint, INT32_MASK)
  local neg = band(uint32, INT32_MSB) == INT32_MSB
  if not neg then return uint32 end
  -- See: https://stackoverflow.com/questions/37411564/hex-to-int32-value
  return (uint32 + 2^31) % 2^32 - 2^31
end

--- @param input string
--- @param base uint
--- @return integer?
local function parse_base(input, base)
  local has_sign = false
  if base == 10 then
    input, has_sign = extract_sign(input)
  end
  local stripped = strip(input)
  if not stripped or stripped == "" then return nil end
  if has_sign then stripped = "-" .. stripped end
  local num = tonumber(stripped, base)
  if not num then return nil end
  return uint_to_int(num)
end

local FORMAT_DECIMAL = "%d"

--- @type { [Mode]: fun(mask: integer): string }
local FORMATTERS = {
  [Mode.DECIMAL] = function(mask) return sformat(FORMAT_DECIMAL, mask) end,
  [Mode.HEX] = int32_to_hex,
  [Mode.BINARY] = int32_to_bin,
  [Mode.OCTAL] = int32_to_oct
}

--- @type { [Mode]: fun(input: string): integer? }
local PARSERS = {
  [Mode.DECIMAL] = function(input) return parse_base(input, 10) end,
  [Mode.HEX] = function(input) return parse_base(input, 16) end,
  [Mode.BINARY] = function(input) return parse_base(input, 2) end,
  [Mode.OCTAL] = function(input) return parse_base(input, 8) end
}

--- @param player LuaPlayer|uint|string?
--- @return Mode mode, boolean prefix
local function get_format_settings(player)
  if not player then return Mode.DECIMAL, false end
  local psettings = settings.get_player_settings(player)
  local mode_setting = psettings[constants.SETTINGS.NETWORK_MASK_DISPLAY_MODE].value
  local prefix_setting = psettings[constants.SETTINGS.NETWORK_MASK_DISPLAY_PREFIX].value
  local mode = Mode[mode_setting] or Mode.DECIMAL
  local prefix = prefix_setting == true
  return mode, prefix
end

--- @param player LuaPlayer|uint|string?
--- @return boolean
local function get_is_hex_mode(player)
  if not player then return false end
  local psettings = settings.get_player_settings(player)
  local parse_mode = psettings[constants.SETTINGS.NETWORK_MASK_PARSE_MODE].value
  return parse_mode == "HEX"
end

local masking = {
  Mode = Mode,
  uint_to_int = uint_to_int
}

local PRETTIFIERS = {
  [Mode.DECIMAL] = function(s) return util.format_number(tonumber(s), false) end,
  [Mode.HEX] = function(s) return gsub(s, "..", "%0 ") end,
  [Mode.BINARY] = function(s) return gsub(s, "....", "%0 ") end
}

--- @param mask integer
--- @param mode Mode
--- @param use_prefix boolean
--- @param pretty boolean?
--- @return string
function masking.format_explicit(mask, mode, use_prefix, pretty)
  local formatter = FORMATTERS[mode]
  local formatted = formatter(mask)
  if pretty and PRETTIFIERS[mode] then formatted = PRETTIFIERS[mode](formatted) end
  if use_prefix then
    return PREFIXES[mode] .. formatted
  else
    return formatted
  end
end

--- Formats a network mask for display.
--- If `player` is given, it will format with respect to the "use hex masks" and
--- "display prefix" setting, otherwise it will assume decimal format and no prefix.
--- @param mask integer
--- @param player LuaPlayer|uint|string?
--- @param pretty boolean?
--- @return string
function masking.format(mask, player, pretty)
  local mode, should_prefix = get_format_settings(player)
  return masking.format_explicit(mask, mode, should_prefix, pretty)
end

--- @param mask integer
--- @param player PlayerIdentification?
function masking.format_for_input(mask, player)
  if get_is_hex_mode(player) then
    return masking.format_explicit(mask, Mode.HEX, false, false)
  end

  local mode, _ = get_format_settings(player)
  return masking.format_explicit(mask, mode, mode ~= Mode.DECIMAL, false)
end

--- Parses the input string to a network mask.
--- If `player` is given, it will parse with respect to the "use hex masks" setting,
--- otherwise it will assume decimal format if no prefix is specified.
---
--- - If the prefix '0x' is specified, input string will always be treated as hexadecimal.
--- - If the prefix '0b' is specified, input string will always be treated as binary.
--- - If the prefix '0d' is specified, input string will always be treated as decimal.
--- - If the prefix '0o' is specified, input string will always be treated as octal.
---
--- Invalid or empty strings will return `0`.
--- @param input string?
--- @param player LuaPlayer|uint|string?
--- @return integer
function masking.parse(input, player)
  if not input then return 0 end
  local has_sign = false
  local is_hex_mode = get_is_hex_mode(player)
  if not is_hex_mode then
    input, has_sign = extract_sign(input)
  end
  local prefix = smatch(input, PREFIX_PATTERN)
  local rest
  if prefix then
    prefix = supper(prefix)
    rest = ssub(input, 3)
  else
    rest = input
  end
  if has_sign then rest = "-" .. rest end
  if is_hex_mode then
    local hex_input
    -- Be a little kind and accept hex and octal prefix even in the strict hex input mode
    -- 'X' and 'O' are not valid hexadecimal digits anyway
    if prefix == "0X" or prefix == "0O" then
      hex_input = rest
    else
      hex_input = input
    end

    local parser = PARSERS[Mode.HEX]
    local parsed = parser(hex_input)

    if not parsed then return 0 end

    return parsed
  end
  local mode = PREFIX_TO_MODE[prefix] or Mode.DECIMAL
  local parser = PARSERS[mode]
  local parsed = parser(rest)
  if not parsed then return 0 end
  return parsed
end

return masking
