class_name Character extends Button


signal moved(character: Character, location: Location)
signal path_scored(character: Character, path_score: int)

@export var path_color := Color()
@export var selected_color := Color.WHITE
@export var offset := Vector2(16.0, 24.0)
@export_group("Scoring")
@export var clear_after_score := false
@export var connection_points := 0
@export var location_type_points := 0
@export_group("Tween", "tween")
@export var tween_time := 0.2
@export var tween_transition := Tween.TRANS_SINE
@export var tween_ease := Tween.EASE_IN_OUT

var tween: Tween
var drawing := false
var last_location: Location
var visited_location_types: Array[Script] = []
var paths: Array[Array] = []

## Set this to move the character.
@onready var location: Location = null:
	set(value):
		assert(value != null)
		if value is Inn:
			drawing = true
		if value is Camp:
			score_path()
		if location:
			location.get_connection_to_location(value).character = self
			location.character = null
			last_location = location
			moved.emit(self, value)

		# NOTICE location is only assigned to value at this point.
		# In the code above this, "location" is the old location.
		location = value
		if not visited_location_types.has(location.get_script()):
			visited_location_types.append(location.get_script())
		location.character = self
		location.claim = self

		tween_movement()
		location.lift_fow()


func _ready() -> void:
	Bus.move_character.connect(_on_bus_move_character)
	Bus.fetch_valid_character_movement.connect(_on_bus_fetch_valid_character_movement)


func tween_movement() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(tween_ease).set_trans(tween_transition).tween_property(
			self, ^"position",
			location.position + (location.size - size) / 2.0 + offset, tween_time)


func score_path() -> void:
	var score := visited_location_types.size() * location_type_points

	for i: Connection in get_tree().get_nodes_in_group(&"connections").filter(
				filter_character_connections):
		score += connection_points
		if clear_after_score:
			i.character = null
	for i: Location in get_tree().get_nodes_in_group(&"locations").filter(
			filter_character_locations):
				if clear_after_score:
					i.claim = null

	# TODO Remove print statements after they're no longer needed
	print(self, ": Loop completed! Score: ", score)
	print("\tLocations visited: ", visited_location_types)
	visited_location_types.clear()
	Bus.path_scored.emit(self, score)
	path_scored.emit(self, score)


func filter_character_connections(connection: Connection) -> bool:
	return connection.character == self


@warning_ignore("shadowed_variable")
func filter_character_locations(location: Location) -> bool:
	return location.claim == self


@warning_ignore("shadowed_variable")
func _on_bus_move_character(character: Character, location: Location) -> void:
	if character != self:
		return
	assert(location in self.location.connected_locations)

	self.location = location


func _on_bus_fetch_valid_character_movement(character: Character,
		valid_location_types: Array[Script]) -> void:
	if character != self:
		return
	Bus.return_valid_character_movement.emit(self, location.get_valid_locations(valid_location_types))


func _on_focus_entered() -> void:
	Bus.character_selected.emit(self)


func _on_focus_exited() -> void:
	Bus.character_deselected.emit(self)
