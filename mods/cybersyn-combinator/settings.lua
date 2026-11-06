local constants = require "scripts.constants"
local NAMES = constants.SETTINGS

data:extend {
  {
    type = "string-setting",
    name = NAMES.LOG_LEVEL,
    setting_type = "startup",
    default_value = "WARN",
    allowed_values = {
      "DEBUG",
      "INFO",
      "WARN",
      "ERROR",
      "DISABLED"
    },
    order = "c[cybersyn]-c[combinator]-l[loglevel]"
  },
  {
    type = "string-setting",
    name = NAMES.CHAT_LOG_LEVEL,
    setting_type = "startup",
    default_value = "ERROR",
    allowed_values = {
      "DEBUG",
      "INFO",
      "WARN",
      "ERROR",
      "DISABLED"
    },
    order = "c[cybersyn]-c[combinator]-l[loglevel]-c[chat]"
  },
  {
    type = "int-setting",
    name = NAMES.SLOT_COUNT_WAGON,
    setting_type = "startup",
    default_value = 1000,
    minimum_value = 1,
    order = "c[cybersyn]-c[combinator]-s[slotcount]-w[wagon]"
  },
  {
    type = "bool-setting",
    name = NAMES.UPGRADEABLE,
    setting_type = "startup",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-u[upgradeable]"
  },
  {
    type = "bool-setting",
    name = NAMES.DISABLE_NONPLAYER_BUILT,
    setting_type = "runtime-global",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-d[disable]-b[built]-n[nonplayer]"
  },
  {
    type = "bool-setting",
    name = NAMES.EMIT_DEFAULT_REQUEST_THRESHOLD,
    setting_type = "runtime-global",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-e[emit]-d[default]-r[request]-t[threshold]"
  },
  {
    type = "bool-setting",
    name = NAMES.EMIT_DEFAULT_FLUID_REQUEST_THRESHOLD,
    setting_type = "runtime-global",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-e[emit]-d[default]-r[request]-t[threshold]-f[fluid]"
  },
  {
    type = "bool-setting",
    name = NAMES.EMIT_DEFAULT_PRIORITY,
    setting_type = "runtime-global",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-e[emit]-d[default]-p[priority]"
  },
  {
    type = "bool-setting",
    name = NAMES.EMIT_DEFAULT_LOCKED_SLOTS,
    setting_type = "runtime-global",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-e[emit]-d[default]-l[locked]-s[slots]"
  },
  {
    type = "bool-setting",
    name = NAMES.EMIT_DEFAULT_RESERVED_FLUID_CAPACITY,
    setting_type = "runtime-global",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-e[emit]-d[default]-r[reserved]-f[fluid]-c[capacity]"
  },
  {
    type = "bool-setting",
    name = NAMES.USE_STACKS,
    setting_type = "runtime-per-user",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-u[use]-s[stacks]"
  },
  {
    type = "bool-setting",
    name = NAMES.ENABLE_EXPRESSIONS,
    setting_type = "runtime-per-user",
    default_value = true,
    order = "c[cybersyn]-c[combinator]-e[expressions]-e[enable]"
  },
  {
    type = "bool-setting",
    name = NAMES.DISABLE_BUILT,
    setting_type = "runtime-per-user",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-d[disable]-b[built]"
  },
  {
    type = "string-setting",
    name = NAMES.NETWORK_MASK_PARSE_MODE,
    setting_type = "runtime-per-user",
    default_value = "DECIMAL",
    allowed_values = {
      "DECIMAL",
      "HEX"
    },
    order = "c[cybersyn]-c[combinator]-m[masks]-p[parse]-m[mode]"
  },
  {
    type = "string-setting",
    name = NAMES.NETWORK_MASK_DISPLAY_MODE,
    setting_type = "runtime-per-user",
    default_value = "DECIMAL",
    allowed_values = {
      "DECIMAL",
      "HEX",
      "BINARY",
      "OCTAL"
    },
    order = "c[cybersyn]-c[combinator]-m[masks]-d[display]"
  },
  {
    type = "bool-setting",
    name = NAMES.NETWORK_MASK_DISPLAY_PREFIX,
    setting_type = "runtime-per-user",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-m[masks]-d[display]-p[prefix]"
  },
  {
    type = "bool-setting",
    name = NAMES.NETWORK_MASK_USE_CS_DEFAULT,
    setting_type = "runtime-per-user",
    default_value = true,
    order = "c[cybersyn]-c[combinator]-m[masks]-d[default]-c[cybersyn]"
  },
  {
    type = "bool-setting",
    name = NAMES.ENCODER_ZERO_INDEX,
    setting_type = "runtime-per-user",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-e[encoder]-z[zeroindex]"
  },
  {
    type = "bool-setting",
    name = NAMES.NEGATIVE_SIGNALS,
    setting_type = "runtime-per-user",
    default_value = false,
    order = "c[cybersyn]-c[combinator]-s[signals]-n[negative]"
  }
}
