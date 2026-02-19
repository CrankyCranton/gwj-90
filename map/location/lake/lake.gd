class_name Lake extends Location


func _get_points(path: Array) -> int:
	@warning_ignore("integer_division")
	return points + path.size() / 3
