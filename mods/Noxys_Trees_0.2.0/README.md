# Noxys Trees

A Factorio modification that makes the trees spread slowly but also die off with certain condition.

## Discord

Want to discuss this mod or talk to Noxy directly? You can just go to the discord!

[<img src="http://cyanox.nl/discord.png" align="middle" title="Discord Invite to Noxys Naughty Nook"  /> Invite to Noxys Naughty Nook](https://discord.gg/0bly1P1wIaTXv9W5)

## Factorio mod portal

[Factorio mod portal page.](https://mods.factorio.com/mods/CobaltSky/Noxys_Trees)

## Settings

### Startup

| Name | Description |
| -------- | -------- |
| Tree dying factor from fire | Percentage of how many trees should be removed after they've been burnt by fire.<br>Vanilla default is 0.8 (80%).<br><br>Set this to 0 to not alter this behavior. |

### Global

| Name | Description |
| -------- | -------- |
| Enabled | When enabled trees will spread and die. |
| Debug mode | Enables the output of debug messages. |
| Debug Interval | The interval in ticks between debug messages. |
| Degrade tiles | Over time slowly degrades floor tiles that block tree growth until the trees can grow there again. |
| Overpopulation kills trees | If a chunk is overpopulated it will slowly kill off trees at random in that chunk. |
| Kill trees near unwanted | Randomly kills trees that are near biter bases, uranium ore or player entities. This also affects the death of trees by lack of fertility or too much pollution. |
| Ticks between operations | Allows fine grained control over the performance of this mod and the speed at which the trees expand. |
| Chunks per operation | Allows fine grained control over the performance of this mod and the speed at which the trees expand. |
| Enable chunks per operation scaling bias | Allows fine grained control over the performance of this mod and the speed at which the trees expand.<br><br>WARNING: This option makes tree growth more consistent throughout a playthrough but will cost more performance the bigger the map becomes.<br><br>Therefore this is a choice between consistent performance versus consistent tree spreading. |
| Chunks per operation scaling bias | Allows fine grained control over the performance of this mod and the speed at which the trees expand.<br><br>Chunks per operation are multiplied with the total chunks divided by this value (if enabled) (this * (TotalChunks / ScalingBias)). |
| Minimum distance between trees | Minimum distance between trees for trees to be able to grow. |
| Minimum distance to enemies | Minimum distance to enemy bases or worms for trees to be able to grow. |
| Minimum distance to uranium ore | Minimum distance to uranium ore for trees to be able to grow. |
| Minimum distance to player entities | Minimum distance to player entities for trees to be able to grow.<br><br>Set this to 0 to skip this check and thus slightly increase performance. |
| Tree deaths by lack of fertility minimum | If the fertility of the ground is lower than this value the tree on top of it has a chance to die. |
| Tree deaths by pollution bias | How quickly trees die from pollution.<br><br>Set this to 0 to disable deaths by pollution.<br><br>Additional trees attempted to be killed = math.ceil(pollution / this). |
| Trees to grow per chunk percentage | Allows fine grained control over the performance of this mod and the speed at which the trees expand.<br><br>Each chunk will at least try to generate one tree but this percentage can increase it to more based on the existing trees in the chunk.<br><br>If the percentage is 0.01 (1%) and the chunk has 200 trees it will try to generate 2 additional trees per operation. |
| Maximum trees per chunk | If there are more trees than this number in a chunk it will not expand any trees in that chunk.<br>(Vanilla dense forests seem to be around 512 trees per chunk) |
| Expansion distance | How far in tiles a tree can generate from its originating tree. |
