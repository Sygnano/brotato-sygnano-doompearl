tool
extends Effect

# Doom Pearl effect: grants `value` extra shop ban tokens to the owning player.
#
# This is a new Effect subclass, not a script extension: it is referenced by path from
# doom_pearl_effect_0.tres and must never be passed to install_script_extension.
# mod_main registers it in ItemService.effects (as DLCData.add_resources does for DLC
# effect scripts) so ItemParentData._deserialize_effect_array can rebuild it from a saved
# run by matching get_id().


static func get_id() -> String:
	return "sygnano_doom_pearl"


func apply(player_index: int) -> void:
	RunData.players_data[player_index].remaining_ban_token += value


func unapply(player_index: int) -> void:
	RunData.players_data[player_index].remaining_ban_token -= value
