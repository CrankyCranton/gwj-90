class_name Bandit extends Character


static var bandits := 0

var just_added := true


func _ready() -> void:
	super()
	modulate = Color.TRANSPARENT
	bandits += 1
	Bus.bandit_added.emit()
	Bus.turn_finished.connect(_on_bus_turn_finished)


func random_walk() -> void:
	var valid_locations := get_valid_locations(Array([null], TYPE_OBJECT, &"Script", null))
	if valid_locations.size() > 0:
		await set_location(valid_locations.pick_random())


func set_location(value: Location) -> void:
	await super(value)
	if location.claim != null and not location.finished:
		location.claim.clear_path()


func die() -> void:
	bandits -= 1
	Bus.bandit_removed.emit()
	queue_free()


func _on_bus_turn_finished() -> void:
	just_added = false
