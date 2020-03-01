# NANOBOTS 1.8.8

## Robot enhancements from the start of the game

Learn how to create powerful but consumable robots after learning automation. Get up and running fast by using these robots to help you build your way up to Roboports and even smarter robots. Add modules to your power armor to reprogram your personal roboport to complete mundane tasks automatically. Place roboport interfaces to have your logistic networks perform tasks while you are away.

### Nanobots

- Pre bot version of ghost building construction bots. Allows researching automated construction earlier (for blueprints etc).
- Equip the Nano Emitter and some Nano ammo, make it your selected gun and any ghosts/blueprints within 7.5 tiles of you will be automatically built if you have the items in your inventory.
- Technologies exist to slightly increase the range and speed of your nanobots.
- These earlier version bots are capable of building, deconstructing and healing. They do not replenish (each Ammo magazine will build 10 items)
- Nanobots do not work inside logistic networks that contain construction robots, or personal roboport zones without an interface module installed in your power armor.
- Manually shooting nanobots releases a pretty cloud of nanobots and nothing else. This is a good way to waste nanobots.

### Ammo Details

- Nano Constructors - These nanobots will revive ghosts in their range, heal damaged structures, and deconstruct marked items.
- Nano Termites - These nanobots will kill off trees. This process causes the tree to topple over and may damage nearby structures.

--------------------------------------------------------------------------------

#### Modular Armor Equipment

Reprogram your personal roboport to do a lot of the mundane tasks for you. Most modules require an active personal roboport and construction bots to fully work.

- Adds new equipment pieces for your power armor that will enhance your late game experience.
- The item retriever module will mark all items on the ground (artifacts, etc) in your personal roboport construction range for deconstruction as long as no enemies are around.
- The tree cutter module will mark all trees within your personal roboport range for deconstruction.
- The unit launcher module will launch Destroys/Defenders/Distractors when enemies get inside your roboport range.
- The feeder will automatically heal you when you are low on health. For a bigger healing bonus keep a stack of healing capsules in your inventory.
- The Belt Immunity chip stops belts from moving you around.
- The Nano interface will allow your nanobots to work even while you are inside logistic networks.

--------------------------------------------------------------------------------

#### Hotkeys and More

Hotkeys are available to toggle equipment on or off. Personal Roboports, Exoskeletons, Night-vision, All or individual Nanobot equipment modules.
If a piece of equipment in your armor is not enabled, adding more pieces of that equipment will install the disabled version.
Equipment states will stay with the power armor making it easy to swap out power armors without having to remember to also toggle the equipment. It is also possible to limit the range that nanobots will work in.

- Switching weapons in a vehicle will now also switch your characters weapons. as long as it is assigned to the same as the switch weapon key, Or you can assign it to a separate key.
- Ctrl F1 - F7 Will toggle specific modular armor equipment on or off. A visual GUI is planned for this in the future.
- Set the maximum radius that a module or nanobot ammo will work by holding the ammo or module in your hand and using the GUI or hotkeys to increase or decrease the range. It is possible to set this value higher than the maximum allowed but it will have no effect.

--------------------------------------------------------------------------------

#### Roboport Interface

The roboport interface allows you to program your logistic networks to do mundane tasks for you. Place a Roboport interface and set virtual signals on the built in combinator. If there are enemies in the construction zone your robots will not execute these tasks. Only up to half of your available construction bots will be uses for these tasks.

- Find items: Will scan for any items on the ground in your network and order your construction robots to pick them up.
- Chop trees: Scan for any trees in range and chop them up. Setting this to a negative symbol will only chop trees if you have less than that amount of raw wood in the network.
- Gather fish: Sends your construction robots on a fishing expedition. Set to a negative amount to only fish if there is less then that amount in the network.
- Roboport only: Set this signal to only run this scanner in the nearest roboports zone and not the whole network.
- (Not implemented yet): Tile builder: Set a tile item signal to pave the network with this tile.
- (Not implemented yet): Tile remover: Set this virtual signal to dig up all tiles and return them to the network
- (Not implemented yet): Unit launcher: Launch units to defend against biter attacks. Attach a chest to the scanner combinator and any robots inside this chest will be used for defensive purposes.

--------------------------------------------------------------------------------

#### Future Plans and Known issues

- Better graphics for the roboport interface
- More power armor equipment modules
- More roboport interface logic
- Even more script optimization's
- Found a bug? Report it here: <https://github.com/Nexela/Nanobots/issues>

#### Many thanks to

- Articulating for his help and Ideas
- TokMor for a lot of extensive bug testing
- M16 for breaking things
- Wube and The Factorio development team
- KatherineOfSky, Arumba, Momentary Flux (and All other youtubers Showing off the Nanobots.)
- Xterminator and his Nanobots spotlight. <https://www.youtube.com/watch?v=sh_oIgUMfV4>
- And you as an everyday user of Nanobots.
