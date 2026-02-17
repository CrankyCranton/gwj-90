# Not going big on the node hierarchy, accessing things by groups.
class_name Map extends TileMapLayer


@export var max_turns := 50
@export_group("Generation")
@export var locations_distribution: Dictionary[PackedScene, int] = {}
@export var empty_space := 30
@export var connect_distance := 1.0
@export var random_offset := 0.35
@export var character_count := 5
@export var characters: Array[PackedScene]

var score := 0:
	set(value):
		score = value
		Bus.total_score_changed.emit(score)
		if score >= location_count:
			Bus.won.emit()
var location_count: int:
	set(_value):
		pass
	get:
		var total := 0
		for count: int in locations_distribution.values():
			total += count
		return total
var grid_size: Vector2i:
	set(_value):
		pass
	get:
		return Vector2i.ONE * ceili(sqrt(location_count + empty_space))

@onready var cards_manager: CardsManager = $CardsManager
# Must be @onready because of when @export variables are assigned
@onready var turns_left := max_turns:
	set(value):
		turns_left = value
		Bus.turns_left_changed.emit(turns_left)
		if turns_left <= 0:
			Bus.ended.emit(score)


func _ready() -> void:
	generate_locations()
	await get_tree().process_frame
	generate_connections()
	await get_tree().process_frame
	offset()
	spawn_characters()
	turns_left = turns_left # Call setter
	cards_manager.init_deck()


## Might be able to be combined with generate_connections() for optimization.
func generate_locations() -> void:
	var available_cells: Array[Vector2i] = []
	for y in grid_size.y:
		for x in grid_size.x:
			available_cells.append(Vector2i(x, y))
	available_cells.shuffle()

	for TYPE: PackedScene in locations_distribution:
		for i in locations_distribution[TYPE]:
			var location: Location = TYPE.instantiate()
			location.position_offset = map_to_local(available_cells.pop_back()) - location.size / 2.0
			add_sibling.call_deferred(location)


## Distance based. Might be changed to adjacency based in the future.
func generate_connections() -> void:
	var predecessors: Array[Location] = []
	var sorted_locations := get_tree().get_nodes_in_group(&"locations")
	for location: Location in sorted_locations:
		var nearest_loc: Location = null
		var nearest_dist := INF
		var connections := 0
		for predecessor in predecessors:
			var distance := predecessor.position.distance_squared_to(location.position)
			if nearest_loc == null or distance < nearest_dist:
				nearest_loc = predecessor
				nearest_dist = distance
			if distance <= pow(connect_distance * get_aprox_cell_size(), 2.0):
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
	add_sibling.call_deferred(connection)

	a.connected_locations.append(b)
	b.connected_locations.append(a)
	a.connections.append(connection)
	b.connections.append(connection)


func offset() -> void:
	for location: Location in get_tree().get_nodes_in_group(&"locations"):
		location.position_offset += Utils.rand_vec2_radial(random_offset * get_aprox_cell_size())
	for connection: Connection in get_tree().get_nodes_in_group(&"connections"):
		connection.update()


func spawn_characters() -> void:
	var inns := get_tree().get_nodes_in_group(&"inn")
	inns.shuffle()
	characters.shuffle()
	assert(character_count <= characters.size())
	for i in character_count:
		var character: Character = characters[i].instantiate()
		#character.offset = character.offset.rotated(float(i) / character_count * TAU)
		character.loop_scored.connect(_on_character_loop_scored)
		character.moved.connect(_on_character_moved)
		add_sibling.call_deferred(character)
		await character.ready
		character.location = inns.pop_back()


func get_aprox_cell_size() -> float:
	return (tile_set.tile_size.x + tile_set.tile_size.y) / 2.0


func _on_character_loop_scored(_character: Character, loop_score: int) -> void:
	score += loop_score


func _on_character_moved(_character: Character, _location: Location) -> void:
	turns_left -= 1
