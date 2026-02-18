# Not going big on the node hierarchy, accessing things by groups.
class_name Map extends Control


@export var max_turns := 50
@export_group("Generation")
@export var max_radius := 2048.0
@export var min_distance := 64.0
@export var max_distance := 256.0
@export var generate_from_rect_center := false
# I have no idea what this does, so I just exported it and used the demo value
@export var retries := 30
@export var character_count := 5
@export var characters: Array[PackedScene]
@export var locations_distribution: Dictionary[PackedScene, int] = {}

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

# Must be @onready because of when @export variables are assigned
@onready var turns_left := max_turns:
	set(value):
		turns_left = value
		Bus.turns_left_changed.emit(turns_left)
		if turns_left <= 0:
			Bus.ended.emit(score)


func _ready() -> void:
	generate_locations()
	generate_connections()
	spawn_characters()
	CardsManager.init_deck()
	turns_left = turns_left # Call setter


## Might be able to be combined with generate_connections() for optimization.
func generate_locations() -> void:
	var pos := size / 2.0 if generate_from_rect_center else Vector2.ZERO
	var available_points := PoissonDiscSampling.generate_points_for_circle(pos,
			max_radius, min_distance, 30, Vector2.INF, location_count)

	var i := 0
	for TYPE: PackedScene in locations_distribution:
		for j in locations_distribution[TYPE]:
			var location: Location = TYPE.instantiate()
			location.position = available_points[i] - location.size / 2.0
			add_child(location)
			i += 1


func generate_connections() -> void:
	var locations: Array[Location] = Array(get_tree().get_nodes_in_group(&"locations"),
			TYPE_OBJECT, &"Button", preload("uid://kttdtllwq2rh"))
	var locations_positions: PackedVector2Array = []
	for location: Location in locations:
		locations_positions.append(location.position)

	var indicies := Geometry2D.triangulate_delaunay(locations_positions)
	print(indicies)
	const STEP := 3
	for i in range(0, indicies.size() - (STEP - 1), STEP):
		print(i)
		for j in range(i, i + STEP):
			var connect_index := wrapi(j, i, i + STEP - 2)
			var from := locations[indicies[j]]
			var to := locations[indicies[connect_index]]
			if not from.is_connected_to_location(to) \
					and from.position.distance_to(to.position) <= max_distance:
				create_connection(from, to)


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
	connection.update()


func spawn_characters() -> void:
	var inns := get_tree().get_nodes_in_group(&"inn")
	inns.shuffle()
	characters.shuffle()
	assert(character_count <= characters.size())
	for i in character_count:
		var character: Character = characters[i].instantiate()
		#character.offset = character.offset.rotated(float(i) / character_count * TAU)
		character.path_scored.connect(_on_character_path_scored)
		character.moved.connect(_on_character_moved)
		add_child(character)
		character.location = inns.pop_back()


func _on_character_path_scored(_character: Character, path_score: int) -> void:
	score += path_score


func _on_character_moved(_character: Character, _location: Location) -> void:
	turns_left -= 1
