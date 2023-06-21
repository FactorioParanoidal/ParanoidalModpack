# Fork adding compatability with vanilla research queue

- the vanilla research UI now remembers the last research completed
- depending on the chosen sync mode, the two research queues (modded and vanilla) are either:
  - always kept in __sync__
  - completed one after the other (__wait__ for vanilla queue to be empty or __freeze__ vanilla while the mod queue has projects)
  - __moved__ from vanilla queue to the __head__ or __tail__  of the modded queue
  - there is also a __hybrid__ mode where the first 4 slots are __synced__ and the last 3 are __moved__

# Improved Research Queue

This is a mod for the game [Factorio](https://www.factorio.com/). It can be downloaded from the [Factorio Mod Portal](https://mods.factorio.com/mod/sonaxaton-research-queue).

## Description

This mod adds a new GUI for managing a queue of research that's easier to use and more featured than the vanilla research queue.

* Maintain a research queue of unlimited size
* Move technologies up and down in the queue
* Adding an unavailable technology to the queue will add all of its prerequisites as well
* Removing a technology from the queue will remove everything that has it as a prerequisite as well
* Easily search and filter technologies to research
* Queue up individual levels of infinite technologies
* Pause the research queue while you plan, then unpause and watch your queue go
* See estimated time to completion and total number of science packs needed for technologies in the queue
* Receive a chat notification when a research finishes (can turn off in mod settings)
* Works with any modded technologies and science packs
* In multiplayer, players on the same team will share the same research queue
* Option to pause the game while you plan your research (off by default, turn on in mod settings)

This mod is intended to replace these other great but outdated mods:

* [Research queue](https://mods.factorio.com/mod/research-queue) / [Research Queue: The Old New Thing](https://mods.factorio.com/mod/research-queue-the-old-new-thing) / [Research Queue: The Old New Thing, 0.18.34 fix](https://mods.factorio.com/mod/research-queue-0-18-34)
* [Deadlock's Research Notifications](https://mods.factorio.com/mod/DeadlockResearchNotifications)

## How to Use

To open the Improved Research Queue window, use the shortcut on your shortcut bar or press `Shift+T`. You will see a list of technologies in the center, the queue on the left, and settings/filters on the right. Hover over any element to see additional info and descriptions of how to use it.

## Settings

Under `Settings` -> `Mod Settings` -> `Per player` -> `Improved Research Queue` you can customize the following settings:

* **Research completion notifications** - If enabled, a message will be posted in your chat when a research completes for your team. Helpful to be able to see a history of completed researches in the chat.
* **Pause game while window is open** - Pause the game while the Research Queue mod window is open. Only works in single player.

You can customize the the keyboard shortcut to open the Research Queue window in `Settings` -> `Controls` -> `Mods` -> `Improved Research Queue`.

## Tips

**Do not use the vanilla research queue with this mod**; this mod will most likely overwrite the vanilla queue. However, starting and cancelling research using the vanilla technology GUI will work fine with this mod. Starting a new research will add it to the start of the queue and unpause the queue. Cancelling the current research will pause the queue.

While using this mod you probably want to turn off the vanilla setting that brings up the technology screen after every research since the mod will auto-select the next research for you if you have a queue set up. Disable the option under `Settings` -> `Interface` -> `Interaction` -> `Technology screen opens when research is completed`.
