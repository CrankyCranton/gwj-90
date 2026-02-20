class_name Monk extends PlayerCharacter


func score_path() -> void:
	super()
	# Copy-pasted from obelisk.gd
	# FIXME Not working because of the order of operations of when score_path() is called.
	# Fixing tweening order should clear this up.
	var inns := get_tree().get_nodes_in_group(&"inn").filter(
			func(inn: Inn) -> bool: return inn.claim == null and inn.character == null)
	if inns.size() > 0:
		await set_location(inns.pick_random())
