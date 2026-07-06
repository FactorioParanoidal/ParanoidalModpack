# Frequently Asked Questions

## How do I install Dectorio?

Download the latest stable release from the [Factorio mod portal](https://mods.factorio.com/mod/Dectorio) or at <https://github.com/jpanther/Dectorio/releases/latest> and copy the entire zip file to your Factorio mods directory:

* Windows: `%appdata%\Factorio\mods`
* Mac: `~/Library/Application Support/factorio/mods/`
* Linux: `~/.factorio/mods`

When you launch the game, the new mod will be enabled by default.

## Is it safe to add/remove Dectorio to existing saves?

Generally, yes, but with a couple of caveats. While the mod tries to play nicely with your save game and any other mods you may be using there are some things that will change. Always make sure you have a backup of your save game before adding or removing any mods as sometimes unpredictable things can happen. Dectorio is a big mod with lots of changes and so it's always best to try not to repeatedly add or remove it from an existing game.

When adding the mod to existing games, Dectorio tries its best to correctly unlock any new items and technologies based upon your existing research, but sometimes items can be left out due to the way the game handles these changes.

Note that by default Dectorio changes the stack size of certain decorative items in order to make it easier to carry more of these items in your inventory. This can have an impact on any circuit conditions you may have set up in your factory, and can also lead to unexpected behaviour if you have chests full of stone bricks that suddenly end up over capacity when the stack size reverts to the base game level. If you want to avoid these sorts of situations, you can change the stack sizes in the Mod startup settings to match the base game before loading your save for the first time. Then if you later decide to remove Dectorio, the stack sizes will not change.

If you remove the mod, any new items that Dectorio adds to the game will simply be hard deleted from your factory, inventory, and technology tree.

## Does the mod work in multiplayer games?

Yes, it _usually_ does and is regularly tested in multiplayer games. However, there are sometimes issues that arise when there are large mod packs on your server as there can be compatibility problems between individual mods. If you have an issue with a multiplayer save, [report an issue on GitHub](https://github.com/jpanther/Dectorio/issues) so I can investigate.

## What changed in the latest update?

Refer to the Changelog for a detailed list of changes in each version. You can find it on the on the [mod portal](https://mods.factorio.com/mod/Dectorio/changelog), in-game on the _Mods_ screen, or changelog.txt within the mod package itself.

## I found a bug!

Oops, sorry! While I test every update before releasing, it's impossible to uncover every combination of game setup out there. You might be using a different set of mods and stumble across something I missed, or I simply might have made an error.

If you find a bug you can check if it's already reported by searching on [GitHub Issues](https://github.com/jpanther/Dectorio/issues). If you're unable to find an open issue addressing the problem, [open a new one](https://github.com/jpanther/Dectorio/issues/new). Be sure to include a title and clear description, as much relevant information as possible, and anything you've tried to fix the issue. If you're using other mods, it's helpful to include a list of these mods in your bug report so that I can try to track down if the issue is a conflict with another mod.

## Is there a way to see the mod in action?

Yes! Some kind members of the community have posted YouTube videos that feature Dectorio.

Check out the [Mod Spotlight video by Xterminator](https://www.youtube.com/watch?v=4OOs8o0dnug) but note that this features an older version of Dectorio without some of the latest updates.

German players may be interested in this [Mod Monday video by SeeNo](https://www.youtube.com/watch?v=0SzAF997sOk) with commentary in Deutsch.

If you've made your own video, get in touch and I'll add a link here.

## Why isn't the mod in my language?

Dectorio relies on community translations for languages other than English. There's a great community that have helped to translate the mod into Chinese, Czech, French, German, Korean, Polish and Russian, however we're always keen to add new language support. If you speak a language other than English and would like to help translate, you can do so by visiting the [Dectorio project on CrowdIn](https://crowdin.com/project/dectorio).

If you would like to translate into a new language that isn't listed on the CrowdIn project, send me a message on CrowdIn with the language you would like added and I'll get you set up. You can do the translations entirely online and you'll be credited in the Dectorio readme and changelog for any contributions you make.

## How do I use the Glowing lamp?

The Glowing lamp works the same way as the base game lamp however when you connect it to a circuit network and pass it a signal, the colour it outputs will glow over a large area on the map. It's useful for making decorative lighting effects or warning lights to show when the factory has an issue. Dectorio adds signal colours to lots of base game items, so you can send a signal of 'iron' and the light will glow a blue colour so you know that's the resource that needs attention.

## How do I use the Lawnmower?

The Lawnmower is a tool that is used while being held in your hand. Simply pick up the Lawnmower from your inventory and while holding it in your cursor, click and drag over an area on the game surface. When you release the mouse button, any decorative items that are inside the area you selected will be deleted.

![Lawnmower](https://img.pantherx.net/dectorio/faq/lawnmower.png)

The Lawnmower can also be used to remove corpses from the ground (such as dead biters, spawners or left over parts of destroyed buildings) by holding down SHIFT (by default) when clicking and dragging over an area on the game surface.

## What's the point of the extra signals like the star or arrows?

These are simply additional signals that you can use when making circuit network conditions. For instance, if you had a circuit network that was calculating the battery level of your accumulators, you might find it easier to follow your logic if you assign this a 'battery' signal, rather than using an arbitrary letter or number. They don't offer any other additional functionality.

## What happened to the signs?

Dectorio used to support placing signs however this feature caused a lot of compatibility issues with other mods and was time consuming to maintain. There are now also a number of other mods that provide similar functionality and as a result, signs have now been deprecated. Check out [Industrial Display Plates](https://mods.factorio.com/mod/IndustrialDisplayPlates) or [Text Plates](https://mods.factorio.com/mod/textplates) for high-quality replacements.

Existing saves will still load normally and any existing signs will work however no new signs can be crafted or placed. To remove sign support completely, disable the compatibility setting in your mod settings.

## I have a sign that's stuck on the map and it cannot be mined. How do I remove it?

Sometimes if something happens while a player is placing a sign - they might be killed, the server goes down, the game crashes, etc. - there can be a situation where the sign is still on the map, but doesn't have an icon. If you try to delete this sign it will say "This cannot be mined." If this is the case, you can run a special command that will find and remove these entities for you. Open the console in game (by default the tilde '~' key) and type `/dect-destroy-orphaned-signs`. If it finds any signs that meet the criteria, you will be told in the console where they were removed.

![Sign cannot be mined](https://img.pantherx.net/dectorio/faq/cannot-be-mined.png)

## Why can't I add other mods from the mod portal that add more coloured signals?

The simple answer is, because most of these other mods don't play nicely with the way they implement their new coloured signals. Dectorio tries to be nice and change the signal colours non-destructively but more often than not, other mods no not do this and so when they try to change the colours it overwrites what Dectorio is doing and causes your game to crash on startup.

Sadly, the way the game flags these errors on startup, it will give the impression that you must toggle off Dectorio to play. However, you can get the best of both worlds. Dectorio supports adding as many coloured signals as you like. You can simply go into your mods folder, unzip Dectorio and edit the _config.lua_ file. In there you will find all the existing colours, and you can add, remove, or change them as you see fit. That way you can mod in your own custom colour list and remove the need for additional mods that simply add more colours.

If you really want to use another mod for coloured signals, but still want to keep all the rest of Dectorio's functionality, you can also use the Mod startup settings to uncheck the 'Enable Signals' option. If you do this before downloading additional mods, you shouldn't have any compatibility issues.

## Will you add [new feature] to the mod?

I'm always interested to hear suggestions for new features. While I don't always have the time to implement everything, if it fits in with the Dectorio theme, I'll often try my best to include it. The quickest way to get my attention is to [create a new issue on GitHub](https://github.com/jpanther/Dectorio/issues) outlining your feature request.

## Why does the Landscaping change adjacent tiles when placing it down?

This is a bit of a quirk with the way the base game handles tile changes. Dectorio works differently to other mods in that the landscaping tools are not placing actual flooring tiles. While other mods place these tiles as a layer on top of the base layer, Dectorio instead changes the base layer directly. The game applies a bit of blending logic to tile placement and as a result it will sometimes adjust adjacent tiles to fit with the landscape.

This is also why you can't mine the landscaping off the ground.

## Are all the mod textures in HD?

The mod is slowly being converted to HD textures. About 60% is currently in HD and more is added progressively with new updates. Just like the base game, due to the time required to make these textures, it's not always practical to convert every old texture to HD in time for every release.

## I really don't like the way hazard concrete looks different in Dectorio!

That's fine, you can turn this off by checking the "Use default Factorio Hazard concrete style" option under the Mod Startup settings. Checking this box will mean that your Hazard concrete looks like the original base game, but you can still use all the other Dectorio concrete styles too.

![Default Hazard concrete setting](https://img.pantherx.net/dectorio/faq/default-hazard-concrete.png)

## Are Angels and Bobs mods supported?

Dectorio doesn't specifically adjust recipes when Angels and Bobs are present but it does work fine with either of these mod packs installed. This does introduce some progression issues with technology required to build certain items like walls and gates and I plan to make recipe adjustments in future updates to smooth this out a bit.

## Is the mod compatible with [other mod]?

While I can't possibly test every combination of mods available, usually Dectorio will work with most other mods. From time to time there may be a compatibility issue that cannot be worked around and these are noted on the Mod Portal page. If you find a new compatibility issue that isn't mentioned on the Mod Portal page, feel free to [create a new issue on GitHub](https://github.com/jpanther/Dectorio/issues) outlining your problem and I'll investigate.

## I don't like that Dectorio changes [something]?

That's a pity, but that's the nature of modding. If you have a valid concern about something Dectorio is changing that seems contrary to the way something should work, feel free to [raise a new issue on GitHub](https://github.com/jpanther/Dectorio/issues) outlining your concern. If it is something that makes sense to change, I'll definitely look to adjust the mod in a future update. However, please note that Dectorio is designed to make it easy to decorate your factory, and the technology and recipe choices try to be somewhat realistic. The mod settings allow you to toggle individual changes on and off so you can customise it to your own play style. If you still don't like that, then simply don't use the mod! Requests that just whinge about things you don't agree with, without being constructive, will be ignored.

## How do I play with Dectorio on Factorio 1.0.x, 0.18.x, 0.17.x, 0.16.x or 0.15.x?

The latest versions of Dectorio are designed to work with Factorio 1.0 and later. Due to the way the base game changes with each major release, there's no way to make the latest versions of Dectorio compatible with older versions of Factorio. However, old stable versions of Dectorio are kept available on the mod portal for each major Factorio release.

- Factorio 1.0.x: Dectorio v0.11.1
- Factorio 0.18.x: Dectorio v0.10.9
- Factorio 0.17.x: Dectorio v0.9.16
- Factorio 0.16.x: Dectorio v0.8.11
- Factorio 0.15.x: Dectorio v0.7.6

Note that these old versions of Dectorio will not be updated with new features, but they will occasionally have bugfixes if it's appropriate. You'll need to upgrade your Factorio version to take advantage of the latest changes.

## The Mod Portal discussion page is disabled!

Yes, yes it is. I tried to keep track of comments people left on the mod portal but it easily got out of hand. There are limited moderation tools available and the discussion generally wasn't helpful for tracking down problems. My preference has always been to use [GitHub Issues](https://github.com/jpanther/Dectorio/issues) to keep track of any bugs or feature requests and so that is now the default way to get in touch. You can also occasionally find me on the official [Factorio Discord](https://discord.gg/G4fpTay) or [Twitter](https://twitter.com/jpanther). Any old discussion topics on the Mod Portal have been archived.
