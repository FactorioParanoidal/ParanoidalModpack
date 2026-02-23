# Contributing

## Bug reports

Please include the [log file](https://wiki.factorio.com/Log_file) in your bug reports. Enable debug logging (not for `on_tick`!) before uploading the log file e.g. on a public pastebin (no one-click hosters, please!).

## Contributing ruins

Since the 1.2.0 release, all ruin-sets from this mod have been moved out to this mod.

You are invited to make your own ruins mod basing on this mod or "stand-alone". Your mod can extend it with more ruins or modify its entities. If your mod requires other mods (because of their content), then add this as a mandatory dependency in your [info.json](https://wiki.factorio.com/Tutorial:Mod_structure#info.json) file.

### Contributing generic ruins to this mod

As usual, you have to first fork this mod on github as I won't permit write access so easily to my repository. And I won't accept contributions bundled in a ZIP/RAR/whatever archive or as individual files emailed to me. The simple reason is that you might have made your modifications on an out-dated version of that file and then I have to repeat my works on it, too, to only include your chances.

For that simple reason, there is GIT, a software versioning and change-tracking software. You might want to download the [offficial client](https://git-scm.com) or install a package of your Linux distribution, later is recommended so your software stays up-to-date.

Now since you have forked this mod, you have to locally "download" or *clone* it. Cloning means that not only the pure files are downloaded but also the whole GIT history which is need to track changes aka. commits.

First create a proper folder in a good place on your computer you can easily remember (most common mistake was to put it "somewhere" and then they cannot find it anymore). A good location is in your "My Documents" folder and call it "Projects".

Second clone your fork with SSH protocol. You can find that URL by clicking on the button "<> Code" and choose SSH. Then click on "Copy URL to clipboard" and you are ready to go.

Example:
- your nickname here on github is `User123`
- your fork of this mod is then `User123/AbandonedRuins-base`
- your final GIT-SSH URL is then: `git@github.com:User123/AbandonedRuins-base.git`

Continue the usual way on how to contribute to an OpenSource project:
- now clone your repository into that new folder "My Documents/Projects" by navigating there. Your client's documentation should provide all needed information (you never stop learning!) for doing this.
- a new folder called "AbandonedRuins-base" has now appeared. Click on that folder and you can finally make changes the proper way, provided you have setup your client correctly (I always assume that!).
- once you have finished committing + pushing your changes, navigate to your github URL `https://User123/AbandonedRuins-base` and verify that your commit has reached there. A message like "This branch is 1 commit(s) ahead of Quix0r/AbandonedRuins-base:master".

You have now made changes to your branch `master` which is untypical for contributions. Typical is to create "topic branches" that are based on `master` and those will be merged into the "upstream" repository.

But if the message is different like that "your branch is `x` commits behind and 1 commit ahead" then you need to "rebase" your changes as the upstream repository has changed and your changes are not based on those latest changes.

To do that is very easy:
- still in your "My Documents/Projects/AbandonedRuins-base" folder, you need to add a remote-tracking branch. With the `git` command on console, this is very easy:
```
$ git remote add upstream git@github.com:Quix0r/AbandonedRuins-base.git
$ git pull --all
$ git checkout master # Or however you have called it, e.g. "develop", then do `git checkout develop` instead.
# To keep your master branch up-to-date
$ git rebase upstream/master
$ git checkout some/topic-branch # Switch to your topic branch and keep it up-to-date
$ git rebase upstream/master
$ git checkout master # Switch back to master branch
$ git push --force --all
```
This is only an example but it should show you, how to to stay up-to-date with your branch. Solve any conflicts before "blindly" proceeding.

As you have probably noticed by now, contributing to this project isn't any harder than contributing to any other project.

### Extending/modifying "base" ruin-set

When you want your ruin-set only extend `AbandonedRuins-base` or modify a few entities (which is maybe needed for Krastorio2) then you have to follow below instructions. You still should clone this mod as described above to give credits to the original authors of this mod. This mod's `control.lua` includes examples on how to extend any existing ruin-set. Please never forget to add that other ruin-set as a mandatory dependency in your [info.json](https://wiki.factorio.com/Tutorial:Mod_structure#info.json) file.

Best practice is to include a version number in it:
```json
{
  "name": "foo-ruin-set",
  "title": "My foo ruin-set",
  "version": "0.0.0",
  "author": "User123",
  "factorio_version": "2.0",
  "description": "Some new generic ruins",
  "dependencies": {
    "base >= 2.0.60",
    "AbandonedRuins-base >= 0.0.6"
  }
}
```
Surely you want some better description introducing your ruin-set mod. If your mod depends on entities from other mods, you have to add them to `dependencies`, too.

I stated in this example `base >= 2.0.60`. This makes sure that gamers have the most recent patch level installed as you probably don't want to support any patch level they have installed. Same with the dependency on this mod which I have only some spare time. Please keep it up-to-date! But you are free to choose dependencies to your liking.

Please *DO ALWAYS* expose your changes to your users. They may depend on it. A proper [changelog.txt](https://wiki.factorio.com/Tutorial:Mod_changelog_format) file is maybe optional for a Factorio mod in general, but it is good for your audience so they see how much efforts you put into your mod.

### Creating stand-alone ruin-sets

Like the mod [realistic-ruins-updated](https://github.com/Quix0r/realistic-ruins-updated) or `AbandondedRuins-Krastorio2` you can make ruin-sets on your own. Then your [info.json](https://wiki.factorio.com/Tutorial:Mod_structure#info.json) should depend on `AbandonedRuins_updated_fork` instead and not on this one.

To do so, your file looks a little different:
```json
{
  "name": "foo-ruin-set",
  "title": "My foo ruin-set",
  "version": "0.0.0",
  "author": "User123",
  "factorio_version": "2.0",
  "description": "Some 'foo/bla' ruins with new graphic assets.",
  "dependencies": {
    "base >= 2.0.60",
    "AbandonedRuins_updated_fork >= 1.3.3",
    "other-contents-mod >= x.y"
  }
}
```

You can use the dedicated [ruin maker mod](https://mods.factorio.com/mod/ruin-maker_updated_fork) to easily create ruins in-game. You can also manually create or edit ruins, their format is documented here: [Ruin data format](format.md).

Please note that `ruin maker` isn't ported to Factorio 2.0 and not supported yet.
