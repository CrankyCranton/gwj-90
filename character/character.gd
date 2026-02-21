class_name Character extends Control


@export var offset := Vector2(16.0, 24.0)
@export var can_walk_on_path := false
@export var can_walk_on_enemies := false
@export_group("Tween", "tween")
@export var tween_time := 1.0
@export var tween_transition := Tween.TRANS_SINE
@export var tween_ease := Tween.EASE_OUT

var tween: Tween

@onready var location: Location = null


func _ready() -> void:
	Bus.fetch_valid_character_movement.connect(_on_bus_fetch_valid_character_movement)


func set_location(value: Location) -> void:
	assert(value != null)
	var last_location := location
	location = value
	location.character = self

	var target_position := location.position + (location.size - size) / 2.0 + offset
	if last_location != null:
		last_location.character = null
		await tween_movement(target_position)
	else:
		position = target_position


func tween_movement(target: Vector2) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_ease(tween_ease).set_trans(tween_transition).tween_property(
			self, ^"position",
			target, tween_time)
	await tween.finished


# Made input argument "valid_types" an array, in case it needs to display the
# valid locations for all the card types you have in hand.
## Null is a wildcard.
func get_valid_locations(valid_types: Array[Script] = []) -> Array[Location]:
	@warning_ignore("shadowed_variable")
	return location.connected_locations.filter(
		func(location: Location) -> bool:
			# Might be about time to split this bad boy into a multi-liner
			return (self.location is Hill or location is Lake or valid_types.has(null) \
					or location.get_script() in valid_types) \
					and ((can_walk_on_enemies and location.character != null \
					and location.character is Bandit) \
					or location.character == null) \
					and (can_walk_on_path \
					or (location.claim == null \
					and self.location.get_connection_to_location(location).character == null)) \
	)


func _on_bus_fetch_valid_character_movement(character: Character,
		valid_location_types: Array[Script]) -> void:
	if character != self:
		return
	Bus.return_valid_character_movement.emit(self, get_valid_locations(valid_location_types))
