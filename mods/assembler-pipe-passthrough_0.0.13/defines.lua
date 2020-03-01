-- Here are the values that are shared across different files.
local assembler_pipe_passthrough_defines = {}

-- Mod ID.
assembler_pipe_passthrough_defines.mod_id = 'assembler-pipe-passthrough'
-- Prefix of the names.
assembler_pipe_passthrough_defines.name_prefix = assembler_pipe_passthrough_defines.mod_id .. '_'

-- Names.
assembler_pipe_passthrough_defines.names = {}
-- Setting names.
assembler_pipe_passthrough_defines.names.settings = {
    multiple_pipe_passthrough = assembler_pipe_passthrough_defines.name_prefix .. 'multiple-pipe-passthrough'
}

return assembler_pipe_passthrough_defines
