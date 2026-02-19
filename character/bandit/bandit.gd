class_name Bandit extends Character


static var bandits := 0


func _ready() -> void:
	bandits += 1
	Bus.bandit_added.emit()


func random_walk() -> void:
	var valid_locations := get_valid_locations(Array([null], TYPE_OBJECT, &"Script", null))
	if valid_locations.size() > 0:
		set_location(valid_locations.pick_random())


func set_location(value: Location) -> void:
	super(value)
	if location.claim != null and not location.finished:
		location.claim.clear_path()


func die() -> void:
	bandits -= 1
	Bus.bandit_removed.emit()
	queue_free()
