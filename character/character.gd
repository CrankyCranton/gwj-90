class_name Character extends Button


signal moved(character: Character, location: Location)
signal path_scored(character: Character, path_score: int)
signal unfinished_path_score_changed(character: Character, path_score: int)

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
var tracing := false
var paths: Array[Dictionary] = [{"locations": [], "connections": []}]

# TODO Put most of movement handling in location.gd
## Set this to move the character.
@onready var location: Location = null:
	set(value):
		assert(value != null)

		var last_location := location
		location = value

		location.character = self

		if last_location != null:
			var connection := last_location.get_connection_to_location(location)
			if tracing and connection:
				paths.back().connections.append(connection)
				connection.character = self

			last_location.character = null
			location._draw_card()

		if location is Inn:
			tracing = true
		if tracing:
			location.claim = self
			paths.back().locations.append(location)
			for l: Location in paths.back().locations:
				l.update_points_counter(paths.back().locations)

		if location is Camp:
			score_path()
		else:
			var score := get_path_score(-1)
			unfinished_path_score_changed.emit(self, score)
			Bus.character_unfinished_path_score_changed.emit(self, score)

		tween_movement()
		location._activate()
		if last_location != null: # Redundant
			moved.emit(self, location)
			Bus.take_turn.emit()


func _ready() -> void:
	Bus.move_character.connect(_on_bus_move_character)
	Bus.fetch_valid_character_movement.connect(_on_bus_fetch_valid_character_movement)


func clear_path() -> void:
	tracing = false
	for l: Location in paths.back().locations:
		l.claim = null
		l.update_points_counter([])
	for c: Connection in paths.back().connections:
		c.character = null
	paths.back().locations = []
	paths.back().connections = []


func tween_movement() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(tween_ease).set_trans(tween_transition).tween_property(
			self, ^"position",
			location.position + (location.size - size) / 2.0 + offset, tween_time)


func score_path() -> void:
	var score := get_path_score(-1) * 2
	@warning_ignore("shadowed_variable")
	for location: Location in paths.back().locations:
		location.update_points_counter(paths.back().locations, true)
	for connection: Connection in paths.back().connections:
		connection.set_completed()
	paths.append({"locations": [], "connections": []})
	tracing = false
	Bus.path_scored.emit(self, score)
	path_scored.emit(self, score)


func get_path_score(index: int) -> int:
	var score := 0
	for l: Location in paths[index].locations:
		score += l._get_points(paths[index].locations)
	return score


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
