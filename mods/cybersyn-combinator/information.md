# Cybersyn Combinator

This mod adds a new fancy combinator to the game, made to be used with the [Project Cybersyn][cybersyn] mod.

It functions like a regular constant combinator, but has built-in support for setting the various Cybersyn-specific signals.

## 2.0 changes

With Factorio 2.0, the internal behaviour of constant combinators was changed.
As of v2.1.0 of this mod, there's a migration in place that should handle converting old combinators to make them work
with the new system. If this still doesn't work, there's also new commands added to forcefully try to fix them:
 - `/cc_sort_all` will try to fix all combinators across all surfaces.
 - `/cc_sort` will try to fix the currently hovered combinator.

## Features

 - Dedicated inputs for Cybersyn signals
   - Request threshold
   - Priority
   - Locked slots
 - Ability to input signals using stack counts
 - Panel to input network masks with options to display them in various formats.
 - You could use it instead of a constant combinator for purposes other than Cybersyn, if you want to (perhaps for the bitmask features)

### Network masks

On the left side of the combinator window is an area to input network masks.
You can read more about how the masks themselves work on the [Cybersyn][cybersyn] mod page.

You can either input bitmask values by hand, or use the GUI encoder for a more visual way where you can toggle specific bits on or off with buttons (described in more detail below).

There are options to display masks as decimal, hexadecimal, binary, or octal numbers, with or without a prefix.

For inputting mask values, you first select a signal (has to be virtual) and then put the value of the network mask in the text field.
By default you can either write decimal numbers as normal, or use hexadecimal/binary/octal by prefixing with `0x`, `0b`, or `0o`, respectively.

Example: Writing the mask as "0x80" is 128 in decimal, or "1000 0000" in binary (the eigth bit is set).

There's also an option to always assume hexadecimal input, but then no other formats will be accepted and any input will be assumed to be hexadecimal.

After pressing the green confirm button, the new network mask will be added to the list, which shows the virtual signal along with the value of the mask.
Left clicking an item in the list will populate the fields above for it to be edited, or you can right click to remove it from the combinator.

#### Encoder

If you don't fancy manually writing out network masks, since version v1.0.0 there is now a friendly GUI encoder you can use!

At the moment, you will have to add a network mask to the list as described above first, then you can **Control + Left-click** on it to open the encoder interface.

In the encoder, you can use numbered buttons to toggle each bit in the network mask, and also see the resulting value in decimal, hexadecimal, binary, and octal.

(The encoder also still has a text field you can use to write the mask yourself, and see the buttons update in real-time as you type.)

### Copy-pasting settings

Because the Cybersyn constant combinator is based on a regular constant combinator, you can copy and paste signals between them like regular constant combinators.

### Expression inputs

If you enable the per-player option of using expressions in inputs, you can use mathematical expressions instead of regular numbers in the following places:

 - Stack input for item signals
 - Non-stack input for item signals
 - Cybersyn signal values

This lets you, for example, input something like `50 * 288 * 4`, which will then evaluate to `57600` when you confirm it (press **Enter** or use the green confirm button).

Note that for the Cybersyn signals, the values are updated as you type, but you can press enter to evaluate it and see the resulting value from your expression.

## Bugs/support/feature requests/questions

You can use the discussion area on the Factorio mods site, but you are more likely to receive a timely response by communicating via the [repository on GitHub][github].

## Acknowledgements

This mod was made with inspiration from the similar mod [LTN Combinator Modernized][ltnc] for the [Logistic Train Network][ltn] mod.

## Compatibility

This mod should probably work with most other mods, provided they don't do very drastic changes and/or overhauls.

Special compatibility notes will be listed in this section as they are discovered.

If there's a mod that is not compatible, please let me know and I'll look into whether it can be made to support it!

### [LTN Combinator Modernized][ltnc]

There's no issue using both mods at the same time, but the option to enable "upgrading constant combinators" might not work as intended if enabled on both mods at the same time.
One mod would get precedence based on load order.
So if you're using both, make sure you only enable the "upgrade" option on the mod you wish to be able to upgrade to from constant combinators (if at all).

### [Nullius][]

Since version 0.3.4, there is support for using this mod with [Nullius][].

The recipe is altered to use 1x Logic Circuit and 1x Memory Circuit, as well as some energy, to match the cost of making an LTN Combinator in Nullius.

[github]: https://github.com/Sharparam/cybersyn-combinator
[cybersyn]: https://mods.factorio.com/mod/cybersyn
[ltnc]: https://mods.factorio.com/mod/LTN_Combinator_Modernized
[ltn]: https://mods.factorio.com/mod/LogisticTrainNetwork
[nullius]: https://mods.factorio.com/mod/nullius
