# Not going big on the node hierarchy, accessing things by groups.
class_name Map extends TileMapLayer


@export_group("Generation")
@export var connect_distance := 64.0
@export var decimation := 0.25
@export var random_offset := 24.0
@export var characters: Array[PackedScene]
@export_group("")
@export var max_turns := 50
@export var required_score := 50

var score := 0:
	set(value):
		score = value
		Bus.total_score_changed.emit(score)
		if score >= required_score:
			Bus.won.emit()

@onready var cards_manager: CardsManager = $CardsManager
# Must be @onready because of when @export variables are assigned
@onready var turns_left := max_turns:
	set(value):
		turns_left = value
		Bus.turns_left_changed.emit(turns_left)
		if turns_left <= 0:
			Bus.ended.emit(score)


func _ready() -> void:
	connect_distance = pow(connect_distance, 2.0)
	decimate()
	# IDK why, but this wurks while waiting a frame doesn't :P
	await get_tree().create_timer(0.0).timeout
	generate_connections()
	offset()
	spawn_characters()
	turns_left = turns_left # Call setter
	cards_manager.init_deck()


func decimate() -> void:
	for cell in get_used_cells():
		if randf() < decimation:
			erase_cell(cell)


func generate_connections() -> void:
	var locations: Array[Node] = get_tree().get_nodes_in_group(&"locations")
	var predecessors: Array[Location] = []
	for location: Location in locations:
		var nearest_loc: Location = null
		var nearest_dist := INF
		var connections := 0
		for predecessor in predecessors:
			var distance := predecessor.position.distance_squared_to(location.position)
			if nearest_loc == null or distance < nearest_dist:
				nearest_loc = predecessor
				nearest_dist = distance
			if distance <= connect_distance:
				create_connection(location, predecessor)
				connections += 1

		# Make sure there's at least 1 connection.
		# The null check is for the first location, when there won't be anything to connect to
		if nearest_loc != null and connections <= 0:
			create_connection(location, nearest_loc)

		predecessors.append(location)


func create_connection(a: Location, b: Location) -> void:
	const CONNECTION := preload("res://map/connection/connection.tscn")
	var connection: Connection = CONNECTION.instantiate()
	connection.a = a
	connection.b = b
	add_child(connection)
	move_child(connection, 0)

	a.connected_locations.append(b)
	b.connected_locations.append(a)
	a.connections.append(connection)
	b.connections.append(connection)


func offset() -> void:
	for location: Location in get_tree().get_nodes_in_group(&"locations"):
		location.position += Utils.rand_vec2_radial(random_offset)
	for connection: Connection in get_tree().get_nodes_in_group(&"connections"):
		connection.update()


func spawn_characters() -> void:
	var locations := get_tree().get_nodes_in_group(&"locations")
	locations.shuffle()
	for CHARACTER: PackedScene in characters:
		var character: Character = CHARACTER.instantiate()
		character.loop_scored.connect(_on_character_loop_scored)
		character.moved.connect(_on_character_moved)
		add_child(character)
		character.location = locations.pop_back()


func _on_character_loop_scored(_character: Character, loop_score: int) -> void:
	score += loop_score


func _on_character_moved(_character: Character, _location: Location) -> void:
	turns_left -= 1
