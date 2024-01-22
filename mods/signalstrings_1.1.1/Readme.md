## SignalStrings

This library provides common functions for handling strings on circuit networks. Strings are expressed as a bitmask of where each letter appears, LSB on the left.
"FOOBAR" = {signal-F=1,signal-O=6,signal-B=8,signal-A=16,signal-R=32}

Strings may be converted to signals using `remote.call('signalstrings','string_to_signals',"FOOBAR")`, and optionally with extra data (in the form of Constant Combinator params to be prefixed) using `remote.call('signalstrings','string_to_signals',"FOOBAR", extrasignals)`. Strings are automatically converted to all-caps to ease conversion, and non-representable characters are discarded (leaving empty space). Item and fluid rich text tags are converted to the matching signals.

Signals may be converted back to a string using `remote.call('signalstrings','signals_to_string',signallist, userichtags)`. If `userichtags` is `true`, item and fluid signals will be converted to their richtext tags.

Mods that add signals may register them for string conversions by calling `remote.call('signalstrings','register_signal','signal-name','X')` in their on_load and on_init events.
