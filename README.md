# Doom Pearl

A [Brotato](https://store.steampowered.com/app/1942280/Brotato/) mod that adds the **Doom Pearl** item: each Doom Pearl you hold gives you one extra shop ban token.

[Steam Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=3485083698)

## The item

| | |
|---|---|
| Tier | 2 (uncommon) |
| Base price | 60 |
| Effect | +1 ban token per pearl |
| Limit | none, they stack |

The pearl comes with its own item set, **Doom Pearl**. Turn it on or off from the main menu's item set screen, the same way as the game's own sets.

## Compatibility

- Brotato 1.2.0.0 and 1.2.0.1
- Godot Mod Loader 6.3.0
- Works in solo and co-op. Runs saved with the pearl load normally, and the effect comes back with them.

## Installation

- **Steam:** subscribe on the [Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=3485083698). The Steam build loads mods from your Workshop subscriptions.
- **Other builds:** put the release `Sygnano-DoomPearl.zip` in the game's `mods` folder.

## How it works

The mod changes no vanilla scripts. It adds its content the way the game adds its own updates (compare `res://updates/u14_paws_n_claws.tres`):

- `updates/doom_pearl_update.tres` is an `UpdateData` that wraps the `ItemSetData` in `updates/item_sets/`. `mod_main.gd` appends it to `ItemService.update_data_list`. From there the vanilla code takes care of unlocking the item, the item set toggle, shop pools and run saves.
- `extensions/effects/items/doom_pearl_effect.gd` is a new `Effect` subclass (id `sygnano_doom_pearl`). It is registered in `ItemService.effects` so that saved runs can rebuild it.
- English text lives in `translations/item_doom_pearl.csv`.

## Repository layout

This repository is the mod folder itself. In a game or decompiled project it goes in `res://mods-unpacked/Sygnano-DoomPearl/`.

```
manifest.json            mod metadata (version, game / loader compatibility)
mod_main.gd              registration of the item set and effect script
extensions/              item data, appearance, icon and effect
translations/            text (CSV source + compiled .translation)
updates/                 UpdateData + ItemSetData
```

## Building a release

1. Put this folder in a Godot 3.6 project of the game at `mods-unpacked/Sygnano-DoomPearl/`, then open the project once so the PNGs are imported.
2. Zip `mods-unpacked/Sygnano-DoomPearl/` together with the matching `.import/*.stex` files, keeping both paths relative to the project root.

## Author

Sygnano
