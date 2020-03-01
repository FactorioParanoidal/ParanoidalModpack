local assembler_pipe_passthrough_defines = require('defines')
data:extend {
    {
        type = 'bool-setting',
        name = assembler_pipe_passthrough_defines.names.settings.multiple_pipe_passthrough,
        setting_type = 'startup',
        default_value = false,
        order = 'aa'
    }
}
