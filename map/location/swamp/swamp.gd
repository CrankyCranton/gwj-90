class_name Swamp extends Location


func _get_points(path: Array) -> int:
	return -5 if path.size() >= 7 else points
