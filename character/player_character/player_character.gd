class_name PlayerCharacter extends Character


signal path_scored(character: PlayerCharacter, path_score: int)
signal unfinished_path_score_changed(character: PlayerCharacter, path_score: int)
signal moved(character: PlayerCharacter)

@export var path_color := Color()
@export var selected_color := Color.WHITE
@export_group("Scoring")
@export var clear_after_score := false
@export var connection_points := 0
@export var location_type_points := 0

var tracing := false
var paths: Array[Dictionary] = [{"locations": [], "connections": []}]

@onready var points_counter: Label = $PointsCounter
@onready var points := 0:
	set(value):
		points = value
		points_counter.text = str(points)


func _update_character_score() -> void:
	pass


func set_location(new_location: Location) -> void:
	var last_location := location
	await move_and_trace(new_location)
	_update_character_score()
	await activate_and_score(new_location)

	if last_location != null:
		moved.emit(self)


func move_and_trace(new_location: Location) -> void:
	var last_location := location
	await super.set_location(new_location)

	if last_location != null:
		var connection := last_location.get_connection_to_location(new_location)
		if tracing and connection:
			paths.back().connections.append(connection)
			connection.character = self

		new_location._draw_card()

	if new_location is Inn:
		tracing = true
	if tracing:
		new_location.claim = self
		paths.back().locations.append(new_location)
		for l: Location in paths.back().locations:
			l.update_points_counter(paths.back().locations)


func activate_and_score(new_location: Location) -> void:
	if new_location.character and new_location.character is Bandit:
		new_location.character.die()

	if new_location is Camp:
		@warning_ignore("redundant_await")
		await score_path()
	else:
		var score := get_path_score(-1)
		unfinished_path_score_changed.emit(self, score)
		Bus.character_unfinished_path_score_changed.emit(self, score)

	@warning_ignore("redundant_await")
	await location._activate()


func clear_path() -> void:
	tracing = false
	for l: Location in paths.back().locations:
		l.claim = null
		l.update_points_counter([])
	for c: Connection in paths.back().connections:
		c.character = null
	paths.back().locations = []
	paths.back().connections = []


func get_path_score(index: int) -> int:
	var score := 0
	for l: Location in paths[index].locations:
		score += l._get_points(paths[index].locations)
	return score + points


func score_path() -> void:
	var score := get_path_score(-1) * 2
	points *= 2
	@warning_ignore("shadowed_variable_base_class")
	for location: Location in paths.back().locations:
		location.update_points_counter(paths.back().locations, true)
		location.finished = true
	for connection: Connection in paths.back().connections:
		connection.set_completed()
	paths.append({"locations": [], "connections": []})
	tracing = false
	Bus.path_scored.emit(self, score)
	path_scored.emit(self, score)


func filter_character_connections(connection: Connection) -> bool:
	return connection.character == self


@warning_ignore("shadowed_variable_base_class")
func filter_character_locations(location: Location) -> bool:
	return location.claim == self


func _on_focus_entered() -> void:
	Bus.character_selected.emit(self)


func _on_focus_exited() -> void:
	Bus.character_deselected.emit(self)
