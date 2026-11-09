### Can you load Muluna on an existing save?

Yes, you can seamlessly load Muluna onto an existing save without breaking any elements of it, but it is recommended you start on a save that has not left Nauvis yet.

### How to I get to Muluna?

Your first space platform will be fully dependent on shipments from Nauvis to function. To make fuel, you must send the platform the ingredients required to make fuel and oxidizer.

### Why does this mod frequently conflict with other mods?

Muluna is not just a planet mod, it reworks several core systems within Factorio: Space Age to make the concept work, including:

1. Rearranging the tech tree to move thrusters before asteroid collectors and crushers.
2. Reworking the crusher into a general building usable on all surfaces.
3. Replacing vanilla inserter and pipe assets with shadow-separated versions to make Muluna's shaders look as expected.
4. Multiplying the maximum fluid throughput of entities by 5 to minimize throughput issues in some of Muluna's recipes.

Muluna also works to maintain synergy with other planet mods, adding compatibility patches with these planets to make the overall Space Age experience more cohesive. This sometimes leads to conflicts. When I receive crash reports due to problematic interactions with other mods, I quickly work to resolve these crashes.

### Why is making oil so hard on Muluna? Why is there no copper on Muluna? Why don't burner entities work?

Muluna's goal is to give you a small understanding of the challenges of building a settlement on our Moon. These challenges would include using aluminum as a primary conductor on lunar circuit boards, generating oxygen and hydrocarbons via photosynthesis, and carefully managing oxygen and carbon dioxide supplies to avoid a backup in either chamber.

### What do each of Muluna's dependencies do?

1. alien-biomes-graphics: Supplies ground textures for Muluna.
2. muluna-graphics: Supplies all other graphics for Muluna, separated from the main mod to reduce the network burden on users from frequent updates.
3. muluna-utility-constants: Modifies utility constants core to Factorio's engine to address problematic engine limits that some of Muluna's recipes reach. Other mods can reach these limits as well, which is why this mod is separated from the main mod.
4. PlanetsLib: Supplies code critical to Muluna and many of the mod portal's most popular planet mods, including Cerys and Janus.
5. tile-upgrade-planner: Muluna adds an upgraded variant of the space platform foundation tile that has half the mass and twice the hit points of the standard space platform foundation. This mod is bundled with Muluna to make it possible to upgrade one type of platform to another without needing to deconstruct the platform. 

### Why are there Fulgoran cargo pods scattered around Muluna?

Ask the Fulgorans.