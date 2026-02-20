class_name Bandit extends Character


static var bandits := 0

var just_added := true


func _ready() -> void:
	super()
	self_modulate = Color.TRANSPARENT
	bandits += 1
	Bus.bandit_added.emit()
	Bus.turn_finished.connect(_on_bus_turn_finished)


func random_walk() -> void:
	var valid_locations := get_valid_locations(Array([null], TYPE_OBJECT, &"Script", null))
	if valid_locations.size() > 0:
		await set_location(valid_locations.pick_random())


func set_location(value: Location) -> void:
	update_visible(value.visible)
	await super(value)
	if location.claim != null and not location.finished:
		location.claim.clear_path()


func die() -> void:
	bandits -= 1
	Bus.bandit_removed.emit()
	queue_free()


func update_visible(value: bool) -> void:
	create_tween().tween_property(self, ^"self_modulate",
			Color.WHITE if value else Color.TRANSPARENT, tween_time)


func _on_bus_turn_finished() -> void:
	just_added = false
