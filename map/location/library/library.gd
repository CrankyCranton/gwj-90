class_name Library extends Location


#func _draw_card() -> void:
	#var hand_size := CardsManager.hand.size() + 1
	#for i in range(CardsManager.hand.size() - 1, -1, -1):
		#CardsManager.burn_card(i)
#
	#for i in hand_size:
		#super()


func _get_points(path: Array) -> int:
	@warning_ignore("integer_division")
	return points - path.size() / 3
