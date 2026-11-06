local constants = {
  INT32_MAX = 2147483647,
  INT32_MIN = -2147483648,
  MOD_NAME = "cybersyn-combinator",
  MOD_TITLE = "Cybersyn Combinator",
  --- @type { [string]: string }
  SETTINGS = {
    LOG_LEVEL = "cybersyn-combinator-loglevel",
    CHAT_LOG_LEVEL = "cybersyn-combinator-loglevel-chat",
    SLOT_ROWS = "cybersyn-combinator-slotrows",
    SLOT_COUNT_WAGON = "cybersyn-combinator-slotcount-wagon",
    UPGRADEABLE = "cybersyn-combinator-upgradeable",
    EMIT_DEFAULT_REQUEST_THRESHOLD = "cybersyn-combinator-emit-default-request-threshold",
    EMIT_DEFAULT_FLUID_REQUEST_THRESHOLD = "cybersyn-combinator-emit-default-fluid-request-threshold",
    EMIT_DEFAULT_PRIORITY = "cybersyn-combinator-emit-default-priority",
    EMIT_DEFAULT_LOCKED_SLOTS = "cybersyn-combinator-emit-default-locked-slots",
    EMIT_DEFAULT_RESERVED_FLUID_CAPACITY = "cybersyn-combinator-emit-default-reserved-fluid-capacity",
    USE_STACKS = "cybersyn-combinator-use-stacks",
    ENABLE_EXPRESSIONS = "cybersyn-combinator-expressions-enable",
    DISABLE_BUILT = "cybersyn-combinator-disable-built",
    DISABLE_NONPLAYER_BUILT = "cybersyn-combinator-disable-built-nonplayer",
    NEGATIVE_SIGNALS = "cybersyn-combinator-negative-signals",
    NETWORK_MASK_PARSE_MODE = "cybersyn-combinator-network-mask-parse-mode",
    NETWORK_MASK_DISPLAY_MODE = "cybersyn-combinator-network-mask-display-mode",
    NETWORK_MASK_DISPLAY_PREFIX = "cybersyn-combinator-network-mask-display-prefix",
    NETWORK_MASK_USE_CS_DEFAULT = "cybersyn-combinator-network-mask-use-cs-default",
    ENCODER_ZERO_INDEX = "cybersyn-combinator-encoder-zero-index",
    -- Project Cybersyn settings
    CS_REQUEST_THRESHOLD = "cybersyn-request-threshold",
    CS_FLUID_REQUEST_THRESHOLD = "cybersyn-fluid-request-threshold",
    CS_PRIORITY = "cybersyn-priority",
    CS_LOCKED_SLOTS = "cybersyn-locked-slots",
    CS_RESERVED_FLUID_CAPACITY = "cybersyn-reserved-fluid-capacity",
    CS_NETWORK_FLAG = "cybersyn-network-flag"
  },
  ENTITY_NAME = "cybersyn-constant-combinator",
  CANNOT_BUILD_SOUND = "utility/cannot_build"
}

--- @type string
constants.ENTITY_CLOSE_SOUND = "entity-close/" .. constants.ENTITY_NAME

return constants
