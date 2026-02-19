class_name Swamp extends Location


func _get_points(path: Array) -> int:
	return 0 if path.size() > 5 else points
