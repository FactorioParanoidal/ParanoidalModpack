[![foundrygg.com](https://img.shields.io/badge/foundrygg-4a1402?style=for-the-badge&logo=vercel&logoColor=white)](https://foundrygg.com)[![Discord](https://img.shields.io/badge/Discord-%235865F2.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/nFVqaPEk97)[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/danielmartin0/PlanetsLib)


# PlanetsLib

Code and graphics to help modders creating planets, moons and other systems. This library is a community project. Anyone is welcome to open a [pull request](https://github.com/danielmartin0/PlanetsLib/pulls) on Github. For feature requests, please open an [issue](https://github.com/danielmartin0/PlanetsLib/issues). For general discussion, use [Discord](https://discord.gg/nFVqaPEk97).

Since other mods make use of the 'orbit structure' this mod provides to the solar system, it is recommended to add PlanetsLib compatibility to your planet mod either by defining your planet prototype using PlanetsLib (as in the first image in the [mod portal gallery](https://mods.factorio.com/mod/PlanetsLib)), or by calling `PlanetsLib:update` in data-updates.lua (second image in the gallery). Besides improving compatibility with PlanetsLib consumers, this means if another mod updates the position of your planet's orbital parent without moving your planet, your planet will be moved too.

We aim to *never make any breaking API changes* such that the library is safe to use. We sometimes deprecate APIs by removing them from the documentation, but they stay functional.

# [Documentation](https://planetslib.foundrygg.com/)

# Contributors

[thesixthroc](https://mods.factorio.com/user/thesixthroc), [MeteorSwarm](https://mods.factorio.com/user/MeteorSwarm), [Midnighttigger](https://mods.factorio.com/user/Midnighttigger), [Tserup](https://mods.factorio.com/user/Tserup), [notnotmelon](https://mods.factorio.com/user/notnotmelon), [Frontrider](https://mods.factorio.com/user/Frontrider), Zwvei, [allisonlastname](https://mods.factorio.com/user/allisonlastname), Hoochie63, [SirPuck](https://mods.factorio.com/user/SirPuck), [Osmo](https://mods.factorio.com/user/O5MO), [Thremtopod](https://mods.factorio.com/user/thremtopod), [Kryzeth](https://mods.factorio.com/user/Kryzeth).


[![Discord](https://img.shields.io/discord/1309620686347702372?style=for-the-badge&logoColor=bf6434&label=The%20Foundry&labelColor=222222&color=bf6434)](https://foundrygg.com)

