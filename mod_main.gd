extends Node

# Doom Pearl: one item whose effect grants an extra shop ban token.
#
# Content is registered the 1.2.0.0 way, like res://updates/u14_paws_n_claws.tres:
# an ItemSetData listing the item, wrapped in an UpdateData (update_type = UPDATE) that is
# appended to ItemService.update_data_list. Vanilla then handles everything else:
# ItemService.items, unlock (ProgressData.add_unlocked_by_default), the item-set toggle
# (ProgressData.active_update_data), shop pools (ItemService.init_unlocked_pool) and run
# save/load (lookups in ItemService.items).

const AUTHORNAME_MODNAME_DIR := "Sygnano-DoomPearl"
const AUTHORNAME_MODNAME_LOG_NAME := "Sygnano-DoomPearl:Main"

const UPDATE_DATA_FILE := "updates/doom_pearl_update.tres"
const EFFECT_SCRIPT_FILE := "extensions/effects/items/doom_pearl_effect.gd"
const TRANSLATION_FILE := "translations/item_doom_pearl.en.translation"

var mod_dir_path := ""

var _update_data: Resource = null
var _effect_script: Script = null


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(AUTHORNAME_MODNAME_DIR)
	# No install_script_extension here: the mod does not extend any vanilla script.
	ModLoaderMod.add_translation(mod_dir_path.plus_file(TRANSLATION_FILE))


func _ready() -> void:
	# mod_main is a child of the ModLoader autoload, so at boot this runs before
	# ProgressData._ready and ItemService._ready. ItemService.update_data_list and
	# ItemService.effects are already filled from item_service.tscn, and ProgressData._ready
	# (DLC detection, init_dlc_content, save load, add_unlocked_by_default,
	# refresh_active_update_data) then picks up the new set by itself.
	_register_effect_script()
	_register_update_data()

	if _is_boot_done():
		# Only reachable if the mod is loaded after boot through the ModLoader API.
		_refresh_progress_and_pools()

	ModLoaderLog.info("Ready!", AUTHORNAME_MODNAME_LOG_NAME)


func _disable() -> void:
	if _update_data != null:
		ItemService.update_data_list.erase(_update_data)
		ItemService.invalidate_items_cache()
		_update_data = null

	if _effect_script != null:
		ItemService.effects.erase(_effect_script)
		_effect_script = null

	if _is_boot_done():
		ProgressData.refresh_active_update_data()
		ItemService.init_unlocked_pool()


# True once ProgressData._ready has detected the owned DLCs and initialised their content.
# Not ProgressData.is_inside_tree(): in Godot 3 every autoload enters the tree before any of
# them runs _ready, so that is already true at boot. Refreshing then makes
# add_unlocked_by_default build ItemService's characters/items/weapons caches while
# available_dlc_ids is still empty, which drops every DLC character for the whole session.
func _is_boot_done() -> bool:
	return ItemService._dlc_content_initialized


# Same job as DLCData.add_resources() for DLC effect scripts: run-state deserialisation
# (ItemParentData._deserialize_effect_array) only rebuilds effects whose script is listed
# in ItemService.effects, matched by get_id().
func _register_effect_script() -> void:
	_effect_script = load(mod_dir_path.plus_file(EFFECT_SCRIPT_FILE))
	if _effect_script == null:
		ModLoaderLog.error("Could not load %s" % EFFECT_SCRIPT_FILE, AUTHORNAME_MODNAME_LOG_NAME)
		return

	if not ItemService.effects.has(_effect_script):
		ItemService.effects.push_back(_effect_script)


func _register_update_data() -> void:
	var update_data = load(mod_dir_path.plus_file(UPDATE_DATA_FILE))
	if not update_data is UpdateData:
		ModLoaderLog.error("Could not load %s" % UPDATE_DATA_FILE, AUTHORNAME_MODNAME_LOG_NAME)
		return

	for existing in ItemService.update_data_list:
		if existing != null and existing.id == update_data.id:
			ModLoaderLog.warning("Item set %s is already registered" % update_data.id, AUTHORNAME_MODNAME_LOG_NAME)
			return

	_update_data = update_data
	ItemService.update_data_list.push_back(update_data)
	ItemService.invalidate_items_cache()


func _refresh_progress_and_pools() -> void:
	ProgressData.add_unlocked_by_default()
	ProgressData.refresh_active_update_data()
	ItemService.init_unlocked_pool()
