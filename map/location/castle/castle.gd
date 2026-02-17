class_name Castle extends Location


func _get_points(path: Array) -> int:
	return 6 if path.size() >= 10 else points
