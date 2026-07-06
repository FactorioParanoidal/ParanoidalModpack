local textplates = {}

textplates.support_legacy = true

-- This file runs both in data and control phases so we need to check both `mods` and `game.active_mods`
local function is_mod_active(mod_name)
  return (mods and mods[mod_name]) or (script and script.active_mods and script.active_mods[mod_name])
end

textplates.build = function()

  -- other mods can call this to get a copy of the symbols list
  get_textplates_symbols = function()
    local symbols = {"blank", "square", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
      "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
      "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
      "arrow_n", "arrow_s", "arrow_w", "arrow_e", "arrow_nw", "arrow_ne", "arrow_sw", "arrow_se",
      "bracket_left", "bracket_right",
      "squarebracket_left", "squarebracket_right",
      "curlybracket_left", "curlybracket_right",
      "greater", "less", "hat", "equals", "minus", "plus", "multiply", "divide", "percent",
      "ampersand", "pipe", "exclamation", "question",
      "colon", "semicolon", "stop", "comma",
      "quotes_single_left", "quotes_single_right", "quotes_double_left", "quotes_double_right",
      "at", "hash", "circle", "ring", "cog"
    }
    if is_mod_active("space-exploration") then
      for _, symbol in pairs({"epsilon", "gamma", "lambda", "omega", "phi", "theta", "xi", "zeta"}) do
        table.insert(symbols, symbol)
      end
    end
    return symbols
  end

  textplates.symbols = get_textplates_symbols()

  textplates.symbol_by_char = {
    a = "a",
    b = "b",
    c = "c",
    d = "d",
    e = "e",
    f = "f",
    g = "g",
    h = "h",
    i = "i",
    j = "j",
    k = "k",
    l = "l",
    m = "m",
    n = "n",
    o = "o",
    p = "p",
    q = "q",
    r = "r",
    s = "s",
    t = "t",
    u = "u",
    v = "v",
    w = "w",
    x = "x",
    y = "y",
    z = "z",
    ["0"] = "0",
    ["1"] = "1",
    ["2"] = "2",
    ["3"] = "3",
    ["4"] = "4",
    ["5"] = "5",
    ["6"] = "6",
    ["7"] = "7",
    ["8"] = "8",
    ["9"] = "9",
    ["^"] = "hat",
    ["@"] = "at",
    ["."] = "stop",
    [","] = "comma",
    ["'"] = "quotes_single_right",
    ["\""] = "quotes_double_right",
    [":"] = "colon",
    [";"] = "semicolon",
    ["("] = "bracket_left",
    ["["] = "squarebracket_left",
    ["{"] = "curlybracket_left",
    [")"] = "bracket_right",
    ["]"] = "squarebracket_right",
    ["}"] = "curlybracket_right",
    ["<"] = "less",
    [">"] = "greater",
    ["/"] = "divide",
    ["\\"] = "divide",
    ["|"] = "pipe",
    ["%"] = "percent",
    ["*"] = "multiply",
    ["+"] = "plus",
    ["-"] = "minus",
    ["_"] = "ring",
    [" "] = "cog",
    ["="] = "equals",
    ["&"] = "ampersand",
    ["?"] = "question",
    ["!"] = "exclamation",
    ["#"] = "hash",
    ["ε"] = "epsilon",
    ["γ"] = "gamma",
    ["λ"] = "lambda",
    ["ω"] = "omega",
    ["φ"] = "phi",
    ["θ"] = "theta",
    ["ξ"] = "xi",
    ["ζ"] = "zeta",
  }

  textplates.types = {}

  local materials = {
    ["stone"] = "stone-brick",
    ["iron"] = "iron-plate",
    ["copper"] = "copper-plate",
    ["steel"] = "steel-plate",
    ["concrete"] = "concrete",
    ["glass"] = "stone",
    ["gold"] = "sulfur",
    ["plastic"] = "plastic-bar",
    ["uranium"] = "uranium-238",
  }
  if is_mod_active("EvenMoreTextPlates") then
    materials["plastic"] = nil
  end

  textplates.technologies = {
    --["stone"] = "stone-brick",
    --["iron"] = "iron-plate",
    --["copper"] = "copper-plate",
    ["steel"] = {prerequisite = {"steel-processing"}},
    ["concrete"] = {prerequisite = {"concrete"}},
    ["glass"] = {prerequisite = {"glass-processing", "glass"}},
    ["gold"] = {prerequisite = {"gold-processing", "ir2-gold-milestone", "sulfur-processing"}},
    ["plastic"] = {prerequisite = {"plastics"}},
    ["uranium"] = {prerequisite = {"uranium-processing"}},
  }

  for material, ingredient in pairs(materials) do
    table.insert(textplates.types, {
      size = "small",
      material = material,
      ingredient = ingredient,
      name = "textplate-small-"..material, -- needs to be the same for entity, blank item, and symbol item prefix
      symbols = get_textplates_symbols()
    })
    table.insert(textplates.types, {
      size = "large",
      material = material,
      ingredient = ingredient,
      name = "textplate-large-"..material, -- needs to be the same for entity, blank item, and symbol item prefix
      symbols = get_textplates_symbols()
    })
  end
end

if mods then textplates.build() end

return textplates
