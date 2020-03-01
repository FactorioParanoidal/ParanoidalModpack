# PICKER PIPE TOOLS

Adds tools focused around ease of use when piping!

- Orphan finder - Hover over any belt or underground belt and it will highlight any underground belts nearby that are missing a connection. The same applies with pipes.
- Pipe cleaner - Use the selection tool to select a single pipe or even group of pipes with a fluid in them. The script will recurse through all pipes connected that have the same fluid as the selected fluid and remove it.
- Underground pipe highlighter - Press `<CTRL SHIFT P>` to ping all underground pipe connections around you. Will also highlight pipes-to-ground in green or red. If red, this means that that pipe is missing a connection. Toggle back off with same button. (Configurable range from 80 to 500 tiles)
- Pipe Highlighter - Simply hover over a pipeline and it will check it for you and highlight it! (Default 250. Configurable 100-250)
- Pipe clamps - Press `<CTRL R>` on a pipe to "clamp" it to it's current connections. This locks it in place without allowing it to connect to anything else. Selection tool can be used to lock an entire area in position, or unlock an entire area. Automated scripts prevent pipes from mixing fluids that don't match when unclamping, or more in depth during placement if auto clamp mode is on.
- Auto Clamp Mode - This allows parallel pipe placement of empty or full pipes. Will prevent fluid mixing if they do not match. See below gifs for what this means. You can toggle autoclamp mode by pressing `<CTRL SHIFT C>` or by typing `/autoclamp <off/false, on/true>`.

## Picker Orphan finder

Highlights nearby underground belts and pipes that are not connected to anything underground when hovering over belts or pipes. Can be disabled per player in mod options.

![Picker Orphan finder](https://github.com/Nexela/PickerAtheneum/raw/master/web/picker-orphans.gif)

## Picker Pipe Cleaner

Call a plumber on any fluidbox by using the selection tool in the blueprint menu. This will loop through all connected pipes and remove the selected fluid allowing your pipes to freely flow again.

![Picker Pipe Cleaner](https://github.com/Nexela/PickerAtheneum/raw/master/web/picker-pipe-cleaner.gif)
![Picker Pipe Cleaner](https://thumbs.gfycat.com/DeadBigGrayling.webp)

## Picker Underground Pipe Highlighter

Want to see where all the underground pipes around you go? Validate your connections by pressing `<CTRL SHIFT P>` and all underground pipes will be shown and orphans marked (Compatible with Advanced Fluid Handling mod). Press again to turn them off.

![Picker Pipe Highlighter](https://thumbs.gfycat.com/WelltodoBonyHusky.webp)

Ever wonder if your soup sandwhich is all connected? Ever wanted to see where a pipe goes? Have you wanted to check if there's any disconnected pipes in a pipeline? Well, just hover your mouse cursor over a pipe and find out! (Default up to 250 pipes in a line)
If an orphan is found (An orphan is defined as having one or no connections) on a pipe, pump, or pipe to ground, it will mark that entire branch to the nearest junction in red. The remainder of all pipes will be marked in yellow.
If there's no orphans, it'll mark it all in green! Green is good!
Pumps can even verify if they're connected to a rail!

![Picker Pipe Highlighter](https://i.imgur.com/erfPf6X.png)
![Picker Pipe Highlighter](https://i.imgur.com/1t7RKo9.png)
![Picker Pipe Highlighter](https://thumbs.gfycat.com/AmazingAdmirableFrog-size_restricted.gif)
![Picker Pipe Highlighter](https://thumbs.gfycat.com/ConstantBlandCoelacanth-size_restricted.gif)

## Picker Pipe Clamps

Want more control of your pipes? Clamps have you covered! Just start drawing a pipeline and the script will handle it for you! This automagically prevents fluid mixing when placing pipes, and even allows parallel pipe laying when the pipes are empty, or full, even with the same liquid.
You can press \<ROTATE> on any pipe to clamp or unclamp it. You can also use the selection tool from the blueprint menu to clamp or unclamp entire areas. (Unclamping will always attempt to prevent fluid mix)
Note: Pipe will attempt to clamp itself if the fluid you're piping doesn't match a building it's trying to connect to (IE: Storage tank.) This will cause warning spam if dragging the mouse while placing pipes and this happens. (see last image below)

![Picker Pipe Clamps](https://thumbs.gfycat.com/JollyCooperativeBlacknorwegianelkhound.webp)
![Picker Pipe Clamps](https://thumbs.gfycat.com/LongPeacefulCrocodile.webp)
![Picker Pipe Clamps](https://thumbs.gfycat.com/LeanSkeletalArmedcrab.webp)
![Picker Pipe Clamps](https://thumbs.gfycat.com/DazzlingComplicatedIberianbarbel-max-1mb.gif)

Contact me on discord at TheStaplergun 2.0#6920
