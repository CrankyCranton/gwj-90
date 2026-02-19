class_name Temple extends Location


#func _draw_card() -> void:
	#CardsManager.add_card(null)


func _get_points(path: Array) -> int:
	return points + path.find(self)
